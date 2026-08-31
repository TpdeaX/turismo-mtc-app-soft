<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${titulo}</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding: 20px; display: flex; justify-content: center; }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); width: 100%; max-width: 500px; }
        h2 { color: #006A6A; text-align: center; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; display: flex; flex-direction: column; gap: 5px; }
        
        md-outlined-text-field { width: 100%; }
        
        .buttons { display: flex; gap: 15px; justify-content: flex-end; margin-top: 20px; }
    </style>
</head>
<body>

    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
    <div class="card">
        <h2>${titulo}</h2>
        
        <form action="${pageContext.request.contextPath}/sucursales/guardar" method="post">
            <input type="hidden" name="id" value="${sucursal.id}">

            <!-- Selector de empresa (solo visible si hay más de una) -->
            <c:choose>
                <c:when test="${empresas.size() > 1}">
                    <div class="form-group">
                        <label style="color: #006A6A; font-weight: 500; margin-bottom: 5px;">Empresa</label>
                        <select name="empresaId" style="padding: 12px; border: 1px solid #ccc; border-radius: 8px; font-size: 14px;">
                            <c:forEach items="${empresas}" var="emp">
                                <option value="${emp.id}" ${sucursal.empresa != null && sucursal.empresa.id == emp.id ? 'selected' : ''}>${emp.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Si solo tiene una empresa, se asigna automáticamente -->
                    <c:if test="${not empty empresas}">
                        <input type="hidden" name="empresaId" value="${empresas[0].id}">
                    </c:if>
                </c:otherwise>
            </c:choose>

            <div class="form-group">
                <md-outlined-text-field label="Nombre" name="nombre" value="${sucursal.nombre}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Dirección" name="direccion" value="${sucursal.direccion}"></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Teléfono" name="telefono" value="${sucursal.telefono}"></md-outlined-text-field>
            </div>

            <div class="buttons">
                <md-text-button type="button" onclick="window.location.href='${pageContext.request.contextPath}/sucursales'">Cancelar</md-text-button>
                <md-filled-button type="submit">Guardar</md-filled-button>
            </div>
        </form>
    </div>

    </div>
</body>
</html>
