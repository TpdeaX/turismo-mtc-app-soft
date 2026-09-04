<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="integraciones" scope="request" />
<c:set var="tituloModulo" value="Integraciones" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Integraciones externas · MTC Perú</title>
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
                    <span class="eyebrow">Módulo de integración</span>
                    <h1 class="mt-2">Integraciones Externas</h1>
                    <p>Estado y bitácora de la sincronización periódica con PeruRail y SENAMHI.
                        El proceso se ejecuta automáticamente al menos una vez al día.</p>
                </div>
                <form method="post" action="${ctx}/panel/integraciones/sincronizar">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <span class="mi mi-sm">sync</span> Sincronizar todo ahora
                    </button>
                </form>
            </div>

            <!-- Estado de cada fuente -->
            <div class="grid grid-2 mb-5">

                <!-- PeruRail -->
                <div class="card anim-up">
                    <div class="card-head">
                        <div class="row center g-3">
                            <span class="stat-icon stat-icon-sm">
                                <span class="mi mi-sm">tram</span>
                            </span>
                            <div>
                                <h3>PeruRail</h3>
                                <div class="soft" style="font-size:.8rem">
                                    Estaciones, horarios, tiempos y tarifas
                                </div>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${ultimaPeruRail.exitosa}">
                                <span class="chip chip-success"><i class="dot dot-live"></i>Operativa</span>
                            </c:when>
                            <c:when test="${empty ultimaPeruRail}">
                                <span class="chip chip-outline"><i class="dot"></i>Sin ejecutar</span>
                            </c:when>
                            <c:otherwise>
                                <span class="chip chip-danger"><i class="dot"></i>Con incidencia</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty ultimaPeruRail}">
                                <p class="muted" style="margin:0">
                                    Todavía no se ha ejecutado ninguna sincronización con esta fuente.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <div class="doc-kpis">
                                    <div class="doc-kpi">
                                        <div class="k">Última ejecución</div>
                                        <div class="v" style="font-size:1.05rem">
                                            ${mtc:relativo(ultimaPeruRail.fecha)}
                                        </div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Registros</div>
                                        <div class="v">${ultimaPeruRail.registros}</div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Duración</div>
                                        <div class="v" style="font-size:1.05rem">${ultimaPeruRail.duracionMs} ms</div>
                                    </div>
                                </div>
                                <p class="muted mt-3" style="font-size:.87rem">${ultimaPeruRail.mensaje}</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card-foot">
                        <form method="post" action="${ctx}/panel/integraciones/sincronizar">
                            <input type="hidden" name="fuente" value="PERURAIL">
                            <button type="submit" class="btn btn-outline btn-sm btn-block">
                                <span class="mi mi-sm">sync</span> Sincronizar solo PeruRail
                            </button>
                        </form>
                    </div>
                </div>

                <!-- SENAMHI -->
                <div class="card anim-up d-1">
                    <div class="card-head">
                        <div class="row center g-3">
                            <span class="stat-icon stat-icon-sm">
                                <span class="mi mi-sm">cloud</span>
                            </span>
                            <div>
                                <h3>SENAMHI</h3>
                                <div class="soft" style="font-size:.8rem">
                                    Pronóstico climático por zona geográfica
                                </div>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${ultimaSenamhi.exitosa}">
                                <span class="chip chip-success"><i class="dot dot-live"></i>Operativa</span>
                            </c:when>
                            <c:when test="${empty ultimaSenamhi}">
                                <span class="chip chip-outline"><i class="dot"></i>Sin ejecutar</span>
                            </c:when>
                            <c:otherwise>
                                <span class="chip chip-danger"><i class="dot"></i>Con incidencia</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty ultimaSenamhi}">
                                <p class="muted" style="margin:0">
                                    Todavía no se ha ejecutado ninguna sincronización con esta fuente.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <div class="doc-kpis">
                                    <div class="doc-kpi">
                                        <div class="k">Última ejecución</div>
                                        <div class="v" style="font-size:1.05rem">
                                            ${mtc:relativo(ultimaSenamhi.fecha)}
                                        </div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Pronósticos</div>
                                        <div class="v">${ultimaSenamhi.registros}</div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Duración</div>
                                        <div class="v" style="font-size:1.05rem">${ultimaSenamhi.duracionMs} ms</div>
                                    </div>
                                </div>
                                <p class="muted mt-3" style="font-size:.87rem">${ultimaSenamhi.mensaje}</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card-foot">
                        <form method="post" action="${ctx}/panel/integraciones/sincronizar">
                            <input type="hidden" name="fuente" value="SENAMHI">
                            <button type="submit" class="btn btn-outline btn-sm btn-block">
                                <span class="mi mi-sm">sync</span> Sincronizar solo SENAMHI
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Bitácora -->
            <div class="card anim-up d-2">
                <div class="card-head">
                    <h3>Bitácora de sincronizaciones</h3>
                    <span class="soft" style="font-size:.82rem">
                        Últimas 20 ejecuciones · las incidencias quedan registradas para su revisión
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty bitacora}">
                        <div class="empty">
                            <span class="mi">history</span>
                            <h4>Bitácora vacía</h4>
                            <p class="muted">Aún no se ha registrado ninguna ejecución.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th style="width:52px"></th>
                                        <th>Fecha y hora</th>
                                        <th>Fuente</th>
                                        <th>Resultado</th>
                                        <th>Registros</th>
                                        <th class="text-right">Duración</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="l" items="${bitacora}">
                                        <tr class="main-row">
                                            <td>
                                                <button type="button" class="expander" data-expand
                                                        aria-expanded="false" aria-controls="det-log-${l.codigo}"
                                                        aria-label="Ver detalle de la ejecución">
                                                    <span class="mi">expand_more</span>
                                                </button>
                                            </td>
                                            <td class="mono">${mtc:fecha(l.fecha)}</td>
                                            <td>
                                                <span class="chip chip-outline">
                                                    <span class="mi mi-sm">
                                                        ${l.fuente eq 'PERURAIL' ? 'tram' : 'cloud'}
                                                    </span>${l.fuente}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${l.exitosa}">
                                                        <span class="chip chip-success">
                                                            <span class="mi mi-sm">check_circle</span>Éxito</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="chip chip-danger">
                                                            <span class="mi mi-sm">error</span>Fallo</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="cell-strong">${l.registros}</td>
                                            <td class="text-right mono">${l.duracionMs} ms</td>
                                        </tr>

                                        <tr class="detail-row" id="det-log-${l.codigo}">
                                            <td colspan="6">
                                                <div class="detail-inner">
                                                    <div class="detail-clip">
                                                        <div class="detail-pad">
                                                            <div class="eyebrow mb-2">Mensaje de la ejecución</div>
                                                            <div class="notice ${l.exitosa ? 'notice-success' : 'notice-danger'}">
                                                                <span class="mi mi-sm">
                                                                    ${l.exitosa ? 'check_circle' : 'error'}
                                                                </span>
                                                                <div>${l.mensaje}</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="card-foot">
                    <div class="row center g-2 soft" style="font-size:.82rem">
                        <span class="mi mi-sm">schedule</span>
                        Si una fuente no responde, la plataforma conserva la última información válida
                        almacenada y muestra al usuario la fecha de vigencia de los datos.
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
