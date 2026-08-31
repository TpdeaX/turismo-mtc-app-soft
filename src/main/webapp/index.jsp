<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Acceso - ${not empty loginEmpresa ? loginEmpresa.nombre : 'La Peruana'}</title>
<meta name="theme-color" content="${not empty loginEmpresa && not empty loginEmpresa.colorPrimario ? loginEmpresa.colorPrimario : '#7C3AED'}">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Poppins:wght@500;600;700;800&display=swap"
	rel="stylesheet">

<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" />
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<script src="https://www.google.com/recaptcha/api.js" async defer></script>

<script type="importmap">
      { "imports": { "@material/web/": "https://esm.run/@material/web/" } }
    </script>
<script type="module">
      import '@material/web/all.js';
      import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
      document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

<style>
:root {
    --brand-purple: ${not empty loginEmpresa && not empty loginEmpresa.colorPrimario ? loginEmpresa.colorPrimario : '#7C3AED'};
    --brand-magenta: ${not empty loginEmpresa && not empty loginEmpresa.colorSecundario ? loginEmpresa.colorSecundario : '#FF2A5F'};
    --brand-yellow: #FFB900;
    --brand-dark: #1e1e2f;
    --md-sys-color-primary: var(--brand-purple);
    --md-outlined-text-field-container-shape: 14px;
    --md-outlined-text-field-outline-color: #cbd5e1;
    --md-outlined-text-field-focus-outline-color: var(--brand-purple);
    --md-outlined-text-field-label-text-font: 'Outfit', sans-serif;
    --login-bg-base: #f8fafc;
}

*, *::before, *::after {
    box-sizing: border-box;
}

body {
    font-family: 'Outfit', sans-serif;
    margin: 0;
    height: 100dvh; /* Altura dinámica completa */
    width: 100vw;
    display: flex;
    justify-content: center;
    align-items: center;
    overflow: hidden; /* Sin scroll */
    
    /* --- FONDO DE PUNTOS --- */
    background-color: var(--login-bg-base);
    background-image: radial-gradient(#cbd5e1 1.5px, transparent 1.5px);
    background-size: 24px 24px;
    position: relative;
    transition: background-color 0.6s ease;
}

/* --- EFECTOS GLOW DE FONDO --- */
#background-effects {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1;
    pointer-events: none;
    overflow: hidden;
    isolation: isolate;
}

.glow-blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(68px) saturate(1.4) brightness(1.08);
    mix-blend-mode: normal;
    will-change: transform, opacity;
    opacity: 0;
    animation: floatFade var(--glow-duration, 9s) cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

.glow-blob.glow-loop {
    animation-iteration-count: infinite;
    animation-direction: normal;
}

/* CORREGIDO: @keyframes sin espacios y formato limpio */
@keyframes floatFade { 
    0% {
        opacity: 0;
        transform: scale(0.55) translate(0, 0);
    }
    18% {
        opacity: 0.1;
    }
    55% {
        opacity: 0.05;
    }
    100% {
        opacity: 0;
        transform: scale(1.45) translate(var(--move-x), var(--move-y));
    }
}

/* --- TARJETA PRINCIPAL (PC) --- */
.main-card {
    display: flex;
    width: 100%;
    max-width: 1000px;
    height: 600px;
    background: #ffffff; /* Blanco sólido solo en PC */
    border-radius: 32px;
    box-shadow: 0 25px 50px -12px rgba(124, 58, 237, 0.25);
    overflow: hidden;
    position: relative;
    z-index: 3;
    animation: slideUp 0.7s cubic-bezier(0.2, 0.8, 0.2, 1);
    transition: box-shadow 0.6s ease, transform 0.35s ease;
}

/* Panel Izquierdo (Visual - PC) */
.visual-side {
    width: 50%;
    background: linear-gradient(135deg, var(--brand-purple) 0%, var(--brand-magenta) 100%);
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 40px;
    color: white;
    text-align: center;
    z-index: 10;
    border-radius: 0 60px 60px 0/0 50% 50% 0;
    overflow: hidden;
    transition: background 0.7s ease;
}

