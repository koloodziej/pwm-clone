<%@ page import="password.pwm.config.PwmSetting" %>
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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="header.jsp" %>
<body onload="pwmPageLoadHandler();updateContinueButton()" class="tundra">
<script type="text/javascript">
    function updateContinueButton() {
        var checkBox = getObject("agreeCheckBox");
        var continueButton = getObject("button_continue");
        if (checkBox != null && continueButton != null) {
            if (checkBox.checked) {
                continueButton.removeAttribute('disabled');
            } else {
                continueButton.disabled = "disabled";
            }
        }
    }
</script>
<div id="wrapper">
    <jsp:include page="header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_ChangePassword"/>
    </jsp:include>
    <div id="centerbody">
        <% //check to see if there is an error
            if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
        %>
            <span id="error_msg" class="msg-error">
                <pwm:ErrorMessage/>
            </span>
        <% } %>

        <span><%=PwmSession.getPwmSession(session).getConfig().readLocalizedStringSetting(PwmSetting.PASSWORD_CHANGE_AGREEMENT_MESSAGE, PwmSession.getSessionStateBean(session).getLocale())%></span>

        <div id="buttonbar">
            <form action="<pwm:url url='ChangePassword'/>" method="post"
                  enctype="application/x-www-form-urlencoded">
                <%-- remove the next line to remove the "I Agree" checkbox --%>
                <input type="checkbox" id="agreeCheckBox" onclick="updateContinueButton()"
                       onchange="updateContinueButton()"/>&nbsp;&nbsp;<label for="agreeCheckBox"><pwm:Display
                    key="Button_Agree"/></label>
                <input type="hidden"
                       name="processAction"
                       value="agree"/>
                <input type="submit" name="button" class="btn"
                       value="    <pwm:Display key="Button_Continue"/>    "
                       id="button_continue"/>
            </form>
            <br/><br/>

            <form action="<%=request.getContextPath()%>/public/<pwm:url url='Logout'/>" method="post"
                  enctype="application/x-www-form-urlencoded">
                <input type="submit" name="button" class="btn"
                       value="    <pwm:Display key="Button_Logout"/>    "
                       id="button_logout"/>
            </form>
        </div>
    </div>
    <br class="clear"/>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>
