<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="password.pwm.ContextManager" %>
<%@ page import="password.pwm.PwmSession" %>
<%@ page import="password.pwm.bean.SessionStateBean" %>
<%@ page import="password.pwm.config.FormConfiguration" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="java.util.List" %>
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
<%@ taglib uri="pwm" prefix="pwm" %>
<table id="form">
    <%
        final PwmSession pwmSession = PwmSession.getPwmSession(session);
        final SessionStateBean ssBean = pwmSession.getSessionStateBean();
        List<FormConfiguration> formConfigurationList = ContextManager.getPwmApplication(session).getConfig().readSettingAsForm((PwmSetting)request.getAttribute("form"),ssBean.getLocale());
        for (FormConfiguration loopConfiguration : formConfigurationList) {
            final String currentValue = StringEscapeUtils.escapeHtml(ssBean.getLastParameterValues().getProperty(loopConfiguration.getAttributeName(),""));
        %>
    <% if (!loopConfiguration.getType().equals(FormConfiguration.Type.hidden)) { %>
    <tr>
        <td class="key">
            <label for="<%=loopConfiguration.getAttributeName()%>"><%= loopConfiguration.getLabel() %></label>
        </td>
        <td>
            <% if ("true".equalsIgnoreCase((String)request.getAttribute("form-readonly")) || loopConfiguration.getType().equals(FormConfiguration.Type.readonly)) { %>
            <%= currentValue %>
            <% } else { %>
            <input style="border:0; width: 100%; text-align: left;" id="<%=loopConfiguration.getAttributeName()%>" type="<%=loopConfiguration.getType()%>"
                   name="<%=loopConfiguration.getAttributeName()%>" value="<%= currentValue %>"
                    <%if(loopConfiguration.isRequired()){%> required="true"<%}%> maxlength="<%=loopConfiguration.getMaximumLength()%>"
            />
            <% } %>
        </td>
    </tr>
    <% if (loopConfiguration.isConfirmationRequired()) { %>
    <tr>
        <td class="key">
            <label id="<%=loopConfiguration.getAttributeName()%>_confirm"><pwm:Display key="Field_Confirm_Prefix"/> <%= loopConfiguration.getLabel() %></label>
        </td>
        <td>
            <input style="border:0; width: 100%" id="<%=loopConfiguration.getAttributeName()%>_confirm"
                   <%-- type="<%=loopConfiguration.getType()%>" --%> type="time"
                   name="<%=loopConfiguration.getAttributeName()%>_confirm"
                   value="<%= ssBean.getLastParameterValues().getProperty(loopConfiguration.getAttributeName(),"") %>"
                   <%if(loopConfiguration.getType().equals(FormConfiguration.Type.readonly)){%> readonly="true" disabled="true" <%}%>
                   <%if(loopConfiguration.isRequired()){%> required="true"<%}%> maxlength="<%=loopConfiguration.getMaximumLength()%>"/>
         </td>
    </tr>
    <% } %>
    <% } else { %>
    <input style="border:0; width: 100%; text-align: left;" id="<%=loopConfiguration.getAttributeName()%>" type="hidden"
           name="<%=loopConfiguration.getAttributeName()%>" value="<%= currentValue %>"/>
    <% } %>
    <% } %>
    <% if ("true".equalsIgnoreCase((String)request.getAttribute("form_showPasswordFields"))) { %>
    <tr>
        <td class="key">
            <label for="password1"><pwm:Display key="Field_NewPassword"/></label>
        </td>
        <td>
            <input style="border:0; width: 100%" type="password" name="password1" id="password1"/>
        </td>
    </tr>
    <tr>
        <td class="key">
            <label for="password2"><pwm:Display key="Field_ConfirmPassword"/></label>
        </td>
        <td>
            <input style="border:0; width: 100%" type="password" name="password2" id="password2"/>
        </td>
    </tr>
    <% } %>
</table>
