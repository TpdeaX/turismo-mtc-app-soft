<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="seccion" value="explorar" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Explorar destinos · MTC Perú</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

<jsp:include page="../shared/portal-nav.jsp" />

<!-- ====================================================================
     CABECERA DE BÚSQUEDA
     ==================================================================== -->
<section style="position:relative;z-index:40;background:linear-gradient(135deg, rgba(6,20,40,.86) 0%, rgba(10,31,61,.76) 50%, rgba(6,20,40,.92) 100%), url('${ctx}/assets/img/hero-explorar.jpg') center 32%/cover no-repeat;color:#fff;padding:44px 0 36px;overflow:visible">
    <div class="wrap" style="position:relative;overflow:visible">
        <div class="row between center wrap-flex g-4">
            <div>
                <span class="eyebrow" style="color:rgba(255,255,255,.55)">Paso 2 · Elige tu andén</span>
                <h1 class="display display-md mt-2" style="color:#fff">
                    <c:choose>
                        <c:when test="${not empty estacionSeleccionada}">${estacionSeleccionada.nombre}</c:when>
                        <c:otherwise>Explorar destinos</c:otherwise>
                    </c:choose>
                </h1>
                <c:if test="${not empty estacionSeleccionada}">
                    <p class="mt-2" style="color:rgba(255,255,255,.72);margin:0">
                        <span class="mi mi-sm" style="vertical-align:-4px">location_on</span>
                        ${estacionSeleccionada.ubicacion} · ${estacionSeleccionada.region}
                    </p>
                </c:if>
            </div>

            <div class="row g-2 wrap-flex">
                <button type="button" class="btn btn-accent" data-modal-open="modal-preferencias">
                    <span class="mi mi-sm">tune</span>
                    Preferencias
                    <c:if test="${preferenciasSesion.totalSeleccionadas gt 0}">
                        <span class="chip" style="background:rgba(0,0,0,.16);color:inherit;padding:2px 9px">
                            ${preferenciasSesion.totalSeleccionadas}
                        </span>
                    </c:if>
                </button>
                <c:if test="${not empty estacionSeleccionada}">
                    <button type="button" class="btn btn-outline" data-modal-open="modal-horarios"
                            style="background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.24);color:#fff">
                        <span class="mi mi-sm">train</span> Horarios y tarifas
                    </button>
                </c:if>
            </div>
        </div>

        <!-- Selector de estación -->
        <form method="get" action="${ctx}/explorar" class="mt-4" style="position:relative;z-index:50;overflow:visible">
            <div class="row g-2 wrap-flex" style="align-items:flex-end">
                <div class="field grow" style="min-width:240px">
                    <label style="color:rgba(255,255,255,.6)">Estación ferroviaria de partida</label>
                    <select class="select" name="estacion" onchange="this.form.submit()">
                        <option value="">— Selecciona una estación —</option>
                        <c:forEach var="e" items="${estaciones}">
                            <option value="${e.codigo}"
                                    <c:if test="${estacionSeleccionada.codigo eq e.codigo}">selected</c:if>>
                                ${e.nombre} — ${e.region}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field grow autocomplete-wrap" style="min-width:200px">
                    <label style="color:rgba(255,255,255,.6)">Buscar destino</label>
                    <div class="input-icon">
                        <span class="mi mi-sm">search</span>
                        <input class="input" type="search" name="q" id="input-buscar-destino"
                               value="${busqueda}" placeholder="Nombre del atractivo…"
                               autocomplete="off" data-autocomplete-destinos>
                    </div>
                    <div class="autocomplete-menu" id="menu-sugerencias-destinos" role="listbox"></div>
                </div>
                <button type="submit" class="btn btn-primary"
                        style="background:#fff;color:var(--brand-navy-800)">
                    <span class="mi mi-sm">search</span> Buscar
                </button>
            </div>
        </form>
    </div>
</section>

<!-- ====================================================================
     CLIMA DE LA ESTACIÓN
     ==================================================================== -->
