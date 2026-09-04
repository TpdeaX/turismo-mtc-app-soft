<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="parametros" scope="request" />
<c:set var="tituloModulo" value="Parámetros generales" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Parámetros generales · MTC Perú</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>
<div class="shell">
    <jsp:include page="../shared/panel-sidebar.jsp" />

    <div class="main">
        <jsp:include page="../shared/panel-topbar.jsp" />

        <div class="page">

            <div class="page-head">
                <div>
                    <span class="eyebrow">Administración MTC</span>
                    <h1 class="mt-2">Parámetros Generales</h1>
                    <p>Panel de configuración de la plataforma. Los cambios se aplican de inmediato
                        al portal público y a los procesos de integración.</p>
                </div>
            </div>

            <form method="post" action="${ctx}/panel/parametros/guardar" data-submit-once>

                <div class="col g-5">
                    <c:forEach var="grupo" items="${grupos}">
                        <div class="card anim-up">
                            <div class="card-head">
                                <div class="row center g-3">
                                    <span class="stat-icon stat-icon-sm">
                                        <span class="mi mi-sm">
                                            <c:choose>
                                                <c:when test="${grupo.key eq 'IDENTIDAD'}">badge</c:when>
                                                <c:when test="${grupo.key eq 'RUTAS'}">directions_walk</c:when>
                                                <c:when test="${grupo.key eq 'INTEGRACIONES'}">sync</c:when>
                                                <c:when test="${grupo.key eq 'PORTAL'}">public</c:when>
                                                <c:otherwise>tune</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </span>
                                    <div>
                                        <h3>
                                            <c:choose>
                                                <c:when test="${grupo.key eq 'IDENTIDAD'}">Identidad de la plataforma</c:when>
                                                <c:when test="${grupo.key eq 'RUTAS'}">Motor de rutas caminables</c:when>
                                                <c:when test="${grupo.key eq 'INTEGRACIONES'}">Integraciones externas</c:when>
                                                <c:when test="${grupo.key eq 'PORTAL'}">Portal del usuario final</c:when>
                                                <c:otherwise>${grupo.key}</c:otherwise>
                                            </c:choose>
                                        </h3>
                                        <div class="soft" style="font-size:.8rem">
                                            ${grupo.value.size()} parámetro(s)
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card-body col g-4">
                                <c:forEach var="p" items="${grupo.value}">
                                    <div class="row between center wrap-flex g-4"
                                         style="padding-bottom:16px;border-bottom:1px solid var(--c-border)">

                                        <div style="max-width:56ch">
                                            <div class="cell-strong">${p.descripcion}</div>
                                            <div class="soft mono mt-1" style="font-size:.76rem">${p.clave}</div>
                                        </div>

                                        <div style="min-width:230px">
                                            <c:choose>
                                                <c:when test="${p.tipo eq 'BOOLEANO'}">
                                                    <label class="switch">
                                                        <input type="checkbox" name="param.${p.clave}" value="true"
                                                               <c:if test="${p.activo}">checked</c:if>>
                                                        <span class="track"></span>
                                                        <span class="switch-label">
                                                            ${p.activo ? 'Habilitado' : 'Deshabilitado'}
                                                        </span>
                                                    </label>
                                                </c:when>
                                                <c:when test="${p.tipo eq 'NUMERO'}">
                                                    <input class="input" type="number" step="0.1"
                                                           name="param.${p.clave}" value="${p.valor}">
                                                </c:when>
                                                <c:otherwise>
                                                    <input class="input" type="text" maxlength="255"
                                                           name="param.${p.clave}" value="<c:out value='${p.valor}'/>">
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Barra de guardado -->
                <div class="card mt-5 anim-up"
                     style="position:sticky;bottom:16px;box-shadow:var(--sh-3)">
                    <div class="card-body-sm row between center wrap-flex g-3">
                        <div class="row center g-3">
                            <span class="mi mi-sm soft">info</span>
                            <span class="soft" style="font-size:.86rem">
                                Los interruptores que queden apagados se guardarán como deshabilitados.
                            </span>
                        </div>
                        <div class="row g-2">
                            <button type="reset" class="btn btn-ghost">
                                <span class="mi mi-sm">undo</span> Descartar
                            </button>
                            <button type="submit" class="btn btn-primary">
                                <span class="mi mi-sm">save</span> Guardar todos los parámetros
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
