<%@ page import="password.pwm.ContextManager" %>
<%@ page import="password.pwm.PwmApplication" %>
<%@ page import="password.pwm.PwmSession" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="password.pwm.error.PwmUnrecoverableException" %>
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

<%--
  ~ This file is imported by most JSPs, it shows the main 'header' in the html
  - which by default is a blue-gray gradieted and rounded block.
  --%>
<%@ taglib uri="pwm" prefix="pwm" %>
<%
    PwmSession pwmSessionHeaderBody = null;
    PwmApplication pwmApplictionHeaderBody = null;
    try {
        pwmApplictionHeaderBody = ContextManager.getPwmApplication(session);
        pwmSessionHeaderBody = PwmSession.getPwmSession(session);
    } catch (PwmUnrecoverableException e) {
        /* application must be unavailable */
    }
%>
<% final boolean loggedIn = pwmSessionHeaderBody != null && pwmSessionHeaderBody.getSessionStateBean().isAuthenticated();%>
<% final boolean showLogout = loggedIn && pwmApplictionHeaderBody != null && pwmApplictionHeaderBody.getConfig().readSettingAsBoolean(PwmSetting.DISPLAY_LOGOUT_BUTTON); %>
<% final boolean showConfigHeader = !request.getRequestURI().contains("configmanager") && pwmApplictionHeaderBody != null && pwmApplictionHeaderBody.getApplicationMode() == PwmApplication.MODE.CONFIGURATION; %>
<% if (showConfigHeader) { %>
<div id="header-warning">PWM is in configuration mode. Use the <a href="<%=request.getContextPath()%><pwm:url url='/config/ConfigManager'/>">ConfigManager</a>
    to modify or lock the configuration.
</div>
<% } %>
<div id="header">
    <div id="header-company-logo"></div>
    <div style="position: absolute; align:left; border-width:0; top: 19px; left:18px;">
        <br/><%-- balance div for ie 6 --%>
    </div>
    <%-- this section handles the logout link (if user is logged in) --%>
    <div style="position: absolute; align:right; border-width:0; top: 19px; right:18px;">
        <div style="visibility: <%=showLogout ? "inline" : "hidden"%>"
             id="logoutDiv">
            <a id="LogoutButton" style="margin-left: auto" href="<%=request.getContextPath()%><pwm:url url='/public/Logout'/>"
               title="<pwm:Display key="Button_Logout"/>">
            </a>
        </div>
    </div>
    <div id="header-page">
        <pwm:Display key="${param['pwm.PageName']}" displayIfMissing="true"/>
    </div>
    <div id="header-title">
        <pwm:Display key="Title_Application"/>
    </div>
    <script type="text/javascript">
        require(["dojo/domReady!"],function(){
            setTimeout(function(){
                require(["dijit/Tooltip"],function(){
                    new dijit.Tooltip({
                        connectId: ["logoutDiv"],
                        label: PWM_STRINGS["Long_Title_Logout"],
                        showDelay: 0
                    });
                });},1000)
        });
    </script>
</div>

