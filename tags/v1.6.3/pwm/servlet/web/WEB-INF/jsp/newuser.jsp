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
<%@ include file="fragment/header.jsp" %>
<body onload="pwmPageLoadHandler();document.forms.newUser.elements[0].focus();" class="nihilo">
<script type="text/javascript"
        src="<%=request.getContextPath()%>/resources/<pwm:url url='newuser.js'/>"></script>
<div id="wrapper">
    <jsp:include page="fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_NewUser"/>
    </jsp:include>
    <div id="centerbody">
        <p><pwm:Display key="Display_NewUser"/></p>
        <div id="PasswordRequirements">
            <ul>
                <pwm:DisplayPasswordRequirements separator="</li>" prepend="<li>" form="newuser"/>
            </ul>
        </div>
        <%@ include file="fragment/message.jsp" %>
        <br/>
        <form action="<pwm:url url='NewUser'/>" method="post" name="newUser" enctype="application/x-www-form-urlencoded"
              id="newUserForm"
              onsubmit="handleFormSubmit('submitBtn',this);return false" onreset="handleFormClear();return false"
              onkeypress="checkForCapsLock(event);validateNewUserForm()"
              >
            <% request.setAttribute("form",PwmSetting.NEWUSER_FORM); %>
            <% request.setAttribute("form_showPasswordFields","true"); %>
            <jsp:include page="fragment/form.jsp"/>
            <div id="buttonbar">
                <input type="hidden" name="processAction" value="create"/>
                <input type="submit" name="Create" class="btn"
                       value="<pwm:Display key="Button_Create"/>"
                       id="submitBtn"/>
                <% if (ContextManager.getPwmApplication(session).getConfig().readSettingAsBoolean(password.pwm.config.PwmSetting.DISPLAY_RESET_BUTTON)) { %>
                <input type="reset" name="reset" class="btn"
                       value="<pwm:Display key="Button_Reset"/>"/>
                <% } %>
                <% if (ContextManager.getPwmApplication(session).getConfig().readSettingAsBoolean(password.pwm.config.PwmSetting.DISPLAY_CANCEL_BUTTON)) { %>
                <button style="visibility:hidden;" name="button" class="btn" id="button_cancel"
                        onclick="window.location='<%=request.getContextPath()%>/public/<pwm:url url='CommandServlet'/>?processAction=continue';return false">
                    <pwm:Display key="Button_Cancel"/>
                </button>
                <script type="text/javascript">getObject('button_cancel').style.visibility = 'visible';</script>
                <% } %>
                <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
            </div>
        </form>
    </div>
    <br class="clear"/>
</div>
<script type="text/javascript">
    PWM_STRINGS['Display_CheckingData'] = "<pwm:Display key="Display_CheckingData"/>";
    PWM_STRINGS['Display_CommunicationError'] = "<pwm:Display key="Display_CommunicationError"/>";
</script>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
