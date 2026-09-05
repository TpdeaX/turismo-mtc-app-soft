<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<footer class="footer">
    <div class="wrap">
        <div class="grid grid-4">

            <div>
                <div class="brand mb-4" style="flex-wrap:wrap">
                    <span class="brand-mark">
                        <img src="${ctx}/assets/img/logo-mtc.png" alt="${parametros['plataforma.nombre']}" width="40" height="40">
                    </span>
                    <span style="display:block;width:100%">
                        <span class="brand-name" style="color:#fff">${parametros['plataforma.nombre']}</span><br>
                        <span class="brand-sub">${parametros['plataforma.lema']}</span>
                    </span>
                </div>
                <p style="max-width:34ch;line-height:1.65">
                    Asesor turístico que integra información climatológica, ferroviaria y de zonas
                    turísticas para recomendar recorridos a pie desde las estaciones.
                </p>
            </div>

            <div>
                <h5>Plataforma</h5>
                <div class="col g-2">
                    <a href="${ctx}/" class="footer-link-item"><span class="mi">home</span> Inicio</a>
                    <a href="${ctx}/explorar" class="footer-link-item"><span class="mi">travel_explore</span> Explorar destinos</a>
                    <a href="${ctx}/#como-funciona" class="footer-link-item"><span class="mi">help_outline</span> Cómo funciona</a>
                    <a href="${ctx}/acceso" class="footer-link-item"><span class="mi">admin_panel_settings</span> Acceso de gestores</a>
                </div>
            </div>

            <div>
                <h5>Fuentes integradas</h5>
                <div class="col g-2" style="align-items:flex-start">
                    <div class="row center g-3">
                        <span class="marca marca-sm" data-marca="SENAMHI">
                            <img src="${ctx}/assets/img/logos-oficiales/senamhi.svg" data-logo-oficial alt="SENAMHI" loading="lazy">
                        </span>
                        <span>SENAMHI</span>
                    </div>
                    <div class="row center g-3">
                        <span class="marca marca-sm" data-marca="PeruRail">
                            <img src="${ctx}/assets/img/logos-oficiales/perurail.svg" data-logo-oficial alt="PeruRail" loading="lazy">
                        </span>
                        <span>PeruRail</span>
                    </div>
                    <div class="row center g-3">
                        <span class="marca marca-sm" data-marca="Travel Group Perú">
                            <img src="${ctx}/assets/img/logos-oficiales/travel-group-peru.svg" data-logo-oficial alt="Travel Group Perú" loading="lazy">
                        </span>
                        <span>Travel Group Perú</span>
                    </div>
                </div>
            </div>

            <div>
                <h5>Alcance del servicio</h5>
                <div class="col g-2">
                    <span class="footer-link-item"><span class="mi">directions_walk</span> Rutas peatonales ida y vuelta</span>
                    <span class="footer-link-item"><span class="mi">alt_route</span> Un solo tramo desde estación</span>
                    <span class="footer-link-item"><span class="mi">picture_as_pdf</span> Informe portátil PDF y HTML</span>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <span class="row center g-3" style="flex-wrap:wrap">
                <span class="marca marca-sm" data-marca="MTC">
                    <img src="${ctx}/assets/img/logos-oficiales/mtc.svg" data-logo-oficial
                         alt="${parametros['plataforma.entidad']}" loading="lazy">
                </span>
                <span>${parametros['plataforma.entidad']} · Plataforma de Zonas Turísticas</span>
            </span>
            <span>${parametros['portal.aviso_legal']}</span>
        </div>
    </div>
</footer>
