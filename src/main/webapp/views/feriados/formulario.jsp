<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${titulo}</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; /* Reset */ }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); width: 100%; max-width: 500px; margin: 40px auto; }
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
        
        <form action="${pageContext.request.contextPath}/feriados/guardar" method="post">
            <input type="hidden" name="id" value="${feriado.id}">

            <div class="form-group">
                <md-outlined-text-field label="Fecha" name="fecha" value="${feriado.fecha}" type="date" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Descripción" name="descripcion" value="${feriado.descripcion}"></md-outlined-text-field>
            </div>

            <c:if test="${not empty empresas && empresas.size() > 1}">
                <div class="form-group">
                    <span style="font-weight: 500; color: #444;">Aplicar a Empresas:</span>
                    <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 8px;">
                        <c:forEach var="emp" items="${empresas}">
                            <c:set var="isSelected" value="false" />
                            <c:if test="${not empty feriado.empresas}">
                                <c:forEach var="sel" items="${feriado.empresas}">
                                    <c:if test="${sel.id == emp.id}">
                                        <c:set var="isSelected" value="true" />
                                    </c:if>
                                </c:forEach>
                            </c:if>

                            <label style="display: flex; align-items: center; gap: 8px;">
                                <md-checkbox name="empresaIds" value="${emp.id}" ${isSelected ? 'checked' : ''}></md-checkbox>
                                <span>${emp.nombre}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <div class="buttons">
                <md-text-button type="button" onclick="window.location.href='${pageContext.request.contextPath}/feriados'">Cancelar</md-text-button>
                <md-filled-button type="submit">Guardar</md-filled-button>
            </div>
        </form>
    </div>

    </div>
    </div>
    </div>
</body>
</html>
