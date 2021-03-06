/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2010 The PWM Project
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

package password.pwm;

import com.novell.ldapchai.ChaiUser;
import com.novell.ldapchai.cr.*;
import com.novell.ldapchai.exception.ChaiException;
import com.novell.ldapchai.exception.ChaiOperationException;
import com.novell.ldapchai.exception.ChaiUnavailableException;
import com.novell.ldapchai.exception.ChaiValidationException;
import com.novell.ldapchai.provider.ChaiProvider;
import password.pwm.config.PwmSetting;
import password.pwm.util.PwmLogger;
import password.pwm.util.TimeDuration;
import password.pwm.ws.client.novell.pwdmgt.*;

import javax.xml.rpc.Stub;
import java.io.Serializable;
import java.net.URL;
import java.rmi.RemoteException;
import java.util.*;

/**
 * @author Jason D. Rivard
 */
public class CrUtility {
    private static final PwmLogger LOGGER = PwmLogger.getLogger(CrUtility.class);

    private CrUtility() {
    }

    public static ChallengeSet readUserChallengeSet(
            final PwmSession pwmSession,
            final ChaiUser theUser,
            final PwmPasswordPolicy policy,
            final Locale locale
    )
    {
        final long methodStartTime = System.currentTimeMillis();

        ChallengeSet returnSet = null;

        if (pwmSession.getConfig().readSettingAsBoolean(PwmSetting.EDIRECTORY_READ_CHALLENGE_SET)) {
            try {
                if (pwmSession.getContextManager().getProxyChaiProvider().getDirectoryVendor() == ChaiProvider.DIRECTORY_VENDOR.NOVELL_EDIRECTORY) {
                    if (policy != null && policy.getChaiPasswordPolicy() != null) {
                        returnSet = CrFactory.readAssignedChallengeSet(theUser.getChaiProvider(), policy.getChaiPasswordPolicy(), locale);
                    }

                    if (returnSet == null) {
                        returnSet = CrFactory.readAssignedChallengeSet(theUser, locale);
                    }

                    if (returnSet == null) {
                        LOGGER.debug(pwmSession, "no nmas c/r policy found for user " + theUser.getEntryDN());
                    } else {
                        LOGGER.debug(pwmSession, "using nmas c/r policy for user " + theUser.getEntryDN() + ": " + returnSet.toString());
                    }
                }
            } catch (ChaiException e) {
                LOGGER.error(pwmSession, "error reading nmas c/r policy for user " + theUser.getEntryDN() + ": " + e.getMessage());
            }
        }

        // use PWM policies if PWM is configured and either its all that is configured OR the NMAS policy read was not successfull
        if (returnSet == null) {
            returnSet = pwmSession.getContextManager().getConfig().getGlobalChallengeSet(pwmSession.getSessionStateBean().getLocale());
            if (returnSet != null) {
                LOGGER.debug(pwmSession, "using pwm c/r policy for user " + theUser.getEntryDN() + ": " + returnSet.toString());
            }
        }

        if (returnSet == null) {
            LOGGER.warn(pwmSession, "no available c/r policy for user" + theUser.getEntryDN() + ": ");
        }

        LOGGER.trace(pwmSession, "readUserChallengeSet completed in " + TimeDuration.fromCurrent(methodStartTime).asCompactString());

        return returnSet;
    }

    public static ResponseSet readUserResponseSet(final PwmSession pwmSession, final ChaiUser theUser)
            throws ChaiUnavailableException
    {
        ResponseSet userResponseSet = null;

        final String novellUserAppWebServiceURL = pwmSession.getConfig().readSettingAsString(PwmSetting.EDIRECTORY_PWD_MGT_WEBSERVICE_URL);

        if (novellUserAppWebServiceURL != null && novellUserAppWebServiceURL.length() > 0) {
            try {
                LOGGER.trace(pwmSession, "establishing connection to web service at " + novellUserAppWebServiceURL);
                final PasswordManagementServiceLocator locater = new PasswordManagementServiceLocator();
                final PasswordManagement service = locater.getPasswordManagementPort(new URL(novellUserAppWebServiceURL));
                ((Stub)service)._setProperty(javax.xml.rpc.Stub.SESSION_MAINTAIN_PROPERTY, Boolean.TRUE);
                final ProcessUserRequest userRequest = new ProcessUserRequest(theUser.getEntryDN());
                final ForgotPasswordWSBean processUserResponse = service.processUser(userRequest);
                if (processUserResponse.isTimeout()) {
                    LOGGER.error(pwmSession, "novell web service reports timeout: " + processUserResponse.getMessage());
                    return null;
                }
                if (processUserResponse.isError()) {
                    LOGGER.error(pwmSession, "novell web service reports error: " + processUserResponse.getMessage());
                    return null;
                }
                return new NovellWSResponseSet(service, processUserResponse, pwmSession);
            } catch (Throwable e) {
                LOGGER.error(pwmSession, "error retrieving novell user responses from web service: " + e.getMessage());
                return null;
            }
        }

        try {
            userResponseSet = theUser.readResponseSet();
        } catch (ChaiOperationException e) {
            LOGGER.debug(pwmSession, "ldap error reading response set: " + e.getMessage());
        }

        return userResponseSet;
    }

