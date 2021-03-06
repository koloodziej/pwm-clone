/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2012 The PWM Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

package password.pwm.servlet;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.novell.ldapchai.ChaiFactory;
import com.novell.ldapchai.ChaiUser;
import com.novell.ldapchai.cr.ChaiCrFactory;
import com.novell.ldapchai.cr.ChaiResponseSet;
import com.novell.ldapchai.cr.Challenge;
import com.novell.ldapchai.cr.ChallengeSet;
import com.novell.ldapchai.exception.ChaiError;
import com.novell.ldapchai.exception.ChaiUnavailableException;
import com.novell.ldapchai.exception.ChaiValidationException;
import com.novell.ldapchai.provider.ChaiProvider;
import password.pwm.*;
import password.pwm.bean.ResponseInfoBean;
import password.pwm.bean.SessionStateBean;
import password.pwm.bean.SetupResponsesBean;
import password.pwm.bean.UserInfoBean;
import password.pwm.config.Message;
import password.pwm.config.PwmSetting;
import password.pwm.error.*;
import password.pwm.util.PwmLogger;
import password.pwm.util.ServletHelper;
import password.pwm.util.operations.CrUtility;
import password.pwm.util.stats.Statistic;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * User interaction servlet for setting up secret question/answer
 *
 * @author Jason D. Rivard
 */
public class SetupResponsesServlet extends TopServlet {
// ------------------------------ FIELDS ------------------------------

    private static final PwmLogger LOGGER = PwmLogger.getLogger(SetupResponsesServlet.class);

// -------------------------- OTHER METHODS --------------------------

    protected void processRequest(
            final HttpServletRequest req,
            final HttpServletResponse resp
    )
            throws ServletException, ChaiUnavailableException, IOException, PwmUnrecoverableException {
        // fetch the required beans / managers
        final PwmSession pwmSession = PwmSession.getPwmSession(req);
        final PwmApplication pwmApplication = ContextManager.getPwmApplication(req);
        final SessionStateBean ssBean = pwmSession.getSessionStateBean();
        final UserInfoBean uiBean = pwmSession.getUserInfoBean();
        final ChallengeSet assignedCs = uiBean.getChallengeSet();

        if (!pwmApplication.getConfig().readSettingAsBoolean(PwmSetting.CHALLENGE_ENABLE)) {
            PwmSession.getPwmSession(req).getSessionStateBean().setSessionError(PwmError.ERROR_SERVICE_NOT_AVAILABLE.toInfo());
            ServletHelper.forwardToErrorPage(req, resp, this.getServletContext());
            return;
        }

        // read the action request parameter
        final String actionParam = Validator.readStringFromRequest(req, PwmConstants.PARAM_ACTION_REQUEST);

        // check to see if the user is permitted to setup responses
        if (!Permission.checkPermission(Permission.SETUP_RESPONSE, pwmSession, pwmApplication)) {
            ssBean.setSessionError(new ErrorInformation(PwmError.ERROR_UNAUTHORIZED));
            ServletHelper.forwardToErrorPage(req, resp, this.getServletContext());
            return;
        }

        // check to see if the user has any challenges assigned
        if (assignedCs == null || assignedCs.getChallenges().isEmpty()) {
            ssBean.setSessionError(new ErrorInformation(PwmError.ERROR_NO_CHALLENGES));
            LOGGER.debug(pwmSession, "no challenge sets configured for user " + uiBean.getUserDN());
            ServletHelper.forwardToErrorPage(req, resp, this.getServletContext());
            return;
        }

        populateBean(pwmSession, pwmApplication, assignedCs);

        if (actionParam != null && actionParam.length() > 0) {
            Validator.validatePwmFormID(req);

            // handle the requested action.
            if ("validateResponses".equalsIgnoreCase(actionParam)) {
                handleValidateResponses(req, resp, assignedCs);
                return;
            } else if ("setResponses".equalsIgnoreCase(actionParam)) {
                handleSetupResponses(req, resp, assignedCs);
                return;
            } else if ("confirmResponses".equalsIgnoreCase(actionParam)) {
                handleConfirmResponses(req, resp);
                return;
            } else if ("changeResponses".equalsIgnoreCase(actionParam)) {
                this.forwardToJSP(req, resp);
                return;
            }
        }

        this.forwardToJSP(req, resp);
    }

