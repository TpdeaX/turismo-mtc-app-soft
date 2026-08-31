<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${not empty empleado.id && empleado.id != 0 ? 'Editar' : 'Nuevo'} Empleado</title>

<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
<script type="module">import '@material/web/all.js';</script>

<style>
    /* 2. ARREGLO DEL MENÚ DESORDENADO */
    body {
        font-family: 'Roboto', sans-serif;
        background-color: #F4FBF9;
        margin: 0;
        padding: 0;
        display: block !important; /* Vital para que el sidebar no flote raro */
    }

    /* Empujamos el contenido a la derecha para respetar tu Sidebar fijo */
    .content-wrapper {
        margin-left: 260px; /* Espacio exacto para tu menú lateral */
        padding: 40px;
        min-height: 100vh;
        width: calc(100% - 260px); /* El ancho restante exacto */
    }

    .main-card {
        background: white;
        padding: 40px;
        border-radius: 16px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
        max-width: 800px;
        margin: 0 auto; /* Centrado horizontalmente en su zona */
    }

    /* Ajustes visuales */
    h2 { color: #006A6A; text-align: center; margin-bottom: 30px; }
    .form-group { margin-bottom: 20px; }
    
    /* Iconos siempre visibles */
    .material-symbols-rounded { 
        font-family: 'Material Symbols Rounded'; 
        font-weight: normal; 
        font-style: normal; 
        line-height: 1; 
        letter-spacing: normal; 
        text-transform: none; 
        display: inline-block; 
        white-space: nowrap; 
        word-wrap: normal; 
        direction: ltr; 
    }
    
    md-outlined-text-field, md-outlined-select { width: 100%; }
</style>
</head>
<body>

    <jsp:include page="../shared/sidebar.jsp" />
    
    <div class="content-wrapper">
        <div class="main-card">
            <h2>${not empty empleado.id && empleado.id != 0 ? 'Editar' : 'Nuevo'} Empleado</h2>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger d-flex align-items-center mb-4">
                    <span class="material-symbols-rounded me-2">error</span>
                    <div>${error}</div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/empleados" method="post" id="formEmpleado" onsubmit="prepararEnvio()">
                <input type="hidden" name="accion" value="guardar"> 
                <input type="hidden" name="id" value="${empleado.id}">

                <div class="row">
                    <div class="col-md-6 form-group">
                        <md-outlined-text-field label="Nombres" id="txtNombres"
                            value="${empleado.nombres}" required></md-outlined-text-field>
                        <input type="hidden" name="nombres" id="hiddenNombres">
                    </div>
                    <div class="col-md-6 form-group">
                        <md-outlined-text-field label="Apellidos" id="txtApellidos"
                            value="${empleado.apellidos}" required></md-outlined-text-field>
                        <input type="hidden" name="apellidos" id="hiddenApellidos">
                    </div>
                </div>

                <div class="form-group">
                    <div style="display: flex; gap: 10px; align-items: flex-end;">
                        <div style="flex-grow: 1;">
                            <md-outlined-text-field label="DNI" id="txtDni"
                                value="${empleado.dni}" type="number" maxlength="8" required></md-outlined-text-field>
                            <input type="hidden" name="dni" id="hiddenDni">
                        </div>
                        <md-filled-tonal-button type="button" style="height: 56px; margin-bottom: 4px;">
                            Consultar <md-icon slot="icon">search</md-icon> 
                        </md-filled-tonal-button>
                    </div>
                </div>

                <div class="form-group">
                    <md-outlined-text-field label="Sueldo Base (S/.)" id="txtSueldo"
                        value="${empleado.sueldoBase}" type="number" step="0.01"></md-outlined-text-field>
                    <input type="hidden" name="sueldoBase" id="hiddenSueldo">
                </div>

                <div class="row">
                    <div class="col-md-6 form-group">
                        <md-outlined-select label="Rol del usuario" id="rolSelect"> 
                            <md-select-option value="EMPLEADO" ${empleado.rol == 'EMPLEADO' ? 'selected' : ''}>
                                <div slot="headline">EMPLEADO ESTÁNDAR</div>
                            </md-select-option> 
                            <md-select-option value="ADMIN" ${empleado.rol == 'ADMIN' ? 'selected' : ''}>
                                <div slot="headline">ADMINISTRADOR TOTAL</div>
                            </md-select-option> 
                            <md-select-option value="PERSONALIZADO" ${empleado.rol == 'PERSONALIZADO' ? 'selected' : ''}>
                                <div slot="headline">PERSONALIZADO</div>
                            </md-select-option> 
                        </md-outlined-select>
                        <input type="hidden" name="rol" id="hiddenRol">
                    </div>

                    <div class="col-md-6 form-group">
                        <md-outlined-select label="Modalidad" id="modalidadSelect">
                            <md-select-option value="OBLIGADO" ${empleado.tipoModalidad == 'OBLIGADO' ? 'selected' : ''}>
                                <div slot="headline">OBLIGADO (Rotativo)</div>
                            </md-select-option> 
                            <md-select-option value="FIJO" ${empleado.tipoModalidad == 'FIJO' ? 'selected' : ''}>
                                <div slot="headline">FIJO (Lunes a Viernes)</div>
                            </md-select-option> 
                            <md-select-option value="LIBRE" ${empleado.tipoModalidad == 'LIBRE' ? 'selected' : ''}>
                                <div slot="headline">LIBRE</div>
                            </md-select-option> 
                        </md-outlined-select>
                        <input type="hidden" name="tipoModalidad" id="hiddenModalidad">
                    </div>
                </div>

                <div class="form-group">
                    <md-outlined-select label="Sucursal Asignada" id="sucursalSelect" required> 
                        <md-select-option value="" disabled selected>
                            <div slot="headline">-- Seleccione Sucursal --</div>
                        </md-select-option> 
                        <c:forEach var="sucursal" items="${listaSucursales}">
                            <md-select-option value="${sucursal.id}"
                                ${empleado.sucursal != null && empleado.sucursal.id == sucursal.id ? 'selected' : ''}>
                                <div slot="headline">${sucursal.nombre}</div>
                            </md-select-option>
                        </c:forEach> 
                    </md-outlined-select>
                    <input type="hidden" name="sucursal.id" id="hiddenSucursal">
                </div>

                <div id="permisosContainer" style="display: none;">
                    <div class="card mt-3 border-0" style="background-color: #f8f9fa;">
                        <div class="card-body">
                            <h6 class="text-primary mb-3">Accesos Especiales</h6>
                            <div class="row">
                                <c:forEach items="${listaTodosPermisos}" var="p">
                                    <div class="col-md-6 mb-2">
                                        <div class="form-check custom-checkbox p-2 border rounded bg-white">
                                            <input class="form-check-input ms-1" type="checkbox"
                                                name="permisosSeleccionados" 
                                                value="${p.nombre}"
                                                id="permiso_${p.id}" 
                                                ${permisosActuales != null && permisosActuales.contains(p.nombre) ? 'checked' : ''}>
                                            <label class="form-check-label ms-2" for="permiso_${p.id}">
                                                ${fn:replace(p.nombre, '_', ' ')}
                                            </label>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>

                <c:if test="${empty empleado.id || empleado.id == 0}">
                    <div class="form-group mt-3">
                        <md-outlined-text-field label="Contraseña" id="txtPassword"
                            type="password" required></md-outlined-text-field>
                        <input type="hidden" name="password" id="hiddenPassword">
                    </div>
                </c:if>

                <div class="buttons">
                    <md-text-button type="button" onclick="window.location.href='${pageContext.request.contextPath}/empleados'">Cancelar</md-text-button>
                    <md-filled-button type="submit">Guardar Datos</md-filled-button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Función que se ejecuta justo antes de enviar
        function prepararEnvio() {
            document.getElementById('hiddenNombres').value = document.getElementById('txtNombres').value;
            document.getElementById('hiddenApellidos').value = document.getElementById('txtApellidos').value;
            document.getElementById('hiddenDni').value = document.getElementById('txtDni').value;
            document.getElementById('hiddenSueldo').value = document.getElementById('txtSueldo').value;
            
            // Dropdowns
            document.getElementById('hiddenRol').value = document.getElementById('rolSelect').value;
            document.getElementById('hiddenModalidad').value = document.getElementById('modalidadSelect').value;
            document.getElementById('hiddenSucursal').value = document.getElementById('sucursalSelect').value;

            // Password (solo si existe el campo)
            const passField = document.getElementById('txtPassword');
            if(passField) {
                document.getElementById('hiddenPassword').value = passField.value;
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            const rolSelect = document.getElementById('rolSelect');
            const permisosContainer = document.getElementById('permisosContainer');

            function togglePermisos() {
                if(rolSelect.value === 'PERSONALIZADO'){
                    permisosContainer.style.display = 'block';
                } else {
                    permisosContainer.style.display = 'none';
                }
            }

            rolSelect.addEventListener('change', togglePermisos);
            // Pequeño delay para asegurar que el componente cargó
            setTimeout(togglePermisos, 500);
        });
    </script>
</body>
</html>
