<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<header class="topnav">
    <div class="wrap">
        <div class="bar">

            <a href="${ctx}/" class="brand">
                <span class="brand-mark">
                    <img src="${ctx}/assets/img/logo-mtc.png" alt="${parametros['plataforma.nombre']}" width="40" height="40">
                </span>
                <span>
                    <span class="brand-name">${parametros['plataforma.nombre']}</span><br>
                    <span class="brand-sub">${parametros['plataforma.lema']}</span>
                </span>
            </a>

            <nav class="links" aria-label="Navegación principal">
                <a href="${ctx}/" class="${seccion eq 'inicio' ? 'active' : ''}">Inicio</a>
                <a href="${ctx}/explorar" class="${seccion eq 'explorar' ? 'active' : ''}">Explorar</a>
                <a href="${ctx}/explorar#estaciones" class="${seccion eq 'estaciones' ? 'active' : ''}">Estaciones</a>
                <a href="${ctx}/#como-funciona">Cómo funciona</a>
            </nav>

            <div class="actions">
                <button type="button" class="icon-btn" data-tema title="Cambiar tema" aria-label="Cambiar tema">
                    <span class="mi mi-sm" data-tema-icono>dark_mode</span>
                </button>

                <c:choose>
                    <c:when test="${not empty usuarioSesion}">
                        <a href="${ctx}/panel" class="btn btn-accent btn-sm">
                            <span class="mi mi-sm">shield_person</span>
                            <span class="hide-sm">Panel</span>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/acceso" class="btn btn-outline btn-sm"
                           style="background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.22);color:#fff">
                            <span class="mi mi-sm">shield_person</span>
                            <span class="hide-sm">Administrador</span>
                        </a>
                    </c:otherwise>
                </c:choose>

                <button type="button" class="icon-btn nav-toggle" data-modal-open="modal-menu"
                        aria-label="Abrir menú">
                    <span class="mi mi-sm">menu</span>
                </button>
            </div>
        </div>
    </div>
</header>

<%-- Menú de navegación en pantallas pequeñas --%>
<div class="modal" id="modal-menu" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <div class="modal-head">
            <div class="modal-icon"><span class="mi">explore</span></div>
            <h3>Navegación</h3>
            <p>Plataforma de Zonas Turísticas</p>
            <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                <span class="mi mi-sm">close</span>
            </button>
        </div>
        <div class="modal-body">
            <div class="col g-2">
                <a class="btn btn-ghost btn-block" style="justify-content:flex-start" href="${ctx}/">
                    <span class="mi mi-sm">home</span> Inicio</a>
                <a class="btn btn-ghost btn-block" style="justify-content:flex-start" href="${ctx}/explorar">
                    <span class="mi mi-sm">travel_explore</span> Explorar destinos</a>
                <a class="btn btn-ghost btn-block" style="justify-content:flex-start" href="${ctx}/#como-funciona">
                    <span class="mi mi-sm">help</span> Cómo funciona</a>
                <hr>
                <a class="btn btn-primary btn-block" href="${ctx}/acceso">
                    <span class="mi mi-sm">shield_person</span> Acceso administrativo</a>
            </div>
        </div>
    </div>
</div>