    /**
     * Handle requests for ajax feedback of user supplied responses.
     *
     * @param req          HttpRequest
     * @param resp         HttpResponse
     * @param challengeSet Assigned challenges
     * @throws IOException              for an IO error
     * @throws ServletException         for an http servlet error
     * @throws password.pwm.error.PwmUnrecoverableException             for any unexpected error
     * @throws ChaiUnavailableException if the ldap directory becomes unavailable
     */
    protected static void handleValidateResponses(
            final HttpServletRequest req,
            final HttpServletResponse resp,
            final ChallengeSet challengeSet
    )
            throws IOException, ServletException, PwmUnrecoverableException, ChaiUnavailableException
    {
        final PwmSession pwmSession = PwmSession.getPwmSession(req);
        final PwmApplication pwmApplication = ContextManager.getPwmApplication(req);

        boolean success = true;
        String userMessage = Message.getLocalizedMessage(pwmSession.getSessionStateBean().getLocale(), Message.SUCCESS_RESPONSES_MEET_RULES, pwmApplication.getConfig());

        try {
            // read in the responses from the request
            final Map<Challenge, String> responseMap = readResponsesFromJsonRequest(req, pwmSession, challengeSet);
            CrUtility.validateResponses(pwmApplication, challengeSet, responseMap);
            generateResponseInfoBean(pwmSession, challengeSet, responseMap);
        } catch (PwmDataValidationException e) {
            success = false;
            userMessage = e.getErrorInformation().toUserStr(pwmSession, pwmApplication);
        }

        final Map<String, String> outputMap = new HashMap<String, String>();
        outputMap.put("version", "1");
        outputMap.put("message", userMessage);
        outputMap.put("success", String.valueOf(success));

        final Gson gson = new Gson();
        final String output = gson.toJson(outputMap);

        resp.setContentType("text/plain;charset=utf-8");
        resp.getWriter().print(output);

        LOGGER.trace(pwmSession, "ajax validate responses: " + output);
    }

    private void handleSetupResponses(
            final HttpServletRequest req,
            final HttpServletResponse resp,
            final ChallengeSet challengeSet
    )
            throws PwmUnrecoverableException, IOException, ServletException, ChaiUnavailableException
    {
        final PwmSession pwmSession = PwmSession.getPwmSession(req);
        final PwmApplication pwmApplication = ContextManager.getPwmApplication(req);
        final SessionStateBean ssBean = pwmSession.getSessionStateBean();

        final ResponseInfoBean responses;
        final Map<Challenge, String> responseMap;
        try {
            // build a response set based on the user's challenge set and the html form response.
            responseMap = readResponsesFromHttpRequest(req, pwmSession, challengeSet);
            CrUtility.validateResponses(pwmApplication, challengeSet, responseMap);
            responses = generateResponseInfoBean(pwmSession, challengeSet, responseMap);
        } catch (PwmDataValidationException e) {
            LOGGER.debug(pwmSession, "error with user's supplied new responses: " + e.getErrorInformation().toDebugStr());
            ssBean.setSessionError(e.getErrorInformation());
            this.forwardToJSP(req, resp);
            return;
        }

        LOGGER.trace(pwmSession, "user's supplied new responses appear to be acceptable");

        if (pwmApplication.getConfig().readSettingAsBoolean(PwmSetting.CHALLENGE_SHOW_CONFIRMATION)) {
            pwmSession.getSetupResponseBean().setResponseMap(responseMap);
            this.forwardToConfirmJSP(req, resp);
        } else {
            try {
                saveResponses(pwmSession, pwmApplication, responses);
            } catch (PwmOperationalException e) {
                LOGGER.error(pwmSession, e.getErrorInformation().toDebugStr());
                pwmSession.getSessionStateBean().setSessionError(e.getErrorInformation());
                this.forwardToJSP(req, resp);
                return;
            } catch (ChaiValidationException e) {
                LOGGER.error(pwmSession, e.getMessage());
                pwmSession.getSessionStateBean().setSessionError(new ErrorInformation(PwmError.ERROR_MISSING_RANDOM_RESPONSE,e.getMessage()));
                this.forwardToConfirmJSP(req, resp);
                return;
            }

            ServletHelper.forwardToSuccessPage(req, resp);
        }
    }

