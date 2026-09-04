<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="seccion" value="inicio" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>MTC Perú · Asesor de rutas turísticas a pie</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

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
                    Ministerio de Transportes y Comunicaciones
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
                    <span class="chip chip-outline">
                        <span class="mi mi-sm">tune</span> Opcional
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
</body>
</html>
