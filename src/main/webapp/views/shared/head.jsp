<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#0A1F3D">
<meta name="description" content="Plataforma del Ministerio de Transportes y Comunicaciones que integra zonas turísticas, pronóstico del SENAMHI y datos ferroviarios de PeruRail para recomendar rutas caminables desde las estaciones.">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;0,9..144,700;1,9..144,600&family=JetBrains+Mono:wght@400;500&display=swap">
<link rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,400,0..1,0">

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=3.3">
<link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/img/logo-mtc.svg">

<%-- Evita el destello de tema claro antes de que cargue app.js --%>
<script>
    (function () {
        try {
            document.documentElement.setAttribute('data-context-path', '${pageContext.request.contextPath}');
            var t = localStorage.getItem('mtc-tema');
            if (!t) {
                t = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
            }
            document.documentElement.setAttribute('data-theme', t);
        } catch (e) { document.documentElement.setAttribute('data-theme', 'light'); }
    })();
</script>
