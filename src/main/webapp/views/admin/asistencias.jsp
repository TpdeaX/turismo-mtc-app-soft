<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Asistencias</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
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
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        
        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
        }

        .compact-table th, .compact-table td { padding: 12px 16px !important; }
        .actions-cell { display: flex; gap: 4px; justify-content: center; }

        /* View Toggle Switch */
        .view-toggle {
            display: flex;
            background-color: var(--md-sys-color-surface-container-high);
            border-radius: 24px;
            padding: 4px;
            gap: 4px;
        }

        /* Status Badges */
        .badge { padding: 4px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
        .badge-qr { background-color: #e3f2fd; color: #1565c0; border: 1px solid #bbdefb; }
        .badge-gps { background-color: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
        .badge-manual { background-color: #fff3e0; color: #ef6c00; border: 1px solid #ffe0b2; }
        .badge-sospechosa { background-color: #ffebee; color: #c62828; border: 1px solid #ffcdd2; animation: pulse-warning 2s ease-in-out infinite; }
        
        @keyframes pulse-warning {
            0%, 100% { box-shadow: 0 0 0 0 rgba(198, 40, 40, 0.2); }
            50% { box-shadow: 0 0 0 4px rgba(198, 40, 40, 0.1); }
        }

        /* Grid View (Cards) */
        .grid-view-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 16px;
            display: none; /* Hidden by default */
        }

        .asistencia-card {
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: 16px;
            background: var(--md-sys-color-surface);
            padding: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
            position: relative;
        }
        
        .asistencia-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--md-sys-elevation-2);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--md-sys-color-outline-variant);
        }

        .card-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        
        .card-label { color: var(--md-sys-color-secondary); }
        .card-value { font-weight: 500; }

        .time-badge {
            background-color: var(--md-sys-color-secondary-container);
            color: var(--md-sys-color-on-secondary-container);
            padding: 4px 8px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 0.85rem;
        }

        /* Animations */
        @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
        .fade-in { animation: fade-in 0.3s ease-out forwards; }
    </style>
</head>
<body>
    <div id="toast-mount-point" style="display:none;"></div>
    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/console-warning.jsp" />
    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="container">
            <!-- Header -->
            <div class="page-header" style="flex-wrap: wrap; gap: 16px;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Ver Asistencias</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Historial completo de marcaciones y registros</p>
                </div>
                
                <div style="display: flex; gap: 12px; align-items: center;">
                    <!-- View Toggle -->
                    <div class="view-toggle">
                        <md-icon-button id="btn-list-view" title="Vista de Lista" onclick="switchView('list')">
                            <md-icon>table_rows</md-icon>
                        </md-icon-button>
                        <md-icon-button id="btn-grid-view" title="Vista de Cuadrícula" onclick="switchView('grid')">
                            <md-icon>grid_view</md-icon>
                        </md-icon-button>
                    </div>

                    <md-outlined-button onclick="exportarExcel()">
                        <md-icon slot="icon">grid_on</md-icon>
                        Exportar Excel
                    </md-outlined-button>
                </div>
            </div>

            <!-- Filters -->
            <div class="card" style="margin-bottom: 24px; padding: 24px;">
                <form id="filterForm" action="${pageContext.request.contextPath}/admin/asistencias/filter" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
                    <div style="display: grid; grid-template-columns: repeat(12, 1fr); gap: 16px; align-items: center;">
                        
                        <!-- Search -->
                        <div style="grid-column: span 4;">
                            <md-outlined-text-field 
                                label="Buscar Empleado" 
                                name="keyword" 
                                value="${keyword}"
                                placeholder="Nombre o DNI" 
                                style="width: 100%;"
                                onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                                <md-icon slot="leading-icon">search</md-icon>
                            </md-outlined-text-field>
                        </div>

                        <!-- Sucursal -->
                        <div style="grid-column: span 3;">
                            <md-outlined-select label="Sucursal" name="sucursalId" style="width: 100%;">
                                <md-select-option value="" ${empty sucursalId ? 'selected' : ''}>
                                    <div slot="headline">Todas</div>
                                </md-select-option>
                                <c:forEach var="s" items="${listaSucursales}">
                                    <md-select-option value="${s.id}" ${sucursalId == s.id ? 'selected' : ''}>
                                        <div slot="headline">${s.nombre}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Fechas -->
                        <div style="grid-column: span 2;">
                            <md-outlined-text-field label="Desde" type="date" name="fechaInicio" value="${fechaInicio}" style="width: 100%;"></md-outlined-text-field>
                        </div>
                        <div style="grid-column: span 2;">
                            <md-outlined-text-field label="Hasta" type="date" name="fechaFin" value="${fechaFin}" style="width: 100%;"></md-outlined-text-field>
                        </div>

                        <div style="grid-column: span 1; display: flex; justify-content: flex-end;">
                           <md-filled-button type="button" onclick="submitFilter()" style="height: 56px; width: 100%;">
                                <md-icon>filter_list</md-icon>
                            </md-filled-button>
                        </div>
                    </div>
                    <div style="text-align: right; margin-top: 8px;">
                        <md-text-button type="button" onclick="limpiarFiltros()">Limpiar Filtros</md-text-button>
                    </div>
                </form>
            </div>

            <!-- List View (Table) -->
            <div id="listView" class="card fade-in">
                <div class="table-container">
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Hora Entrada</th>
                                <th>Hora Salida</th>
                                <th>Empleado</th>
                                <th>Sucursal</th>
                                <th>Modo</th>
                                <th>Obs.</th>
                                <th style="text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="${listaAsistencia}">
                                <tr>
                                    <td>${a.fecha}</td>
                                    <td>
                                        <span class="time-badge">${a.horaEntrada != null ? a.horaEntrada : '--:--'}</span>
                                    </td>
                                    <td>
                                        <span class="time-badge">${a.horaSalida != null ? a.horaSalida : '--:--'}</span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 500;">${a.empleado.apellidos}, ${a.empleado.nombres}</div>
                                        <div style="font-size: 0.8rem; color: var(--md-sys-color-secondary);">${a.empleado.dni}</div>
                                    </td>
                                    <td>${a.empleado.sucursal != null ? a.empleado.sucursal.nombre : '-'}</td>
                                    <td>
                                        <span class="badge ${a.modo == 'QR_DINAMICO' ? 'badge-qr' : (a.modo == 'GPS' ? 'badge-gps' : 'badge-manual')}">
                                            <span class="material-symbols-outlined" style="font-size: 14px;">
                                                ${a.modo == 'QR_DINAMICO' ? 'qr_code' : (a.modo == 'GPS' ? 'location_on' : 'edit_note')}
                                            </span>
                                            ${a.modo}
                                        </span>
                                        <c:if test="${a.sospechosa == true}">
                                            <span class="badge badge-sospechosa" style="margin-left: 4px;">
                                                <span class="material-symbols-outlined" style="font-size: 14px;">warning</span>
                                                Sospechosa
                                            </span>
                                        </c:if>
                                    </td>
                                    <td style="max-width: 150px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${a.observacion}">
                                        ${a.observacion}
                                    </td>
                                    <td>
                                        <div class="actions-cell">
                                            <md-icon-button title="Ver Detalle" onclick="verDetalle('${a.id}', '${a.fotoUrl}', '${a.latitud}', '${a.longitud}')">
                                                <md-icon>visibility</md-icon>
                                            </md-icon-button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaAsistencia}">
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                                        No se encontraron asistencias con los filtros seleccionados.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Grid View (Cards) -->
            <div id="gridView" class="grid-view-container fade-in">
                <c:forEach var="a" items="${listaAsistencia}">
                    <div class="asistencia-card">
                        <div class="card-header">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <div style="width: 32px; height: 32px; background: var(--md-sys-color-primary-container); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--md-sys-color-on-primary-container); font-weight: bold;">
                                    ${fn:substring(a.empleado.nombres, 0, 1)}${fn:substring(a.empleado.apellidos, 0, 1)}
                                </div>
                                <div>
                                    <div style="font-weight: 600; font-size: 0.95rem;">${a.empleado.apellidos} ${a.empleado.nombres}</div>
                                    <div style="font-size: 0.75rem; color: var(--md-sys-color-secondary);">${a.fecha}</div>
                                </div>
                            </div>
                            <md-icon-button onclick="verDetalle('${a.id}', '${a.fotoUrl}', '${a.latitud}', '${a.longitud}')">
                                <md-icon>info</md-icon>
                            </md-icon-button>
                        </div>
                        
                        <div class="card-row">
                            <span class="card-label">Hora Entrada:</span>
                            <span class="time-badge">${a.horaEntrada != null ? a.horaEntrada : '--:--'}</span>
                        </div>
                        <div class="card-row">
                            <span class="card-label">Hora Salida:</span>
                            <span class="time-badge">${a.horaSalida != null ? a.horaSalida : '--:--'}</span>
                        </div>
                        <div class="card-row">
                            <span class="card-label">Sucursal:</span>
                            <span class="card-value">${a.empleado.sucursal != null ? a.empleado.sucursal.nombre : '-'}</span>
                        </div>
                        <div class="card-row" style="margin-top: 8px; align-items: center; flex-wrap: wrap; gap: 4px;">
                             <span class="badge ${a.modo == 'QR_DINAMICO' ? 'badge-qr' : (a.modo == 'GPS' ? 'badge-gps' : 'badge-manual')}">
                                <span class="material-symbols-outlined" style="font-size: 14px;">
                                    ${a.modo == 'QR_DINAMICO' ? 'qr_code' : (a.modo == 'GPS' ? 'location_on' : 'edit_note')}
                                </span>
                                ${a.modo}
                            </span>
                            <c:if test="${a.sospechosa == true}">
                                <span class="badge badge-sospechosa">
                                    <span class="material-symbols-outlined" style="font-size: 14px;">warning</span>
                                    Sospechosa
                                </span>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty listaAsistencia}">
                     <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                        No hay cartas para mostrar.
                    </div>
                </c:if>
            </div>

            <!-- Pagination (Shared) -->
             <div class="card" style="margin-top: 16px; padding: 16px 24px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 24px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Mostrar:</span>
                        <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                            <md-select-option value="5" ${size == 5 ? 'selected' : ''}><div slot="headline">5</div></md-select-option>
                            <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                            <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
                            <md-select-option value="50" ${size == 50 ? 'selected' : ''}><div slot="headline">50</div></md-select-option>
                        </md-outlined-select>
                    </div>
                    <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                        ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number + 1) * size} de ${pagina.totalElements}
                    </div>
                </div>
                
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
                    <md-outlined-text-field type="number" min="1" max="${pagina.totalPages}"
                        onkeydown="if(event.key === 'Enter') changePage(this.value - 1)"
                        placeholder="${pagina.number + 1}" style="width: 80px;">
                    </md-outlined-text-field>
                </div>
            </div>

        </div>

        <!-- MODAL: Detalle de Asistencia -->
        <md-dialog id="modal-detalle" style="min-width: 400px; max-width: 600px;">
            <md-icon slot="icon">visibility</md-icon>
            <div slot="headline">Evidencia de Asistencia</div>
            <div slot="content">
                <div id="detalle-content" style="display: flex; flex-direction: column; gap: 16px; align-items: center; padding-top: 16px;">
                    <img id="detalle-foto" src="" alt="Foto de evidencia" style="max-width: 100%; border-radius: 12px; display: none; box-shadow: var(--md-sys-elevation-2);">
                    <div id="detalle-no-foto" style="color: var(--md-sys-color-secondary); display: none;">No hay foto registrada</div>
                    
                    <div style="width: 100%; text-align: left; margin-top: 8px;">
                        <p><strong>Ubicación:</strong> <span id="detalle-coords" style="font-family: monospace;"></span></p>
                        <a id="detalle-mapa-link" href="#" target="_blank" style="display: inline-flex; align-items: center; gap: 4px; color: var(--md-sys-color-primary); text-decoration: none; font-weight: 500;">
                            <span class="material-symbols-outlined" style="font-size: 18px;">map</span> Ver en Google Maps
                        </a>
                    </div>
                </div>
            </div>
            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-detalle').close()">Cerrar</md-text-button>
            </div>
        </md-dialog>

        <script>
            // --- View Switcher ---
            let currentView = localStorage.getItem('asistenciaViewMode') || 'list';
            
            function switchView(mode) {
                currentView = mode;
                localStorage.setItem('asistenciaViewMode', mode);
                updateViewUI();
            }

            function updateViewUI() {
                const listView = document.getElementById('listView');
                const gridView = document.getElementById('gridView');
                const btnList = document.getElementById('btn-list-view');
                const btnGrid = document.getElementById('btn-grid-view');

                if (currentView === 'grid') {
                    listView.style.display = 'none';
                    gridView.style.display = 'grid';
                    btnGrid.variant = 'filled-tonal'; // Highlight
                    btnList.variant = 'standard';
                } else {
                    gridView.style.display = 'none';
                    listView.style.display = 'block';
                    btnList.variant = 'filled-tonal'; // Highlight
                    btnGrid.variant = 'standard';
                }
            }
            
            // Init View
            document.addEventListener('DOMContentLoaded', () => {
                updateViewUI();
            });

            // --- Filters & Pagination ---
            function submitFilter() {
                document.getElementById('pageInput').value = 0;
                document.getElementById('filterForm').submit();
            }

            function limpiarFiltros() {
                document.querySelector('input[name="keyword"]').value = '';
                document.querySelector('md-outlined-select[name="sucursalId"]').selectIndex(0);
                document.querySelector('input[name="fechaInicio"]').value = '';
                document.querySelector('input[name="fechaFin"]').value = '';
                submitFilter();
            }

            function changePage(page) {
                const totalPages = ${pagina.totalPages != null ? pagina.totalPages : 0};
                if (page < 0 || (totalPages > 0 && page >= totalPages)) {
                    showToast('Error', 'La página solicitada no está disponible', 'error', 'error');
                    return;
                }
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
                form.action = '${pageContext.request.contextPath}/admin/exportar/excel';
                form.submit();
                setTimeout(() => { form.action = originalAction; }, 500);
            }

            // --- Details Modal ---
            function verDetalle(id, fotoUrl, lat, lon) {
                const img = document.getElementById('detalle-foto');
                const noImg = document.getElementById('detalle-no-foto');
                const coords = document.getElementById('detalle-coords');
                const mapLink = document.getElementById('detalle-mapa-link');
                
                // Reset
                img.style.display = 'none';
                noImg.style.display = 'none';
                
                if (fotoUrl && fotoUrl !== 'null' && fotoUrl.trim() !== '') {
                    img.src = '${pageContext.request.contextPath}/' + fotoUrl;
                    img.style.display = 'block';
                } else {
                    noImg.style.display = 'block';
                }
                
                coords.innerText = lat + ', ' + lon;
                if(lat && lon && lat != 0) {
                     mapLink.href = 'https://www.google.com/maps?q=' + lat + ',' + lon;
                     mapLink.style.display = 'inline-flex';
                } else {
                    coords.innerText = 'No registrada';
                    mapLink.style.display = 'none';
                }

                document.getElementById('modal-detalle').show();
            }
        </script>
        
        <!-- Shared Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    </div>
</body>
</html>
