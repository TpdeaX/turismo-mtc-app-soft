<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="seccion" value="inicio" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>${parametros['plataforma.nombre']} · Asesor de rutas turísticas a pie</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

<%-- Pantalla de carga del portal principal --%>
<div id="splash-screen" class="splash-screen">

    <%-- Patrón topográfico de fondo --%>
    <svg class="splash-topo" viewBox="0 0 800 600" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <defs>
            <linearGradient id="spl-g1" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stop-color="#F5C518" stop-opacity=".07"/>
                <stop offset="100%" stop-color="#5EEAD4" stop-opacity=".04"/>
            </linearGradient>
        </defs>
        <g fill="none" stroke="url(#spl-g1)" stroke-width=".8">
            <path d="M-20 520 C80 480,180 540,280 500 S480 420,580 460 S780 380,880 420"/>
            <path d="M-20 440 C100 400,200 460,320 420 S500 340,620 380 S780 300,880 340"/>
            <path d="M-20 360 C120 320,220 380,360 340 S520 260,660 300 S780 220,880 260"/>
            <path d="M-20 280 C140 240,240 300,400 260 S540 180,700 220 S780 140,880 180"/>
            <path d="M-20 200 C160 160,260 220,440 180 S560 100,740 140 S780 60,880 100"/>
            <path d="M-20 120 C180 80,280 140,480 100 S580 20,780 60 S820 -20,880 20"/>
        </g>
    </svg>

    <%-- Partículas brillantes flotantes --%>
    <div class="splash-particles" aria-hidden="true">
        <i class="sp" style="--x:10%;--y:20%;--d:6s;--s:3px"></i>
        <i class="sp" style="--x:25%;--y:70%;--d:8s;--s:2px"></i>
        <i class="sp" style="--x:40%;--y:15%;--d:7s;--s:4px"></i>
        <i class="sp" style="--x:60%;--y:80%;--d:5s;--s:2px"></i>
        <i class="sp" style="--x:75%;--y:30%;--d:9s;--s:3px"></i>
        <i class="sp" style="--x:85%;--y:65%;--d:6s;--s:2px"></i>
        <i class="sp" style="--x:15%;--y:85%;--d:10s;--s:3px"></i>
        <i class="sp" style="--x:50%;--y:45%;--d:7s;--s:2px"></i>
        <i class="sp" style="--x:90%;--y:10%;--d:8s;--s:4px"></i>
        <i class="sp" style="--x:35%;--y:55%;--d:6s;--s:2px"></i>
        <i class="sp" style="--x:70%;--y:90%;--d:9s;--s:3px"></i>
        <i class="sp" style="--x:5%;--y:50%;--d:7s;--s:2px"></i>
    </div>

    <%-- Iconos temáticos flotando --%>
    <div class="splash-icons" aria-hidden="true">
        <span class="splash-float-icon" style="--x:8%;--y:18%;--d:12s;--dl:0s">
            <span class="mi">terrain</span>
        </span>
        <span class="splash-float-icon" style="--x:88%;--y:22%;--d:14s;--dl:.5s">
            <span class="mi">tram</span>
        </span>
        <span class="splash-float-icon" style="--x:12%;--y:75%;--d:11s;--dl:1s">
            <span class="mi">wb_sunny</span>
        </span>
        <span class="splash-float-icon" style="--x:82%;--y:78%;--d:13s;--dl:1.5s">
            <span class="mi">directions_walk</span>
        </span>
        <span class="splash-float-icon" style="--x:22%;--y:40%;--d:15s;--dl:2s">
            <span class="mi">map</span>
        </span>
        <span class="splash-float-icon" style="--x:78%;--y:48%;--d:10s;--dl:2.5s">
            <span class="mi">travel_explore</span>
        </span>
        <span class="splash-float-icon" style="--x:50%;--y:88%;--d:12s;--dl:3s">
            <span class="mi">flag</span>
        </span>
        <span class="splash-float-icon" style="--x:35%;--y:12%;--d:13s;--dl:1.2s">
            <span class="mi">photo_camera</span>
        </span>
        <span class="splash-float-icon" style="--x:65%;--y:14%;--d:11s;--dl:2.2s">
            <span class="mi">cloud</span>
        </span>
        <span class="splash-float-icon" style="--x:92%;--y:50%;--d:14s;--dl:.8s">
            <span class="mi">landscape</span>
        </span>
    </div>

    <%-- Contenido central --%>
    <div class="splash-content">

        <%-- Anillos giratorios concéntricos --%>
        <div class="splash-rings">
            <div class="splash-ring splash-ring-1"></div>
            <div class="splash-ring splash-ring-2"></div>
            <div class="splash-ring splash-ring-3"></div>
            <img src="${ctx}/assets/img/logo-mtc.png"
                 alt="${parametros['plataforma.nombre']}"
                 width="80" height="80" class="splash-logo">
        </div>

        <h2 class="splash-title">${parametros['plataforma.nombre']}</h2>
        <span class="splash-sub">${parametros['plataforma.lema']}</span>

        <%-- Barra de progreso animada --%>
        <div class="splash-progress">
            <div class="splash-progress-bar"></div>
        </div>

        <div class="splash-features">
            <span><span class="mi mi-sm">thermostat</span> Clima</span>
            <span class="splash-dot"></span>
            <span><span class="mi mi-sm">train</span> Trenes</span>
            <span class="splash-dot"></span>
            <span><span class="mi mi-sm">hiking</span> Rutas</span>
        </div>

        <span class="splash-hint">Preparando tu experiencia turística…</span>
    </div>

    <%-- Línea decorativa inferior con gradiente --%>
    <div class="splash-bottom-line"></div>
