<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="modulo" value="categorias" scope="request" />
<c:set var="tituloModulo" value="Categorías" scope="request" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Categorías de preferencia · MTC Perú</title>
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
                    <span class="eyebrow">Travel Group Perú</span>
                    <h1 class="mt-2">Categorías de Preferencia</h1>
                    <p>Catálogo que se despliega al turista cuando ingresa sus preferencias y que
                        determina el filtrado de las zonas turísticas.</p>
                </div>
                <button type="button" class="btn btn-primary btn-lg"
                        data-modal-open="modal-categoria"
                        data-modal-title="Nueva categoría"
                        data-modal-sub="Se mostrará en el formulario de preferencias"
                        data-set-codigo="" data-set-nombre="" data-set-descripcion=""
                        data-set-icono="tour" data-set-color="#0A1F3D" data-set-estado="true">
                    <span class="mi mi-sm">new_label</span> Nueva categoría
                </button>
            </div>

            <div class="grid grid-3">
                <c:forEach var="cat" items="${categorias}" varStatus="st">
                    <div class="card card-hover anim-up" style="animation-delay:${st.index * 0.05}s">
                        <div class="card-body">
                            <div class="row between center g-3">
                                <span class="stat-icon stat-icon-cat" style="--cat:${cat.color}">
                                    <span class="mi">${cat.icono}</span>
                                </span>
                                <c:choose>
                                    <c:when test="${cat.estado}">
                                        <span class="chip chip-success"><i class="dot"></i>Activa</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="chip chip-outline"><i class="dot"></i>Inactiva</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <h3 class="mt-3" style="font-size:1.05rem">${cat.nombre}</h3>
                            <p class="muted mt-1" style="font-size:.87rem;min-height:2.6em">
                                ${cat.descripcion}
                            </p>

                            <div class="row center g-2 mt-3">
                                <span class="chip chip-outline mono" style="font-size:.72rem">
                                    ${cat.icono}
                                </span>
                                <span class="chip chip-outline mono" style="font-size:.72rem">
                                    ${cat.color}
                                </span>
                            </div>
                        </div>

                        <div class="card-foot row end g-2">
                            <button type="button" class="btn btn-ghost btn-sm"
                                    data-modal-open="modal-categoria"
                                    data-modal-title="Editar categoría"
                                    data-modal-sub="${cat.nombre}"
                                    data-set-codigo="${cat.codigo}"
                                    data-set-nombre="<c:out value='${cat.nombre}'/>"
                                    data-set-descripcion="<c:out value='${cat.descripcion}'/>"
                                    data-set-icono="${cat.icono}"
                                    data-set-color="${cat.color}"
                                    data-set-estado="${cat.estado}">
                                <span class="mi mi-sm">edit</span> Editar
                            </button>
                            <button type="button" class="btn btn-ghost btn-sm"
                                    style="color:var(--c-danger)"
                                    data-modal-open="modal-eliminar-categoria"
                                    data-set-codigo="${cat.codigo}"
                                    data-set-nombrecategoria="<c:out value='${cat.nombre}'/>">
                                <span class="mi mi-sm">delete</span>
                            </button>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <c:if test="${empty categorias}">
                <div class="card">
                    <div class="empty">
                        <span class="mi">sell</span>
                        <h4>Sin categorías registradas</h4>
                        <p class="muted">Crea al menos una categoría para poder clasificar las zonas turísticas.</p>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- MODAL · Categoría -->
<div class="modal" id="modal-categoria" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card">
        <form method="post" action="${ctx}/panel/categorias/guardar" data-submit-once>
            <div class="modal-head">
                <div class="modal-icon"><span class="mi">sell</span></div>
                <h3 data-modal-title-target>Nueva categoría</h3>
                <p data-modal-sub-target>Se mostrará en el formulario de preferencias</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="codigo">

                <div class="form-grid cols-2">
                    <div class="field span-full">
                        <label for="c-nombre">Nombre <span class="req">*</span></label>
                        <input class="input" type="text" id="c-nombre" name="nombre" maxlength="50" required
                               data-autofocus placeholder="Ej. Naturaleza">
                    </div>
                    <div class="field span-full">
                        <label for="c-desc">Descripción</label>
                        <textarea class="textarea" id="c-desc" name="descripcion" maxlength="200"
                                  style="min-height:74px"
                                  placeholder="Qué tipo de atractivos agrupa esta categoría…"></textarea>
                    </div>
                    <div class="field span-full">
                        <label>Icono de la categoría</label>
                        <div class="icon-picker" data-icon-picker>
                            <input type="hidden" name="icono" value="tour">
                            <div class="icon-picker-head">
                                <span class="icon-picker-preview"><span class="mi">tour</span></span>
                                <div class="icon-picker-id">
                                    <div class="icon-picker-name">tour</div>
                                    <div class="icon-picker-sub">Símbolo seleccionado</div>
                                </div>
                                <div class="input-icon icon-picker-search">
                                    <span class="mi mi-sm">search</span>
                                    <input class="input" type="text" autocomplete="off"
                                           spellcheck="false" placeholder="Buscar: museo, tren, sol…">
                                </div>
                            </div>
                            <div class="icon-picker-tabs" role="tablist"></div>
                            <div class="icon-picker-grid" role="listbox" aria-label="Catálogo de iconos"></div>
                        </div>
                        <span class="hint">Elige el símbolo tocándolo; no necesitas escribir su nombre.</span>
                    </div>

                    <div class="field span-full">
                        <label>Color distintivo</label>
                        <div class="color-picker" data-color-picker>
                            <input type="hidden" name="color" value="#0A1F3D">
                            <div class="color-picker-head">
                                <span class="color-preview"><span class="mi">palette</span></span>
                                <div class="grow">
                                    <input class="input color-hex" type="text" maxlength="7"
                                           autocomplete="off" spellcheck="false" aria-label="Código hexadecimal">
                                    <div class="color-picker-hint">Código hexadecimal · también puedes usar la rueda de color.</div>
                                </div>
                            </div>
                            <div class="color-swatches">
                                <span class="color-swatch color-custom" title="Color personalizado">
                                    <span class="mi">colorize</span>
                                    <input type="color" aria-label="Elegir un color personalizado">
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="field span-full">
                        <label class="switch">
                            <input type="checkbox" name="estado" value="true" checked>
                            <span class="track"></span>
                            <span class="switch-label">Mostrar en el formulario de preferencias</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-ghost" data-modal-close>Cancelar</button>
                <button type="submit" class="btn btn-primary">
                    <span class="mi mi-sm">save</span> Guardar categoría
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL · Eliminar categoría -->
<div class="modal" id="modal-eliminar-categoria" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="modal-card modal-sm">
        <form method="post" action="${ctx}/panel/categorias/eliminar" data-submit-once>
            <div class="modal-head danger">
                <div class="modal-icon"><span class="mi">delete_forever</span></div>
                <h3>¿Eliminar categoría?</h3>
                <p>Esta acción no se puede deshacer</p>
                <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">
                    <span class="mi mi-sm">close</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="codigo">
                <div class="confirm-box">
                    <span class="mi">warning</span>
                    <div>Si la categoría está asignada a alguna zona turística, la eliminación
                        será rechazada. Desactívala en su lugar.</div>
                </div>
                <div class="confirm-target">
                    <div class="eyebrow">Categoría seleccionada</div>
                    <div class="cell-strong mt-1" data-field="nombrecategoria">—</div>
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

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
