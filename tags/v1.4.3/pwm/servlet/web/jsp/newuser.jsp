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
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="header.jsp" %>
<body onload="document.forms.newUser.elements[0].focus();" onunload="unloadHandler();">
<div id="wrapper">
    <jsp:include page="header-body.jsp"><jsp:param name="pwm.PageName" value="Title_NewUser"/></jsp:include>
    <div id="centerbody">
        <p><pwm:Display key="Display_NewUser"/></p>
        <form action="<pwm:url url='NewUser'/>" method="post" name= "newUser" enctype="application/x-www-form-urlencoded" autocomplete="off"
                onsubmit="handleFormSubmit('submitBtn');" onreset="handleFormClear();">
            <%  //check to see if there is an error
                if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
            %>
            <span id="error_msg" class="msg-error">
                <pwm:ErrorMessage/>
            </span>
            <% } %>

            <pwm:ParameterForm formName="newuser"/>

            <div id="buttonbar">
                <input type="hidden" name="processAction" value="create"/>
                <input tabindex="3" type="submit" name="Create" class="btn"
                       value="     <pwm:Display key="Button_Create"/>     "
                       id="submitBtn"/>
                <input tabindex="4" type="reset" name="reset" class="btn"
                       value="     <pwm:Display key="Button_Reset"/>     "/>
            </div>
        </form>
    </div>
    <br class="clear"/>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>
