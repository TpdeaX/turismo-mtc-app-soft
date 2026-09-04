<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Acceso de gestores · MTC Perú</title>
    <jsp:include page="../shared/head.jsp" />
</head>
<body>

<main style="min-height:100vh;display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr)"
      class="login-shell">

    <!-- ============ PANEL DE MARCA ============ -->
    <section class="hero" style="min-height:auto;border-radius:0">
        <div class="hero-bg-photo" style="background-image:url('${ctx}/assets/img/login-bg.jpg');background-position:center top;"></div>
        <div class="wrap" style="position:relative;z-index:1;max-width:560px">

            <a href="${ctx}/" class="brand mb-6">
                <span class="brand-mark" style="width:48px;height:48px">
                    <img src="${ctx}/assets/img/logo-mtc.svg" alt="MTC Perú" width="48" height="48">
                </span>
                <span>
                    <span class="brand-name" style="color:#fff">MTC PERÚ</span><br>
                    <span class="brand-sub">Plataforma Oficial de Turismo y Transporte</span>
                </span>
            </a>

            <h1 class="display display-lg" style="color:#fff">
                Panel de <em>gestión</em> de la plataforma
            </h1>

            <p class="hero-sub">
                Espacio reservado para los gestores autorizados de Travel Group Perú, PeruRail y
                el Ministerio de Transportes y Comunicaciones.
            </p>

            <div class="col g-3 mt-6" style="background:rgba(255,255,255,.05);padding:18px 20px;border-radius:var(--r-lg);border:1px solid rgba(255,255,255,.1);backdrop-filter:blur(6px)">
                <div class="row center g-3">
                    <span class="stat-icon stat-icon-sm" style="background:rgba(245,197,24,.15);color:var(--brand-gold-500)">
                        <span class="mi mi-sm">hiking</span>
                    </span>
                    <div>
                        <div style="font-weight:650;color:#fff">Travel Group Perú</div>
                        <div style="font-size:.84rem;color:rgba(255,255,255,.68)">
                            Registra y actualiza las zonas turísticas y sus rutas caminables.
                        </div>
                    </div>
                </div>
                <div class="row center g-3">
                    <span class="stat-icon stat-icon-sm" style="background:rgba(245,197,24,.15);color:var(--brand-gold-500)">
                        <span class="mi mi-sm">train</span>
                    </span>
                    <div>
                        <div style="font-weight:650;color:#fff">PeruRail</div>
                        <div style="font-size:.84rem;color:rgba(255,255,255,.68)">
                            Mantiene servicios, horarios, tiempos de recorrido y tarifas.
                        </div>
                    </div>
                </div>
                <div class="row center g-3">
                    <span class="stat-icon stat-icon-sm" style="background:rgba(245,197,24,.15);color:var(--brand-gold-500)">
                        <span class="mi mi-sm">verified_user</span>
                    </span>
                    <div>
                        <div style="font-weight:650;color:#fff">Administración MTC</div>
                        <div style="font-size:.84rem;color:rgba(255,255,255,.68)">
                            Configura los parámetros generales y supervisa las integraciones.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============ FORMULARIO ============ -->
    <section style="display:grid;place-items:center;padding:48px 24px;background:var(--c-bg)">
        <div style="width:100%;max-width:400px">

            <div class="row between center mb-5">
                <a href="${ctx}/" class="btn btn-ghost btn-sm">
                    <span class="mi mi-sm">arrow_back</span> Ir al portal
                </a>
                <button type="button" class="btn-icon" data-tema aria-label="Cambiar tema">
                    <span class="mi mi-sm" data-tema-icono>dark_mode</span>
                </button>
            </div>

            <span class="eyebrow">Acceso restringido</span>
            <h2 class="display display-md mt-2">Iniciar sesión</h2>
            <p class="muted mt-2">Ingresa con tus credenciales institucionales.</p>

            <c:if test="${not empty error}">
                <div class="notice notice-danger mt-4">
                    <span class="mi mi-sm">error</span>
                    <div>${error}</div>
                </div>
            </c:if>

            <form method="post" action="${ctx}/acceso" class="col g-4 mt-5" data-submit-once>
                <input type="hidden" name="destino" value="${destino}">

                <div class="field">
                    <label for="correo">Correo institucional <span class="req">*</span></label>
                    <div class="input-icon">
                        <span class="mi mi-sm">mail</span>
                        <input class="input" type="email" id="correo" name="correo" required
                               autocomplete="username" data-autofocus
                               value="${correo}" placeholder="nombre@entidad.pe">
                    </div>
                </div>

                <div class="field">
                    <label for="password">Contraseña <span class="req">*</span></label>
                    <div class="input-icon">
                        <span class="mi mi-sm">lock</span>
                        <input class="input" type="password" id="password" name="password" required
                               autocomplete="current-password" placeholder="••••••••">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-block">
                    <span class="mi mi-sm">login</span> Ingresar al panel
                </button>
            </form>

            <!-- Credenciales de evaluación del caso -->
            <div class="card mt-5">
                <div class="card-head" style="padding:14px 18px">
                    <h3 style="font-size:.86rem">Cuentas de demostración</h3>
                    <span class="chip chip-outline" style="font-size:.7rem">Caso de estudio</span>
                </div>
                <div class="card-body" style="padding:14px 18px">
                    <div class="col g-2">
                        <button type="button" class="demo-acc-btn"
                                onclick="rellenar('admin@mtc.gob.pe','admin123')">
                            <div>
                                <div class="row center g-2">
                                    <strong style="font-size:.85rem">Administrador MTC</strong>
                                    <span class="demo-role-badge" style="background:var(--c-primary-container);color:var(--c-on-primary-container)">MTC</span>
                                </div>
                                <div class="soft mono" style="font-size:.78rem;margin-top:2px">admin@mtc.gob.pe · admin123</div>
                            </div>
                            <span class="mi mi-sm soft">key</span>
                        </button>
                        <button type="button" class="demo-acc-btn"
                                onclick="rellenar('gestor@travelgroup.pe','travel123')">
                            <div>
                                <div class="row center g-2">
                                    <strong style="font-size:.85rem">Travel Group Perú</strong>
                                    <span class="demo-role-badge" style="background:rgba(18,128,92,.12);color:#12805c">Turismo</span>
                                </div>
                                <div class="soft mono" style="font-size:.78rem;margin-top:2px">gestor@travelgroup.pe · travel123</div>
                            </div>
                            <span class="mi mi-sm soft">key</span>
                        </button>
                        <button type="button" class="demo-acc-btn"
                                onclick="rellenar('operaciones@perurail.com','rail123')">
                            <div>
                                <div class="row center g-2">
                                    <strong style="font-size:.85rem">PeruRail</strong>
                                    <span class="demo-role-badge" style="background:rgba(199,154,5,.15);color:#a87400">Operador</span>
                                </div>
                                <div class="soft mono" style="font-size:.78rem;margin-top:2px">operaciones@perurail.com · rail123</div>
                            </div>
                            <span class="mi mi-sm soft">key</span>
                        </button>
                    </div>
                </div>
            </div>

            <p class="soft text-center mt-5" style="font-size:.78rem">
                Ministerio de Transportes y Comunicaciones<br>
                El portal turístico es de acceso libre y no requiere iniciar sesión.
            </p>
        </div>
    </section>
</main>

<style>
    @media (max-width: 900px) {
        .login-shell { grid-template-columns: 1fr !important; }
        .login-shell > .hero { display: none; }
    }
</style>

<script>
    function rellenar(correo, clave) {
        document.getElementById('correo').value = correo;
        document.getElementById('password').value = clave;
        document.getElementById('password').focus();
    }
</script>

<jsp:include page="../shared/scripts.jsp" />
</body>
</html>
