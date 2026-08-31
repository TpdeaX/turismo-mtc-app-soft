<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parámetros Generales | Sistema Gestión</title>
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
        .params-container {
            max-width: 820px;
        }
        
        .page-header {
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .page-header h1 {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 2rem;
            margin: 0;
        }

        .page-subtitle {
            color: var(--md-sys-color-secondary);
            margin-top: 4px;
            font-size: 0.9rem;
        }

        .config-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .config-badge.global {
            background: var(--md-sys-color-tertiary-container);
            color: var(--md-sys-color-on-tertiary-container);
        }

        .config-badge.empresa {
            background: var(--md-sys-color-primary-container);
            color: var(--md-sys-color-on-primary-container);
        }

        .section-card {
            background: var(--md-sys-color-surface);
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: 20px;
            box-shadow: var(--md-sys-elevation-1);
            margin-bottom: 24px;
            overflow: hidden;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 20px 24px 0;
        }

        .section-header .material-symbols-outlined {
            color: var(--md-sys-color-primary);
            font-size: 28px;
        }

        .section-title {
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--md-sys-color-on-surface);
        }

        .section-body {
            padding: 20px 24px 24px;
        }

        /* Form Grid for text/number inputs */
        .input-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 8px;
        }

        /* Toggle item row */
        .toggle-list {
            border-top: 1px solid var(--md-sys-color-outline-variant);
            margin-top: 16px;
            padding-top: 8px;
        }

        .toggle-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 0;
            gap: 16px;
        }

        .toggle-item + .toggle-item {
            border-top: 1px solid color-mix(in srgb, var(--md-sys-color-outline-variant) 50%, transparent);
        }

        .toggle-info {
            flex: 1;
        }

        .toggle-label {
            font-weight: 500;
            color: var(--md-sys-color-on-surface);
            font-size: 0.95rem;
        }

        .toggle-desc {
            font-size: 0.82rem;
            color: var(--md-sys-color-on-surface-variant);
            margin-top: 2px;
            line-height: 1.4;
        }

        /* MD3 Switch */
        .md3-switch {
            position: relative;
            display: inline-flex;
            align-items: center;
            width: 52px;
            height: 32px;
            flex-shrink: 0;
            cursor: pointer;
        }

        .md3-switch input {
            opacity: 0;
            width: 0;
            height: 0;
            position: absolute;
        }

        .md3-switch-track {
            width: 52px;
            height: 32px;
            border-radius: 16px;
            background: var(--md-sys-color-surface-variant);
            border: 2px solid var(--md-sys-color-outline);
            transition: all 300ms cubic-bezier(0.2, 0, 0, 1);
            position: relative;
        }

        .md3-switch-thumb {
            position: absolute;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: var(--md-sys-color-outline);
            top: 50%;
            left: 6px;
            transform: translateY(-50%);
            transition: all 300ms cubic-bezier(0.2, 0, 0, 1);
            box-shadow: var(--md-sys-elevation-1);
        }

        .md3-switch input:checked ~ .md3-switch-track {
            background: var(--md-sys-color-primary);
            border-color: var(--md-sys-color-primary);
        }

        .md3-switch input:checked ~ .md3-switch-track .md3-switch-thumb {
            left: 28px;
            width: 24px;
            height: 24px;
            background: var(--md-sys-color-on-primary);
        }

        .md3-switch:hover .md3-switch-track {
            background: var(--md-sys-color-surface-variant);
        }

        .md3-switch:hover input:checked ~ .md3-switch-track {
            background: var(--md-sys-color-primary);
        }

        /* Focus ring */
        .md3-switch input:focus-visible ~ .md3-switch-track {
            outline: 2px solid var(--md-sys-color-primary);
            outline-offset: 2px;
        }

        /* Actions bar */
        .actions-bar {
            display: flex;
            justify-content: flex-end;
            padding: 8px 0 32px;
        }

        /* Toggle only section (no inputs above) */
        .toggle-list.no-border {
            border: none;
            margin-top: 0;
            padding-top: 0;
        }

        /* Animation */
        .section-card {
            animation: slideInUp 0.3s ease-out both;
        }

        .section-card:nth-child(2) { animation-delay: 0.05s; }
        .section-card:nth-child(3) { animation-delay: 0.1s; }

        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
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
            <div class="params-container">
                
                <div class="page-header">
                    <div style="flex: 1;">
                        <h1>Parámetros Generales</h1>
                        <p class="page-subtitle">Configura los valores predeterminados del sistema</p>
                    </div>
                    <div>
                        <c:if test="${configTipo == 'empresa' && empresaActual != null}">
                            <span class="config-badge empresa">
                                <span class="material-symbols-outlined" style="font-size: 16px;">apartment</span>
                                ${empresaActual.nombre}
                            </span>
                        </c:if>
                        <c:if test="${configTipo == 'global'}">
                            <span class="config-badge global">
                                <span class="material-symbols-outlined" style="font-size: 16px;">public</span>
                                Configuración Global
                            </span>
                        </c:if>
                    </div>
                </div>
    
                <form id="configForm" action="${pageContext.request.contextPath}/parametros/generales/guardar" method="POST">
                    
                    <!-- Cálculos y Asistencia -->
                    <div class="section-card">
                        <div class="section-header">
                            <span class="material-symbols-outlined">schedule</span>
                            <span class="section-title">Cálculos y Asistencia</span>
                        </div>
                        
                        <div class="section-body">
                            <div class="input-grid">
                                <div>
                                    <md-outlined-text-field 
                                        label="Hora de Entrada (Defecto)" 
                                        type="time"
                                        name="asistencia_hora_entrada" 
                                        value="${configs['asistencia_hora_entrada']}"
                                        style="width: 100%;">
                                        <md-icon slot="leading-icon">login</md-icon>
                                    </md-outlined-text-field>
                                </div>
                                
                                <div>
                                    <md-outlined-text-field 
                                        label="Tolerancia (Minutos)" 
                                        type="number"
                                        name="asistencia_tolerancia" 
                                        value="${configs['asistencia_tolerancia']}"
                                        min="0"
                                        supporting-text="Tiempo de gracia antes de marcar tardanza"
                                        style="width: 100%;">
                                        <md-icon slot="leading-icon">timer</md-icon>
                                    </md-outlined-text-field>
                                </div>
                            </div>
    
                            <div class="toggle-list">
                                <div class="toggle-item">
                                    <div class="toggle-info">
                                        <div class="toggle-label">Descuento por Faltas</div>
                                        <div class="toggle-desc">Aplicar descuentos automáticos por inasistencias</div>
                                    </div>
                                    <label class="md3-switch">
                                        <input type="checkbox" name="descuento_falta_enabled" value="true" ${configs['descuento_falta_enabled'] == 'true' ? 'checked' : ''}>
                                        <span class="md3-switch-track">
                                            <span class="md3-switch-thumb"></span>
                                        </span>
                                    </label>
                                </div>
    
                                <div class="toggle-item">
                                    <div class="toggle-info">
                                        <div class="toggle-label">Descuento por Tardanzas</div>
                                        <div class="toggle-desc">Aplicar descuentos por minutos de tardanza</div>
                                    </div>
                                    <label class="md3-switch">
                                        <input type="checkbox" name="descuento_tardanza_enabled" value="true" ${configs['descuento_tardanza_enabled'] == 'true' ? 'checked' : ''}>
                                        <span class="md3-switch-track">
                                            <span class="md3-switch-thumb"></span>
                                        </span>
                                    </label>
                                </div>
                                
                                <div class="toggle-item">
                                    <div class="toggle-info">
                                        <div class="toggle-label">Permitir Horas Extras</div>
                                        <div class="toggle-desc">Habilitar el cálculo y registro de horas extras</div>
                                    </div>
                                    <label class="md3-switch">
                                        <input type="checkbox" name="asistencia_permitir_extras" value="true" ${configs['asistencia_permitir_extras'] == 'true' ? 'checked' : ''}>
                                        <span class="md3-switch-track">
                                            <span class="md3-switch-thumb"></span>
                                        </span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
    
                    <!-- Sistema e Interfaz -->
                    <div class="section-card">
                        <div class="section-header">
                            <span class="material-symbols-outlined">display_settings</span>
                            <span class="section-title">Sistema e Interfaz</span>
                        </div>
                        
                        <div class="section-body">
                            <div class="toggle-list no-border">
                                <div class="toggle-item">
                                    <div class="toggle-info">
                                        <div class="toggle-label">Efecto Blur en Modales</div>
                                        <div class="toggle-desc">Mejora visual al abrir ventanas emergentes con fondo difuminado</div>
                                    </div>
                                    <label class="md3-switch">
                                        <input type="checkbox" name="ui_blur_modal" value="true" ${configs['ui_blur_modal'] == 'true' ? 'checked' : ''}>
                                        <span class="md3-switch-track">
                                            <span class="md3-switch-thumb"></span>
                                        </span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
    
                    <div class="actions-bar">
                        <md-filled-button type="submit">
                            <md-icon slot="icon">save</md-icon>
                            Guardar Cambios
                        </md-filled-button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Toast Mount Point -->
    <div id="toast-mount-point" style="display:none;"></div>

    <!-- Scripts -->
    <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             // Show toast from server params if exists
            <c:if test="${not empty mensaje}">
                const type = "${tipoMensaje}" === 'error' ? 'error' : 'success';
                const icon = type === 'success' ? 'check_circle' : 'error';
                const title = type === 'success' ? 'Éxito' : 'Error';
                
                if (typeof showToast === 'function') {
                     showToast(title, "${mensaje}", type, icon);
                }
            </c:if>
        });
    </script>
</body>
</html>
