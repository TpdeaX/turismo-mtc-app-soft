<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="usuario" value="${sessionScope.usuario}" />

<c:set var="p_dashboard" value="false" />
<c:set var="p_horarios" value="false" />
<c:set var="p_reportes" value="false" />
<c:set var="p_empleados" value="false" />
<c:set var="p_config" value="false" />

<c:choose>
    <c:when test="${usuario.rol == 'ADMIN' or usuario.rol == 'SUPER_ADMIN'}">
        <c:set var="p_dashboard" value="true" />
        <c:set var="p_horarios" value="true" />
        <c:set var="p_reportes" value="true" />
        <c:set var="p_empleados" value="true" />
        <c:set var="p_config" value="true" />
    </c:when>

    <c:when test="${usuario.rol == 'PERSONALIZADO'}">
        <c:forEach items="${usuario.permisos}" var="permiso">
            <c:if test="${permiso.nombre == 'VER_DASHBOARD_TOTAL'}"> <c:set var="p_dashboard" value="true" /> </c:if>
            <c:if test="${permiso.nombre == 'EDITAR_HORARIOS'}">     <c:set var="p_horarios" value="true" /> </c:if>
            <c:if test="${permiso.nombre == 'VER_REPORTES'}">        <c:set var="p_reportes" value="true" /> </c:if>
            <c:if test="${permiso.nombre == 'GESTIONAR_EMPLEADOS'}"> <c:set var="p_empleados" value="true" /> </c:if>
            <c:if test="${permiso.nombre == 'CONFIGURACION_SISTEMA'}"><c:set var="p_config" value="true" /> </c:if>
        </c:forEach>
    </c:when>
</c:choose>

<%
    String currentPath = (String) request.getAttribute("jakarta.servlet.forward.servlet_path");
    if (currentPath == null) {
        currentPath = request.getServletPath();
    }

    boolean isHorarios = currentPath.contains("/horarios");
    boolean isAsistencias = currentPath.contains("/asistencias");
    boolean isOperacionesOpen = isHorarios || isAsistencias;
    boolean isJustificaciones = currentPath.contains("/justificaciones");
    
    boolean isCalculo = currentPath.contains("/reportes/calculo");
    boolean isReporteHoras = currentPath.contains("/reportes/horas");
    boolean isReportePuntualidad = currentPath.contains("/reportes/puntualidad");
    boolean isReportesOpen = isCalculo || isReporteHoras || isReportePuntualidad;
    
    boolean isSucursales = currentPath.contains("/sucursales");
    boolean isEmpleados = currentPath.contains("/empleados");
    boolean isEmpresas = currentPath.contains("/empresas");
    boolean isOrganizacionOpen = isSucursales || isEmpleados || isEmpresas;
    
    boolean isTipoTurno = currentPath.contains("/tipoturno");
    boolean isFeriados = currentPath.contains("/feriados");
    boolean isParametrosGenerales = currentPath.contains("/parametros/generales");
    boolean isConfiguracionOpen = isTipoTurno || isFeriados || isParametrosGenerales;
    
    boolean isDashboard = currentPath.equals("/admin") || currentPath.endsWith("/dashboard.jsp") || currentPath.endsWith("/admin/") || currentPath.contains("/dashboard");
    
    boolean isEmpleadoPage = currentPath.equals("/empleado") || currentPath.endsWith("/empleado/");
    boolean isHistorial = currentPath.contains("/mi-historial");
%>

