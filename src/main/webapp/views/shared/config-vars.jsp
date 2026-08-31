<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 
    Componente: config-vars.jsp
    Propósito: Inyectar configuraciones del sistema como variables JavaScript globales
    para que puedan ser consumidas por scripts del frontend.
    
    Uso: Incluir este archivo en cualquier JSP que necesite acceso a las configuraciones:
    <jsp:include page="../shared/config-vars.jsp" />
    
    Luego en JavaScript:
    if (window.SYSTEM_CONFIG.ui_blur_modal) { ... }
--%>
<script>
    // Configuración del Sistema - Variables Globales
    window.SYSTEM_CONFIG = window.SYSTEM_CONFIG || {};
    
    // UI Settings
    <c:choose>
        <c:when test="${configs['ui_blur_modal'] == 'true'}">
            window.SYSTEM_CONFIG.ui_blur_modal = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.ui_blur_modal = false;
        </c:otherwise>
    </c:choose>
    
    // Asistencia Settings
    window.SYSTEM_CONFIG.asistencia_tolerancia = ${not empty configs['asistencia_tolerancia'] ? configs['asistencia_tolerancia'] : 15};
    window.SYSTEM_CONFIG.asistencia_hora_entrada = '${not empty configs["asistencia_hora_entrada"] ? configs["asistencia_hora_entrada"] : "08:00"}';
    
    <c:choose>
        <c:when test="${configs['asistencia_permitir_extras'] == 'true'}">
            window.SYSTEM_CONFIG.asistencia_permitir_extras = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.asistencia_permitir_extras = false;
        </c:otherwise>
    </c:choose>
    
    // Descuentos Settings
    <c:choose>
        <c:when test="${configs['descuento_falta_enabled'] == 'true'}">
            window.SYSTEM_CONFIG.descuento_falta_enabled = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.descuento_falta_enabled = false;
        </c:otherwise>
    </c:choose>
    
    <c:choose>
        <c:when test="${configs['descuento_tardanza_enabled'] == 'true'}">
            window.SYSTEM_CONFIG.descuento_tardanza_enabled = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.descuento_tardanza_enabled = false;
        </c:otherwise>
    </c:choose>
    
    // Configuración de Empresa Activa (Multi-empresa)
    window.EMPRESA_CONFIG = {
        codigo: '${not empty sessionScope.empresaActiva.codigo ? sessionScope.empresaActiva.codigo : "PERUANA"}',
        nombre: '${not empty sessionScope.empresaActiva.nombre ? sessionScope.empresaActiva.nombre : "La Peruana"}',
        colorPrimario: '${not empty sessionScope.empresaActiva.colorPrimario ? sessionScope.empresaActiva.colorPrimario : "#EC407A"}',
        colorSecundario: '${not empty sessionScope.empresaActiva.colorSecundario ? sessionScope.empresaActiva.colorSecundario : "#BA68C8"}',
        logoPath: '${not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : "logo-peruana.png"}',
        iconPath: '${not empty sessionScope.empresaActiva.iconPath ? sessionScope.empresaActiva.iconPath : "logo-peruana-icon.png"}'
    };
    
    // Aplicar colores de marca dinámicamente
    document.documentElement.style.setProperty('--brand-primary', window.EMPRESA_CONFIG.colorPrimario);
    document.documentElement.style.setProperty('--brand-secondary', window.EMPRESA_CONFIG.colorSecundario);
</script>
