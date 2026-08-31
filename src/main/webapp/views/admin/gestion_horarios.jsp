<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Horarios</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
    
    <!-- xlsx-js-style for Excel Export with Styling -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>

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
        :root {
            /* Excel-like Grid Dimensions */
            --cell-height: 48px;
            --cell-width: 140px;
            --header-height: 60px;
            --time-col-width: 80px;
            
            /* Colors mapped to Theme */
            --grid-border: var(--border-color);
            --header-bg: var(--bg-surface-container); /* Slight contrast */
            --surface-bg: var(--bg-surface);
            
            /* Shift Colors (Pastels/Vibrant) */
            --shift-caja: #FFCDD2; 
            --shift-preventa: #E1BEE7; 
            --shift-atencion: #C8E6C9; 
            --shift-refri: #FFF9C4; 
            --shift-pesado: #D1C4E9; 
            --shift-despacho: #BBDEFB; 
            --shift-default: var(--bg-hover);
        }
        
        [data-theme="dark"] {
             /* Adjust shift colors for Dark Mode to be less bright or more opaque? */
             --shift-caja: #E57373; 
             --shift-preventa: #BA68C8; 
             --shift-atencion: #81C784; 
             --shift-refri: #FFF176; 
             --shift-pesado: #9575CD; 
             --shift-despacho: #64B5F6; 
             --shift-default: #424242;
        }
        
        body {
            font-family: 'Roboto', 'Inter', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-primary);
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            overflow: hidden;
        }

        /* Layout Structure */
        .main-content {
            flex: 1;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            /* Sidebar margin handled by sidebar.jsp JS */
            background-color: var(--bg-body);
        }

        /* Toolbar */
        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            background: var(--bg-surface);
            border-bottom: 1px solid var(--grid-border);
            z-index: 10;
            flex-wrap: wrap;
            gap: 16px;
        }

        .toolbar-title h2 {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 500;
            color: var(--text-primary);
        }

        .toolbar-actions {
            display: flex;
            gap: 16px;
            align-items: center;
            flex-wrap: wrap;
        }

        /* Scheduler Viewport */
        #scheduler-viewport {
            flex: 1;
            overflow: auto;
            position: relative;
            background: var(--bg-surface);
            /* Custom Scrollbar */
            scrollbar-width: thin;
            scrollbar-color: var(--text-secondary) var(--bg-surface);
        }

        /* Sticky Headers */
        .header-row {
            position: sticky;
            top: 0;
            z-index: 10;
            display: flex;
            background: var(--header-bg);
            border-bottom: 2px solid var(--grid-border); 
            box-shadow: var(--shadow-sm);
        }

        .corner-header {
            position: sticky;
            left: 0;
            z-index: 11;
            width: var(--time-col-width);
            min-width: var(--time-col-width);
            height: var(--header-height);
            background: var(--header-bg);
            border-right: 2px solid var(--grid-border);
            border-bottom: 2px solid var(--grid-border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: var(--text-secondary);
            font-size: 0.8rem;
            box-sizing: border-box;
        }

        .icon_main{
            top: -64px !important;
        }

        .employee-header {
            width: var(--cell-width);
            min-width: var(--cell-width);
            height: var(--header-height);
            border-right: 1px solid var(--grid-border);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 4px;
            box-sizing: border-box;
            background: var(--header-bg);
        }

        .emp-name {
            font-weight: 700;
            font-size: 0.9rem;
            text-transform: uppercase;
            color: var(--text-primary);
        }
        .emp-role {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }

        /* Time Column */
        .time-col {
            position: absolute;
            left: 0;
            top: var(--header-height);
            width: var(--time-col-width);
            z-index: 9;
            background: var(--header-bg);
            border-right: 2px solid var(--grid-border);
            box-sizing: border-box;
        }

        .time-slot {
            height: var(--cell-height);
            border-bottom: 1px solid var(--grid-border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            color: var(--text-secondary);
            font-weight: 500;
            box-sizing: border-box;
        }

        /* Grid Body */
        .grid-canvas {
            position: absolute;
            left: var(--time-col-width);
            top: var(--header-height);
            background: var(--bg-surface);
        }

        .grid-row {
            display: flex;
        }

        .grid-cell {
            width: var(--cell-width);
            min-width: var(--cell-width);
            height: var(--cell-height);
            border-right: 1px solid var(--grid-border);
            border-bottom: 1px solid var(--grid-border);
            box-sizing: border-box;
            position: relative;
            transition: background-color 0.1s;
        }
        
        .grid-cell:hover {
            background-color: var(--bg-hover);
        }

        /* Shift Events */
        .shift-event {
            position: absolute;
            width: calc(var(--cell-width) - 8px);
            border-radius: 4px;
            padding: 4px 6px;
            font-size: 0.75rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
            cursor: pointer;
            z-index: 5;
            overflow: hidden;
            display: flex;
            box-sizing: border-box;
            flex-direction: column;
            justify-content: center;
            border-left: 4px solid rgba(0,0,0,0.1); /* Left accent */
            transition: transform 0.1s, box-shadow 0.1s;
            user-select: none;
        }

        .shift-event:hover {
            z-index: 8;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }
        
        .shift-event.dragging {
            opacity: 0.7;
            pointer-events: none;
            z-index: 100;
            transform: scale(1.02);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        .resize-handle {
            position: absolute;
            left: 0;
            right: 0;
            height: 8px;
            cursor: ns-resize;
            z-index: 10;
        }
        .resize-handle.top {
            top: 0;
            border-radius: 4px 4px 0 0;
        }
        .resize-handle.bottom {
            bottom: 0;
            border-radius: 0 0 4px 4px;
        }
        .resize-handle:hover {
            background: rgba(0,0,0,0.15);
        }
        
        /* Ghost element for drag */
        .shift-ghost {
            position: fixed;
            pointer-events: none;
            z-index: 9999;
            opacity: 0.85;
            transform: rotate(2deg);
            box-shadow: 0 12px 24px rgba(0,0,0,0.4);
        }
        
        /* Drop indicator cell highlight */
        .grid-cell.drop-target {
            background-color: rgba(33, 150, 243, 0.2) !important;
            outline: 2px dashed var(--md-sys-color-primary, #1976D2);
            outline-offset: -2px;
        }
        
        .grid-cell.drop-invalid {
            background-color: rgba(244, 67, 54, 0.15) !important;
        }
        
        /* Shift Tooltip */
        .shift-tooltip {
            position: fixed;
            z-index: 10000;
            background: var(--bg-surface);
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            padding: 16px;
            max-width: 300px;
            min-width: 220px;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.2s, visibility 0.2s, transform 0.2s;
            transform: translateY(8px);
            border: 1px solid var(--border-color);
        }
        
        .shift-tooltip.visible {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        .tooltip-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .tooltip-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1rem;
        }
        
        .tooltip-name {
            font-weight: 600;
            font-size: 1rem;
            color: var(--text-primary);
        }
        
        .tooltip-role {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }
        
        .tooltip-stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
            margin-bottom: 12px;
        }
        
        .tooltip-stat {
            background: var(--bg-hover);
            padding: 8px 10px;
            border-radius: 8px;
            text-align: center;
        }
        
        .tooltip-stat-value {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--md-sys-color-primary, #1976D2);
        }
        
        .tooltip-stat-label {
            font-size: 0.7rem;
            color: var(--text-secondary);
            text-transform: uppercase;
        }
        
        .tooltip-shift-info {
            background: var(--bg-hover);
            padding: 10px;
            border-radius: 8px;
        }
        
        .tooltip-shift-type {
            font-weight: 600;
            margin-bottom: 4px;
        }
        
        .tooltip-shift-time {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        
        /* Placeholder column for adding employees */
        .employee-header.placeholder {
            background: transparent;
            border: 2px dashed var(--border-color);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .employee-header.placeholder:hover {
            background: var(--bg-hover);
            border-color: var(--md-sys-color-primary, #1976D2);
        }
        
        .placeholder-icon {
            font-size: 32px;
            color: var(--text-secondary);
        }
        
        .placeholder-text {
            font-size: 0.75rem;
            color: var(--text-secondary);
            margin-top: 4px;
        }
        
        /* Employee Selector Modal */
        .employee-selector-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 9998;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s, visibility 0.3s;
        }
        
        .employee-selector-backdrop.visible {
            opacity: 1;
            visibility: visible;
        }
        
        .employee-selector {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.9);
            background: var(--bg-surface);
            border-radius: 16px;
            box-shadow: 0 16px 48px rgba(0,0,0,0.3);
            z-index: 9999;
            width: 90%;
            max-width: 500px;
            max-height: 70vh;
            overflow: hidden;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s;
        }
        
        .employee-selector.visible {
            opacity: 1;
            visibility: visible;
            transform: translate(-50%, -50%) scale(1);
        }
        
        .employee-selector-header {
            padding: 20px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .employee-selector-title {
            font-size: 1.25rem;
            font-weight: 600;
        }
        
        .employee-selector-list {
            padding: 12px;
            max-height: 400px;
            overflow-y: auto;
        }
        
        .employee-selector-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.15s;
        }
        
        .employee-selector-item:hover {
            background: var(--bg-hover);
        }
        
        .employee-selector-item.selected {
            background: rgba(33, 150, 243, 0.15);
        }
        
        .employee-selector-item .avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .employee-selector-footer {
            padding: 16px 20px;
            border-top: 1px solid var(--border-color);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        
        /* Remove button on employee header */
        .emp-remove-btn {
            position: absolute;
            top: 2px;
            right: 2px;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: rgba(0,0,0,0.1);
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.2s, background 0.2s;
        }
        
        .employee-header:hover .emp-remove-btn {
            opacity: 1;
        }
        
        .emp-remove-btn:hover {
            background: rgba(244, 67, 54, 0.2);
        }
        
        .emp-remove-btn span {
            font-size: 14px;
            color: var(--text-secondary);
        }

        /* Ctrl indicator */
        .ctrl-indicator {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: var(--bg-surface);
            padding: 12px 20px;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.2);
            font-size: 0.9rem;
            font-weight: 500;
            z-index: 9999;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.2s, visibility 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .ctrl-indicator.visible {
            opacity: 1;
            visibility: visible;
        }
        
        .ctrl-indicator span {
            color: var(--md-sys-color-primary, #1976D2);
        }

        /* Context Menu (Material Style) */
        #context-menu {
            position: fixed;
            display: none;
            background: var(--surface-bg);
            border-radius: 4px;
            box-shadow: 0 2px 4px -1px rgba(0,0,0,0.2), 0 4px 5px 0 rgba(0,0,0,0.14), 0 1px 10px 0 rgba(0,0,0,0.12);
            z-index: 9999;
            min-width: 160px;
            padding: 8px 0;
        }
        
        .ctx-item {
            padding: 0 16px;
            height: 40px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.9rem;
            cursor: pointer;
            color: var(--text-primary);
        }
        
        .ctx-item:hover {
            background-color: rgba(0,0,0,0.05);
        }
        
        .ctx-item span {
            font-size: 20px;
            color: var(--text-secondary);
        }
        
        .ctx-item.danger {
            color: #B3261E;
        }
        .ctx-item.danger span {
            color: #B3261E;
        }

        /* Dialog Styles */
        .dialog-content {
            display: flex;
            flex-direction: column;
            gap: 16px;
            width: 300px; /* Or min-width */
            padding-top: 8px;
        }
        
        .row-inputs {
            display: flex;
            gap: 12px;
        }
        
        .row-inputs > * {
            flex: 1;
        }
        
        /* Plantilla Item Cards */
        .plantilla-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            background: var(--bg-hover);
            border-radius: 12px;
            margin-bottom: 8px;
            transition: background 0.15s, transform 0.1s;
        }
        
        .plantilla-item:hover {
            background: var(--bg-surface-container);
            transform: translateX(2px);
        }
        
        .plantilla-item-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        
        .plantilla-item-name {
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--text-primary);
        }
        
        .plantilla-item-meta {
            font-size: 0.8rem;
            color: var(--text-secondary);
            display: flex;
            gap: 12px;
        }
        
        .plantilla-item-actions {
            display: flex;
            gap: 4px;
        }
        
        .plantilla-section {
            padding: 4px 0;
        }

    </style>
</head>
<body>

    <!-- Loading Screen -->
    <jsp:include page="/views/shared/loading-screen.jsp" />
    <jsp:include page="/views/shared/console-warning.jsp" />

    <!-- Sidebar -->
    <jsp:include page="/views/shared/sidebar.jsp" />

    <div class="main-content">
        <!-- Header -->
        <jsp:include page="/views/shared/header.jsp" />

        <!-- Toolbar -->
        <div class="toolbar">
            <div class="toolbar-title">
                <h2>Programación de Turnos</h2>
            </div>
            <div class="toolbar-actions">
                <!-- Date Picker disguised as text field for now, or native -->
                <md-outlined-text-field 
                    type="date" 
                    id="date-picker" 
                    label="Fecha" 
                    value="${fechaSeleccionada}">
                </md-outlined-text-field>

                <md-outlined-button id="btn-refresh">
                    <md-icon slot="icon">refresh</md-icon>
                    Actualizar
                </md-outlined-button>
                
                <c:if test="${isAdmin}">
                    <md-outlined-button id="btn-copy-from-date">
                        <md-icon slot="icon">content_copy</md-icon>
                        Copiar de Otro Día
                    </md-outlined-button>
                    
                    <md-filled-tonal-button id="btn-plantillas">
                        <md-icon slot="icon">library_add</md-icon>
                        Gestionar Plantillas
                    </md-filled-tonal-button>
                    
                    <md-filled-button id="btn-new-shift">
                        <md-icon slot="icon">add</md-icon>
                        Nuevo Turno
                    </md-filled-button>
                    
                    <md-outlined-button id="btn-export-excel">
                        <md-icon slot="icon">table_view</md-icon>
                        Exportar Excel
                    </md-outlined-button>
                </c:if>
                
                <div style="font-size: 0.8rem; color: var(--text-secondary); margin-left: 8px;">
                     <strong>Ctrl + Drag</strong> para duplicar
                </div>
            </div>
        </div>

        <!-- Main Scheduler Grid -->
        <div id="scheduler-viewport">
            <div id="scheduler-grid">
                <!-- Generated by JS -->
            </div>
        </div>
    </div>

    </div>

    <!-- Edit/Create Modal (Standard Custom Modal) -->
    <md-dialog id="shift-dialog" style="min-width: 320px;">
        <md-icon slot="icon">calendar_add_on</md-icon>
        <div slot="headline">Nuevo Turno</div>
        
        <form slot="content" id="shift-form" method="dialog">
            <div class="dialog-content">
                <input type="hidden" id="shift-id">
                
                <md-outlined-select label="Empleado" id="shift-employee" required class="full-width-field">
                     <md-icon slot="leading-icon">person</md-icon>
                     <!-- Options injected by JS -->
                </md-outlined-select>
    
                <div class="row-inputs">
                    <md-outlined-text-field 
                        type="time" 
                        label="Inicio" 
                        id="shift-start" 
                        required
                        class="time-field">
                        <md-icon slot="leading-icon">schedule</md-icon>
                    </md-outlined-text-field>
                    
                    <md-outlined-text-field 
                        type="time" 
                        label="Fin" 
                        id="shift-end" 
                        required
                        class="time-field">
                        <md-icon slot="leading-icon">update</md-icon>
                    </md-outlined-text-field>
                </div>
                
                <md-outlined-select label="Tipo de Turno" id="shift-type" required class="full-width-field">
                    <md-icon slot="leading-icon">work</md-icon>
                    <md-select-option value="Caja">
                        <div slot="headline">Caja</div>
                    </md-select-option>
                    <md-select-option value="Preventa">
                        <div slot="headline">Preventa</div>
                    </md-select-option>
                    <md-select-option value="Refrigerio">
                         <div slot="headline">Refrigerio</div>
                    </md-select-option>
                    <md-select-option value="Atencion">
                         <div slot="headline">Atención</div>
                    </md-select-option>
                    <md-select-option value="Pesado">
                         <div slot="headline">Pesado</div>
                    </md-select-option>
                    <md-select-option value="Despacho">
                         <div slot="headline">Despacho</div>
                    </md-select-option>
                    <md-select-option value="Caja 2do Nivel">
                         <div slot="headline">Caja 2do Nivel</div>
                    </md-select-option>
                </md-outlined-select>
            </div>
        </form>

        <div slot="actions">
             <md-icon-button id="btn-delete-dialog" style="margin-right: auto; display: none; --md-icon-button-icon-color: var(--md-sys-color-error);">
                <md-icon>delete</md-icon>
             </md-icon-button>
            
            <md-text-button value="cancel">Cancelar</md-text-button>
            <md-filled-button id="btn-save-dialog">
                <md-icon slot="icon">save</md-icon>
                Guardar
            </md-filled-button>
        </div>
    </md-dialog>

    <!-- Context Menu -->
    <div id="context-menu">
        <div class="ctx-item" id="ctx-edit">
            <span class="material-symbols-outlined">edit</span>
            Editar
        </div>
        <div class="ctx-item" id="ctx-duplicate">
             <span class="material-symbols-outlined">content_copy</span>
            Duplicar
        </div>
        <div class="ctx-item" id="ctx-copy-to-date">
             <span class="material-symbols-outlined">event</span>
            Copiar a otra fecha
        </div>
        <div class="separator" style="height:1px; background:#eee; margin:4px 0;"></div>
        <div class="ctx-item danger" id="ctx-delete">
             <span class="material-symbols-outlined">delete</span>
            Eliminar
        </div>
    </div>

    <!-- Shift Tooltip -->
    <div id="shift-tooltip" class="shift-tooltip">
        <div class="tooltip-header">
            <div class="tooltip-avatar" id="tooltip-avatar">JS</div>
            <div>
                <div class="tooltip-name" id="tooltip-name">Juan Pérez</div>
                <div class="tooltip-role" id="tooltip-role">Vendedor</div>
            </div>
        </div>
        <div class="tooltip-stats">
            <div class="tooltip-stat">
                <div class="tooltip-stat-value" id="tooltip-hours">8.5h</div>
                <div class="tooltip-stat-label">Horas Hoy</div>
            </div>
            <div class="tooltip-stat">
                <div class="tooltip-stat-value" id="tooltip-shifts">2</div>
                <div class="tooltip-stat-label">Turnos</div>
            </div>
        </div>
        <div class="tooltip-shift-info">
            <div class="tooltip-shift-type" id="tooltip-type">Caja</div>
            <div class="tooltip-shift-time" id="tooltip-time">08:00 - 16:00 (8h)</div>
        </div>
    </div>

    <!-- Employee Selector Dialog -->
    <md-dialog id="employee-selector-dialog" style="min-width: 400px; max-width: 500px; max-height: 80vh;">
        <md-icon slot="icon" class="icon_main">group_add</md-icon>
        <div slot="headline">Agregar Empleados</div>
        
        <div slot="content">
            <div style="padding: 0 4px 12px 4px;">
                <md-outlined-text-field 
                    id="emp-selector-search" 
                    label="Buscar por nombre, DNI o rol" 
                    type="search"
                    class="full-width-field">
                    <md-icon slot="leading-icon">search</md-icon>
                </md-outlined-text-field>
            </div>
            
            <div class="employee-selector-list" id="employee-selector-list" style="min-height: 300px;">
                <!-- Populated by JS -->
            </div>
            
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 4px 0 4px; border-top: 1px solid var(--border-color);">
                <md-icon-button id="emp-selector-prev" disabled>
                    <md-icon>chevron_left</md-icon>
                </md-icon-button>
                <span id="emp-selector-page-info" style="font-size: 0.85rem; color: var(--text-secondary);">Página 1 de 1</span>
                <md-icon-button id="emp-selector-next" disabled>
                    <md-icon>chevron_right</md-icon>
                </md-icon-button>
            </div>
        </div>

        <div slot="actions">
            <md-text-button id="btn-cancel-selector">Cancelar</md-text-button>
            <md-filled-button id="btn-confirm-selector">
                <md-icon slot="icon">check</md-icon>
                Confirmar <span id="emp-selector-count" style="margin-left: 4px; font-size: 0.8em; opacity: 0.8;"></span>
            </md-filled-button>
        </div>
    </md-dialog>

    <!-- Ctrl Indicator -->
    <div id="ctrl-indicator" class="ctrl-indicator">
        <span class="material-symbols-outlined">content_copy</span>
        Modo Duplicar (suelta para copiar)
    </div>

    <!-- Copy From Date Modal -->
    <md-dialog id="copy-from-date-dialog" style="min-width: 380px;">
        <md-icon slot="icon">content_copy</md-icon>
        <div slot="headline">Copiar Turnos de Otro Día</div>
        
        <div slot="content">
            <div class="dialog-content">
                <md-outlined-text-field 
                    type="date" 
                    id="copy-source-date" 
                    label="Fecha Origen"
                    class="full-width-field">
                    <md-icon slot="leading-icon">calendar_today</md-icon>
                </md-outlined-text-field>
                
                <div style="margin-top: 12px; padding: 12px; background: var(--bg-hover); border-radius: 8px; font-size: 0.85rem; color: var(--text-secondary);">
                    <strong>Nota:</strong> Se copiarán todos los turnos de la fecha origen al día seleccionado actualmente.
                </div>
            </div>
        </div>

        <div slot="actions">
            <md-text-button id="btn-cancel-copy-from">Cancelar</md-text-button>
            <md-filled-button id="btn-confirm-copy-from">
                <md-icon slot="icon">content_copy</md-icon>
                Copiar Turnos
            </md-filled-button>
        </div>
    </md-dialog>

    <!-- Enhanced Plantillas Modal -->
    <md-dialog id="plantillas-dia-dialog" style="min-width: 520px; max-width: 600px;">
        <md-icon slot="icon">library_add</md-icon>
        <div slot="headline">Gestión de Plantillas de Día</div>
        
        <div slot="content">
            <div class="dialog-content" style="gap: 20px;">
                <!-- Save Current Day as Template Section -->
                <div class="plantilla-section">
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
                        <span class="material-symbols-outlined" style="color: var(--md-sys-color-primary);">save</span>
                        <h4 style="margin: 0; font-size: 1rem;">Guardar día actual como plantilla</h4>
                    </div>
                    <div style="display: flex; gap: 12px; align-items: flex-end;">
                        <md-outlined-text-field 
                            id="new-plantilla-name" 
                            label="Nombre de la plantilla"
                            style="flex: 1;">
                            <md-icon slot="leading-icon">description</md-icon>
                        </md-outlined-text-field>
                        <md-filled-button id="btn-save-as-plantilla">
                            <md-icon slot="icon">save</md-icon>
                            Guardar
                        </md-filled-button>
                    </div>
                </div>
                
                <md-divider style="margin: 4px 0;"></md-divider>
                
                <!-- Apply Existing Template Section -->
                <div class="plantilla-section">
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
                        <span class="material-symbols-outlined" style="color: var(--md-sys-color-primary);">folder_open</span>
                        <h4 style="margin: 0; font-size: 1rem;">Plantillas guardadas</h4>
                    </div>
                    <div id="plantillas-dia-list" style="max-height: 250px; overflow-y: auto;">
                        <!-- Dynamically populated list of templates -->
                        <div class="empty-state" style="text-align: center; padding: 24px; color: var(--text-secondary);">
                            <span class="material-symbols-outlined" style="font-size: 48px; opacity: 0.5;">folder_off</span>
                            <p>No hay plantillas guardadas</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div slot="actions">
            <md-text-button id="btn-close-plantillas-dia">Cerrar</md-text-button>
        </div>
    </md-dialog>

    <!-- Legacy Plantillas Modal (Per-Employee Weekly Templates) -->
    <md-dialog id="plantillas-dialog" style="min-width: 400px;">
        <md-icon slot="icon">library_add</md-icon>
        <div slot="headline">Aplicar Plantilla Semanal</div>
        
        <div slot="content">
            <div class="dialog-content">
                <md-outlined-select label="Plantilla" id="plantilla-select" class="full-width-field">
                    <md-icon slot="leading-icon">description</md-icon>
                    <!-- Options injected by JS -->
                </md-outlined-select>
                
                <md-outlined-select label="Empleado" id="plantilla-employee" class="full-width-field">
                    <md-icon slot="leading-icon">person</md-icon>
                    <!-- Options injected by JS -->
                </md-outlined-select>
                
                <div style="margin-top: 12px; padding: 12px; background: var(--bg-hover); border-radius: 8px; font-size: 0.85rem; color: var(--text-secondary);">
                    <strong>Nota:</strong> La plantilla se aplicará al día seleccionado según el día de la semana configurado en la plantilla.
                </div>
            </div>
        </div>

        <div slot="actions">
            <md-text-button id="btn-cancel-plantilla">Cancelar</md-text-button>
            <md-filled-button id="btn-apply-plantilla">
                <md-icon slot="icon">check</md-icon>
                Aplicar
            </md-filled-button>
        </div>
    </md-dialog>

    <!-- Copy to Date Modal -->
    <md-dialog id="copy-date-dialog" style="min-width: 320px;">
        <md-icon slot="icon">event</md-icon>
        <div slot="headline">Copiar Turno a Otra Fecha</div>
        
        <div slot="content">
            <div class="dialog-content">
                <md-outlined-text-field 
                    type="date" 
                    id="copy-target-date" 
                    label="Fecha Destino"
                    class="full-width-field">
                    <md-icon slot="leading-icon">calendar_today</md-icon>
                </md-outlined-text-field>
            </div>
        </div>

        <div slot="actions">
            <md-text-button id="btn-cancel-copy-date">Cancelar</md-text-button>
            <md-filled-button id="btn-confirm-copy-date">
                <md-icon slot="icon">content_copy</md-icon>
                Copiar
            </md-filled-button>
        </div>
    </md-dialog>


    <!-- Logic -->
    <script>
        const CTX = "${pageContext.request.contextPath}";
        const IS_ADMIN = ${isAdmin};
        const INITIAL_DATE = "${fechaSeleccionada}";
        // Data injected from Server
        const EMPLOYEES = [
            <c:forEach items="${empleados}" var="e" varStatus="loop">
                { 
                    id: ${e.id}, 
                    nombres: "<c:out value='${e.nombres}' escapeXml='true'/>",
                    apellidos: "<c:out value='${e.apellidos}' escapeXml='true'/>",
                    role: "<c:out value='${e.rol}' escapeXml='true'/>", 
                    dni: "<c:out value='${e.dni}' escapeXml='true'/>" 
                }${!loop.last ? ',' : ''}
            </c:forEach>
        ];
        
        // --- State ---
        let shifts = [];
        let visibleEmployeeIds = []; // IDs of employees visible in grid
        
        // Configuration
        const START_HOUR = 6; // 6 AM
        const END_HOUR = 24;  // 12 AM next day
        const CELL_HEIGHT = 48; // px, Must match CSS
        const COL_WIDTH = 140; // px, Must match CSS
        
        // Drag/Resize State
        let isDragging = false;
        let isResizing = false;
        let resizeEdge = null; // 'top' or 'bottom'
        let dragData = null;
        let ghostElement = null;
        let currentDropTarget = null;
        let hasMoved = false; // Track if mouse actually moved (for click vs drag)
        const DRAG_THRESHOLD = 5; // Pixels of movement before considering it a drag
        
        // Tooltip State
        let tooltipTimeout = null;
        
        // Employee Selector State
        let empSelectorPage = 1;
        const empSelectorPerPage = 10;
        let empSelectorSearch = "";
        let tempSelectedEmpIds = new Set(); // Track selections across pages
        
        // --- Initialization ---
        function init() {
            loadVisibleEmployees();
            renderGrid();
            loadShifts(INITIAL_DATE);
            
            // Pre-populate Employee Select (Static List)
            const sel = document.getElementById('shift-employee');
            if(sel && EMPLOYEES) {
                sel.innerHTML = '';
                EMPLOYEES.forEach(e => {
                    const opt = document.createElement('md-select-option');
                    opt.value = e.id.toString();
                    opt.innerHTML = '<div slot="headline">' + e.nombres.split(' ')[0] + ' ' + e.apellidos.split(' ')[0] + '</div>';
                    sel.appendChild(opt);
                });
            }

            // Event Listeners
            const btnRefresh = document.getElementById('btn-refresh');
            if(btnRefresh) btnRefresh.addEventListener('click', () => loadShifts(document.getElementById('date-picker').value));
            
            const datePicker = document.getElementById('date-picker');
            if(datePicker) datePicker.addEventListener('change', (e) => loadShifts(e.target.value));
            
            if(IS_ADMIN) {
                const btnNew = document.getElementById('btn-new-shift');
                if(btnNew) {
                    btnNew.addEventListener('click', () => openDialog());
                }
                
                const btnSave = document.getElementById('btn-save-dialog');
                if(btnSave) btnSave.addEventListener('click', saveFromDialog);
                
                const btnDelete = document.getElementById('btn-delete-dialog');
                if(btnDelete) btnDelete.addEventListener('click', deleteFromDialog);
                
                // Copy From Date button and modal
                const btnCopyFromDate = document.getElementById('btn-copy-from-date');
                if(btnCopyFromDate) {
                    btnCopyFromDate.addEventListener('click', openCopyFromDateModal);
                }
                
                const btnCancelCopyFrom = document.getElementById('btn-cancel-copy-from');
                if(btnCancelCopyFrom) btnCancelCopyFrom.addEventListener('click', closeCopyFromDateModal);
                
                const btnConfirmCopyFrom = document.getElementById('btn-confirm-copy-from');
                if(btnConfirmCopyFrom) btnConfirmCopyFrom.addEventListener('click', confirmCopyFromDate);
                
                // Plantillas Day button and modal
                const btnPlantillas = document.getElementById('btn-plantillas');
                if(btnPlantillas) {
                    btnPlantillas.addEventListener('click', openPlantillasDiaModal);
                }
                
                const btnClosePlantillasDia = document.getElementById('btn-close-plantillas-dia');
                if(btnClosePlantillasDia) btnClosePlantillasDia.addEventListener('click', closePlantillasDiaModal);
                
                const btnSaveAsPlantilla = document.getElementById('btn-save-as-plantilla');
                if(btnSaveAsPlantilla) btnSaveAsPlantilla.addEventListener('click', saveCurrentDayAsPlantilla);
                
                // Legacy per-employee plantillas modal buttons
                const btnCancelPlantilla = document.getElementById('btn-cancel-plantilla');
                if(btnCancelPlantilla) btnCancelPlantilla.addEventListener('click', closePlantillasModal);
                
                const btnApplyPlantilla = document.getElementById('btn-apply-plantilla');
                if(btnApplyPlantilla) btnApplyPlantilla.addEventListener('click', applyPlantilla);
                
                // Copy single shift to date modal buttons
                const btnCancelCopyDate = document.getElementById('btn-cancel-copy-date');
                if(btnCancelCopyDate) btnCancelCopyDate.addEventListener('click', closeCopyDateModal);
                
                const btnConfirmCopyDate = document.getElementById('btn-confirm-copy-date');
                if(btnConfirmCopyDate) btnConfirmCopyDate.addEventListener('click', confirmCopyToDate);
                
                // Context menu copy to date
                const ctxCopyToDate = document.getElementById('ctx-copy-to-date');
                if(ctxCopyToDate) ctxCopyToDate.addEventListener('click', openCopyToDateFromContext);
            }
            
            // Employee Selector events
            initEmployeeSelector();
            
            // Global mouse events for drag/resize
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', handleMouseUp);
            
            // Ctrl key indicator
            document.addEventListener('keydown', (e) => {
                if(e.key === 'Control' && isDragging) {
                    document.getElementById('ctrl-indicator').classList.add('visible');
                }
            });
            document.addEventListener('keyup', (e) => {
                if(e.key === 'Control') {
                    document.getElementById('ctrl-indicator').classList.remove('visible');
                }
            });
        }
        
        // --- Visible Employees Management ---
        function loadVisibleEmployees() {
            const saved = localStorage.getItem('visibleEmployees_' + INITIAL_DATE.slice(0, 7)); // Per month
            if(saved) {
                try {
                    visibleEmployeeIds = JSON.parse(saved);
                } catch(e) {
                    visibleEmployeeIds = [];
                }
            }
            // If nothing saved, show empty (placeholder mode)
            if(!visibleEmployeeIds.length) {
                visibleEmployeeIds = [];
            }
        }
        
        function saveVisibleEmployees() {
            localStorage.setItem('visibleEmployees_' + document.getElementById('date-picker').value.slice(0, 7), JSON.stringify(visibleEmployeeIds));
        }
        
        function getVisibleEmployees() {
            return EMPLOYEES.filter(e => visibleEmployeeIds.includes(e.id));
        }
        
        function addEmployeeToView(empId) {
            if(!visibleEmployeeIds.includes(empId)) {
                visibleEmployeeIds.push(empId);
                saveVisibleEmployees();
                renderGrid();
                renderShifts();
            }
        }
        
        async function removeEmployeeFromView(empId) {
            if(IS_ADMIN) {
                if(!confirm("¿Deseas eliminar todos los turnos asignados a este empleado para hoy? \n\nEsta acción eliminará permanentemente los turnos de la base de datos.")) {
                    return;
                }
                
                try {
                    const date = document.getElementById('date-picker').value;
                    const res = await fetch(CTX + '/horarios/api/eliminar-turnos-empleado', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({
                            empleadoId: empId,
                            fecha: date
                        })
                    });
                    
                    if(!res.ok) {
                        alert("Error al eliminar los turnos");
                        return;
                    }
                } catch(e) {
                    console.error(e);
                    alert("Error de conexión al eliminar turnos");
                    return;
                }
            }
            
            // Proceed to remove from view locally
            visibleEmployeeIds = visibleEmployeeIds.filter(id => id !== empId);
            saveVisibleEmployees();
            renderGrid();
            // Reload shifts to reflect deletion
            loadShifts(document.getElementById('date-picker').value);
        }
        
        function initEmployeeSelector() {
            const btnCancel = document.getElementById('btn-cancel-selector');
            const btnConfirm = document.getElementById('btn-confirm-selector');
            const searchInput = document.getElementById('emp-selector-search');
            const btnPrev = document.getElementById('emp-selector-prev');
            const btnNext = document.getElementById('emp-selector-next');
            
            if(btnCancel) btnCancel.addEventListener('click', closeEmployeeSelector);
            if(btnConfirm) btnConfirm.addEventListener('click', confirmEmployeeSelection);
            
            if(searchInput) {
                searchInput.addEventListener('input', (e) => {
                    empSelectorSearch = e.target.value.toLowerCase();
                    empSelectorPage = 1;
                    renderEmployeeSelectorList();
                });
            }
            
            if(btnPrev) {
                btnPrev.addEventListener('click', () => {
                    if(empSelectorPage > 1) {
                        empSelectorPage--;
                        renderEmployeeSelectorList();
                    }
                });
            }
            
            if(btnNext) {
                btnNext.addEventListener('click', () => {
                    empSelectorPage++;
                    renderEmployeeSelectorList();
                });
            }
        }
        
        function openEmployeeSelector() {
            const dialog = document.getElementById('employee-selector-dialog');
            const searchInput = document.getElementById('emp-selector-search');
            
            // Reset State
            empSelectorPage = 1;
            empSelectorSearch = "";
            if(searchInput) searchInput.value = "";
            
            // Initialize Selection with current visible
            tempSelectedEmpIds = new Set(visibleEmployeeIds);
            
            renderEmployeeSelectorList();
            updateSelectionCount();
            
            dialog.show();
        }
        
        function renderEmployeeSelectorList() {
            const list = document.getElementById('employee-selector-list');
            const btnPrev = document.getElementById('emp-selector-prev');
            const btnNext = document.getElementById('emp-selector-next');
            const pageInfo = document.getElementById('emp-selector-page-info');
            
            list.innerHTML = '';
            
            // Filter
            const filtered = EMPLOYEES.filter(e => {
                const term = empSelectorSearch;
                return !term || 
                       e.nombres.toLowerCase().includes(term) || 
                       e.apellidos.toLowerCase().includes(term) || 
                       e.dni.includes(term) ||
                       e.role.toLowerCase().includes(term);
            });
            
            // Pagination
            const totalPages = Math.ceil(filtered.length / empSelectorPerPage) || 1;
            if(empSelectorPage > totalPages) empSelectorPage = totalPages;
            if(empSelectorPage < 1) empSelectorPage = 1;
            
            const startStr = (empSelectorPage - 1) * empSelectorPerPage;
            const endStr = startStr + empSelectorPerPage;
            const pageItems = filtered.slice(startStr, endStr);
            
            // Render
            if(pageItems.length === 0) {
                list.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-secondary);">No se encontraron empleados</div>';
            } else {
                pageItems.forEach(emp => {
                    const isSelected = tempSelectedEmpIds.has(emp.id);
                    const item = document.createElement('div');
                    item.className = 'employee-selector-item' + (isSelected ? ' selected' : '');
                    item.dataset.empId = emp.id;
                    
                    const initials = (emp.nombres[0] || '') + (emp.apellidos[0] || '');
                    item.innerHTML = '<div class="avatar">' + initials.toUpperCase() + '</div>' +
                        '<div>' +
                            '<div style="font-weight:600;">' + emp.nombres.split(' ')[0] + ' ' + emp.apellidos.split(' ')[0] + '</div>' +
                            '<div style="font-size:0.8rem; color:var(--text-secondary);">' + emp.role + ' - ' + emp.dni + '</div>' +
                        '</div>';
                    
                    item.addEventListener('click', () => {
                        if(tempSelectedEmpIds.has(emp.id)) {
                            tempSelectedEmpIds.delete(emp.id);
                            item.classList.remove('selected');
                        } else {
                            tempSelectedEmpIds.add(emp.id);
                            item.classList.add('selected');
                        }
                        updateSelectionCount();
                    });
                    
                    list.appendChild(item);
                });
            }
            
            // Update Controls
            pageInfo.textContent = 'Página ' + empSelectorPage + ' de ' + totalPages;
            btnPrev.disabled = empSelectorPage <= 1;
            btnNext.disabled = empSelectorPage >= totalPages;
        }
        
        function updateSelectionCount() {
            const countSpan = document.getElementById('emp-selector-count');
            if(countSpan) {
                countSpan.textContent = '(' + tempSelectedEmpIds.size + ')';
            }
        }
        
        function closeEmployeeSelector() {
            document.getElementById('employee-selector-dialog').close();
        }
        
        function confirmEmployeeSelection() {
            visibleEmployeeIds = Array.from(tempSelectedEmpIds);
            saveVisibleEmployees();
            closeEmployeeSelector();
            renderGrid();
            renderShifts();
        }
        
        // --- Grid Rendering ---
        function renderGrid() {
            const grid = document.getElementById('scheduler-grid');
            if(!grid) return;
            grid.innerHTML = '';
            
            const visibleEmps = getVisibleEmployees();
            
            // 1. Header Row (Corner + Employees + Placeholder)
            const headerRow = document.createElement('div');
            headerRow.className = 'header-row';
            
            const corner = document.createElement('div');
            corner.className = 'corner-header';
            corner.textContent = 'HORA / EMP';
            headerRow.appendChild(corner);
            
            visibleEmps.forEach(emp => {
                const cell = document.createElement('div');
                cell.className = 'employee-header';
                cell.style.position = 'relative';
                const shortName = emp.nombres.split(' ')[0] + ' ' + emp.apellidos.split(' ')[0];
                cell.innerHTML = '<div class="emp-name">' + shortName + '</div><div class="emp-role">' + emp.role + '</div>';
                
                // Remove button
                const removeBtn = document.createElement('button');
                removeBtn.className = 'emp-remove-btn';
                removeBtn.innerHTML = '<span class="material-symbols-outlined">close</span>';
                removeBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    removeEmployeeFromView(emp.id);
                });
                cell.appendChild(removeBtn);
                
                headerRow.appendChild(cell);
            });
            
            // Add Placeholder column
            const placeholder = document.createElement('div');
            placeholder.className = 'employee-header placeholder';
            placeholder.innerHTML = '<span class="material-symbols-outlined placeholder-icon">person_add</span><div class="placeholder-text">Agregar</div>';
            placeholder.addEventListener('click', openEmployeeSelector);
            headerRow.appendChild(placeholder);
            
            grid.appendChild(headerRow);
            
            // 2. Time Column
            const timeCol = document.createElement('div');
            timeCol.className = 'time-col';
            
            for(let h = START_HOUR; h < END_HOUR; h++) {
                const hourSlot = document.createElement('div');
                hourSlot.className = 'time-slot';
                hourSlot.textContent = h.toString().padStart(2, '0') + ':00';
                timeCol.appendChild(hourSlot);
            }
            grid.appendChild(timeCol);
            
            // 3. Grid Canvas
            const canvas = document.createElement('div');
            canvas.className = 'grid-canvas';
            
            for(let h = START_HOUR; h < END_HOUR; h++) {
                const row = document.createElement('div');
                row.className = 'grid-row';
                
                visibleEmps.forEach(emp => {
                    const cell = document.createElement('div');
                    cell.className = 'grid-cell';
                    cell.dataset.empId = emp.id;
                    cell.dataset.hour = h;
                    
                    if(IS_ADMIN) {
                        cell.addEventListener('dblclick', () => openDialog(null, emp.id, h.toString().padStart(2,'0') + ':00', (h+4).toString().padStart(2,'0') + ':00'));
                    }
                    
                    row.appendChild(cell);
                });
                
                // Extra cell for placeholder column (no interaction)
                const placeholderCell = document.createElement('div');
                placeholderCell.className = 'grid-cell';
                placeholderCell.style.borderRight = 'none';
                row.appendChild(placeholderCell);
                
                canvas.appendChild(row);
            }
            
            grid.appendChild(canvas);
        }
        
        async function loadShifts(date) {
             // 1. Update Session Date in Background (so F5 uses this date)
             try {
                fetch(CTX + '/horarios/api/set-date', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({fecha: date})
                });
             } catch(e) { console.error("Error setting session date", e); }
             
             // 2. Load Data (AJAX)
             try {
                 const res = await fetch(CTX + '/horarios/api/list?fecha=' + date);
                 if(res.ok) {
                     shifts = await res.json();
                     renderShifts();
                 }
             } catch(e) { console.error(e); }
        }
        
        function renderShifts() {
            document.querySelectorAll('.shift-event').forEach(e => e.remove());
            
            const canvas = document.querySelector('.grid-canvas');
            if(!canvas) return;
            
            const visibleEmps = getVisibleEmployees();
            
            shifts.forEach(shift => {
                const empIndex = visibleEmps.findIndex(e => e.id == shift.empleadoId);
                if(empIndex === -1) return; // Employee not visible
                
                const startDec = textToDecimal(shift.horaInicio);
                const endDec = textToDecimal(shift.horaFin);
                
                if(endDec <= START_HOUR) return;
                
                const effectiveStart = Math.max(startDec, START_HOUR);
                const top = (effectiveStart - START_HOUR) * CELL_HEIGHT;
                const duration = endDec - effectiveStart;
                const height = duration * CELL_HEIGHT;
                const left = empIndex * COL_WIDTH;
                
                const el = document.createElement('div');
                el.className = 'shift-event';
                el.style.top = (top + 1) + 'px';
                el.style.height = (height - 2) + 'px';
                el.style.left = (left + 4) + 'px';
                el.style.backgroundColor = shift.color || 'var(--shift-default)';
                el.style.color = '#222'; 
                el.dataset.shiftId = shift.id;
                el.dataset.empId = shift.empleadoId;
                
                el.innerHTML = '<strong>' + shift.horaInicio + ' - ' + shift.horaFin + '</strong><div>' + shift.tipoTurno + '</div>';
                
                // Add resize handles (top and bottom)
                if(IS_ADMIN) {
                    const handleTop = document.createElement('div');
                    handleTop.className = 'resize-handle top';
                    handleTop.addEventListener('mousedown', (e) => startResize(e, shift, 'top'));
                    el.appendChild(handleTop);
                    
                    const handleBottom = document.createElement('div');
                    handleBottom.className = 'resize-handle bottom';
                    handleBottom.addEventListener('mousedown', (e) => startResize(e, shift, 'bottom'));
                    el.appendChild(handleBottom);
                    
                    // Drag start
                    el.addEventListener('mousedown', (e) => {
                        if(e.target.classList.contains('resize-handle')) return;
                        startDrag(e, shift, el);
                    });
                    
                    // Click to edit - only if not a real drag
                    el.addEventListener('click', (e) => {
                        if(isResizing) return;
                        // Only open dialog if mouse didn't move significantly (was a click, not a drag)
                        if(!hasMoved) {
                            e.stopPropagation();
                            openDialog(shift);
                        }
                    });
                }
                
                // Tooltip events
                el.addEventListener('mouseenter', (e) => showTooltip(e, shift));
                el.addEventListener('mouseleave', hideTooltip);
                el.addEventListener('mousemove', updateTooltipPosition);
                
                canvas.appendChild(el);
            });
        }
        
        // --- Drag & Drop ---
        function startDrag(e, shift, element) {
            if(e.button !== 0) return;
            e.preventDefault();
            
            // Reset hasMoved flag - will be set to true if mouse moves beyond threshold
            hasMoved = false;
            isDragging = true;
            dragData = {
                shift: shift,
                originalElement: element,
                startX: e.clientX,
                startY: e.clientY,
                offsetX: e.clientX - element.getBoundingClientRect().left,
                offsetY: e.clientY - element.getBoundingClientRect().top,
                ghostCreated: false // Track if ghost was created
            };
            
            // Don't create ghost immediately - wait for actual movement
            hideTooltip();
        }
        
        function handleMouseMove(e) {
            if(isDragging && dragData) {
                // Check if mouse has moved beyond threshold
                const deltaX = Math.abs(e.clientX - dragData.startX);
                const deltaY = Math.abs(e.clientY - dragData.startY);
                
                if(!hasMoved && (deltaX > DRAG_THRESHOLD || deltaY > DRAG_THRESHOLD)) {
                    hasMoved = true;
                    
                    // Create ghost now that we know it's a real drag
                    if(!dragData.ghostCreated) {
                        const element = dragData.originalElement;
                        ghostElement = element.cloneNode(true);
                        ghostElement.classList.add('shift-ghost');
                        ghostElement.style.width = element.offsetWidth + 'px';
                        ghostElement.style.height = element.offsetHeight + 'px';
                        ghostElement.style.left = (e.clientX - dragData.offsetX) + 'px';
                        ghostElement.style.top = (e.clientY - dragData.offsetY) + 'px';
                        document.body.appendChild(ghostElement);
                        element.classList.add('dragging');
                        dragData.ghostCreated = true;
                    }
                }
                
                if(ghostElement) {
                    ghostElement.style.left = (e.clientX - dragData.offsetX) + 'px';
                    ghostElement.style.top = (e.clientY - dragData.offsetY) + 'px';
                    
                    // Show ctrl indicator if Ctrl is held
                    if(e.ctrlKey) {
                        document.getElementById('ctrl-indicator').classList.add('visible');
                    } else {
                        document.getElementById('ctrl-indicator').classList.remove('visible');
                    }
                    
                    // Highlight drop target
                    updateDropTarget(e);
                }
            }
            
            if(isResizing && dragData) {
                handleResize(e);
            }
        }
        
        function updateDropTarget(e) {
            // Clear previous target
            document.querySelectorAll('.grid-cell.drop-target, .grid-cell.drop-invalid').forEach(c => {
                c.classList.remove('drop-target', 'drop-invalid');
            });
            
            const cell = document.elementFromPoint(e.clientX, e.clientY);
            if(cell && cell.classList.contains('grid-cell') && cell.dataset.empId) {
                cell.classList.add('drop-target');
                currentDropTarget = cell;
            } else {
                currentDropTarget = null;
            }
        }
        
        async function handleMouseUp(e) {
            if(isDragging) {
                const ctrlHeld = e.ctrlKey;
                
                // Clear ghost and styling
                if(ghostElement) {
                    ghostElement.remove();
                    ghostElement = null;
                }
                if(dragData && dragData.originalElement) {
                    dragData.originalElement.classList.remove('dragging');
                }
                
                document.getElementById('ctrl-indicator').classList.remove('visible');
                document.querySelectorAll('.grid-cell.drop-target, .grid-cell.drop-invalid').forEach(c => {
                    c.classList.remove('drop-target', 'drop-invalid');
                });
                
                // If we have a valid drop target AND we actually dragged (not just clicked)
                if(currentDropTarget && dragData && hasMoved) {
                    const newEmpId = parseInt(currentDropTarget.dataset.empId);
                    const newHour = parseInt(currentDropTarget.dataset.hour);
                    const shift = dragData.shift;
                    
                    // Calculate new times preserving duration
                    const oldStartDec = textToDecimal(shift.horaInicio);
                    const oldEndDec = textToDecimal(shift.horaFin);
                    const duration = oldEndDec - oldStartDec;
                    
                    const newStart = decimalToText(newHour);
                    const newEnd = decimalToText(newHour + duration);
                    
                    if(ctrlHeld) {
                        // Duplicate: create new shift
                        const savedData = await saveShiftToAPI(null, newEmpId, newStart, newEnd, shift.tipoTurno);
                        if(savedData && savedData.id) {
                            // Add to local shifts array immediately so collision detection sees it
                            shifts.push({
                                id: savedData.id,
                                empleadoId: newEmpId,
                                fecha: document.getElementById('date-picker').value,
                                horaInicio: newStart,
                                horaFin: newEnd,
                                tipoTurno: shift.tipoTurno
                            });
                        }
                    } else {
                        // Move: update existing shift
                        await saveShiftToAPI(shift.id, newEmpId, newStart, newEnd, shift.tipoTurno);
                        // Update local object immediately
                        shift.empleadoId = newEmpId;
                        shift.horaInicio = newStart;
                        shift.horaFin = newEnd;
                    }
                    
                    // Check for collision and resolve
                    await resolveCollisions(newEmpId);
                }
                
                isDragging = false;
                dragData = null;
                currentDropTarget = null;
            }
            
            if(isResizing) {
                await finishResize();
            }
        }
        
        // --- Resize ---
        function startResize(e, shift, edge) {
            e.preventDefault();
            e.stopPropagation();
            
            isResizing = true;
            resizeEdge = edge;
            dragData = {
                shift: shift,
                startY: e.clientY,
                originalStart: textToDecimal(shift.horaInicio),
                originalEnd: textToDecimal(shift.horaFin)
            };
            hideTooltip();
        }
        
        function handleResize(e) {
            if(!dragData) return;
            
            const deltaY = e.clientY - dragData.startY;
            const deltaHours = deltaY / CELL_HEIGHT;
            
            let newStart = dragData.originalStart;
            let newEnd = dragData.originalEnd;
            
            if(resizeEdge === 'top') {
                newStart = Math.max(START_HOUR, Math.min(dragData.originalEnd - 0.5, dragData.originalStart + deltaHours));
                newStart = Math.round(newStart * 4) / 4; // Snap to 15min
            } else {
                newEnd = Math.max(dragData.originalStart + 0.5, Math.min(END_HOUR, dragData.originalEnd + deltaHours));
                newEnd = Math.round(newEnd * 4) / 4;
            }
            
            // Update visual immediately
            const shiftEl = document.querySelector('.shift-event[data-shift-id="' + dragData.shift.id + '"]');
            if(shiftEl) {
                const top = (Math.max(newStart, START_HOUR) - START_HOUR) * CELL_HEIGHT;
                const height = (newEnd - Math.max(newStart, START_HOUR)) * CELL_HEIGHT;
                shiftEl.style.top = (top + 1) + 'px';
                shiftEl.style.height = (height - 2) + 'px';
                shiftEl.querySelector('strong').textContent = decimalToText(newStart) + ' - ' + decimalToText(newEnd);
            }
            
            dragData.newStart = newStart;
            dragData.newEnd = newEnd;
        }
        
        async function finishResize() {
            if(dragData && dragData.newStart !== undefined) {
                const shift = dragData.shift;
                const newStart = decimalToText(dragData.newStart);
                const newEnd = decimalToText(dragData.newEnd);
                
                await saveShiftToAPI(shift.id, shift.empleadoId, newStart, newEnd, shift.tipoTurno);
                
                // Update local state immediately
                shift.horaInicio = newStart;
                shift.horaFin = newEnd;
                
                await resolveCollisions(shift.empleadoId);
            }
            
            isResizing = false;
            resizeEdge = null;
            dragData = null;
        }
        
        // --- Collision Detection & Resolution ---
        async function resolveCollisions(empId) {
            let iterations = 0;
            const maxIterations = 10;
            let hasCollision = true;
            
            while(hasCollision && iterations < maxIterations) {
                hasCollision = await resolveCollisionPass(empId);
                iterations++;
            }
            
            // Reload to get updated data
            await loadShifts(document.getElementById('date-picker').value);
        }
        
        async function resolveCollisionPass(empId) {
            // Get all shifts for this employee, sorted by start time
            const empShifts = shifts.filter(s => s.empleadoId == empId).sort((a, b) => {
                return textToDecimal(a.horaInicio) - textToDecimal(b.horaInicio);
            });
            
            let foundCollision = false;
            const updatePromises = [];
            
            // Cascade through all shifts - resolve ALL collisions in one pass
            for(let i = 0; i < empShifts.length - 1; i++) {
                const current = empShifts[i];
                const next = empShifts[i + 1];
                
                const currentEnd = textToDecimal(current.horaFin);
                const nextStart = textToDecimal(next.horaInicio);
                
                if(currentEnd > nextStart) {
                    // Collision detected! Push next shift down immediately
                    const newNextStart = currentEnd;
                    const nextDuration = textToDecimal(next.horaFin) - textToDecimal(next.horaInicio);
                    const newNextEnd = Math.min(END_HOUR, newNextStart + nextDuration);
                    
                    // Update local data immediately so next iteration sees correct values
                    next.horaInicio = decimalToText(newNextStart);
                    next.horaFin = decimalToText(newNextEnd);
                    
                    // Queue API call (don't await to avoid multiple round trips)
                    updatePromises.push(
                        saveShiftToAPI(
                            next.id, 
                            next.empleadoId, 
                            next.horaInicio, 
                            next.horaFin, 
                            next.tipoTurno
                        )
                    );
                    
                    foundCollision = true;
                }
            }
            
            // Wait for all API calls to complete
            if(updatePromises.length > 0) {
                await Promise.all(updatePromises);
            }
            
            return foundCollision;
        }
        
        // --- Tooltip ---
        function showTooltip(e, shift) {
            if(isDragging || isResizing) return;
            
            tooltipTimeout = setTimeout(() => {
                const tooltip = document.getElementById('shift-tooltip');
                const emp = EMPLOYEES.find(em => em.id == shift.empleadoId);
                
                if(!emp) return;
                
                // Calculate employee's total hours for the day
                const empShifts = shifts.filter(s => s.empleadoId == shift.empleadoId);
                let totalHours = 0;
                empShifts.forEach(s => {
                    totalHours += textToDecimal(s.horaFin) - textToDecimal(s.horaInicio);
                });
                
                const shiftDuration = textToDecimal(shift.horaFin) - textToDecimal(shift.horaInicio);
                const initials = (emp.nombres[0] || '') + (emp.apellidos[0] || '');
                
                document.getElementById('tooltip-avatar').textContent = initials.toUpperCase();
                document.getElementById('tooltip-name').textContent = emp.nombres.split(' ')[0] + ' ' + emp.apellidos.split(' ')[0];
                document.getElementById('tooltip-role').textContent = emp.role + ' - DNI: ' + emp.dni;
                document.getElementById('tooltip-hours').textContent = totalHours.toFixed(1) + 'h';
                document.getElementById('tooltip-shifts').textContent = empShifts.length;
                document.getElementById('tooltip-type').textContent = shift.tipoTurno;
                document.getElementById('tooltip-time').textContent = shift.horaInicio + ' - ' + shift.horaFin + ' (' + shiftDuration.toFixed(1) + 'h)';
                
                positionTooltip(e);
                tooltip.classList.add('visible');
            }, 400);
        }
        
        function hideTooltip() {
            if(tooltipTimeout) {
                clearTimeout(tooltipTimeout);
                tooltipTimeout = null;
            }
            document.getElementById('shift-tooltip').classList.remove('visible');
        }
        
        function updateTooltipPosition(e) {
            positionTooltip(e);
        }
        
        function positionTooltip(e) {
            const tooltip = document.getElementById('shift-tooltip');
            const padding = 16;
            let x = e.clientX + padding;
            let y = e.clientY + padding;
            
            // Prevent going off-screen
            const rect = tooltip.getBoundingClientRect();
            if(x + rect.width > window.innerWidth) {
                x = e.clientX - rect.width - padding;
            }
            if(y + rect.height > window.innerHeight) {
                y = e.clientY - rect.height - padding;
            }
            
            tooltip.style.left = x + 'px';
            tooltip.style.top = y + 'px';
        }
        
        // --- Logic: Dialogs ---
        function openDialog(shift, empId, startStr, endStr) {
            const d = document.getElementById('shift-dialog');
            const sel = document.getElementById('shift-employee');

            if(shift) {
                 sel.value = shift.empleadoId.toString();
            } else if(empId) {
                 sel.value = empId.toString();
            } else {
                 sel.value = "";
            }

            if(shift) {
                d.querySelector('[slot="headline"]').textContent = "Editar Turno";
                document.getElementById('shift-id').value = shift.id;
                document.getElementById('shift-start').value = shift.horaInicio;
                document.getElementById('shift-end').value = shift.horaFin;
                document.getElementById('shift-type').value = shift.tipoTurno;
                const btnDel = document.getElementById('btn-delete-dialog');
                if(btnDel) btnDel.style.display = 'inline-flex';
            } else {
                d.querySelector('[slot="headline"]').textContent = "Nuevo Turno";
                document.getElementById('shift-id').value = "";
                document.getElementById('shift-start').value = startStr || "08:00";
                document.getElementById('shift-end').value = endStr || "17:00";
                document.getElementById('shift-type').value = "Atencion";
                const btnDel = document.getElementById('btn-delete-dialog');
                if(btnDel) btnDel.style.display = 'none';
            }
            
            d.show();
        }
        
        function closeDialog() {
            document.getElementById('shift-dialog').close();
        }
        
        function saveFromDialog() {
             const idNode = document.getElementById('shift-id');
             const empNode = document.getElementById('shift-employee');
             const startNode = document.getElementById('shift-start');
             const endNode = document.getElementById('shift-end');
             const typeNode = document.getElementById('shift-type');
             
             saveShiftElement(idNode.value, empNode.value, startNode.value, endNode.value, typeNode.value);
             closeDialog();
        }

        function deleteFromDialog() {
            const id = document.getElementById('shift-id').value;
             if(id && confirm("¿Eliminar turno?")) {
                 fetch(CTX + '/horarios/api/eliminar', {
                     method: 'POST',
                     headers: {'Content-Type': 'application/json'},
                     body: JSON.stringify({id: id})
                 }).then(res => {
                      if(res.ok) {
                          closeDialog();
                          loadShifts(document.getElementById('date-picker').value);
                      } else {
                          alert("Error al eliminar");
                      }
                 });
             }
        }
        
        // --- API & Helpers ---
        async function saveShiftElement(id, empId, start, end, type) {
            if (!empId) {
                alert("Por favor selecciona un empleado");
                return;
            }
            
            const timePattern = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
            
            if (!start || !end || !timePattern.test(start) || !timePattern.test(end)) {
                alert("Horas inválidas. Formato requerido: HH:MM");
                return;
            }
            
            if(start.length === 4 && start.indexOf(':')===1) start = "0" + start;
            if(end.length === 4 && end.indexOf(':')===1) end = "0" + end;
            
            // Auto-add employee to visible grid if not already visible
            const empIdInt = parseInt(empId);
            if(!visibleEmployeeIds.includes(empIdInt)) {
                addEmployeeToView(empIdInt);
            }
            
            await saveShiftToAPI(id || null, empId, start, end, type);
            await loadShifts(document.getElementById('date-picker').value);
        }
        
        async function saveShiftToAPI(id, empId, start, end, type) {
            const date = document.getElementById('date-picker').value;
            const payload = {
                id: id,
                empleadoId: empId,
                fecha: date,
                horaInicio: start,
                horaFin: end,
                tipoTurno: type
            };
            
            try {
                const res = await fetch(CTX + '/horarios/api/guardar', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(payload)
                });
                
                if(!res.ok) {
                    const txt = await res.text();
                    console.error("Error al guardar:", txt);
                    return null;
                }
                
                return await res.json();
            } catch (e) {
                console.error(e);
                return null;
            }
        }

        function textToDecimal(timeStr) {
            if(!timeStr || !timeStr.includes(':')) return 0;
            const parts = timeStr.split(':');
            return parseFloat(parts[0]) + (parseFloat(parts[1])/60);
        }
        
        function decimalToText(decimal) {
             if(isNaN(decimal)) return "00:00";
             let h = Math.floor(decimal);
             let m = Math.round((decimal - h) * 60);
             if(m === 60) { h++; m=0; }
             if(h >= 24) { return "23:59"; }
             return h.toString().padStart(2,'0') + ':' + m.toString().padStart(2,'0');
        }
        
        // --- Copy From Any Date ---
        function openCopyFromDateModal() {
            const dialog = document.getElementById('copy-from-date-dialog');
            const sourceDate = document.getElementById('copy-source-date');
            
            // Default to yesterday
            const yesterday = new Date();
            yesterday.setDate(yesterday.getDate() - 1);
            sourceDate.value = yesterday.toISOString().split('T')[0];
            
            dialog.show();
        }
        
        function closeCopyFromDateModal() {
            document.getElementById('copy-from-date-dialog').close();
        }
        
        async function confirmCopyFromDate() {
            const sourceDate = document.getElementById('copy-source-date').value;
            const targetDate = document.getElementById('date-picker').value;
            
            if(!sourceDate) {
                alert('Por favor selecciona una fecha origen');
                return;
            }
            
            if(sourceDate === targetDate) {
                alert('La fecha origen debe ser diferente a la fecha destino');
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/copiar-dia', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        fechaOrigen: sourceDate,
                        fechaDestino: targetDate
                    })
                });
                
                if(res.ok) {
                    const data = await res.json();
                    closeCopyFromDateModal();
                    alert('Se copiaron ' + data.copiados + ' turnos exitosamente');
                    await loadShifts(targetDate);
                } else {
                    alert('Error al copiar turnos');
                }
            } catch(e) {
                console.error(e);
                alert('Error al copiar turnos');
            }
        }
        
        // --- Plantillas de Día (Full Day Templates) ---
        let plantillasDiaData = [];
        
        async function openPlantillasDiaModal() {
            const dialog = document.getElementById('plantillas-dia-dialog');
            document.getElementById('new-plantilla-name').value = '';
            
            await loadPlantillasDia();
            dialog.show();
        }
        
        function closePlantillasDiaModal() {
            document.getElementById('plantillas-dia-dialog').close();
        }
        
        async function loadPlantillasDia() {
            const listContainer = document.getElementById('plantillas-dia-list');
            
            try {
                const res = await fetch(CTX + '/horarios/api/plantillas-dia');
                if(res.ok) {
                    plantillasDiaData = await res.json();
                }
            } catch(e) {
                console.error(e);
            }
            
            if(plantillasDiaData.length === 0) {
                listContainer.innerHTML = '<div class="empty-state" style="text-align: center; padding: 24px; color: var(--text-secondary);">' +
                    '<span class="material-symbols-outlined" style="font-size: 48px; opacity: 0.5;">folder_off</span>' +
                    '<p>No hay plantillas guardadas</p>' +
                '</div>';
                return;
            }
            
            listContainer.innerHTML = '';
            plantillasDiaData.forEach(p => {
                const item = document.createElement('div');
                item.className = 'plantilla-item';
                item.innerHTML = 
                    '<div class="plantilla-item-info">' +
                        '<div class="plantilla-item-name">' + p.nombre + '</div>' +
                        '<div class="plantilla-item-meta">' +
                            '<span>' + p.cantidadTurnos + ' turnos</span>' +
                            '<span>Creada: ' + (p.fechaCreacion || 'N/A') + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div class="plantilla-item-actions">' +
                        '<md-filled-tonal-icon-button data-id="' + p.id + '" class="apply-plantilla-dia" title="Aplicar">' +
                            '<md-icon>play_arrow</md-icon>' +
                        '</md-filled-tonal-icon-button>' +
                        '<md-icon-button data-id="' + p.id + '" class="delete-plantilla-dia" title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);">' +
                            '<md-icon>delete</md-icon>' +
                        '</md-icon-button>' +
                    '</div>';
                
                // Apply button
                item.querySelector('.apply-plantilla-dia').addEventListener('click', () => applyPlantillaDia(p.id));
                
                // Delete button
                item.querySelector('.delete-plantilla-dia').addEventListener('click', () => deletePlantillaDia(p.id));
                
                listContainer.appendChild(item);
            });
        }
        
        async function saveCurrentDayAsPlantilla() {
            const nombre = document.getElementById('new-plantilla-name').value.trim();
            const fecha = document.getElementById('date-picker').value;
            
            if(!nombre) {
                alert('Por favor ingresa un nombre para la plantilla');
                return;
            }
            
            if(shifts.length === 0) {
                alert('No hay turnos en el día actual para guardar');
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/guardar-plantilla-dia', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        nombre: nombre,
                        fecha: fecha
                    })
                });
                
                if(res.ok) {
                    const data = await res.json();
                    document.getElementById('new-plantilla-name').value = '';
                    await loadPlantillasDia();
                    alert('Plantilla guardada con ' + data.turnos + ' turnos');
                } else {
                    const errText = await res.text();
                    alert('Error: ' + errText);
                }
            } catch(e) {
                console.error(e);
                alert('Error al guardar plantilla');
            }
        }
        
        async function applyPlantillaDia(plantillaId) {
            const targetDate = document.getElementById('date-picker').value;
            
            if(!confirm('¿Aplicar esta plantilla al día ' + targetDate + '? Se crearán los turnos guardados.')) {
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/aplicar-plantilla-dia', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        plantillaId: plantillaId,
                        fechaDestino: targetDate
                    })
                });
                
                if(res.ok) {
                    const data = await res.json();
                    closePlantillasDiaModal();
                    alert('Plantilla aplicada: ' + data.creados + ' turnos creados');
                    await loadShifts(targetDate);
                } else {
                    alert('Error al aplicar plantilla');
                }
            } catch(e) {
                console.error(e);
                alert('Error al aplicar plantilla');
            }
        }
        
        async function deletePlantillaDia(plantillaId) {
            if(!confirm('¿Eliminar esta plantilla permanentemente?')) {
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/eliminar-plantilla-dia', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        id: plantillaId
                    })
                });
                
                if(res.ok) {
                    await loadPlantillasDia();
                } else {
                    alert('Error al eliminar plantilla');
                }
            } catch(e) {
                console.error(e);
                alert('Error al eliminar plantilla');
            }
        }
        
        // --- Legacy Per-Employee Plantillas Modal ---
        let plantillasData = [];
        
        async function openPlantillasModal() {
            const dialog = document.getElementById('plantillas-dialog');
            const plantillaSelect = document.getElementById('plantilla-select');
            const employeeSelect = document.getElementById('plantilla-employee');
            
            // Fetch plantillas
            try {
                const res = await fetch(CTX + '/horarios/api/plantillas');
                if(res.ok) {
                    plantillasData = await res.json();
                }
            } catch(e) {
                console.error(e);
            }
            
            // Populate plantilla select
            plantillaSelect.innerHTML = '';
            plantillasData.forEach(p => {
                const opt = document.createElement('md-select-option');
                opt.value = p.id.toString();
                opt.innerHTML = '<div slot="headline">' + p.nombre + '</div>';
                plantillaSelect.appendChild(opt);
            });
            
            // Populate employee select
            employeeSelect.innerHTML = '';
            EMPLOYEES.forEach(e => {
                const opt = document.createElement('md-select-option');
                opt.value = e.id.toString();
                opt.innerHTML = '<div slot="headline">' + e.nombres.split(' ')[0] + ' ' + e.apellidos.split(' ')[0] + '</div>';
                employeeSelect.appendChild(opt);
            });
            
            dialog.show();
        }
        
        function closePlantillasModal() {
            document.getElementById('plantillas-dialog').close();
        }
        
        async function applyPlantilla() {
            const plantillaId = document.getElementById('plantilla-select').value;
            const empleadoId = document.getElementById('plantilla-employee').value;
            const fecha = document.getElementById('date-picker').value;
            
            if(!plantillaId || !empleadoId) {
                alert('Por favor selecciona una plantilla y un empleado');
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/aplicar-plantilla', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        plantillaId: plantillaId,
                        empleadoId: empleadoId,
                        fecha: fecha
                    })
                });
                
                if(res.ok) {
                    closePlantillasModal();
                    
                    // Auto-add employee to visible list
                    const empIdInt = parseInt(empleadoId);
                    if(!visibleEmployeeIds.includes(empIdInt)) {
                        addEmployeeToView(empIdInt);
                    }
                    
                    await loadShifts(fecha);
                    alert('Plantilla aplicada exitosamente');
                } else {
                    alert('Error al aplicar plantilla');
                }
            } catch(e) {
                console.error(e);
                alert('Error al aplicar plantilla');
            }
        }
        
        // --- Copy to Date ---
        let copyToDateShiftId = null;
        
        function openCopyToDateFromContext() {
            const ctxMenu = document.getElementById('context-menu');
            ctxMenu.style.display = 'none';
            
            // Get shift ID from context (stored when context menu opened)
            if(!copyToDateShiftId) return;
            
            const dialog = document.getElementById('copy-date-dialog');
            const dateInput = document.getElementById('copy-target-date');
            
            // Default to tomorrow
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            dateInput.value = tomorrow.toISOString().split('T')[0];
            
            dialog.show();
        }
        
        function closeCopyDateModal() {
            document.getElementById('copy-date-dialog').close();
            copyToDateShiftId = null;
        }
        
        async function confirmCopyToDate() {
            const targetDate = document.getElementById('copy-target-date').value;
            
            if(!targetDate) {
                alert('Por favor selecciona una fecha destino');
                return;
            }
            
            if(!copyToDateShiftId) {
                alert('No se ha seleccionado ningún turno');
                return;
            }
            
            try {
                const res = await fetch(CTX + '/horarios/api/copiar-turno', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        turnoId: copyToDateShiftId,
                        fechaDestino: targetDate
                    })
                });
                
                if(res.ok) {
                    closeCopyDateModal();
                    alert('Turno copiado exitosamente a ' + targetDate);
                } else {
                    alert('Error al copiar turno');
                }
            } catch(e) {
                console.error(e);
                alert('Error al copiar turno');
            }
        }
        
        // Store shift ID when context menu appears
        function setupContextMenuShiftCapture() {
            document.addEventListener('contextmenu', (e) => {
                const shiftEl = e.target.closest('.shift-event');
                if(shiftEl) {
                    copyToDateShiftId = parseInt(shiftEl.dataset.shiftId);
                }
            });
        }
        
        // --- Styles Patch (Final Robust Fix + Animations) ---
        // --- Styles Patch (Final Robust Fix + Animations) ---
        function fixDialogScrim() {
            customElements.whenDefined('md-dialog').then(() => {
                const dialogs = document.querySelectorAll('md-dialog');
                dialogs.forEach(d => {
                    if (d && d.shadowRoot) {
                        const style = document.createElement('style');
                        style.textContent = `
                            .scrim { 
                                z-index: -1 !important; 
                                opacity: 0 !important; 
                                pointer-events: none !important;
                                background-color: rgba(0,0,0,0.4) !important;
                                backdrop-filter: blur(8px) !important;
                                display: flex !important;
                                inset: 0 !important;
                                position: fixed !important;
                                transition: opacity 0.3s ease, z-index 0s 0.3s; 
                            }
                            :host([open]) .scrim {
                                z-index: inherit !important; 
                                opacity: 1 !important; 
                                pointer-events: auto !important;
                                transition: opacity 0.4s ease, z-index 0s;
                            }
                            .container {
                                overflow: visible !important;
                                border-radius: 28px !important;
                            }
                            :host {
                                overflow: visible !important;
                            }
                            dialog {
                                overflow: visible !important;
                            }
                        `;
                        d.shadowRoot.appendChild(style);
                    }
                });
            });
        }
        
        // --- Excel Export Function (Native XLSX with styling) ---
        function exportToExcel() {
            const date = document.getElementById('date-picker').value;
            const visibleEmps = getVisibleEmployees();
            
            if(visibleEmps.length === 0) {
                alert('No hay empleados visibles para exportar');
                return;
            }
            
            // Color map for shift types (ARGB format for xlsx-js-style)
            const shiftColorMap = {
                'Caja': 'FFFFCDD2',
                'Caja 2do Nivel': 'FFEF9A9A',
                'Preventa': 'FFE1BEE7',
                'Despacho PreVenta': 'FFCE93D8',
                'Atencion': 'FFC8E6C9',
                'ATENCION': 'FFC8E6C9',
                'Refrigerio': 'FFFFF9C4',
                'Pesado': 'FFD1C4E9',
                'PESADO': 'FFD1C4E9',
                'Despacho': 'FFBBDEFB',
                'Stock': 'FFFFE0B2',
                'STOCK': 'FFFFE0B2'
            };
            
            // Build title with date
            const fechaObj = new Date(date + 'T00:00:00');
            const dia = fechaObj.getDate();
            const endDia = dia + 4; // Assuming week range
            const mes = fechaObj.toLocaleDateString('es-ES', { month: 'short' });
            const titulo = 'Programación de los turnos de los empleados (Del ' + dia + ' al ' + endDia + ' ' + mes.charAt(0).toUpperCase() + mes.slice(1) + '.)';
            
            // Define hour range
            const startHour = 7;
            const endHour = 20; // up to 20:00
            const dataStartRow = 5; // Row index where data starts (0-indexed)
            
            // Build data array with shift tracking for merges
            const data = [];
            const cellShiftMap = {}; // Track which shift covers each cell for merging
            
            // Row 0: Empty (will be title)
            data.push([]);
            
            // Row 1: Title
            const titleRow = [titulo];
            for(let i = 0; i < visibleEmps.length; i++) titleRow.push('');
            data.push(titleRow);
            
            // Row 2: Empty
            data.push([]);
            
            // Row 3: HORAS header row
            const horasRow = ['HORAS:'];
            visibleEmps.forEach((emp, idx) => {
                horasRow.push((idx + 1) + '.00');
            });
            data.push(horasRow);
            
            // Row 4: TRABAJADOR header row - handle duplicate names
            const trabajadorRow = ['TRABAJADOR:'];
            
            // Build display names with duplicate detection
            const displayNames = visibleEmps.map(emp => {
                const firstName = emp.nombres.split(' ')[0].toUpperCase();
                const lastNames = emp.apellidos ? emp.apellidos.split(' ') : [];
                const firstLastName = lastNames[0] ? lastNames[0].toUpperCase() : '';
                const secondLastName = lastNames[1] ? lastNames[1].toUpperCase() : '';
                return { emp, firstName, firstLastName, secondLastName };
            });
            
            displayNames.forEach((item, idx) => {
                // Check for duplicates with same first name
                const duplicatesFirstName = displayNames.filter(d => d.firstName === item.firstName);
                
                if(duplicatesFirstName.length > 1) {
                    // Check if first name + first last name is also duplicated
                    const duplicatesWithLastName = duplicatesFirstName.filter(d => 
                        d.firstLastName === item.firstLastName
                    );
                    
                    if(duplicatesWithLastName.length > 1) {
                        // Check if even second last name is duplicated
                        const duplicatesFullName = duplicatesWithLastName.filter(d =>
                            d.secondLastName === item.secondLastName
                        );
                        
                        if(duplicatesFullName.length > 1) {
                            // Fallback: add sequential number (find position among duplicates)
                            const position = duplicatesFullName.findIndex(d => d.emp.id === item.emp.id) + 1;
                            const baseName = item.firstName + (item.firstLastName ? ' ' + item.firstLastName.charAt(0) + '.' : '');
                            trabajadorRow.push(baseName + ' (' + position + ')');
                        } else if(item.secondLastName) {
                            // Add initial of second last name
                            trabajadorRow.push(item.firstName + ' ' + item.secondLastName.charAt(0) + '.');
                        } else {
                            // No second last name, use number
                            const position = duplicatesWithLastName.findIndex(d => d.emp.id === item.emp.id) + 1;
                            trabajadorRow.push(item.firstName + ' ' + item.firstLastName.charAt(0) + '. (' + position + ')');
                        }
                    } else {
                        // Add first last name initial to differentiate
                        trabajadorRow.push(item.firstName + ' ' + (item.firstLastName ? item.firstLastName.charAt(0) + '.' : ''));
                    }
                } else {
                    // No duplicates, just first name
                    trabajadorRow.push(item.firstName);
                }
            });
            
            data.push(trabajadorRow);
            
            // Data rows - hourly slots (full hours like 7:00 - 8:00)
            for(let h = startHour; h < endHour; h++) {
                const timeLabel = h + ':00 - ' + (h + 1) + ':00';
                const row = [timeLabel];
                const rowIdx = dataStartRow + (h - startHour);
                
                visibleEmps.forEach((emp, colIdx) => {
                    // Find shift that covers this hour
                    const shift = shifts.find(s => {
                        if(s.empleadoId != emp.id) return false;
                        const shiftStart = textToDecimal(s.horaInicio);
                        const shiftEnd = textToDecimal(s.horaFin);
                        // Check if the mid-point of the hour falls within the shift
                        const hourMid = h + 0.5;
                        return hourMid >= shiftStart && hourMid < shiftEnd;
                    });
                    
                    if(shift) {
                        row.push(shift.tipoTurno);
                        // Store shift info for merge calculation
                        cellShiftMap[rowIdx + '_' + (colIdx + 1)] = {
                            shiftId: shift.id,
                            tipo: shift.tipoTurno,
                            startHour: Math.floor(textToDecimal(shift.horaInicio)),
                            endHour: Math.ceil(textToDecimal(shift.horaFin))
                        };
                    } else {
                        row.push('');
                    }
                });
                data.push(row);
            }
            
            // Create worksheet
            const ws = XLSX.utils.aoa_to_sheet(data);
            
            // Define styles
            const titleStyle = {
                fill: { fgColor: { rgb: 'FFF5E6D3' } },
                font: { bold: true, sz: 12, color: { rgb: 'FF5D4037' } },
                alignment: { horizontal: 'center', vertical: 'center' },
                border: {
                    top: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    bottom: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    left: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    right: { style: 'thin', color: { rgb: 'FFD0CECE' } }
                }
            };
            
            const headerStyle = {
                fill: { fgColor: { rgb: 'FFFFF8E1' } },
                font: { bold: true, sz: 9 },
                alignment: { horizontal: 'center', vertical: 'center' },
                border: {
                    top: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    bottom: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    left: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    right: { style: 'thin', color: { rgb: 'FFD0CECE' } }
                }
            };
            
            const timeCellStyle = {
                fill: { fgColor: { rgb: 'FFFAFAFA' } },
                font: { sz: 8, color: { rgb: 'FF666666' } },
                alignment: { horizontal: 'left', vertical: 'center' },
                border: {
                    top: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    bottom: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    left: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    right: { style: 'thin', color: { rgb: 'FFD0CECE' } }
                }
            };
            
            const defaultCellStyle = {
                alignment: { horizontal: 'center', vertical: 'center' },
                font: { sz: 9 },
                border: {
                    top: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    bottom: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    left: { style: 'thin', color: { rgb: 'FFD0CECE' } },
                    right: { style: 'thin', color: { rgb: 'FFD0CECE' } }
                }
            };
            
            // Apply styles to cells
            const range = XLSX.utils.decode_range(ws['!ref']);
            for(let R = 0; R <= range.e.r; R++) {
                for(let C = 0; C <= range.e.c; C++) {
                    const cellAddr = XLSX.utils.encode_cell({ r: R, c: C });
                    if(!ws[cellAddr]) ws[cellAddr] = { v: '', t: 's' };
                    
                    const cell = ws[cellAddr];
                    
                    // Title row (row 1)
                    if(R === 1) {
                        cell.s = titleStyle;
                    }
                    // Header rows (rows 3-4)
                    else if(R === 3 || R === 4) {
                        cell.s = headerStyle;
                    }
                    // Data rows
                    else if(R >= 5) {
                        if(C === 0) {
                            // Time column
                            cell.s = timeCellStyle;
                        } else {
                            // Shift cells - apply color based on value
                            const value = cell.v;
                            if(value && shiftColorMap[value]) {
                                cell.s = {
                                    ...defaultCellStyle,
                                    fill: { fgColor: { rgb: shiftColorMap[value] } }
                                };
                            } else {
                                cell.s = defaultCellStyle;
                            }
                        }
                    }
                }
            }
            
            // Build merges array
            const merges = [
                { s: { r: 1, c: 0 }, e: { r: 1, c: visibleEmps.length } } // Title merge
            ];
            
            // Calculate vertical merges for each employee column
            for(let colIdx = 1; colIdx <= visibleEmps.length; colIdx++) {
                let mergeStart = null;
                let currentShiftId = null;
                let currentTipo = null;
                
                for(let rowIdx = dataStartRow; rowIdx <= dataStartRow + (endHour - startHour - 1); rowIdx++) {
                    const cellInfo = cellShiftMap[rowIdx + '_' + colIdx];
                    
                    if(cellInfo && cellInfo.shiftId === currentShiftId) {
                        // Continue the merge
                    } else {
                        // End previous merge if exists and spans multiple rows
                        if(mergeStart !== null && currentShiftId !== null && rowIdx - 1 > mergeStart) {
                            merges.push({
                                s: { r: mergeStart, c: colIdx },
                                e: { r: rowIdx - 1, c: colIdx }
                            });
                            
                            // Clear content from merged cells (keep only first)
                            for(let r = mergeStart + 1; r < rowIdx; r++) {
                                const addr = XLSX.utils.encode_cell({ r: r, c: colIdx });
                                if(ws[addr]) ws[addr].v = '';
                            }
                        }
                        
                        // Start new potential merge
                        if(cellInfo) {
                            mergeStart = rowIdx;
                            currentShiftId = cellInfo.shiftId;
                            currentTipo = cellInfo.tipo;
                        } else {
                            mergeStart = null;
                            currentShiftId = null;
                            currentTipo = null;
                        }
                    }
                }
                
                // Handle last merge if it extends to the end
                const lastRowIdx = dataStartRow + (endHour - startHour - 1);
                if(mergeStart !== null && currentShiftId !== null && lastRowIdx > mergeStart) {
                    merges.push({
                        s: { r: mergeStart, c: colIdx },
                        e: { r: lastRowIdx, c: colIdx }
                    });
                    
                    // Clear content from merged cells
                    for(let r = mergeStart + 1; r <= lastRowIdx; r++) {
                        const addr = XLSX.utils.encode_cell({ r: r, c: colIdx });
                        if(ws[addr]) ws[addr].v = '';
                    }
                }
            }
            
            ws['!merges'] = merges;
            
            // Set column widths
            const colWidths = [{ wch: 15 }]; // Time column
            visibleEmps.forEach(() => colWidths.push({ wch: 12 }));
            ws['!cols'] = colWidths;
            
            // Set row heights
            const rowHeights = [];
            for(let i = 0; i <= range.e.r; i++) {
                rowHeights.push({ hpt: 18 });
            }
            ws['!rows'] = rowHeights;
            
            // Create workbook and save
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Programación de Turnos');
            
            // Download
            XLSX.writeFile(wb, 'Programacion_Turnos_' + date + '.xlsx');
        }

        
        // Init
        document.addEventListener('DOMContentLoaded', () => {
             init();
             fixDialogScrim();
             setupContextMenuShiftCapture();
             
             const btnCancel = document.querySelector('md-text-button[value="cancel"]');
             if(btnCancel) {
                 btnCancel.addEventListener('click', (e) => {
                     e.preventDefault();
                     closeDialog();
                 });
             }
             
             // Excel export button listener
             const btnExport = document.getElementById('btn-export-excel');
             if(btnExport) {
                 btnExport.addEventListener('click', exportToExcel);
             }
        });
    </script>
</body>
</html>