<style>
    :root {
        --sidebar-width: 280px;
        --sidebar-bg: var(--bg-sidebar);
        --primary-color: var(--color-primary); 
        --hover-bg: var(--bg-hover);
        --active-bg: var(--color-surface-tint);
        --sidebar-mini-width: 80px;
    }

    body {
        padding: 0 !important;
        margin: 0 !important;
        overflow-x: hidden;
    }
    
    .main-content {
        width: auto;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        box-sizing: border-box;
    }
    
    /* Cuando el sidebar estÃ¡ anclado, el main-content debe calcular su ancho correctamente */
    html.sidebar-pinned .main-content {
        width: calc(100vw - var(--sidebar-width));
        margin-left: var(--sidebar-width);
    }
    
    html.sidebar-pinned.sidebar-minimized .main-content,
    html.sidebar-pinned .sidebar.minimized ~ .main-content,
    html.sidebar-pinned:has(.sidebar.minimized) .main-content {
        width: calc(100vw - var(--sidebar-mini-width));
        margin-left: var(--sidebar-mini-width);
    }

    #sidebar-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(0,0,0,0.5);
        z-index: 1150;
        display: none;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    #sidebar-overlay.active {
        display: block;
        opacity: 1;
    }

    .sidebar {
        width: var(--sidebar-width);
        background-color: var(--sidebar-bg);
        height: 100vh;
        position: fixed;
        top: 0;
        left: 0;
        display: flex;
        flex-direction: column;
        border-right: 1px solid var(--border-color);
        z-index: 1200;
        transition: transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1), 
                    width 0.4s cubic-bezier(0.25, 0.8, 0.25, 1), background-color 0.3s, border-color 0.3s;
        overflow: hidden; 
        box-shadow: 2px 0 8px var(--shadow-sm);
    }
    
    .sidebar.closed {
        transform: translateX(-100%);
    }

    .sidebar-header {
        padding: 0 16px;
        height: 64px;
        display: flex;
        justify-content: flex-start;
        align-items: center;
        border-bottom: 1px solid transparent;
        flex-shrink: 0;
    }

    .sidebar-logo {
        max-width: 100%;
        height: auto;
        display: block;
        max-height: 80px;
    }

    .sidebar-menu {
        flex: 1;
        overflow-y: auto;
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    
    .sidebar-menu::-webkit-scrollbar {
        width: 4px;
        display: none;
    }
    .sidebar-menu:hover::-webkit-scrollbar, .sidebar-menu:focus-within::-webkit-scrollbar {
        display: block;
    }
    .sidebar-menu::-webkit-scrollbar-thumb {
        background-color: var(--border-color);
        border-radius: 4px;
    }
    .sidebar-menu {
        scrollbar-width: none;
        -ms-overflow-style: none;
    }

    .menu-category {
        font-size: 0.75rem;
        font-weight: 500;
        color: var(--text-secondary);
        padding: 16px 16px 8px 16px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 8px;
    }

    .nav-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 16px;
        border-radius: 8px;
        text-decoration: none;
        color: var(--icon-color);
        font-size: 0.95rem;
        font-weight: 500;
        transition: all 0.2s ease, padding 0.2s ease;
        cursor: pointer;
        position: relative;
    }

    .nav-label {
        white-space: nowrap;
        opacity: 1;
        transition: opacity 0.2s ease;
    }

    .nav-content {
        display: flex;
        align-items: center;
        gap: 16px;
        transition: gap 0.3s ease;
    }

    .nav-item:hover {
        background-color: var(--hover-bg);
        color: var(--text-primary);
    }

    .nav-item.active {
        background-color: #FFF0F5;
        color: #880E4F;
    }

    .material-symbols-outlined {
        font-size: 24px;
        color: var(--icon-color);
    }
    
    .nav-item.active .material-symbols-outlined {
        color: #880E4F;
        font-variation-settings: 'FILL' 1;
    }
    
    .dropdown-arrow {
        width: 24px !important;
        height: 24px !important;
        min-width: 24px !important;
        display: grid !important;
        place-items: center !important;
        transform-origin: 50% 50% !important;
        font-size: 20px !important;
        line-height: 1 !important;
        margin: 0 !important;
        padding: 0 !important;
        transition: transform 0.3s ease;
    }
    
    .nav-item.expanded .dropdown-arrow {
        transform: rotate(180deg);
    }
    
    .submenu {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        padding-left: 0;
    }

    .submenu.open {
        max-height: 500px;
    }
    
    .submenu .nav-item {
        padding-left: 56px;
        font-size: 0.9rem;
    }

    .sidebar-footer {
        padding: 12px 16px;
        border-top: 1px solid var(--border-color);
        font-size: 0.9rem;
        color: var(--text-secondary);
        flex-shrink: 0;
        background-color: var(--bg-sidebar);
        transition: background-color 0.3s, border-color 0.3s;
    }

    .pin-toggle {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
        padding: 12px;
        border-radius: 8px;
        transition: background 0.2s;
        user-select: none;
    }

    .pin-toggle:hover {
        background-color: var(--hover-bg);
    }
    
    .pin-icon {
        transition: transform 0.3s;
    }
    .pin-toggle.pinned .pin-icon {
        transform: rotate(45deg);
        color: #880E4F;
    }

    .sidebar.minimized {
        width: var(--sidebar-mini-width);
    }
    
    .menu-category, .nav-label, .dropdown-arrow, .sidebar-footer div:last-child {
        transition: opacity 0.2s ease, transform 0.2s ease;
        transform-origin: left center;
    }

    .pin-toggle span:last-child {
         transition: opacity 0.2s ease;
    }

    .sidebar.minimized .menu-category,
    .sidebar.minimized .nav-label,
    .sidebar.minimized .dropdown-arrow,
    .sidebar.minimized .pin-toggle span:last-child,
    .sidebar.minimized .sidebar-footer div:last-child {
        display: none;
    }
    
    .sidebar.minimized .nav-item {
        justify-content: center;
        padding: 12px;
    }
    
    .sidebar.minimized .nav-content {
        gap: 0;
    }
    
    .sidebar.minimized .sidebar-header {
        flex-direction: column;
        padding: 12px 0;
        height: auto;
        gap: 8px;
        overflow: hidden;
    }
    
    .sidebar.minimized .sidebar-header .icon-btn {
        margin-right: 0 !important;
    }

    .sidebar.minimized .sidebar-logo.full-logo {
        display: none;
    }
    
    .sidebar.minimized .sidebar-logo.icon-logo {
        display: block !important;
        width: 32px; 
        height: auto;
    }
    
    .sidebar.minimized .pin-toggle {
        justify-content: center;
    }
    
    .sidebar.minimized, 
    .sidebar.minimized .sidebar-menu {
        overflow: visible !important;
    }
    
    .sidebar.minimized .submenu {
        display: block !important;
        visibility: hidden;
        opacity: 0;
        transform: translateX(-10px);
        transition: opacity 0.2s ease, transform 0.2s ease, visibility 0.2s;
        
        position: absolute;
        left: calc(100% + 15px);
        top: 0;
        width: 240px; 
        background-color: var(--sidebar-bg);
        border: 1px solid var(--border-color);
        border-left: 4px solid var(--primary-color);
        border-radius: 8px;
        box-shadow: 6px 0 16px rgba(0,0,0,0.1);
        padding: 8px 0;
        z-index: 9999;
        max-height: none !important;
        overflow: visible !important;
    }

    .sidebar.minimized .submenu::after {
        content: '';
        position: absolute;
        top: 20px;
        left: -8px;
        width: 16px;
        height: 16px;
        background-color: var(--sidebar-bg);
        border-left: 1px solid var(--border-color);
        border-bottom: 1px solid var(--border-color);
        transform: rotate(45deg);
    }
    
    .sidebar.minimized .submenu.floating-open {
        visibility: visible;
        opacity: 1;
        transform: translateX(0);
    }
    
    .sidebar.minimized .submenu .nav-item {
        padding: 12px 20px;
        justify-content: flex-start !important;
        text-align: left !important;
        width: 100%;
        border-radius: 4px;
        margin: 0 4px;
        width: calc(100% - 8px);
    }
    
    .sidebar.minimized .submenu .nav-content {
        justify-content: flex-start !important;
        width: 100%;
        gap: 12px;
    }
    
    .sidebar.minimized .submenu .nav-label {
        display: block !important;
        opacity: 1 !important;
        color: var(--text-secondary);
        font-weight: 500;
        text-align: left !important; 
        flex: 1;
    }
    
    .sidebar.minimized .submenu .nav-item:hover {
        background-color: var(--hover-bg);
    }
    
    .sidebar.minimized .submenu .nav-item:hover .nav-label {
        color: var(--text-primary);
    }
    
    .submenu .nav-item {
        justify-content: flex-start !important;
        gap: 12px;
    }
    
    .nav-item-group {
        position: relative;
    }
