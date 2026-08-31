<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Tipos de Turno</title>
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

        .actions-cell {
            display: flex;
            gap: 4px;
        }
        
        .color-sample { 
            width: 24px; 
            height: 24px; 
            border-radius: 50%; 
            border: 1px solid var(--md-sys-color-outline); 
            display: inline-block; 
            vertical-align: middle;
            margin-right: 8px;
        }
        
        /* Modal form styles */
        .color-input-wrapper {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px;
            border: 1px solid var(--md-sys-color-outline);
            border-radius: 4px;
            transition: 0.2s;
            margin-bottom: 16px;
        }
        
        .color-input-wrapper:hover {
            border-color: var(--md-sys-color-on-surface);
        }

        input[type="color"] {
            border: none;
            width: 48px;
            height: 48px;
            cursor: pointer;
            background: none;
            padding: 0;
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
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Tipos de Turno</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Administra los tipos de turnos disponibles</p>
                </div>
                <div>
                     <md-filled-button onclick="abrirModalNuevo()">
                        <md-icon slot="icon">add</md-icon>
                        Nuevo Tipo
                    </md-filled-button>
                </div>
            </div>

            <!-- Advanced Filter Form -->
            <div class="card" style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface);">
                <form id="filterForm" action="${pageContext.request.contextPath}/tipoturno" method="get">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
                    <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                        <div style="flex: 1; min-width: 250px;">
                            <md-outlined-text-field 
                                label="Buscar" 
                                name="keyword" 
                                value="${keyword}"
                                placeholder="Nombre del turno..." 
                                style="width: 100%;">
                                <md-icon slot="leading-icon">search</md-icon>
                            </md-outlined-text-field>
                        </div>
                        
                        <div style="display: flex; gap: 8px;">
                            <md-outlined-button type="button" onclick="limpiarFiltros()">
                                Limpiar
                            </md-outlined-button>
                            <md-filled-button type="button" onclick="submitFilter()">
                                <md-icon slot="icon">filter_list</md-icon>
                                Filtrar
                            </md-filled-button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Table Card -->
            <div class="card">
                <div class="table-container">
                    <style>
                        .compact-table th, .compact-table td {
                            padding: 12px 16px !important;
                        }
                    </style>
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Nombre</th>
                                <th style="width: 150px;">Color</th>
                                <th style="width: 120px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${lista}">
                                <tr>
                                    <td>${t.id}</td>
                                    <td>
                                        <div style="font-weight: 500; color: var(--md-sys-color-on-surface);">${t.nombre}</div>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <div class="color-sample" style="background-color: ${t.color};"></div>
                                            <span style="font-family: monospace;">${t.color}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="actions-cell" style="justify-content: center;">
                                            <md-icon-button onclick="abrirModalEditar('${t.id}', '${t.nombre}', '${t.color}')" title="Editar">
                                                <md-icon>edit</md-icon>
                                            </md-icon-button>
                                            <md-icon-button onclick="abrirModalEliminar('${t.id}', '${t.nombre}')" title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);">
                                                <md-icon>delete</md-icon>
                                            </md-icon-button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty lista}">
                                <tr>
                                    <td colspan="4" style="text-align: center; padding: 60px 0;">
                                        <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
                                            <div style="width: 64px; height: 64px; background: var(--md-sys-color-surface-variant); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                                <span class="material-symbols-outlined" style="font-size: 32px; color: var(--md-sys-color-on-surface-variant);">layers_clear</span>
                                            </div>
                                            <div style="font-size: 1rem; font-weight: 500; color: var(--md-sys-color-on-surface);">No hay tipos de turno</div>
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
        
        <!-- Form Modal (Create/Edit) -->
        <md-dialog id="modal-form" style="min-width: 350px;">
            <div slot="headline" id="modal-form-title">Nuevo Tipo de Turno</div>
            <form slot="content" id="form-tipo" method="post" action="${pageContext.request.contextPath}/tipoturno/guardar">
                <input type="hidden" name="id" id="form-id" value="0">
                <div class="dialog-content" style="padding-top: 16px; display: flex; flex-direction: column; gap: 16px;">
                    <md-outlined-text-field 
                        label="Nombre del Turno" 
                        name="nombre" 
                        id="form-nombre"
                        required
                        supporting-text="Ej: Mañana, Tarde, Noche"
                        style="width: 100%;">
                    </md-outlined-text-field>

                    <div>
                        <label style="color: var(--md-sys-color-on-surface-variant); font-size: 0.8rem; font-weight: 500; display: block; margin-bottom: 8px;">Color Identificativo</label>
                        <div class="color-input-wrapper">
                            <input type="color" name="color" id="form-color" value="#6750A4">
                            <div style="display: flex; flex-direction: column;">
                                <span style="font-weight: 500; color: var(--md-sys-color-on-surface);">Seleccionar color</span>
                                <span style="font-size: 0.75rem; color: var(--md-sys-color-secondary);">Para calendarios y listas</span>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-form').close()">Cancelar</md-text-button>
                <md-filled-button onclick="document.getElementById('form-tipo').submit()">
                    <md-icon slot="icon">save</md-icon>
                    Guardar
                </md-filled-button>
            </div>
        </md-dialog>

        <!-- Delete Confirmation Dialog -->
        <md-dialog id="modal-eliminar" style="min-width: 320px;">
            <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
            <div slot="headline">Eliminar Tipo de Turno</div>
            <form slot="content" id="form-eliminar" method="post" action="${pageContext.request.contextPath}/tipoturno/eliminar">
                <input type="hidden" name="id" id="delete-id">
                <div class="dialog-content">
                    Estas a punto de eliminar el turno <strong id="delete-name"></strong>. Esta acción no se puede deshacer.
                </div>
            </form>
            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-eliminar').close()">Cancelar</md-text-button>
                <md-filled-button onclick="document.getElementById('form-eliminar').submit()" style="--md-filled-button-container-color: var(--md-sys-color-error);">
                    <md-icon slot="icon">delete</md-icon>
                    Eliminar
                </md-filled-button>
            </div>
        </md-dialog>

        <script>
            function submitFilter() {
                document.getElementById('pageInput').value = 0; 
                document.getElementById('filterForm').submit();
            }

            function limpiarFiltros() {
                document.querySelectorAll('md-outlined-text-field').forEach(field => field.value = '');
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

            function abrirModalEliminar(id, nombre) {
                document.getElementById('delete-id').value = id;
                document.getElementById('delete-name').textContent = nombre;
                document.getElementById('modal-eliminar').show();
            }
            
            function abrirModalNuevo() {
                document.getElementById('modal-form-title').innerText = 'Nuevo Tipo de Turno';
                document.getElementById('form-id').value = 0;
                document.getElementById('form-nombre').value = '';
                document.getElementById('form-color').value = '#6750A4';
                document.getElementById('modal-form').show();
            }
            
            function abrirModalEditar(id, nombre, color) {
                document.getElementById('modal-form-title').innerText = 'Editar Tipo de Turno';
                document.getElementById('form-id').value = id;
                document.getElementById('form-nombre').value = nombre;
                document.getElementById('form-color').value = color;
                document.getElementById('modal-form').show();
            }
        </script>
        
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                 fixDialogScrim(['modal-eliminar', 'modal-form']);
                 
                 // Toast messages from backend
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
                     }
                     showToast(title, msg, type, icon);
                 }
            });
        </script>
    </div>
</body>
</html>