<c:if test="${not empty estacionSeleccionada}">
<section style="padding:22px 0 0">
    <div class="wrap">
        <c:choose>
            <c:when test="${empty clima}">
                <div class="notice notice-warning">
                    <span class="mi">cloud_off</span>
                    <div>
                        <div class="notice-title">Pronóstico no disponible</div>
                        El servicio del SENAMHI no ha entregado datos vigentes para esta zona.
                        La información turística y ferroviaria se muestra igualmente.
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <div class="card-body row between center wrap-flex g-4">
                        <div class="row center g-4">
                            <div class="weather" style="border:none;background:transparent;padding:0">
                                <div class="w-ico"><span class="mi">${clima.icono}</span></div>
                                <div>
                                    <div class="row center g-2">
                                        <span class="w-temp">${clima.temperatura}°</span>
                                        <span class="soft" style="font-size:.86rem">
                                            ${clima.temperaturaMin}° / ${clima.temperaturaMax}°
                                        </span>
                                    </div>
                                    <div class="w-cond">${clima.condicion} · SENAMHI</div>
                                </div>
                            </div>
                        </div>

                        <div class="row center g-5 wrap-flex">
                            <div>
                                <div class="eyebrow">Humedad</div>
                                <div style="font-weight:700">${clima.humedad}%</div>
                            </div>
                            <div>
                                <div class="eyebrow">Viento</div>
                                <div style="font-weight:700">${clima.viento} km/h ${clima.vientoDireccion}</div>
                            </div>
                            <div>
                                <div class="eyebrow">Prob. lluvia</div>
                                <div style="font-weight:700">${clima.probabilidadLluvia}%</div>
                            </div>
                            <c:if test="${not empty proximaSalida}">
                                <div>
                                    <div class="eyebrow">Próxima salida</div>
                                    <div style="font-weight:700">${mtc:hora(proximaSalida.horaSalida)}</div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <c:if test="${not climaVigente}">
                        <div class="card-foot">
                            <div class="row center g-2 soft" style="font-size:.82rem">
                                <span class="mi mi-sm">history</span>
                                Mostrando el último pronóstico válido almacenado
                                (${mtc:soloFecha(clima.fecha)}).
                                Última sincronización exitosa: ${mtc:fecha(climaActualizado)}.
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>
</c:if>

<!-- ====================================================================
     RESULTADOS — Zonas turísticas filtradas
     ==================================================================== -->
