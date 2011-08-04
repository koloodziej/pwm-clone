/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2011 The PWM Project
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

import password.pwm.config.Display;
import password.pwm.config.Message;
import password.pwm.error.PwmError;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.TimeZone;

/**
 * Constant values used throughout the servlet.
 *
 * @author Jason D. Rivard
 */
public abstract class PwmConstants {
// ------------------------------ FIELDS ------------------------------

    // ------------------------- PUBLIC CONSTANTS -------------------------
    public static final String BUILD_TIME =     ResourceBundle.getBundle("password.pwm.BuildInformation").getString("build.time");
    public static final String BUILD_NUMBER =   ResourceBundle.getBundle("password.pwm.BuildInformation").getString("build.number");
    public static final String BUILD_TYPE =     ResourceBundle.getBundle("password.pwm.BuildInformation").getString("build.type");
    public static final String PWM_VERSION =    ResourceBundle.getBundle("password.pwm.BuildInformation").getString("pwm.version");
    public static final String PWM_WEBSITE =    ResourceBundle.getBundle("password.pwm.BuildInformation").getString("pwm.website");

    public static final String SERVLET_VERSION = "v" + PWM_VERSION + " b" + BUILD_NUMBER + " (" + BUILD_TYPE + ")";

    public static final int MAX_EMAIL_QUEUE_SIZE = 1000;
    public static final int MAX_SMS_QUEUE_SIZE = 100;

    public static final Locale DEFAULT_LOCALE = new Locale("");

    public static final DateFormat PWM_STANDARD_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z");

    public static final String HTTP_HEADER_BASIC_AUTH = "Authorization";
    public static final String HTTP_BASIC_AUTH_PREFIX = "Basic ";
    public static final String HTTP_HEADER_X_FORWARDED_FOR = "X-Forwarded-For";


    public static final String CONTEXT_ATTR_CONTEXT_MANAGER = "ContextManager";
    public static final String SESSION_ATTR_PWM_SESSION = "PwmSession";

    public static final String DEFAULT_BUILD_CHECKSUM_FILENAME = "BuildChecksum.properties";

    public static final String URL_JSP_LOGIN = "WEB-INF/jsp/login.jsp";
    public static final String URL_JSP_LOGOUT = "WEB-INF/jsp/logout.jsp";
    public static final String URL_JSP_SUCCESS = "WEB-INF/jsp/success.jsp";
    public static final String URL_JSP_ERROR = "WEB-INF/jsp/error.jsp";
    public static final String URL_JSP_WAIT = "WEB-INF/jsp/wait.jsp";
    public static final String URL_JSP_PASSWORD_CHANGE = "WEB-INF/jsp/changepassword.jsp";
    public static final String URL_JSP_PASSWORD_AGREEMENT = "WEB-INF/jsp/changepassword-agreement.jsp";
    public static final String URL_JSP_SETUP_RESPONSES = "WEB-INF/jsp/setupresponses.jsp";
    public static final String URL_JSP_CONFIRM_RESPONSES = "WEB-INF/jsp/setupresponses-confirm.jsp";
    public static final String URL_JSP_RECOVER_PASSWORD_SEARCH = "WEB-INF/jsp/forgottenpassword-search.jsp";
    public static final String URL_JSP_RECOVER_PASSWORD_RESPONSES = "WEB-INF/jsp/forgottenpassword-responses.jsp";
    public static final String URL_JSP_RECOVER_PASSWORD_CHOICE = "WEB-INF/jsp/forgottenpassword-choice.jsp";
    public static final String URL_JSP_RECOVER_PASSWORD_ENTER_CODE = "WEB-INF/jsp/forgottenpassword-entercode.jsp";
    public static final String URL_JSP_FORGOTTEN_USERNAME = "WEB-INF/jsp/forgottenusername-search.jsp";
    public static final String URL_JSP_ACTIVATE_USER = "WEB-INF/jsp/activateuser.jsp";
    public static final String URL_JSP_UPDATE_ATTRIBUTES = "WEB-INF/jsp/updateprofile.jsp";
    public static final String URL_JSP_NEW_USER = "WEB-INF/jsp/newuser.jsp";
    public static final String URL_JSP_GUEST_REGISTRATION = "WEB-INF/jsp/newguest.jsp";
    public static final String URL_JSP_GUEST_UPDATE = "WEB-INF/jsp/updateguest.jsp";
    public static final String URL_JSP_GUEST_UPDATE_SEARCH = "WEB-INF/jsp/updateguest-search.jsp";
    public static final String URL_JSP_SHORTCUT = "WEB-INF/jsp/shortcut.jsp";
    public static final String URL_JSP_PASSWORD_WARN = "private/passwordwarn.jsp";
    public static final String URL_JSP_CAPTCHA = "WEB-INF/jsp/captcha.jsp";
    public static final String URL_JSP_PEOPLE_SEARCH = "WEB-INF/jsp/peoplesearch.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_EDITOR = "WEB-INF/jsp/configmanager-editor.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_EDITOR_SETTINGS = "WEB-INF/jsp/configmanager-editor-settings.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_EDITOR_LOCALEBUNDLE = "WEB-INF/jsp/configmanager-editor-localeBundle.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_LOGVIEW = "WEB-INF/jsp/configmanager-logview.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_MODE_NEW = "WEB-INF/jsp/configmanager-mode-new.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_MODE_CONFIGURATION = "WEB-INF/jsp/configmanager-mode-configuration.jsp";
    public static final String URL_JSP_CONFIG_MANAGER_MODE_RUNNING = "WEB-INF/jsp/configmanager-mode-running.jsp";
    public static final String URL_JSP_HELPDESK = "WEB-INF/jsp/helpdesk.jsp";