</style>

<div id="sidebar-overlay" onclick="closeSidebar()"></div>

<div id="app-sidebar" class="sidebar">
    <div class="sidebar-header">
        <div class="icon-btn sidebar-menu-toggle" onclick="toggleSidebar()" style="margin-right: 16px; cursor: pointer; display: flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 50%;">
            <span class="material-symbols-outlined">menu</span>
        </div>
        <img src="${pageContext.request.contextPath}/assets/${not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana.png'}"
             data-logo-light="${not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana.png'}"
             data-logo-dark="${not empty sessionScope.empresaActiva.logoPathForDark ? sessionScope.empresaActiva.logoPathForDark : (not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana-dm.png')}"
             alt="${not empty sessionScope.empresaActiva.nombre ? sessionScope.empresaActiva.nombre : 'Grupo Peruana'}" class="sidebar-logo full-logo">
        <img src="${pageContext.request.contextPath}/assets/${not empty sessionScope.empresaActiva.iconPath ? sessionScope.empresaActiva.iconPath : 'logo-peruana-icon.png'}"
             data-icon-light="${not empty sessionScope.empresaActiva.iconPath ? sessionScope.empresaActiva.iconPath : 'logo-peruana-icon.png'}"
             data-icon-dark="${not empty sessionScope.empresaActiva.iconPathForDark ? sessionScope.empresaActiva.iconPathForDark : (not empty sessionScope.empresaActiva.iconPath ? sessionScope.empresaActiva.iconPath : 'logo-peruana-icon.png')}"
             alt="Logo" class="sidebar-logo icon-logo" style="display:none;">
    </div>

    <div class="sidebar-menu">
        <c:if test="${p_dashboard}">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item <%= isDashboard ? "active" : "" %>">
                <div class="nav-content">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span class="nav-label">Dashboard</span>
                </div>
            </a>
        </c:if>

        <c:if test="${usuario.rol != 'ADMIN' and usuario.rol != 'SUPER_ADMIN'}">
        <div class="menu-category">Mi GestiÃ³n</div>
        <a href="${pageContext.request.contextPath}/empleado" class="nav-item <%= isEmpleadoPage ? "active" : "" %>">
             <div class="nav-content">
                <span class="material-symbols-outlined">person</span>
                <span class="nav-label">Mis Asistencias</span>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/justificaciones" class="nav-item <%= isJustificaciones ? "active" : "" %>">
             <div class="nav-content">
                <span class="material-symbols-outlined">event_busy</span>
                <span class="nav-label">Ausencias y Justif.</span>
            </div>
        </a>
        </c:if>

        <c:if test="${p_horarios}">
            <div class="menu-category">Operaciones</div>
            <div class="nav-item-group">
                 <div class="nav-item <%= isOperacionesOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                    <div class="nav-content">
                        <span class="material-symbols-outlined">calendar_month</span>
                        <span class="nav-label">Horarios y Marcaciones</span>
                    </div>
                    <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
                </div>
                <div class="submenu <%= isOperacionesOpen ? "open" : "" %>" style="<%= isOperacionesOpen ? "max-height: 500px;" : "" %>">
                     <a href="${pageContext.request.contextPath}/horarios" class="nav-item <%= isHorarios ? "active" : "" %>">
                        <span class="material-symbols-outlined" style="font-size: 20px;">edit_calendar</span>
                        <span class="nav-label">Gestionar Horarios</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/asistencias" class="nav-item <%= isAsistencias ? "active" : "" %>">
                        <span class="material-symbols-outlined" style="font-size: 20px;">fact_check</span>
                        <span class="nav-label">Ver Asistencias</span>
                    </a>
                </div>
            </div>
        </c:if>

        <c:if test="${p_reportes}">
            <div class="menu-category">Análisis</div>
            <div class="nav-item-group">
                <div class="nav-item <%= isReportesOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                    <div class="nav-content">
                        <span class="material-symbols-outlined">bar_chart</span>
                        <span class="nav-label">Reportes</span>
                    </div>
                    <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
                </div>
                <div class="submenu <%= isReportesOpen ? "open" : "" %>" style="<%= isReportesOpen ? "max-height: 500px;" : "" %>">
                    <a href="${pageContext.request.contextPath}/reportes/calculo" class="nav-item <%= isCalculo ? "active" : "" %>">
                        <span class="material-symbols-outlined" style="font-size: 20px;">description</span>
                        <span class="nav-label">Calculo de Asistencias</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/reportes/horas" class="nav-item <%= isReporteHoras ? "active" : "" %>">
                         <span class="material-symbols-outlined" style="font-size: 20px;">schedule</span>
                        <span class="nav-label">Reporte de Horas</span>
                    </a>
                     <a href="${pageContext.request.contextPath}/reportes/puntualidad" class="nav-item <%= isReportePuntualidad ? "active" : "" %>">
                         <span class="material-symbols-outlined" style="font-size: 20px;">trending_up</span>
                        <span class="nav-label">Reporte de Puntualidad</span>
                    </a>
                </div>
            </div>
        </c:if>

        <c:if test="${p_config or p_empleados}">
            <div class="menu-category">Gestión General</div>
             <div class="nav-item-group">
                <div class="nav-item <%= isOrganizacionOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                    <div class="nav-content">
                        <span class="material-symbols-outlined">domain</span>
                        <span class="nav-label">Organización</span>
                    </div>
                    <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
                </div>
                <div class="submenu <%= isOrganizacionOpen ? "open" : "" %>" style="<%= isOrganizacionOpen ? "max-height: 500px;" : "" %>">
                    <c:if test="${usuario.rol == 'SUPER_ADMIN' or (usuario.rol == 'ADMIN' and not empty usuario.empresas and usuario.empresas.size() > 1)}">
                        <a href="${pageContext.request.contextPath}/empresas" class="nav-item <%= isEmpresas ? "active" : "" %>">
                           <span class="material-symbols-outlined" style="font-size: 20px;">business</span>
                           <span class="nav-label">Empresas</span>
                        </a>
                    </c:if>
                    <c:if test="${p_config and (usuario.rol != 'ADMIN' or usuario.tieneAccesoTodasSucursales())}">
                        <a href="${pageContext.request.contextPath}/sucursales" class="nav-item <%= isSucursales ? "active" : "" %>">
                           <span class="material-symbols-outlined" style="font-size: 20px;">store</span>
                           <span class="nav-label">Sucursales</span>
                        </a>
                    </c:if>
                    <c:if test="${p_empleados}">
                        <a href="${pageContext.request.contextPath}/empleados" class="nav-item <%= isEmpleados ? "active" : "" %>">
                           <span class="material-symbols-outlined" style="font-size: 20px;">group</span>
                           <span class="nav-label">Personal</span>
                        </a>
                    </c:if>
                </div>
            </div>
        </c:if>
        
        <c:if test="${p_config}">
            <div class="menu-category">Configuración</div>
            <div class="nav-item-group">
                <div class="nav-item <%= isConfiguracionOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                    <div class="nav-content">
                        <span class="material-symbols-outlined">settings_suggest</span>
                        <span class="nav-label">Parámetros</span>
                    </div>
                    <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
                </div>
                <div class="submenu <%= isConfiguracionOpen ? "open" : "" %>" style="<%= isConfiguracionOpen ? "max-height: 500px;" : "" %>">
                     <a href="${pageContext.request.contextPath}/tipoturno" class="nav-item <%= isTipoTurno ? "active" : "" %>">
                        <span class="material-symbols-outlined" style="font-size: 20px;">work_history</span>
                        <span class="nav-label">Tipos de Turno</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/feriados" class="nav-item <%= isFeriados ? "active" : "" %>">
                        <span class="material-symbols-outlined" style="font-size: 20px;">celebration</span>
                        <span class="nav-label">Feriados</span>
                    </a>
                    <c:if test="${usuario.rol != 'ADMIN' or usuario.tieneAccesoTotalSistema()}">
                        <a href="${pageContext.request.contextPath}/parametros/generales" class="nav-item <%= isParametrosGenerales ? "active" : "" %>">
                            <span class="material-symbols-outlined" style="font-size: 20px;">tune</span>
                            <span class="nav-label">Parámetros Generales</span>
                        </a>
                    </c:if>
                </div>
            </div>
        </c:if>
        
        <div style="margin-top: auto;"></div>
         <div class="menu-category">Ayuda</div>
        <a href="#" class="nav-item" onclick="downloadDocumentation(event)">
             <div class="nav-content">
                <span class="material-symbols-outlined">help</span>
                <span class="nav-label">Documentación</span>
            </div>
        </a>
        <a href="#" class="nav-item" onclick="contactSupport(event)">
             <div class="nav-content">
                <span class="material-symbols-outlined">support_agent</span>
                <span class="nav-label">Soporte</span>
            </div>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="pin-toggle" onclick="togglePinstate()" id="pinToggleBtn">
            <span class="material-symbols-outlined pin-icon">push_pin</span>
            <span>Menú Anclado</span>
        </div>
        <div style="text-align: center; margin-top: 10px; font-size: 0.75rem; color: #999;">
             ©2025 ${not empty sessionScope.empresaActiva.nombre ? sessionScope.empresaActiva.nombre : 'La Peruana'}
        </div>
    </div>
