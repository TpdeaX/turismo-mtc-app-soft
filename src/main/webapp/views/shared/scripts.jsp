<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Puente entre los flash attributes del controlador y el sistema de toasts --%>
<div id="flash-toast" hidden
     data-mensaje="<c:out value='${toast}'/>"
     data-tipo="${empty toastTipo ? 'info' : toastTipo}"></div>

<div class="toast-stack" aria-live="polite" aria-atomic="true"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/maplibre-gl/4.7.1/maplibre-gl.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js?v=4.7"></script>
