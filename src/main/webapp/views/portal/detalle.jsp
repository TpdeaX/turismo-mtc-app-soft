<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="seccion" value="explorar" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>${zona.nombre} · MTC Perú</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

<jsp:include page="../shared/portal-nav.jsp" />

<!-- ====================================================================
     PORTADA DE LA ZONA
     ==================================================================== -->
<section style="position:relative;background:var(--brand-navy-800);color:#fff">
    <div style="position:absolute;inset:0;overflow:hidden">
        <img data-fallback data-seed="${zona.codigo}" alt="${zona.nombre}"
             style="width:100%;height:100%;object-fit:cover;opacity:.42"
             <c:if test="${not empty zona.imagen}">src="${zona.imagen}"</c:if>>
        <div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(6,20,40,.72) 0%,rgba(6,20,40,.5) 40%,rgba(6,20,40,.95) 100%)"></div>
    </div>

    <div class="wrap" style="position:relative;z-index:1;padding-top:44px;padding-bottom:44px">
        <a href="${ctx}/explorar?estacion=${estacion.codigo}" class="chip chip-outline mb-4"
           style="border-color:rgba(255,255,255,.28);color:rgba(255,255,255,.86)">
            <span class="mi mi-sm">arrow_back</span> Volver a ${estacion.nombre}
        </a>

        <div class="row g-2 wrap-flex mb-3">
            <c:forEach var="cat" items="${zona.categorias}">
                <span class="chip" style="background:rgba(255,255,255,.14);color:#fff">
                    <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                </span>
            </c:forEach>
        </div>

        <h1 class="display display-xl" style="color:#fff;max-width:18ch">${zona.nombre}</h1>

        <p class="mt-3" style="color:rgba(255,255,255,.78);max-width:64ch;font-size:1.04rem">
            ${zona.descripcion}
        </p>

        <div class="row g-5 mt-5 wrap-flex">
            <div>
                <div class="eyebrow" style="color:rgba(255,255,255,.5)">Estación</div>
                <div class="row center g-2 mt-1" style="font-weight:650">
                    <span class="mi mi-sm" style="color:var(--brand-gold-500)">tram</span>
                    ${estacion.nombre}
                </div>
            </div>
            <c:if test="${not empty zona.ubicacion}">
                <div>
                    <div class="eyebrow" style="color:rgba(255,255,255,.5)">Ubicación</div>
                    <div class="row center g-2 mt-1" style="font-weight:650">
                        <span class="mi mi-sm" style="color:var(--brand-gold-500)">location_on</span>
                        ${zona.ubicacion}
                    </div>
                </div>
            </c:if>
            <c:if test="${zona.costoReferencial gt 0}">
                <div>
                    <div class="eyebrow" style="color:rgba(255,255,255,.5)">Ingreso referencial</div>
                    <div class="row center g-2 mt-1" style="font-weight:650">
                        <span class="mi mi-sm" style="color:var(--brand-gold-500)">local_activity</span>
                        ${mtc:soles(zona.costoReferencial)}
                    </div>
                </div>
            </c:if>
        </div>

        <div class="row g-2 mt-5 wrap-flex">
            <a href="${ctx}/informe/${zona.codigo}" class="btn btn-accent btn-lg">
                <span class="mi">description</span> Ver informe consolidado
            </a>
            <a href="${ctx}/informe/${zona.codigo}/pdf" class="btn btn-lg btn-outline"
               style="background:rgba(255,255,255,.1);border-color:rgba(255,255,255,.26);color:#fff">
                <span class="mi">picture_as_pdf</span> Descargar PDF
            </a>
        </div>
    </div>
</section>

<!-- ====================================================================
     CONTENIDO
     ==================================================================== -->
