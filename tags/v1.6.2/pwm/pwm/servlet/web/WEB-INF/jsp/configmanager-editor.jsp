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

<%@ page import="password.pwm.bean.ConfigManagerBean" %>
<%@ page import="password.pwm.servlet.ConfigManagerServlet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="fragment/header.jsp" %>
<% final Collection<Locale> localeList = new ArrayList<Locale>(ContextManager.getPwmApplication(session).getConfig().getKnownLocales()); %>
<% localeList.remove(Helper.localeResolver(PwmConstants.DEFAULT_LOCALE, localeList)); %>
<% final Locale locale = password.pwm.PwmSession.getPwmSession(session).getSessionStateBean().getLocale(); %>
<% final password.pwm.config.PwmSetting.Level level = password.pwm.PwmSession.getPwmSession(session).getConfigManagerBean().getLevel(); %>
<% final boolean showDesc = password.pwm.PwmSession.getPwmSession(session).getConfigManagerBean().isShowDescr(); %>
<% final ConfigManagerBean configManagerBean = password.pwm.PwmSession.getPwmSession(session).getConfigManagerBean(); %>
<% final password.pwm.config.PwmSetting.Category category = configManagerBean.getCategory(); %>
<% final PwmApplication.MODE configMode = ContextManager.getPwmApplication(session).getApplicationMode(); %>

<body class="nihilo">
<script type="text/javascript" src="<%=request.getContextPath()%><pwm:url url="/resources/configmanager.js"/>"></script>
<div id="wrapper" style="border:1px; background-color: black">
<div id="header">
    <div id="header-company-logo"></div>
    <div id="header-page">
        PWM Configuration Editor
    </div>
    <div id="header-title" style="text-align: right;">
        <% if (configMode == PwmApplication.MODE.CONFIGURATION || configMode == PwmApplication.MODE.NEW) { %>
        Editing Live Configuration
        <% } else { %>
        Editing In Memory Configuration
        <% } %>
    </div>
