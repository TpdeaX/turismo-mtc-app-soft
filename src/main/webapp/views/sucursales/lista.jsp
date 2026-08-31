<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Sucursales</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <!-- Leaflet -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    
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
        /* Shared Styles */
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

        /* Form Styles inside Modal */
        .modal-form-grid { 
            display: grid; 
            grid-template-columns: 1fr; 
            gap: 16px; 
            margin-top: 8px;
            max-height: 60vh;
            overflow-y: auto;
            padding-right: 4px;
        }
        
        md-outlined-text-field { width: 100%; }

        /* Animations */
        @keyframes fade-in-down {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slide-in-up {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        tbody tr {
            animation: slide-in-up 0.4s ease-out forwards;
        }
        
        tbody tr:nth-child(1) { animation-delay: 0.05s; }
        tbody tr:nth-child(2) { animation-delay: 0.1s; }
        tbody tr:nth-child(3) { animation-delay: 0.15s; }
        tbody tr:nth-child(4) { animation-delay: 0.2s; }
        tbody tr:nth-child(5) { animation-delay: 0.25s; }
        
        #map { height: 300px; width: 100%; border-radius: 4px; margin-top: 8px; z-index: 0; }
        /* Fix Leaflet in Modal */
        .leaflet-container { font-family: 'Roboto', sans-serif; }
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
            <div class="page-header" style="gap: 16px; flex-wrap: wrap;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Lista de Sucursales</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Administra las sedes de la empresa</p>
                </div>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <md-filled-button onclick="abrirModalNuevo()">
                        <md-icon slot="icon">add_business</md-icon>
                        Nueva Sucursal
                    </md-filled-button>
                </div>
            </div>

            <!-- Filter Form -->
            <div class="card" style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface); animation: fade-in-down 0.5s ease-out;">
                <form id="filterForm" action="${pageContext.request.contextPath}/sucursales/filter" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina != null ? pagina.number : 0}">
                    
                    <div style="display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; align-items: center;">
                        
                        <!-- Search -->
                        <div style="grid-column: span 3;">
                            <md-outlined-text-field 
                                label="Buscar" 
                                name="keyword" 
                                value="${keyword}"
                                placeholder="Nombre, Dirección..." 
                                style="width: 100%;"
                                onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                                <md-icon slot="leading-icon">search</md-icon>
                            </md-outlined-text-field>
                        </div>

                        <!-- Company Filter -->
                        <div style="grid-column: span 2;">
                            <md-outlined-select label="Empresa" name="empresaId" id="filterEmpresa" style="width: 100%;">
                                <md-select-option value="" selected><div slot="headline">Todas</div></md-select-option>
                                <c:forEach items="${empresas}" var="emp">
                                    <md-select-option value="${emp.id}" ${empresaId == emp.id ? 'selected' : ''}>
                                        <div slot="headline">${emp.nombre}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Botones de Acción -->
                        <div style="grid-column: span 1; display: flex; gap: 8px; justify-content: flex-end;">
                             <md-icon-button type="button" onclick="limpiarFiltros()" title="Limpiar">
                                <md-icon>delete_sweep</md-icon>
                            </md-icon-button>
                            <md-filled-button type="button" onclick="submitFilter()">
                                <md-icon slot="icon">filter_list</md-icon>
                                Filtrar
                            </md-filled-button>
                        </div>
                    </div>
                    <input type="hidden" name="size" id="sizeInput" value="${size != null ? size : 5}">
                </form>
            </div>

            <!-- Table Card -->
            <div class="card" style="animation: fade-in-down 0.6s ease-out;">
                <div class="table-container">
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Nombre</th>
                                <th>Empresa</th>
                                <th>Dirección</th>
                                <th style="width: 150px;">Teléfono</th>
                                <th style="width: 120px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty sucursales}">
                                    <c:forEach var="s" items="${sucursales}">
                                        <tr>
                                            <td>${s.id}</td>
                                            <td>
                                                <div style="font-weight: 500;">${s.nombre}</div>
                                            </td>
                                            <td>
                                                <c:if test="${s.empresa != null}">
                                                    <span style="background: var(--md-sys-color-secondary-container); padding: 4px 8px; border-radius: 12px; font-size: 0.85rem;">${s.empresa.nombre}</span>
                                                </c:if>
                                            </td>
                                            <td>${s.direccion}</td>
                                            <td style="font-family: monospace;">${s.telefono}</td>
                                            <td>
                                                <div class="actions-cell">
                                                    <md-icon-button title="Editar"
                                                        onclick="abrirModalEditar(this)"
                                                        data-id="${s.id}"
                                                        data-nombre="${s.nombre}"
                                                        data-direccion="${s.direccion}"
                                                        data-telefono="${s.telefono}"
                                                        data-lat="${s.latitud}"
                                                        data-lng="${s.longitud}"
                                                        data-tolerancia="${s.toleranciaMetros}"
                                                        data-empresa-id="${s.empresa != null ? s.empresa.id : ''}">
                                                        <md-icon>edit</md-icon>
                                                    </md-icon-button>
                                                    
                                                    <md-icon-button title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);"
                                                        onclick="abrirModalEliminar('${s.id}')">
                                                        <md-icon>delete</md-icon>
                                                    </md-icon-button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                                            No hay sucursales registradas.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                
                 <!-- Pagination logic (Conditional if backend supports 'pagina' object) -->
                 <c:if test="${pagina != null}">
                     <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                        <div style="display: flex; align-items: center; gap: 24px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas por página:</span>
                                <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                    <md-select-option value="5" ${size == 5 ? 'selected' : ''}><div slot="headline">5</div></md-select-option>
                                    <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                                    <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
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

        <!-- MODAL: Nueva / Editar Sucursal -->
        <md-dialog id="modal-sucursal" style="min-width: 400px; max-width: 600px;">
            <md-icon slot="icon">store</md-icon>
            <div slot="headline" id="modal-title">Nueva Sucursal</div>
            
            <form slot="content" id="form-sucursal" method="post" action="${pageContext.request.contextPath}/sucursales/guardar">
                <input type="hidden" name="id" id="sucursal-id" value="">
                <input type="hidden" name="latitud" id="sucursal-lat">
                <input type="hidden" name="longitud" id="sucursal-lng">

                <div class="modal-form-grid">
                    <!-- Selector de empresa (solo si hay más de una) -->
                    <c:if test="${empresas != null && empresas.size() > 1}">
                        <div>
                            <label style="display: block; margin-bottom: 8px; font-family: 'Roboto', sans-serif; font-size: 0.875rem; color: var(--md-sys-color-on-surface-variant);">Empresa</label>
                            <select name="empresaId" id="input-empresa" style="width: 100%; padding: 12px; border: 1px solid var(--md-sys-color-outline); border-radius: 8px; font-size: 14px; background: var(--md-sys-color-surface);">
                                <c:forEach items="${empresas}" var="emp">
                                    <option value="${emp.id}">${emp.nombre}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>
                    <c:if test="${empresas != null && empresas.size() == 1}">
                        <input type="hidden" name="empresaId" id="input-empresa" value="${empresas[0].id}">
                    </c:if>
                    
                    <md-outlined-text-field label="Nombre" name="nombre" id="input-nombre" required></md-outlined-text-field>
                    <md-outlined-text-field label="Dirección" name="direccion" id="input-direccion"></md-outlined-text-field>
                    <md-outlined-text-field label="Teléfono" name="telefono" id="input-telefono" type="tel"></md-outlined-text-field>
                    <md-outlined-text-field label="Tolerancia (metros)" name="toleranciaMetros" id="input-tolerancia" type="number" value="100" min="1"></md-outlined-text-field>
                    
                    <div>
                         <label style="display: block; margin-bottom: 8px; font-family: 'Roboto', sans-serif; font-size: 0.875rem; color: var(--md-sys-color-on-surface-variant);">Ubicación</label>
                         <div id="map"></div>
                         <div style="font-size: 0.75rem; color: var(--md-sys-color-on-surface-variant); margin-top: 4px;">Haga clic en el mapa para seleccionar la ubicación.</div>
                    </div>
                </div>
            </form>

            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-sucursal').close()">Cancelar</md-text-button>
                <md-filled-button onclick="submitFormSucursal()">Guardar</md-filled-button>
            </div>
        </md-dialog>

        <!-- MODAL: Eliminar -->
        <md-dialog id="modal-eliminar" style="max-width: 400px;">
            <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
            <div slot="headline">¿Eliminar Sucursal?</div>
            <div slot="content">Esta acción no se puede deshacer.</div>
            
            <form id="form-eliminar" method="post" action="${pageContext.request.contextPath}/sucursales/eliminar">
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
            const modalSucursal = document.getElementById('modal-sucursal');
            const formSucursal = document.getElementById('form-sucursal');
            let map, marker;
            
            function initMap() {
                if (map) return; // Initialize only once or reset handled in show
                
                // Default to Lima
                const defaultLat = -12.046374;
                const defaultLng = -77.042793;
                
                map = L.map('map').setView([defaultLat, defaultLng], 13);

                // Google Maps Layer
                L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
                    maxZoom: 20,
                    subdomains:['mt0','mt1','mt2','mt3']
                }).addTo(map);

                map.on('click', function(e) {
                    updateMarker(e.latlng.lat, e.latlng.lng);
                    obtenerDireccion(e.latlng.lat, e.latlng.lng);
                });
            }

            function updateMarker(lat, lng) {
                if (marker) {
                    marker.setLatLng([lat, lng]);
                } else {
                    marker = L.marker([lat, lng]).addTo(map);
                }
                document.getElementById('sucursal-lat').value = lat;
                document.getElementById('sucursal-lng').value = lng;
            }

            function obtenerDireccion(lat, lng) {
                const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=\${lat}&lon=\${lng}`;
                
                document.getElementById('input-direccion').parentElement.classList.add('loading'); // Optional visual cue
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        if (data && data.address) {
                            // Construct a cleaner address
                            const road = data.address.road || '';
                            const houseNumber = data.address.house_number || '';
                            const city = data.address.city || data.address.town || data.address.village || '';
                            const district = data.address.suburb || data.address.neighbourhood || '';
                            
                            let fullAddress = road;
                            if (houseNumber) fullAddress += ' ' + houseNumber;
                            if (district) fullAddress += ', ' + district;
                            if (city) fullAddress += ', ' + city;
                            
                            // Fallback if construction fails but display_name exists
                            if (!fullAddress.trim() && data.display_name) {
                                fullAddress = data.display_name;
                            }

                            document.getElementById('input-direccion').value = fullAddress;
                        }
                    })
                    .catch(bs => console.error("Error geocoding:", bs));
            }
            
            function abrirModalNuevo() {
                document.getElementById('modal-title').innerText = "Nueva Sucursal";
                document.querySelector('#modal-sucursal md-icon[slot="icon"]').innerText = "add_business";
                document.getElementById('sucursal-id').value = "0";
                formSucursal.reset();
                
                // Reset hidden inputs
                document.getElementById('sucursal-lat').value = "";
                document.getElementById('sucursal-lat').value = "";
                document.getElementById('sucursal-lng').value = "";
                document.getElementById('input-tolerancia').value = "100";
                
                modalSucursal.show();
                
                // Fix map rendering issues in modal
                setTimeout(() => {
                    if (!map) initMap();
                    map.invalidateSize();
                    
                    // Reset map to default view and remove marker
                    if (marker) {
                        map.removeLayer(marker);
                        marker = null;
                    }
                    
                    // Try to get current location
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(
                            (position) => {
                                const lat = position.coords.latitude;
                                const lng = position.coords.longitude;
                                map.setView([lat, lng], 15);
                                // Optional: Automatically set marker at current location?
                                // Let's just center it for now as per "para no ir hasta mi ciudad para recien ver donde es"
                            }, 
                            (error) => {
                                console.warn("Geolocation denied or error:", error);
                                map.setView([-12.046374, -77.042793], 13); // Fallback to Lima
                            }
                        );
                    } else {
                        map.setView([-12.046374, -77.042793], 13);
                    }
                }, 200);
            }

            function abrirModalEditar(btn) {
                const data = btn.dataset;
                document.getElementById('modal-title').innerText = "Editar Sucursal";
                document.querySelector('#modal-sucursal md-icon[slot="icon"]').innerText = "edit";
                document.getElementById('sucursal-id').value = data.id;
                
                document.getElementById('input-nombre').value = data.nombre;
                document.getElementById('input-direccion').value = data.direccion;
                document.getElementById('input-direccion').value = data.direccion;
                document.getElementById('input-telefono').value = data.telefono;
                document.getElementById('input-tolerancia').value = data.tolerancia || "100";
                
                // Seleccionar empresa
                const empresaSelect = document.getElementById('input-empresa');
                if (empresaSelect && data.empresaId) {
                    empresaSelect.value = data.empresaId;
                }
                
                // Set hidden inputs
                document.getElementById('sucursal-lat').value = data.lat || "";
                document.getElementById('sucursal-lng').value = data.lng || "";

                modalSucursal.show();
                
                setTimeout(() => {
                   if (!map) initMap();
                   map.invalidateSize();
                   
                   if (data.lat && data.lng) {
                       const lat = parseFloat(data.lat);
                       const lng = parseFloat(data.lng);
                       updateMarker(lat, lng);
                       map.setView([lat, lng], 15);
                   } else {
                       // If no location saved, reset view
                       if (marker) {
                           map.removeLayer(marker);
                           marker = null;
                       }
                       map.setView([-12.046374, -77.042793], 13);
                   }
                }, 200);
            }

            function abrirModalEliminar(id) {
                document.getElementById('id-eliminar').value = id;
                document.getElementById('modal-eliminar').show();
            }
            
            function submitFormSucursal() {
                const nombre = document.getElementById('input-nombre');
                if(!nombre.value.trim()) {
                    nombre.error = true;
                    return;
                }
                formSucursal.submit();
            }

            // --- Filter Logic ---
            function submitFilter() {
                document.getElementById('pageInput').value = 0; 
                document.getElementById('filterForm').submit();
            }

            function limpiarFiltros() {
                const search = document.querySelector('md-outlined-text-field[name="keyword"]');
                if(search) search.value = '';
                
                const filterEmpresa = document.getElementById('filterEmpresa');
                if(filterEmpresa) filterEmpresa.selectIndex(0); // Reset to first option (Todas)
                
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

            // --- Initialization ---
            document.addEventListener('DOMContentLoaded', () => {
                // If using utils.js for fixing dialog scrims
                if (typeof fixDialogScrim === 'function') {
                    fixDialogScrim(['modal-sucursal', 'modal-eliminar']);
                }
                handleParams();
            });

            function handleParams() {
                const params = new URLSearchParams(window.location.search);
                const status = params.get('status');
                
                if (status) {
                    let title, message, type, icon;
                    
                    switch(status) {
                        case 'created':
                        case 'success': // Fallback
                            title = 'Operación Exitosa';
                            message = 'La sucursal ha sido registrada correctamente.';
                            type = 'success';
                            icon = 'check_circle';
                            break;
                        case 'updated':
                            title = 'Sucursal Actualizada';
                            message = 'Los datos han sido guardados.';
                            type = 'success';
                            icon = 'save';
                            break;
                        case 'deleted':
                            title = 'Sucursal Eliminada';
                            message = 'El registro ha sido eliminado del sistema.';
                            type = 'success';
                            icon = 'delete';
                            break;
                        case 'error':
                            title = 'Error';
                            message = 'Ocurrió un error al procesar la solicitud.';
                            type = 'error';
                            icon = 'error';
                            break;
                    }

                    if (title && typeof showToast === 'function') {
                        showToast(title, message, type, icon);
                    }
                    
                    // Clean URL
                    window.history.replaceState({}, document.title, window.location.pathname);
                }
            }
        </script>
        
        <!-- Shared Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    </div>
</body>
</html>
