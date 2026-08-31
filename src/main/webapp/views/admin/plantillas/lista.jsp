<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Plantillas de Horarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body>
    <jsp:include page="/views/shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/shared/header.jsp" />

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Gestión de Plantillas</h2>
            <a href="${pageContext.request.contextPath}/plantillas/nueva" class="btn btn-primary">
                <i class="bi bi-plus-circle"></i> Nueva Plantilla
            </a>
        </div>

        <div class="card shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Detalles</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${plantillas}" var="p">
                                <tr>
                                    <td>${p.nombre}</td>
                                    <td>
                                        <span class="badge bg-info">${p.detalles.size()} días configurados</span>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/plantillas/editar?id=${p.id}" class="btn btn-primary" title="Editar">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <form action="${pageContext.request.contextPath}/plantillas/eliminar" method="post" class="d-inline" onsubmit="return confirm('¿Eliminar esta plantilla?');">
                                                <input type="hidden" name="id" value="${p.id}">
                                                <button type="submit" class="btn btn-danger" title="Eliminar">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty plantillas}">
                                <tr>
                                    <td colspan="3" class="text-center text-muted py-4">
                                        No hay plantillas registradas
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