    private void handleConfirmResponses(
            final HttpServletRequest req,
            final HttpServletResponse resp
    )
            throws PwmUnrecoverableException, IOException, ServletException, ChaiUnavailableException
    {

        final PwmSession pwmSession = PwmSession.getPwmSession(req);
        final PwmApplication pwmApplication = ContextManager.getPwmApplication(req);

        Validator.validatePwmFormID(req);

        final Map<Challenge, String> responseMap = pwmSession.getSetupResponseBean().getResponseMap();
        if (responseMap != null && !responseMap.isEmpty()) {
            try {
                final ChallengeSet challengeSet = pwmSession.getUserInfoBean().getChallengeSet();
                CrUtility.validateResponses(pwmApplication, challengeSet, responseMap);
                final ResponseInfoBean responses = generateResponseInfoBean(pwmSession, challengeSet, responseMap);
                saveResponses(pwmSession, pwmApplication, responses);
            } catch (PwmOperationalException e) {
                LOGGER.error(pwmSession, e.getErrorInformation().toDebugStr());
                pwmSession.getSessionStateBean().setSessionError(e.getErrorInformation());
                this.forwardToConfirmJSP(req, resp);
                return;
            } catch (ChaiValidationException e) {
                LOGGER.error(pwmSession, e.getMessage());
                pwmSession.getSessionStateBean().setSessionError(new ErrorInformation(PwmError.ERROR_MISSING_RANDOM_RESPONSE,e.getMessage()));
                this.forwardToConfirmJSP(req, resp);
                return;
            }
        }

        ServletHelper.forwardToSuccessPage(req, resp);
    }

    private void saveResponses(final PwmSession pwmSession, final PwmApplication pwmApplication, final ResponseInfoBean responseInfoBean)
            throws PwmUnrecoverableException, ChaiUnavailableException, PwmOperationalException, ChaiValidationException
    {
        final ChaiUser theUser = pwmSession.getSessionManager().getActor();
        final String userGUID = pwmSession.getUserInfoBean().getUserGuid();
        CrUtility.writeResponses(pwmSession, pwmApplication, theUser, userGUID, responseInfoBean);
        final UserInfoBean uiBean = pwmSession.getUserInfoBean();
        UserStatusHelper.populateActorUserInfoBean(pwmSession, pwmApplication, uiBean.getUserDN(), uiBean.getUserCurrentPassword());
        pwmApplication.getStatisticsManager().incrementValue(Statistic.SETUP_RESPONSES);
        pwmSession.getUserInfoBean().setRequiresResponseConfig(false);
        pwmSession.getSessionStateBean().setSessionSuccess(Message.SUCCESS_SETUP_RESPONSES, null);
        UserHistory.updateUserHistory(pwmSession, pwmApplication, UserHistory.Record.Event.SET_RESPONSES, null);
    }

    private static Map<Challenge, String> readResponsesFromHttpRequest(
            final HttpServletRequest req,
            final PwmSession pwmSession,
            final ChallengeSet challengeSet)
            throws PwmDataValidationException, PwmUnrecoverableException {
        final Map<String, String> inputMap = new HashMap<String, String>();

        for (Enumeration nameEnum = req.getParameterNames(); nameEnum.hasMoreElements();) {
            final String paramName = nameEnum.nextElement().toString();
            final String paramValue = Validator.readStringFromRequest(req, paramName);
            inputMap.put(paramName, paramValue);
        }

        return paramMapToChallengeMap(inputMap, pwmSession, challengeSet);
    }

    private static Map<Challenge, String> readResponsesFromJsonRequest(
            final HttpServletRequest req,
            final PwmSession pwmSession,
            final ChallengeSet challengeSet)
            throws PwmDataValidationException, PwmUnrecoverableException, IOException {
        final Map<String, String> inputMap = new HashMap<String, String>();

        final String bodyString = ServletHelper.readRequestBody(req, 10 * 1024);

        final Gson gson = new Gson();
        final Map<String, String> srcMap = gson.fromJson(bodyString, new TypeToken<Map<String, String>>() {
        }.getType());

        if (srcMap == null) {
            return null;
        }

        for (final String key : srcMap.keySet()) {
            final String paramValue = srcMap.get(key);
            inputMap.put(key, paramValue);
        }

        return paramMapToChallengeMap(inputMap, pwmSession, challengeSet);
    }

