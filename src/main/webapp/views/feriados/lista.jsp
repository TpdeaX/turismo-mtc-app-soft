<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Feriados


        
    </title>
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
        
        /* Table Action Buttons container */
        .actions-cell {
            display: flex;
            gap: 4px;
            justify-content: center;
        }

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
            /* opacity: 0; removed to ensure visibility */
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
        
        /* Modal Form Grid */
        .modal-form-grid {
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-top: 16px;
        }
        
        md-outlined-text-field { width: 100%; }
        
        /* Compact Table */
        .compact-table th, .compact-table td {
            padding: 12px 16px !important;
            color: var(--md-sys-color-on-surface); /* Enforce text color */
        }
    </style>
</head>
<body>

    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/console-warning.jsp" />
    <jsp:include page="../shared/sidebar.jsp" />

    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />

        <div class="container">
            
            <div class="page-header" style="gap: 16px; flex-wrap: wrap;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem; margin: 0;">Lista de Feriados</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Gestiona los días no laborables</p>
                </div>
                <div>
                     <md-filled-button onclick="abrirModalNuevo()">
                        <md-icon slot="icon">add</md-icon>
                        Nuevo Feriado
                    </md-filled-button>
                </div>
            </div>

            <!-- Filter and Search -->
            <div class="card" style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface); animation: fade-in-down 0.5s ease-out;">
                <form id="filterForm" action="${pageContext.request.contextPath}/feriados/filter" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
                    <div style="display: flex; gap: 16px; align-items: center;">
                        <md-outlined-text-field 
                            label="Buscar" 
                            name="keyword" 
                            value="${keyword}"
                            placeholder="Descripción..." 
                            style="flex: 1;"
                            onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                            <md-icon slot="leading-icon">search</md-icon>
                        </md-outlined-text-field>

                        <md-filled-button type="button" onclick="submitFilter()">
                            <md-icon slot="icon">search</md-icon>
                            Buscar
                        </md-filled-button>
                        
                         <md-outlined-button type="button" onclick="limpiarFiltros()">
                            Limpiar
                        </md-outlined-button>
                    </div>
                </form>
            </div>

            <div class="card" style="animation: fade-in-down 0.6s ease-out;">
                <div class="table-container">
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th style="width: 150px;">Fecha</th>
                                <th>Descripción</th>
                                <th style="width: 100px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="f" items="${feriados}">
                                <tr>
                                    <td>
                                        <span style="color: var(--md-sys-color-secondary); font-family: monospace;">#${f.id}</span>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span class="material-symbols-outlined" style="font-size: 18px; color: var(--md-sys-color-primary);">event</span>
                                            <span style="font-weight: 500;">${f.fecha}</span>
                                        </div>
                                    </td>
                                    <td>
                                        ${f.descripcion}
                                    </td>
                                    <td>
                                        <div class="actions-cell">
                                            <md-icon-button title="Editar" 
                                                onclick="abrirModalEditar('${f.id}', '${f.fecha}', '${fn:escapeXml(f.descripcion)}')">
                                                <md-icon>edit</md-icon>
                                            </md-icon-button>
                                            
                                            <md-icon-button title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);"
                                                onclick="abrirModalEliminar('${f.id}')">
                                                <md-icon>delete</md-icon>
                                            </md-icon-button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty feriados}">
                                <tr>
                                    <td colspan="4" style="text-align: center; padding: 60px 0;">
                                        <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
                                            <div style="width: 64px; height: 64px; background: var(--md-sys-color-surface-variant); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                                <span class="material-symbols-outlined" style="font-size: 32px; color: var(--md-sys-color-on-surface-variant);">event_busy</span>
                                            </div>
                                            <div style="font-size: 1rem; font-weight: 500; color: var(--md-sys-color-on-surface);">No se encontraron feriados</div>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination & Controls (MD3) -->
                <c:if test="${pagina != null}">
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
                </c:if>
            </div>
        </div>

        <!-- MODAL: Nuevo / Editar -->
        <md-dialog id="modal-feriado" style="min-width: 350px; max-width: 500px;">
            <md-icon slot="icon">event</md-icon>
            <div slot="headline" id="modal-title">Nuevo Feriado</div>
            
            <form slot="content" id="form-feriado" method="post" action="${pageContext.request.contextPath}/feriados/guardar">
                <input type="hidden" name="id" id="input-id" value="0">
                <div class="modal-form-grid">
                    <md-outlined-text-field 
                        type="date" 
                        label="Fecha" 
                        name="fecha" 
                        id="input-fecha" 
                        required>
                    </md-outlined-text-field>
                    
                    <md-outlined-text-field 
                        label="Descripción" 
                        name="descripcion" 
                        id="input-descripcion" 
                        required>
                    </md-outlined-text-field>
                </div>
            </form>
            
            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-feriado').close()">Cancelar</md-text-button>
                <md-filled-button onclick="submitForm()">Guardar</md-filled-button>
            </div>
        </md-dialog>

        <!-- MODAL: Eliminar -->
        <md-dialog id="modal-eliminar" style="max-width: 400px;">
            <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
            <div slot="headline">¿Eliminar Feriado?</div>
            <div slot="content">Esta acción no se puede deshacer.</div>
            
            <form id="form-eliminar" method="post" action="${pageContext.request.contextPath}/feriados/eliminar">
                <input type="hidden" name="id" id="id-eliminar">
            </form>

            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-eliminar').close()">Cancelar</md-text-button>
                <md-filled-button onclick="document.getElementById('form-eliminar').submit()" 
                    style="--md-filled-button-container-color: var(--md-sys-color-error);">
                    Eliminar
                </md-filled-button>
            </div>
        </md-dialog>

        <script>
            // --- Modal Logic ---
            function abrirModalNuevo() {
                document.getElementById('modal-title').innerText = "Nuevo Feriado";
                document.getElementById('input-id').value = "0";
                document.getElementById('input-fecha').value = "";
                document.getElementById('input-descripcion').value = "";
                document.getElementById('modal-feriado').show();
            }

            function abrirModalEditar(id, fecha, descripcion) {
                document.getElementById('modal-title').innerText = "Editar Feriado";
                document.getElementById('input-id').value = id;
                document.getElementById('input-fecha').value = fecha;
                document.getElementById('input-descripcion').value = descripcion;
                document.getElementById('modal-feriado').show();
            }

            function abrirModalEliminar(id) {
                document.getElementById('id-eliminar').value = id;
                document.getElementById('modal-eliminar').show();
            }
            
            function submitForm() {
                const fecha = document.getElementById('input-fecha');
                const desc = document.getElementById('input-descripcion');
                
                if(!fecha.value) {
                    fecha.error = true;
                    return;
                }
                if(!desc.value.trim()) {
                    desc.error = true;
                    return;
                }
                
                document.getElementById('form-feriado').submit();
            }

            // --- Filter & Pagination ---
            function submitFilter() {
                document.getElementById('pageInput').value = 0; 
                document.getElementById('filterForm').submit();
            }

            function limpiarFiltros() {
                document.querySelector('md-outlined-text-field[name="keyword"]').value = '';
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
        </script>
        
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', () => {
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
                 
                 // Fix dialog scrims
                 if (typeof fixDialogScrim === 'function') {
                    fixDialogScrim(['modal-feriado', 'modal-eliminar']);
                 }
            });
        </script>
    </div>
</body>
</html>