.visual-decor {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.shape {
    position: absolute;
    opacity: 0.15;
    border-radius: 50%;
    filter: blur(40px);
}

.shape-1 {
    width: 300px;
    height: 300px;
    background: white;
    top: -50px;
    left: -50px;
}

.shape-2 {
    width: 200px;
    height: 200px;
    border: 40px solid var(--brand-yellow);
    bottom: 10%;
    right: -50px;
    opacity: 0.1;
}

.logo-container {
    background: white;
    width: 110px;
    height: 110px;
    border-radius: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
    margin-bottom: 25px;
    animation: floatLogo 6s ease-in-out infinite;
    transition: transform 0.35s ease, opacity 0.35s ease;
}

.logo-img {
    width: 65px;
}

.brand-title {
    font-family: 'Poppins', sans-serif;
    font-size: 2.5rem;
    font-weight: 700;
    margin: 0;
    line-height: 1.1;
    transition: color 0.35s ease, opacity 0.35s ease, transform 0.35s ease;
}

.brand-sub {
    font-size: 1.1rem;
    opacity: 0.9;
    margin-top: 10px;
    font-weight: 300;
    transition: opacity 0.35s ease, transform 0.35s ease;
}

.social-section {
    margin-top: 40px;
}

.social-icons {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.social-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(5px);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    text-decoration: none;
    transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
    z-index: 1;
}

/* Pseudo-element for smooth background transitions (esp. Gradients) */
.social-btn::before {
    content: '';
    position: absolute;
    inset: 0;
    z-index: -1;
    opacity: 0;
    transition: opacity 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.social-btn:hover {
    transform: translateY(-5px);
    color: white;
    /* Remove direct background change to rely on pseudo-element */
}

.social-btn:hover::before {
    opacity: 1;
}

/* Define backgrounds on the pseudo-element */
.social-btn.fb::before { 
    background-color: rgba(24, 119, 242, 0.85); 
}
.social-btn.tt::before { 
    background-color: rgba(0, 0, 0, 0.85); 
}
.social-btn.ig::before { 
    background: linear-gradient(45deg, rgba(240, 148, 51, 0.85) 0%, rgba(230, 104, 60, 0.85) 25%, rgba(220, 39, 67, 0.85) 50%, rgba(204, 35, 102, 0.85) 75%, rgba(188, 24, 136, 0.85) 100%); 
}
.social-btn.wa::before { 
    background-color: rgba(37, 211, 102, 0.85); 
}
.social-btn.em::before { 
    background-color: rgba(234, 67, 53, 0.85); 
}

/* Keep shadows on the main element or move to hover */
.social-btn.fb:hover { box-shadow: 0 10px 20px -5px rgba(24, 119, 242, 0.5); }
.social-btn.tt:hover { box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.5); }
.social-btn.ig:hover { box-shadow: 0 10px 20px -5px rgba(220, 39, 67, 0.5); }
.social-btn.wa:hover { box-shadow: 0 10px 20px -5px rgba(37, 211, 102, 0.5); }
.social-btn.em:hover { box-shadow: 0 10px 20px -5px rgba(234, 67, 53, 0.5); }

/* --- FORMULARIO --- */
.form-side {
    flex: 1;
    background: transparent;
    padding: 40px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.form-header {
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    margin-bottom: 25px;
}

/* Logo Móvil vs Emoji Desktop */
.mobile-logo {
    display: none; /* Oculto por defecto (PC) */
    width: 90px;
    height: 90px;
    object-fit: contain;
    margin-bottom: 20px;
    filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
    animation: floatLogo 6s ease-in-out infinite;
    transition: opacity 0.35s ease, transform 0.35s ease;
}

.wave-emoji {
    font-size: 3.5rem;
    display: block;
    margin-bottom: 10px;
    animation: wave 2.5s infinite;
    transform-origin: 70% 70%;
}

.welcome-title {
    font-family: 'Poppins', sans-serif;
    font-size: 2rem;
    font-weight: 700;
    color: var(--brand-dark);
    margin: 0;
    transition: color 0.35s ease, opacity 0.35s ease, transform 0.35s ease;
}

.welcome-desc {
    color: #64748b;
    margin-top: 8px;
    font-size: 0.95rem;
    max-width: 90%;
    transition: opacity 0.35s ease, transform 0.35s ease;
}

.brand-fade-target {
    transition: opacity 0.3s ease, transform 0.3s ease;
}

.main-card.brand-transitioning .brand-fade-target {
    opacity: 0.2;
    transform: translateY(6px);
}

/* Inputs */
.input-group {
    width: 100%;
    max-width: 310px;
    margin-bottom: 15px;
    margin-left: auto;
    margin-right: auto;
}

md-outlined-text-field {
    width: 100%;
    background: rgba(255, 255, 255, 0.8);
}

md-outlined-select {
    width: 100%;
}

.captcha-wrapper {
    margin: 5px auto 20px auto;
    width: 310px;
    display: flex;
    justify-content: center;
}

.btn-wrapper {
    width: 100%;
    max-width: 310px;
    margin: 0 auto;
}

md-filled-button {
    width: 100%;
    height: 52px;
    font-size: 1rem;
    border-radius: 12px;
    --md-filled-button-container-color: var(--brand-purple);
    --md-filled-button-label-text-font: 'Poppins', sans-serif;
}

.error-banner {
    background: #fff1f2;
    border-left: 4px solid #e11d48;
    color: #be123c;
    padding: 10px;
    border-radius: 8px;
    font-size: 0.85rem;
    margin-bottom: 15px;
    max-width: 310px;
    display: flex;
    align-items: center;
    gap: 10px;
}

/* CORREGIDO: @keyframes sin espacios */
@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(40px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes floatLogo { 
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
}

@keyframes wave { 
    0%, 60%, 100% { transform: rotate(0deg); }
    10%, 30% { transform: rotate(14deg); }
    20%, 40% { transform: rotate(-8deg); }
    50% { transform: rotate(10deg); }
}

/* =========================================
   MÓVIL: ESTILO "TARJETA FLOTANTE"
   ========================================= */
@media (max-width: 900px) {
    .main-card {
        width: 90%;
        max-width: 400px;
        height: auto;
        min-height: auto;
        flex-direction: column;
    }
    .visual-side {
        display: none !important;
    }

    .form-side {
        width: 100%;
        padding: 30px 20px;
    }

    .wave-emoji { display: none; }
    .mobile-logo { display: block; }
    
    .welcome-title { font-size: 1.8rem; }

    .captcha-wrapper {
        transform: scale(0.85);
        transform-origin: center;
        margin-bottom: 15px;
    }

    md-outlined-text-field {
        background-color: rgba(255, 255, 255, 0.9);
        border-radius: 14px;
    }

    .input-group, .btn-wrapper, .error-banner {
        max-width: 100%;
    }
}

/* Saved Accounts & Remember Me */
.saved-accounts-container {
    display: none;
    width: 100%;
    flex-direction: column;
    align-items: center;
    animation: fadeIn 0.5s ease;
    margin-bottom: 20px;
}

.account-card {
    display: flex;
    align-items: center;
    width: 100%;
    max-width: 310px;
    /* Match Header User Profile Button */
    background-color: #E8DEF8; /* Lavender / Surface Container High */
    padding: 8px 16px 8px 8px; /* Slightly tighter padding like header btn */
    border-radius: 12px; /* Rounded corners as per card style */
    margin-bottom: 12px;
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
    transition: all 0.2s ease;
    border: 1px solid transparent;
    position: relative;
    user-select: none;
    min-height: 52px;
}

.account-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(124, 58, 237, 0.15);
    background-color: #E2D3F5; /* Slightly darker lavender on hover */
}

/* Header Avatar Style */
.account-avatar {
    width: 36px;
    height: 36px;
    background-color: #E91E63; /* Pink matching header */
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 0.95rem;
    margin-right: 12px;
    flex-shrink: 0;
    text-transform: uppercase;
}

.account-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
}
.account-name {
    font-weight: 700;
    color: #1C1B1F; /* var(--text-primary) */
    font-size: 1rem;
    line-height: 1.2;
}
.account-role {
    display: none; /* User didn't request role, closer match to header */
}

.remove-account {
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    color: #625B71; /* Secondary */
    transition: all 0.2s;
    margin-left: 8px;
}
.remove-account:hover {
    background: #FFD8E4; /* Error Container */
    color: #B3261E; /* Error */
}

.add-account-btn {
    margin-top: 10px;
    color: var(--brand-purple);
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 8px;
    transition: background 0.2s;
    font-size: 0.9rem;
}
.add-account-btn:hover {
    background: #f3e8ff;
}

.remember-me {
    width: 100%;
    max-width: 310px;
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 25px;
    font-size: 0.9rem;
    color: #475569;
}

.back-btn-container {
    width: 100%;
    display: flex;
    justify-content: flex-start;
    padding-bottom: 10px;
}

.back-btn {
    background: none;
    border: none;
    cursor: pointer;
    color: var(--brand-dark);
    font-size: 1.2rem;
    padding: 8px;
    border-radius: 50%;
    transition: background 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
}

.back-btn:hover {
    background-color: rgba(0,0,0,0.05);
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>
</head>
<body>

	<!-- Loading Screen -->
	<jsp:include page="views/shared/loading-screen.jsp" />

	<div id="background-effects"></div>

	<div class="main-card">

		<div class="visual-side">
			<div class="visual-decor">
				<div class="shape shape-1"></div>
				<div class="shape shape-2"></div>
			</div>

			<div class="logo-container">
				<c:set var="idxLogoPath" value="${not empty loginEmpresa && not empty loginEmpresa.logoPath ? loginEmpresa.logoPath : 'logo-peruana.png'}" />
				<c:set var="idxFolder" value="${fn:startsWith(idxLogoPath, 'logo-peruana') || fn:startsWith(idxLogoPath, 'logo-roma') ? 'assets/' : 'uploads/logos/'}" />
				<img src="${idxFolder}${idxLogoPath}" alt="Logo" class="logo-img brand-fade-target" id="loginVisualLogo" loading="eager" fetchpriority="high" decoding="async" onerror="this.onerror=null;this.src='assets/logo-peruana.png';">
			</div>
			<h1 class="brand-title brand-fade-target">${not empty loginEmpresa ? loginEmpresa.nombre : 'La Peruana'}</h1>
			<p class="brand-sub brand-fade-target">Calidad de productos e insumos.</p>

			<div class="social-section">
				<div class="social-icons">
					<a href="https://www.facebook.com/Grupoperuanaa/?locale=es_LA"
						target="_blank" class="social-btn fb" title="Facebook"> <i
						class="fa-brands fa-facebook-f"></i>
					</a> <a href="https://tiktok.com/@la_peruana.tiktok" target="_blank"
						class="social-btn tt" title="TikTok"> <i
						class="fa-brands fa-tiktok"></i>
					</a> <a href="https://instagram.com/la_peruana.ig" target="_blank"
						class="social-btn ig" title="Instagram"> <i
						class="fa-brands fa-instagram"></i>
					</a> <a href="https://whatsapp.com/channel/0029VbAh6DhB4hdPQ0Qmp702"
						target="_blank" class="social-btn wa" title="Canal WhatsApp">
						<i class="fa-brands fa-whatsapp"></i>
					</a> <a href="https://api.whatsapp.com/send?phone=%2B51961907427"
						target="_blank" class="social-btn wa" title="WhatsApp Personal">
						<i class="fa-solid fa-message"></i>
					</a> <a href="mailto:Pedidos@grupoperuana.pe" class="social-btn em"
						title="Correo"> <i class="fa-solid fa-envelope"></i>
					</a>
				</div>
			</div>
		</div>

		<div class="form-side">
			<div class="form-header">
                <div id="back-btn-wrapper" class="back-btn-container" style="display: none;">
                    <button type="button" class="back-btn" onclick="goBack()" title="Regresar">
                        <i class="fa-solid fa-arrow-left"></i>
                    </button>
                </div>

				<img src="${idxFolder}${idxLogoPath}" class="mobile-logo brand-fade-target" loading="eager" decoding="async" onerror="this.onerror=null;this.src='assets/logo-peruana.png';"
					alt="Logo Peruana"> <span class="wave-emoji">👋</span>

				<h2 class="welcome-title brand-fade-target">¡Hola de nuevo!</h2>
				<p class="welcome-desc brand-fade-target">Ingresa tus credenciales para acceder al
					sistema.</p>
			</div>

			<div id="saved-sessions-view" class="saved-accounts-container">
				<!-- JS populate -->
			</div>

			<c:if test="${not empty sessionScope.error}">
				<div class="error-banner">
					<i class="fa-solid fa-circle-exclamation"></i> <span>${sessionScope.error}</span>
				</div>
				<c:remove var="error" scope="session" />
			</c:if>

			<form action="/auth/login" method="post" id="loginForm">
				<input type="hidden" name="accion" value="login">
				<c:if test="${loginEmpresaFija and not empty loginEmpresa}">
					<input type="hidden" name="empresaId" value="${loginEmpresa.id}">
				</c:if>
				<c:if test="${mostrarSelectorEmpresaLogin}">
					<div class="input-group">
						<md-outlined-select id="empresaSelect" label="Empresa (opcional)" name="empresaId">
							<md-select-option value="" selected>
								<div slot="headline">Todas mis empresas</div>
							</md-select-option>
							<c:forEach items="${empresasLogin}" var="empresaLogin">
								<md-select-option value="${empresaLogin.id}">
									<div slot="headline">${empresaLogin.nombre}</div>
								</md-select-option>
							</c:forEach>
						</md-outlined-select>
					</div>
				</c:if>

				<div class="input-group">
					<md-outlined-text-field label="DNI / Usuario" name="dni"
						type="text" required> <md-icon
						slot="leading-icon" class="material-symbols-rounded">person</md-icon>
					</md-outlined-text-field>
				</div>

				<div class="input-group">
					<md-outlined-text-field label="Contraseña" name="password"
						type="password" required> <md-icon
						slot="leading-icon" class="material-symbols-rounded">lock</md-icon>
					</md-outlined-text-field>
				</div>
				<div class="remember-me">
					<md-checkbox name="rememberMe" id="rememberMe" touch-target="wrapper"></md-checkbox>
					<label for="rememberMe" style="cursor: pointer;">Recordarme</label>
				</div>

				<div class="btn-wrapper">
					<md-filled-button type="submit" id="loginBtn"> <span
						id="btnText">Ingresar</span> <md-icon slot="trailing-icon"
						class="material-symbols-rounded">arrow_forward</md-icon> </md-filled-button>
				</div>
			</form>
		</div>
	</div>

	<script>
	// Ejecutar apenas cargue la ventana
    window.onload = function() {
        console.log(
            "%c¡Detente!", 
            "color: #ff0000; font-size: 60px; font-weight: bold; text-shadow: 2px 2px 0px black; font-family: sans-serif;"
        );

        console.log(
            "%cEsta función del navegador está pensada para desarrolladores. Este código pertenece a la Empresa Grupo Peruana, si usted toca algún código no tendrá efectos en el sistema, sino solo en su propio navegador.", 
            "font-size: 16px; padding: 10px; border-radius: 5px; line-height: 1.5; font-family: sans-serif;"
        );
    };

    const container = document.getElementById('background-effects');
    let colorPalettes = [
        'rgba(124, 58, 237, 0.9)',
        'rgba(255, 42, 95, 0.88)',
        'rgba(255, 185, 0, 0.84)',
        'rgba(124, 58, 237, 0.72)'
    ];

    function hexToRgb(hex) {
        const value = (hex || '').replace('#', '').trim();
        if (value.length !== 6) return null;
        return {
            r: parseInt(value.substring(0, 2), 16),
            g: parseInt(value.substring(2, 4), 16),
            b: parseInt(value.substring(4, 6), 16)
        };
    }

    function mixRgb(a, b, weight) {
        const w = Math.max(0, Math.min(1, weight));
        return {
            r: Math.round(a.r + (b.r - a.r) * w),
            g: Math.round(a.g + (b.g - a.g) * w),
            b: Math.round(a.b + (b.b - a.b) * w)
        };
    }

    function buildGlowPalette(primary, secondary) {
        const p = hexToRgb(primary) || { r: 124, g: 58, b: 237 };
        const s = hexToRgb(secondary) || { r: 255, g: 42, b: 95 };
        const blend = mixRgb(p, s, 0.45);
        return [
            `rgba(\${p.r}, \${p.g}, \${p.b}, 0.96)`,
            `rgba(\${s.r}, \${s.g}, \${s.b}, 0.94)`,
            `rgba(\${blend.r}, \${blend.g}, \${blend.b}, 0.9)`,
            `rgba(\${p.r}, \${p.g}, \${p.b}, 0.78)`
        ];
    }

    function animateGlowPalette(primary, secondary) {
        colorPalettes = buildGlowPalette(primary, secondary);
        if (!container) return;

        const blobs = container.querySelectorAll('.glow-blob');
        blobs.forEach((blob, index) => {
            blob.style.transition = 'background-color 850ms ease';
            blob.style.backgroundColor = colorPalettes[index % colorPalettes.length];
        });
    }

    function getSoftBackground(primary) {
        const rgb = hexToRgb(primary);
        if (!rgb) return '#f8fafc';
        return `rgba(\${rgb.r}, \${rgb.g}, \${rgb.b}, 0.06)`;
    }

    const cssVars = getComputedStyle(document.documentElement);
    colorPalettes = buildGlowPalette(
        cssVars.getPropertyValue('--brand-purple').trim() || '#7C3AED',
        cssVars.getPropertyValue('--brand-magenta').trim() || '#FF2A5F'
    );

    let activeBrandLightLogo = '${not empty loginEmpresa && not empty loginEmpresa.logoPath ? loginEmpresa.logoPath : "logo-peruana.png"}';
    let activeBrandDarkLogo = '${not empty loginEmpresa && not empty loginEmpresa.logoPathForDark ? loginEmpresa.logoPathForDark : (not empty loginEmpresa && not empty loginEmpresa.logoPath ? loginEmpresa.logoPath : "logo-peruana-dm.png")}';

    function updateLoginBrandLogos() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        const target = isDark ? activeBrandDarkLogo : activeBrandLightLogo;
        const folder = (target.startsWith('logo-peruana') || target.startsWith('logo-roma')) ? 'assets/' : 'uploads/logos/';

        const visualLogo = document.getElementById('loginVisualLogo');
        const mobileLogo = document.querySelector('.mobile-logo');
        const nextSrc = folder + target;

        if (visualLogo && visualLogo.getAttribute('src') !== nextSrc) visualLogo.src = nextSrc;
        if (mobileLogo && mobileLogo.getAttribute('src') !== nextSrc) mobileLogo.src = nextSrc;

        if (typeof syncLoadingLogoByTheme === 'function') {
            syncLoadingLogoByTheme();
        }
    }
    updateLoginBrandLogos();

    function applyCompanyBrand(empresa) {
        if (!empresa) {
            return;
        }

        const companyName = empresa.nombre || 'La Peruana';
        const primary = empresa.colorPrimario || '#7C3AED';
        const secondary = empresa.colorSecundario || '#FF2A5F';
        const darkLogo = empresa.logoPathForDark || empresa.logoPath || 'logo-peruana-dm.png';
        const lightLogo = empresa.logoPath || 'logo-peruana.png';
        activeBrandLightLogo = lightLogo;
        activeBrandDarkLogo = darkLogo;

        document.documentElement.style.setProperty('--brand-purple', primary);
        document.documentElement.style.setProperty('--brand-magenta', secondary);
        document.documentElement.style.setProperty('--login-bg-base', getSoftBackground(primary));
        animateGlowPalette(primary, secondary);

        updateLoginBrandLogos();

        const title = document.querySelector('.brand-title');
        if (title) {
            title.textContent = companyName;
        }
        document.title = 'Acceso - ' + companyName;

        const themeColorMeta = document.querySelector('meta[name="theme-color"]');
        if (themeColorMeta) {
            themeColorMeta.setAttribute('content', primary);
        }

        const loadingLogo = document.querySelector('.loading-logo');
        if (loadingLogo) {
            loadingLogo.dataset.logoLight = lightLogo;
            loadingLogo.dataset.logoDark = darkLogo;
            const targetFilename = (document.documentElement.getAttribute('data-theme') === 'dark') ? darkLogo : lightLogo;
            const targetFolder = (targetFilename.startsWith('logo-peruana') || targetFilename.startsWith('logo-roma')) ? '/assets/' : '/uploads/logos/';
            loadingLogo.src = '${pageContext.request.contextPath}' + targetFolder + targetFilename;
        }
    }

    let brandTransitionTimer = null;
    function transitionToCompany(empresa) {
        if (!empresa) return;
        const card = document.querySelector('.main-card');
        if (!card) {
            applyCompanyBrand(empresa);
            return;
        }

        card.classList.add('brand-transitioning');
        if (brandTransitionTimer) clearTimeout(brandTransitionTimer);
        brandTransitionTimer = setTimeout(() => {
            applyCompanyBrand(empresa);
            requestAnimationFrame(() => {
                card.classList.remove('brand-transitioning');
            });
        }, 140);
    }

    const loginCompanies = [
        <c:forEach items="${empresasLogin}" var="empresa" varStatus="status">
        {
            id: ${empresa.id},
            nombre: '${fn:escapeXml(empresa.nombre)}',
            colorPrimario: '${not empty empresa.colorPrimario ? empresa.colorPrimario : "#7C3AED"}',
            colorSecundario: '${not empty empresa.colorSecundario ? empresa.colorSecundario : "#FF2A5F"}',
            logoPath: '${not empty empresa.logoPath ? empresa.logoPath : "logo-peruana.png"}',
            logoPathForDark: '${not empty empresa.logoPathForDark ? empresa.logoPathForDark : (not empty empresa.logoPath ? empresa.logoPath : "logo-peruana-dm.png")}'
        }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const defaultLoginBrand = {
        nombre: '${fn:escapeXml(not empty loginEmpresa ? loginEmpresa.nombre : "La Peruana")}',
        colorPrimario: '${not empty loginEmpresa && not empty loginEmpresa.colorPrimario ? loginEmpresa.colorPrimario : "#7C3AED"}',
        colorSecundario: '${not empty loginEmpresa && not empty loginEmpresa.colorSecundario ? loginEmpresa.colorSecundario : "#FF2A5F"}',
        logoPath: '${not empty loginEmpresa && not empty loginEmpresa.logoPath ? loginEmpresa.logoPath : "logo-peruana.png"}',
        logoPathForDark: '${not empty loginEmpresa && not empty loginEmpresa.logoPathForDark ? loginEmpresa.logoPathForDark : (not empty loginEmpresa && not empty loginEmpresa.logoPath ? loginEmpresa.logoPath : "logo-peruana-dm.png")}'
    };

    const selectorEmpresasVisible = ${mostrarSelectorEmpresaLogin ? 'true' : 'false'};
    if (selectorEmpresasVisible && loginCompanies.length > 1) {
        const select = document.getElementById('empresaSelect');
        if (select) {
            if (select.value) {
                const initialSelected = loginCompanies.find(e => String(e.id) === String(select.value));
                if (initialSelected) {
                    applyCompanyBrand(initialSelected);
                }
            }
            select.addEventListener('change', function() {
                if (!this.value) {
                    applyCompanyBrand(defaultLoginBrand);
                    return;
                }
                const selected = loginCompanies.find(e => String(e.id) === String(this.value));
                transitionToCompany(selected);
            });
        }
    }
	
	
        // --- LÓGICA DEL LOGIN ---
        const loginForm = document.getElementById('loginForm');
        
        // Brand Colors for Random Avatars
        const brandColors = [
            '#7C3AED', // Brand Purple
            '#FF2A5F', // Brand Magenta
            '#FFB900', // Brand Yellow
            '#FF9F1C', // Orange
            '#2EC4B6', // Teal
            '#3A86FF'  // Blue
        ];
        
        const getRandomBrandColor = () => {
             return brandColors[Math.floor(Math.random() * brandColors.length)];
        };

        // Saved Sessions Logic
        const savedSessions = JSON.parse(localStorage.getItem('saved_sessions') || '[]');
        const savedView = document.getElementById('saved-sessions-view');
        // Welcome elements
        const welcomeTitle = document.querySelector('.welcome-title');
        const welcomeDesc = document.querySelector('.welcome-desc');
        const backBtnWrapper = document.getElementById('back-btn-wrapper');

        function renderSavedSessions() {
            if (savedSessions.length > 0) {
                // Hide Login Form
                loginForm.style.display = 'none';
                savedView.style.display = 'flex';
                // Hide Back Button explicitly when in selection mode
                backBtnWrapper.style.display = 'none';
                
                welcomeTitle.textContent = "Bienvenido de nuevo";
                welcomeDesc.textContent = "Selecciona una cuenta para ingresar.";
                
                savedView.innerHTML = '';
                
                savedSessions.forEach((user, index) => {
                    const card = document.createElement('div');
                    card.className = 'account-card';
                    card.onclick = (e) => {
                         // Ignore if clicked on remove button (handled by its own listener)
                         if(e.target.closest('.remove-account')) return;
                         selectAccount(user);
                    };
                    
                    // Name Parsing
                    let displayName = 'Usuario';
                    if (user.nombres && user.nombres.trim().length > 0) {
                        const n = user.nombres.trim().split(/\s+/)[0];
                        const a = (user.apellidos && user.apellidos.trim()) ? user.apellidos.trim().split(/\s+/)[0] : '';
                        displayName = n + (a ? ' ' + a : '');
                    }
                    
                    const nInitial = (user.nombres && user.nombres.trim()) ? user.nombres.trim().charAt(0).toUpperCase() : '';
                    const aInitial = (user.apellidos && user.apellidos.trim()) ? user.apellidos.trim().charAt(0).toUpperCase() : '';
                    
                    // Prioritize computed initials over stored 'avatar' which might be stale (single letter)
                    let avatarText = nInitial + aInitial;
                    if (!avatarText) {
                        avatarText = user.avatar || displayName.charAt(0).toUpperCase();
                    }

                    // DOM Creation (Safer and easier to debug)
                    const elAvatar = document.createElement('div');
                    elAvatar.className = 'account-avatar';
                    elAvatar.style.backgroundColor = getRandomBrandColor(); // Random Color
                    elAvatar.textContent = avatarText;
                    
                    const elInfo = document.createElement('div');
                    elInfo.className = 'account-info';
                    
                    const elName = document.createElement('div');
                    elName.className = 'account-name';
                    elName.textContent = displayName;
                    
                    elInfo.appendChild(elName);
                    
                    const elRemove = document.createElement('div');
                    elRemove.className = 'remove-account';
                    elRemove.title = "Eliminar cuenta";
                    elRemove.innerHTML = '<i class="fa-solid fa-xmark"></i>';
                    elRemove.onclick = (e) => {
                        e.stopPropagation();
                        removeAccount(index);
                    };

                    card.appendChild(elAvatar);
                    card.appendChild(elInfo);
                    card.appendChild(elRemove);
                    
                    savedView.appendChild(card);
                });
                
                // Add "Use another account" button
                const addBtn = document.createElement('div');
                addBtn.className = 'add-account-btn';
                addBtn.innerHTML = '<i class="fa-solid fa-plus"></i> Usar otra cuenta';
                addBtn.onclick = showLoginForm;
                savedView.appendChild(addBtn);
                
            } else {
                showLoginForm();
            }
        }

        function selectAccount(user) {
            // Check if we have a saved password for Instant Login
            if (user.password && user.password.trim() !== "") {
                // IMPORTANT: Save auth intent BEFORE submit to preserve remember state
                sessionStorage.setItem('pending_auth', JSON.stringify({
                    dni: user.dni,
                    password: user.password,
                    remember: true // If we have a password, it implies we want to keep remembering
                }));
                
                // Populate inputs before submitting!
                document.querySelector('md-outlined-text-field[name="dni"]').value = user.dni;
                document.querySelector('md-outlined-text-field[name="password"]').value = user.password;
                
                // Auto submit the form directly (bypass JS submit handler)
                loginForm.submit(); 
                return;
            }


            // Normal flow: Show form and ask for password
            showLoginForm();
            
            const dniInput = document.querySelector('md-outlined-text-field[name="dni"]');
            const passInput = document.querySelector('md-outlined-text-field[name="password"]');
            
            // Set value for MD component
            dniInput.value = user.dni;
            
            // Highlight connection
            welcomeTitle.textContent = "Hola, " + user.nombres.split(' ')[0];
            welcomeDesc.textContent = "Por favor, confirma tu contraseña.";
            
            // Focus password
            setTimeout(() => {
                passInput.focus();
            }, 300);
        }

        window.removeAccount = function(index) {
            savedSessions.splice(index, 1);
            localStorage.setItem('saved_sessions', JSON.stringify(savedSessions));
            // Re-render
            const savedView2 = document.getElementById('saved-sessions-view');
            // If empty, force login form
            if (savedSessions.length === 0) {
                savedView2.style.display = 'none'; // hide immediately
                showLoginForm();
                return;
            }
            renderSavedSessions();
        };

        function showLoginForm() {
            savedView.style.display = 'none';
            loginForm.style.display = 'block';
            
            // Animate form appearance
            loginForm.style.animation = 'fadeIn 0.4s ease';
            
            // Default texts if we are not selecting a specific user (checked by logic or simply reset everywhere)
            // If we coming from "Usar otra cuenta", we want standard text.
            // If coming from selectAccount, we override it there.
            // But showLoginForm is called by "Usar otra cuenta" directly.
            // Let's rely on selectAccount overriding it AFTER calling showLoginForm.
             if (savedSessions.length === 0 || window.event?.currentTarget?.className === 'add-account-btn') {
                 welcomeTitle.textContent = "¡Hola de nuevo!";
                 welcomeDesc.textContent = "Ingresa tus credenciales para acceder al sistema.";
                 // Clear inputs if "Use another"
                 document.querySelector('md-outlined-text-field[name="dni"]').value = '';
                 document.querySelector('md-outlined-text-field[name="password"]').value = '';
            }
             
            // Show Back button if we have saved sessions
            if (savedSessions.length > 0) {
                backBtnWrapper.style.display = 'flex';
            } else {
                backBtnWrapper.style.display = 'none';
            }
        }
        
        function goBack() {
             loginForm.style.display = 'none';
             renderSavedSessions();
             // Reset form fields
             document.querySelector('md-outlined-text-field[name="dni"]').value = '';
             document.querySelector('md-outlined-text-field[name="password"]').value = '';
        }


        // Init
        window.addEventListener('load', renderSavedSessions);


        const loginBtn = document.getElementById('loginBtn');
        const btnText = document.getElementById('btnText');

        loginForm.addEventListener('submit', () => {
            const rememberMe = document.getElementById('rememberMe').checked;
            const dniVal = document.querySelector('md-outlined-text-field[name="dni"]').value;
            const passVal = document.querySelector('md-outlined-text-field[name="password"]').value;
            
            // Save intention to sessionStorage (bridge to dashboard)
            // We always save this so the dashboard knows what to do (save with or without password)
            sessionStorage.setItem('pending_auth', JSON.stringify({
                dni: dniVal,
                password: passVal,
                remember: rememberMe
            }));
            
            loginBtn.disabled = true;
            // Usamos comillas simples para evitar conflicto con JSP
            btnText.innerHTML = '<md-circular-progress indeterminate density="-4" style="--md-circular-progress-size: 20px; --md-circular-progress-active-indicator-color: white; margin-right:8px;"></md-circular-progress> Verificando...';
        });

        // --- NUEVO EFECTO DE LUCES DE FONDO ---

        function randomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1) + min);
        }

        function clamp(value, min, max) {
            return Math.max(min, Math.min(max, value));
        }

        const loopGlowAnchors = [
            { x: 0.12, y: 0.18 },
            { x: 0.84, y: 0.2 },
            { x: 0.2, y: 0.78 },
            { x: 0.8, y: 0.74 },
            { x: 0.5, y: 0.52 }
        ];

        function placeLoopGlow(blob, anchor) {
            const minSize = Math.max(220, Math.round(window.innerWidth * 0.2));
            const maxSize = Math.max(minSize + 40, Math.round(window.innerWidth * 0.44));
            const size = randomInt(minSize, maxSize);

            const centerX = window.innerWidth * anchor.x + randomInt(-130, 130);
            const centerY = window.innerHeight * anchor.y + randomInt(-95, 95);
            const left = clamp(centerX - size / 2, -size * 0.2, window.innerWidth - size * 0.8);
            const top = clamp(centerY - size / 2, -size * 0.2, window.innerHeight - size * 0.8);

            blob.style.width = size + 'px';
            blob.style.height = size + 'px';
            blob.style.left = left + 'px';
            blob.style.top = top + 'px';
            blob.style.setProperty('--move-x', randomInt(-200, 200) + 'px');
            blob.style.setProperty('--move-y', randomInt(-180, 180) + 'px');
            blob.style.setProperty('--glow-duration', randomInt(11200, 16800) + 'ms');
            blob.style.animationDelay = randomInt(-15000, -700) + 'ms';
        }

        function initLoopGlows() {
            if (!container || !colorPalettes || colorPalettes.length === 0) return;
            container.querySelectorAll('.glow-loop').forEach((el) => el.remove());

            loopGlowAnchors.forEach((anchor, index) => {
                const blob = document.createElement('div');
                blob.classList.add('glow-blob', 'glow-loop');
                blob.style.backgroundColor = colorPalettes[index % colorPalettes.length];
                placeLoopGlow(blob, anchor);
                container.appendChild(blob);
            });
        }

        function createGlow() {
            if (!container || !colorPalettes || colorPalettes.length === 0) return;
            const blob = document.createElement('div');
            blob.classList.add('glow-blob');

            // Tamaño aleatorio
            const size = randomInt(window.innerWidth * 0.22, window.innerWidth * 0.58);
            
            // Concatenacion con '+' para que JSP no busque variables
            blob.style.width = size + 'px';
            blob.style.height = size + 'px';

            blob.style.left = randomInt(-size/2, window.innerWidth - size/2) + 'px';
            blob.style.top = randomInt(-size/2, window.innerHeight - size/2) + 'px';

            blob.style.backgroundColor = colorPalettes[randomInt(0, colorPalettes.length - 1)];
            blob.style.setProperty('--glow-duration', randomInt(9800, 13600) + 'ms');
            
            // Variables CSS para movimiento
            blob.style.setProperty('--move-x', randomInt(-240, 240) + 'px');
            blob.style.setProperty('--move-y', randomInt(-220, 220) + 'px');

            container.appendChild(blob);

            // Limpieza
            setTimeout(() => {
                blob.remove();
            }, 11500); 
        }

        // Iniciar efecto
        initLoopGlows();
        createGlow();
        createGlow();
        createGlow();
        createGlow();
        createGlow();
        createGlow();
        setInterval(createGlow, 850);

        let glowResizeTimer = null;
        window.addEventListener('resize', () => {
            if (glowResizeTimer) clearTimeout(glowResizeTimer);
            glowResizeTimer = setTimeout(initLoopGlows, 220);
        });
    </script>

    <!-- Global Image Loader -->
    <jsp:include page="views/shared/image-loader.jsp" />
</body>
</html>