    private static Map<Challenge, String> paramMapToChallengeMap(
            final Map<String, String> inputMap,
            final PwmSession pwmSession,
            final ChallengeSet challengeSet
    )
            throws PwmDataValidationException, PwmUnrecoverableException
    {
        final List<ErrorInformation> errorInformations = new ArrayList<ErrorInformation>();

        { // check for duplicate questions.  need to check the actual req params because the following dupes wont populate duplicates
            final Set<String> questionTexts = new HashSet<String>();
            for (final String paramName : inputMap.keySet()) {
                final String paramValue = inputMap.get(paramName);
                if (paramValue != null && paramValue.length() > 0 && paramName.startsWith(PwmConstants.PARAM_QUESTION_PREFIX)) {
                    if (questionTexts.contains(paramValue.toLowerCase())) {
                        errorInformations.add(new ErrorInformation(PwmError.ERROR_CHALLENGE_DUPLICATE,null,paramName));
                    } else {
                        questionTexts.add(paramValue.toLowerCase());
                    }
                }
            }
        }

        final Map<Challenge, String> readResponses = new LinkedHashMap<Challenge, String>();
        final SetupResponsesBean responsesBean = pwmSession.getSetupResponseBean();

        { // read in the question texts and responses
            for (final String indexKey : responsesBean.getIndexedChallenges().keySet()) {
                final Challenge loopChallenge = responsesBean.getIndexedChallenges().get(indexKey);
                if (loopChallenge.isRequired() || !responsesBean.isSimpleMode()) {

                    if (!loopChallenge.isAdminDefined()) {
                        final String questionText = inputMap.get(PwmConstants.PARAM_QUESTION_PREFIX + indexKey);
                        loopChallenge.setChallengeText(questionText);
                    }

                    final String answer = inputMap.get(PwmConstants.PARAM_RESPONSE_PREFIX + indexKey);

                    if (answer.length() > 0) {
                        readResponses.put(loopChallenge, answer);
                    }
                }
            }

            if (responsesBean.isSimpleMode()) { // if in simple mode, read the select-based random challenges

                for (int i = 0; i < responsesBean.getIndexedChallenges().size(); i++) {
                    final String questionText = inputMap.get(PwmConstants.PARAM_QUESTION_PREFIX + "Random_" + String.valueOf(i));

                    Challenge challenge = null;
                    for (final Challenge loopC : challengeSet.getRandomChallenges()) {
                        if (loopC.isAdminDefined() && questionText != null && questionText.equals(loopC.getChallengeText())) {
                            challenge = loopC;
                            break;
                        }
                    }

                    final String answer = inputMap.get(PwmConstants.PARAM_RESPONSE_PREFIX + "Random_" + String.valueOf(i));
                    if (answer != null && answer.length() > 0) {
                        readResponses.put(challenge, answer);
                    }
                }
            }
        }

        if (!errorInformations.isEmpty()) {
            throw new PwmDataValidationException(errorInformations.get(0));
        }

        return readResponses;
    }


    private static ResponseInfoBean generateResponseInfoBean(
            final PwmSession pwmSession,
            final ChallengeSet challengeSet,
            final Map<Challenge, String> readResponses
    )
            throws ChaiUnavailableException, PwmDataValidationException, PwmUnrecoverableException {
        final ChaiProvider provider = pwmSession.getSessionManager().getChaiProvider();
        final ChaiUser actor = ChaiFactory.createChaiUser(pwmSession.getUserInfoBean().getUserDN(), provider);

        try {
            final ResponseInfoBean responseInfoBean = new ResponseInfoBean(
                    readResponses,
                    challengeSet.getLocale(),
                    challengeSet.getMinRandomRequired(),
                    challengeSet.getIdentifier()
            );

            final ChaiResponseSet responseSet = ChaiCrFactory.newChaiResponseSet(
                    readResponses,
                    challengeSet.getLocale(),
                    challengeSet.getMinRandomRequired(),
                    provider.getChaiConfiguration(),
                    challengeSet.getIdentifier());

            responseSet.meetsChallengeSetRequirements(challengeSet);

            final int minRandomRequiredSetup = pwmSession.getSetupResponseBean().getMinRandomSetup();
            if (minRandomRequiredSetup == 0) { // if using recover style, then all readResponses must be supplied at this point.
                if (responseSet.getChallengeSet().getRandomChallenges().size() < challengeSet.getRandomChallenges().size()) {
                    throw new ChaiValidationException("too few random responses", ChaiError.CR_TOO_FEW_RANDOM_RESPONSES);
                }
            }

            return responseInfoBean;
        } catch (ChaiValidationException e) {
            final ErrorInformation errorInfo = convertChaiValidationException(e);
            throw new PwmDataValidationException(errorInfo);
        }
    }

