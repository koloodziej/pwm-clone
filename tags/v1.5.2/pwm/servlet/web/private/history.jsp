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

<%@ page import="password.pwm.UserHistory" %>
<%@ page import="password.pwm.config.Message" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="../jsp/header.jsp" %>
<body onload="pwmPageLoadHandler();">
<%
    UserHistory userHistory = new UserHistory(0);
    try { userHistory = UserHistory.readUserHistory(PwmSession.getPwmSession(session)); } catch (Exception e) { }
%>
<div id="wrapper">
    <jsp:include page="../jsp/header-body.jsp"><jsp:param name="pwm.PageName" value="Title_UserEventHistory"/></jsp:include>
    <div id="centerbody">
        <% final String timeZone = (java.text.DateFormat.getDateTimeInstance()).getTimeZone().getDisplayName(); %>
        <p><pwm:Display key="Display_UserEventHistory" value1="<%= timeZone %>"/></p>
        <%  //check to see if there is an error
            if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
        %>
            <span id="error_msg" class="msg-error">
                <pwm:ErrorMessage/>
            </span>
        <% } %>

        <table style="border-collapse:collapse;  border: 2px solid #D4D4D4; width:100%">
            <% for (final UserHistory.Record record : userHistory.getRecords()) { %>
            <tr>
                <td class="key" style="width: 200px">
                    <%= (DateFormat.getDateTimeInstance(DateFormat.DEFAULT, DateFormat.DEFAULT, request.getLocale())).format(new Date(record.getTimestamp())) %>
                </td>
                <td>
                    <%= Message.getLocalizedMessage(PwmSession.getPwmSession(session).getSessionStateBean().getLocale(), record.getEventCode().getMessage()) %>
                </td>
            </tr>
            <% } %>
        </table>
        <br class="clear"/>
        <div id="buttonbar">
            <form action="<%=request.getContextPath()%>/public/<pwm:url url='CommandServlet'/>" method="post"
                  enctype="application/x-www-form-urlencoded">
                <input type="hidden"
                       name="processAction"
                       value="continue"/>
                <input type="submit" name="button" class="btn"
                       value="    <pwm:Display key="Button_Continue"/>    "
                       id="button_logout"/>
            </form>
        </div>
        <br class="clear"/>
    </div>
</div>
<%@ include file="../jsp/footer.jsp" %>
</body>
</html>