</div>

<script>
    function safeToast(message, type) {
        if (typeof showToast === 'function') {
             if (typeof activeToasts !== 'undefined') {
                 var icon = 'info';
                 if(type === 'success') icon = 'check_circle';
                 if(type === 'error') icon = 'error';
                 showToast('Sistema', message, type, icon);
             } else {
                 showToast(message, type);
             }
        }
    }

    function downloadDocumentation(e) {
        if(e) e.preventDefault();
        safeToast('Descargando documentaciÃ³n...', 'success');
        window.open('https://docs.google.com/viewer?url=https://github.com/TpdeaX/grupo-peruana-asistencia-pooII-sp/raw/main/INFORME%20DE%20POO2.pdf&embedded=false', '_blank');
    }

    function contactSupport(e) {
        if(e) e.preventDefault();
        var numbers = ['51975198852', '51991806740'];
        var randomNum = numbers[Math.floor(Math.random() * numbers.length)];
        
        safeToast('Conectando con un asesor...', 'success');
        var url = 'https://api.whatsapp.com/send?phone=' + randomNum;
        window.open(url, '_blank');
    }

    const sidebar = document.getElementById('app-sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const pinBtn = document.getElementById('pinToggleBtn');
    
    const currentUserId = '${sessionScope.usuario.id}';
    let storedState = localStorage.getItem('sidebarPinned_' + currentUserId);
    let isPinned = storedState === null ? true : storedState === 'true';

    let storedMinimized = localStorage.getItem('sidebarMinimized_' + currentUserId);
    let isMinimized = storedMinimized === 'true';

    (function initSidebarImmediate() {
        if (isPinned) {
            document.documentElement.classList.add('sidebar-pinned');
            if(sidebar) {
                sidebar.classList.remove('closed');
                if (isMinimized) {
                    sidebar.classList.add('minimized');
                    document.documentElement.classList.add('sidebar-minimized');
                } else {
                    sidebar.classList.remove('minimized');
                    document.documentElement.classList.remove('sidebar-minimized');
                }
            }
            if(pinBtn) pinBtn.classList.add('pinned');
            if(overlay) overlay.classList.remove('active');
        } else {
            document.documentElement.classList.remove('sidebar-pinned');
            document.documentElement.classList.remove('sidebar-minimized');
            if(sidebar) {
                 sidebar.classList.add('closed');
                 sidebar.classList.remove('minimized');
            }
            if(pinBtn) pinBtn.classList.remove('pinned');
        }
    })();

    function togglePinstate() {
        isPinned = !isPinned;
        localStorage.setItem('sidebarPinned_' + currentUserId, isPinned);
        
        if (isPinned) {
            pinBtn.classList.add('pinned');
             sidebar.classList.remove('closed');
             document.documentElement.classList.add('sidebar-pinned');
             if(isMinimized) {
                 sidebar.classList.add('minimized');
                 document.documentElement.classList.add('sidebar-minimized');
             }
             overlay.classList.remove('active'); 
        } else {
            pinBtn.classList.remove('pinned');
             document.documentElement.classList.remove('sidebar-pinned');
             document.documentElement.classList.remove('sidebar-minimized');
             closeSidebar();
             sidebar.classList.remove('minimized');
             closeAllFloatingMenus();
        }
    }
    
    function openSidebar() {
        sidebar.classList.remove('closed');
        if (!isPinned) {
            overlay.classList.add('active');
        }
    }
    
    function closeSidebar() {
        if (!isPinned) {
            sidebar.classList.add('closed');
            overlay.classList.remove('active');
        }
    }
    
    function toggleSidebar() {
        if (sidebar.classList.contains('closed')) {
            openSidebar();
        } else {
            if (isPinned) {
               sidebar.classList.toggle('minimized');
               isMinimized = sidebar.classList.contains('minimized');
               localStorage.setItem('sidebarMinimized_' + currentUserId, isMinimized);
               if(isMinimized) {
                   document.documentElement.classList.add('sidebar-minimized');
               } else {
                   document.documentElement.classList.remove('sidebar-minimized');
               }

               if(sidebar.classList.contains('minimized')) {
                   closeAllFloatingMenus();
               }
            } else {
               closeSidebar();
            }
        }
    }
    
    function closeAllFloatingMenus() {
        document.querySelectorAll('.submenu.floating-open').forEach(el => {
            el.classList.remove('floating-open');
        });
    }
    
    function toggleSubmenu(header) {
        if (sidebar.classList.contains('minimized')) {
             const submenu = header.nextElementSibling;
             if(submenu) {
                 document.querySelectorAll('.submenu.floating-open').forEach(el => {
                     if(el !== submenu) el.classList.remove('floating-open');
                 });
                 submenu.classList.toggle('floating-open');
             }
             return;
        }

        const submenu = header.nextElementSibling;
        if (submenu && submenu.classList.contains('submenu')) {
            const isOpen = submenu.classList.contains('open');
            if (isOpen) {
                submenu.style.maxHeight = null;
                submenu.classList.remove('open');
                header.classList.remove('expanded');
            } else {
                submenu.classList.add('open');
                header.classList.add('expanded');
                submenu.style.maxHeight = submenu.scrollHeight + "px";
            }
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
         if (isPinned && sidebar) sidebar.classList.remove('closed');
    });

    window.toggleSidebarGlobal = toggleSidebar;

    document.addEventListener('click', function(event) {
        if (sidebar && sidebar.classList.contains('minimized')) {
            const isClickInsideSidebar = sidebar.contains(event.target);
            const isFloatingMenu = event.target.closest('.submenu.floating-open');
            if (!isClickInsideSidebar && !isFloatingMenu) {
                closeAllFloatingMenus();
            }
        }
    });
</script>

<c:if test="${not empty sessionScope.usuario}">
    <input type="hidden" id="session-user-dni" value="<c:out value='${sessionScope.usuario.dni}'/>" />
    <input type="hidden" id="session-user-nombres" value="<c:out value='${sessionScope.usuario.nombres}'/>" />
    <input type="hidden" id="session-user-apellidos" value="<c:out value='${sessionScope.usuario.apellidos}'/>" />
    <input type="hidden" id="session-user-rol" value="<c:out value='${sessionScope.usuario.rol}'/>" />

<script>
    document.addEventListener("DOMContentLoaded", function() {
        try {
            const getVal = (id) => {
                const el = document.getElementById(id);
                return el ? el.value.trim() : '';
            };

            const dni = getVal('session-user-dni');
            const n = getVal('session-user-nombres');
            const a = getVal('session-user-apellidos');
            const rol = getVal('session-user-rol');

            var i1 = (n && n.length > 0) ? n.charAt(0) : 'U';
            var i2 = (a && a.length > 0) ? a.charAt(0) : '';

            let passwordToSave = null;
            const pendingAuthStr = sessionStorage.getItem('pending_auth');
            if (pendingAuthStr) {
                try {
                    const pendingAuth = JSON.parse(pendingAuthStr);
                    if (pendingAuth.dni === dni) {
                        passwordToSave = pendingAuth.password;
                    }
                } catch(e) {}
                sessionStorage.removeItem('pending_auth');
            }

            let sessions = [];
            try {
                sessions = JSON.parse(localStorage.getItem('saved_sessions') || '[]');
                if(!Array.isArray(sessions)) sessions = [];
            } catch(e) { sessions = []; }
            
            if (!passwordToSave) {
                const existingSession = sessions.find(s => s.dni === dni);
                if (existingSession && existingSession.password) {
                    passwordToSave = existingSession.password;
                }
            }
            
            const user = {
                dni: dni,
                nombres: n,
                apellidos: a,
                rol: rol,
                avatar: (i1 + i2).toUpperCase(),
                password: passwordToSave
            };
            
            sessions = sessions.filter(s => s.dni !== user.dni);
            sessions.unshift(user);
            if (sessions.length > 5) sessions.pop();
            
            localStorage.setItem('saved_sessions', JSON.stringify(sessions));
            
        } catch(e) { console.error("Error saving session", e); }
    });
</script>
</c:if>