    private void forwardToJSP(
            final HttpServletRequest req,
            final HttpServletResponse resp
    )
            throws IOException, ServletException {
        this.getServletContext().getRequestDispatcher('/' + PwmConstants.URL_JSP_SETUP_RESPONSES).forward(req, resp);
    }

    private void forwardToConfirmJSP(
            final HttpServletRequest req,
            final HttpServletResponse resp
    )
            throws IOException, ServletException {
        this.getServletContext().getRequestDispatcher('/' + PwmConstants.URL_JSP_CONFIRM_RESPONSES).forward(req, resp);
    }

    private static ErrorInformation convertChaiValidationException(
            final ChaiValidationException e
    ) {
        switch (e.getErrorCode()) {
            case CR_TOO_FEW_CHALLENGES:
                return new ErrorInformation(PwmError.ERROR_MISSING_REQUIRED_RESPONSE, null, e.getFieldName());

            case CR_TOO_FEW_RANDOM_RESPONSES:
                return new ErrorInformation(PwmError.ERROR_MISSING_RANDOM_RESPONSE, null, e.getFieldName());

            case CR_MISSING_REQUIRED_CHALLENGE_TEXT:
                return new ErrorInformation(PwmError.ERROR_MISSING_CHALLENGE_TEXT, null, e.getFieldName());

            case CR_RESPONSE_TOO_LONG:
                return new ErrorInformation(PwmError.ERROR_RESPONSE_TOO_LONG, null, e.getFieldName());

            case CR_RESPONSE_TOO_SHORT:
            case CR_MISSING_REQUIRED_RESPONSE_TEXT:
                return new ErrorInformation(PwmError.ERROR_RESPONSE_TOO_SHORT, null, e.getFieldName());

            case CR_DUPLICATE_RESPONSES:
                return new ErrorInformation(PwmError.ERROR_RESPONSE_DUPLICATE, null, e.getFieldName());

            default:
                return new ErrorInformation(PwmError.ERROR_UNKNOWN);
        }
    }

    private void populateBean(final PwmSession pwmSession, final PwmApplication pwmApplication, final ChallengeSet challengeSet)
            throws PwmUnrecoverableException
    {
        int minRandomSetup;
        boolean useSimple = true;
        final Map<String, Challenge> indexedChallenges = new LinkedHashMap<String, Challenge>();

        {
            minRandomSetup = (int) pwmApplication.getConfig().readSettingAsLong(PwmSetting.CHALLENGE_MIN_RANDOM_SETUP);
            if (minRandomSetup != 0 && minRandomSetup < challengeSet.getMinRandomRequired()) {
                minRandomSetup = challengeSet.getMinRandomRequired();
            }
            if (minRandomSetup > challengeSet.getRandomChallenges().size()) {
                minRandomSetup = 0;
            }
        }
        {
            {
                if (minRandomSetup == 0) {
                    useSimple = false;
                }

                for (final Challenge challenge : challengeSet.getChallenges()) {
                    if (!challenge.isRequired() && !challenge.isAdminDefined()) {
                        useSimple = false;
                    }
                }

                if (challengeSet.getRandomChallenges().size() == challengeSet.getMinRandomRequired()) {
                    useSimple = false;
                }
            }
        }

        {
            int i = 0;
            for (final Challenge loopChallenge : challengeSet.getChallenges()) {
                indexedChallenges.put(String.valueOf(i), loopChallenge);
                i++;
            }
        }

        pwmSession.getSetupResponseBean().setSimpleMode(useSimple);
        pwmSession.getSetupResponseBean().setChallengeList(indexedChallenges);
        pwmSession.getSetupResponseBean().setMinRandomSetup(minRandomSetup);
    }
}