    public static class NovellWSResponseSet implements ResponseSet, Serializable {
        private transient final PasswordManagement service;
        private final String userDN;
        private final ChallengeSet challengeSet;
        private final PwmSession pwmSession;

        public NovellWSResponseSet(
                final PasswordManagement service,
                final ForgotPasswordWSBean wsBean,
                final PwmSession pwmSession
        )
                throws ChaiValidationException
        {
            this.userDN = wsBean.getUserDN();
            this.service = service;
            this.pwmSession = pwmSession;
            final List<Challenge> challenges = new ArrayList<Challenge>();
            for (final String loopQuestion : wsBean.getChallengeQuestions()) {
                final Challenge loopChallenge = CrFactory.newChallenge(
                        true,
                        loopQuestion,
                        1,
                        255,
                        true
                );
                challenges.add(loopChallenge);
            }
            challengeSet = CrFactory.newChallengeSet(challenges,Locale.getDefault(),0,"NovellWSResponseSet derived ChallengeSet");
        }

        public ChallengeSet getChallengeSet() {
            return challengeSet;
        }

        public boolean meetsChallengeSetRequirements(final ChallengeSet challengeSet) {
            return challengeSet.getAdminDefinedChallenges().size() > 0 || challengeSet.getMinRandomRequired() > 0;
        }

        public String stringValue() throws UnsupportedOperationException {
            return "NovellWSResponseSet derived ResponseSet";
        }

        public boolean test(final Map<Challenge, String> responseTest) throws ChaiUnavailableException {
            if (service == null) {
                LOGGER.error(pwmSession,"beginning web service 'processChaRes' response test, however service bean is not in session memory, aborting response test...");
                return false;
            }
            LOGGER.trace(pwmSession,"beginning web service 'processChaRes' response test ");
            final String[] responseArray = new String[challengeSet.getAdminDefinedChallenges().size()];
            {
                int i = 0;
                for (final Challenge loopChallenge : challengeSet.getAdminDefinedChallenges()) {
                    final String loopResponse = responseTest.get(loopChallenge);
                    responseArray[i] = loopResponse;
                    i++;
                }
            }
            final ProcessChaResRequest request = new ProcessChaResRequest();
            request.setChaAnswers(responseArray);
            request.setUserDN(userDN);

            try {
                final ForgotPasswordWSBean response = service.processChaRes(request);
                if (response.isTimeout()) {
                    LOGGER.error(pwmSession, "NovellWSResponseSet: web service reports timeout: " + response.getMessage());
                    return false;
                }
                if (response.isError()) {
                    if ("Account restrictions prevent you from logging in. See your administrator for more details.".equals(response.getMessage())) {
                        //throw PwmException.createPwmException(PwmError.ERROR_INTRUDER_USER);
                    }
                    LOGGER.error(pwmSession, "NovellWSResponseSet: web service reports error: " + response.getMessage());
                    return false;
                }
                LOGGER.debug(pwmSession,"NovellWSResponseSet: web service has validated the users responses");
                return true;
            } catch (RemoteException e) {
                LOGGER.error("NovellWSResponseSet: error processing web service response: " + e.getMessage());
            }

            pwmSession.getContextManager().getIntruderManager().addBadAddressAttempt(pwmSession);
            return false;  //To change body of implemented methods use File | Settings | File Templates.
        }

        public boolean write() throws ChaiUnavailableException, IllegalStateException, ChaiOperationException {
            throw new IllegalStateException("unsupported");
        }

        public boolean write(final CrMode writeMode) throws ChaiUnavailableException, IllegalStateException, ChaiOperationException {
            throw new IllegalStateException("unsupported");
        }

        public Locale getLocale() throws ChaiUnavailableException, IllegalStateException, ChaiOperationException {
            return Locale.getDefault();
        }

        public Date getTimestamp() throws ChaiUnavailableException, IllegalStateException, ChaiOperationException {
            return new Date();
        }
    }
}
