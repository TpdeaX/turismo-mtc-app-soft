<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${modoEdicion ? 'Editar' : 'Nueva'} Empresa - Sistema de Asistencia</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,1,0" />
    
    <script type="importmap">
        { "imports": { "@material/web/": "https://esm.run/@material/web/" } }
    </script>
    <script type="module">
        import '@material/web/all.js';
    </script>

    <style>
        :root {
            --color-primary: #6750A4;
            --color-surface: #FFFFFF;
            --color-on-surface: #1C1B1F;
            --color-surface-variant: #E7E0EC;
            --shadow-sm: rgba(0,0,0,0.08);
        }
        
        body {
            font-family: 'Outfit', sans-serif;
            margin: 0;
            padding: 0;
            background: #F8F9FA;
        }
        
        .page-content {
            padding: 24px;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .page-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
        }
        
        .back-btn {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            cursor: pointer;
            border: none;
            background: transparent;
            color: var(--color-on-surface);
            transition: background 0.2s;
        }
        
        .back-btn:hover {
            background: var(--color-surface-variant);
        }
        
        .page-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--color-on-surface);
            margin: 0;
        }
        
        .form-card {
            background: var(--color-surface);
            border-radius: 16px;
            box-shadow: 0 2px 8px var(--shadow-sm);
            padding: 32px;
        }
        
        .form-section {
            margin-bottom: 32px;
        }
        
        .form-section-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--color-primary);
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-row.single {
            grid-template-columns: 1fr;
        }
        
        md-outlined-text-field {
            width: 100%;
        }
        
        .color-picker-group {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        
        .color-picker-wrapper {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex: 1;
        }
        
        .color-picker-wrapper label {
            font-size: 0.85rem;
            color: #666;
        }
        
        .color-input-container {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        input[type="color"] {
            width: 48px;
            height: 48px;
            border: 2px solid var(--color-surface-variant);
            border-radius: 12px;
            cursor: pointer;
            padding: 2px;
        }
        
        .color-value {
            font-family: monospace;
            font-size: 0.9rem;
            color: #666;
        }
        
        .preview-section {
            background: linear-gradient(135deg, var(--preview-primary, #EC407A) 0%, var(--preview-secondary, #BA68C8) 100%);
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            color: white;
            margin-top: 16px;
        }
        
        .preview-logo {
            max-height: 60px;
            max-width: 200px;
            object-fit: contain;
            margin-bottom: 12px;
        }
        
        .preview-name {
            font-size: 1.25rem;
            font-weight: 600;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding-top: 24px;
            border-top: 1px solid var(--color-surface-variant);
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 28px;
            border: none;
            border-radius: 24px;
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        
        .btn-secondary {
            background: transparent;
            color: var(--color-primary);
            border: 1px solid var(--color-primary);
        }
        
        .btn-secondary:hover {
            background: rgba(103, 80, 164, 0.1);
        }
        
        .btn-primary {
            background: var(--color-primary);
            color: white;
        }
        
        .btn-primary:hover {
            filter: brightness(1.1);
            box-shadow: 0 4px 12px rgba(103, 80, 164, 0.4);
        }
        
        .checkbox-wrapper {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 16px;
        }
        
        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/sidebar.jsp" />
    
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="page-content">
            <div class="page-header">
                <a href="${pageContext.request.contextPath}/empresas" class="back-btn" title="Volver">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <h1 class="page-title">${modoEdicion ? 'Editar Empresa' : 'Nueva Empresa'}</h1>
            </div>
            
            <form action="${pageContext.request.contextPath}/empresas/guardar" method="post" class="form-card">
                <c:if test="${modoEdicion}">
                    <input type="hidden" name="id" value="${empresa.id}">
                </c:if>
                
                <div class="form-section">
                    <h3 class="form-section-title">
                        <span class="material-symbols-outlined">business</span>
                        Información General
                    </h3>
                    
                    <div class="form-row">
                        <md-outlined-text-field 
                            label="Código" 
                            name="codigo" 
                            value="${empresa.codigo}"
                            required
                            maxlength="20"
                            placeholder="Ej: PERUANA, ROMA">
                        </md-outlined-text-field>
                        
                        <md-outlined-text-field 
                            label="Nombre" 
                            name="nombre" 
                            value="${empresa.nombre}"
                            required
                            maxlength="100"
                            placeholder="Ej: La Peruana">
                        </md-outlined-text-field>
                    </div>
                </div>
                
                <div class="form-section">
                    <h3 class="form-section-title">
                        <span class="material-symbols-outlined">palette</span>
                        Colores de Marca
                    </h3>
                    
                    <div class="color-picker-group">
                        <div class="color-picker-wrapper">
                            <label>Color Primario</label>
                            <div class="color-input-container">
                                <input type="color" 
                                       id="colorPrimario" 
                                       name="colorPrimario" 
                                       value="${not empty empresa.colorPrimario ? empresa.colorPrimario : '#EC407A'}"
                                       onchange="updatePreview()">
                                <span class="color-value" id="primaryValue">${not empty empresa.colorPrimario ? empresa.colorPrimario : '#EC407A'}</span>
                            </div>
                        </div>
                        
                        <div class="color-picker-wrapper">
                            <label>Color Secundario</label>
                            <div class="color-input-container">
                                <input type="color" 
                                       id="colorSecundario" 
                                       name="colorSecundario" 
                                       value="${not empty empresa.colorSecundario ? empresa.colorSecundario : '#BA68C8'}"
                                       onchange="updatePreview()">
                                <span class="color-value" id="secondaryValue">${not empty empresa.colorSecundario ? empresa.colorSecundario : '#BA68C8'}</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="preview-section" id="colorPreview">
                        <c:if test="${not empty empresa.logoPath}">
                            <img src="${pageContext.request.contextPath}/assets/${empresa.logoPath}" 
                                 alt="Logo" 
                                 class="preview-logo"
                                 id="previewLogo">
                        </c:if>
                        <div class="preview-name" id="previewName">${not empty empresa.nombre ? empresa.nombre : 'Vista Previa'}</div>
                    </div>
                </div>
                
                <div class="form-section">
                    <h3 class="form-section-title">
                        <span class="material-symbols-outlined">image</span>
                        Archivos de Logo
                    </h3>
                    
                    <div class="form-row">
                        <md-outlined-text-field 
                            label="Logo completo (claro)" 
                            name="logoPath" 
                            value="${empresa.logoPath}"
                            placeholder="Ej: logo-peruana.png">
                            <md-icon slot="leading-icon">photo</md-icon>
                        </md-outlined-text-field>
                        
                        <md-outlined-text-field 
                            label="Logo completo (oscuro)" 
                            name="logoDarkPath" 
                            value="${empresa.logoDarkPath}"
                            placeholder="Ej: logo-peruana-dm.png">
                            <md-icon slot="leading-icon">dark_mode</md-icon>
                        </md-outlined-text-field>
                    </div>

                    <div class="form-row">
                        <md-outlined-text-field 
                            label="Icono (claro)" 
                            name="iconPath" 
                            value="${empresa.iconPath}"
                            placeholder="Ej: logo-peruana-icon.png">
                            <md-icon slot="leading-icon">crop_square</md-icon>
                        </md-outlined-text-field>

                        <md-outlined-text-field 
                            label="Icono (oscuro)" 
                            name="iconDarkPath" 
                            value="${empresa.iconDarkPath}"
                            placeholder="Ej: logo-peruana-icon-dm.png">
                            <md-icon slot="leading-icon">nightlight</md-icon>
                        </md-outlined-text-field>
                    </div>

                    <div class="checkbox-wrapper">
                        <md-checkbox id="usarMismoLogoOscuro"
                                     name="usarMismoLogoOscuro"
                                     ${empresa.usarMismoLogoOscuro ? 'checked' : ''}>
                        </md-checkbox>
                        <label for="usarMismoLogoOscuro">Usar logo claro también para modo oscuro</label>
                    </div>

                    <div class="checkbox-wrapper">
                        <md-checkbox id="usarMismoIconoOscuro"
                                     name="usarMismoIconoOscuro"
                                     ${empresa.usarMismoIconoOscuro ? 'checked' : ''}>
                        </md-checkbox>
                        <label for="usarMismoIconoOscuro">Usar icono claro también para modo oscuro</label>
                    </div>
                    
                    <p style="font-size: 0.85rem; color: #666; margin-top: 8px;">
                        <span class="material-symbols-outlined" style="font-size: 16px; vertical-align: middle;">info</span>
                        El logo se usa en sidebar, login y pantalla de carga. Los archivos deben estar en <code>/assets/</code>.
                    </p>
                </div>
                
                <div class="checkbox-wrapper">
                    <md-checkbox 
                        id="esPrincipal" 
                        name="esPrincipal"
                        ${empresa.esPrincipal ? 'checked' : ''}>
                    </md-checkbox>
                    <label for="esPrincipal">Marcar como empresa principal (usado como fallback para UI)</label>
                </div>
                
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/empresas" class="btn btn-secondary">Cancelar</a>
                    <button type="submit" class="btn btn-primary">
                        <span class="material-symbols-outlined">save</span>
                        ${modoEdicion ? 'Guardar Cambios' : 'Crear Empresa'}
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function updatePreview() {
            const primary = document.getElementById('colorPrimario').value;
            const secondary = document.getElementById('colorSecundario').value;
            const preview = document.getElementById('colorPreview');
            
            preview.style.background = `linear-gradient(135deg, ${primary} 0%, ${secondary} 100%)`;
            
            document.getElementById('primaryValue').textContent = primary;
            document.getElementById('secondaryValue').textContent = secondary;
        }
        
        // Initialize preview on load
        document.addEventListener('DOMContentLoaded', updatePreview);
        
        // Update preview name when typing
        document.querySelector('md-outlined-text-field[name="nombre"]').addEventListener('input', function(e) {
            const value = e.target.value || 'Vista Previa';
            document.getElementById('previewName').textContent = value;
        });
    </script>
</body>
</html>