<section class="section-sm">
    <div class="wrap">

        <c:choose>

            <%-- Aún no se eligió estación --%>
            <c:when test="${empty estacionSeleccionada}">
                <div class="card">
                    <div class="empty">
                        <span class="mi">tram</span>
                        <h4>Selecciona tu estación de partida</h4>
                        <p class="muted" style="max-width:52ch;margin:0 auto">
                            Elige arriba la estación ferroviaria desde la que quieres empezar a caminar.
                            Te mostraremos las zonas turísticas vinculadas y su ruta a pie de ida y vuelta.
                        </p>

                        <div class="grid grid-auto mt-5" style="text-align:left">
                            <c:forEach var="e" items="${estaciones}" end="5">
                                <a href="${ctx}/explorar?estacion=${e.codigo}" class="station-card">
                                    <span class="station-badge">
                                        <span class="mi">tram</span>
                                    </span>
                                    <div style="min-width:0;flex:1">
                                        <div style="font-weight:650;font-size:.95rem">${e.nombre}</div>
                                        <div class="row center g-1 soft" style="font-size:.82rem;margin-top:2px">
                                            <span class="mi mi-sm" style="font-size:14px">location_on</span>
                                            ${e.region}
                                        </div>
                                    </div>
                                    <span class="mi mi-sm soft">arrow_forward</span>
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </c:when>

            <%-- Estación sin zonas registradas --%>
            <c:when test="${empty resultados}">
                <div class="card">
                    <div class="empty">
                        <span class="mi">travel_explore</span>
                        <h4>
                            <c:choose>
                                <c:when test="${preferenciasSesion.totalSeleccionadas gt 0}">
                                    Ninguna zona coincide con tus preferencias
                                </c:when>
                                <c:otherwise>
                                    Esta estación aún no tiene zonas turísticas registradas
                                </c:otherwise>
                            </c:choose>
                        </h4>
                        <p class="muted" style="max-width:56ch;margin:0 auto">
                            <c:choose>
                                <c:when test="${preferenciasSesion.totalSeleccionadas gt 0}">
                                    Prueba ampliando tus categorías o elevando la dificultad máxima aceptada.
                                </c:when>
                                <c:otherwise>
                                    Travel Group Perú aún no ha levantado zonas turísticas para
                                    ${estacionSeleccionada.nombre}. Prueba con otra estación.
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <div class="row center g-2 mt-4" style="justify-content:center">
                            <button type="button" class="btn btn-primary" data-modal-open="modal-preferencias">
                                <span class="mi mi-sm">tune</span> Ajustar preferencias
                            </button>
                            <form method="post" action="${ctx}/preferencias/limpiar">
                                <button type="submit" class="btn btn-ghost">
                                    <span class="mi mi-sm">filter_alt_off</span> Quitar filtros
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:when>

            <%-- Resultados --%>
            <c:otherwise>
                <div class="row between center wrap-flex g-3 mb-4">
                    <div>
                        <h2 style="font-size:1.3rem">
                            ${resultados.size()} ruta(s) recomendada(s)
                        </h2>
                        <p class="muted" style="margin:4px 0 0;font-size:.88rem">
                            <c:choose>
                                <c:when test="${preferenciasSesion.totalSeleccionadas gt 0}">
                                    Filtrado por
                                    <c:forEach var="cat" items="${categorias}">
                                        <c:if test="${preferenciasSesion.tieneCategoria(cat.codigo)}">
                                            <span class="chip chip-primary" style="margin:0 2px">
                                                <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                            </span>
                                        </c:if>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    Sin filtro de preferencias: se muestran todas las zonas disponibles.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <button type="button" class="btn btn-outline btn-sm" data-modal-open="modal-preferencias">
                        <span class="mi mi-sm">tune</span> Cambiar filtros
                    </button>
                </div>

                <div class="grid grid-auto">
                    <c:forEach var="r" items="${resultados}">
                        <article class="card card-hover zona-card reveal">
                            <a href="${ctx}/zona/${r.zona.codigo}" class="zona-media">
                                <img data-fallback data-seed="${r.zona.codigo}" alt="${r.zona.nombre}"
                                     loading="lazy"
                                     <c:if test="${not empty r.zona.imagen}">src="${mtc:foto(r.zona.imagen, ctx)}"</c:if>>
                                <c:if test="${not empty r.tarifaDesde}">
                                    <span class="price-tag">Desde S/ ${mtc:solesCorto(r.tarifaDesde)}</span>
                                </c:if>
                                <c:if test="${r.coincidencias gt 0}">
                                    <span class="state-tag">
                                        <span class="mi mi-sm" style="color:var(--c-success)">check_circle</span>
                                        ${r.coincidencias} coincidencia(s)
                                    </span>
                                </c:if>
                            </a>

                            <div class="zona-body">
                                <div class="row between center g-2 wrap-flex">
                                    <a href="${ctx}/zona/${r.zona.codigo}" class="zona-title">${r.zona.nombre}</a>
                                    <div class="row g-1 center">
                                        <c:forEach var="cat" items="${r.zona.categorias}" end="0">
                                            <span class="chip chip-categoria" style="--cat:${cat.color}">
                                                <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                            </span>
                                        </c:forEach>
                                        <c:if test="${r.zona.categorias.size() gt 1}">
                                            <span class="chip chip-outline chip-more"
                                                  data-tooltip-html="tooltip-explorar-${r.zona.codigo}"
                                                  title="<c:forEach var="cat" items="${r.zona.categorias}" begin="1" varStatus="cs">${cat.nombre}${cs.last ? '' : ', '}</c:forEach>"
                                                  tabindex="0"
                                                  role="button"
                                                  aria-label="Ver más categorías">
                                                +${r.zona.categorias.size() - 1}
                                            </span>
                                            <div id="tooltip-explorar-${r.zona.codigo}" style="display:none">
                                                <div class="tooltip-header">
                                                    <span class="mi mi-sm">category</span>
                                                    Otras categorías (${r.zona.categorias.size() - 1})
                                                </div>
                                                <div class="tooltip-chips">
                                                    <c:forEach var="cat" items="${r.zona.categorias}" begin="1">
                                                        <span class="chip chip-categoria" style="--cat:${cat.color}">
                                                            <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                                        </span>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <p class="zona-desc">${r.zona.descripcion}</p>

                                <!-- Ruta caminable recomendada -->
                                <c:if test="${not empty r.ruta}">
                                    <div class="row center g-3 wrap-flex"
                                         style="padding:11px 13px;border-radius:var(--r-md);background:var(--c-surface-3)">
                                        <span class="item row center g-1" style="font-size:.84rem">
                                            <span class="mi mi-sm" style="color:var(--c-primary)">directions_walk</span>
                                            <strong>${r.ruta.distanciaTotalKm} km</strong>
                                        </span>
                                        <span class="item row center g-1" style="font-size:.84rem">
                                            <span class="mi mi-sm" style="color:var(--c-primary)">timer</span>
                                            ${r.ruta.tiempoTotalTexto}
                                        </span>
                                        <span class="row center g-2" style="margin-left:auto">
                                            <span class="difficulty" data-level="${r.ruta.nivelDificultad}"
                                                  title="Dificultad: ${r.ruta.dificultad}">
                                                <i></i><i></i><i></i>
                                            </span>
                                        </span>
                                    </div>
                                </c:if>

                                <div class="zona-meta">
                                    <c:if test="${not empty r.clima}">
                                        <span class="item">
                                            <span class="mi mi-sm">${r.clima.icono}</span>
                                            ${r.clima.temperatura}°C ${r.clima.condicion}
                                        </span>
                                    </c:if>
                                    <c:if test="${not empty r.proximaSalida}">
                                        <span class="item">
                                            <span class="mi mi-sm">train</span>
                                            Próx: ${mtc:hora(r.proximaSalida.horaSalida)}
                                        </span>
                                    </c:if>
                                </div>

                                <a href="${ctx}/zona/${r.zona.codigo}" class="btn btn-primary btn-block mt-2">
                                    Ver detalles <span class="mi mi-sm">arrow_forward</span>
                                </a>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- ====================================================================
     MODAL · Preferencias turísticas
     ==================================================================== -->
