<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="zonas" scope="request" />
<c:set var="tituloModulo" value="Zonas turísticas" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Gestión de Zonas Turísticas · MTC Perú</title>
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
                    <span class="eyebrow">Travel Group Perú</span>
                    <h1 class="mt-2">Gestión de Zonas Turísticas</h1>
                    <p>Registra, actualiza y elimina las zonas turísticas vinculadas a las rutas
                        caminables de cada estación ferroviaria.</p>
                </div>
                <button type="button" class="btn btn-primary btn-lg"
                        data-modal-open="modal-zona"
                        data-modal-title="Registrar nueva zona turística"
                        data-modal-sub="Complete los datos y vincúlela a una ruta"
                        data-set-codigo=""
                        data-set-nombre=""
                        data-set-descripcion=""
                        data-set-ubicacion=""
                        data-set-imagen=""
                        data-set-costoReferencial="0"
                        data-set-categorias=""
                        data-set-estado="true">
                    <span class="mi mi-sm">add_location_alt</span> Nueva zona turística
                </button>
            </div>

            <!-- Resumen -->
            <div class="grid grid-4 mb-4">
                <div class="card card-body-sm anim-up">
                    <div class="eyebrow">Total registradas</div>
                    <div class="stat-value mt-1">${zonas.size()}</div>
                </div>
                <div class="card card-body-sm anim-up d-1">
                    <div class="eyebrow">Rutas disponibles</div>
                    <div class="stat-value mt-1">${rutas.size()}</div>
                </div>
                <div class="card card-body-sm anim-up d-2">
                    <div class="eyebrow">Estaciones</div>
                    <div class="stat-value mt-1">${estaciones.size()}</div>
                </div>
                <div class="card card-body-sm anim-up d-3">
                    <div class="eyebrow">Categorías activas</div>
                    <div class="stat-value mt-1">${categorias.size()}</div>
                </div>
            </div>

            <!-- Filtro en vivo -->
            <div class="filterbar mb-4 anim-up d-2">
                <div class="field grow">
                    <div class="input-icon">
                        <span class="mi mi-sm">search</span>
                        <input class="input" type="search" placeholder="Buscar por nombre, estación o categoría…"
                               data-filter-target="#tabla-zonas" data-filter-empty="#sin-resultados">
                    </div>
                </div>
                <span class="chip chip-outline">
                    <span class="mi mi-sm">filter_alt</span> Filtro en vivo
                </span>
            </div>

            <!-- Tabla -->
            <div class="card anim-up d-3">
                <div class="card-head">
                    <h3>Zonas registradas</h3>
                    <span class="soft" style="font-size:.82rem">
                        Despliega una fila para ver su ruta, su descripción completa y sus categorías.
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty zonas}">
                        <div class="empty">
                            <span class="mi">landscape</span>
                            <h4>Aún no hay zonas turísticas</h4>
                            <p class="muted">Registra la primera zona para que aparezca en el portal público.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="data" id="tabla-zonas">
                                <thead>
                                    <tr>
                                        <th style="width:52px"></th>
                                        <th>Zona turística</th>
                                        <th>Estación · Ruta</th>
                                        <th>Categorías</th>
                                        <th>Estado</th>
                                        <th class="text-right" style="width:150px">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="z" items="${zonas}">

                                    <%-- Lista de códigos de categoría para precargar el modal --%>
                                    <c:set var="catIds" value="" />
                                    <c:forEach var="cat" items="${z.categorias}" varStatus="s">
                                        <c:set var="catIds" value="${catIds}${s.first ? '' : ','}${cat.codigo}" />
                                    </c:forEach>

                                    <tr class="main-row">
                                        <td>
                                            <button type="button" class="expander" data-expand
                                                    aria-expanded="false" aria-controls="det-zona-${z.codigo}"
                                                    aria-label="Ver detalle de ${z.nombre}">
                                                <span class="mi">expand_more</span>
                                            </button>
                                        </td>
                                        <td>
                                            <div class="row center g-3">
                                                <img data-fallback data-seed="${z.codigo}" alt="${z.nombre}"
                                                     style="width:52px;height:40px;object-fit:cover;border-radius:var(--r-xs);flex-shrink:0"
                                                     <c:if test="${not empty z.imagen}">src="${mtc:foto(z.imagen, ctx)}"</c:if>>
                                                <div style="min-width:0">
                                                    <div class="cell-strong">${z.nombre}</div>
                                                    <div class="soft" style="font-size:.79rem">
                                                        ${empty z.ubicacion ? 'Sin referencia' : z.ubicacion}
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div>${z.estacion.nombre}</div>
                                            <div class="soft" style="font-size:.79rem">${z.ruta.nombre}</div>
                                        </td>
                                        <td>
                                            <div class="row g-1 wrap-flex">
                                                <c:forEach var="cat" items="${z.categorias}" end="1">
                                                    <span class="chip chip-categoria" style="--cat:${cat.color}">
                                                        <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                                    </span>
                                                </c:forEach>
                                                <c:if test="${z.categorias.size() gt 2}">
                                                    <span class="chip chip-outline">
                                                        +${z.categorias.size() - 2}
                                                    </span>
                                                </c:if>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${z.estado}">
                                                    <span class="chip chip-success"><i class="dot"></i>Activo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="chip chip-outline"><i class="dot"></i>Oculto</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="actions">
                                                <a href="${ctx}/zona/${z.codigo}" target="_blank"
                                                   class="btn-icon btn-icon-sm" title="Ver en el portal">
                                                    <span class="mi mi-sm">open_in_new</span>
                                                </a>

                                                <button type="button" class="btn-icon btn-icon-sm accent"
                                                        title="Editar"
                                                        data-modal-open="modal-zona"
                                                        data-modal-title="Editar zona turística"
                                                        data-modal-sub="${z.nombre}"
                                                        data-set-codigo="${z.codigo}"
                                                        data-set-nombre="<c:out value='${z.nombre}'/>"
                                                        data-set-descripcion="<c:out value='${z.descripcion}'/>"
                                                        data-set-ubicacion="<c:out value='${z.ubicacion}'/>"
                                                        data-set-imagen="<c:out value='${z.imagen}'/>"
                                                        data-set-costoReferencial="${z.costoReferencial}"
                                                        data-set-estacionCodigo="${z.estacion.codigo}"
                                                        data-set-rutaCodigo="${z.ruta.codigo}"
                                                        data-set-categorias="${catIds}"
                                                        data-set-estado="${z.estado}">
                                                    <span class="mi mi-sm">edit</span>
                                                </button>

                                                <form method="post" action="${ctx}/panel/zonas/estado"
                                                      style="display:inline">
                                                    <input type="hidden" name="codigo" value="${z.codigo}">
                                                    <button type="submit" class="btn-icon btn-icon-sm"
                                                            title="${z.estado ? 'Ocultar del portal' : 'Publicar en el portal'}">
                                                        <span class="mi mi-sm">
                                                            ${z.estado ? 'visibility_off' : 'visibility'}
                                                        </span>
                                                    </button>
                                                </form>

                                                <button type="button" class="btn-icon btn-icon-sm danger"
                                                        title="Eliminar"
                                                        data-modal-open="modal-eliminar-zona"
                                                        data-set-codigo="${z.codigo}"
                                                        data-set-nombreZona="<c:out value='${z.nombre}'/>"
                                                        data-set-estacionZona="<c:out value='${z.estacion.nombre}'/>">
                                                    <span class="mi mi-sm">delete</span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>

                                    <!-- Fila desplegable con el detalle completo -->
                                    <tr class="detail-row" id="det-zona-${z.codigo}">
                                        <td colspan="6">
                                            <div class="detail-inner">
                                                <div class="detail-clip">
                                                    <div class="detail-pad">
                                                        <div class="grid grid-2 g-5">

                                                            <div>
                                                                <div class="eyebrow mb-2">Descripción</div>
                                                                <p style="margin:0">
                                                                    ${empty z.descripcion
                                                                        ? 'Sin descripción registrada.' : z.descripcion}
                                                                </p>

                                                                <div class="eyebrow mt-4 mb-2">Categorías asignadas</div>
                                                                <div class="row g-1 wrap-flex">
                                                                    <c:forEach var="cat" items="${z.categorias}">
                                                                        <span class="chip chip-categoria" style="--cat:${cat.color}">
                                                                            <span class="mi mi-sm">${cat.icono}</span>${cat.nombre}
                                                                        </span>
                                                                    </c:forEach>
                                                                </div>
                                                            </div>

                                                            <div>
                                                                <div class="eyebrow mb-2">Ruta caminable vinculada</div>
                                                                <div class="doc-kpis">
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Distancia (tramo)</div>
                                                                        <div class="v">${z.ruta.distanciaKm} km</div>
                                                                    </div>
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Ida y vuelta</div>
                                                                        <div class="v">${z.ruta.distanciaIdaVueltaKm} km</div>
                                                                    </div>
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Tiempo estimado</div>
                                                                        <div class="v">${z.ruta.tiempoEstimado}</div>
                                                                    </div>
                                                                    <div class="doc-kpi">
                                                                        <div class="k">Dificultad</div>
                                                                        <div class="v">${z.ruta.dificultad}</div>
                                                                    </div>
                                                                </div>

                                                                <div class="row g-4 mt-4 wrap-flex"
                                                                     style="font-size:.84rem">
                                                                    <span class="muted">
                                                                        <strong>Costo referencial:</strong>
                                                                        ${mtc:soles(z.costoReferencial)}
                                                                    </span>
                                                                    <span class="muted">
                                                                        <strong>Registrada:</strong>
                                                                        ${mtc:fecha(z.registrado)}
                                                                    </span>
                                                                    <span class="muted">
                                                                        <strong>Actualizada:</strong>
                                                                        ${mtc:fecha(z.actualizado)}
                                                                    </span>
                                                                </div>
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

                        <div class="empty hidden" id="sin-resultados">
                            <span class="mi">search_off</span>
                            <h4>Sin coincidencias</h4>
                            <p class="muted">Ninguna zona coincide con el texto buscado.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- ====================================================================
     MODAL · Alta / edición de zona turística
     ==================================================================== -->
