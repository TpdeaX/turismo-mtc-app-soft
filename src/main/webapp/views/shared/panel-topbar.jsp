<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="topbar">
    <div class="row center g-3" style="min-width:0">
        <button type="button" class="btn-icon nav-toggle" data-sidebar-toggle aria-label="Abrir menú">
            <span class="mi mi-sm">menu</span>
        </button>
        <div class="crumbs">
            <a href="${ctx}/panel">Panel</a>
            <c:if test="${not empty tituloModulo}">
                <span class="sep">/</span>
                <span class="now">${tituloModulo}</span>
            </c:if>
        </div>
    </div>

    <div class="row center g-2">
        <span class="chip chip-success" title="Estado de las integraciones periódicas">
            <i class="dot dot-live"></i> Sistemas operativos
        </span>
        <button type="button" class="btn-icon" data-tema title="Cambiar tema" aria-label="Cambiar tema">
            <span class="mi mi-sm" data-tema-icono>dark_mode</span>
        </button>
        <span class="avatar" title="${usuarioSesion.nombre} · ${usuarioSesion.rolTexto}">
            ${usuarioSesion.iniciales}
        </span>
    </div>
</div>
