<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="rutas" scope="request" />
<c:set var="tituloModulo" value="Rutas caminables" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Rutas caminables · ${parametros['plataforma.nombre']}</title>
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
                    <h1 class="mt-2">Rutas Caminables</h1>
                    <p>Tramos peatonales de ida y vuelta que parten y retornan a la misma estación.
                        El tiempo estimado se calcula automáticamente a partir de la distancia y la dificultad.</p>
                </div>
                <button type="button" class="btn btn-primary btn-lg"
                        data-modal-open="modal-ruta"
                        data-modal-title="Registrar nueva ruta"
                        data-modal-sub="Define el tramo peatonal desde una estación"
                        data-set-codigo=""
                        data-set-nombre=""
                        data-set-distanciakm=""
                        data-set-dificultad="Fácil">
                    <span class="mi mi-sm">add_road</span> Nueva ruta
                </button>
            </div>

            <div class="notice notice-info mb-4 anim-up">
                <span class="mi mi-sm">function</span>
                <div>
                    <div class="notice-title">Cómo se calcula el tiempo estimado</div>
                    Distancia de ida y vuelta ÷ velocidad de caminata
                    (<strong>${velocidad} km/h</strong>, configurable en Parámetros generales),
                    con un recargo del 15 % en rutas moderadas y del 35 % en rutas de dificultad alta.
                </div>
            </div>

            <div class="filterbar mb-4 anim-up d-1">
                <div class="field grow">
                    <div class="input-icon">
                        <span class="mi mi-sm">search</span>
                        <input class="input" type="search" placeholder="Buscar por ruta, estación o dificultad…"
                               data-filter-target="#tabla-rutas" data-filter-empty="#sin-rutas">
                    </div>
                </div>
            </div>

            <div class="card anim-up d-2">
                <div class="card-head">
                    <h3>Rutas registradas</h3>
                    <span class="chip chip-outline">${rutas.size()} rutas</span>
                </div>

                <c:choose>
                    <c:when test="${empty rutas}">
                        <div class="empty">
                            <span class="mi">route</span>
                            <h4>Aún no hay rutas caminables</h4>
                            <p class="muted">Registra una ruta antes de vincular zonas turísticas.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="data" id="tabla-rutas">
                                <thead>
                                    <tr>
                                        <th style="width:52px"></th>
                                        <th>Ruta</th>
                                        <th>Estación de partida</th>
                                        <th>Tramo</th>
                                        <th>Ida y vuelta</th>
                                        <th>Tiempo</th>
                                        <th>Dificultad</th>
                                        <th class="text-right" style="width:110px">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${rutas}">
                                        <tr class="main-row">
                                            <td>
                                                <button type="button" class="expander" data-expand
                                                        aria-expanded="false" aria-controls="det-ruta-${r.codigo}"
                                                        aria-label="Ver zonas de la ruta">
                                                    <span class="mi">expand_more</span>
                                                </button>
                                            </td>
                                            <td class="cell-strong">${r.nombre}</td>
                                            <td>
                                                <div>${r.estacion.nombre}</div>
                                                <div class="soft" style="font-size:.79rem">${r.estacion.region}</div>
                                            </td>
                                            <td class="mono">${r.distanciaKm} km</td>
                                            <td class="mono cell-strong">${r.distanciaIdaVueltaKm} km</td>
                                            <td>${r.tiempoEstimado}</td>
                                            <td>
                                                <div class="row center g-2">
                                                    <span class="difficulty"
                                                          data-level="${r.dificultad eq 'Alta' ? 3 : (r.dificultad eq 'Moderada' ? 2 : 1)}">
                                                        <i></i><i></i><i></i>
                                                    </span>
                                                    <span>${r.dificultad}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="actions">
                                                    <button type="button" class="btn-icon btn-icon-sm accent"
                                                            title="Editar"
                                                            data-modal-open="modal-ruta"
                                                            data-modal-title="Editar ruta caminable"
                                                            data-modal-sub="${r.nombre}"
                                                            data-set-codigo="${r.codigo}"
                                                            data-set-nombre="<c:out value='${r.nombre}'/>"
                                                            data-set-estacioncodigo="${r.estacion.codigo}"
                                                            data-set-distanciakm="${r.distanciaKm}"
                                                            data-set-dificultad="${r.dificultad}">
                                                        <span class="mi mi-sm">edit</span>
                                                    </button>
                                                    <button type="button" class="btn-icon btn-icon-sm danger"
                                                            title="Eliminar"
                                                            data-modal-open="modal-eliminar-ruta"
                                                            data-set-codigo="${r.codigo}"
                                                            data-set-nombreruta="<c:out value='${r.nombre}'/>"
                                                            data-set-zonasruta="${r.zonas.size()} zona(s) vinculada(s)">
                                                        <span class="mi mi-sm">delete</span>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr class="detail-row" id="det-ruta-${r.codigo}">
                                            <td colspan="8">
                                                <div class="detail-inner">
                                                    <div class="detail-clip">
                                                        <div class="detail-pad">
                                                            <div class="eyebrow mb-3">
                                                                Zonas turísticas vinculadas a esta ruta
                                                            </div>
                                                            <c:choose>
                                                                <c:when test="${empty r.zonas}">
                                                                    <p class="soft" style="margin:0">
                                                                        Esta ruta aún no tiene zonas turísticas asociadas.
                                                                    </p>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="grid grid-3">
                                                                        <c:forEach var="z" items="${r.zonas}">
                                                                            <div class="card card-body-sm">
                                                                                <div class="row between center g-2">
                                                                                    <span class="cell-strong">${z.nombre}</span>
                                                                                    <span class="chip ${z.estado ? 'chip-success' : 'chip-outline'}">
                                                                                        <i class="dot"></i>${z.estado ? 'Activa' : 'Oculta'}
                                                                                    </span>
                                                                                </div>
                                                                                <div class="soft mt-1" style="font-size:.8rem">
                                                                                    ${z.categoriasTexto}
                                                                                </div>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="empty hidden" id="sin-rutas">
                            <span class="mi">search_off</span>
                            <h4>Sin coincidencias</h4>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- MODAL · Alta / edición de ruta -->
