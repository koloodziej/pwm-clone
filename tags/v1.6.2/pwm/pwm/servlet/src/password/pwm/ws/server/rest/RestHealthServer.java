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

package password.pwm.ws.server.rest;

import com.google.gson.Gson;
import com.novell.ldapchai.exception.ChaiUnavailableException;
import com.novell.ldapchai.util.StringHelper;
import password.pwm.*;
import password.pwm.error.PwmUnrecoverableException;
import password.pwm.health.HealthMonitor;
import password.pwm.health.HealthRecord;
import password.pwm.util.PwmLogger;
import password.pwm.util.ServletHelper;
import password.pwm.util.stats.Statistic;
import password.pwm.ws.server.RestServerHelper;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

@Path("/pwm-health")
public class RestHealthServer {

    private static final PwmLogger LOGGER = PwmLogger.getLogger(RestHealthServer.class);

    @Context
    HttpServletRequest request;

    // This method is called if TEXT_PLAIN is request
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String doPwmHealthPlainGet() {
        try {
            final PwmApplication pwmApplication = ContextManager.getPwmApplication(request);
            final PwmSession pwmSession = PwmSession.getPwmSession(request);
            LOGGER.trace(pwmSession,ServletHelper.debugHttpRequest(request));
            final boolean isExternal = RestServerHelper.determineIfRestClientIsExternal(request);

            final String resultString = pwmApplication.getHealthMonitor().getMostSevereHealthStatus().toString();
            if (isExternal) {
                pwmApplication.getStatisticsManager().incrementValue(Statistic.REST_HEALTH);
            }
            return resultString;
        } catch (Exception e) {
            LOGGER.error("unexpected error building json response for /health rest service: " + e.getMessage());
        }
        return "";
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public String doPwmHealthJsonGet(@QueryParam("refreshImmediate") final String requestImmediateParam) {
        final boolean requestImmediate = StringHelper.convertStrToBoolean(requestImmediateParam);
        try {
            final PwmApplication pwmApplication = ContextManager.getPwmApplication(request);
            final PwmSession pwmSession = PwmSession.getPwmSession(request);
            LOGGER.trace(pwmSession,ServletHelper.debugHttpRequest(request));
            final boolean isExternal = RestServerHelper.determineIfRestClientIsExternal(request);

            final String resultString = processGetHealthCheckData(pwmApplication, pwmSession, requestImmediate);
            if (isExternal) {
                pwmApplication.getStatisticsManager().incrementValue(Statistic.REST_HEALTH);
            }
            return resultString;
        } catch (Exception e) {
            LOGGER.error("unexpected error building json response for /health rest service: " + e.getMessage());
        }

        return "";
    }

    private static String processGetHealthCheckData(
            final PwmApplication pwmApplication,
            final PwmSession pwmSession,
            final boolean refreshImmediate
    )
            throws ChaiUnavailableException, IOException, ServletException, PwmUnrecoverableException {
        final HealthMonitor healthMonitor = pwmApplication.getHealthMonitor();

        boolean doRefresh = false;
        if (refreshImmediate) {
            if (pwmApplication.getApplicationMode() == PwmApplication.MODE.CONFIGURATION) {
                LOGGER.trace(pwmSession, "allowing configuration refresh (ConfigurationMode=CONFIGURATION)");
                doRefresh = true;
            } else {
                if (pwmSession.getSessionStateBean().isAuthenticated()) {
                    try {
                        doRefresh = Permission.checkPermission(Permission.PWMADMIN, pwmSession, pwmApplication);
                    } catch (Exception e) {
                        LOGGER.warn(pwmSession, "error during authorization check: " + e.getMessage());
                    }
                }
            }
        }

        final Collection<HealthRecord> healthRecords = healthMonitor.getHealthRecords(doRefresh);
        final Map<String, Object> returnMap = new LinkedHashMap<String, Object>();
        returnMap.put("date", PwmConstants.DEFAULT_DATETIME_FORMAT.format(healthMonitor.getLastHealthCheckDate()));
        returnMap.put("timestamp", healthMonitor.getLastHealthCheckDate().getTime());
        returnMap.put("overall", healthMonitor.getMostSevereHealthStatus().toString());
        returnMap.put("data", healthRecords);

        final Gson gson = new Gson();
        return gson.toJson(returnMap);
    }
}