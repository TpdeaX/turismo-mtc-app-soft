<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="ferroviario" scope="request" />
<c:set var="tituloModulo" value="Horarios y precios" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Horarios y Precios Ferroviarios · MTC Perú</title>
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
                    <h1 class="mt-2">Horarios y Precios Ferroviarios</h1>
                    <p>Gestión de frecuencias, tiempos de recorrido y tarifas para el servicio
                        interprovincial y turístico de trenes.</p>
                </div>
                <div class="row g-2 wrap-flex">
                    <button type="button" class="btn btn-outline" data-modal-open="modal-tarifas">
                        <span class="mi mi-sm">payments</span> Ajustar tarifas
                    </button>
                    <button type="button" class="btn btn-outline" data-modal-open="modal-servicio"
                            data-modal-title="Registrar nuevo servicio"
                            data-modal-sub="Define el trayecto entre dos estaciones"
                            data-set-codigo="" data-set-nombre="" data-set-corredor=""
                            data-set-estado="ACTIVO">
                        <span class="mi mi-sm">add_road</span> Nuevo servicio
                    </button>
                    <button type="button" class="btn btn-primary" data-modal-open="modal-horario"
                            data-modal-title="Programar nuevo horario"
                            data-modal-sub="Salida, llegada y tarifa del servicio"
                            data-set-codigo="" data-set-horasalida="" data-set-horallegada=""
                            data-set-tarifa="" data-set-frecuencia="Diario" data-set-estado="ACTIVO">
                        <span class="mi mi-sm">more_time</span> Nuevo horario
                    </button>
                </div>
            </div>

            <!-- Corredores -->
            <c:if test="${not empty corredores}">
                <div class="mb-4 anim-up">
                    <div class="segmented">
                        <a href="${ctx}/panel/ferroviario"
                           class="${empty corredorActivo ? 'active' : ''}">Todos los corredores</a>
                        <c:forEach var="co" items="${corredores}">
                            <a href="${ctx}/panel/ferroviario?corredor=${co}"
                               class="${corredorActivo eq co ? 'active' : ''}">${co}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <div class="filterbar mb-4 anim-up d-1">
                <div class="field grow">
                    <div class="input-icon">
                        <span class="mi mi-sm">search</span>
                        <input class="input" type="search" placeholder="Buscar tren, estación o corredor…"
                               data-filter-target="#tabla-servicios" data-filter-empty="#sin-servicios">
                    </div>
                </div>
                <span class="chip chip-outline">
                    <span class="mi mi-sm">train</span> ${servicios.size()} servicios
                </span>
                <span class="chip chip-outline">
                    <span class="mi mi-sm">schedule</span> ${horarios.size()} horarios
                </span>
            </div>

            <!-- ==================== SERVICIOS con horarios desplegables ==================== -->
            <div class="card anim-up d-2 mb-5">
                <div class="card-head">
                    <h3>Servicios ferroviarios</h3>
                    <span class="soft" style="font-size:.82rem">
                        Despliega un servicio para administrar sus horarios y tarifas.
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty servicios}">
                        <div class="empty">
                            <span class="mi">train</span>
                            <h4>Sin servicios registrados</h4>
                            <p class="muted">Sincroniza con PeruRail o registra un servicio manualmente.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="data" id="tabla-servicios">
                                <thead>
                                    <tr>
                                        <th style="width:52px"></th>
                                        <th>Servicio</th>
                                        <th>Trayecto</th>
                                        <th>Corredor</th>
                                        <th>Horarios</th>
                                        <th>Estado</th>
                                        <th class="text-right" style="width:120px">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="s" items="${servicios}">
                                    <c:if test="${empty corredorActivo or corredorActivo eq s.corredor}">

                                    <tr class="main-row">
                                        <td>
                                            <button type="button" class="expander" data-expand
                                                    aria-expanded="false" aria-controls="det-srv-${s.codigo}"
                                                    aria-label="Ver horarios de ${s.nombre}">
                                                <span class="mi">expand_more</span>
                                            </button>
                                        </td>
                                        <td>
                                            <div class="row center g-3">
                                                <span class="stat-icon stat-icon-sm">
                                                    <span class="mi mi-sm">tram</span>
                                                </span>
                                                <span class="cell-strong">${s.nombre}</span>
                                            </div>
                                        </td>
                                        <td class="muted">${s.trayecto}</td>
                                        <td><span class="chip chip-outline">${s.corredor}</span></td>
                                        <td>
                                            <span class="chip chip-info">
                                                ${s.horarios.size()} programado(s)
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${s.estado eq 'ACTIVO'}">
                                                    <span class="chip chip-success"><i class="dot"></i>Activo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="chip chip-warning"><i class="dot"></i>Retraso</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="actions">
                                                <button type="button" class="btn-icon btn-icon-sm"
                                                        title="Agregar horario a este servicio"
                                                        data-modal-open="modal-horario"
                                                        data-modal-title="Nuevo horario"
                                                        data-modal-sub="${s.nombre} · ${s.trayecto}"
                                                        data-set-codigo=""
                                                        data-set-serviciocodigo="${s.codigo}"
                                                        data-set-horasalida="" data-set-horallegada=""
                                                        data-set-tarifa="" data-set-frecuencia="Diario"
                                                        data-set-estado="ACTIVO">
                                                    <span class="mi mi-sm">more_time</span>
                                                </button>
                                                <button type="button" class="btn-icon btn-icon-sm accent"
                                                        title="Editar servicio"
                                                        data-modal-open="modal-servicio"
                                                        data-modal-title="Editar servicio ferroviario"
                                                        data-modal-sub="${s.nombre}"
                                                        data-set-codigo="${s.codigo}"
                                                        data-set-nombre="<c:out value='${s.nombre}'/>"
                                                        data-set-origencodigo="${s.origen.codigo}"
                                                        data-set-destinocodigo="${s.destino.codigo}"
                                                        data-set-corredor="<c:out value='${s.corredor}'/>"
                                                        data-set-estado="${s.estado}">
                                                    <span class="mi mi-sm">edit</span>
                                                </button>
                                                <button type="button" class="btn-icon btn-icon-sm danger"
                                                        title="Eliminar servicio"
                                                        data-modal-open="modal-eliminar-servicio"
                                                        data-set-codigo="${s.codigo}"
                                                        data-set-nombreservicio="<c:out value='${s.nombre}'/>"
                                                        data-set-trayectoservicio="<c:out value='${s.trayecto}'/>">
                                                    <span class="mi mi-sm">delete</span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>

                                    <!-- Horarios del servicio -->
                                    <tr class="detail-row" id="det-srv-${s.codigo}">
                                        <td colspan="7">
                                            <div class="detail-inner">
                                                <div class="detail-clip">
                                                    <div class="detail-pad">
                                                        <div class="row between center wrap-flex g-3 mb-3">
                                                            <div class="eyebrow">
                                                                Horarios, tiempos de recorrido y tarifas
                                                            </div>
                                                            <button type="button" class="btn btn-outline btn-sm"
                                                                    data-modal-open="modal-horario"
                                                                    data-modal-title="Nuevo horario"
                                                                    data-modal-sub="${s.nombre}"
                                                                    data-set-codigo=""
                                                                    data-set-serviciocodigo="${s.codigo}"
                                                                    data-set-horasalida="" data-set-horallegada=""
                                                                    data-set-tarifa="" data-set-frecuencia="Diario"
                                                                    data-set-estado="ACTIVO">
                                                                <span class="mi mi-sm">add</span> Agregar horario
                                                            </button>
                                                        </div>

                                                        <c:choose>
                                                            <c:when test="${empty s.horarios}">
                                                                <p class="soft" style="margin:0">
                                                                    Este servicio aún no tiene horarios programados.
                                                                </p>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="table-wrap"
                                                                     style="border:1px solid var(--c-border);border-radius:var(--r-md);background:var(--c-surface)">
                                                                    <table class="data">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Salida</th>
                                                                                <th>Llegada</th>
                                                                                <th>Duración</th>
                                                                                <th>Frecuencia</th>
                                                                                <th>Tarifa</th>
                                                                                <th>Estado</th>
                                                                                <th class="text-right">Acciones</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                        <c:forEach var="h" items="${s.horarios}">
                                                                            <tr>
                                                                                <td class="mono cell-strong">
                                                                                    ${mtc:hora(h.horaSalida)}</td>
                                                                                <td class="mono">
                                                                                    ${mtc:hora(h.horaLlegada)}</td>
                                                                                <td>${h.duracionTexto}</td>
                                                                                <td class="muted">${h.frecuencia}</td>
                                                                                <td>
                                                                                    <span class="chip chip-accent">
                                                                                        ${mtc:soles(h.tarifa)}</span>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${h.estado eq 'ACTIVO'}">
                                                                                            <span class="chip chip-success">
                                                                                                <i class="dot"></i>Activo</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span class="chip chip-warning">
                                                                                                <i class="dot"></i>${h.estado}</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <div class="actions">
                                                                                        <button type="button"
                                                                                                class="btn-icon btn-icon-sm accent"
                                                                                                title="Editar horario"
                                                                                                data-modal-open="modal-horario"
                                                                                                data-modal-title="Editar horario"
                                                                                                data-modal-sub="${s.nombre} · ${mtc:hora(h.horaSalida)}"
                                                                                                data-set-codigo="${h.codigo}"
                                                                                                data-set-serviciocodigo="${s.codigo}"
                                                                                                data-set-horasalida="${h.horaSalida}"
                                                                                                data-set-horallegada="${h.horaLlegada}"
                                                                                                data-set-tarifa="${h.tarifa}"
                                                                                                data-set-frecuencia="<c:out value='${h.frecuencia}'/>"
                                                                                                data-set-estado="${h.estado}">
                                                                                            <span class="mi mi-sm">edit</span>
                                                                                        </button>
                                                                                        <button type="button"
                                                                                                class="btn-icon btn-icon-sm danger"
                                                                                                title="Eliminar horario"
                                                                                                data-modal-open="modal-eliminar-horario"
                                                                                                data-set-codigo="${h.codigo}"
                                                                                                data-set-horarioinfo="${s.nombre} · salida ${mtc:hora(h.horaSalida)}"
                                                                                                data-set-horariotarifa="Tarifa ${mtc:soles(h.tarifa)}">
                                                                                            <span class="mi mi-sm">delete</span>
                                                                                        </button>
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
                                        </td>
                                    </tr>
                                    </c:if>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="empty hidden" id="sin-servicios">
                            <span class="mi">search_off</span>
                            <h4>Sin coincidencias</h4>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL · Servicio ==================== -->