</div>

<jsp:include page="../shared/portal-nav.jsp" />

<!-- ====================================================================
     HERO
     ==================================================================== -->
<section class="hero">
    <div class="hero-bg-photo" style="background-image:url('${ctx}/assets/img/hero-andes-train.jpg');"></div>
    <div class="wrap">
        <div class="grid grid-2 g-6" style="align-items:center">

            <div class="anim-up">
                <span class="hero-kicker">
                    <span class="mi mi-sm">verified</span>
                    ${parametros['plataforma.entidad']}
                </span>

                <h1 class="display display-xl">
                    Baja del tren y <em>camina</em> hacia el Perú que no conocías.
                </h1>

                <p class="hero-sub">
                    Elegimos por ti la ruta turística a pie —de ida y vuelta— que sale de la estación
                    ferroviaria que escojas, cruzando el clima del SENAMHI, los horarios de PeruRail
                    y las zonas registradas por Travel Group Perú.
                </p>

                <div class="row g-3 mt-5 wrap-flex">
                    <a href="#planifica" class="btn btn-accent btn-lg">
                        <span class="mi">explore</span> Planificar mi recorrido
                    </a>
                    <a href="#como-funciona" class="btn btn-lg btn-outline"
                       style="background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.24);color:#fff">
                        <span class="mi">play_circle</span> Cómo funciona
                    </a>
                </div>

                <div class="hero-stats">
                    <div>
                        <div class="n">${totalZonas}</div>
                        <div class="l">Zonas turísticas activas</div>
                    </div>
                    <div>
                        <div class="n">${totalEstaciones}</div>
                        <div class="l">Estaciones ferroviarias</div>
                    </div>
                    <div>
                        <div class="n">${totalServicios}</div>
                        <div class="l">Servicios operativos</div>
                    </div>
                </div>
            </div>

            <div class="anim-up d-2">
                <div class="sources col g-3">
                    <div class="row between center g-3">
                        <span class="eyebrow" style="color:rgba(255,255,255,.55)">Fuentes oficiales integradas</span>
                        <span class="chip" style="background:rgba(245,197,24,.16);color:var(--brand-gold-400)">
                            <i class="dot dot-live" style="background:var(--brand-gold-500)"></i> En línea
                        </span>
                    </div>

                    <div class="marca-fuente">
                        <span class="marca" data-marca="SENAMHI">
                            <img src="${ctx}/assets/img/logos-oficiales/senamhi.svg" data-logo-oficial
                                 alt="SENAMHI · Servicio Nacional de Meteorología e Hidrología del Perú"
                                 width="232" height="56" loading="lazy">
                        </span>
                        <span class="marca-dato">
                            <strong>Pronóstico climático</strong>
                            <c:choose>
                                <c:when test="${not empty actualizadoSenamhi}">
                                    Actualizado ${mtc:fechaCorta(actualizadoSenamhi)}
                                </c:when>
                                <c:otherwise>Sin sincronizar</c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <div class="marca-fuente">
                        <span class="marca" data-marca="PeruRail">
                            <img src="${ctx}/assets/img/logos-oficiales/perurail.svg" data-logo-oficial
                                 alt="PeruRail · transporte ferroviario turístico"
                                 width="232" height="56" loading="lazy">
                        </span>
                        <span class="marca-dato">
                            <strong>Horarios y tarifas</strong>
                            <c:choose>
                                <c:when test="${not empty actualizadoPeruRail}">
                                    Actualizado ${mtc:fechaCorta(actualizadoPeruRail)}
                                </c:when>
                                <c:otherwise>Sin sincronizar</c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <div class="marca-fuente">
                        <span class="marca" data-marca="Travel Group Perú">
                            <img src="${ctx}/assets/img/logos-oficiales/travel-group-peru.svg" data-logo-oficial
                                 alt="Travel Group Perú · operador de zonas turísticas"
                                 width="232" height="56" loading="lazy">
                        </span>
                        <span class="marca-dato">
                            <strong>Catálogo turístico</strong>
                            ${totalZonas} zonas registradas
                        </span>
                    </div>

                    <p style="font-size:.8rem;color:rgba(255,255,255,.6);margin:2px 0 0;line-height:1.6">
                        Los datos climáticos y ferroviarios se sincronizan de forma automática al menos
                        una vez al día. Si una fuente no responde, mantenemos el último dato válido y
                        te indicamos su fecha.
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ====================================================================
     PLANIFICADOR
     ==================================================================== -->