<div class="modal" id="modal-zona" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-md">
        <form method="post" action="${ctx}/panel/zonas/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">landscape</span></div>
                <h3 data-modal-title-target>Registrar nueva zona turística</h3>
                <p data-modal-sub-target>Complete los datos y vincúlela a una ruta</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">

                    <div class="field span-full">
                        <label for="z-nombre">Nombre de la zona turística <span class="req">*</span></label>
                        <input class="input" type="text" id="z-nombre" name="nombre" maxlength="100" required
                               data-autofocus placeholder="Ej. Conjunto Arqueológico de Ollantaytambo">
                        <span class="hint">Máximo 100 caracteres.</span>
                    </div>

                    <div class="field span-full">
                        <label for="z-desc">Descripción</label>
                        <textarea class="textarea" id="z-desc" name="descripcion" maxlength="500"
                                  placeholder="Describe el atractivo, su valor turístico y qué encontrará el visitante…"></textarea>
                        <span class="hint">Máximo 500 caracteres.</span>
                    </div>

                    <div class="field">
                        <label for="z-estacion">Estación ferroviaria <span class="req">*</span></label>
                        <select class="select" id="z-estacion" name="estacionCodigo" required
                                data-cascade-source="#z-ruta">
                            <option value="">Seleccione una estación…</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}">${e.nombre} — ${e.region}</option>
                            </c:forEach>
                        </select>
                        <span class="hint">Listado de solo lectura provisto por PeruRail.</span>
                    </div>

                    <div class="field">
                        <label for="z-ruta">Ruta caminable <span class="req">*</span></label>
                        <select class="select" id="z-ruta" name="rutaCodigo" required
                                data-base="${ctx}/api/estaciones/{codigo}/rutas">
                            <option value="">Seleccione primero una estación</option>
                        </select>
                        <span class="hint">La ruta define el tiempo y la dificultad del recorrido.</span>
                    </div>

                    <div class="field">
                        <label for="z-ubicacion">Referencia de ubicación</label>
                        <input class="input" type="text" id="z-ubicacion" name="ubicacion" maxlength="50"
                               placeholder="Ej. Centro histórico">
                    </div>

                    <div class="field">
                        <label for="z-costo">Costo referencial de ingreso (S/)</label>
                        <input class="input" type="number" id="z-costo" name="costoReferencial"
                               min="0" step="0.10" value="0" placeholder="0.00">
                        <span class="hint">Use 0 si el ingreso es libre.</span>
                    </div>

                    <div class="field span-full">
                        <label for="z-imagen">URL de la fotografía</label>
                        <input class="input" type="url" id="z-imagen" name="imagen" maxlength="400"
                               placeholder="https://…">
                        <span class="hint">Opcional. Si se deja vacía, la plataforma genera una portada.</span>
                    </div>

                    <div class="field span-full">
                        <label>Categorías de preferencia <span class="req">*</span></label>
                        <div class="pref-grid">
                            <c:forEach var="cat" items="${categorias}">
                                <label class="pref">
                                    <input type="checkbox" name="categorias" value="${cat.codigo}" data-multi>
                                    <span class="pref-icon" style="--cat:${cat.color}">
                                        <span class="mi">${cat.icono}</span>
                                    </span>
                                    <span class="pref-name">${cat.nombre}</span>
                                </label>
                            </c:forEach>
                        </div>
                        <span class="hint">Seleccione al menos una. Definen cómo se filtra la zona
                            según las preferencias del turista.</span>
                    </div>

                    <div class="field span-full">
                        <label class="switch">
                            <input type="checkbox" name="estado" value="true" checked>
                            <span class="track"></span>
                            <span class="switch-label">Publicar en el portal público</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar cambios
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ====================================================================
     MODAL · Confirmación de eliminación
     ==================================================================== -->
