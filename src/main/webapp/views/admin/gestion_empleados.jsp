<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="es">

            <head>
                <meta charset="UTF-8">
                <title>Gestión de Empleados</title>

                <link
                    href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

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
                    import { styles as typescaleStyles } from '@material/web/typography/md-typescale-styles.js';
                    document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
                </script>

                <style>
                    /* Shared Styles */
                    .page-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 24px;
                    }

                    .card {
                        border: 1px solid var(--md-sys-color-outline-variant);
                        box-shadow: var(--md-sys-elevation-1);
                        border-radius: 20px;
                        overflow: hidden;
                        background: var(--md-sys-color-surface);
                    }

                    .compact-table th,
                    .compact-table td {
                        padding: 12px 16px !important;
                    }

                    .actions-cell {
                        display: flex;
                        gap: 4px;
                    }

                    /* Badge Styles */
                    .badge {
                        padding: 4px 12px;
                        border-radius: 8px;
                        font-size: 0.8rem;
                        font-weight: 500;
                        display: inline-flex;
                        align-items: center;
                        gap: 4px;
                    }

                    .badge-admin {
                        background-color: #e3f2fd;
                        color: #1565c0;
                        border: 1px solid #bbdefb;
                    }

                    .badge-superadmin {
                        background-color: #fff3e0;
                        color: #e65100;
                        border: 1px solid #ffcc02;
                    }

                    .badge-emp {
                        background-color: #e8f5e9;
                        color: #2e7d32;
                        border: 1px solid #c8e6c9;
                    }

                    /* Form Styles inside Modal */
                    .modal-form-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 16px;
                        margin-top: 8px;
                    }

                    .full-width {
                        grid-column: span 2;
                    }

                    md-outlined-text-field,
                    md-outlined-select {
                        width: 100%;
                    }

                    /* DNI Input Group with Button */
                    .dni-group {
                        display: flex;
                        gap: 8px;
                        align-items: flex-start;
                    }

                    .dni-group md-outlined-text-field {
                        flex-grow: 1;
                    }

                    #dniError {
                        color: var(--md-sys-color-error);
                        font-size: 0.8rem;
                        margin-top: 4px;
                        display: none;
                        margin-left: 4px;
                    }

                    /* Animations */
                    @keyframes fade-in-down {
                        from {
                            opacity: 0;
                            transform: translateY(-10px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    @keyframes slide-in-up {
                        from {
                            opacity: 0;
                            transform: translateY(20px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    /* Staggered Animation for Table Rows */
                    tbody tr {
                        animation: slide-in-up 0.4s ease-out forwards;
                    }

                    tbody tr:nth-child(1) {
                        animation-delay: 0.05s;
                    }

                    tbody tr:nth-child(2) {
                        animation-delay: 0.1s;
                    }

                    tbody tr:nth-child(3) {
                        animation-delay: 0.15s;
                    }

                    tbody tr:nth-child(4) {
                        animation-delay: 0.2s;
                    }

                    tbody tr:nth-child(5) {
                        animation-delay: 0.25s;
                    }

                    tbody tr:nth-child(6) {
                        animation-delay: 0.3s;
                    }

                    tbody tr:nth-child(7) {
                        animation-delay: 0.35s;
                    }

                    tbody tr:nth-child(8) {
                        animation-delay: 0.4s;
                    }

                    tbody tr:nth-child(9) {
                        animation-delay: 0.45s;
                    }

                    tbody tr:nth-child(10) {
                        animation-delay: 0.5s;
                    }
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
                        <div class="page-header" style="gap: 16px; flex-wrap: wrap;">
                            <div style="flex: 1;">
                                <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Lista
                                    de Personal</h1>
                                <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Administra los
                                    empleados y sus roles</p>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center;">
                                <md-outlined-button onclick="exportarExcel()">
                                    <md-icon slot="icon">grid_on</md-icon>
                                    Exportar a Excel
                                </md-outlined-button>
                                <md-filled-tonal-button onclick="exportarPdf()">
                                    <md-icon slot="icon">picture_as_pdf</md-icon>
                                    Exportar a PDF
                                </md-filled-tonal-button>
                                <md-filled-button onclick="abrirModalNuevo()">
                                    <md-icon slot="icon">person_add</md-icon>
                                    Nuevo Empleado
                                </md-filled-button>
                            </div>
                        </div>

                        <div class="card"
                            style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface); animation: fade-in-down 0.5s ease-out;">
                            <form id="filterForm" action="${pageContext.request.contextPath}/empleados/filter"
                                method="post">
                                <input type="hidden" name="page" id="pageInput" value="${pagina.number}">

                                <div
                                    style="display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; align-items: start;">

                                    <div style="grid-column: span 4;">
                                        <md-outlined-text-field label="Buscar" name="keyword" value="${keyword}"
                                            placeholder="Nombre, DNI..." style="width: 100%;"
                                            onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                                            <md-icon slot="leading-icon">search</md-icon>
                                        </md-outlined-text-field>
                                    </div>

                                    <div style="grid-column: span 2;">
                                        <md-outlined-select label="Rol" name="rol" style="width: 100%;">
                                            <md-select-option value="" ${empty rol ? 'selected' : '' }>
                                                <div slot="headline">Todos</div>
                                            </md-select-option>
                                            <c:if test="${esSuperAdmin}">
                                                <md-select-option value="SUPER_ADMIN" ${rol=='SUPER_ADMIN' ? 'selected' : '' }>
                                                    <div slot="headline">SUPER ADMIN</div>
                                                </md-select-option>
                                            </c:if>
                                            <md-select-option value="ADMIN" ${rol=='ADMIN' ? 'selected' : '' }>
                                                <div slot="headline">ADMIN</div>
                                            </md-select-option>
                                            <md-select-option value="EMPLEADO" ${rol=='EMPLEADO' ? 'selected' : '' }>
                                                <div slot="headline">EMPLEADO</div>
                                            </md-select-option>
                                        </md-outlined-select>
                                    </div>

                                    <!-- Fila 2: Filtros desplegables -->
                                    <!-- Empresa (Solo si tiene > 1) -->
                                    <c:if test="${fn:length(listaEmpresas) > 1}">
                                        <div style="grid-column: span 2;">
                                            <md-outlined-select label="Empresa" name="empresaId" style="width: 100%;" onchange="submitFilter()">
                                                <md-select-option value="" ${empty empresaId ? 'selected' : '' }>
                                                    <div slot="headline">Todas</div>
                                                </md-select-option>
                                                <c:forEach var="emp" items="${listaEmpresas}">
                                                    <md-select-option value="${emp.id}" ${empresaId == emp.id ? 'selected' : '' }>
                                                        <div slot="headline">${emp.nombre}</div>
                                                    </md-select-option>
                                                </c:forEach>
                                            </md-outlined-select>
                                        </div>
                                    </c:if>

                                    <!-- Sucursal (Solo si tiene > 1) -->
                                    <!-- Si empresa está visible (span 2), Modalidad (span 2), Sucursal (span 2) = 6 -->
                                    <!-- Si empresa NO visible, Modalidad (span 3), Sucursal (span 3) = 6 -->
                                    
                                    <c:set var="colsModalidad" value="${fn:length(listaEmpresas) > 1 ? 2 : 3}" />
                                    <c:set var="colsSucursal" value="${fn:length(listaEmpresas) > 1 ? 2 : 3}" />

                                    <div style="grid-column: span ${colsModalidad};">
                                        <md-outlined-select label="Modalidad" name="modalidad" style="width: 100%;">
                                            <md-select-option value="" ${empty modalidad ? 'selected' : '' }>
                                                <div slot="headline">Todas</div>
                                            </md-select-option>
                                            <md-select-option value="FIJO" ${modalidad=='FIJO' ? 'selected' : '' }>
                                                <div slot="headline">FIJO</div>
                                            </md-select-option>
                                            <md-select-option value="OBLIGADO" ${modalidad=='OBLIGADO' ? 'selected' : '' }>
                                                <div slot="headline">OBLIGADO</div>
                                            </md-select-option>
                                            <md-select-option value="LIBRE" ${modalidad=='LIBRE' ? 'selected' : '' }>
                                                <div slot="headline">LIBRE</div>
                                            </md-select-option>
                                        </md-outlined-select>
                                    </div>

                                    <c:if test="${fn:length(listaSucursales) > 1}">
                                        <div style="grid-column: span ${colsSucursal};">
                                            <md-outlined-select label="Sucursal" name="sucursalId" style="width: 100%;">
                                                <md-select-option value="" ${empty sucursalId ? 'selected' : '' }>
                                                    <div slot="headline">Todas</div>
                                                </md-select-option>
                                                <c:forEach var="s" items="${listaSucursales}">
                                                    <md-select-option value="${s.id}" ${sucursalId==s.id ? 'selected' : '' }>
                                                        <div slot="headline">${s.nombre}</div>
                                                    </md-select-option>
                                                </c:forEach>
                                            </md-outlined-select>
                                        </div>
                                    </c:if>

                                    <div
                                        style="grid-column: span 6; display: flex; gap: 8px; justify-content: flex-end; align-items: center; margin-top: 24px;">
                                        <md-outlined-button type="button" onclick="limpiarFiltros()" style="flex: 1;">
                                            Limpiar
                                        </md-outlined-button>
                                        <md-filled-button type="button" onclick="submitFilter()" style="flex: 1;">
                                            <md-icon slot="icon">filter_list</md-icon>
                                            Filtrar
                                        </md-filled-button>
                                    </div>

                                </div>

                                <input type="hidden" name="size" id="sizeInput" value="${size}">
                            </form>
                        </div>


                        <!-- ... (Code omitted for brevity until script section) ... -->


                        <div class="card" style="animation: fade-in-down 0.6s ease-out;">
                            <div class="table-container">
                                <table class="compact-table" style="width: 100%;">
                                    <thead>
                                        <tr>
                                            <th style="width: 100px;">ID</th>
                                            <th>Apellidos y Nombres</th>
                                            <th style="width: 150px;">DNI</th>
                                            <th style="width: 150px;">Rol</th>
                                            <th style="width: 140px; text-align: center;">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="e" items="${listaEmpleados}">
                                            <tr>
                                                <td>${e.id}</td>
                                                <td>
                                                    <div style="font-weight: 500;">${e.apellidos}, ${e.nombres}</div>
                                                </td>
                                                <td style="font-family: monospace; font-size: 0.95rem;">${e.dni}</td>
                                                <td>
                                                    <span
                                                        class="badge ${e.rol == 'SUPER_ADMIN' ? 'badge-superadmin' : (e.rol == 'ADMIN' ? 'badge-admin' : 'badge-emp')}">
                                                        <span class="material-symbols-outlined"
                                                            style="font-size: 16px;">
                                                            ${e.rol == 'SUPER_ADMIN' ? 'shield_person' : (e.rol == 'ADMIN' ? 'admin_panel_settings' : 'badge')}
                                                        </span>
                                                        ${e.rol}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="actions-cell" style="justify-content: center;">
                                                        <md-icon-button title="Editar" onclick="abrirModalEditar(this)"
                                                            data-id="${e.id}" data-nombres="${e.nombres}"
                                                            data-apellidos="${e.apellidos}" data-dni="${e.dni}"
                                                            data-sueldo="${e.sueldoBase}" data-rol="${e.rol}"
                                                            data-modalidad="${e.tipoModalidad}"
                                                            data-sucursal="${e.sucursal != null ? e.sucursal.id : ''}"
                                                            data-permisos="${e.permisosString}"
                                                            data-empresas="<c:forEach var='emp' items='${e.empresas}' varStatus='st'>${emp.id}<c:if test='${!st.last}'>,</c:if></c:forEach>">
                                                            <md-icon>edit</md-icon>
                                                        </md-icon-button>

                                                        <md-icon-button title="Eliminar"
                                                            style="--md-icon-button-icon-color: var(--md-sys-color-error);"
                                                            onclick="abrirModalEliminar('${e.id}')">
                                                            <md-icon>delete</md-icon>
                                                        </md-icon-button>

                                                        <md-icon-button title="Cambiar Contraseña"
                                                            onclick="abrirModalPassword('${e.id}', '${e.nombres}')">
                                                            <md-icon>key</md-icon>
                                                        </md-icon-button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty listaEmpleados}">
                                            <tr>
                                                <td colspan="5"
                                                    style="text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                                                    No hay empleados registrados.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                            <div
                                style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                                <div style="display: flex; align-items: center; gap: 24px;">
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <span
                                            style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas
                                            por página:</span>
                                        <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                            <md-select-option value="5" ${size==5 ? 'selected' : '' }>
                                                <div slot="headline">5</div>
                                            </md-select-option>
                                            <md-select-option value="10" ${size==10 ? 'selected' : '' }>
                                                <div slot="headline">10</div>
                                            </md-select-option>
                                            <md-select-option value="25" ${size==25 ? 'selected' : '' }>
                                                <div slot="headline">25</div>
                                            </md-select-option>
                                            <md-select-option value="50" ${size==50 ? 'selected' : '' }>
                                                <div slot="headline">50</div>
                                            </md-select-option>
                                            <md-select-option value="100" ${size==100 ? 'selected' : '' }>
                                                <div slot="headline">100</div>
                                            </md-select-option>
                                        </md-outlined-select>
                                    </div>
                                    <div
                                        style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                                        ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements :
                                        (pagina.number + 1) * size} de ${pagina.totalElements}
                                    </div>
                                </div>

                                <div style="display: flex; align-items: center; gap: 16px;">
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <md-icon-button ${pagina.first ? 'disabled' : '' }
                                            onclick="changePage(${pagina.number - 1})">
                                            <md-icon>chevron_left</md-icon>
                                        </md-icon-button>
                                        <md-icon-button ${pagina.last ? 'disabled' : '' }
                                            onclick="changePage(${pagina.number + 1})">
                                            <md-icon>chevron_right</md-icon>
                                        </md-icon-button>
                                    </div>
                                    <div
                                        style="display: flex; align-items: center; gap: 12px; padding-left: 16px; border-left: 1px solid var(--md-sys-color-outline-variant);">
                                        <span
                                            style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); white-space: nowrap;">Ir
                                            a página</span>
                                        <md-outlined-text-field type="number" min="1" max="${pagina.totalPages}"
                                            onkeydown="if(event.key === 'Enter') changePage(this.value - 1)"
                                            placeholder="${pagina.number + 1}" style="width: 80px;">
                                        </md-outlined-text-field>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <md-dialog id="modal-empleado" style="min-width: 500px; max-width: 800px;">
                        <md-icon slot="icon">person_add</md-icon>
                        <div slot="headline" id="modal-title">Nuevo Empleado</div>

                        <form slot="content" id="form-empleado" method="post" action="empleados"
                            style="max-height: 60vh; overflow-y: auto; overflow-x: hidden; padding-right: 10px;">

                            <input type="hidden" name="accion" id="form-accion" value="guardar">
                            <input type="hidden" name="id" id="empleado-id" value="">

                            <div class="modal-form-grid">
                                <div class="full-width">
                                    <div class="dni-group">
                                        <md-outlined-text-field label="DNI" name="dni" id="input-dni" type="number"
                                            maxlength="8" required value="${empleado.dni}">
                                        </md-outlined-text-field>
                                        <md-filled-tonal-button type="button" id="btn-consultar-dni"
                                            style="height: 56px;">
                                            <md-icon>search</md-icon>
                                        </md-filled-tonal-button>
                                    </div>
                                    <div id="dniError">Este DNI ya está registrado.</div>
                                </div>

                                <md-outlined-text-field label="Nombres" name="nombres" id="input-nombres" required
                                    value="${empleado.nombres}"></md-outlined-text-field>
                                <md-outlined-text-field label="Apellidos" name="apellidos" id="input-apellidos" required
                                    value="${empleado.apellidos}"></md-outlined-text-field>
                                <md-outlined-text-field label="Sueldo Base (S/.)" name="sueldoBase" id="input-sueldo"
                                    type="number" step="0.01" value="${empleado.sueldoBase}"></md-outlined-text-field>

                                <div class="full-width">
                                    <md-outlined-select label="Rol" id="input-rol">
                                        <input type="hidden" name="rol" id="hidden-rol" value="EMPLEADO">
                                        <md-select-option value="EMPLEADO">
                                            <md-icon slot="start">badge</md-icon>
                                            <div slot="headline">Empleado</div>
                                            <div slot="supporting-text">Acceso solo a su perfil y asistencia</div>
                                        </md-select-option>
                                        <c:if test="${esSuperAdmin}">
                                            <md-select-option value="ADMIN">
                                                <md-icon slot="start">admin_panel_settings</md-icon>
                                                <div slot="headline">Administrador</div>
                                                <div slot="supporting-text">Administra empresas asignadas</div>
                                            </md-select-option>
                                        </c:if>
                                        <md-select-option value="EMPLEADO_RESTRINGIDO"></md-select-option>
                                        <md-icon slot="start">person_alert</md-icon>
                                        <div slot="headline">Empleado con permisos extra</div>
                                        <div slot="supporting-text">Empleado + permisos específicos</div>
                                        </md-select-option>
                                        <md-select-option value="ADMIN_RESTRINGIDO">
                                            <md-icon slot="start">admin_panel_settings</md-icon>
                                            <div slot="headline">Administrador restringido</div>
                                            <div slot="supporting-text">Admin con acceso limitado</div>
                                        </md-select-option>
                                    </md-outlined-select>

                                    <div id="modal-permisos-container"
                                        style="display: none; background: linear-gradient(135deg, var(--md-sys-color-surface-container-low) 0%, var(--md-sys-color-surface-container) 100%); padding: 20px; border-radius: 12px; margin-top: 16px; border: 1px solid var(--md-sys-color-outline-variant); box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 16px;">
                                            <span class="material-symbols-outlined"
                                                style="color: var(--md-sys-color-primary); font-size: 24px;">shield_person</span>
                                            <div>
                                                <p
                                                    style="margin: 0; font-weight: 600; color: var(--md-sys-color-on-surface); font-size: 0.95rem;">
                                                    Configurar Permisos</p>
                                                <p style="margin: 2px 0 0 0; font-size: 0.8rem; color: var(--md-sys-color-secondary);"
                                                    id="permisos-helper-text">Selecciona los módulos a los que tendrá
                                                    acceso</p>
                                            </div>
                                        </div>

                                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                                            <c:forEach var="p" items="${listaTodosPermisos}">
                                                <label
                                                    style="display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 10px 12px; background: var(--md-sys-color-surface); border-radius: 8px; border: 1px solid var(--md-sys-color-outline-variant); transition: all 0.2s;">
                                                    <md-checkbox value="${p.nombre}" data-permiso="${p.nombre}"
                                                        touch-target="wrapper"></md-checkbox>
                                                    <div style="flex: 1;">
                                                        <span
                                                            style="font-size: 0.9rem; font-weight: 500; color: var(--md-sys-color-on-surface);">${fn:replace(p.nombre,
                                                            '_', ' ')}</span>
                                                    </div>
                                                </label>
                                            </c:forEach>
                                        </div>

                                        <c:if test="${empty listaTodosPermisos}">
                                            <div
                                                style="text-align: center; padding: 24px; color: var(--md-sys-color-secondary);">
                                                <span class="material-symbols-outlined"
                                                    style="font-size: 32px; opacity: 0.5;">info</span>
                                                <p style="margin: 8px 0 0 0;">No hay permisos configurados en el
                                                    sistema.</p>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Sección de Asignación de Empresas (solo visible por SUPER_ADMIN para rol ADMIN) -->
                                    <c:if test="${esSuperAdmin}">
                                        <div id="modal-empresas-container" class="full-width"
                                            style="display: none; background: linear-gradient(135deg, var(--md-sys-color-surface-container-low) 0%, var(--md-sys-color-surface-container) 100%); padding: 20px; border-radius: 12px; margin-top: 16px; border: 1px solid var(--md-sys-color-outline-variant); box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 16px;">
                                                <span class="material-symbols-outlined"
                                                    style="color: var(--md-sys-color-primary); font-size: 24px;">business</span>
                                                <div>
                                                    <p
                                                        style="margin: 0; font-weight: 600; color: var(--md-sys-color-on-surface); font-size: 0.95rem;">
                                                        Asignar Empresas</p>
                                                    <p style="margin: 2px 0 0 0; font-size: 0.8rem; color: var(--md-sys-color-secondary);">
                                                        Selecciona las empresas que administrará</p>
                                                </div>
                                            </div>

                                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                                                <c:forEach var="emp" items="${listaTodasEmpresas}">
                                                    <label
                                                        style="display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 10px 12px; background: var(--md-sys-color-surface); border-radius: 8px; border: 1px solid var(--md-sys-color-outline-variant); transition: all 0.2s;">
                                                        <md-checkbox value="${emp.id}" data-empresa="${emp.id}"
                                                            touch-target="wrapper"></md-checkbox>
                                                        <div style="flex: 1;">
                                                            <span
                                                                style="font-size: 0.9rem; font-weight: 500; color: var(--md-sys-color-on-surface);">${emp.nombre}</span>
                                                        </div>
                                                    </label>
                                                </c:forEach>
                                            </div>

                                            <c:if test="${empty listaTodasEmpresas}">
                                                <div
                                                    style="text-align: center; padding: 24px; color: var(--md-sys-color-secondary);">
                                                    <span class="material-symbols-outlined"
                                                        style="font-size: 32px; opacity: 0.5;">info</span>
                                                    <p style="margin: 8px 0 0 0;">No hay empresas registradas.</p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </div>

                                <div>
                                    <md-outlined-select label="Modalidad" id="input-modalidad">
                                        <input type="hidden" name="tipoModalidad" id="hidden-modalidad"
                                            value="OBLIGADO">
                                        <md-select-option value="OBLIGADO" ${empleado.tipoModalidad=='OBLIGADO'
                                            ? 'selected' : '' }>
                                            <div slot="headline">OBLIGADO (Horario Rotativo)</div>
                                        </md-select-option>
                                        <md-select-option value="FIJO" ${empleado.tipoModalidad=='FIJO' ? 'selected'
                                            : '' }>
                                            <div slot="headline">FIJO (Rol Fijo)</div>
                                        </md-select-option>
                                        <md-select-option value="LIBRE" ${empleado.tipoModalidad=='LIBRE' ? 'selected'
                                            : '' }>
                                            <div slot="headline">LIBRE (Asistencia Libre)</div>
                                        </md-select-option>
                                    </md-outlined-select>
                                </div>

                                <div>
                                    <md-outlined-select label="Sucursal" id="input-sucursal">
                                        <md-select-option value="">
                                            <div slot="headline">-- Seleccionar --</div>
                                        </md-select-option>
                                        <c:forEach var="s" items="${listaSucursales}">
                                            <md-select-option value="${s.id}" ${empleado.sucursal !=null &&
                                                empleado.sucursal.id==s.id ? 'selected' : '' }>
                                                <div slot="headline">${s.nombre}</div>
                                            </md-select-option>
                                        </c:forEach>
                                    </md-outlined-select>
                                    <input type="hidden" name="sucursal.id" id="hidden-sucursal-id" value="">
                                    <p
                                        style="margin: 4px 0 0 4px; font-size: 0.75rem; color: var(--md-sys-color-secondary);">
                                        * Opcional</p>
                                </div>

                                <div class="full-width" id="password-container">
                                    <md-outlined-text-field label="Contraseña" name="password" id="input-password"
                                        type="password"></md-outlined-text-field>
                                </div>
                            </div>
                        </form>

                        <div slot="actions">
                            <md-text-button
                                onclick="document.getElementById('modal-empleado').close()">Cancelar</md-text-button>
                            <md-filled-button onclick="submitFormEmpleado()">Guardar</md-filled-button>
                        </div>
                    </md-dialog>

                    <md-dialog id="modal-eliminar" style="max-width: 400px;">
                        <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
                        <div slot="headline">¿Eliminar Empleado?</div>
                        <div slot="content">Esta acción no se puede deshacer. El empleado será eliminado permanentemente
                            del sistema.</div>

                        <form id="form-eliminar" method="post" action="empleados">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" id="id-eliminar">
                        </form>

                        <div slot="actions">
                            <md-text-button
                                onclick="document.getElementById('modal-eliminar').close()">Cancelar</md-text-button>
                            <md-filled-button onclick="document.getElementById('form-eliminar').submit()"
                                style="--md-filled-button-container-color: var(--md-sys-color-error);">
                                Eliminar
                            </md-filled-button>
                        </div>
                    </md-dialog>

                    <md-dialog id="modal-password" style="max-width: 400px;">
                        <md-icon slot="icon">lock_reset</md-icon>
                        <div slot="headline">Cambiar Contraseña</div>

                        <form slot="content" id="form-password" method="post" action="empleados">
                            <input type="hidden" name="accion" value="cambiarPassword">
                            <input type="hidden" name="id" id="id-password">
                            <p style="margin-bottom: 16px; color: var(--md-sys-color-secondary);">
                                Ingresa la nueva contraseña para <strong id="nombre-empleado-pwd"></strong>.
                            </p>
                            <md-outlined-text-field label="Nueva Contraseña" name="password" id="input-new-password"
                                type="password" required class="full-width">
                            </md-outlined-text-field>
                        </form>

                        <div slot="actions">
                            <md-text-button
                                onclick="document.getElementById('modal-password').close()">Cancelar</md-text-button>
                            <md-filled-button onclick="submitFormPassword()">Actualizar</md-filled-button>
                        </div>
                    </md-dialog>

                    <script>
                        // --- Modal Logic ---
                        const modalEmpleado = document.getElementById('modal-empleado');
                        const formEmpleado = document.getElementById('form-empleado');

                        function abrirModalNuevo() {
                            // Reset styling and content
                            document.getElementById('modal-title').innerText = "Nuevo Empleado";
                            document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "person_add";
                            document.getElementById('form-accion').value = "guardar";
                            document.getElementById('empleado-id').value = "0";

                            // Clear fields
                            formEmpleado.reset();

                            // Reset hidden inputs to default values
                            const hiddenRol = document.getElementById('hidden-rol');
                            if (hiddenRol) hiddenRol.value = 'EMPLEADO';

                            const hiddenModalidad = document.getElementById('hidden-modalidad');
                            if (hiddenModalidad) hiddenModalidad.value = 'OBLIGADO';

                            // Recreate hidden sucursal if it was removed
                            let hiddenSucursal = document.getElementById('hidden-sucursal-id');
                            if (!hiddenSucursal) {
                                hiddenSucursal = document.createElement('input');
                                hiddenSucursal.type = 'hidden';
                                hiddenSucursal.name = 'sucursal.id';
                                hiddenSucursal.id = 'hidden-sucursal-id';
                                hiddenSucursal.value = '';
                                document.getElementById('input-sucursal').parentElement.appendChild(hiddenSucursal);
                            }
                            hiddenSucursal.value = '';

                            // Reset Checkboxes Logic (Ocultar siempre al crear nuevo al principio)
                            const permisosDiv = document.getElementById('modal-permisos-container');
                            if (permisosDiv) {
                                permisosDiv.style.display = 'none';
                                // Uncheck all checkboxes
                                const checks = permisosDiv.querySelectorAll('md-checkbox');
                                checks.forEach(c => c.checked = false);
                            }

                            // Show Password and Enable it
                            const passContainer = document.getElementById('password-container');
                            const passInput = document.getElementById('input-password');
                            if (passContainer && passInput) {
                                passContainer.style.display = 'block';
                                passInput.required = true;
                                passInput.setAttribute('name', 'password');
                            }

                            modalEmpleado.show();
                        }

                        function submitFilter() {
                            document.getElementById('pageInput').value = 0;
                            document.getElementById('filterForm').submit();
                        }

                        function limpiarFiltros() {
                            document.getElementById('filterForm').reset();
                            const search = document.querySelector('md-outlined-text-field[name="keyword"]');
                            if (search) search.value = '';
                            const selects = document.querySelectorAll('md-outlined-select');
                            selects.forEach(s => s.selectIndex(0));
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
                            window.location.href = '${pageContext.request.contextPath}/empleados/export/excel';
                        }

                        function exportarPdf() {
                            window.location.href = '${pageContext.request.contextPath}/empleados/export/pdf';
                        }

                        function abrirModalEditar(btn) {
                            const data = btn.dataset;

                            document.getElementById('modal-title').innerText = "Editar Empleado";
                            document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "edit";
                            document.getElementById('form-accion').value = "guardar";
                            document.getElementById('empleado-id').value = data.id;

                            // Fill fields
                            document.getElementById('input-nombres').value = data.nombres;
                            document.getElementById('input-apellidos').value = data.apellidos;
                            document.getElementById('input-dni').value = data.dni;
                            document.getElementById('input-sueldo').value = data.sueldo;

                            // Selects and their hidden inputs
                            document.getElementById('input-rol').value = data.rol;
                            const hiddenRol = document.getElementById('hidden-rol');
                            if (hiddenRol) hiddenRol.value = data.rol || 'EMPLEADO';

                            document.getElementById('input-modalidad').value = data.modalidad;
                            const hiddenModalidad = document.getElementById('hidden-modalidad');
                            if (hiddenModalidad) hiddenModalidad.value = data.modalidad || 'OBLIGADO';

                            document.getElementById('input-sucursal').value = data.sucursal;
                            // Recreate hidden sucursal if it was removed
                            let hiddenSucursal = document.getElementById('hidden-sucursal-id');
                            if (!hiddenSucursal) {
                                hiddenSucursal = document.createElement('input');
                                hiddenSucursal.type = 'hidden';
                                hiddenSucursal.name = 'sucursal.id';
                                hiddenSucursal.id = 'hidden-sucursal-id';
                                document.getElementById('input-sucursal').parentElement.appendChild(hiddenSucursal);
                            }
                            hiddenSucursal.value = data.sucursal || '';

                            // LOGICA PERMISOS RESTRINGIDOS
                            const permisosDiv = document.getElementById('modal-permisos-container');
                            const permisosHelper = document.getElementById('permisos-helper-text');
                            if (permisosDiv) {
                                if (data.rol === 'ADMIN_RESTRINGIDO' || data.rol === 'EMPLEADO_RESTRINGIDO') {
                                    permisosDiv.style.display = 'block';
                                    if (permisosHelper) {
                                        permisosHelper.textContent = data.rol === 'ADMIN_RESTRINGIDO'
                                            ? 'Deselecciona los módulos que NO tendrá acceso'
                                            : 'Selecciona los permisos adicionales para este empleado';
                                    }
                                } else {
                                    permisosDiv.style.display = 'none';
                                }
                                // Uncheck all checkboxes by default when editing
                                const checks = permisosDiv.querySelectorAll('md-checkbox');
                                checks.forEach(c => c.checked = false);

                                // Mark existing permissions
                                if (data.permisos && data.permisos.trim() !== '') {
                                    const arr = data.permisos.split(',');

                                    // Usar setTimeout para asegurar que los componentes MD estén listos
                                    setTimeout(() => {
                                        arr.forEach(p => {
                                            const permisoTrimmed = p.trim();

                                            // Buscar por texto del label (Estrategia robusta para MD Web Components)
                                            const allLabels = permisosDiv.querySelectorAll('label');
                                            allLabels.forEach(label => {
                                                const texto = label.textContent.trim().replace(/ /g, '_');
                                                if (texto === permisoTrimmed) {
                                                    const chkInLabel = label.querySelector('md-checkbox');
                                                    if (chkInLabel) {
                                                        chkInLabel.checked = true;
                                                    }
                                                }
                                            });
                                        });
                                    }, 200);
                                }
                            }

                            // Hide Password
                            const passContainer = document.getElementById('password-container');
                            const passInput = document.getElementById('input-password');
                            passContainer.style.display = 'none';
                            passInput.required = false;
                            passInput.removeAttribute('name');

                            // Load assigned empresas for edit (SUPER_ADMIN)
                            const empresasContainer = document.getElementById('modal-empresas-container');
                            if (empresasContainer) {
                                // Uncheck all empresa checkboxes first
                                const empresaChecks = empresasContainer.querySelectorAll('md-checkbox');
                                empresaChecks.forEach(c => c.checked = false);

                                // Show container if editing an ADMIN
                                if (data.rol === 'ADMIN') {
                                    empresasContainer.style.display = 'block';
                                    // Check assigned empresas
                                    if (data.empresas && data.empresas.trim() !== '') {
                                        const empIds = data.empresas.split(',').map(id => id.trim());
                                        setTimeout(() => {
                                            empresaChecks.forEach(chk => {
                                                if (empIds.includes(chk.getAttribute('data-empresa'))) {
                                                    chk.checked = true;
                                                }
                                            });
                                        }, 200);
                                    }
                                } else {
                                    empresasContainer.style.display = 'none';
                                }
                            }

                            modalEmpleado.show();
                        }

                        function submitFormEmpleado() {
                            const required = ['input-nombres', 'input-apellidos', 'input-dni'];
                            let valid = true;
                            required.forEach(id => {
                                const el = document.getElementById(id);
                                if (!el.value) { el.error = true; valid = false; }
                                else { el.error = false; }
                            });

                            if (document.getElementById('password-container').style.display !== 'none') {
                                const pass = document.getElementById('input-password');
                                if (!pass.value) { pass.error = true; valid = false; }
                                else { pass.error = false; }
                            }

                            if (valid) {
                                // Copy values from md-outlined-select to hidden inputs
                                // This is necessary because Material Design Web components don't participate
                                // in form submission the same way native HTML elements do

                                // Handle rol
                                const rolSelect = document.getElementById('input-rol');
                                const hiddenRol = document.getElementById('hidden-rol');
                                if (rolSelect && hiddenRol) {
                                    hiddenRol.value = rolSelect.value || 'EMPLEADO';
                                }

                                // Handle modalidad
                                const modalidadSelect = document.getElementById('input-modalidad');
                                const hiddenModalidad = document.getElementById('hidden-modalidad');
                                if (modalidadSelect && hiddenModalidad) {
                                    hiddenModalidad.value = modalidadSelect.value || 'OBLIGADO';
                                }

                                // Manual handling for md-checkbox permissions
                                // Remove any existing hidden inputs for permissions to avoid duplicates
                                const existingHiddens = formEmpleado.querySelectorAll('input[type="hidden"][name="permisosSeleccionados"]');
                                existingHiddens.forEach(h => h.remove());

                                const permisosDiv = document.getElementById('modal-permisos-container');
                                if (permisosDiv && permisosDiv.style.display !== 'none') {
                                    const checkboxes = permisosDiv.querySelectorAll('md-checkbox');
                                    checkboxes.forEach(chk => {
                                        if (chk.checked) {
                                            const input = document.createElement('input');
                                            input.type = 'hidden';
                                            input.name = 'permisosSeleccionados';
                                            input.value = chk.value;
                                            formEmpleado.appendChild(input);
                                        }
                                    });
                                }

                                // Handle sucursal.id - copy value from md-outlined-select to hidden input
                                // If empty, remove the hidden input to avoid binding errors with empty string to Integer
                                const sucursalSelect = document.getElementById('input-sucursal');
                                const hiddenSucursal = document.getElementById('hidden-sucursal-id');

                                if (sucursalSelect && hiddenSucursal) {
                                    const sucursalValue = sucursalSelect.value;
                                    if (sucursalValue && sucursalValue !== '' && sucursalValue !== 'null') {
                                        hiddenSucursal.value = sucursalValue;
                                    } else {
                                        // Remove the hidden input to avoid sending empty sucursal.id
                                        hiddenSucursal.remove();
                                    }
                                }

                                // Handle empresas assignment (SUPER_ADMIN)
                                const empresasContainer = document.getElementById('modal-empresas-container');
                                const existingEmpresaHiddens = formEmpleado.querySelectorAll('input[type="hidden"][name="empresasSeleccionadas"]');
                                existingEmpresaHiddens.forEach(h => h.remove());

                                if (empresasContainer && empresasContainer.style.display !== 'none') {
                                    const empresaCheckboxes = empresasContainer.querySelectorAll('md-checkbox');
                                    empresaCheckboxes.forEach(chk => {
                                        if (chk.checked) {
                                            const input = document.createElement('input');
                                            input.type = 'hidden';
                                            input.name = 'empresasSeleccionadas';
                                            input.value = chk.getAttribute('data-empresa');
                                            formEmpleado.appendChild(input);
                                        }
                                    });
                                }

                                formEmpleado.submit();
                            }
                        }

                        function abrirModalEliminar(id) {
                            document.getElementById('id-eliminar').value = id;
                            document.getElementById('modal-eliminar').show();
                        }

                        function abrirModalPassword(id, nombres) {
                            document.getElementById('id-password').value = id;
                            document.getElementById('nombre-empleado-pwd').innerText = nombres;
                            document.getElementById('input-new-password').value = '';
                            document.getElementById('input-new-password').error = false;
                            document.getElementById('modal-password').show();
                        }

                        function submitFormPassword() {
                            const pass = document.getElementById('input-new-password');
                            if (!pass.value || pass.value.trim() === '') {
                                pass.error = true;
                                return;
                            }
                            document.getElementById('form-password').submit();
                        }

                        // --- GLOBAL FUNCTIONS ---

                        // Toast Helper (Global)
                        function showToast(title, message, type = 'info') {
                            const toast = document.createElement('div');
                            toast.className = `toast toast-${type}`;

                            let iconName = 'info';
                            if (type === 'success') iconName = 'check_circle';
                            if (type === 'error') iconName = 'error';
                            if (type === 'warning') iconName = 'warning';

                            toast.innerHTML = `
                    <div class="toast-icon"><span class="material-symbols-outlined">\${iconName}</span></div>
                    <div class="toast-content">
                        <div class="toast-title">\${title}</div>
                        <div class="toast-message">\${message}</div>
                    </div>
                    <div class="toast-progress"></div>
                `;

                            document.body.appendChild(toast);

                            // Trigger animation
                            requestAnimationFrame(() => {
                                toast.classList.add('show');
                            });

                            setTimeout(() => {
                                toast.classList.remove('show');
                                setTimeout(() => toast.remove(), 500);
                            }, 3000);
                        }

                        // --- LISTENERS EXTRA ---
                        document.addEventListener('DOMContentLoaded', () => {
                            // Fix for Material Design Dialog Scrim/Backdrop
                            if (typeof fixDialogScrim === 'function') {
                                fixDialogScrim(['modal-empleado', 'modal-eliminar', 'modal-password']);
                            }

                            // 1. DNI Logic
                            // 1. DNI Logic
                            const btnConsultar = document.getElementById('btn-consultar-dni');
                            const dniInput = document.getElementById('input-dni');
                            if (btnConsultar && dniInput) {
                                btnConsultar.addEventListener('click', async () => {
                                    const dni = dniInput.value;
                                    if (!dni || dni.length !== 8) {
                                        showToast('Error', 'El DNI debe tener 8 dígitos', 'error');
                                        return;
                                    }

                                    // UI Loading State
                                    const originalIcon = btnConsultar.innerHTML;
                                    btnConsultar.disabled = true;
                                    // Use inline HTML for spinner since we are inside a module script scope effectively (or just global)
                                    btnConsultar.innerHTML = '<span class="material-symbols-outlined" style="animation: spin 1s linear infinite;">refresh</span>';

                                    try {
                                        // Check context path availability. If outside JSP scope, hardcode or get from meta. 
                                        // Fortunately this is inside the JSP file.
                                        const response = await fetch('${pageContext.request.contextPath}/api/dni/' + dni);
                                        const data = await response.json();

                                        if (data.ok && data.datos) {
                                            document.getElementById('input-nombres').value = data.datos.nombres;
                                            const apellidos = data.datos.apePaterno + (data.datos.apeMaterno ? ' ' + data.datos.apeMaterno : '');
                                            document.getElementById('input-apellidos').value = apellidos;

                                            // Auto-focus next field
                                            document.getElementById('input-sueldo').focus();
                                            showToast('Éxito', 'Datos encontrados correctamente', 'success');
                                            document.getElementById('dniError').style.display = 'none';
                                        } else {
                                            showToast('Atención', data.mensaje || 'No se encontraron datos', 'warning');
                                            document.getElementById('dniError').innerText = data.mensaje || 'No encontrado';
                                            document.getElementById('dniError').style.display = 'block';
                                        }
                                    } catch (error) {
                                        console.error(error);
                                        showToast('Error', 'Error de conexión con el servicio', 'error');
                                    } finally {
                                        btnConsultar.disabled = false;
                                        btnConsultar.innerHTML = originalIcon;
                                    }
                                });
                            }



                            // Simple spinner animation style if not present
                            if (!document.getElementById('spinner-style')) {
                                const style = document.createElement('style');
                                style.id = 'spinner-style';
                                style.innerHTML = '@keyframes spin { 100% { transform: rotate(360deg); } }';
                                document.head.appendChild(style);
                            }

                            // 2. ROL CHANGE LISTENER (Mostrar/Ocultar Checkboxes)
                            const inputRol = document.getElementById('input-rol');
                            const permisosDiv = document.getElementById('modal-permisos-container');
                            const permisosHelper = document.getElementById('permisos-helper-text');

                            if (inputRol && permisosDiv) {
                                inputRol.addEventListener('change', () => {
                                    const rolValue = inputRol.value;
                                    if (rolValue === 'ADMIN_RESTRINGIDO' || rolValue === 'EMPLEADO_RESTRINGIDO') {
                                        permisosDiv.style.display = 'block';
                                        // Update helper text based on role
                                        if (permisosHelper) {
                                            if (rolValue === 'ADMIN_RESTRINGIDO') {
                                                permisosHelper.textContent = 'Deselecciona los módulos que NO tendrá acceso';
                                            } else {
                                                permisosHelper.textContent = 'Selecciona los permisos adicionales para este empleado';
                                            }
                                        }
                                    } else {
                                        permisosDiv.style.display = 'none';
                                        // Opcional: Desmarcar checkboxes
                                        const checks = permisosDiv.querySelectorAll('md-checkbox');
                                        checks.forEach(c => c.checked = false);
                                    }

                                    // Mostrar/ocultar panel de empresas según rol
                                    const empresasDiv = document.getElementById('modal-empresas-container');
                                    if (empresasDiv) {
                                        if (rolValue === 'ADMIN') {
                                            empresasDiv.style.display = 'block';
                                        } else {
                                            empresasDiv.style.display = 'none';
                                            // Desmarcar empresa checkboxes
                                            const empChecks = empresasDiv.querySelectorAll('md-checkbox');
                                            empChecks.forEach(c => c.checked = false);
                                        }
                                    }
                                });
                            }
                        });

                        // --- AUTO OPEN MODAL ON ERROR ---
                        document.addEventListener('DOMContentLoaded', () => {
                            <c:if test="${not empty abrirModal}">
                                const modal = document.getElementById('modal-empleado');
                                const empId = "${empleado.id}";

                                if(empId && empId !== '0' && empId !== '') {
                                    document.getElementById('modal-title').innerText = "Editar Empleado";
                                document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "edit";
                                document.getElementById('empleado-id').value = empId;
                                document.getElementById('form-accion').value = "guardar";
                    } else {
                                    document.getElementById('modal-title').innerText = "Nuevo Empleado";
                                document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "person_add";
                                document.getElementById('empleado-id').value = "0";
                                document.getElementById('form-accion').value = "guardar";
                    }

                                // Handle Permissions Persistence for restricted role logic
                                const inputRol = document.getElementById('input-rol');
                                const permisosDiv = document.getElementById('modal-permisos-container');

                                if(inputRol && (inputRol.value === 'ADMIN_RESTRINGIDO' || inputRol.value === 'EMPLEADO_RESTRINGIDO')) {
                                    permisosDiv.style.display = 'block';
                         // Since we don't easily pass checkboxes list back via simple EL to checked attr here without looping,
                         // users might need to re-select exact perms if they made a mistake. 
                         // But we can add a toast to remind them.
                    }

                                modal.show();

                                <c:if test="${not empty error}">
                         // Use a timeout to ensure toast renders after layout
                         setTimeout(() => showToast('Atención', '${error}', 'warning'), 500);
                                </c:if>
                            </c:if>
                        });
                    </script>
                </div>
                <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
            </body>

            </html>
