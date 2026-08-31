<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Empresas</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <!-- SheetJS for Excel export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <!-- jsPDF for PDF export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
    
    <script type="importmap">
        { "imports": { "@material/web/": "https://esm.run/@material/web/" } }
    </script>
    <script type="module">
        import '@material/web/all.js';
        import { styles as typescaleStyles } from '@material/web/typography/md-typescale-styles.js';
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
        
        /* View Toggle */
        .view-toggle {
            display: flex;
            background-color: var(--md-sys-color-surface-container-high);
            border-radius: 24px;
            padding: 4px;
            gap: 4px;
        }
        
        /* ==================== Cards Grid ==================== */
        .empresas-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .empresa-card {
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: 16px;
            background: var(--md-sys-color-surface);
            overflow: visible;
            transition: transform 0.2s, box-shadow 0.2s;
            animation: fadeIn 0.4s ease backwards;
            position: relative;
        }
        
        .empresa-card:nth-child(1) { animation-delay: 0.05s; }
        .empresa-card:nth-child(2) { animation-delay: 0.1s; }
        .empresa-card:nth-child(3) { animation-delay: 0.15s; }
        .empresa-card:nth-child(4) { animation-delay: 0.2s; }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .empresa-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--md-sys-elevation-2);
        }
        
        /* Card Header with color band */
        .empresa-card-header {
            position: relative;
            height: 80px;
            border-radius: 16px 16px 0 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        /* Circle container for logo - positioned between header and body */
        .empresa-logo-circle {
            position: absolute;
            bottom: -45px;
            left: 50%;
            transform: translateX(-50%);
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: #ffffff;
            border: 4px solid var(--md-sys-color-surface);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            z-index: 10;
        }
        
        .empresa-logo-circle img {
            max-height: 60px;
            max-width: 60px;
            object-fit: contain;
        }
        
        .empresa-logo-circle .material-symbols-outlined {
            font-size: 40px;
            color: var(--md-sys-color-on-surface-variant);
        }
        
        .empresa-badge-principal {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(255,255,255,0.95);
            color: #7c4dff;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.7rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 4px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        }
        
        .empresa-badge-principal .material-symbols-outlined {
            font-size: 13px;
            color: #7c4dff;
        }
        
        .empresa-card-body {
            padding: 60px 16px 16px 16px; /* Extra padding top for logo circle */
            text-align: center;
            background: var(--md-sys-color-surface-container);
            border-radius: 0 0 16px 16px;
        }
        
        .empresa-card-nombre {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--md-sys-color-on-surface);
            margin: 0 0 6px 0;
        }
        
        .empresa-card-codigo {
            font-size: 0.8rem;
            color: var(--md-sys-color-on-surface-variant);
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-family: monospace;
            background: var(--md-sys-color-surface);
            padding: 3px 10px;
            border-radius: 6px;
            margin-bottom: 12px;
        }
        
        .empresa-card-colors {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-bottom: 12px;
        }
        
        .color-dot {
            width: 24px;
            height: 24px;
            border-radius: 6px;
            border: 2px solid var(--md-sys-color-surface);
            box-shadow: 0 1px 4px rgba(0,0,0,0.2);
        }
        
        .empresa-card-actions {
            display: flex;
            justify-content: center;
            gap: 6px;
            padding-top: 12px;
            border-top: 1px solid var(--md-sys-color-outline-variant);
        }
        
        /* ==================== Table View ==================== */
        .table-logo-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .table-logo-preview {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .table-logo-preview img {
            max-width: 28px;
            max-height: 28px;
            object-fit: contain;
            filter: brightness(0) invert(1);
        }
        
        .table-colors {
            display: flex;
            gap: 6px;
        }
        
        .badge {
            padding: 4px 12px;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .badge-principal {
            background: var(--md-sys-color-primary-container);
            color: var(--md-sys-color-on-primary-container);
        }
        
        /* Logo Upload Area */
        .logo-upload-area {
            border: 2px dashed var(--md-sys-color-outline-variant);
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
            background: var(--md-sys-color-surface-container);
            position: relative;
            min-height: 120px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        
        .logo-upload-area:hover {
            border-color: var(--md-sys-color-primary);
            background: var(--md-sys-color-surface-container-high);
        }
        
        .logo-upload-area.has-file {
            border-style: solid;
            border-color: var(--md-sys-color-primary);
        }
        
        .logo-upload-area.dragover {
            border-color: var(--md-sys-color-primary);
            background: var(--md-sys-color-primary-container);
        }
        
        /* View switching */
        .view-cards { display: grid; }
        .view-table { display: none; }
        
        [data-view="table"] .view-cards { display: none; }
        [data-view="table"] .view-table { display: block; }
        
        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
        }
        
        .empty-state-icon {
            width: 100px;
            height: 100px;
            background: var(--md-sys-color-surface-container);
            border-radius: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
        }
        
        .empty-state-icon .material-symbols-outlined {
            font-size: 48px;
            color: var(--md-sys-color-on-surface-variant);
        }
        
        .empty-state h3 {
            font-size: 1.5rem;
            color: var(--md-sys-color-on-surface);
            margin: 0 0 8px;
        }
        
        .empty-state p {
            color: var(--md-sys-color-on-surface-variant);
            margin-bottom: 24px;
        }
        
        /* Animation */
        @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
        .fade-in { animation: fade-in 0.3s ease-out forwards; }
        
        /* Modal form styles */
        .modal-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .full-width { grid-column: span 2; }
        md-outlined-text-field, md-outlined-select { width: 100%; }
        
        .color-section { margin-top: 16px; }
        .variant-preview {
            width: 44px;
            height: 44px;
            background: var(--md-sys-color-surface-container-high);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
            border: 1px solid var(--md-sys-color-outline-variant);
        }
        .variant-preview img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .color-section-title {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--md-sys-color-primary);
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .color-picker-row { display: flex; gap: 20px; }
        .color-picker-item { flex: 1; }
        .color-picker-item label {
            font-size: 0.8rem;
            color: var(--md-sys-color-on-surface-variant);
            display: block;
            margin-bottom: 8px;
        }
        .color-input-wrap { display: flex; align-items: center; gap: 10px; }
        input[type="color"] {
            width: 44px;
            height: 44px;
            border: 2px solid var(--md-sys-color-outline-variant);
            border-radius: 10px;
            cursor: pointer;
            padding: 2px;
            background: var(--md-sys-color-surface);
        }
        input[type="color"]:hover { border-color: var(--md-sys-color-primary); }
        .color-hex {
            font-family: monospace;
            font-size: 0.85rem;
            color: var(--md-sys-color-on-surface-variant);
            background: var(--md-sys-color-surface-container);
            padding: 5px 8px;
            border-radius: 6px;
        }
        .preview-card {
            margin-top: 16px;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            color: white;
        }
        .preview-label { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 1px; opacity: 0.8; }
        .preview-name { font-size: 1rem; font-weight: 600; }
        .variant-preview {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            background: var(--md-sys-color-surface-container-high);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
            border: 1px solid var(--md-sys-color-outline-variant);
        }
        .variant-preview img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: none;
        }
        .variant-preview .material-symbols-outlined {
            font-size: 22px;
            color: var(--md-sys-color-on-surface-variant);
            display: inline-flex;
        }
        .file-info {
            margin-top: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.8rem;
            color: var(--md-sys-color-on-surface-variant);
            background: var(--md-sys-color-surface-container);
            padding: 10px 14px;
            border-radius: 10px;
        }
        .file-info .material-symbols-outlined { font-size: 16px; color: var(--md-sys-color-primary); }
        .file-info code { background: var(--md-sys-color-surface); padding: 2px 6px; border-radius: 4px; }
        .checkbox-row {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            background: var(--md-sys-color-surface-container);
            border-radius: 12px;
            margin-top: 16px;
        }
        .checkbox-row label { font-size: 0.9rem; color: var(--md-sys-color-on-surface); }
        
        @media (max-width: 600px) {
            .empresas-grid { grid-template-columns: 1fr; }
            .modal-form-grid { grid-template-columns: 1fr; }
            .full-width { grid-column: span 1; }
            .color-picker-row { flex-direction: column; gap: 12px; }
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
        
        <div class="container" id="pageContent" data-view="cards">
            <!-- Page Header -->
            <div class="page-header" style="flex-wrap: wrap; gap: 16px;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Gestión de Empresas</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Administra las empresas del sistema</p>
                </div>
                <div style="display: flex; gap: 12px; align-items: center;">
                    <div class="view-toggle">
                        <md-icon-button id="btn-card-view" title="Vista de Tarjetas" onclick="switchView('cards')">
                            <md-icon>grid_view</md-icon>
                        </md-icon-button>
                        <md-icon-button id="btn-table-view" title="Vista de Tabla" onclick="switchView('table')">
                            <md-icon>table_rows</md-icon>
                        </md-icon-button>
                    </div>
                    <md-outlined-button onclick="exportarExcel()">
                        <md-icon slot="icon">grid_on</md-icon>
                        Exportar Excel
                    </md-outlined-button>
                    <md-filled-tonal-button onclick="exportarPdf()">
                        <md-icon slot="icon">picture_as_pdf</md-icon>
                        Exportar PDF
                    </md-filled-tonal-button>
                    <md-filled-button onclick="abrirModalNuevo()">
                        <md-icon slot="icon">add</md-icon>
                        Nueva Empresa
                    </md-filled-button>
                </div>
            </div>
            
            <!-- Filters -->
            <div class="card" style="margin-bottom: 24px; padding: 24px;">
                <form id="filterForm" action="${pageContext.request.contextPath}/empresas/filter" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
                    <div style="display: grid; grid-template-columns: 1fr auto; gap: 16px; align-items: center;">
                        <md-outlined-text-field 
                            label="Buscar" 
                            name="keyword"
                            id="searchInput"
                            value="${keyword}"
                            placeholder="Nombre, Código o RUC..." 
                            style="width: 100%;"
                            onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                            <md-icon slot="leading-icon">search</md-icon>
                        </md-outlined-text-field>
                        
                        <md-filled-button type="button" onclick="submitFilter()" style="height: 56px;">
                            <md-icon slot="icon">filter_list</md-icon>
                            Filtrar
                        </md-filled-button>
                    </div>
                </form>
            </div>
            
            <c:choose>
                <c:when test="${not empty empresas}">
                    <!-- Cards View -->
                    <div class="empresas-grid view-cards" id="empresasGrid">
                    <c:forEach var="empresa" items="${empresas}">
                            <div class="empresa-card empresa-card-item" 
                                 data-id="${empresa.id}" 
                                 data-codigo="${empresa.codigo}" 
                                 data-nombre="${empresa.nombre}" 
                                 data-color-primario="${empresa.colorPrimario}" 
                                 data-color-secundario="${empresa.colorSecundario}"
                                 data-logo-path="${empresa.logoPath}" 
                                 data-icon-path="${empresa.iconPath}" 
                                 data-es-principal="${empresa.esPrincipal}"
                                 data-ruc="${empresa.ruc}"
                                 data-sector="${empresa.sector}"
                                 data-logo-dark-path="${empresa.logoDarkPath}" 
                                 data-icon-dark-path="${empresa.iconDarkPath}" 
                                 data-usar-mismo-logo-oscuro="${empresa.usarMismoLogoOscuro}" 
                                 data-usar-mismo-icono-oscuro="${empresa.usarMismoIconoOscuro}">
                                <div class="empresa-card-header" style="background: linear-gradient(135deg, ${empresa.colorPrimario} 0%, ${empresa.colorSecundario} 100%);">
                                    <c:if test="${empresa.esPrincipal}">
                                        <span class="empresa-badge-principal">
                                            <span class="material-symbols-outlined">star</span>
                                            Principal
                                        </span>
                                    </c:if>
                                    <div class="empresa-logo-circle">
                                        <c:if test="${not empty empresa.logoPath}">
                                            <img src="${pageContext.request.contextPath}/uploads/logos/${empresa.logoPath}" alt="${empresa.nombre}">
                                        </c:if>
                                        <c:if test="${empty empresa.logoPath}">
                                            <span class="material-symbols-outlined">domain</span>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="empresa-card-body">
                                    <h3 class="empresa-card-nombre">${empresa.nombre}</h3>
                                    <span class="empresa-card-codigo">
                                        <span class="material-symbols-outlined" style="font-size: 13px;">tag</span>
                                        ${empresa.codigo}
                                    </span>
                                    <div class="empresa-card-colors">
                                        <div class="color-dot" style="background: ${empresa.colorPrimario};" title="Primario"></div>
                                        <div class="color-dot" style="background: ${empresa.colorSecundario};" title="Secundario"></div>
                                    </div>
                                    <div class="empresa-card-actions">
                                        <md-icon-button title="Editar" onclick="abrirModalEditar(${empresa.id})">
                                            <md-icon>edit</md-icon>
                                        </md-icon-button>
                                        <c:if test="${not empresa.esPrincipal}">
                                            <md-icon-button title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);" 
                                                           onclick="abrirModalEliminar(${empresa.id}, '${empresa.nombre}')">
                                                <md-icon>delete</md-icon>
                                            </md-icon-button>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- Table View -->
                    <div class="card view-table fade-in">
                        <div class="table-container">
                            <table class="compact-table" style="width: 100%;">
                                <thead>
                                    <tr>
                                        <th style="width: 250px;">Empresa</th>
                                        <th style="width: 120px;">Código</th>
                                        <th style="width: 100px;">Colores</th>
                                        <th style="width: 100px;">Estado</th>
                                        <th style="width: 100px; text-align: center;">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="empresa" items="${empresas}">
                                        <tr class="empresa-table-item"
                                            data-id="${empresa.id}" 
                                            data-codigo="${empresa.codigo}" 
                                            data-nombre="${empresa.nombre}" 
                                            data-color-primario="${empresa.colorPrimario}" 
                                            data-color-secundario="${empresa.colorSecundario}"
                                            data-logo-path="${empresa.logoPath}" 
                                            data-icon-path="${empresa.iconPath}" 
                                            data-es-principal="${empresa.esPrincipal}"
                                            data-ruc="${empresa.ruc}"
                                            data-sector="${empresa.sector}"
                                 data-logo-dark-path="${empresa.logoDarkPath}" 
                                 data-icon-dark-path="${empresa.iconDarkPath}" 
                                 data-usar-mismo-logo-oscuro="${empresa.usarMismoLogoOscuro}" 
                                 data-usar-mismo-icono-oscuro="${empresa.usarMismoIconoOscuro}">
                                            <td>
                                                <div class="table-logo-cell">
                                                    <div class="table-logo-preview" style="background: linear-gradient(135deg, ${empresa.colorPrimario} 0%, ${empresa.colorSecundario} 100%);">
                                                        <c:if test="${not empty empresa.logoPath}">
                                                            <img src="${pageContext.request.contextPath}/uploads/logos/${empresa.logoPath}" alt="${empresa.nombre}">
                                                        </c:if>
                                                        <c:if test="${empty empresa.logoPath}">
                                                            <span class="material-symbols-outlined" style="color: white; font-size: 22px;">domain</span>
                                                        </c:if>
                                                    </div>
                                                    <div style="font-weight: 500;">${empresa.nombre}</div>
                                                </div>
                                            </td>
                                            <td style="font-family: monospace;">${empresa.codigo}</td>
                                            <td>
                                                <div class="table-colors">
                                                    <div class="color-dot" style="background: ${empresa.colorPrimario};"></div>
                                                    <div class="color-dot" style="background: ${empresa.colorSecundario};"></div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:if test="${empresa.esPrincipal}">
                                                    <span class="badge badge-principal">
                                                        <span class="material-symbols-outlined" style="font-size: 14px;">star</span>
                                                        Principal
                                                    </span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div class="actions-cell">
                                                    <md-icon-button title="Editar" onclick="abrirModalEditar(${empresa.id})">
                                                        <md-icon>edit</md-icon>
                                                    </md-icon-button>
                                                    <c:if test="${not empresa.esPrincipal}">
                                                        <md-icon-button title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);"
                                                                       onclick="abrirModalEliminar(${empresa.id}, '${empresa.nombre}')">
                                                            <md-icon>delete</md-icon>
                                                        </md-icon-button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        </div>
                        
                        <!-- Pagination Controls -->
                        <div class="card" style="margin-top: 16px; padding: 16px 24px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px;">
                            <div style="display: flex; align-items: center; gap: 24px;">
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
                                <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                                    ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number + 1) * size} de ${pagina.totalElements}
                                </div>
                            </div>

                            <div style="display: flex; align-items: center; gap: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                        <md-icon>chevron_left</md-icon>
                                    </md-icon-button>
                                    <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                        <md-icon>chevron_right</md-icon>
                                    </md-icon-button>
                                </div>
                                <div style="display: flex; align-items: center; gap: 12px; padding-left: 16px; border-left: 1px solid var(--md-sys-color-outline-variant);">
                                    <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); white-space: nowrap;">Ir a página</span>
                                    <md-outlined-text-field type="number" min="1" max="${pagina.totalPages}"
                                        onkeydown="if(event.key === 'Enter') changePage(this.value - 1)"
                                        placeholder="${pagina.number + 1}" style="width: 80px;">
                                    </md-outlined-text-field>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <span class="material-symbols-outlined">domain_add</span>
                        </div>
                        <h3>No hay empresas registradas</h3>
                        <p>Comienza agregando tu primera empresa al sistema</p>
                        <md-filled-button onclick="abrirModalNuevo()">
                            <md-icon slot="icon">add</md-icon>
                            Agregar Primera Empresa
                        </md-filled-button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <!-- Modal Crear/Editar -->
    <md-dialog id="modal-empresa" style="min-width: 500px; max-width: 550px;">
        <md-icon slot="icon" id="modal-icon">domain_add</md-icon>
        <div slot="headline" id="modal-title">Nueva Empresa</div>
        
        <form slot="content" id="form-empresa" method="dialog" style="max-height: 55vh; overflow-y: auto; padding-right: 8px;">
            <input type="hidden" id="empresa-id" value="">
            
            <div class="modal-form-grid">
                <md-outlined-text-field id="input-codigo" label="Código" required maxlength="20" placeholder="Ej: PERUANA"></md-outlined-text-field>
                <md-outlined-text-field id="input-nombre" label="Nombre" required maxlength="100" placeholder="Ej: La Peruana"></md-outlined-text-field>
                <md-outlined-text-field id="input-ruc" label="RUC" maxlength="11" placeholder="Ej: 20123456789" type="number"></md-outlined-text-field>
                <md-outlined-text-field id="input-sector" label="Sector" maxlength="50" placeholder="Ej: Tecnología"></md-outlined-text-field>
            </div>
            
            <div class="color-section">
                <div class="color-section-title">
                    <span class="material-symbols-outlined">palette</span>
                    Colores de Marca
                </div>
                <div class="color-picker-row">
                    <div class="color-picker-item">
                        <label>Color Primario</label>
                        <div class="color-input-wrap">
                            <input type="color" id="input-color-primario" value="#EC407A" onchange="actualizarPreview()">
                            <span class="color-hex" id="hex-primario">#EC407A</span>
                        </div>
                    </div>
                    <div class="color-picker-item">
                        <label>Color Secundario</label>
                        <div class="color-input-wrap">
                            <input type="color" id="input-color-secundario" value="#BA68C8" onchange="actualizarPreview()">
                            <span class="color-hex" id="hex-secundario">#BA68C8</span>
                        </div>
                    </div>
                </div>
                <div class="preview-card" id="preview-card" style="background: linear-gradient(135deg, #EC407A 0%, #BA68C8 100%);">
                    <div class="preview-label">Vista Previa</div>
                    <div class="preview-name" id="preview-nombre">Nueva Empresa</div>
                </div>
            </div>
            
            <div class="logo-upload-section" style="margin-top: 16px;">
                <div class="color-section-title">
                    <span class="material-symbols-outlined">photo_library</span>
                    Imágenes de Marca (Light / Dark)
                </div>
                <input type="hidden" id="input-logo-path" value="">
                <input type="hidden" id="input-logo-dark-path" value="">
                <input type="hidden" id="input-icon-path" value="">
                <input type="hidden" id="input-icon-dark-path" value="">

                <div style="display:grid; gap: 12px;">
                    <div class="file-info">
                        <div class="variant-preview">
                            <img id="preview-logo-light" alt="Preview logo light">
                            <span class="material-symbols-outlined" id="placeholder-logo-light">image</span>
                        </div>
                        <span class="material-symbols-outlined">image</span>
                        <strong>Logo Light:</strong>
                        <code id="label-logo-light">(sin imagen)</code>
                        <input type="file" id="input-logo-light-file" accept="image/*" style="display:none;" onchange="handleVariantFile('logoLight', this)">
                        <md-outlined-button type="button" onclick="document.getElementById('input-logo-light-file').click()">
                            <md-icon slot="icon">upload</md-icon>
                            Subir
                        </md-outlined-button>
                    </div>

                    <div class="checkbox-row" style="margin-top: 0;">
                        <md-checkbox id="input-usar-mismo-logo-oscuro" checked onchange="toggleDarkImageConfig()"></md-checkbox>
                        <label>Usar el mismo logo para modo oscuro</label>
                    </div>

                    <div class="file-info" id="row-logo-dark">
                        <div class="variant-preview">
                            <img id="preview-logo-dark" alt="Preview logo dark">
                            <span class="material-symbols-outlined" id="placeholder-logo-dark">dark_mode</span>
                        </div>
                        <span class="material-symbols-outlined">dark_mode</span>
                        <strong>Logo Dark:</strong>
                        <code id="label-logo-dark">(igual que light)</code>
                        <input type="file" id="input-logo-dark-file" accept="image/*" style="display:none;" onchange="handleVariantFile('logoDark', this)">
                        <md-outlined-button type="button" id="btn-logo-dark-upload" onclick="document.getElementById('input-logo-dark-file').click()">
                            <md-icon slot="icon">upload</md-icon>
                            Subir
                        </md-outlined-button>
                    </div>

                    <div class="file-info">
                        <div class="variant-preview">
                            <img id="preview-icon-light" alt="Preview icono light">
                            <span class="material-symbols-outlined" id="placeholder-icon-light">apps</span>
                        </div>
                        <span class="material-symbols-outlined">apps</span>
                        <strong>Icono Light:</strong>
                        <code id="label-icon-light">(sin imagen)</code>
                        <input type="file" id="input-icon-light-file" accept="image/*" style="display:none;" onchange="handleVariantFile('iconLight', this)">
                        <md-outlined-button type="button" onclick="document.getElementById('input-icon-light-file').click()">
                            <md-icon slot="icon">upload</md-icon>
                            Subir
                        </md-outlined-button>
                    </div>

                    <div class="checkbox-row" style="margin-top: 0;">
                        <md-checkbox id="input-usar-mismo-icono-oscuro" checked onchange="toggleDarkImageConfig()"></md-checkbox>
                        <label>Usar el mismo icono para modo oscuro</label>
                    </div>

                    <div class="file-info" id="row-icon-dark">
                        <div class="variant-preview">
                            <img id="preview-icon-dark" alt="Preview icono dark">
                            <span class="material-symbols-outlined" id="placeholder-icon-dark">dark_mode</span>
                        </div>
                        <span class="material-symbols-outlined">dark_mode</span>
                        <strong>Icono Dark:</strong>
                        <code id="label-icon-dark">(igual que light)</code>
                        <input type="file" id="input-icon-dark-file" accept="image/*" style="display:none;" onchange="handleVariantFile('iconDark', this)">
                        <md-outlined-button type="button" id="btn-icon-dark-upload" onclick="document.getElementById('input-icon-dark-file').click()">
                            <md-icon slot="icon">upload</md-icon>
                            Subir
                        </md-outlined-button>
                    </div>
                </div>
            </div>
            
            <div class="checkbox-row">
                <md-checkbox id="input-es-principal"></md-checkbox>
                <label>Marcar como empresa principal</label>
            </div>
        </form>
        
        <div slot="actions">
            <md-text-button type="button" onclick="document.getElementById('modal-empresa').close()">Cancelar</md-text-button>
            <md-filled-button type="button" onclick="guardarEmpresa()">Guardar</md-filled-button>
        </div>
    </md-dialog>
    
    <!-- Modal Eliminar -->
    <md-dialog id="modal-eliminar" style="max-width: 400px;">
        <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
        <div slot="headline">¿Eliminar Empresa?</div>
        <div slot="content">
            Esta acción no se puede deshacer. La empresa <strong id="delete-empresa-nombre"></strong> será eliminada permanentemente.
        </div>
        <div slot="actions">
            <md-text-button onclick="document.getElementById('modal-eliminar').close()">Cancelar</md-text-button>
            <md-filled-button id="btn-confirm-delete" style="--md-filled-button-container-color: var(--md-sys-color-error);">Eliminar</md-filled-button>
        </div>
    </md-dialog>
    
    <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        // GLOBAL STATE
        let currentEditingId = null; // Renamed to avoid confusion
        let currentDeleteId = null;
        let currentView = localStorage.getItem('empresasView') || 'cards';
        
        // Apply dialog scrim (blur backdrop) fix
        document.addEventListener('DOMContentLoaded', () => {
            fixDialogScrim(['modal-empresa', 'modal-eliminar']);
            updateViewUI();
        });
        
        // ==================== View Switcher ====================
        function switchView(mode) {
            currentView = mode;
            localStorage.setItem('empresasView', mode);
            updateViewUI();
        }
        
        function updateViewUI() {
            const pageContent = document.getElementById('pageContent');
            pageContent.dataset.view = currentView;
            
            const btnCard = document.getElementById('btn-card-view');
            const btnTable = document.getElementById('btn-table-view');
            
            if (currentView === 'table') {
                btnTable.variant = 'filled-tonal';
                btnCard.variant = 'standard';
            } else {
                btnCard.variant = 'filled-tonal';
                btnTable.variant = 'standard';
            }
        }
        
        // ==================== Filter & Pagination ====================
        function submitFilter() {
            document.getElementById('pageInput').value = 0;
            document.getElementById('filterForm').submit();
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
        
        function limpiarFiltros() {
            const searchInput = document.getElementById('searchInput');
            if(searchInput) searchInput.value = '';
            submitFilter();
        }
        
        // ==================== Export Excel ====================
        function exportarExcel() {
            const { utils, writeFile } = XLSX;
            const data = [];
            
            document.querySelectorAll('.empresa-card-item').forEach(item => {
                if (item.style.display !== 'none') {
                    data.push({
                        'Código': item.dataset.codigo,
                        'Nombre de Empresa': item.dataset.nombre,
                        'Color Primario': item.dataset.colorPrimario,
                        'Color Secundario': item.dataset.colorSecundario,
                        'Logo': item.dataset.logoPath || '(Sin logo)',
                        'Empresa Principal': item.dataset.esPrincipal === 'true' ? '✓ Sí' : 'No'
                    });
                }
            });
            
            if (data.length === 0) {
                showToast('Sin datos', 'No hay empresas para exportar', 'warning', 'warning');
                return;
            }
            
            const ws = utils.json_to_sheet(data);
            const wb = utils.book_new();
            utils.book_append_sheet(wb, ws, 'Empresas');
            
            // Ajustar ancho de columnas para mejor visualización
            ws['!cols'] = [
                { wch: 15 },  // Código
                { wch: 30 },  // Nombre
                { wch: 12 },  // Color Primario  
                { wch: 12 },  // Color Secundario
                { wch: 20 },  // Logo
                { wch: 15 }   // Principal
            ];
            
            const fecha = new Date().toISOString().split('T')[0];
            writeFile(wb, `Empresas_GPA_${fecha}.xlsx`);
            showToast('Excel Exportado', `Se exportaron ${data.length} empresas`, 'success', 'download_done');
        }
        
        // ==================== Export PDF ====================
        function exportarPdf() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('p', 'mm', 'a4');
            
            const data = [];
            let empresaPrincipal = null;
            
            document.querySelectorAll('.empresa-card-item').forEach(item => {
                if (item.style.display !== 'none') {
                    const esPrincipal = item.dataset.esPrincipal === 'true';
                    if (esPrincipal) empresaPrincipal = item.dataset.nombre;
                    
                    data.push([
                        item.dataset.codigo,
                        item.dataset.nombre,
                        item.dataset.colorPrimario,
                        item.dataset.colorSecundario,
                        esPrincipal ? '✓' : ''
                    ]);
                }
            });
            
            if (data.length === 0) {
                showToast('Sin datos', 'No hay empresas para exportar', 'warning', 'warning');
                return;
            }
            
            // Header con gradiente
            doc.setFillColor(103, 80, 164);
            doc.rect(0, 0, 210, 40, 'F');
            
            // Título
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(22);
            doc.setFont(undefined, 'bold');
            doc.text('Listado de Empresas', 14, 18);
            
            // Subtítulo
            doc.setFontSize(11);
            doc.setFont(undefined, 'normal');
            doc.text('Grupo Peruana Asistencia - Sistema de Gestión', 14, 26);
            
            // Fecha
            doc.setFontSize(10);
            doc.text('Generado: ' + new Date().toLocaleDateString('es-PE', {
                day: '2-digit',
                month: 'long',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            }), 14, 34);
            
            // Estadísticas
            doc.setTextColor(0, 0, 0);
            doc.setFontSize(11);
            doc.setFont(undefined, 'bold');
            doc.text(`Total de Empresas: ${data.length}`, 14, 50);
            if (empresaPrincipal) {
                doc.setFont(undefined, 'normal');
                doc.text(`Empresa Principal: ${empresaPrincipal}`, 14, 57);
            }
            
            // Tabla
            doc.autoTable({
                head: [['Código', 'Nombre de Empresa', 'Color 1°', 'Color 2°', 'Principal']],
                body: data,
                startY: 65,
                theme: 'grid',
                styles: {
                    fontSize: 9,
                    cellPadding: 4,
                    valign: 'middle'
                },
                headStyles: { 
                    fillColor: [103, 80, 164],
                    textColor: 255,
                    fontStyle: 'bold',
                    halign: 'center'
                },
                alternateRowStyles: {
                    fillColor: [245, 245, 250]
                },
                columnStyles: {
                    0: { halign: 'center', fontStyle: 'bold' },
                    2: { halign: 'center' },
                    3: { halign: 'center' },
                    4: { halign: 'center', fontStyle: 'bold' }
                },
                didParseCell: function(data) {
                    // Colorear celdas de colores
                    if (data.section === 'body' && (data.column.index === 2 || data.column.index === 3)) {
                        const color = data.cell.raw;
                        if (color && color.startsWith('#')) {
                            const r = parseInt(color.slice(1,3), 16);
                            const g = parseInt(color.slice(3,5), 16);
                            const b = parseInt(color.slice(5,7), 16);
                            data.cell.styles.fillColor = [r, g, b];
                            data.cell.styles.textColor = (r*0.299 + g*0.587 + b*0.114) > 186 ? [0,0,0] : [255,255,255];
                        }
                    }
                }
            });
            
            // Footer
            const pageCount = doc.internal.getNumberOfPages();
            for (let i = 1; i <= pageCount; i++) {
                doc.setPage(i);
                doc.setFontSize(8);
                doc.setTextColor(128, 128, 128);
                doc.text(`Página ${i} de ${pageCount}`, 105, 290, { align: 'center' });
                doc.text('© Grupo Peruana Asistencia', 14, 290);
            }
            
            const fecha = new Date().toISOString().split('T')[0];
            doc.save(`Empresas_GPA_${fecha}.pdf`);
            showToast('PDF Exportado', `Se exportaron ${data.length} empresas`, 'success', 'download_done');
        }
        
        // ==================== Modal Crear ====================
        function abrirModalNuevo() {
            currentEditingId = null;
            selectedImageFiles = { logoLight: null, logoDark: null, iconLight: null, iconDark: null };
            document.getElementById('modal-icon').textContent = 'domain_add';
            document.getElementById('modal-title').textContent = 'Nueva Empresa';
            document.getElementById('empresa-id').value = '';
            document.getElementById('input-codigo').value = '';
            document.getElementById('input-nombre').value = '';
            document.getElementById('input-ruc').value = '';
            document.getElementById('input-sector').value = '';
            document.getElementById('input-color-primario').value = '#EC407A';
            document.getElementById('input-color-secundario').value = '#BA68C8';
            document.getElementById('input-logo-path').value = '';
            document.getElementById('input-logo-dark-path').value = '';
            document.getElementById('input-icon-path').value = '';
            document.getElementById('input-icon-dark-path').value = '';
            document.getElementById('input-usar-mismo-logo-oscuro').checked = true;
            document.getElementById('input-usar-mismo-icono-oscuro').checked = true;
            document.getElementById('input-es-principal').checked = false;
            refreshVariantLabels();
            toggleDarkImageConfig();
            actualizarPreview();
            document.getElementById('modal-empresa').show();
        }
        // ==================== Modal Editar ====================
        function abrirModalEditar(empresaId) {
            const element = document.querySelector('[data-id="' + empresaId + '"]');
            if (!element) {
                showToast('Error', 'No se encontró la empresa', 'error', 'error');
                return;
            }
            selectedImageFiles = { logoLight: null, logoDark: null, iconLight: null, iconDark: null };
            const data = element.dataset;

            currentEditingId = parseInt(empresaId);
            if (isNaN(currentEditingId) || currentEditingId <= 0) {
                showToast('Error', 'ID de empresa inválido', 'error', 'error');
                return;
            }

            document.getElementById('modal-icon').textContent = 'edit';
            document.getElementById('modal-title').textContent = 'Editar Empresa';
            document.getElementById('empresa-id').value = currentEditingId;
            document.getElementById('input-codigo').value = data.codigo || '';
            document.getElementById('input-nombre').value = data.nombre || '';
            document.getElementById('input-ruc').value = data.ruc || '';
            document.getElementById('input-sector').value = data.sector || '';
            document.getElementById('input-color-primario').value = data.colorPrimario || '#EC407A';
            document.getElementById('input-color-secundario').value = data.colorSecundario || '#BA68C8';
            document.getElementById('input-logo-path').value = data.logoPath || '';
            document.getElementById('input-logo-dark-path').value = data.logoDarkPath || '';
            document.getElementById('input-icon-path').value = data.iconPath || '';
            document.getElementById('input-icon-dark-path').value = data.iconDarkPath || '';
            document.getElementById('input-usar-mismo-logo-oscuro').checked = (data.usarMismoLogoOscuro === 'true');
            document.getElementById('input-usar-mismo-icono-oscuro').checked = (data.usarMismoIconoOscuro === 'true');
            document.getElementById('input-es-principal').checked = data.esPrincipal === 'true';

            refreshVariantLabels();
            toggleDarkImageConfig();
            actualizarPreview();
            document.getElementById('modal-empresa').show();
        }
        
        function actualizarPreview() {
            const primario = document.getElementById('input-color-primario').value;
            const secundario = document.getElementById('input-color-secundario').value;
            const nombre = document.getElementById('input-nombre').value || 'Nueva Empresa';
            document.getElementById('preview-card').style.background = `linear-gradient(135deg, ${primario} 0%, ${secundario} 100%)`;
            document.getElementById('hex-primario').textContent = primario.toUpperCase();
            document.getElementById('hex-secundario').textContent = secundario.toUpperCase();
            document.getElementById('preview-nombre').textContent = nombre;
        }
        
        document.getElementById('input-nombre').addEventListener('input', actualizarPreview);
        

        // ==================== Eliminar ====================
        function abrirModalEliminar(id, nombre) {
            deleteId = id;
            document.getElementById('delete-empresa-nombre').textContent = nombre;
            document.getElementById('modal-eliminar').show();
        }
        
        document.getElementById('btn-confirm-delete').addEventListener('click', async () => {
            if (!deleteId) return;
            try {
                const response = await fetch(`${contextPath}/api/empresas/${deleteId}`, { method: 'DELETE' });
                const result = await response.json();
                
                if (result.success) {
                    showToast('Eliminada', result.message, 'success', 'delete');
                    document.getElementById('modal-eliminar').close();
                    document.querySelectorAll(`[data-id="${deleteId}"]`).forEach(el => {
                        el.style.transition = 'all 0.3s ease';
                        el.style.opacity = '0';
                        el.style.transform = 'scale(0.95)';
                        setTimeout(() => el.remove(), 300);
                    });
                    deleteId = null;
                } else {
                    showToast('Error', result.message || 'No se pudo eliminar', 'error', 'error');
                }
            } catch (error) {
                console.error(error);
                showToast('Error', 'No se pudo conectar con el servidor', 'error', 'wifi_off');
            }
        });
        
                // ==================== Imagenes de Marca ====================
        let selectedImageFiles = {
            logoLight: null,
            logoDark: null,
            iconLight: null,
            iconDark: null
        };

        function handleVariantFile(variantKey, input) {
            if (!input || !input.files || !input.files[0]) {
                return;
            }
            const file = input.files[0];
            if (!file.type || !file.type.startsWith('image/')) {
                showToast('Error', 'El archivo debe ser una imagen', 'error', 'error');
                input.value = '';
                return;
            }
            if (file.size > 2 * 1024 * 1024) {
                showToast('Error', 'El archivo es demasiado grande (m�x 2MB)', 'error', 'error');
                input.value = '';
                return;
            }
            selectedImageFiles[variantKey] = file;
            refreshVariantLabels();
        }

        function getPathFromVariant(variantKey) {
            if (variantKey === 'logoLight') return document.getElementById('input-logo-path').value;
            if (variantKey === 'logoDark') return document.getElementById('input-logo-dark-path').value;
            if (variantKey === 'iconLight') return document.getElementById('input-icon-path').value;
            return document.getElementById('input-icon-dark-path').value;
        }

        function setPathForVariant(variantKey, value) {
            if (variantKey === 'logoLight') document.getElementById('input-logo-path').value = value;
            if (variantKey === 'logoDark') document.getElementById('input-logo-dark-path').value = value;
            if (variantKey === 'iconLight') document.getElementById('input-icon-path').value = value;
            if (variantKey === 'iconDark') document.getElementById('input-icon-dark-path').value = value;
        }

        function resolveVariantPath(variantKey) {
            const stored = getPathFromVariant(variantKey);
            if (!stored) return '';
            if (stored.startsWith('blob:') || stored.startsWith('data:') || stored.startsWith('http')) {
                return stored;
            }
            return `${contextPath}/uploads/logos/${stored}`;
        }

        const blobUrlCache = {};

        function getVariantPreviewSrc(variantKey) {
            const sameLogo = document.getElementById('input-usar-mismo-logo-oscuro').checked;
            const sameIcon = document.getElementById('input-usar-mismo-icono-oscuro').checked;

            if (variantKey === 'logoDark' && sameLogo) {
                return getVariantPreviewSrc('logoLight');
            }
            if (variantKey === 'iconDark' && sameIcon) {
                return getVariantPreviewSrc('iconLight');
            }

            const selected = selectedImageFiles[variantKey];
            if (selected) {
                if (!blobUrlCache[variantKey] || blobUrlCache[variantKey].file !== selected) {
                    if (blobUrlCache[variantKey]) URL.revokeObjectURL(blobUrlCache[variantKey].url);
                    blobUrlCache[variantKey] = {
                        file: selected,
                        url: URL.createObjectURL(selected)
                    };
                }
                return blobUrlCache[variantKey].url;
            }
            return resolveVariantPath(variantKey);
        }

        function renderVariantPreview(variantKey) {
            const normalizedKey = variantKey.replace(/([A-Z])/g, '-$1').toLowerCase();
            const imageEl = document.getElementById(`preview-${normalizedKey}`);
            const placeholderEl = document.getElementById(`placeholder-${normalizedKey}`);
            if (!imageEl || !placeholderEl) return;

            const src = getVariantPreviewSrc(variantKey);
            if (src) {
                imageEl.src = src;
                imageEl.style.display = 'block';
                placeholderEl.style.display = 'none';
            } else {
                imageEl.removeAttribute('src');
                imageEl.style.display = 'none';
                placeholderEl.style.display = 'inline-flex';
            }
        }

        function refreshVariantLabels() {
            const map = [
                { key: 'logoLight', labelId: 'label-logo-light' },
                { key: 'logoDark', labelId: 'label-logo-dark' },
                { key: 'iconLight', labelId: 'label-icon-light' },
                { key: 'iconDark', labelId: 'label-icon-dark' }
            ];

            map.forEach(({ key, labelId }) => {
                const el = document.getElementById(labelId);
                if (!el) return;
                const selected = selectedImageFiles[key];
                const stored = getPathFromVariant(key);
                const sameLogo = document.getElementById('input-usar-mismo-logo-oscuro').checked;
                const sameIcon = document.getElementById('input-usar-mismo-icono-oscuro').checked;

                if (key === 'logoDark' && sameLogo) {
                    el.textContent = '(igual que light)';
                } else if (key === 'iconDark' && sameIcon) {
                    el.textContent = '(igual que light)';
                } else if (selected) {
                    el.textContent = selected.name;
                } else if (stored) {
                    el.textContent = stored;
                } else {
                    el.textContent = '(sin imagen)';
                }
                renderVariantPreview(key);
            });
        }

        function toggleDarkImageConfig() {
            const sameLogo = document.getElementById('input-usar-mismo-logo-oscuro').checked;
            const sameIcon = document.getElementById('input-usar-mismo-icono-oscuro').checked;

            const rowLogoDark = document.getElementById('row-logo-dark');
            const rowIconDark = document.getElementById('row-icon-dark');
            const btnLogoDark = document.getElementById('btn-logo-dark-upload');
            const btnIconDark = document.getElementById('btn-icon-dark-upload');

            if (rowLogoDark) rowLogoDark.style.opacity = sameLogo ? '0.6' : '1';
            if (rowIconDark) rowIconDark.style.opacity = sameIcon ? '0.6' : '1';
            if (btnLogoDark) btnLogoDark.disabled = sameLogo;
            if (btnIconDark) btnIconDark.disabled = sameIcon;

            if (sameLogo) {
                selectedImageFiles.logoDark = null;
                document.getElementById('input-logo-dark-file').value = '';
                document.getElementById('input-logo-dark-path').value = '';
            }
            if (sameIcon) {
                selectedImageFiles.iconDark = null;
                document.getElementById('input-icon-dark-file').value = '';
                document.getElementById('input-icon-dark-path').value = '';
            }

            refreshVariantLabels();
        }

        async function uploadImageVariant(codigo, variant, file) {
            const formData = new FormData();
            formData.append('file', file);
            formData.append('codigo', codigo);
            formData.append('variant', variant);

            const uploadResponse = await fetch(`${contextPath}/api/empresas/upload-image`, {
                method: 'POST',
                body: formData
            });

            const uploadResult = await uploadResponse.json();
            if (!uploadResult.success) {
                throw new Error(uploadResult.message || 'No se pudo subir la imagen');
            }
            return uploadResult.filename;
        }

        async function uploadSelectedImages(codigo) {
            const map = [
                { key: 'logoLight', variant: 'logo_light', pathKey: 'logoPath' },
                { key: 'logoDark', variant: 'logo_dark', pathKey: 'logoDarkPath' },
                { key: 'iconLight', variant: 'icon_light', pathKey: 'iconPath' },
                { key: 'iconDark', variant: 'icon_dark', pathKey: 'iconDarkPath' }
            ];

            for (const item of map) {
                if (item.key === 'logoDark' && document.getElementById('input-usar-mismo-logo-oscuro').checked) {
                    continue;
                }
                if (item.key === 'iconDark' && document.getElementById('input-usar-mismo-icono-oscuro').checked) {
                    continue;
                }

                const selected = selectedImageFiles[item.key];
                if (!selected) continue;

                const filename = await uploadImageVariant(codigo, item.variant, selected);
                if (item.pathKey === 'logoPath') setPathForVariant('logoLight', filename);
                if (item.pathKey === 'logoDarkPath') setPathForVariant('logoDark', filename);
                if (item.pathKey === 'iconPath') setPathForVariant('iconLight', filename);
                if (item.pathKey === 'iconDarkPath') setPathForVariant('iconDark', filename);
            }
        }

        // ==================== Guardar ====================
        async function guardarEmpresa() {
            const codigo = document.getElementById('input-codigo').value.trim();
            const nombre = document.getElementById('input-nombre').value.trim();

            if (!codigo || !nombre) {
                showToast('Campos Requeridos', 'El código y nombre son obligatorios', 'warning', 'warning');
                return;
            }

            try {
                await uploadSelectedImages(codigo);
            } catch (error) {
                console.error(error);
                showToast('Error Upload', error.message || 'No se pudo subir una imagen', 'error', 'error');
                return;
            }

            const usarMismoLogoOscuro = document.getElementById('input-usar-mismo-logo-oscuro').checked;
            const usarMismoIconoOscuro = document.getElementById('input-usar-mismo-icono-oscuro').checked;
            const logoPath = document.getElementById('input-logo-path').value;
            const iconPath = document.getElementById('input-icon-path').value;
            const logoDarkPath = usarMismoLogoOscuro ? logoPath : document.getElementById('input-logo-dark-path').value;
            const iconDarkPath = usarMismoIconoOscuro ? iconPath : document.getElementById('input-icon-dark-path').value;

            const empresa = {
                codigo,
                nombre,
                colorPrimario: document.getElementById('input-color-primario').value,
                colorSecundario: document.getElementById('input-color-secundario').value,
                logoPath,
                logoDarkPath,
                iconPath,
                iconDarkPath,
                usarMismoLogoOscuro,
                usarMismoIconoOscuro,
                ruc: document.getElementById('input-ruc').value.trim(),
                sector: document.getElementById('input-sector').value.trim(),
                esPrincipal: document.getElementById('input-es-principal').checked
            };

            try {
                // Ensure id is a strict integer fallback to 0
                const numericId = parseInt(currentEditingId);
                const idToSave = (!isNaN(numericId) && numericId > 0) ? numericId : 0;
                const isEditing = idToSave > 0;
                
                let url = isEditing ? `${contextPath}/api/empresas/${idToSave}` : `${contextPath}/api/empresas`;
                // Fallback catch: if URL ends in a slash and it's a PUT, prevent the NoResourceFoundException
                if (isEditing && url.endsWith('/')) {
                    console.error("[DEBUG] Error: URL ended in a slash despite isEditing=true");
                    url = url + idToSave; 
                }

                const method = isEditing ? 'PUT' : 'POST';
                
                console.log(`[DEBUG GPA] Guardando. idToSave: ${idToSave}, isEditing: ${isEditing}, Method: ${method}, URL: ${url}`);

                const response = await fetch(url, {
                    method,
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(empresa)
                });
                
                const text = await response.text();
                let result;
                try {
                    result = text ? JSON.parse(text) : {};
                } catch (e) {
                    throw new Error(text || 'Servidor devolvió formato inválido.');
                }

                if (response.ok && result?.success !== false) {
                    showToast(isEditing ? 'Actualizada' : 'Creada', result.message || 'Operación exitosa', 'success', 'check_circle');
                    document.getElementById('modal-empresa').close();
                    setTimeout(() => location.reload(), 800);
                } else {
                    showToast('Error', result.message || result.error || 'No se pudo guardar la empresa', 'error', 'error');
                }
            } catch (error) {
                console.error(error);
                let msg = error.message;
                if (msg.includes('No static resource')) {
                   msg = "Error 404: Endpoint no encontrado (" + msg + ")";
                }
                showToast('Error', msg || 'No se pudo conectar con el servidor', 'error', 'wifi_off');
            }
        }
    </script>
</body>
</html>










