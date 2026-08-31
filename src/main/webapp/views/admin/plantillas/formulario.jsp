<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
 <!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">	
    <title>${plantilla.id != 0 ? 'Editar' : 'Nueva'} Plantilla Semanal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    
    <style>
        .day-row { background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px; border: 1px solid #dee2e6; }
        .day-label { font-weight: bold; font-size: 1.1em; color: #495057; }
        
        /* Ajuste consistente con el otro formulario */
        .main-content { margin-left: 260px; padding: 20px; } 
    </style>
</head>
<body>
    
    <jsp:include page="/views/shared/sidebar.jsp" />
    
    <div class="main-content">
        <jsp:include page="/views/shared/header.jsp" />
    
        <div class="container mt-4 mb-5">
            <div class="card shadow border-0"> 
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">${plantilla.id != 0 ? 'Editar' : 'Nueva'} Plantilla Semanal</h4>
                    <div>
                         <button type="button" class="btn btn-light btn-sm" onclick="copiarLunes()">
                            <i class="bi bi-files"></i> Copiar Lunes a Todo
                         </button>
                         <button type="button" class="btn btn-outline-light btn-sm" onclick="limpiarTodo()">
                            <i class="bi bi-trash"></i> Limpiar
                         </button>
                    </div>
                </div>
                
                <div class="card-body p-4">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger d-flex align-items-center">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/plantillas/guardar" method="post" id="templateForm">
                        <input type="hidden" name="id" value="${plantilla.id}">
                        
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="nombre" class="form-label fw-bold">Nombre de la Plantilla <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="nombre" name="nombre" 
                                       placeholder="Ej: Horario Oficina Completo"
                                       value="${plantilla.nombre}" required>
                            </div>

                            <div class="col-md-6">
                                <label for="sucursal" class="form-label fw-bold">Sucursal Asignada <span class="text-danger">*</span></label>
                                <select name="sucursal.id" id="sucursal" class="form-select" required>
                                    <option value="" disabled selected>-- Seleccione Sucursal --</option>
                                    <c:forEach items="${listaSucursales}" var="s">
                                        <option value="${s.id}" ${plantilla.sucursal.id == s.id ? 'selected' : ''}>
                                            ${s.nombre}
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="form-text text-muted">Selecciona la sucursal donde aplica esta plantilla.</div>
                            </div>
                        </div>

                        <hr class="mb-4">

                        <div class="d-grid gap-3">
                           <% 
                              String[] diasArray = {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"};
                              pageContext.setAttribute("dias", diasArray);
                           %>
                            
                            <c:forEach begin="0" end="6" var="i">
                                <c:set var="detalle" value="${null}" />
                                <c:if test="${plantilla != null}">
                                    <c:forEach items="${plantilla.detalles}" var="d">
                                        <c:if test="${d.diaSemana == (i + 1)}">
                                            <c:set var="detalle" value="${d}" />
                                        </c:if>
                                    </c:forEach>
                                </c:if>

                                <div class="day-row" id="day-${i}">
                                    <input type="hidden" name="detalles[${i}].diaSemana" value="${i + 1}">
                                    
                                    <div class="row align-items-center">
                                        <div class="col-md-2">
                                            <div class="day-label">${dias[i]}</div>
                                            <div class="form-check mt-1">
                                                <input class="form-check-input" type="checkbox" id="checkDescanso-${i}" 
                                                       ${(detalle == null || detalle.esDescanso) ? 'checked' : ''} 
                                                       onchange="toggleDia(${i})">
                                                <label class="form-check-label small text-muted" for="checkDescanso-${i}">Descanso</label>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-3">
                                            <label class="form-label small">Inicio</label>
                                            <input type="time" class="form-control inputs-dia-${i}" 
                                                   name="detalles[${i}].horaInicio" 
                                                   value="${detalle != null ? detalle.horaInicio : ''}">
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small">Fin</label>
                                            <input type="time" class="form-control inputs-dia-${i}" 
                                                   name="detalles[${i}].horaFin" 
                                                   value="${detalle != null ? detalle.horaFin : ''}">
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label small">Turno</label>
                                            <select class="form-select inputs-dia-${i}" name="detalles[${i}].tipoTurno">
                                                <option value="">(Ninguno)</option>
                                                <c:forEach items="${tiposTurno}" var="t">
                                                    <option value="${t.nombre}" ${detalle != null && detalle.tipoTurno == t.nombre ? 'selected' : ''}>${t.nombre}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-1 text-end">
                                            <c:if test="${i > 0}">
                                                <button type="button" class="btn btn-outline-secondary btn-sm" title="Copiar del día anterior" onclick="copiarAnterior(${i})">
                                                    <i class="bi bi-arrow-up"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="d-grid gap-2 mt-4 d-md-flex justify-content-md-end">
                            <a href="${pageContext.request.contextPath}/plantillas" class="btn btn-secondary me-md-2">Cancelar</a>
                            <button type="submit" class="btn btn-primary btn-lg px-5">Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function toggleDia(index) {
            const isDescanso = document.getElementById('checkDescanso-' + index).checked;
            const inputs = document.querySelectorAll('.inputs-dia-' + index);
            
            inputs.forEach(input => {
                input.disabled = isDescanso;
                if(isDescanso) input.value = '';
            });
        }

        document.addEventListener("DOMContentLoaded", function() {
            for(let i=0; i<7; i++) toggleDia(i);
        });

        function copiarAnterior(index) {
            if (index <= 0) return;
            const prevInputs = document.querySelectorAll('.inputs-dia-' + (index - 1));
            const currentInputs = document.querySelectorAll('.inputs-dia-' + index);
            
            for (let i = 0; i < prevInputs.length; i++) {
                currentInputs[i].value = prevInputs[i].value;
            }
            const prevCheck = document.getElementById('checkDescanso-' + (index - 1));
            const curCheck = document.getElementById('checkDescanso-' + index);
            curCheck.checked = prevCheck.checked;
            toggleDia(index);
        }

        function limpiarTodo() {
            for(let i=0; i<7; i++) {
                document.getElementById('checkDescanso-' + i).checked = true;
                toggleDia(i);
            }
        }

        function copiarLunes() {
            const lunesInputs = document.querySelectorAll('.inputs-dia-0');
            const lunesCheck = document.getElementById('checkDescanso-0');

            for(let i=1; i<7; i++) {
                const currentInputs = document.querySelectorAll('.inputs-dia-' + i);
                for (let k = 0; k < currentInputs.length; k++) {
                    currentInputs[k].value = lunesInputs[k].value;
                }
                document.getElementById('checkDescanso-' + i).checked = lunesCheck.checked;
                toggleDia(i);
            }
        }
    </script>
</body>
</html>
