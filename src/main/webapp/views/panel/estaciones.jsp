<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="estaciones" scope="request" />
<c:set var="tituloModulo" value="Estaciones" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Estaciones ferroviarias · MTC Perú</title>
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
                    <span class="eyebrow">PeruRail</span>
                    <h1 class="mt-2">Estaciones Ferroviarias</h1>
                    <p>Listado de estaciones integrado desde PeruRail. Se utiliza para vincular
                        correctamente las zonas turísticas registradas por Travel Group Perú.</p>
                </div>
                <c:if test="${usuarioSesion.admin}">
                    <button type="button" class="btn btn-primary btn-lg"
                            data-modal-open="modal-estacion"
                            data-modal-title="Registrar nueva estación"
                            data-modal-sub="Solo el administrador puede editar el listado"
                            data-set-codigo="" data-set-nombre="" data-set-ubicacion=""
                            data-set-region="" data-set-latitud="" data-set-longitud=""
                            data-set-conexiones="">
                        <span class="mi mi-sm">add_location</span> Nueva estación
                    </button>
                </c:if>
            </div>

            <c:if test="${not usuarioSesion.admin}">
                <div class="notice notice-info mb-4 anim-up">
                    <span class="mi mi-sm">visibility</span>
                    <div>
                        <div class="notice-title">Consulta en modo de solo lectura</div>
                        Las estaciones provienen exclusivamente de
                        PeruRail y no pueden editarse desde este módulo.
                    </div>
                </div>
            </c:if>

            <!-- Buscador -->
            <form method="get" action="${ctx}/panel/estaciones" class="filterbar mb-4 anim-up d-1">
                <div class="field grow">
                    <div class="input-icon">
                        <span class="mi mi-sm">search</span>
                        <input class="input" type="search" name="q" value="${q}"
                               placeholder="Buscar por nombre, ubicación o región…">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">search</span> Buscar
                </button>
                <c:if test="${not empty q}">
                    <a href="${ctx}/panel/estaciones" class="btn btn-ghost">
                        <span class="mi mi-sm">filter_alt_off</span> Limpiar
                    </a>
                </c:if>
                <span class="chip chip-outline">
                    <span class="mi mi-sm">tram</span> ${estaciones.size()} estaciones
                </span>
            </form>

            <div class="card anim-up d-2">
                <div class="card-head">
                    <h3>Listado de estaciones</h3>
                    <span class="soft" style="font-size:.82rem">
                        Despliega una fila para ver sus coordenadas y sus rutas caminables.
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty estaciones}">
                        <div class="empty">
                            <span class="mi">tram</span>
                            <h4>Sin estaciones</h4>
                            <p class="muted">
                                <c:choose>
                                    <c:when test="${not empty q}">Ninguna estación coincide con la búsqueda.</c:when>
                                    <c:otherwise>Ejecuta una sincronización con PeruRail para poblar el listado.</c:otherwise>
                                </c:choose>
                            </p>
                            <form method="post" action="${ctx}/panel/integraciones/sincronizar" class="mt-4">
                                <input type="hidden" name="fuente" value="PERURAIL">
                                <button type="submit" class="btn btn-primary">
                                    <span class="mi mi-sm">sync</span> Sincronizar con PeruRail
                                </button>
                            </form>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th style="width:52px"></th>
                                        <th>Estación</th>
                                        <th>Región</th>
                                        <th>Conexiones</th>
                                        <th>Rutas</th>
                                        <th>Actualizada</th>
                                        <c:if test="${usuarioSesion.admin}">
                                            <th class="text-right" style="width:110px">Acciones</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="e" items="${estaciones}">
                                    <tr class="main-row">
                                        <td>
                                            <button type="button" class="expander" data-expand
                                                    aria-expanded="false" aria-controls="det-est-${e.codigo}"
                                                    aria-label="Ver detalle de ${e.nombre}">
                                                <span class="mi">expand_more</span>
                                            </button>
                                        </td>
                                        <td>
                                            <div class="row center g-3">
                                                <span class="stat-icon stat-icon-sm">
                                                    <span class="mi mi-sm">tram</span>
                                                </span>
                                                <div style="min-width:0">
                                                    <div class="cell-strong">${e.nombre}</div>
                                                    <div class="soft" style="font-size:.79rem">${e.ubicacion}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td><span class="chip chip-outline">${e.region}</span></td>
                                        <td class="muted">${e.conexiones}</td>
                                        <td>
                                            <span class="chip chip-info">${e.rutas.size()} ruta(s)</span>
                                        </td>
                                        <td class="soft" style="font-size:.82rem">
                                            ${mtc:relativo(e.actualizado)}
                                        </td>
                                        <c:if test="${usuarioSesion.admin}">
                                            <td>
                                                <div class="actions">
                                                    <button type="button" class="btn-icon btn-icon-sm accent"
                                                            title="Editar"
                                                            data-modal-open="modal-estacion"
                                                            data-modal-title="Editar estación"
                                                            data-modal-sub="${e.nombre}"
                                                            data-set-codigo="${e.codigo}"
                                                            data-set-nombre="<c:out value='${e.nombre}'/>"
                                                            data-set-ubicacion="<c:out value='${e.ubicacion}'/>"
                                                            data-set-region="<c:out value='${e.region}'/>"
                                                            data-set-latitud="${e.latitud}"
                                                            data-set-longitud="${e.longitud}"
                                                            data-set-conexiones="<c:out value='${e.conexiones}'/>">
                                                        <span class="mi mi-sm">edit</span>
                                                    </button>
                                                    <button type="button" class="btn-icon btn-icon-sm danger"
                                                            title="Eliminar"
                                                            data-modal-open="modal-eliminar-estacion"
                                                            data-set-codigo="${e.codigo}"
                                                            data-set-nombreestacion="<c:out value='${e.nombre}'/>"
                                                            data-set-rutasestacion="${e.rutas.size()} ruta(s) asociada(s)">
                                                        <span class="mi mi-sm">delete</span>
                                                    </button>
                                                </div>
                                            </td>
                                        </c:if>
                                    </tr>

                                    <tr class="detail-row" id="det-est-${e.codigo}">
                                        <td colspan="${usuarioSesion.admin ? 7 : 6}">
                                            <div class="detail-inner">
                                                <div class="detail-clip">
                                                    <div class="detail-pad">
                                                        <div class="grid grid-2 g-5">
                                                            <div>
                                                                <div class="eyebrow mb-2">Zona geográfica</div>
                                                                <div class="doc-kpis">
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Latitud</div>
                                                                        <div class="v mono"
                                                                             style="font-size:1rem">${e.latitud}</div>
                                                                    </div>
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Longitud</div>
                                                                        <div class="v mono"
                                                                             style="font-size:1rem">${e.longitud}</div>
                                                                    </div>
                                                                </div>
                                                                <p class="soft mt-3" style="font-size:.82rem;margin:0">
                                                                    Estas coordenadas determinan la zona geográfica
                                                                    usada para consultar el pronóstico del SENAMHI.
                                                                </p>
                                                            </div>

                                                            <div>
                                                                <div class="eyebrow mb-2">Rutas caminables</div>
                                                                <c:choose>
                                                                    <c:when test="${empty e.rutas}">
                                                                        <p class="soft" style="margin:0">
                                                                            Sin rutas registradas desde esta estación.
                                                                        </p>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="col g-2">
                                                                            <c:forEach var="r" items="${e.rutas}">
                                                                                <div class="row between center g-3"
                                                                                     style="padding:9px 12px;border-radius:var(--r-sm);background:var(--c-surface)">
                                                                                    <span class="cell-strong">${r.nombre}</span>
                                                                                    <span class="soft" style="font-size:.82rem">
                                                                                        ${r.distanciaKm} km · ${r.dificultad}
                                                                                    </span>
                                                                                </div>
                                                                            </c:forEach>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
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
            </div>
        </div>
    </div>
