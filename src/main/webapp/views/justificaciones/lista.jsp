<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Justificaciones | Grupo Peruana</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <!-- Material Web Components -->
    <script type="importmap">
    {
      "imports": {
        "@material/web/": "https://esm.run/@material/web/"
      }
    }
    </script>
    <script type="module">
        import '@material/web/all.js';
        import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
        document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

    <style>
        /* Specific page overrides */
        .page-header {
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 24px;
        }

        /* Card enhancement for table */
        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
        }

        /* Status colors override for chips or text */
        .status-pendiente { color: #f57c00; font-weight: 500; background: #fff8e1; padding: 4px 12px; border-radius: 8px; border: 1px solid #ffe082; display: inline-flex; align-items: center; gap: 4px; }
        .status-aceptada { color: var(--md-sys-color-on-success-container); font-weight: 500; background: var(--md-sys-color-success-container); padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; }
        .status-rechazada { color: var(--md-sys-color-on-error-container); font-weight: 500; background: var(--md-sys-color-error-container); padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; }

        [data-theme="dark"] .status-pendiente { background: #5c4200; color: #ffca28; border-color: #6f5500; }
        
        /* Table Action Buttons container */
        .actions-cell {
            display: flex;
            gap: 4px;
        }
    </style>
</head>
<body>

    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/console-warning.jsp" />
    
    <%-- Conditional Layout based on role --%>
    <c:choose>
        <c:when test="${sessionScope.usuario.rol == 'ADMIN' || sessionScope.usuario.rol == 'JEFE'}">
            <jsp:include page="../shared/sidebar.jsp" />
            <div class="main-content">
                <jsp:include page="../shared/header.jsp" />
                <div class="container">
            
            <!-- Alerts -->

            
            <div class="page-header" style="gap: 16px; flex-wrap: wrap;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Justificaciones</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Gestiona incidencias y permisos</p>
                </div>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <md-outlined-button type="button" onclick="exportarExcel()">
                        <md-icon slot="icon">grid_on</md-icon>
                        Exportar a Excel
                    </md-outlined-button>
                    <md-filled-tonal-button type="button" onclick="exportarPdf()">
                        <md-icon slot="icon">picture_as_pdf</md-icon>
                        Exportar a PDF
                    </md-filled-tonal-button>
                    <c:if test="${sessionScope.usuario.rol != 'JEFE' && sessionScope.usuario.rol != 'ADMIN'}">
                        <md-filled-button href="${pageContext.request.contextPath}/justificaciones/nuevo" onclick="window.location.href='${pageContext.request.contextPath}/justificaciones/nuevo'">
                            <md-icon slot="icon">add</md-icon>
                            Nueva Solicitud
                        </md-filled-button>
                    </c:if>
                </div>
            </div>

            <!-- Advanced Filter Form -->
            <div class="card" style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface); animation: fade-in-down 0.5s ease-out;">
                <form id="filterForm" action="${pageContext.request.contextPath}/justificaciones" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; align-items: start;">
                        
                        <!-- Search (Spans 2 columns) -->
                        <div style="grid-column: span 2;">
                            <md-outlined-text-field 
                                label="Buscar" 
                                name="keyword" 
                                value="${keyword}"
                                placeholder="Nombre, DNI..." 
                                style="width: 100%;">
                                <md-icon slot="leading-icon">search</md-icon>
                            </md-outlined-text-field>
                        </div>

                        <!-- Estado (Spans 1 column) -->
                        <div>
                            <md-outlined-select label="Estado" name="estado" style="width: 100%;">
                                <md-select-option value="" ${empty estado ? 'selected' : ''}>
                                    <div slot="headline">Todos</div>
                                </md-select-option>
                                <md-select-option value="PENDIENTE" ${estado == 'PENDIENTE' ? 'selected' : ''}>
                                    <div slot="headline">Pendiente</div>
                                    <md-icon slot="start">pending</md-icon>
                                </md-select-option>
                                <md-select-option value="ACEPTADA" ${estado == 'ACEPTADA' ? 'selected' : ''}>
                                    <div slot="headline">Aceptada</div>
                                    <md-icon slot="start">check_circle</md-icon>
                                </md-select-option>
                                <md-select-option value="RECHAZADA" ${estado == 'RECHAZADA' ? 'selected' : ''}>
                                    <div slot="headline">Rechazada</div>
                                    <md-icon slot="start">cancel</md-icon>
                                </md-select-option>
                            </md-outlined-select>
                        </div>

                        <!-- Row 2: Dates -->
                        <!-- Fecha Solicitud -->
                        <md-outlined-text-field 
                            type="date"
                            label="Fecha Solicitud" 
                            name="fechaSolicitud" 
                            value="${fechaSolicitud}"
                            style="width: 100%;">
                        </md-outlined-text-field>

                        <!-- Rango Inicio -->
                        <md-outlined-text-field 
                            type="date"
                            label="Periodo Desde" 
                            name="fechaInicio" 
                            value="${fechaInicio}"
                            style="width: 100%;">
                        </md-outlined-text-field>

                        <!-- Rango Fin -->
                        <md-outlined-text-field 
                            type="date"
                            label="Periodo Hasta" 
                            name="fechaFin" 
                            value="${fechaFin}"
                            style="width: 100%;">
                        </md-outlined-text-field>
                    </div>

                    <input type="hidden" name="size" id="sizeInput" value="${size}">

                     <!-- Botones de Acción - New Row -->
                    <div style="grid-column: span 3; display: flex; gap: 8px; justify-content: flex-end; align-items: center; margin-top: 24px;">
                        <md-outlined-button type="button" onclick="limpiarFiltros()" style="flex: 1;">
                            Limpiar
                        </md-outlined-button>
                        <md-filled-button type="button" onclick="submitFilter()" style="flex: 1;">
                            <md-icon slot="icon">filter_list</md-icon>
                            Filtrar
                        </md-filled-button>
                    </div>

                </form>
            </div>

            <!-- Reportes Card -->


            <script>
                function submitFilter() {
                    document.getElementById('pageInput').value = 0; 
                    document.getElementById('filterForm').submit();
                }

                function limpiarFiltros() {
                    // Reset text fields
                    document.querySelectorAll('md-outlined-text-field').forEach(field => field.value = '');
                    // Reset select
                    const select = document.querySelector('md-outlined-select[name="estado"]');
                    if (select) select.selectIndex(0); // Select 'Todos'
                    
                    submitFilter();
                }

                function changePage(page) {
                    document.getElementById('pageInput').value = page;
                    document.getElementById('filterForm').submit();
                }

                function changeSize(size) {
                    document.getElementById('sizeInput').value = size;
                    document.getElementById('pageInput').value = 0;
                    document.getElementById('filterForm').submit();
                }

                function exportarExcel() {
                    const form = document.getElementById('filterForm');
                    const originalAction = form.action;
                    form.action = '${pageContext.request.contextPath}/justificaciones/export/excel';
                    form.submit();
                    setTimeout(() => { form.action = originalAction; }, 500);
                }

                function exportarPdf() {
                    const form = document.getElementById('filterForm');
                    const originalAction = form.action;
                    form.action = '${pageContext.request.contextPath}/justificaciones/export/pdf';
                    form.submit();
                    setTimeout(() => { form.action = originalAction; }, 500);
                }
            </script>

            <style>
                @keyframes fade-in-down {
                    from { opacity: 0; transform: translateY(-10px); }
                    to { opacity: 1; transform: translateY(0); }
                }

                @keyframes slide-in-up {
                    from { opacity: 0; transform: translateY(20px); }
                    to { opacity: 1; transform: translateY(0); }
                }

                /* Staggered Animation for Table Rows */
                tbody tr {
                    opacity: 0;
                    animation: slide-in-up 0.4s ease-out forwards;
                }
                
                tbody tr:nth-child(1) { animation-delay: 0.05s; }
                tbody tr:nth-child(2) { animation-delay: 0.1s; }
                tbody tr:nth-child(3) { animation-delay: 0.15s; }
                tbody tr:nth-child(4) { animation-delay: 0.2s; }
                tbody tr:nth-child(5) { animation-delay: 0.25s; }
                tbody tr:nth-child(6) { animation-delay: 0.3s; }
                tbody tr:nth-child(7) { animation-delay: 0.35s; }
                tbody tr:nth-child(8) { animation-delay: 0.4s; }
                tbody tr:nth-child(9) { animation-delay: 0.45s; }
                tbody tr:nth-child(10) { animation-delay: 0.5s; }
            </style>

            <div class="card" style="animation: fade-in-down 0.6s ease-out;">
                <div class="table-container">
                    <style>
                        .compact-table th, .compact-table td {
                            padding: 12px 16px !important;
                        }
                    </style>
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th style="width: 110px;">Fecha Solicitud</th>
                                <c:if test="${sessionScope.usuario.rol == 'ADMIN'}">
                                    <th style="width: 200px;">Empleado</th>
                                </c:if>
                                <th style="width: 140px;">Detalle</th>
                                <th style="width: 180px;">Periodo</th>
                                <th style="width: 120px;">Estado</th>
                                <th style="width: 90px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="j" items="${lista}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 600; color: var(--md-sys-color-on-surface);">${j.fechaSolicitud}</div>
                                    </td>
                                    <c:if test="${sessionScope.usuario.rol == 'ADMIN'}">
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <div style="width: 36px; height: 36px; background: var(--md-sys-color-secondary-container); color: var(--md-sys-color-on-secondary-container); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700;">
                                                    ${j.empleado.nombres.substring(0,1)}
                                                </div>
                                                <div style="display: flex; flex-direction: column;">
                                                     <span style="font-weight: 500;">${j.empleado.nombres} ${j.empleado.apellidos}</span>
                                                     <span style="font-size: 0.75rem; color: var(--md-sys-color-secondary);">DNI: ${j.empleado.dni}</span>
                                                </div>
                                            </div>
                                        </td>
                                    </c:if>
                                    <td style="white-space: normal;">
                                        <md-outlined-button onclick="verDetalle('${fn:escapeXml(j.motivo)}', '${fn:escapeXml(j.comentarioAprobacion)}', '${fn:escapeXml(j.evidenciaUrl)}')" style="--md-outlined-button-container-height: 32px;">
                                            <md-icon slot="icon">visibility</md-icon>
                                            Ver
                                        </md-outlined-button>
                                    </td>
                                    <td>
                                        <div style="display: flex; flex-direction: column; gap: 4px;">
                                            <div style="display: flex; align-items: center; gap: 6px; font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant);">
                                                <span class="material-symbols-outlined" style="font-size: 18px; color: var(--md-sys-color-primary);">calendar_today</span>
                                                ${j.fechaInicio} 
                                                <c:if test="${j.fechaInicio != j.fechaFin}"> - ${j.fechaFin}</c:if>
                                            </div>
                                            <c:if test="${j.esPorHoras}">
                                                <div style="display: flex; align-items: center; gap: 6px; font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant);">
                                                    <span class="material-symbols-outlined" style="font-size: 18px; color: var(--md-sys-color-tertiary);">schedule</span>
                                                    ${j.horaInicio} - ${j.horaFin}
                                                </div>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${j.estado == 'PENDIENTE'}">
                                                <div class="status-pendiente">
                                                    <span class="material-symbols-outlined" style="font-size: 16px;">pending</span> Pendiente
                                                </div>
                                            </c:when>
                                            <c:when test="${j.estado == 'ACEPTADA'}">
                                                <div class="status-aceptada">
                                                    <span class="material-symbols-outlined" style="font-size: 16px;">check_circle</span> Aceptada
                                                </div>
                                            </c:when>
                                            <c:when test="${j.estado == 'RECHAZADA'}">
                                                <div class="status-rechazada">
                                                    <span class="material-symbols-outlined" style="font-size: 16px;">cancel</span> Rechazada
                                                </div>
                                            </c:when>
                                            <c:otherwise><span>${j.estado}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="actions-cell">
                                            <c:if test="${(sessionScope.usuario.rol == 'ADMIN' || sessionScope.usuario.rol == 'JEFE')}">
                                                <md-icon-button onclick="abrirModal('${j.id}', 'aprobar')" title="Aprobar" style="--md-icon-button-icon-color: var(--md-sys-color-success);">
                                                    <md-icon>check</md-icon>
                                                </md-icon-button>
                                                <md-icon-button onclick="abrirModal('${j.id}', 'rechazar')" title="Rechazar" style="--md-icon-button-icon-color: var(--md-sys-color-error);">
                                                    <md-icon>close</md-icon>
                                                </md-icon-button>
                                            </c:if>

                                            <c:if test="${j.estado == 'PENDIENTE' && sessionScope.usuario.id == j.empleado.id}">
                                                <md-icon-button href="${pageContext.request.contextPath}/justificaciones/editar/${j.id}" onclick="window.location.href='${pageContext.request.contextPath}/justificaciones/editar/${j.id}'" title="Editar">
                                                    <md-icon>edit</md-icon>
                                                </md-icon-button>
                                                <md-icon-button onclick="if(confirm('¿Seguro de eliminar?')) window.location.href='${pageContext.request.contextPath}/justificaciones/eliminar/${j.id}'" title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);">
                                                    <md-icon>delete</md-icon>
                                                </md-icon-button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty lista}">
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 80px 0;">
                                        <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
                                            <div style="width: 80px; height: 80px; background: var(--md-sys-color-surface-variant); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                                <span class="material-symbols-outlined" style="font-size: 40px; color: var(--md-sys-color-on-surface-variant);">inbox</span>
                                            </div>
                                            <div style="font-size: 1.1rem; font-weight: 500; color: var(--md-sys-color-on-surface);">No hay justificaciones</div>
                                            <p style="color: var(--md-sys-color-secondary);">No se encontraron registros para mostrar</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination & Controls (MD3) -->
                <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                    
                    <!-- Left Side: Items per page & Page Info -->
                    <div style="display: flex; align-items: center; gap: 24px;">
                        
                        <!-- Items per page -->
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas por página:</span>
                            <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                <md-select-option value="5" ${size == 5 ? 'selected' : ''}>
                                    <div slot="headline">5</div>
                                </md-select-option>
                                <md-select-option value="10" ${size == 10 ? 'selected' : ''}>
                                    <div slot="headline">10</div>
                                </md-select-option>
                                <md-select-option value="25" ${size == 25 ? 'selected' : ''}>
                                    <div slot="headline">25</div>
                                </md-select-option>
                                <md-select-option value="50" ${size == 50 ? 'selected' : ''}>
                                    <div slot="headline">50</div>
                                </md-select-option>
                                <md-select-option value="100" ${size == 100 ? 'selected' : ''}>
                                    <div slot="headline">100</div>
                                </md-select-option>
                            </md-outlined-select>
                        </div>

                        <!-- Page Info Text -->
                        <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                            ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number + 1) * size} de ${pagina.totalElements}
                        </div>
                    </div>

                    <!-- Right Side: Navigation & Go To -->
                    <div style="display: flex; align-items: center; gap: 16px;">
                        
                        <!-- Navigation Buttons -->
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                <md-icon>chevron_left</md-icon>
                            </md-icon-button>
                            
                            <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                <md-icon>chevron_right</md-icon>
                            </md-icon-button>
                        </div>

                        <!-- Go to Page Input -->
                         <div style="display: flex; align-items: center; gap: 12px; padding-left: 16px; border-left: 1px solid var(--md-sys-color-outline-variant);">
                            <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); white-space: nowrap;">Ir a página</span>
                            <md-outlined-text-field 
                                type="number" 
                                min="1" 
                                max="${pagina.totalPages}" 
                                onkeydown="if(event.key === 'Enter') changePage(this.value - 1)"
                                placeholder="${pagina.number + 1}" 
                                style="width: 80px;">
                            </md-outlined-text-field>
                        </div>

                    </div>
                </div>

            </div>
        </div>

        <!-- MD3 Dialog for Processing Requests -->
        <md-dialog id="modal-procesar" style="min-width: 320px;">
            <md-icon slot="icon" id="dialog-icon">gavel</md-icon>
            <div slot="headline" id="dialog-title">Procesar Solicitud</div>
            
            <form slot="content" id="form-procesar" method="post">
                <div class="dialog-content">
                    <p id="dialog-summary" style="margin: 0; padding-bottom: 8px; color: var(--md-sys-color-secondary); font-size: 0.9rem; text-align: center;"></p>
                    
                    <md-outlined-text-field
                        type="textarea"
                        label="Comentario / Observación"
                        name="comentario"
                        id="dialog-comentario"
                        rows="3"
                        required
                        class="full-width-field">
                        <md-icon slot="leading-icon">comment</md-icon>
                    </md-outlined-text-field>
                </div>
            </form>
    
            <div slot="actions">
                <md-text-button value="cancel" onclick="cerrarModal()">Cancelar</md-text-button>
                <md-filled-button id="btn-confirmar-dialog" onclick="submitDialog()">
                    <md-icon slot="icon" id="btn-icon">check</md-icon>
                    <span id="btn-text">Confirmar</span>
                </md-filled-button>
            </div>
        </md-dialog>

        <!-- MD3 Dialog for Viewing Details -->
        <md-dialog id="modal-detalle" style="min-width: 350px; max-width: 500px;">
            <md-icon slot="icon">info</md-icon>
            <div slot="headline">Detalle de la Justificación</div>
            <div slot="content" style="display: flex; flex-direction: column; gap: 16px; padding-top: 8px;">
                <!-- Motivo -->
                <div>
                    <h4 style="margin: 0 0 4px 0; font-size: 0.9rem; color: var(--md-sys-color-primary);">Motivo del Empleado</h4>
                    <p id="detalle-motivo" style="margin: 0; color: var(--md-sys-color-on-surface-variant); background: var(--md-sys-color-surface-variant); padding: 12px; border-radius: 8px; font-size: 0.95rem;"></p>
                </div>
                
                <!-- Respuesta -->
                <div id="wrapper-respuesta" style="display: none;">
                    <h4 style="margin: 0 0 4px 0; font-size: 0.9rem; color: var(--md-sys-color-primary);">Respuesta del Administrador</h4>
                    <p id="detalle-respuesta" style="margin: 0; color: var(--md-sys-color-on-surface-variant); background: var(--md-sys-color-surface-variant); padding: 12px; border-radius: 8px; font-size: 0.95rem;"></p>
                </div>

                <!-- Evidencia -->
                <div id="wrapper-evidencia" style="display: none;">
                    <h4 style="margin: 0 0 8px 0; font-size: 0.9rem; color: var(--md-sys-color-primary);">Evidencia Adjunta</h4>
                    <md-outlined-button id="btn-evidencia" target="_blank" style="width: 100%;">
                        <md-icon slot="icon">attachment</md-icon>
                        Ver Documento / Imagen
                    </md-outlined-button>
                </div>
            </div>
            <div slot="actions">
                <md-filled-button onclick="document.getElementById('modal-detalle').close()">
                    Cerrar
                </md-filled-button>
            </div>
        </md-dialog>

        <script>
            function verDetalle(motivo, respuesta, evidenciaUrl) {
                const dialog = document.getElementById('modal-detalle');
                const pMotivo = document.getElementById('detalle-motivo');
                const pRespuesta = document.getElementById('detalle-respuesta');
                const wrapperRespuesta = document.getElementById('wrapper-respuesta');
                const wrapperEvidencia = document.getElementById('wrapper-evidencia');
                const btnEvidencia = document.getElementById('btn-evidencia');
                
                // Decode or handle potential simple strings. 
                // Since this is JSP EL, strings are directly pasted. 
                // We should be careful about quotes, but sticking to basic string for now.
                pMotivo.textContent = motivo;
                
                if (respuesta && respuesta.trim() !== '') {
                    pRespuesta.textContent = respuesta;
                    wrapperRespuesta.style.display = 'block';
                } else {
                    wrapperRespuesta.style.display = 'none';
                }

                if (evidenciaUrl && evidenciaUrl.trim() !== '') {
                    const ctx = '${pageContext.request.contextPath}';
                    const fullUrl = ctx + '/' + evidenciaUrl;
                    btnEvidencia.href = fullUrl;
                    btnEvidencia.onclick = () => window.open(fullUrl, '_blank');
                    wrapperEvidencia.style.display = 'block';
                } else {
                    wrapperEvidencia.style.display = 'none';
                }
                
                dialog.show();
            }

            function abrirModal(id, accion) {
                const dialog = document.getElementById('modal-procesar');
                const form = document.getElementById('form-procesar');
                const title = document.getElementById('dialog-title');
                const summary = document.getElementById('dialog-summary');
                const btnIcon = document.getElementById('btn-icon');
                const btnText = document.getElementById('btn-text');
                const dialogIcon = document.getElementById('dialog-icon');
                const btn = document.getElementById('btn-confirmar-dialog');

                // Dynamic Action URL
                form.action = '${pageContext.request.contextPath}/justificaciones/admin/' + id + '/' + accion;
                
                // Reset field
                document.getElementById('dialog-comentario').value = '';

                // Prevent potential reuse of bad state
                btn.className = ''; 

                if (accion === 'aprobar') {
                    title.innerText = 'Aprobar Solicitud';
                    summary.innerText = 'Estás a punto de aprobar esta justificación. Agrega un comentario opcional.';
                    dialogIcon.innerText = 'check_circle';
                    dialogIcon.style.background = 'linear-gradient(135deg, var(--md-sys-color-success-container), var(--md-sys-color-surface))';
                    dialogIcon.style.color = 'var(--md-sys-color-success)';
                    
                    btnIcon.innerText = 'check';
                    btnText.innerText = 'Aprobar';
                    
                    // Styling 
                    btn.style.setProperty('--md-filled-button-container-color', 'var(--md-sys-color-success)');
                } else {
                    title.innerText = 'Rechazar Solicitud';
                    summary.innerText = 'Indica el motivo del rechazo para notificar al empleado.';
                    dialogIcon.innerText = 'cancel';
                    dialogIcon.style.background = 'linear-gradient(135deg, var(--md-sys-color-error-container), var(--md-sys-color-surface))';
                    dialogIcon.style.color = 'var(--md-sys-color-error)';
                    
                    btnIcon.innerText = 'block';
                    btnText.innerText = 'Rechazar';
                    
                    // Styling
                    btn.style.setProperty('--md-filled-button-container-color', 'var(--md-sys-color-error)');
                }

                dialog.show();
            }

            function cerrarModal() {
                document.getElementById('modal-procesar').close();
            }

            function submitDialog() {
                const form = document.getElementById('form-procesar');
                // Basic validation if needed
                if(document.getElementById('dialog-comentario').value.trim() === '' && document.getElementById('btn-text').innerText === 'Rechazar') {
                     // Maybe enforce comment on Rejection?
                     // For now let backend handle or browser handle 'required'
                }
                form.submit();
            }

