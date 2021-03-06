
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

<%@ page import="password.pwm.config.PwmSetting" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="header.jsp" %>
<body onload="pwmPageLoadHandler();document.forms.verifyCaptcha.recaptcha_response_field.focus();">
<div id="wrapper">
    <jsp:include page="header-body.jsp"><jsp:param name="pwm.PageName" value="Title_Captcha"/></jsp:include>
    <div id="centerbody">
        <p><pwm:Display key="Display_Captcha"/></p>
        <%  //check to see if there is an error
            if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
        %>
            <span id="error_msg" class="msg-error">
                <pwm:ErrorMessage/>
            </span>
        <% } %>
        <br/>
        <form action="<pwm:url url='Captcha'/>" method="post" enctype="application/x-www-form-urlencoded"
              name="verifyCaptcha" onsubmit="handleFormSubmit('verify_button');">
            <%-- begin reCaptcha section (http://recaptcha.net/apidocs/captcha/client.html) --%>
            <% final String reCaptchaPublicKey = password.pwm.PwmSession.getPwmSession(session).getConfig().readSettingAsString(PwmSetting.RECAPTCHA_KEY_PUBLIC); %>
            <% final String userLocale = password.pwm.PwmSession.getPwmSession(session).getSessionStateBean().getLocale().getLanguage(); %>
            <% final String reCaptchaURL = request.isSecure() ? "https://api-secure.recaptcha.net" : "http://api.recaptcha.net"; %>
            <script type="text/javascript">
                var RecaptchaOptions = { theme : 'clean' };
            </script>
            <script type="text/javascript"
               src="<%=reCaptchaURL%>/challenge?k=<%=reCaptchaPublicKey%>&lang=<%=userLocale%>">
            </script>
            <noscript>
               <iframe src="<%=reCaptchaURL%>/noscript?k=<%=reCaptchaPublicKey%>&lany=<%=userLocale%>"
                   height="300" width="500" frameborder="0">&nbsp;</iframe>
            </noscript>
            <%-- end reCaptcha section --%>
            <div id="buttonbar">
                <input type="hidden" name="processAction" value="doVerify"/>
                <input type="submit" name="verify" class="btn"
                       id="verify_button"
                       value="    <pwm:Display key="Button_Verify"/>    "/>
                <input type="reset" name="reset" class="btn"
                       value="    <pwm:Display key="Button_Reset"/>    "
                       />
                <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
            </div>
        </form>
    </div>
    <br class="clear"/>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>

