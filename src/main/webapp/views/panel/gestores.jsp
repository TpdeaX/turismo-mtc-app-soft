<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="mtc" uri="http://zonasturisticas.com/mtc" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="gestores" scope="request" />
<c:set var="tituloModulo" value="Gestores autorizados" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Gestores autorizados · ${parametros['plataforma.nombre']}</title>
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
                    <h1 class="mt-2">Gestores Autorizados</h1>
                    <p>Cuentas con acceso al panel administrativo. Cada rol determina qué módulos
                        puede administrar, conforme a las responsabilidades asignadas.</p>
                </div>
                <div class="row g-2 center wrap-flex">
                    <!-- Botón para abrir modal de Matriz de Permisos -->
                    <button type="button" class="btn btn-outline btn-lg"
                            data-modal-open="modal-permisos-rol"
                            title="Ver matriz de responsabilidades por rol">
                        <span class="mi mi-sm" style="color:var(--brand-navy-600)">shield</span>
                        <span>Permisos por rol</span>
                        <span class="mi mi-sm soft">info</span>
                    </button>

                    <button type="button" class="btn btn-primary btn-lg"
                            data-modal-open="modal-gestor"
                            data-modal-title="Registrar nuevo gestor"
                            data-modal-sub="Asigna el rol según la entidad responsable"
                            data-set-codigo="" data-set-nombre="" data-set-correo=""
                            data-set-rol="TRAVEL_GROUP" data-set-estado="true">
                        <span class="mi mi-sm">person_add</span> Nuevo gestor
                    </button>
                </div>
            </div>

            <!-- Listado de gestores -->
            <div class="card anim-up d-1">
                <div class="card-head">
                    <h3>Cuentas registradas</h3>
                    <span class="chip chip-outline">${gestores.size()} gestores</span>
                </div>

                <div class="table-wrap">
                    <table class="data">
                        <thead>
                            <tr>
                                <th>Gestor</th>
                                <th>Correo institucional</th>
                                <th>Rol</th>
                                <th>Último acceso</th>
                                <th>Estado</th>
                                <th class="text-right" style="width:110px">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="g" items="${gestores}">
                                <tr class="main-row">
                                    <td>
                                        <div class="row center g-3">
                                            <span class="avatar">${g.iniciales}</span>
                                            <span class="cell-strong">${g.nombre}</span>
                                        </div>
                                    </td>
                                    <td class="mono muted">${g.correo}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${g.rol eq 'ADMIN'}">
                                                <span class="chip chip-primary">
                                                    <span class="mi mi-sm">shield_person</span>${g.rolTexto}</span>
                                            </c:when>
                                            <c:when test="${g.rol eq 'TRAVEL_GROUP'}">
                                                <span class="chip chip-info">
                                                    <span class="mi mi-sm">landscape</span>${g.rolTexto}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="chip chip-accent">
                                                    <span class="mi mi-sm">tram</span>${g.rolTexto}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="soft" style="font-size:.83rem">${mtc:relativo(g.ultimoAcceso)}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${g.estado}">
                                                <span class="chip chip-success"><i class="dot"></i>Activo</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="chip chip-outline"><i class="dot"></i>Desactivado</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <button type="button" class="btn-icon btn-icon-sm accent"
                                                    title="Editar"
                                                    data-modal-open="modal-gestor"
                                                    data-modal-title="Editar gestor"
                                                    data-modal-sub="${g.nombre}"
                                                    data-set-codigo="${g.codigo}"
                                                    data-set-nombre="<c:out value='${g.nombre}'/>"
                                                    data-set-correo="${g.correo}"
                                                    data-set-rol="${g.rol}"
                                                    data-set-estado="${g.estado}">
                                                <span class="mi mi-sm">edit</span>
                                            </button>
                                            <c:if test="${usuarioSesion.codigo ne g.codigo}">
                                                <button type="button" class="btn-icon btn-icon-sm danger"
                                                        title="Eliminar"
                                                        data-modal-open="modal-eliminar-gestor"
                                                        data-set-codigo="${g.codigo}"
                                                        data-set-nombregestor="<c:out value='${g.nombre}'/>"
                                                        data-set-correogestor="${g.correo}">
                                                    <span class="mi mi-sm">delete</span>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL · Gestor -->
