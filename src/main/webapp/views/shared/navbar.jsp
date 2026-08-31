<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .top-app-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 24px;
        background-color: white; 
        color: #1f1f1f;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        position: sticky;
        top: 0;
        z-index: 1000;
    }
    
    .app-logo-link {
        text-decoration: none;
        color: #006A6A; 
        font-size: 1.375rem;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 12px;
        transition: opacity 0.2s;
    }
    .app-logo-link:hover {
        opacity: 0.8;
    }

    .user-info {
        display: flex;
        align-items: center;
        gap: 20px;
    }
    
    .nav-link {
        text-decoration: none;
        color: #444746;
        font-weight: 500;
        font-size: 0.95rem;
        padding: 8px 12px;
        border-radius: 8px;
        transition: background 0.2s;
    }
    .nav-link:hover {
        background-color: #f0f2f5;
        color: #1f1f1f;
    }
</style>

<c:set var="homeLink" value="${pageContext.request.contextPath}/" />
<c:if test="${sessionScope.usuario.rol == 'ADMIN'}">
    <c:set var="homeLink" value="${pageContext.request.contextPath}/admin" />
</c:if>
<c:if test="${sessionScope.usuario.rol == 'EMPLEADO'}">
    <c:set var="homeLink" value="${pageContext.request.contextPath}/empleado" />
</c:if>

<nav class="top-app-bar">
    <a href="${homeLink}" class="app-logo-link">
        <span class="material-symbols-outlined" style="font-size: 28px;">encrypted</span>
        Grupo Peruana
    </a>
    
    <div class="user-info">
        <span style="font-size: 0.9rem; color: #555;">Hola, <b>${sessionScope.usuario.nombres}</b></span>
        
        <c:if test="${sessionScope.usuario.rol == 'ADMIN' && not empty sessionScope.empresasAdmin && sessionScope.empresasAdmin.size() > 1}">
            <div style="margin-right: 15px;">
                <select id="companySwitcher" onchange="switchCompany(this.value)" style="padding: 6px; border-radius: 4px; border: 1px solid #ccc; cursor: pointer;">
                    <c:forEach items="${sessionScope.empresasAdmin}" var="emp">
                        <option value="${emp.id}" ${sessionScope.empresaActiva != null && sessionScope.empresaActiva.id == emp.id ? 'selected' : ''}>
                            ${emp.nombre}
                        </option>
                    </c:forEach>
                    <%-- 
                    <option value="-1" ${sessionScope.empresaActiva == null ? 'selected' : ''}>Todas</option> 
                    --%>
                </select>
            </div>
            <script>
                function switchCompany(id) {
                    fetch('${pageContext.request.contextPath}/api/session/context/empresa/' + id, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    })
                    .then(response => response.json())
                    .then(data => {
                        if(data.success) {
                            location.reload();
                        } else {
                            alert('Error al cambiar de empresa: ' + data.message);
                        }
                    })
                    .catch(error => console.error('Error:', error));
                }
            </script>
        </c:if>

        <c:if test="${sessionScope.usuario.rol == 'ADMIN'}">
            <a class="nav-link" href="${pageContext.request.contextPath}/empleados">Empleados</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/horarios">Horarios</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/plantillas">Plantillas</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/tipoturno">Tipos de Turno</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/sucursales">Sucursales</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/feriados">Feriados</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/justificaciones">Justificaciones</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/reportes/calculo">Reportes</a>
        </c:if>

        <c:if test="${sessionScope.usuario.rol == 'EMPLEADO'}">
            <a class="nav-link" href="${pageContext.request.contextPath}/empleado/mi_historial">Mi Historial</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/justificaciones">Justificaciones</a>
        </c:if>

        <md-text-button href="${pageContext.request.contextPath}/auth/logout" style="color: #b71c1c;">
            Salir
            <span slot="icon" class="material-symbols-outlined">logout</span>
        </md-text-button>
    </div>
</nav>
