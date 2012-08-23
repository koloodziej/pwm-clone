<%@ page import="password.pwm.Validator" %>
<%@ page import="java.util.Enumeration" %>
<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2012 The PWM Project
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

<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="/WEB-INF/jsp/fragment/header.jsp" %>
<body class="nihilo" onload="pwmPageLoadHandler();">
<jsp:include page="/WEB-INF/jsp/fragment/header-body.jsp">
    <jsp:param name="pwm.PageName" value="HTTP Request Information"/>
</jsp:include>
<div id="wrapper">
    <div id="centerbody">
        <%@ include file="admin-nav.jsp" %>
        <div data-dojo-type="dijit.layout.TabContainer" style="width: 100%; height: 100%;" data-dojo-props="doLayout: false, persist: true">
            <div data-dojo-type="dijit.layout.ContentPane" title="Request Information">
                <table>
                    <tr>
                        <td class="key">
                            Request Method
                        </td>
                        <td>
                            <%= request.getMethod() %>
                        </td>
                    </tr>
                    <tr>
                        <td class="key">
                            Path Info
                        </td>
                        <td>
                            <%= request.getPathInfo() %>
                        </td>
                    </tr>
                    <tr>
                        <td class="key">
                            Path Translated
                        </td>
                        <td>
                            <%= request.getPathTranslated() %>
                        </td>
                    </tr>
                    <tr>
                        <td class="key">
                            Query String
                        </td>
                        <td>
                            <%= request.getQueryString() %>
                        </td>
                    </tr>
                    <tr>
                        <td class="key">
                            Request URI
                        </td>
                        <td>
                            <%= request.getRequestURI() %>
                        </td>
                    </tr>
                    <tr>
                        <td class="key">
                            Servlet Path
                        </td>
                        <td>
                            <%= request.getServletPath() %>
                        </td>
                    </tr>
                </table>
            </div>
            <% if (request.getCookies() != null && request.getCookies().length > 0) { %>
            <div data-dojo-type="dijit.layout.ContentPane" title="Cookies">
                <table>
                    <% for (final Cookie cookie : request.getCookies()) { %>
                    <tr>
                        <td class="key">
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), cookie.getName(), 1024) %>
                        </td>
                        <td>
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), cookie.getValue(), 1024) %>
                        </td>
                    </tr>
                    <% } %>
                </table>
                <br class="clear"/>
            </div>
            <% } %>
            <% if (request.getHeaderNames() != null && request.getHeaderNames().hasMoreElements()) { %>
            <div data-dojo-type="dijit.layout.ContentPane" title="Headers">
                <table>
                    <% for (final Enumeration headerEnum = request.getHeaderNames(); headerEnum.hasMoreElements();) { %>
                    <% final String loopHeader = (String) headerEnum.nextElement(); %>
                    <% for (final Enumeration valueEnum = request.getHeaders(loopHeader); valueEnum.hasMoreElements();) { %>
                    <% final String loopValue = (String) valueEnum.nextElement(); %>
                    <tr>
                        <td class="key">
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), loopHeader, 1024) %>
                        </td>
                        <td>
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), loopValue, 1024) %>
                        </td>
                    </tr>
                    <% } %>
                    <% } %>
                </table>
            </div>
            <% } %>
            <% if (request.getParameterNames() != null && request.getParameterNames().hasMoreElements()) { %>
            <div data-dojo-type="dijit.layout.ContentPane" title="Parameters">
                <table>
                    <% for (final Enumeration parameterEnum = request.getParameterNames(); parameterEnum.hasMoreElements();) { %>
                    <% final String loopParameter = (String) parameterEnum.nextElement(); %>
                    <% for (final String loopValue : Validator.readStringsFromRequest(request, loopParameter, 1024)) { %>
                    <tr>
                        <td class="key">
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), loopParameter, 1024) %>
                        </td>
                        <td>
                            <%= Validator.sanatizeInputValue(ContextManager.getPwmApplication(session).getConfig(), loopValue, 1024) %>
                        </td>
                    </tr>
                    <% } %>
                    <% } %>
                </table>
            </div>
            <% } %>
        </div>
    </div>
    <script type="text/javascript">
        require(["dojo/parser","dijit/layout/TabContainer","dijit/layout/ContentPane","dojo/domReady!"],function(dojoParser){
            dojoParser.parse();
        });
    </script>
    <%@ include file="/WEB-INF/jsp/fragment/footer.jsp" %>
</body>
</html>