<div class="modal" id="modal-preferencias" aria-hidden="true" role="dialog" aria-modal="true"
     aria-labelledby="tit-pref">
    <div class="modal-card modal-md">
        <form method="post" action="${ctx}/preferencias" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">tune</span></div>
                <h3 id="tit-pref">Tus preferencias turísticas</h3>
                <p>Se aplican únicamente a esta sesión de consulta</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <div class="pref-grid">
                    <c:forEach var="cat" items="${categorias}">
                        <label class="pref">
                            <input type="checkbox" name="categorias" value="${cat.codigo}"
                                   <c:if test="${preferenciasSesion.tieneCategoria(cat.codigo)}">checked</c:if>>
                            <span class="pref-icon" style="--cat:${cat.color}">
                                <span class="mi">${cat.icono}</span>
                            </span>
                            <span class="pref-name">${cat.nombre}</span>
                        </label>
                    </c:forEach>
                </div>

                <div class="form-grid cols-2 mt-4">
                    <div class="field">
                        <label for="pref-estacion">Estación de partida</label>
                        <select class="select" name="estacion" id="pref-estacion">
                            <option value="">Todas las estaciones</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}"
                                        <c:if test="${estacionSeleccionada.codigo eq e.codigo}">selected</c:if>>
                                    ${e.nombre}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label for="pref-dif">Dificultad máxima</label>
                        <select class="select" name="dificultad" id="pref-dif">
                            <option value="">Sin límite</option>
                            <option value="Fácil"    <c:if test="${preferenciasSesion.dificultadMaxima eq 'Fácil'}">selected</c:if>>Fácil</option>
                            <option value="Moderada" <c:if test="${preferenciasSesion.dificultadMaxima eq 'Moderada'}">selected</c:if>>Hasta moderada</option>
                            <option value="Alta"     <c:if test="${preferenciasSesion.dificultadMaxima eq 'Alta'}">selected</c:if>>Cualquiera</option>
                        </select>
                    </div>
                </div>

                <div class="notice notice-info mt-4">
                    <span class="mi mi-sm">info</span>
                    <div>Si no seleccionas ninguna categoría, la plataforma mostrará todas las zonas
                        turísticas disponibles sin filtrar.</div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">check</span> Aplicar preferencias
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ====================================================================
     MODAL · Horarios y tarifas de la estación
     ==================================================================== -->
<c:if test="${not empty estacionSeleccionada}">
<div class="modal" id="modal-horarios" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-lg">
        <div class="modal-head">
            <div class="modal-icon"><span class="mi">train</span></div>
            <h3>Servicio ferroviario · PeruRail</h3>
            <p>${estacionSeleccionada.nombre} — horarios, tiempos de recorrido y tarifas</p>
            <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                <span class="mi mi-sm">close</span>
            </button>
        </div>

        <div class="modal-body" style="padding:0">
            <c:choose>
                <c:when test="${empty horarios}">
                    <div class="empty">
                        <span class="mi">train</span>
                        <h4>Sin horarios vigentes</h4>
                        <p class="muted">No se registran servicios activos para esta estación.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-wrap">
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
                                <c:forEach var="h" items="${horarios}">
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
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="modal-foot" style="justify-content:space-between">
            <span class="soft" style="font-size:.8rem">
                La plataforma no realiza venta ni reserva de boletos.
            </span>
            <button type="button" class="btn btn-primary" data-modal-close>Entendido</button>
        </div>
    </div>
</div>
</c:if>

<jsp:include page="../shared/portal-footer.jsp" />
<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
