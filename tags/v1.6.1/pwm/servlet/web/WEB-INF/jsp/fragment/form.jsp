<%@ page import="password.pwm.PwmSession" %>
<%@ page import="password.pwm.bean.SessionStateBean" %>
<%@ page import="password.pwm.config.FormConfiguration" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="java.util.List" %>
<%@ page import="password.pwm.ContextManager" %>
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
<%@ taglib uri="pwm" prefix="pwm" %>
<table id="form">
    <%
        final PwmSession pwmSession = PwmSession.getPwmSession(session);
        final SessionStateBean ssBean = pwmSession.getSessionStateBean();
        List<FormConfiguration> formConfigurationList = ContextManager.getPwmApplication(session).getConfig().readSettingAsForm((PwmSetting)request.getAttribute("form"),ssBean.getLocale());
        for (FormConfiguration loopConfiguration : formConfigurationList) {
        %>
    <tr>
        <td class="key">
            <%= loopConfiguration.getLabel() %>
        </td>
        <td>
            <input style="border:0; width: 100%; text-align: left;" id="<%=loopConfiguration.getAttributeName()%>" type="<%=loopConfiguration.getType()%>"
                   name="<%=loopConfiguration.getAttributeName()%>"
                   value="<%= ssBean.getLastParameterValues().getProperty(loopConfiguration.getAttributeName(),"") %>"
                   <%if(loopConfiguration.getType().equals(FormConfiguration.Type.READONLY)){%> readonly="true" disabled="true" <%}%>
                   <%if(loopConfiguration.isRequired()){%> required="true"<%}%> maxlength="<%=loopConfiguration.getMaximumLength()%>"
                    />
        </td>
    </tr>
    <% if (loopConfiguration.isConfirmationRequired()) { %>
    <tr>
        <td class="key">
            <pwm:Display key="Field_Confirm_Prefix"/> <%= loopConfiguration.getLabel() %>
        </td>
        <td>
            <input style="border:0; width: 100%" id="<%=loopConfiguration.getAttributeName()%>_confirm" type="<%=loopConfiguration.getType()%>"
                   name="<%=loopConfiguration.getAttributeName()%>_confirm"
                   value="<%= ssBean.getLastParameterValues().getProperty(loopConfiguration.getAttributeName(),"") %>"
                   <%if(loopConfiguration.getType().equals(FormConfiguration.Type.READONLY)){%> readonly="true" disabled="true" <%}%>
                   <%if(loopConfiguration.isRequired()){%> required="true"<%}%> maxlength="<%=loopConfiguration.getMaximumLength()%>"/>
         </td>
    </tr>
    <% } %>
    <% } %>
    <% if ("true".equalsIgnoreCase((String)request.getAttribute("form_showPasswordFields"))) { %>
    <tr>
        <td class="key">
            <pwm:Display key="Field_NewPassword"/>
        </td>
        <td>
            <input style="border:0; width: 100%" type="password" name="password1" id="password1"/>
        </td>
    </tr>
    <tr>
        <td class="key">
            <pwm:Display key="Field_ConfirmPassword"/>
        </td>
        <td>
            <input style="border:0; width: 100%" type="password" name="password2" id="password2"/>
        </td>
    </tr>
    <% } %>
</table>