<section class="section" id="planifica">
    <div class="wrap">

        <div class="text-center mb-5 reveal">
            <span class="eyebrow">Paso 1 · Cuéntanos qué te gusta</span>
            <h2 class="display display-lg mt-2">Arma tu recorrido en dos pasos</h2>
            <p class="lead mt-2" style="max-width:60ch;margin-left:auto;margin-right:auto">
                Selecciona tus preferencias y la estación desde la que quieres partir. El resto
                lo calcula la plataforma.
            </p>
        </div>

        <form method="post" action="${ctx}/preferencias" class="card reveal" data-submit-once>
            <div class="card-body card-body-lg">

                <!-- --- Preferencias turísticas --- -->
                <div class="row between center wrap-flex g-3 mb-3">
                    <div>
                        <h3 style="font-size:1.08rem">Preferencias turísticas</h3>
                        <p class="muted" style="margin:4px 0 0;font-size:.88rem">
                            Puedes elegir varias. Si no seleccionas ninguna, te mostraremos todo lo disponible.
                        </p>
                    </div>
                    <span class="muted" style="font-size:.8rem;font-style:italic;opacity:.7">
                        <span class="mi mi-sm" style="font-size:.85rem;vertical-align:middle">tune</span> Opcional
                    </span>
                </div>

                <div class="pref-grid">
                    <c:forEach var="cat" items="${categorias}">
                        <label class="pref">
                            <input type="checkbox" name="categorias" value="${cat.codigo}"
                                   <c:if test="${preferenciasSesion.tieneCategoria(cat.codigo)}">checked</c:if>>
                            <span class="pref-icon" style="--cat:${cat.color}">
                                <span class="mi">${cat.icono}</span>
                            </span>
                            <span>
                                <span class="pref-name">${cat.nombre}</span>
                            </span>
                        </label>
                    </c:forEach>
                </div>

                <hr>

                <!-- --- Estación de partida + filtros --- -->
                <div class="mb-3">
                    <h3 style="font-size:1.08rem">Punto de partida y exigencia</h3>
                    <p class="muted" style="margin:4px 0 0;font-size:.88rem">
                        Todas las rutas son peatonales, de un solo tramo de ida y vuelta a la misma estación.
                    </p>
                </div>

                <div class="form-grid cols-3">
                    <div class="field span-2">
                        <label for="estacion">Estación ferroviaria de partida</label>
                        <select class="select" name="estacion" id="estacion">
                            <option value="">Todas las estaciones</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}"
                                        <c:if test="${preferenciasSesion.estacionCodigo eq e.codigo}">selected</c:if>>
                                    ${e.nombre} — ${e.region}
                                </option>
                            </c:forEach>
                        </select>
                        <span class="hint">Listado obtenido de la integración con PeruRail.</span>
                    </div>

                    <div class="field">
                        <label for="dificultad">Dificultad máxima</label>
                        <select class="select" name="dificultad" id="dificultad">
                            <option value="">Sin límite</option>
                            <option value="Fácil"    <c:if test="${preferenciasSesion.dificultadMaxima eq 'Fácil'}">selected</c:if>>Fácil</option>
                            <option value="Moderada" <c:if test="${preferenciasSesion.dificultadMaxima eq 'Moderada'}">selected</c:if>>Hasta moderada</option>
                            <option value="Alta"     <c:if test="${preferenciasSesion.dificultadMaxima eq 'Alta'}">selected</c:if>>Cualquiera</option>
                        </select>
                        <span class="hint">Filtra rutas según tu condición física.</span>
                    </div>
                </div>

                <div class="row between center wrap-flex g-3 mt-5">
                    <p class="soft" style="margin:0;font-size:.82rem;max-width:46ch">
                        Tus preferencias se guardan únicamente en esta sesión de consulta.
                        No necesitas registrarte ni iniciar sesión.
                    </p>
                    <div class="row g-2">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <span class="mi">search</span> Ver rutas recomendadas
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</section>