</div>

<c:if test="${usuarioSesion.admin}">
<!-- MODAL · Estación -->
<div class="modal" id="modal-estacion" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/estaciones/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">tram</span></div>
                <h3 data-modal-title-target>Registrar nueva estación</h3>
                <p data-modal-sub-target>Solo el administrador puede editar el listado</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="e-nombre">Nombre de la estación <span class="req">*</span></label>
                        <input class="input" type="text" id="e-nombre" name="nombre" maxlength="50" required
                               data-autofocus placeholder="Ej. Estación Ollantaytambo">
                    </div>
                    <div class="field span-full">
                        <label for="e-ubicacion">Ubicación / dirección <span class="req">*</span></label>
                        <input class="input" type="text" id="e-ubicacion" name="ubicacion" maxlength="50" required
                               placeholder="Ej. Av. Ferrocarril s/n">
                    </div>
                    <div class="field">
                        <label for="e-region">Región</label>
                        <input class="input" type="text" id="e-region" name="region" maxlength="50"
                               list="lista-regiones" placeholder="Ej. Cusco (Urubamba)">
                        <datalist id="lista-regiones">
                            <c:forEach var="rg" items="${regiones}">
                                <option value="${rg}"></option>
                            </c:forEach>
                        </datalist>
                    </div>
                    <div class="field">
                        <label for="e-conexiones">Conexiones disponibles</label>
                        <input class="input" type="text" id="e-conexiones" name="conexiones" maxlength="150"
                               placeholder="Ej. Bus, Taxi, Peatonal">
                    </div>
                    <div class="field">
                        <label for="e-lat">Latitud</label>
                        <input class="input" type="number" id="e-lat" name="latitud" step="0.000001"
                               placeholder="-13.258500">
                    </div>
                    <div class="field">
                        <label for="e-lng">Longitud</label>
                        <input class="input" type="number" id="e-lng" name="longitud" step="0.000001"
                               placeholder="-72.264600">
                        <span class="hint">Necesarias para el pronóstico por zona geográfica.</span>
                    </div>
                </div>

                <div class="notice notice-warning mt-4">
                    <span class="mi mi-sm">policy</span>
                    <div>La información logística ferroviaria
                        proviene exclusivamente de PeruRail. Una sincronización posterior puede
                        sobrescribir los cambios manuales.</div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar estación
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL · Eliminar estación -->
<div class="modal" id="modal-eliminar-estacion" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/estaciones/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar estación?</h3>
                <p>Esta acción no se puede deshacer</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>Solo pueden eliminarse estaciones sin rutas turísticas asociadas.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Estación seleccionada</div>
                    <div class="cell-strong mt-1" data-field="nombreestacion">—</div>
                    <div class="soft" style="font-size:.83rem" data-field="rutasestacion">—</div>
                </div>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-danger">
                    <span class="mi mi-sm">delete</span> Sí, eliminar
                </button>
            </div>
        </form>
    </div>
</div>
</c:if>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
