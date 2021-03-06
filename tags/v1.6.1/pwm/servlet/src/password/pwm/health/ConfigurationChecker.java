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

package password.pwm.health;

import password.pwm.PwmApplication;
import password.pwm.util.operations.CrUtility;
import password.pwm.util.operations.PasswordUtility;
import password.pwm.PwmConstants;
import password.pwm.config.Configuration;
import password.pwm.config.PwmSetting;
import password.pwm.servlet.NewUserServlet;
import password.pwm.util.PwmLogger;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

public class ConfigurationChecker implements HealthChecker {
    private static final String TOPIC = "Configuration";
    private static final PwmLogger LOGGER = PwmLogger.getLogger(HealthChecker.class);

    public List<HealthRecord> doHealthCheck(final PwmApplication pwmApplication) {
        if (pwmApplication.getConfig() == null) {
            final HealthRecord hr = new HealthRecord(HealthStatus.WARN, TOPIC, "Unable to read configuration");
            return Collections.singletonList(hr);
        }

        final Configuration config = pwmApplication.getConfig();
        final List<HealthRecord> records = new ArrayList<HealthRecord>();

        if (config.readSettingAsBoolean(PwmSetting.HIDE_CONFIGURATION_HEALTH_WARNINGS)) {
            return records;
        }

        if (pwmApplication.getApplicationMode() == PwmApplication.MODE.CONFIGURATION) {
            final StringBuilder errorMsg = new StringBuilder();
            errorMsg.append("PWM is currently in ").append(pwmApplication.getApplicationMode().toString()).append(" mode. ");
            errorMsg.append("Anyone accessing this site can modify the configuration without authenticating.  When ready, lock the configuration to secure this installation.");
            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
        }

        if (!config.readSettingAsBoolean(PwmSetting.REQUIRE_HTTPS)) {
            final StringBuilder errorMsg = new StringBuilder();
            errorMsg.append(PwmSetting.REQUIRE_HTTPS.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" -> ");
            errorMsg.append(PwmSetting.REQUIRE_HTTPS.getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" setting should be set to true for proper security");

            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
        }

        if (config.readSettingAsBoolean(PwmSetting.LDAP_PROMISCUOUS_SSL)) {
            final StringBuilder errorMsg = new StringBuilder();
            errorMsg.append(PwmSetting.LDAP_PROMISCUOUS_SSL.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" -> ");
            errorMsg.append(PwmSetting.LDAP_PROMISCUOUS_SSL.getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" setting should be set to false for proper security");

            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
        }

        if (config.readSettingAsBoolean(PwmSetting.DISPLAY_SHOW_DETAILED_ERRORS)) {
            final StringBuilder errorMsg = new StringBuilder();
            errorMsg.append(PwmSetting.DISPLAY_SHOW_DETAILED_ERRORS.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" -> ");
            errorMsg.append(PwmSetting.DISPLAY_SHOW_DETAILED_ERRORS.getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" setting should be set to false for proper security");

            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
        }

        if (config.readSettingAsString(PwmSetting.LDAP_TEST_USER_DN) == null || config.readSettingAsString(PwmSetting.LDAP_TEST_USER_DN).length() < 1 ) {
            final StringBuilder errorMsg = new StringBuilder();
            errorMsg.append(PwmSetting.LDAP_TEST_USER_DN.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" -> ");
            errorMsg.append(PwmSetting.LDAP_TEST_USER_DN.getLabel(PwmConstants.DEFAULT_LOCALE));
            errorMsg.append(" setting should be set to verify proper operation");

            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
        }

        {
            final List<String> ldapServerURLs = config.readSettingAsStringArray(PwmSetting.LDAP_SERVER_URLS);
            if (ldapServerURLs != null && !ldapServerURLs.isEmpty()) {
                for (final String urlStringValue : ldapServerURLs) {
                    try {
                        final URI url = new URI(urlStringValue);
                        final boolean secure = "ldaps".equalsIgnoreCase(url.getScheme());
                        if (!secure) {
                            final StringBuilder errorMsg = new StringBuilder();
                            errorMsg.append(PwmSetting.LDAP_SERVER_URLS.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
                            errorMsg.append(" -> ");
                            errorMsg.append(PwmSetting.LDAP_SERVER_URLS.getLabel(PwmConstants.DEFAULT_LOCALE));
                            errorMsg.append(" url is configured for non-secure connection: ").append(urlStringValue);

                            records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
                        }
                    } catch (URISyntaxException  e) {
                        final StringBuilder errorMsg = new StringBuilder();
                        errorMsg.append(PwmSetting.LDAP_SERVER_URLS.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
                        errorMsg.append(" -> ");
                        errorMsg.append(PwmSetting.LDAP_SERVER_URLS.getLabel(PwmConstants.DEFAULT_LOCALE));
                        errorMsg.append(" error parsing urls: ").append(e.getMessage());

                        records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
                    }
                }
            }
        }

        for (final PwmSetting setting : PwmSetting.values()) {
            if (PwmSetting.Syntax.PASSWORD == setting.getSyntax() && !config.isDefaultValue(setting)) {
                final String passwordValue = config.readSettingAsString(setting);
                final int strength = PasswordUtility.checkPasswordStrength(config, null, passwordValue);
                if (strength < 50) {
                    final StringBuilder errorMsg = new StringBuilder();
                    errorMsg.append(setting.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
                    errorMsg.append(" -> ");
                    errorMsg.append(setting.getLabel(PwmConstants.DEFAULT_LOCALE));
                    errorMsg.append(" strength of password is weak (").append(strength).append("/100); increase password length/complexity for proper security");

                    records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
                }
            }
        }

        {
            final String novellUserAppURL = config.readSettingAsString(PwmSetting.EDIRECTORY_PWD_MGT_WEBSERVICE_URL);
            if (novellUserAppURL != null && novellUserAppURL.length() > 0) {
                try {
                    final URL url = new URL(novellUserAppURL);
                    final boolean secure = "https".equalsIgnoreCase(url.getProtocol());
                    if (!secure) {
                        records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, "UserApp Password SOAP Service URL is not secure (https)"));
                    }
                } catch (MalformedURLException e) {
                    LOGGER.debug("error parsing Novell PwdMgt Web Service URL: " + e.getMessage());
                    records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, "error parsing Novell PwdMgt Web Service URL: " + e.getMessage()));
                }
            }
        }