<div class="modal" id="modal-eliminar-zona" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/zonas/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar zona turística?</h3>
                <p>Esta acción no se puede deshacer</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>
                        La zona se retirará definitivamente del listado disponible para los usuarios
                        finales y dejará de aparecer en las consultas y en los informes.
                    </div>
                </div>

                <div class="confirm-target">
                    <div class="eyebrow">Zona seleccionada</div>
                    <div class="cell-strong mt-1" data-field="nombreZona">—</div>
                    <div class="soft" style="font-size:.83rem" data-field="estacionZona">—</div>
                </div>

                <p class="soft mt-3" style="font-size:.82rem">
                    Si solo deseas ocultarla temporalmente, usa el botón de visibilidad en la tabla
                    en lugar de eliminarla.
                </p>
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

<jsp:include page="../shared/scripts.jsp" />
<script>
    /* Al abrir el modal en modo edición, precarga la ruta que ya tenía la zona. */
    document.addEventListener('click', function (ev) {
        var b = ev.target.closest('[data-modal-open="modal-zona"]');
        if (!b) { return; }
        var ruta = b.getAttribute('data-set-rutaCodigo') || '';
        var selRuta = document.getElementById('z-ruta');
        selRuta.dataset.preseleccion = ruta;
        if (!ruta) {
            selRuta.innerHTML = '<option value="">Seleccione primero una estación</option>';
        }
    }, true);

    /* Abre el modal automáticamente si se llegó desde "Nueva zona" del panel. */
    <c:if test="${param.nueva eq '1'}">
    document.addEventListener('DOMContentLoaded', function () {
        MTC.modal.abrir('modal-zona');
    });
    </c:if>
</script>
</body>
</html>
