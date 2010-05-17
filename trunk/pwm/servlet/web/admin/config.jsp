<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2010 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<%@ page import="com.novell.ldapchai.util.StringHelper" %>
<%@ page import="password.pwm.ContextManager" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="password.pwm.config.StoredConfiguration" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<% final PwmSession pwmSession = PwmSession.getPwmSession(session); %>
<% final password.pwm.config.Configuration pwmConfig = pwmSession.getConfig(); %>
<% final StoredConfiguration storedConfig = pwmConfig.getStoredConfiguration(); %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="../jsp/header.jsp" %>
<body onload="pwmPageLoadHandler();">
<div id="wrapper">
    <jsp:include page="../jsp/header-body.jsp"><jsp:param name="pwm.PageName" value="PWM Configuration Settings"/></jsp:include>
    <div id="centerbody">
        <p style="text-align:center;">
            <a href="status.jsp">Status</a> | <a href="statistics.jsp">Statistics</a> | <a href="eventlog.jsp">Event Log</a> | <a href="intruderstatus.jsp">Intruders</a> | <a href="activesessions.jsp">Sessions</a> | <a href="config.jsp">Configuration</a> | <a href="UserInformation">User Information</a>
        </p>
        <p>
            Configuration load time <%= (java.text.DateFormat.getDateTimeInstance()).format(new Date(ContextManager.getContextManager(session).getConfig().getLoadTime())) %>
        </p>
        <ol>
            <% for (final PwmSetting.Category loopCategory : PwmSetting.valuesByCategory().keySet()) { %>
            <li><a href="#<%=loopCategory%>"><%=loopCategory.getLabel(request.getLocale())%></a></li>
            <% } %>
        </ol>
        <%
            for (final PwmSetting.Category loopCategory : PwmSetting.valuesByCategory().keySet()) {
                final List<PwmSetting> loopSettings = PwmSetting.valuesByCategory().get(loopCategory);
        %>
        <table>
            <tr>
                <td class="title" colspan="10">
                    <a name="<%=loopCategory%>"><%= loopCategory.getLabel(request.getLocale()) %></a>
                </td>
            </tr>
            <%  for (final PwmSetting loopSetting : loopSettings) { %>
            <tr>
                <td class="key" style="width:100px; text-align:center;">
                    <%= loopSetting.getLabel(request.getLocale()) %>
                </td>
                <td>
                    <%
                        if (loopSetting.isConfidential()) {
                            out.write("* not shown *");
                        } else {
                            switch (loopSetting.getSyntax()) {
                                case STRING_ARRAY:
                                {
                                    final List<String> values = storedConfig.readStringArraySetting(loopSetting);
                                    for (final String value : values) {
                                        out.write(value + "<br/>");
                                    }
                                }
                                break;

                                case LOCALIZED_STRING:
                                {
                                    final Map<String,String> values = storedConfig.readLocalizedStringSetting(loopSetting);
                                    for (final String locale : values.keySet()) {
                                        out.write("<b>" + locale + "</b>" + values.get(locale) + "<br/>");
                                    }

                                }
                                break;

                                case LOCALIZED_STRING_ARRAY:
                                {
                                    final Map<String,List<String>> values = storedConfig.readLocalizedStringArraySetting(loopSetting);
                                    for (final String locale : values.keySet()) {
                                        out.write("<table><tr><td>");
                                        out.write((locale == null || locale.length() < 1) ? "Default" : locale);
                                        out.write("</td><td>");
                                        for (final String value : values.get(locale)) {
                                            out.write(value + "<br/>");
                                        }
                                        out.write("</td></tr></table>");
                                    }
                                }
                                break;

                                default:
                                    out.write(storedConfig.readSetting(loopSetting));
                            }
                        }
                    %>
                </td>
            </tr>
            <% } %>
        </table>
        <br class="clear"/>
        <% } %>
        <br class="clear"/>
    </div>
</div>
<br class="clear"/>
<%@ include file="../jsp/footer.jsp" %>
</body>
</html>












