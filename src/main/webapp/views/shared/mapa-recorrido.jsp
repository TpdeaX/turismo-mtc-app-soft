<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Mapa del recorrido a pie desde la estación hasta la zona turística.

    Cuando ambos puntos tienen coordenadas registradas se dibuja un mapa 3D real
    con relieve de los Andes (MapLibre GL + OpenStreetMap sobre el modelo de
    elevación de AWS Terrain Tiles, ver app.js#initGeomap). Si a la zona le
    faltan coordenadas —o si el navegador no puede dibujar el mapa— se muestra
    el esquema a escala libre (RN01, RN04) con los mismos datos reales de
    distancia y tiempo.

    Espera en ámbito de petición:
      mapaEstacion · Estacion            mapaZona · ZonaTuristica
      mapaRuta     · RutaRecomendadaDTO
--%>
<c:set var="hayCoordenadas"
       value="${not empty mapaEstacion.latitud and not empty mapaEstacion.longitud
                and not empty mapaZona.latitud and not empty mapaZona.longitud}" />
<div class="route-map-wrap">

    <c:if test="${hayCoordenadas}">
        <div class="route-geomap" data-geomap
             data-est-lat="${mapaEstacion.latitud}" data-est-lng="${mapaEstacion.longitud}"
             data-est-nombre="<c:out value='${mapaEstacion.nombre}'/>"
             data-zona-lat="${mapaZona.latitud}" data-zona-lng="${mapaZona.longitud}"
             data-zona-nombre="<c:out value='${mapaZona.nombre}'/>"
             data-ruta-km="${mapaRuta.distanciaIdaKm}"
             role="img"
             aria-label="Mapa en tres dimensiones del recorrido a pie desde ${mapaEstacion.nombre} hasta ${mapaZona.nombre}: ${mapaRuta.distanciaIdaKm} kilómetros por tramo, aproximadamente ${mapaRuta.minutosIda} minutos, con retorno por el mismo camino.">
            <%-- Spinner de carga: se oculta cuando el mapa termina de renderizar --%>
            <div class="geomap-loading" data-geomap-loader>
                <div class="geomap-spinner"></div>
                <span>Cargando mapa…</span>
            </div>
        </div>
        <span class="soft" style="font-size:.74rem">
            Trazado sobre caminos reales · 3D con relieve o carta plana, y las vías
            férreas con el botón del tren · arrastra para girar, Ctrl + rueda para acercar
        </span>
    </c:if>

    <%-- Esquema de respaldo: visible solo si no hay coordenadas (o si falla el mapa 3D) --%>
    <div ${hayCoordenadas ? 'hidden data-geomap-fallback' : ''}>
    <div class="route-map" role="img"
         aria-label="Recorrido a pie desde ${mapaEstacion.nombre} hasta ${mapaZona.nombre}: ${mapaRuta.distanciaIdaKm} kilómetros por tramo, aproximadamente ${mapaRuta.minutosIda} minutos, con retorno por el mismo camino.">

        <svg class="route-map-canvas" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true" focusable="false">
            <defs>
                <linearGradient id="rmTrazo" x1="0" y1="1" x2="1" y2="0">
                    <stop offset="0%"   stop-color="#F5C518"/>
                    <stop offset="55%"  stop-color="#7FD4C1"/>
                    <stop offset="100%" stop-color="#5EEAD4"/>
                </linearGradient>
            </defs>

            <%-- Retícula urbana decorativa --%>
            <g class="rm-grid" vector-effect="non-scaling-stroke">
                <path d="M0 22 H100 M0 46 H100 M0 70 H100 M0 88 H100"/>
                <path d="M12 0 V100 M34 0 V100 M56 0 V100 M78 0 V100"/>
            </g>

            <%-- Curvas de nivel: sugieren el relieve andino --%>
            <g class="rm-contour" vector-effect="non-scaling-stroke">
                <path d="M-4 62 C 18 50, 30 68, 52 56 S 84 34, 104 44"/>
                <path d="M-4 82 C 20 72, 34 86, 56 74 S 86 56, 104 66"/>
                <path d="M-4 40 C 16 30, 32 44, 54 32 S 84 14, 104 22"/>
            </g>

            <%-- Trazo del recorrido: halo + línea --%>
            <path class="rm-route-glow" vector-effect="non-scaling-stroke" fill="none"
                  d="M18 73 C 30 70, 37 58, 50 48 S 71 33, 82 25"/>
            <path class="rm-route" vector-effect="non-scaling-stroke" fill="none"
                  d="M18 73 C 30 70, 37 58, 50 48 S 71 33, 82 25"/>
        </svg>

        <%-- Punto de partida y retorno --%>
        <span class="route-pin is-inicio" style="--x:18%;--y:73%">
            <span class="pin-mark"><span class="mi mi-sm">tram</span><i class="pin-n">1</i></span>
            <span class="pin-tag">
                <b>${mapaEstacion.nombre}</b>
                <i>Salida y retorno</i>
            </span>
        </span>

        <%-- Tramo peatonal --%>
        <span class="route-leg" style="--x:50%;--y:48%">
            <span class="mi mi-sm">directions_walk</span>
            <b>${mapaRuta.distanciaIdaKm} km</b>
            <span class="sep">·</span>
            <span>${mapaRuta.minutosIda} min</span>
            <span class="leg-vuelta">ida y vuelta</span>
        </span>

        <%-- Destino --%>
        <span class="route-pin is-destino" style="--x:82%;--y:25%">
            <span class="pin-mark"><span class="mi mi-sm">flag</span><i class="pin-n">3</i></span>
            <span class="pin-tag">
                <b>${mapaZona.nombre}</b>
                <i>Destino</i>
            </span>
        </span>

        <span class="route-map-nota">Esquema del recorrido · no está a escala</span>
    </div>
    </div>

    <%-- Secuencia detallada, numerada igual que el esquema --%>
    <ol class="route-steps">
        <li class="route-step is-inicio">
            <span class="step-n">1</span>
            <div>
                <div class="s-title">Salida · ${mapaEstacion.nombre}</div>
                <div class="s-meta">
                    ${mapaEstacion.ubicacion}<c:if test="${not empty mapaEstacion.conexiones}"> · Conexiones: ${mapaEstacion.conexiones}</c:if>
                </div>
            </div>
        </li>
        <li class="route-step">
            <span class="step-n">2</span>
            <div>
                <div class="s-title">${mapaRuta.ruta.nombre}</div>
                <div class="s-meta">${mapaRuta.distanciaIdaKm} km a pie · aprox. ${mapaRuta.minutosIda} min</div>
            </div>
        </li>
        <li class="route-step is-destino">
            <span class="step-n">3</span>
            <div>
                <div class="s-title">Llegada · ${mapaZona.nombre}</div>
                <div class="s-meta">Tiempo de visita a discreción del viajero</div>
            </div>
        </li>
        <li class="route-step is-inicio">
            <span class="step-n">4</span>
            <div>
                <div class="s-title">Retorno · ${mapaEstacion.nombre}</div>
                <div class="s-meta">Mismo tramo de vuelta · aprox. ${mapaRuta.minutosIda} min</div>
            </div>
        </li>
    </ol>
</div>
