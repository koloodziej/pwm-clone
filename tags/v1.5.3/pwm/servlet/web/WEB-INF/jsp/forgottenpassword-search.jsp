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

<%@ page import="password.pwm.config.Configuration" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="header.jsp" %>
<body onload="pwmPageLoadHandler();getObject('username').focus();" class="tundra">
<div id="wrapper">
    <jsp:include page="header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_ForgottenPassword"/>
    </jsp:include>
    <div id="centerbody">
        <p><pwm:Display key="Display_ForgottenPassword"/></p>

        <form action="<pwm:url url='ForgottenPassword'/>" method="post" enctype="application/x-www-form-urlencoded"
              name="searchForm"
              onsubmit="handleFormSubmit('submitBtn',this);return false" onreset="handleFormClear();return false;"
              id="searchForm">
            <% //check to see if there is an error
                if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
            %>
            <span id="error_msg" class="msg-error">
                <pwm:ErrorMessage/>
            </span>
            <% } %>

            <% //check to see if any locations are configured.
                if (!PwmSession.getPwmSession(session).getConfig().getLoginContexts().isEmpty()) {
            %>
            <h2><label for="context"><pwm:Display key="Field_Location"/></label></h2>
            <select name="context" id="context">
                <pwm:DisplayLocationOptions name="context"/>
            </select>
            <% } %>

            <h2><label for="username"><pwm:Display key="Field_Username"/></label></h2>
            <input type="text" id="username" name="username" class="inputfield"
                   value="<pwm:ParamValue name='username'/>"/>

            <div id="buttonbar">
                <input type="hidden"
                       name="processAction"
                       value="search"/>
                <input type="submit" class="btn"
                       name="search"
                       value="     <pwm:Display key="Button_Search"/>     "
                       id="submitBtn"/>
                <input type="reset" class="btn"
                       name="reset" onclick="clearForm('searchForm');return false;"
                       value="     <pwm:Display key="Button_Reset"/>     "/>
                <% if (password.pwm.PwmSession.getPwmSession(session).getConfig().readSettingAsBoolean(password.pwm.config.PwmSetting.DISPLAY_CANCEL_BUTTON)) { %>
                <button style="visibility:hidden;" name="button" class="btn" id="button_cancel"
                        onclick="window.location='<%=request.getContextPath()%>/public/<pwm:url url='CommandServlet'/>?processAction=continue';return false">
                    &nbsp;&nbsp;&nbsp;<pwm:Display key="Button_Cancel"/>&nbsp;&nbsp;&nbsp;
                </button>
                <script type="text/javascript">getObject('button_cancel').style.visibility = 'visible';</script>
                <% } %>
                <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
            </div>
        </form>
    </div>
    <br class="clear"/>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>

