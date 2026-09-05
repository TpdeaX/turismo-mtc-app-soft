<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="sidebar-backdrop"></div>

<aside class="sidebar">

    <a href="${ctx}/" class="side-brand">
        <span class="brand-mark">
            <img src="${ctx}/assets/img/logo-mtc.png" alt="${parametros['plataforma.nombre']}" width="42" height="42">
        </span>
        <span>
            <span class="brand-name" style="color:#fff">${parametros['plataforma.nombre']}</span><br>
            <span class="brand-sub">Panel administrativo</span>
        </span>
    </a>

    <nav class="side-nav" aria-label="Módulos del panel">

        <div class="side-group">General</div>
        <a href="${ctx}/panel" class="side-link ${modulo eq 'panel' ? 'active' : ''}">
            <span class="mi mi-sm">dashboard</span> Panel de control
        </a>

        <c:if test="${usuarioSesion.puedeGestionarZonas}">
            <div class="side-group">Travel Group Perú</div>
            <a href="${ctx}/panel/zonas" class="side-link ${modulo eq 'zonas' ? 'active' : ''}">
                <span class="mi mi-sm">landscape</span> Zonas turísticas
            </a>
            <a href="${ctx}/panel/rutas" class="side-link ${modulo eq 'rutas' ? 'active' : ''}">
                <span class="mi mi-sm">directions_walk</span> Rutas caminables
            </a>
            <a href="${ctx}/panel/categorias" class="side-link ${modulo eq 'categorias' ? 'active' : ''}">
                <span class="mi mi-sm">sell</span> Categorías
            </a>
        </c:if>

        <div class="side-group">PeruRail</div>
        <a href="${ctx}/panel/estaciones" class="side-link ${modulo eq 'estaciones' ? 'active' : ''}">
            <span class="mi mi-sm">tram</span> Estaciones
            <c:if test="${not usuarioSesion.admin}">
                <span class="badge">Lectura</span>
            </c:if>
        </a>
        <c:if test="${usuarioSesion.puedeGestionarFerroviario}">
            <a href="${ctx}/panel/ferroviario" class="side-link ${modulo eq 'ferroviario' ? 'active' : ''}">
                <span class="mi mi-sm">schedule</span> Horarios y precios
            </a>
        </c:if>

        <c:if test="${usuarioSesion.puedeConfigurarPlataforma}">
            <div class="side-group">Administración</div>
            <a href="${ctx}/panel/parametros" class="side-link ${modulo eq 'parametros' ? 'active' : ''}">
                <span class="mi mi-sm">tune</span> Parámetros generales
            </a>
            <a href="${ctx}/panel/gestores" class="side-link ${modulo eq 'gestores' ? 'active' : ''}">
                <span class="mi mi-sm">manage_accounts</span> Gestores autorizados
            </a>
        </c:if>

        <div class="side-group">Portal</div>
        <a href="${ctx}/" class="side-link">
            <span class="mi mi-sm">public</span> Ver portal público
        </a>
    </nav>

    <div class="side-foot">
        <div class="user-card">
            <span class="avatar">${usuarioSesion.iniciales}</span>
            <div class="grow" style="min-width:0">
                <div style="color:#fff;font-weight:650;font-size:.86rem;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                    ${usuarioSesion.nombre}
                </div>
                <div style="font-size:.74rem;color:rgba(255,255,255,.5)">${usuarioSesion.rolTexto}</div>
            </div>
            <button type="button" class="btn-logout" title="Cerrar sesión"
                    data-modal-open="modal-confirmar-salir" aria-label="Cerrar sesión">
                <span class="mi">logout</span>
            </button>
        </div>
    </div>
</aside>

<!-- Modal Confirmación de Cerrar Sesión -->
<div class="modal" id="modal-confirmar-salir" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="tit-salir">
    <div class="modal-card modal-sm">
        <div class="modal-head danger">
            <div class="modal-icon"><span class="mi">logout</span></div>
            <h3 id="tit-salir">¿Deseas cerrar sesión?</h3>
            <p>Finalizar sesión de ${usuarioSesion.nombre}</p>
            <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                <span class="mi mi-sm">close</span>
            </button>
        </div>
        <div class="modal-body">
            <div class="confirm-box">
                <span class="mi">info</span>
                <div>
                    Estás a punto de salir del panel administrativo. Para volver a ingresar deberás
                    introducir nuevamente tus credenciales de acceso.
                </div>
            </div>
            <div class="confirm-target mt-3">
                <div class="eyebrow">Cuenta actual</div>
                <div class="cell-strong mt-1">${usuarioSesion.nombre}</div>
                <div class="soft" style="font-size:.83rem">${usuarioSesion.rolTexto} · ${usuarioSesion.correo}</div>
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
            <a href="${ctx}/salir" class="btn btn-danger">
                <span class="mi mi-sm">logout</span> Sí, cerrar sesión
            </a>
        </div>
    </div>
</div>