<div class="modal" id="modal-servicio" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/servicios/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">tram</span></div>
                <h3 data-modal-title-target>Registrar nuevo servicio</h3>
                <p data-modal-sub-target>Define el trayecto entre dos estaciones</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="s-nombre">Nombre del servicio <span class="req">*</span></label>
                        <input class="input" type="text" id="s-nombre" name="nombre" maxlength="50" required
                               data-autofocus placeholder="Ej. Vistadome 31">
                    </div>

                    <div class="field">
                        <label for="s-origen">Estación de origen <span class="req">*</span></label>
                        <select class="select" id="s-origen" name="origenCodigo" required>
                            <option value="">Seleccione…</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}">${e.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="field">
                        <label for="s-destino">Estación de destino <span class="req">*</span></label>
                        <select class="select" id="s-destino" name="destinoCodigo" required>
                            <option value="">Seleccione…</option>
                            <c:forEach var="e" items="${estaciones}">
                                <option value="${e.codigo}">${e.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="field">
                        <label for="s-corredor">Corredor</label>
                        <input class="input" type="text" id="s-corredor" name="corredor" maxlength="50"
                               list="lista-corredores" placeholder="Ej. Cusco - Machupicchu">
                        <datalist id="lista-corredores">
                            <c:forEach var="co" items="${corredores}">
                                <option value="${co}"></option>
                            </c:forEach>
                        </datalist>
                    </div>

                    <div class="field">
                        <label for="s-estado">Estado operativo</label>
                        <select class="select" id="s-estado" name="estado">
                            <option value="ACTIVO">Activo</option>
                            <option value="RETRASO">Con retraso</option>
                            <option value="SUSPENDIDO">Suspendido</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar servicio
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== MODAL · Horario ==================== -->
<div class="modal" id="modal-horario" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/horarios/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">schedule</span></div>
                <h3 data-modal-title-target>Programar nuevo horario</h3>
                <p data-modal-sub-target>Salida, llegada y tarifa del servicio</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="h-servicio">Servicio ferroviario <span class="req">*</span></label>
                        <select class="select" id="h-servicio" name="servicioCodigo" required>
                            <option value="">Seleccione un servicio…</option>
                            <c:forEach var="s" items="${servicios}">
                                <option value="${s.codigo}">${s.nombre} — ${s.trayecto}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="field">
                        <label for="h-salida">Hora de salida <span class="req">*</span></label>
                        <input class="input" type="time" id="h-salida" name="horaSalida" required>
                    </div>

                    <div class="field">
                        <label for="h-llegada">Hora de llegada <span class="req">*</span></label>
                        <input class="input" type="time" id="h-llegada" name="horaLlegada" required>
                        <span class="hint">El tiempo de recorrido se calcula solo.</span>
                    </div>

                    <div class="field">
                        <label for="h-tarifa">Tarifa (S/) <span class="req">*</span></label>
                        <input class="input" type="number" id="h-tarifa" name="tarifa"
                               min="0" step="0.10" required placeholder="245.00">
                    </div>

                    <div class="field">
                        <label for="h-frecuencia">Frecuencia</label>
                        <input class="input" type="text" id="h-frecuencia" name="frecuencia" maxlength="50"
                               list="lista-frecuencias" value="Diario">
                        <datalist id="lista-frecuencias">
                            <option value="Diario"></option>
                            <option value="Lun - Sáb"></option>
                            <option value="Lun - Vie"></option>
                            <option value="Mar, Jue, Dom"></option>
                            <option value="Mié, Sáb"></option>
                            <option value="Fines de semana"></option>
                        </datalist>
                    </div>

                    <div class="field span-full">
                        <label for="h-estado">Estado</label>
                        <select class="select" id="h-estado" name="estado">
                            <option value="ACTIVO">Activo</option>
                            <option value="RETRASO">Con retraso</option>
                            <option value="SUSPENDIDO">Suspendido</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar horario
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== MODAL · Ajuste masivo de tarifas ==================== -->
<div class="modal" id="modal-tarifas" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/horarios/tarifas" data-submit-once>
            <div class="modal-head accent">
                <div class="modal-icon"><span class="mi">payments</span></div>
                <h3>Ajuste masivo de tarifas</h3>
                <p>Aplica un porcentaje sobre las tarifas vigentes</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <div class="form-grid cols-2">
                    <div class="field">
                        <label for="t-corredor">Corredor</label>
                        <select class="select" id="t-corredor" name="corredor">
                            <option value="">Todos los corredores</option>
                            <c:forEach var="co" items="${corredores}">
                                <option value="${co}">${co}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label for="t-porcentaje">Porcentaje de ajuste (%) <span class="req">*</span></label>
                        <input class="input" type="number" id="t-porcentaje" name="porcentaje"
                               step="0.5" min="-90" max="200" required placeholder="5" data-autofocus>
                        <span class="hint">Usa valores negativos para descuentos.</span>
                    </div>
                </div>

                <div class="notice notice-warning mt-4">
                    <span class="mi mi-sm">warning</span>
                    <div>
                        <div class="notice-title">Operación masiva</div>
                        El ajuste se aplicará a todos los horarios del corredor seleccionado y quedará
                        reflejado de inmediato en el portal público.
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-accent">
                    <span class="mi mi-sm">price_change</span> Aplicar ajuste
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== MODALES · Eliminación ==================== -->
<div class="modal" id="modal-eliminar-servicio" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/servicios/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar servicio?</h3>
                <p>Esta acción no se puede deshacer</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>Solo pueden eliminarse servicios sin horarios programados.
                        Elimine primero sus horarios.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Servicio seleccionado</div>
                    <div class="cell-strong mt-1" data-field="nombreservicio">—</div>
                    <div class="soft" style="font-size:.83rem" data-field="trayectoservicio">—</div>
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

<div class="modal" id="modal-eliminar-horario" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/horarios/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar horario?</h3>
                <p>Dejará de mostrarse en el portal</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>El horario se eliminará de forma permanente y dejará de aparecer en las
                        consultas e informes del usuario final.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Horario seleccionado</div>
                    <div class="cell-strong mt-1" data-field="horarioinfo">—</div>
                    <div class="soft" style="font-size:.83rem" data-field="horariotarifa">—</div>
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