    public static final String URL_JSP_USER_INFORMATION = "admin/userinformation.jsp";

    public static final String URL_SERVLET_LOGIN = "Login";
    public static final String URL_SERVLET_LOGOUT = "Logout";
    public static final String URL_SERVLET_CHANGE_PASSWORD = "ChangePassword";
    public static final String URL_SERVLET_UPDATE_PROFILE = "UpdateProfile";
    public static final String URL_SERVLET_SETUP_RESPONSES = "SetupResponses";
    public static final String URL_SERVLET_RECOVER_PASSWORD = "ForgottenPassword";
    public static final String URL_SERVLET_NEW_USER = "NewUser";
    public static final String URL_SERVLET_GUEST_REGISTRATION = "GuestRegistration";
    public static final String URL_SERVLET_GUEST_UPDATE = "GuestUpdate";
    public static final String URL_SERVLET_CAPTCHA = "Captcha";
    public static final String URL_SERVLET_COMMAND = "CommandServlet";
    public static final String URL_SERVLET_CONFIG_MANAGER = "ConfigManager";

    public static final String PARAM_ACTION_REQUEST = "processAction";
    public static final String PARAM_VERIFICATION_KEY = "session_verificiation_key";
    public static final String PARAM_RESPONSE_PREFIX = "PwmResponse_R_";
    public static final String PARAM_QUESTION_PREFIX = "PwmResponse_Q_";

    public static final String VALUE_REPLACEMENT_USERNAME = "%USERNAME%";

    // don't worry.  look over there.
    public static final String[] X_AMB_HEADER = new String[]{
            "bonjour!",
            "just like X-Fry, only ambier",
            "mooooooo!",
            "amby wamby",
            "deciphered by leading cryptologists",
            "a retina scanner would be a lot cooler",
            "if you can read this header, your debugging to close",
            "my author wrote this servlet and all I got was this lousy header...",
            "j00s j0ur d4ddy",
            "amb is my her0",
            "dear hax0r: fl33! n0\\/\\/!",
            "if its broke, it's krowten's fault",
            "in the future, you'll just /think/ your password",
            "all passwords super-duper encrypted with double rot13",
            "chance of password=password? 92%",
            "from the next-time-just-phone-it-in dept",
            "this header contains 100% genuine nougat",
            "are passwords really necessary?  can't we all just get along?",
            "That's amazing! I've got the same combination on my luggage!",
            "just because it looks plaintext doesn't mean there isn't a steganographic 1024bit AES key",
            "whatever happened to speech wreck a nation technology?",     // thx wk
            "Password schmassword, I can't even remember my user name...",
            "The Mummy's password is in crypted",   // thx wk
            "The zombie's password is expired", // wk
            "Chuck Yeager's password is in plane text", // thx wk
            "Fruit flies have one time use passwords",
            "As Gregor Samsa awoke one morning from uneasy dreams he found himself transformed in his bed into a gigantic password.",
            "NOTICE: This header is protected by the Digital Millennium Copyright Act of 1996.  Reading this header is strictly forbidden."
    };

    public static final int PASSWORD_UPDATE_CYCLE_DELAY = 1000 * 2;  //milliseconds
    public static final int PASSWORD_UPDATE_INITIAL_DELAY = 1000; //milliseconds

    static {
        PWM_STANDARD_DATE_FORMAT.setTimeZone(TimeZone.getTimeZone("Zulu"));
    }


// -------------------------- ENUMERATIONS --------------------------

    public static enum CONTEXT_PARAM {
        CONFIG_FILE("pwmConfigPath"),
        WORDLIST_LOAD_FACTOR("wordlistLoadFactor"),
        KNOWN_LOCALES("knownLocales");


        private final String key;

        public String getKey() {
            return key;
        }

        CONTEXT_PARAM(final String key) {
            this.key = key;
        }
    }

    public static enum EDITABLE_LOCALE_BUNDLES {
        DISPLAY(Display.class),
        ERRORS(PwmError.class),
        MESSAGE(Message.class),
        ;

        private final Class theClass;

        EDITABLE_LOCALE_BUNDLES(final Class theClass) {
            this.theClass = theClass;
        }

        public Class getTheClass() {
            return theClass;
        }
    }
}