        if (config.readSettingAsBoolean(PwmSetting.FORGOTTEN_PASSWORD_ENABLE)) {
            if (!config.readSettingAsBoolean(PwmSetting.CHALLENGE_REQUIRE_RESPONSES)) {
                if (!config.readSettingAsBoolean(PwmSetting.CHALLENGE_TOKEN_ENABLE)) {
                    final Collection<String> formSettings = config.readSettingAsLocalizedStringArray(PwmSetting.CHALLENGE_REQUIRED_ATTRIBUTES, null);
                    if (formSettings.isEmpty()) {
                        records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, "No forgotten password recovery options are enabled"));
                    }
                }
            }
        }

        //if (pwmApplication.getConfigReader().modifiedSincePWMSave()) {
        //    records.add(new HealthRecord(HealthStatus.CAUTION, TOPIC, "Configuration file has been modified outside of PWM.  Please edit and save the configuration using the ConfigManager to be sure all settings are valid."));
        //}

        boolean hasDbConfiguration = true;
        {
            if (config.readSettingAsString(PwmSetting.DATABASE_CLASS) == null || config.readSettingAsString(PwmSetting.DATABASE_CLASS).length() < 1) {
                hasDbConfiguration = false;
            }
            if (config.readSettingAsString(PwmSetting.DATABASE_URL) == null || config.readSettingAsString(PwmSetting.DATABASE_URL).length() < 1) {
                hasDbConfiguration = false;
            }
            if (config.readSettingAsString(PwmSetting.DATABASE_USERNAME) == null || config.readSettingAsString(PwmSetting.DATABASE_USERNAME).length() < 1) {
                hasDbConfiguration = false;
            }
            if (config.readSettingAsString(PwmSetting.DATABASE_PASSWORD) == null || config.readSettingAsString(PwmSetting.DATABASE_PASSWORD).length() < 1) {
                hasDbConfiguration = false;
            }
        }

        if (!hasDbConfiguration) {
            if (config.readSettingAsBoolean(PwmSetting.RESPONSE_STORAGE_DB)) {
                final StringBuilder errorMsg = new StringBuilder();
                errorMsg.append(PwmSetting.RESPONSE_STORAGE_DB.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
                errorMsg.append(" -> ");
                errorMsg.append(PwmSetting.RESPONSE_STORAGE_DB.getLabel(PwmConstants.DEFAULT_LOCALE));
                errorMsg.append(" is enabled, but database connection settings are not set");
                records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
            }

            {
                final String readRawValue = config.readSettingAsString(PwmSetting.FORGOTTEN_PASSWORD_READ_PREFERENCE);
                final List<CrUtility.STORAGE_METHOD> readPreferences = new ArrayList<CrUtility.STORAGE_METHOD>();
                for (final String rawValue : readRawValue.split("-")) {
                    readPreferences.add(CrUtility.STORAGE_METHOD.valueOf(rawValue));
                }

                if (readPreferences.contains(CrUtility.STORAGE_METHOD.DB)) {
                final StringBuilder errorMsg = new StringBuilder();
                errorMsg.append(PwmSetting.FORGOTTEN_PASSWORD_READ_PREFERENCE.getCategory().getLabel(PwmConstants.DEFAULT_LOCALE));
                errorMsg.append(" -> ");
                errorMsg.append(PwmSetting.FORGOTTEN_PASSWORD_READ_PREFERENCE.getLabel(PwmConstants.DEFAULT_LOCALE));
                errorMsg.append(" includes database storage, but database connection settings are not set");
                records.add(new HealthRecord(HealthStatus.CONFIG, TOPIC, errorMsg.toString()));
            }
            }
        }

        {
            final List<HealthRecord> healthRecords = NewUserServlet.checkConfiguration(config,PwmConstants.DEFAULT_LOCALE);
            if (healthRecords != null && !healthRecords.isEmpty()) {
                records.addAll(healthRecords);
            }
        }

        return records;
    }
}