<div class="modal" id="modal-ruta" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/rutas/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">route</span></div>
                <h3 data-modal-title-target>Registrar nueva ruta</h3>
                <p data-modal-sub-target>Define el tramo peatonal desde una estación</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="r-nombre">Nombre de la ruta <span class="req">*</span></label>
                        <input class="input" type="text" id="r-nombre" name="nombre" maxlength="100" required
                               data-autofocus placeholder="Ej. Sendero Jardín de Mandor">
                    </div>

                    <div class="field span-full">
                        <label for="r-estacion">Estación de partida y retorno <span class="req">*</span></label>
                        <select class="select" id="r-estacion" name="estacionCodigo" required>
                            <option value="">Seleccione una estación…</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}">${e.nombre} — ${e.region}</option>
                            </c:forEach>
                        </select>
                        <span class="hint">La ruta parte y retorna a esta misma estación.</span>
                    </div>

                    <div class="field">
                        <label for="r-distancia">Distancia del tramo (km) <span class="req">*</span></label>
                        <input class="input" type="number" id="r-distancia" name="distanciaKm"
                               min="0.1" max="25" step="0.01" required placeholder="2.50">
                        <span class="hint">Solo de ida. El sistema duplica el valor para el retorno.</span>
                    </div>

                    <div class="field">
                        <label for="r-dificultad">Dificultad <span class="req">*</span></label>
                        <select class="select" id="r-dificultad" name="dificultad" required>
                            <option value="Fácil">Fácil</option>
                            <option value="Moderada">Moderada</option>
                            <option value="Alta">Alta</option>
                        </select>
                        <span class="hint">Ajusta el recargo de tiempo por pendiente.</span>
                    </div>
                </div>

                <div class="notice notice-info mt-4">
                    <span class="mi mi-sm">directions_walk</span>
                    <div>El tiempo estimado no se ingresa manualmente: la plataforma lo recalcula
                        cada vez que guardas la ruta.</div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar ruta
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL · Eliminar ruta -->
<div class="modal" id="modal-eliminar-ruta" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/rutas/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar ruta?</h3>
                <p>Esta acción no se puede deshacer</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>Solo es posible eliminar rutas que no tengan zonas turísticas vinculadas.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Ruta seleccionada</div>
                    <div class="cell-strong mt-1" data-field="nombreruta">—</div>
                    <div class="soft" style="font-size:.83rem" data-field="zonasruta">—</div>
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

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
