<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2011 The PWM Project
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

<%@ page import="password.pwm.util.PwmDBLogger" %>
<%@ page import="password.pwm.util.PwmLogEvent" %>
<%@ page import="password.pwm.util.PwmLogLevel" %>
<%@ page import="password.pwm.PwmSession" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<% final PwmDBLogger pwmDBLogger = PwmSession.getPwmSession(session).getContextManager().getPwmDBLogger(); %>
<body onload="pwmPageLoadHandler();">
<div style="width: 100%; text-align:center;">
<a href="<pwm:url url='ConfigManager'/>?processAction=viewLog">refresh</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="#" onclick="self.close()">close</a>
</div>
<%
    final PwmLogLevel logLevel = PwmLogLevel.TRACE;
    final PwmDBLogger.EventType logType = PwmDBLogger.EventType.Both;
    final int eventCount = 1000;
    final long maxTime = 10000;
    final PwmDBLogger.SearchResults searchResults = pwmDBLogger.readStoredEvents(PwmSession.getPwmSession(session), logLevel, eventCount, "", "", maxTime, logType);
%>
<pre><% for (final PwmLogEvent event : searchResults.getEvents()) { %><%= event.toLogString(true) %><%="\n"%><% } %></pre>
</body>
</html>