</script>
            
            <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
            <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
            <script>
            document.addEventListener('DOMContentLoaded', () => {
                 fixDialogScrim(['modal-procesar', 'modal-detalle']);
                 
                 // Cancel button listener
                 const btnCancel = document.querySelector('md-text-button[value="cancel"]');
                 if(btnCancel) {
                     btnCancel.addEventListener('click', (e) => {
                         e.preventDefault(); 
                         cerrarModal();
                     });
                 }

                 // Check for Server-Side Messages
                 const msg = "${not empty mensaje ? mensaje : ''}";
                 const type = "${not empty tipoMensaje ? tipoMensaje : 'info'}";
                 
                 if(msg) {
                     let title = 'Notificación';
                     let icon = 'info';
                     
                     if(type === 'success') {
                         title = 'Éxito';
                         icon = 'check_circle';
                     } else if (type === 'error') {
                         title = 'Error';
                         icon = 'error';
                     } else if (type === 'warning') {
                         title = 'Advertencia';
                         icon = 'warning';
                     }

                     showToast(title, msg, type, icon);
                 }
                 
                 // Clean URL params if they exist (optional, mostly for redirected params)
                 const params = new URLSearchParams(window.location.search);
                 if(params.has('mensaje')) {
                     // If we were using URL params instead of Flash attributes. 
                     // Current controller uses FlashAttributes which aren't in URL usually, 
                     // but good to keep clean.
                 }
            });
        </script>
                </div><%-- end container --%>
            </div><%-- end main-content --%>
        </c:when>
        <c:otherwise>
            <%-- Mobile Layout for Employees --%>
            <jsp:include page="../shared/mobile-layout.jsp" />
            <main class="mobile-content">
                <div class="page-header" style="margin-bottom: 20px;">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin: 0 0 4px 0;">Mis Justificaciones</h1>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); margin: 0;">Gestiona tus solicitudes</p>
                </div>
                
                <a href="${pageContext.request.contextPath}/justificaciones/nuevo" 
                   style="display: flex; align-items: center; justify-content: center; gap: 8px; background: linear-gradient(135deg, #EC407A 0%, #AB47BC 100%); color: white; padding: 14px 24px; border-radius: 28px; text-decoration: none; font-weight: 600; margin-bottom: 20px; box-shadow: 0 4px 16px rgba(236, 64, 122, 0.3);">
                    <span class="material-symbols-rounded" style="font-size: 20px;">add</span>
                    Nueva Solicitud
                </a>
                
                <c:choose>
                    <c:when test="${empty lista}">
                        <div style="text-align: center; padding: 48px 24px;">
                            <span class="material-symbols-rounded" style="font-size: 64px; color: #CAC4D0;">inbox</span>
                            <h3 style="font-size: 1.1rem; color: var(--text-primary); margin: 16px 0 8px 0;">Sin justificaciones</h3>
                            <p style="font-size: 0.9rem; color: var(--text-secondary); margin: 0;">No tienes solicitudes registradas</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 12px;">
                            <c:forEach var="j" items="${lista}">
                                <div style="background: var(--surface, #fff); border-radius: 16px; padding: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); border-left: 4px solid ${j.estado == 'PENDIENTE' ? '#FF9800' : j.estado == 'ACEPTADA' ? '#4CAF50' : '#F44336'};">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                                        <div>
                                            <div style="font-weight: 600; color: var(--text-primary);">${j.fechaSolicitud}</div>
                                            <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 4px;">
                                                ${j.fechaInicio} 
                                                <c:if test="${j.fechaInicio != j.fechaFin}"> - ${j.fechaFin}</c:if>
                                            </div>
                                        </div>
                                        <span style="padding: 4px 10px; border-radius: 16px; font-size: 0.7rem; font-weight: 600; text-transform: uppercase;
                                            background: ${j.estado == 'PENDIENTE' ? 'rgba(255,152,0,0.12)' : j.estado == 'ACEPTADA' ? 'rgba(76,175,80,0.12)' : 'rgba(244,67,54,0.12)'};
                                            color: ${j.estado == 'PENDIENTE' ? '#E65100' : j.estado == 'ACEPTADA' ? '#2E7D32' : '#C62828'};">
                                            ${j.estado}
                                        </span>
                                    </div>
                                    <div style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                        ${j.motivo}
                                    </div>
                                    <c:if test="${j.estado == 'PENDIENTE'}">
                                        <div style="display: flex; gap: 8px; margin-top: 12px; padding-top: 12px; border-top: 1px solid #eee;">
                                            <a href="${pageContext.request.contextPath}/justificaciones/editar/${j.id}" 
                                               style="flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px; background: rgba(236,64,122,0.1); color: #EC407A; border-radius: 12px; text-decoration: none; font-size: 0.85rem; font-weight: 600;">
                                                <span class="material-symbols-rounded" style="font-size: 18px;">edit</span>
                                                Editar
                                            </a>
                                            <a href="${pageContext.request.contextPath}/justificaciones/eliminar/${j.id}" 
                                               onclick="return confirm('¿Eliminar esta solicitud?');"
                                               style="flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px; background: rgba(244,67,54,0.1); color: #F44336; border-radius: 12px; text-decoration: none; font-size: 0.85rem; font-weight: 600;">
                                                <span class="material-symbols-rounded" style="font-size: 18px;">delete</span>
                                                Eliminar
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </main>
        </c:otherwise>
    </c:choose>
</body>
</html>
