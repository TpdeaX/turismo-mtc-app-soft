<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="panel" scope="request" />
<c:set var="tituloModulo" value="Panel de control" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Panel de control · MTC Perú</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>
<div class="shell">
    <jsp:include page="../shared/panel-sidebar.jsp" />

    <div class="main">
        <jsp:include page="../shared/panel-topbar.jsp" />

        <div class="page">

            <div class="page-head">
                <div>
                    <span class="eyebrow">Bienvenido, ${usuarioSesion.nombre}</span>
                    <h1 class="mt-2">Panel de Control Administrativo</h1>
                    <p>Visión general del estado de la plataforma y de sus módulos de integración
                        con SENAMHI, PeruRail y Travel Group Perú.</p>
                </div>
                <form method="post" action="${ctx}/panel/integraciones/sincronizar">
                    <button type="submit" class="btn btn-primary">
                        <span class="mi mi-sm">sync</span> Sincronizar fuentes
                    </button>
                </form>
            </div>

            <!-- Estado general -->
            <c:set var="hayFallo" value="false" />
            <c:forEach var="a" items="${resumen.alertas}">
                <c:if test="${a.tipo eq 'error'}"><c:set var="hayFallo" value="true" /></c:if>
            </c:forEach>

            <div class="card mb-4 anim-up">
                <div class="card-body-sm row center g-3">
                    <span class="chip ${hayFallo ? 'chip-danger' : 'chip-success'}">
                        <i class="dot ${hayFallo ? '' : 'dot-live'}"></i>
                        ${hayFallo ? 'Incidencia en una integración' : 'Todos los sistemas operativos'}
                    </span>
                    <span class="soft" style="font-size:.84rem">
                        Sincronización automática diaria · última ejecución
                        ${mtc:relativo(resumen.ultimaSincronizacionSenamhi.fecha)}
                    </span>
                </div>
            </div>

            <!-- Tarjetas de módulos -->
            <div class="grid grid-3 mb-5">

                <div class="card card-hover anim-up d-1">
                    <div class="stat">
                        <div class="stat-icon"><span class="mi">landscape</span></div>
                        <div class="stat-title">Zonas Turísticas</div>
                        <div class="soft" style="font-size:.83rem">Integración Travel Group Perú</div>
                        <div class="row center g-2 mt-3">
                            <span class="stat-value">${resumen.zonasActivas}</span>
                            <span class="stat-label">zonas activas<br>
                                <span class="soft">de ${resumen.zonasTotales} registradas</span>
                            </span>
                        </div>
                    </div>
                    <c:if test="${usuarioSesion.puedeGestionarZonas}">
                        <div class="card-foot">
                            <a href="${ctx}/panel/zonas" class="btn btn-ghost btn-sm btn-block"
                               style="justify-content:space-between">
                                Gestionar zonas <span class="mi mi-sm">arrow_forward</span>
                            </a>
                        </div>
                    </c:if>
                </div>

                <div class="card card-hover anim-up d-2">
                    <div class="stat">
                        <div class="stat-icon"><span class="mi">tram</span></div>
                        <div class="stat-title">Conexiones Férreas</div>
                        <div class="soft" style="font-size:.83rem">Integración PeruRail</div>
                        <div class="row center g-2 mt-3">
                            <span class="stat-value">${resumen.serviciosOperativos}</span>
                            <span class="stat-label">servicios operativos<br>
                                <span class="soft">${resumen.horarios} horarios · ${resumen.estaciones} estaciones</span>
                            </span>
                        </div>
                    </div>
                    <div class="card-foot">
                        <c:set var="destinoFerroviario"
                               value="${usuarioSesion.puedeGestionarFerroviario ? '/panel/ferroviario' : '/panel/estaciones'}" />
                        <a href="${ctx}${destinoFerroviario}"
                           class="btn btn-ghost btn-sm btn-block" style="justify-content:space-between">
                            ${usuarioSesion.puedeGestionarFerroviario ? 'Ver horarios' : 'Ver estaciones'}
                            <span class="mi mi-sm">arrow_forward</span>
                        </a>
                    </div>
                </div>

                <div class="card card-hover anim-up d-3">
                    <div class="stat">
                        <div class="stat-icon"><span class="mi">cloud</span></div>
                        <div class="stat-title">Datos Climáticos</div>
                        <div class="soft" style="font-size:.83rem">Fuente SENAMHI</div>
                        <div class="row center g-2 mt-3">
                            <c:choose>
                                <c:when test="${resumen.ultimaSincronizacionSenamhi.exitosa}">
                                    <span class="chip chip-success">
                                        <span class="mi mi-sm">sync</span>
                                        ${mtc:relativo(resumen.ultimaSincronizacionSenamhi.fecha)}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="chip chip-danger">
                                        <span class="mi mi-sm">sync_problem</span> Última ejecución falló
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="soft mt-2" style="font-size:.83rem">
                            ${resumen.ultimaSincronizacionSenamhi.registros} pronósticos almacenados
                        </div>
                    </div>
                    <div class="card-foot">
                        <a href="${ctx}/panel/integraciones" class="btn btn-ghost btn-sm btn-block"
                           style="justify-content:space-between">
                            Monitoreo de integraciones <span class="mi mi-sm">arrow_forward</span>
                        </a>
                    </div>
                </div>
            </div>

            <div class="grid" style="grid-template-columns:minmax(0,1.5fr) minmax(0,1fr)">

                <!-- Alertas del sistema -->
                <div class="card anim-up d-4">
                    <div class="card-head">
                        <h3>Alertas del Sistema</h3>
                        <span class="chip chip-outline">${resumen.alertas.size()}</span>
                    </div>
                    <div class="card-body col g-3">
                        <c:forEach var="a" items="${resumen.alertas}">
                            <div class="alert-item ${a.tipo}">
                                <span class="mi mi-sm">${a.icono}</span>
                                <div class="grow">
                                    <div class="row between center g-3 wrap-flex">
                                        <span class="a-title">${a.titulo}</span>
                                        <span class="a-time">${a.momento}</span>
                                    </div>
                                    <div class="a-body">${a.detalle}</div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Acciones rápidas -->
                <div class="col g-4">
                    <div class="card card-dark anim-up d-5">
                        <div class="card-body">
                            <span class="eyebrow" style="color:var(--brand-gold-500)">Acciones rápidas</span>
                            <h3 class="mt-2" style="color:#fff;font-size:1.1rem">Atajos de gestión</h3>

                            <div class="col g-2 mt-4">
                                <c:if test="${usuarioSesion.puedeGestionarZonas}">
                                    <a href="${ctx}/panel/zonas?nueva=1" class="btn btn-block btn-outline"
                                       style="justify-content:flex-start;background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.2);color:#fff">
                                        <span class="mi mi-sm">add_location_alt</span> Nueva zona turística
                                    </a>
                                    <a href="${ctx}/panel/rutas" class="btn btn-block btn-outline"
                                       style="justify-content:flex-start;background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.2);color:#fff">
                                        <span class="mi mi-sm">route</span> Nueva ruta caminable
                                    </a>
                                </c:if>
                                <c:if test="${usuarioSesion.puedeGestionarFerroviario}">
                                    <a href="${ctx}/panel/ferroviario" class="btn btn-block btn-outline"
                                       style="justify-content:flex-start;background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.2);color:#fff">
                                        <span class="mi mi-sm">payments</span> Ajuste de tarifas
                                    </a>
                                </c:if>
                                <c:if test="${usuarioSesion.puedeConfigurarPlataforma}">
                                    <a href="${ctx}/panel/parametros" class="btn btn-block btn-outline"
                                       style="justify-content:flex-start;background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.2);color:#fff">
                                        <span class="mi mi-sm">tune</span> Parámetros generales
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <div class="card anim-up d-6">
                        <div class="card-head"><h3>Inventario</h3></div>
                        <div class="card-body col g-3" style="font-size:.9rem">
                            <div class="row between center">
                                <span class="muted">Estaciones ferroviarias</span>
                                <strong>${resumen.estaciones}</strong>
                            </div>
                            <div class="row between center">
                                <span class="muted">Rutas caminables</span>
                                <strong>${resumen.rutas}</strong>
                            </div>
                            <div class="row between center">
                                <span class="muted">Zonas turísticas</span>
                                <strong>${resumen.zonasTotales}</strong>
                            </div>
                            <div class="row between center">
                                <span class="muted">Horarios programados</span>
                                <strong>${resumen.horarios}</strong>
                            </div>
                            <div class="row between center">
                                <span class="muted">Categorías de preferencia</span>
                                <strong>${resumen.categorias}</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