<div class="modal" id="modal-gestor" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/gestores/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">manage_accounts</span></div>
                <h3 data-modal-title-target>Registrar nuevo gestor</h3>
                <p data-modal-sub-target>Asigna el rol según la entidad responsable</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="g-nombre">Nombre completo <span class="req">*</span></label>
                        <input class="input" type="text" id="g-nombre" name="nombre" maxlength="100" required
                               data-autofocus placeholder="Ej. María Ascarza">
                    </div>
                    <div class="field span-full">
                        <label for="g-correo">Correo institucional <span class="req">*</span></label>
                        <input class="input" type="email" id="g-correo" name="correo" maxlength="100" required
                               placeholder="nombre@entidad.pe">
                    </div>
                    <div class="field">
                        <label for="g-rol">Rol <span class="req">*</span></label>
                        <select class="select" id="g-rol" name="rol" required>
                            <option value="TRAVEL_GROUP">Travel Group Perú</option>
                            <option value="PERURAIL">PeruRail</option>
                            <option value="ADMIN">Administrador MTC</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="g-pass">Contraseña</label>
                        <input class="input" type="password" id="g-pass" name="password"
                               autocomplete="new-password" placeholder="••••••••">
                        <span class="hint">Déjala vacía al editar para conservar la actual.</span>
                    </div>
                    <div class="field span-full">
                        <label class="switch">
                            <input type="checkbox" name="estado" value="true" checked>
                            <span class="track"></span>
                            <span class="switch-label">Cuenta activa</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar gestor
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL · Eliminar gestor -->
<div class="modal" id="modal-eliminar-gestor" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/gestores/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">person_remove</span></div>
                <h3>¿Eliminar gestor?</h3>
                <p>Perderá el acceso al panel administrativo</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>La cuenta se eliminará de forma permanente. Si solo deseas suspender el
                        acceso, desactívala desde el formulario de edición.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Gestor seleccionado</div>
                    <div class="cell-strong mt-1" data-field="nombregestor">—</div>
                    <div class="soft mono" style="font-size:.83rem" data-field="correogestor">—</div>
                </div>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-danger">
                    <span class="mi mi-sm">delete</span> Sí, eliminar
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== MODAL · Matriz de Permisos por Rol ==================== -->
<div class="modal" id="modal-permisos-rol" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="tit-matriz">
    <div class="modal-card modal-md">
        <div class="modal-head">
            <div class="modal-icon"><span class="mi">shield</span></div>
            <h3 id="tit-matriz">Matriz de permisos por rol</h3>
            <p>Alcance administrativo y niveles de acceso según la entidad responsable</p>
            <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                <span class="mi mi-sm">close</span>
            </button>
        </div>

        <div class="modal-body" style="padding:0">
            <div class="table-wrap" style="border:none">
                <table class="data" style="margin:0">
                    <thead>
                        <tr style="background:var(--c-surface-2)">
                            <th style="padding:16px 22px">Módulo administrativo</th>
                            <th class="text-center" style="padding:16px">
                                <span class="chip" style="background:#EBF3FE;color:#1B4278;font-weight:700">Admin MTC</span>
                            </th>
                            <th class="text-center" style="padding:16px">
                                <span class="chip" style="background:#EEF2FF;color:#4F46E5;font-weight:700">Travel Group</span>
                            </th>
                            <th class="text-center" style="padding:16px">
                                <span class="chip" style="background:#FEF9C3;color:#854D0E;font-weight:700">PeruRail</span>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="padding:14px 22px">
                                <strong>Zonas, rutas y categorías</strong>
                                <div class="soft" style="font-size:.78rem">Creación, edición y catálogo turístico</div>
                            </td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center soft"><span class="mi" style="font-size:20px">remove</span></td>
                        </tr>
                        <tr>
                            <td style="padding:14px 22px">
                                <strong>Estaciones ferroviarias</strong>
                                <div class="soft" style="font-size:.78rem">Datos generales y consulta operativa</div>
                            </td>
                            <td class="text-center"><span class="chip chip-success" style="font-size:.74rem;padding:3px 10px">Edición total</span></td>
                            <td class="text-center"><span class="chip chip-outline" style="font-size:.74rem;padding:3px 10px">Solo lectura</span></td>
                            <td class="text-center"><span class="chip chip-outline" style="font-size:.74rem;padding:3px 10px">Solo lectura</span></td>
                        </tr>
                        <tr>
                            <td style="padding:14px 22px">
                                <strong>Horarios y tarifas</strong>
                                <div class="soft" style="font-size:.78rem">Itinerarios y programación de servicios</div>
                            </td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center soft"><span class="mi" style="font-size:20px">remove</span></td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                        </tr>
                        <tr>
                            <td style="padding:14px 22px">
                                <strong>Parámetros generales y gestores</strong>
                                <div class="soft" style="font-size:.78rem">Configuración y alta de cuentas</div>
                            </td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center soft"><span class="mi" style="font-size:20px">remove</span></td>
                            <td class="text-center soft"><span class="mi" style="font-size:20px">remove</span></td>
                        </tr>
                        <tr>
                            <td style="padding:14px 22px">
                                <strong>Monitoreo de integraciones</strong>
                                <div class="soft" style="font-size:.78rem">Sincronización PeruRail y SENAMHI</div>
                            </td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                            <td class="text-center"><span class="mi" style="color:var(--c-success);font-size:20px">check_circle</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal-foot">
            <button type="button" class="btn btn-primary" data-modal-close>
                <span class="mi mi-sm">check</span> Entendido
            </button>
        </div>
    </div>
</div>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
