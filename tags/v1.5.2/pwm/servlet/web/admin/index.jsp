<%@ page import="password.pwm.PwmConstants" %>
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
<jsp:include page="../jsp/header.jsp"/>
<body onload="pwmPageLoadHandler();">
<meta http-equiv="refresh" content="0;url=<%=request.getContextPath()%><pwm:url url="/admin/status.jsp"/>"/>
<div id="wrapper">
    <jsp:include page="../jsp/header-body.jsp"><jsp:param name="pwm.PageName" value="PWM Administration"/></jsp:include>
    <div id="content">                                    o
        <div id="centerbody">
            Loading... <a href="<%=request.getContextPath()%><pwm:url url="/admin/status.jsp"/>">PWM Status</a>
        </div>
    </div>
    <br class="clear" />
</div>
<%@ include file="../jsp/footer.jsp" %>
</body>
</html>