<section class="section-sm">
    <div class="wrap">
        <div class="grid" style="grid-template-columns:minmax(0,1.55fr) minmax(0,1fr)">

            <!-- ============ COLUMNA PRINCIPAL ============ -->
            <div class="col g-5">

                <!-- Ruta caminable recomendada -->
                <div class="card reveal">
                    <div class="card-head">
                        <div class="row center g-3">
                            <span class="stat-icon stat-icon-sm">
                                <span class="mi mi-sm">directions_walk</span>
                            </span>
                            <div>
                                <h3>Ruta caminable recomendada</h3>
                                <div class="soft" style="font-size:.8rem">Un solo tramo · ida y vuelta</div>
                            </div>
                        </div>
                        <c:if test="${not empty ruta}">
                            <span class="chip chip-outline" title="Dificultad del recorrido">
                                <span class="difficulty" data-level="${ruta.nivelDificultad}">
                                    <i></i><i></i><i></i>
                                </span>
                                ${ruta.dificultad}
                            </span>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${empty ruta}">
                            <div class="empty">
                                <span class="mi">route</span>
                                <h4>Sin ruta registrada</h4>
                                <p class="muted">Esta zona aún no tiene un tramo caminable definido.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card-body">
                                <div class="doc-kpis mb-4">
                                    <div class="doc-kpi">
                                        <div class="k">Distancia total</div>
                                        <div class="v">${ruta.distanciaTotalKm} km</div>
                                        <div class="soft" style="font-size:.76rem">
                                            ${ruta.distanciaIdaKm} km por tramo
                                        </div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Tiempo estimado</div>
                                        <div class="v">${ruta.tiempoTotalTexto}</div>
                                        <div class="soft" style="font-size:.76rem">
                                            ida y vuelta caminando
                                        </div>
                                    </div>
                                    <div class="doc-kpi">
                                        <div class="k">Dificultad</div>
                                        <div class="v">${ruta.dificultad}</div>
                                        <div class="soft" style="font-size:.76rem">
                                            recorrido peatonal
                                        </div>
                                    </div>
                                </div>

                                <!-- Secuencia del recorrido -->
                                <div class="route-line">
                                    <div class="route-step gold">
                                        <div class="s-title">Salida · ${estacion.nombre}</div>
                                        <div class="s-meta">
                                            ${estacion.ubicacion}
                                            <c:if test="${not empty estacion.conexiones}">
                                                · Conexiones: ${estacion.conexiones}
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="route-step">
                                        <div class="s-title">${ruta.ruta.nombre}</div>
                                        <div class="s-meta">
                                            ${ruta.distanciaIdaKm} km a pie · aprox. ${ruta.minutosIda} min
                                        </div>
                                    </div>
                                    <div class="route-step">
                                        <div class="s-title">Llegada · ${zona.nombre}</div>
                                        <div class="s-meta">Tiempo de visita a discreción del viajero</div>
                                    </div>
                                    <div class="route-step gold">
                                        <div class="s-title">Retorno · ${estacion.nombre}</div>
                                        <div class="s-meta">
                                            Mismo tramo de vuelta · aprox. ${ruta.minutosIda} min
                                        </div>
                                    </div>
                                </div>

                                <div class="notice ${ruta.aptaSegunClima ? 'notice-success' : 'notice-warning'} mt-4">
                                    <span class="mi mi-sm">
                                        ${ruta.aptaSegunClima ? 'hiking' : 'umbrella'}
                                    </span>
                                    <div>
                                        <div class="notice-title">Recomendación del asesor</div>
                                        ${ruta.recomendacion}
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Datos ferroviarios con filas desplegables -->
                <div class="card reveal">
                    <div class="card-head">
                        <div class="row center g-3">
                            <span class="stat-icon stat-icon-sm">
                                <span class="mi mi-sm">train</span>
                            </span>
                            <div>
                                <h3>Servicio ferroviario</h3>
                                <div class="soft" style="font-size:.8rem">Fuente: PeruRail</div>
                            </div>
                        </div>
                        <span class="chip chip-success"><i class="dot dot-live"></i> Operativo</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty servicios}">
                            <div class="empty">
                                <span class="mi">train</span>
                                <h4>Sin servicios registrados</h4>
                                <p class="muted">No hay conexiones ferroviarias vigentes para esta estación.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-wrap">
                                <table class="data">
                                    <thead>
                                        <tr>
                                            <th style="width:52px"></th>
                                            <th>Servicio</th>
                                            <th>Trayecto</th>
                                            <th>Corredor</th>
                                            <th class="text-right">Estado</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${servicios}">
                                            <tr class="main-row">
                                                <td>
                                                    <button type="button" class="expander" data-expand
                                                            aria-expanded="false"
                                                            aria-controls="det-svc-${s.codigo}"
                                                            aria-label="Ver horarios de ${s.nombre}">
                                                        <span class="mi">expand_more</span>
                                                    </button>
                                                </td>
                                                <td class="cell-strong">${s.nombre}</td>
                                                <td class="muted">${s.trayecto}</td>
                                                <td class="muted">${s.corredor}</td>
                                                <td class="text-right">
                                                    <c:choose>
                                                        <c:when test="${s.estado eq 'ACTIVO'}">
                                                            <span class="chip chip-success"><i class="dot"></i>Activo</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="chip chip-warning"><i class="dot"></i>Retraso</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                            <tr class="detail-row" id="det-svc-${s.codigo}"
                                                data-src="${ctx}/api/servicios/${s.codigo}/horarios">
                                                <td colspan="5">
                                                    <div class="detail-inner">
                                                        <div class="detail-clip">
                                                            <div class="detail-pad" data-detail-body>
                                                                <div class="soft">Cargando…</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <div class="card-foot">
                                <span class="soft" style="font-size:.8rem">
                                    <span class="mi mi-sm" style="vertical-align:-4px">info</span>
                                    Despliega cada servicio para ver sus horarios, tiempos de recorrido y tarifas.
                                    La plataforma no vende ni reserva boletos.
                                </span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- ============ COLUMNA LATERAL ============ -->
            <div class="col g-5">

                <!-- Pronóstico climático -->
                <div class="card reveal">
                    <div class="card-head">
                        <h3>Clima · SENAMHI</h3>
                        <c:if test="${not empty clima}">
                            <span class="chip ${climaVigente ? 'chip-success' : 'chip-warning'}">
                                <i class="dot"></i>${climaVigente ? 'Vigente' : 'En caché'}
                            </span>
                        </c:if>
                    </div>

                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty clima}">
                                <div class="notice notice-warning">
                                    <span class="mi mi-sm">cloud_off</span>
                                    <div>
                                        <div class="notice-title">Pronóstico no disponible</div>
                                        El servicio de SENAMHI no respondió. Se muestra el resto de la
                                        información turística y ferroviaria.
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="weather">
                                    <div class="w-ico"><span class="mi">${clima.icono}</span></div>
                                    <div>
                                        <div class="w-temp">${clima.temperatura}°C</div>
                                        <div class="w-cond">${clima.condicion}</div>
                                    </div>
                                </div>

                                <div class="weather-grid">
                                    <div>
                                        <div class="k">Mín / Máx</div>
                                        <div class="v">${clima.temperaturaMin}° / ${clima.temperaturaMax}°</div>
                                    </div>
                                    <div>
                                        <div class="k">Humedad</div>
                                        <div class="v">${clima.humedad}%</div>
                                    </div>
                                    <div>
                                        <div class="k">Viento</div>
                                        <div class="v">${clima.viento} km/h ${clima.vientoDireccion}</div>
                                    </div>
                                    <div>
                                        <div class="k">Prob. lluvia</div>
                                        <div class="v">${clima.probabilidadLluvia}%</div>
                                    </div>
                                </div>

                                <c:if test="${not climaVigente}">
                                    <div class="notice notice-warning mt-3">
                                        <span class="mi mi-sm">history</span>
                                        <div>
                                            Último pronóstico válido almacenado (${mtc:soloFecha(clima.fecha)}).
                                            Sincronización exitosa: ${mtc:fecha(climaActualizado)}.
                                        </div>
                                    </div>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:if test="${not empty pronostico}">
                        <div class="card-foot">
                            <div class="eyebrow mb-2">Próximos días</div>
                            <div class="forecast">
                                <c:forEach var="p" items="${pronostico}" end="4">
                                    <div class="day">
                                        <div class="d">${mtc:diaCorto(p.fecha)}</div>
                                        <div><span class="mi">${p.icono}</span></div>
                                        <div class="t">${p.temperatura}°</div>
                                        <div class="r">${p.probabilidadLluvia}% lluvia</div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Acciones -->
                <div class="card card-dark reveal">
                    <div class="card-body">
                        <span class="eyebrow" style="color:var(--brand-gold-500)">Herramientas</span>
                        <h3 class="mt-2" style="color:#fff;font-size:1.1rem">Informe consolidado</h3>
                        <p class="mt-2" style="color:var(--c-text-on-dark-muted);font-size:.88rem">
                            Reúne en un solo documento los datos turísticos, climáticos y ferroviarios
                            de esta consulta.
                        </p>
                        <div class="col g-2 mt-4">
                            <a href="${ctx}/informe/${zona.codigo}" class="btn btn-accent btn-block">
                                <span class="mi mi-sm">description</span> Ver informe
                            </a>
                            <a href="${ctx}/informe/${zona.codigo}/pdf" class="btn btn-block btn-outline"
                               style="background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.24);color:#fff">
                                <span class="mi mi-sm">picture_as_pdf</span> Descargar en PDF
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Otras zonas de la misma estación -->
                <c:if test="${not empty relacionadas}">
                    <div class="card reveal">
                        <div class="card-head"><h3>También desde esta estación</h3></div>
                        <div class="card-body col g-3">
                            <c:forEach var="r" items="${relacionadas}">
                                <a href="${ctx}/zona/${r.codigo}" class="row center g-3"
                                   style="padding:8px;border-radius:var(--r-md)">
                                    <img data-fallback data-seed="${r.codigo}" alt="${r.nombre}"
                                         style="width:64px;height:52px;object-fit:cover;border-radius:var(--r-sm);flex-shrink:0"
                                         <c:if test="${not empty r.imagen}">src="${r.imagen}"</c:if>>
                                    <div style="min-width:0">
                                        <div style="font-weight:650;font-size:.92rem">${r.nombre}</div>
                                        <div class="soft" style="font-size:.8rem">
                                            ${r.ruta.tiempoEstimado} · ${r.ruta.dificultad}
                                        </div>
                                    </div>
                                    <span class="mi mi-sm soft" style="margin-left:auto">arrow_forward</span>
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../shared/portal-footer.jsp" />
<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