<!-- ====================================================================
     DESTACADOS
     ==================================================================== -->
<c:if test="${not empty destacadas}">
<section class="section-sm" style="background:var(--c-bg-alt)">
    <div class="wrap">
        <div class="row between center wrap-flex g-3 mb-4 reveal">
            <div>
                <span class="eyebrow">Descubre el Perú</span>
                <h2 class="display display-md mt-2">Zonas turísticas destacadas</h2>
            </div>
            <a href="${ctx}/explorar" class="btn btn-outline">
                Ver todas <span class="mi mi-sm">arrow_forward</span>
            </a>
        </div>

        <div class="grid grid-auto">
            <c:forEach var="z" items="${destacadas}" varStatus="st">
                <a href="${ctx}/zona/${z.codigo}" class="card card-hover zona-card reveal">
                    <div class="zona-media">
                        <img data-fallback data-seed="${z.codigo}" alt="${z.nombre}"
                             loading="lazy"
                             <c:if test="${not empty z.imagen}">src="${mtc:foto(z.imagen, ctx)}"</c:if>>
                        <c:if test="${z.costoReferencial gt 0}">
                            <span class="price-tag">Desde S/ ${mtc:solesCorto(z.costoReferencial)}</span>
                        </c:if>
                    </div>
                    <div class="zona-body">
                        <div class="row between center g-2">
                            <span class="zona-title">${z.nombre}</span>
                        </div>
                        <div class="row g-1 wrap-flex">
                            <c:forEach var="cat" items="${z.categorias}" end="1">
                                <span class="chip chip-categoria" style="--cat:${cat.color}">
                                    <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                </span>
                            </c:forEach>
                            <c:if test="${z.categorias.size() gt 2}">
                                <span class="chip chip-outline chip-more"
                                      data-tooltip-html="tooltip-inicio-${z.codigo}"
                                      title="<c:forEach var="cat" items="${z.categorias}" begin="2" varStatus="cs">${cat.nombre}${cs.last ? '' : ', '}</c:forEach>"
                                      tabindex="0"
                                      role="button"
                                      aria-label="Ver más categorías">
                                    +${z.categorias.size() - 2}
                                </span>
                                <div id="tooltip-inicio-${z.codigo}" style="display:none">
                                    <div class="tooltip-header">
                                        <span class="mi mi-sm">category</span>
                                        Otras categorías (${z.categorias.size() - 2})
                                    </div>
                                    <div class="tooltip-chips">
                                        <c:forEach var="cat" items="${z.categorias}" begin="2">
                                            <span class="chip chip-categoria" style="--cat:${cat.color}">
                                                <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                            </span>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                        <p class="zona-desc">${z.descripcion}</p>
                        <div class="zona-meta">
                            <span class="item"><span class="mi mi-sm">tram</span>${z.estacion.nombre}</span>
                            <span class="item"><span class="mi mi-sm">schedule</span>${z.ruta.tiempoEstimado}</span>
                        </div>
                    </div>
                </a>
            </c:forEach>
        </div>
    </div>
</section>
</c:if>

<!-- ====================================================================
     CÓMO FUNCIONA
     ==================================================================== -->