</div>
<div id="TopMenu">
</div>
<div id="centerbody" style="width: 600px; align: center; background-color: white; padding: 10px; margin-top: 0" >
<%@ include file="/WEB-INF/jsp/fragment/message.jsp" %>
<script type="text/javascript">
function buildMenuBar() {
    clearDijitWidget('topMenuBar');
    require(["dojo","dijit","dijit/Menu","dijit/Dialog","dijit/MenuBar","dijit/MenuItem","dijit/MenuBarItem","dijit/PopupMenuBarItem","dijit/CheckedMenuItem","dijit/MenuSeparator"],function(dojo,dijit){
        var topMenuBar = new dijit.MenuBar({id:"topMenuBar"});
        { // Settings Menu
            var settingsMenu = new dijit.Menu({});
        <% for (final PwmSetting.Category loopCategory : PwmSetting.Category.valuesByGroup(0)) { %>
        <% if (loopCategory != PwmSetting.Category.EDIRECTORY || configManagerBean.getConfiguration().template() == PwmSetting.Template.NOVL) { %>
        <% if (loopCategory == category && configManagerBean.getEditMode() == ConfigManagerServlet.EDIT_MODE.SETTINGS) { %>
            settingsMenu.addChild(new dijit.MenuItem({
                label: '<%=loopCategory.getLabel(locale)%>',
                disabled: true
            }));
        <% } else { %>
            settingsMenu.addChild(new dijit.MenuItem({
                label: '<%=loopCategory.getLabel(locale)%>',
                onClick: function() {
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&category=<%=loopCategory.toString()%>",
                        sync: false,
                        error: function(errorObj) {
                            showError("error reason: " + errorObj)
                        },
                        load: function(data) {
                            loadMainPageBody();
                        }
                    });
                }
            }));
        <% } %>
        <% } %>
        <% } %>
            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "Settings",
                popup: settingsMenu
            }));
        }
        { // Modules Menu
            var modulesMenu = new dijit.Menu({});
        <% for (final PwmSetting.Category loopCategory : PwmSetting.Category.valuesByGroup(1)) { %>
        <% if (loopCategory == category && configManagerBean.getEditMode() == ConfigManagerServlet.EDIT_MODE.SETTINGS) { %>
            modulesMenu.addChild(new dijit.MenuItem({
                label: '<%=loopCategory.getLabel(locale)%>',
                disabled: true
            }));
        <% } else { %>
            modulesMenu.addChild(new dijit.MenuItem({
                label: '<%=loopCategory.getLabel(locale)%>',
                onClick: function() {
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&category=<%=loopCategory.toString()%>",
                        sync: false,
                        error: function(errorObj) {
                            showError("error reason: " + errorObj)
                        },
                        load: function(data) {
                            loadMainPageBody();
                        }
                    });
                }
            }));
        <% } %>
        <% } %>
            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "Modules",
                popup: modulesMenu
            }));
        }
        { // Display menu
            var displayMenu = new dijit.Menu({});

        <% for (final PwmConstants.EDITABLE_LOCALE_BUNDLES localeBundle : PwmConstants.EDITABLE_LOCALE_BUNDLES.values()) { %>
        <% if (localeBundle == configManagerBean.getLocaleBundle() && configManagerBean.getEditMode() == ConfigManagerServlet.EDIT_MODE.LOCALEBUNDLE) { %>
            displayMenu.addChild(new dijit.MenuItem({
                label: '<%=localeBundle.getTheClass().getSimpleName()%>',
                disabled: true
            }));
        <% } else { %>
            displayMenu.addChild(new dijit.MenuItem({
                label: '<%=localeBundle.getTheClass().getSimpleName()%>',
                onClick: function() {
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&localeBundle=<%=localeBundle.toString()%>",
                        sync: false,
                        error: function(errorObj) {
                            showError("error loading " + keyName + ", reason: " + errorObj)
                        },
                        load: function(data) {
                            loadMainPageBody();
                        }
                    });
                }
            }));
        <% } %>
        <% } %>
            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "Custom Text",
                popup: displayMenu
            }));
        }
        { // view
            var viewMenu = new dijit.Menu({});
            viewMenu.addChild(new dijit.CheckedMenuItem({
                label: "Advanced Settings",
                checked: <%=level == PwmSetting.Level.ADVANCED ? "true" : "false"%>,
                onClick: function() {
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&level=<%=level == PwmSetting.Level.ADVANCED ? "BASIC" : "ADVANCED"%>",
                        sync: false,
                        load: function(data) {
                            loadMainPageBody();
                        }
                    });
                }
            }));
            viewMenu.addChild(new dijit.CheckedMenuItem({
                label: "Display Help Text",
                checked: <%=showDesc ? "true" : "false"%>,
                onClick: function() {
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&showDesc=<%=showDesc ? "false" : "true"%>",
                        sync: false,
                        load: function(data) {
                            loadMainPageBody();
                        }
                    });
                }
            }));
            viewMenu.addChild(new dijit.MenuSeparator());
            viewMenu.addChild(new dijit.MenuItem({
                label: "Configuration Notes",
                onClick: function() {
                    showConfigurationNotes();
                }
            }));
            viewMenu.addChild(new dijit.MenuItem({
                label: "PWM Macro Help",
                onClick: function() {
                    var idName = 'dialogPopup';
                    clearDijitWidget(idName);
                    var theDialog = new dijit.Dialog({
                        id: idName,
                        title: 'PWM Macro Help',
                        style: "width: 550px",
                        href: "<pwm:url url="/pwm/resources/macroHelp.html"/>"
                    });
                    theDialog.show();
                }
            }));
            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "View",
                popup: viewMenu
            }));
        }

        { // Templates
            var templateMenu = new dijit.Menu({});
        <% for (final PwmSetting.Template template : PwmSetting.Template.values()) { %>
        <% final boolean isCurrentTemplate = configManagerBean.getConfiguration().template() == template; %>
            templateMenu.addChild(new dijit.CheckedMenuItem({
                label: "<%=template.getDescription()%>",
                checked: <%=isCurrentTemplate ? "true" : "false"%>,
                onClick: function() {
                    if (!confirm('Are you sure you want to change the default settings template?  \n\nIf you proceed, be sure to closely review the resulting configuration as any settings using default values may change.')) {
                        return;
                    }
                    showWaitDialog();
                    dojo.xhrGet({
                        url:"ConfigManager?processAction=setOption&pwmFormID=" + PWM_GLOBAL['pwmFormID'] + "&template=<%=template.toString()%>",
                        sync: true,
                        error: function(errorObj) {
                            showError("error loading " + keyName + ", reason: " + errorObj)
                        },
                        load: function(data) {
                            window.location = "ConfigManager";
                        }
                    });
                }
            }));
        <% } %>
            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "Template",
                popup: templateMenu
            }));
        }
        { // Actions
            var actionsMenu = new dijit.Menu({});

        <% if (ContextManager.getPwmApplication(session).getApplicationMode() == PwmApplication.MODE.RUNNING) { %>
            actionsMenu.addChild(new dijit.MenuItem({
                label: "Finish Editing",
                onClick: function() {
                    showWaitDialog('Updating Configuration');
                    setTimeout(function() {
                        document.forms['completeEditing'].submit();
                    }, 1000)
                }
            }));
        <% } else { %>
            actionsMenu.addChild(new dijit.MenuItem({
                label: "Save",
                iconClass: "dijitEditorIcon dijitEditorIconSave",
                onClick: function() {
                    if (confirm('Are you sure you want to save the changes to the current PWM configuration?')) {
                        saveConfiguration();
                    }
                }
            }));
        <% } %>
            actionsMenu.addChild(new dijit.MenuItem({
                label: "Cancel",
                iconClass: "dijitEditorIcon dijitEditorIconCancel",
                onClick: function() {
                    document.forms['cancelEditing'].submit();
                }
            }));

            topMenuBar.addChild(new dijit.PopupMenuBarItem({
                label: "Actions",
                popup: actionsMenu
            }));
        }
        topMenuBar.placeAt("TopMenu");
        topMenuBar.startup();

    });
}

require(["dojo","dojo/domReady!"],function(dojo){
    buildMenuBar();
    if(dojo.isIE <= 8){ // only IE8 and below
        alert('Internet Explorer 8 and below is not able to correctly load this page.  Please use a newer version of IE or a different browser.');
    }
});

function loadMainPageBody() {
    window.location = '<%=request.getContextPath()%><pwm:url url="/config/ConfigManager"/>';
}

</script>
<form action="<pwm:url url='ConfigManager'/>" method="post" name="completeEditing"
      enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="processAction" value="finishEditing"/>
    <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
</form>
<form action="<pwm:url url='ConfigManager'/>" method="post" name="cancelEditing"
      enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="processAction" value="cancelEditing"/>
    <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
</form>
<div id="mainContentPane" style="width: 600px">
    <% if (configManagerBean.getEditMode() == ConfigManagerServlet.EDIT_MODE.SETTINGS) { %>
    <jsp:include page="configmanager-editor-settings.jsp"/>
    <% } else if (configManagerBean.getEditMode() == ConfigManagerServlet.EDIT_MODE.LOCALEBUNDLE) { %>
    <jsp:include page="configmanager-editor-localeBundle.jsp"/>
    <% } %>
</div>
</div>
</div>
<br/>
<br/>
<div style="background:  black; color: white;"><%@ include file="fragment/footer.jsp" %></div>
</body>
</html>
