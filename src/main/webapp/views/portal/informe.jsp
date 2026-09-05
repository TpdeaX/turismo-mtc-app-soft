<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="seccion" value="explorar" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Informe consolidado · ${informe.zona.nombre}</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

<div class="no-print">
    <jsp:include page="../shared/portal-nav.jsp" />
</div>

<section class="section-sm">
    <div class="wrap wrap-narrow">

        <!-- Barra de acciones -->
        <div class="row between center wrap-flex g-3 mb-4 no-print">
            <a href="${ctx}/zona/${informe.zona.codigo}" class="btn btn-ghost">
                <span class="mi mi-sm">arrow_back</span> Volver al destino
            </a>
            <div class="row g-2">
                <button type="button" class="btn btn-outline" onclick="window.print()">
                    <span class="mi mi-sm">print</span> Imprimir
                </button>
                <a href="${ctx}/informe/${informe.zona.codigo}/pdf" class="btn btn-primary">
                    <span class="mi mi-sm">picture_as_pdf</span> Descargar PDF
                </a>
            </div>
        </div>

        <!-- ============================================================
             DOCUMENTO
             ============================================================ -->
        <article class="doc anim-up">

            <!-- Encabezado -->
            <header class="doc-head">
                <div class="row between center wrap-flex g-3">
                    <div class="brand">
                        <span class="brand-mark">
                            <img src="${ctx}/assets/img/logo-mtc.png" alt="${parametros['plataforma.nombre']}" width="40" height="40">
                        </span>
                        <span>
                            <span class="brand-name" style="color:#fff">${parametros['plataforma.nombre']}</span><br>
                            <span class="brand-sub">Informe consolidado</span>
                        </span>
                    </div>
                    <span class="chip" style="background:rgba(255,255,255,.14);color:#fff">
                        <span class="mi mi-sm">verified</span> Documento oficial de consulta
                    </span>
                </div>

                <h1 class="display display-md mt-4" style="color:#fff">${informe.zona.nombre}</h1>

                <div class="doc-meta">
                    <div>
                        <div class="k">Folio</div>
                        <div class="v mono">${informe.folio}</div>
                    </div>
                    <div>
                        <div class="k">Generado</div>
                        <div class="v">${mtc:fecha(informe.generado)}</div>
                    </div>
                    <div>
                        <div class="k">Estación de partida</div>
                        <div class="v">${informe.estacion.nombre}</div>
                    </div>
                    <div>
                        <div class="k">Preferencias aplicadas</div>
                        <div class="v">${informe.preferenciasTexto}</div>
                    </div>
                </div>
            </header>

            <!-- 1 · Zona turística -->
            <section class="doc-section">
                <div class="eyebrow">1 · Zona turística</div>
                <div class="row between center wrap-flex g-3">
                    <h2 style="font-size:1.32rem">${informe.zona.nombre}</h2>
                    <div class="row g-1 wrap-flex">
                        <c:forEach var="cat" items="${informe.zona.categorias}">
                            <span class="chip chip-categoria" style="--cat:${cat.color}">
                                <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                            </span>
                        </c:forEach>
                    </div>
                </div>
                <p class="muted mt-1" style="font-size:.88rem">
                    <span class="mi mi-sm" style="vertical-align:-4px">location_on</span>
                    ${informe.zona.ubicacion} · ${informe.estacion.ubicacion}
                </p>
                <p class="mt-3">${informe.zona.descripcion}</p>

                <c:if test="${informe.zona.costoReferencial gt 0}">
                    <div class="notice notice-info mt-3">
                        <span class="mi mi-sm">local_activity</span>
                        <div>Ingreso referencial al atractivo:
                            <strong>${mtc:soles(informe.zona.costoReferencial)}</strong>.
                            El sistema no gestiona el pago de las zonas turísticas.</div>
                    </div>
                </c:if>
            </section>

            <!-- 2 · Ruta caminable -->
            <section class="doc-section">
                <div class="eyebrow">2 · Ruta caminable recomendada (ida y vuelta)</div>

                <c:choose>
                    <c:when test="${empty informe.rutaRecomendada}">
                        <p class="muted">No hay una ruta caminable registrada para esta zona.</p>
                    </c:when>
                    <c:otherwise>
                        <c:set var="r" value="${informe.rutaRecomendada}" />
                        <div class="doc-kpis">
                            <div class="doc-kpi">
                                <div class="k">Distancia total</div>
                                <div class="v">${r.distanciaTotalKm} km</div>
                            </div>
                            <div class="doc-kpi">
                                <div class="k">Tiempo estimado</div>
                                <div class="v">${r.tiempoTotalTexto}</div>
                            </div>
                            <div class="doc-kpi">
                                <div class="k">Dificultad</div>
                                <div class="v">${r.dificultad}</div>
                            </div>
                            <div class="doc-kpi">
                                <div class="k">Modalidad</div>
                                <div class="v" style="font-size:1.05rem">Peatonal</div>
                            </div>
                        </div>

                        <c:if test="${not empty informe.estacion and not empty informe.zona}">
                            <div class="mt-4">
                                <c:set var="mapaEstacion" value="${informe.estacion}" scope="request" />
                                <c:set var="mapaZona" value="${informe.zona}" scope="request" />
                                <c:set var="mapaRuta" value="${r}" scope="request" />
                                <jsp:include page="../shared/mapa-recorrido.jsp" />
                            </div>
                        </c:if>

                        <div class="notice ${r.aptaSegunClima ? 'notice-success' : 'notice-warning'} mt-4">
                            <span class="mi mi-sm">${r.aptaSegunClima ? 'hiking' : 'umbrella'}</span>
                            <div>${r.recomendacion}</div>
                        </div>

                        <p class="soft mt-3" style="font-size:.8rem">
                            Modalidad de trayecto único: el recorrido parte y retorna a la misma estación
                            y se realiza exclusivamente a pie.
                        </p>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- 3 · Clima SENAMHI -->
            <section class="doc-section">
                <div class="row between center wrap-flex g-3">
                    <div class="eyebrow">3 · Pronóstico climático · SENAMHI</div>
                    <c:if test="${not empty informe.climaActualizado}">
                        <span class="soft" style="font-size:.78rem">
                            Última sincronización exitosa: ${mtc:fecha(informe.climaActualizado)}
                        </span>
                    </c:if>
                </div>

                <c:if test="${not informe.climaDisponible}">
                    <div class="notice notice-warning mt-3">
                        <span class="mi mi-sm">cloud_off</span>
                        <div>${informe.climaMensaje}</div>
                    </div>
                </c:if>

                <c:if test="${not empty informe.climaActual}">
                    <c:set var="cl" value="${informe.climaActual}" />
                    <div class="weather mt-3">
                        <div class="w-ico"><span class="mi">${cl.icono}</span></div>
                        <div class="grow">
                            <div class="row between center wrap-flex g-3">
                                <div>
                                    <div class="w-temp">${cl.temperatura}°C</div>
                                    <div class="w-cond">${cl.condicion} · ${mtc:soloFecha(cl.fecha)}</div>
                                </div>
                                <div class="row g-5 wrap-flex">
                                    <div>
                                        <div class="eyebrow">Humedad</div>
                                        <div style="font-weight:700">${cl.humedad}%</div>
                                    </div>
                                    <div>
                                        <div class="eyebrow">Viento</div>
                                        <div style="font-weight:700">${cl.viento} km/h ${cl.vientoDireccion}</div>
                                    </div>
                                    <div>
                                        <div class="eyebrow">Prob. lluvia</div>
                                        <div style="font-weight:700">${cl.probabilidadLluvia}%</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty informe.pronostico}">
                        <div class="forecast mt-4">
                            <c:forEach var="p" items="${informe.pronostico}" end="4">
                                <div class="day">
                                    <div class="d">${mtc:diaCorto(p.fecha)}</div>
                                    <div><span class="mi">${p.icono}</span></div>
                                    <div class="t">${p.temperatura}°</div>
                                    <div class="r">${p.temperaturaMin}° / ${p.temperaturaMax}°</div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                </c:if>
            </section>

            <!-- 4 · Servicio ferroviario -->
            <section class="doc-section">
                <div class="row between center wrap-flex g-3">
                    <div class="eyebrow">4 · Servicio ferroviario · PeruRail</div>
                    <c:if test="${not empty informe.ferroviarioActualizado}">
                        <span class="soft" style="font-size:.78rem">
                            Sincronizado: ${mtc:fecha(informe.ferroviarioActualizado)}
                        </span>
                    </c:if>
                </div>

                <c:choose>
                    <c:when test="${not informe.tieneHorarios}">
                        <div class="notice notice-warning mt-3">
                            <span class="mi mi-sm">train</span>
                            <div>No se registran horarios ferroviarios vigentes para esta estación.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap mt-3" style="border:1px solid var(--c-border);border-radius:var(--r-md)">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th>Servicio</th>
                                        <th>Trayecto</th>
                                        <th>Salida</th>
                                        <th>Llegada</th>
                                        <th>Duración</th>
                                        <th>Frecuencia</th>
                                        <th class="text-right">Tarifa</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="h" items="${informe.horarios}">
                                        <tr class="main-row">
                                            <td class="cell-strong">${h.servicio.nombre}</td>
                                            <td class="muted">${h.servicio.trayecto}</td>
                                            <td class="mono cell-strong">${mtc:hora(h.horaSalida)}</td>
                                            <td class="mono">${mtc:hora(h.horaLlegada)}</td>
                                            <td>${h.duracionTexto}</td>
                                            <td class="muted">${h.frecuencia}</td>
                                            <td class="text-right">
                                                <span class="chip chip-accent">${mtc:soles(h.tarifa)}</span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <c:if test="${not empty informe.tarifaMinima}">
                                    <tfoot>
                                        <tr>
                                            <td colspan="6" class="cell-strong">Rango tarifario</td>
                                            <td class="text-right cell-strong">
                                                ${mtc:soles(informe.tarifaMinima)} – ${mtc:soles(informe.tarifaMaxima)}
                                            </td>
                                        </tr>
                                    </tfoot>
                                </c:if>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- Pie -->
            <footer class="doc-section" style="background:var(--c-surface-2)">
                <div class="eyebrow mb-3">Fuentes oficiales integradas</div>
                <div class="marca-fila mb-4">
                    <span class="marca marca-sm marca-borde" data-marca="SENAMHI">
                        <img src="${ctx}/assets/img/logos-oficiales/senamhi.svg" data-logo-oficial alt="SENAMHI" loading="lazy">
                    </span>
                    <span class="marca marca-sm marca-borde" data-marca="PeruRail">
                        <img src="${ctx}/assets/img/logos-oficiales/perurail.svg" data-logo-oficial alt="PeruRail" loading="lazy">
                    </span>
                    <span class="marca marca-sm marca-borde" data-marca="Travel Group Perú">
                        <img src="${ctx}/assets/img/logos-oficiales/travel-group-peru.svg" data-logo-oficial alt="Travel Group Perú" loading="lazy">
                    </span>
                    <span class="marca marca-sm marca-borde" data-marca="MTC">
                        <img src="${ctx}/assets/img/logos-oficiales/mtc.svg" data-logo-oficial
                             alt="${parametros['plataforma.entidad']}" loading="lazy">
                    </span>
                </div>
                <div class="row between center wrap-flex g-3">
                    <p class="soft" style="margin:0;font-size:.8rem;max-width:64ch">
                        Informe generado automáticamente por la Plataforma de Zonas Turísticas de
                        ${parametros['plataforma.entidad']}. Documento dirigido al usuario final
                        y a Travel Group Perú. ${parametros['portal.aviso_legal']}
                    </p>
                    <span class="chip chip-outline mono">${informe.folio}</span>
                </div>
            </footer>
        </article>
    </div>
</section>

<div class="no-print">
    <jsp:include page="../shared/portal-footer.jsp" />
</div>
<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