<section class="section" id="como-funciona">
    <div class="wrap">
        <div class="text-center mb-6 reveal">
            <span class="eyebrow">Del andén al atractivo</span>
            <h2 class="display display-lg mt-2">Cómo trabaja el asesor</h2>
        </div>

        <div class="grid grid-4">
            <div class="step-card reveal">
                <div class="row between center">
                    <div class="step-icon-wrap"><span class="mi">tune</span></div>
                    <span class="step-num">01</span>
                </div>
                <h4 class="mt-2" style="font-size:1.02rem">Tus preferencias</h4>
                <p class="muted mt-1" style="font-size:.88rem">
                    Eliges las categorías que te interesan: naturaleza, historia, aventura, cultura y más.
                </p>
            </div>
            <div class="step-card reveal d-1">
                <div class="row between center">
                    <div class="step-icon-wrap"><span class="mi">tram</span></div>
                    <span class="step-num">02</span>
                </div>
                <h4 class="mt-2" style="font-size:1.02rem">Tu estación</h4>
                <p class="muted mt-1" style="font-size:.88rem">
                    Seleccionas la estación de PeruRail desde la que quieres partir a caminar.
                </p>
            </div>
            <div class="step-card reveal d-2">
                <div class="row between center">
                    <div class="step-icon-wrap"><span class="mi">directions_walk</span></div>
                    <span class="step-num">03</span>
                </div>
                <h4 class="mt-2" style="font-size:1.02rem">La ruta a pie</h4>
                <p class="muted mt-1" style="font-size:.88rem">
                    Calculamos el recorrido a pie de ida y vuelta con su tiempo estimado y dificultad.
                </p>
            </div>
            <div class="step-card reveal d-3">
                <div class="row between center">
                    <div class="step-icon-wrap"><span class="mi">receipt_long</span></div>
                    <span class="step-num">04</span>
                </div>
                <h4 class="mt-2" style="font-size:1.02rem">Tu informe</h4>
                <p class="muted mt-1" style="font-size:.88rem">
                    Recibes un informe consolidado con clima, horarios y tarifas, descargable en PDF.
                </p>
            </div>
        </div>

        <div class="card card-dark mt-5 reveal">
            <div class="card-body card-body-lg">
                <div class="grid grid-2 g-5" style="align-items:center">
                    <div>
                        <span class="eyebrow" style="color:var(--brand-gold-500)">Criterio del servicio</span>
                        <h3 class="display display-md mt-2" style="color:#fff">
                            Un solo tramo. Siempre a pie. Siempre de regreso.
                        </h3>
                        <p class="mt-3" style="color:var(--c-text-on-dark-muted);max-width:52ch">
                            Toda ruta recomendada parte y retorna a la misma estación, y está diseñada
                            para recorrerse exclusivamente caminando. No combinamos estaciones ni otros
                            medios de transporte.
                        </p>
                    </div>
                    <div class="col g-3">
                        <div class="row center g-3">
                            <span class="mi mi-lg" style="color:var(--brand-gold-500)">directions_walk</span>
                            <div>
                                <div style="font-weight:650;color:#fff">Alcance exclusivamente peatonal</div>
                                <div style="font-size:.85rem;color:var(--c-text-on-dark-muted)">
                                    Velocidad de caminata y pendiente incluidas en el cálculo.
                                </div>
                            </div>
                        </div>
                        <div class="row center g-3">
                            <span class="mi mi-lg" style="color:var(--brand-gold-500)">sync</span>
                            <div>
                                <div style="font-weight:650;color:#fff">Datos actualizados a diario</div>
                                <div style="font-size:.85rem;color:var(--c-text-on-dark-muted)">
                                    Clima y logística ferroviaria sincronizados automáticamente.
                                </div>
                            </div>
                        </div>
                        <div class="row center g-3">
                            <span class="mi mi-lg" style="color:var(--brand-gold-500)">picture_as_pdf</span>
                            <div>
                                <div style="font-weight:650;color:#fff">Informe portátil</div>
                                <div style="font-size:.85rem;color:var(--c-text-on-dark-muted)">
                                    Visualizable en HTML y descargable en PDF desde cualquier navegador.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../shared/portal-footer.jsp" />
<jsp:include page="../shared/scripts.jsp" />

<script>
(function () {
    var splash = document.getElementById('splash-screen');
    if (!splash) return;
    function ocultar() {
        splash.classList.add('is-hidden');
        setTimeout(function () { splash.remove(); }, 600);
    }
    // Esperar a que cargue todo (imágenes, fuentes, etc.)
    if (document.readyState === 'complete') {
        setTimeout(ocultar, 300);
    } else {
        window.addEventListener('load', function () { setTimeout(ocultar, 300); });
    }
    // Red de seguridad: si algo se traba, se oculta en 5 segundos
    setTimeout(ocultar, 5000);
})();
</script>
</body>
</html>
