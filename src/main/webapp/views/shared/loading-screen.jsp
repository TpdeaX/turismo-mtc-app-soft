<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Apply theme immediately to prevent flash -->
<jsp:include page="theme-init.jsp" />

<!-- Resolve paths -->
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="iconPath" value="${not empty sessionScope.empresaActiva.iconPath ? sessionScope.empresaActiva.iconPath : (not empty requestScope.loginEmpresa.iconPath ? requestScope.loginEmpresa.iconPath : 'logo-peruana-icon.png')}" />
<c:set var="iconDarkPath" value="${not empty sessionScope.empresaActiva.iconDarkPath ? sessionScope.empresaActiva.iconDarkPath : (not empty requestScope.loginEmpresa.iconDarkPath ? requestScope.loginEmpresa.iconDarkPath : iconPath)}" />
<c:set var="logoName" value="${not empty sessionScope.empresaActiva.nombre ? sessionScope.empresaActiva.nombre : (not empty requestScope.loginEmpresa.nombre ? requestScope.loginEmpresa.nombre : 'La Peruana')}" />
<c:set var="folderLight" value="${fn:startsWith(iconPath, 'logo-peruana') || fn:startsWith(iconPath, 'logo-roma') ? '/assets/' : '/uploads/logos/'}" />

<!-- Loading Screen Overlay -->
<div id="loading-screen" class="loading-screen">
    <!-- Animated particles -->
    <div class="loading-particles">
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
    </div>
    
    <!-- Main content -->
    <div class="loading-content">
        <!-- Logo container with Ring and Glow -->
        <div class="loading-logo-container">
            <div class="loading-ring"></div>
            <img src="${pageContext.request.contextPath}${folderLight}${iconPath}"
                 data-logo-light="${iconPath}"
                 data-logo-dark="${iconDarkPath}"
                 alt="${logoName}" 
                 class="loading-logo"
                 onerror="console.error('FAILED TO LOAD LOGO (JSP HTML Context). Attempted URL:', this.src, 'ContextPath:', '${pageContext.request.contextPath}');">
            <div class="loading-logo-glow"></div>
            <div class="loading-logo-glow2"></div>
        </div>
        
        <!-- Loading text with dots animation -->
        <div class="loading-text">
            <span>Cargando</span>
            <span class="loading-dots">
                <span>.</span><span>.</span><span>.</span>
            </span>
        </div>
        
        <!-- Progress bar -->
        <div class="loading-progress-container">
            <div class="loading-progress-bar"></div>
            <div class="loading-progress-glow"></div>
        </div>
    </div>
</div>

<style>
/* === LOADING SCREEN STYLES === */
.loading-screen {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    /* Light theme (default) */
    background: linear-gradient(135deg, #FFF0F5 0%, #FCE4EC 50%, #F8BBD9 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 99999;
    opacity: 1;
    visibility: visible;
    overflow: hidden;
    /* Smooth fade transition - 0.8s for very smooth effect */
    transition: opacity 0.8s cubic-bezier(0.4, 0, 0.2, 1), 
                visibility 0.8s cubic-bezier(0.4, 0, 0.2, 1),
                transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Dark theme support */
[data-theme="dark"] .loading-screen {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f0f23 100%);
}

/* Fade out with scale effect */
.loading-screen.fade-out {
    opacity: 0;
    visibility: hidden;
    transform: scale(1.05);
}

.loading-screen.fade-out .loading-content {
    transform: scale(0.9) translateY(-20px);
    opacity: 0;
}

.loading-screen.hidden {
    display: none;
}

.loading-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 32px;
    position: relative;
    z-index: 2;
    transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1), 
                opacity 0.4s ease;
    transform: translateY(-20px);
    /* Entrance animation */
    animation: contentEnter 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

@keyframes contentEnter {
    0% {
        opacity: 0;
        transform: translateY(0) scale(0.8);
    }
    100% {
        opacity: 1;
        transform: translateY(-20px) scale(1);
    }
}

/* === ROTATING RING === */
.loading-ring {
    position: absolute;
    width: 100%;
    height: 100%;
    border: 3px solid transparent;
    border-top-color: #EC407A;
    border-right-color: #BA68C8;
    border-radius: 50%;
    animation: ringRotate 1.5s linear infinite;
    z-index: 5;
}

.loading-ring::before {
    content: '';
    position: absolute;
    top: 5px;
    left: 5px;
    right: 5px;
    bottom: 5px;
    border: 2px dashed rgba(236, 64, 122, 0.3);
    border-radius: 50%;
    animation: ringRotate 3s linear infinite reverse;
}

@keyframes ringRotate {
    to { transform: rotate(360deg); }
}

/* === LOGO CONTAINER === */
.loading-logo-container {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 140px; /* Increased container size */
    height: 140px;
    margin-bottom: 8px;
}

.loading-logo {
    width: 90px;
    max-width: 90px;
    height: auto;
    max-height: 56px;
    object-fit: contain;
    animation: logoFloat 2s ease-in-out infinite;
    filter: drop-shadow(0 8px 24px rgba(236, 64, 122, 0.4));
    position: relative;
    z-index: 3;
}

[data-theme="dark"] .loading-logo {
    filter: drop-shadow(0 8px 32px rgba(236, 64, 122, 0.6));
}

/* Primary glow */
.loading-logo-glow {
    position: absolute;
    width: 100px;
    height: 100px;
    background: radial-gradient(circle, rgba(236, 64, 122, 0.5) 0%, transparent 70%);
    border-radius: 50%;
    animation: glowPulse 2s ease-in-out infinite;
    z-index: 1;
}

/* Secondary glow (larger, delayed) */
.loading-logo-glow2 {
    position: absolute;
    width: 140px;
    height: 140px;
    background: radial-gradient(circle, rgba(186, 104, 200, 0.3) 0%, transparent 70%);
    border-radius: 50%;
    animation: glowPulse 2s ease-in-out infinite 0.5s;
    z-index: 0;
}

[data-theme="dark"] .loading-logo-glow {
    background: radial-gradient(circle, rgba(236, 64, 122, 0.6) 0%, transparent 70%);
}

[data-theme="dark"] .loading-logo-glow2 {
    background: radial-gradient(circle, rgba(186, 104, 200, 0.4) 0%, transparent 70%);
}

/* === LOADING TEXT WITH ANIMATED DOTS === */
.loading-text {
    font-family: 'Outfit', 'Inter', sans-serif;
    font-size: 1.2rem;
    font-weight: 500;
    color: #880E4F;
    letter-spacing: 1px;
    display: flex;
    align-items: center;
}

[data-theme="dark"] .loading-text {
    color: #F8BBD9;
}

.loading-dots span {
    animation: dotBounce 1.4s ease-in-out infinite;
    display: inline-block;
}

.loading-dots span:nth-child(1) { animation-delay: 0s; }
.loading-dots span:nth-child(2) { animation-delay: 0.2s; }
.loading-dots span:nth-child(3) { animation-delay: 0.4s; }

@keyframes dotBounce {
    0%, 60%, 100% { transform: translateY(0); }
    30% { transform: translateY(-6px); }
}

/* === PROGRESS BAR === */
.loading-progress-container {
    width: 220px;
    height: 5px;
    background: rgba(236, 64, 122, 0.15);
    border-radius: 10px;
    overflow: visible;
    position: relative;
}

[data-theme="dark"] .loading-progress-container {
    background: rgba(236, 64, 122, 0.25);
}

.loading-progress-bar {
    height: 100%;
    width: 0%;
    background: linear-gradient(90deg, #EC407A 0%, #BA68C8 50%, #EC407A 100%);
    background-size: 200% 100%;
    border-radius: 10px;
    animation: progressFill 1.8s ease-out forwards, progressShimmer 2s ease-in-out infinite;
    position: relative;
}

.loading-progress-glow {
    position: absolute;
    top: -4px;
    right: 0;
    width: 20px;
    height: 13px;
    background: radial-gradient(ellipse, rgba(236, 64, 122, 0.8) 0%, transparent 70%);
    border-radius: 50%;
    animation: progressGlow 1.8s ease-out forwards;
    opacity: 0;
}

@keyframes progressGlow {
    0% { left: 0; opacity: 0; }
    10% { opacity: 1; }
    100% { left: calc(100% - 10px); opacity: 1; }
}

/* === FLOATING PARTICLES === */
.loading-particles {
    position: absolute;
    width: 100%;
    height: 100%;
    overflow: hidden;
    z-index: 1;
}

.particle {
    position: absolute;
    width: 8px;
    height: 8px;
    background: linear-gradient(135deg, #EC407A, #BA68C8);
    border-radius: 50%;
    opacity: 0.4;
    animation: particleFloat 8s ease-in-out infinite;
}

.particle:nth-child(1) { left: 10%; top: 20%; animation-delay: 0s; animation-duration: 7s; }
.particle:nth-child(2) { left: 20%; top: 80%; animation-delay: -1s; animation-duration: 9s; width: 6px; height: 6px; }
.particle:nth-child(3) { left: 40%; top: 10%; animation-delay: -2s; animation-duration: 6s; width: 10px; height: 10px; }
.particle:nth-child(4) { left: 60%; top: 90%; animation-delay: -3s; animation-duration: 8s; }
.particle:nth-child(5) { left: 80%; top: 30%; animation-delay: -4s; animation-duration: 10s; width: 5px; height: 5px; }
.particle:nth-child(6) { left: 90%; top: 70%; animation-delay: -5s; animation-duration: 7s; width: 12px; height: 12px; }
.particle:nth-child(7) { left: 5%; top: 50%; animation-delay: -6s; animation-duration: 9s; width: 7px; height: 7px; }
.particle:nth-child(8) { left: 75%; top: 50%; animation-delay: -7s; animation-duration: 11s; width: 9px; height: 9px; }

[data-theme="dark"] .particle {
    opacity: 0.5;
}

@keyframes particleFloat {
    0%, 100% {
        transform: translateY(0) translateX(0) rotate(0deg);
        opacity: 0.4;
    }
    25% {
        transform: translateY(-30px) translateX(20px) rotate(90deg);
        opacity: 0.6;
    }
    50% {
        transform: translateY(-60px) translateX(-10px) rotate(180deg);
        opacity: 0.3;
    }
    75% {
        transform: translateY(-30px) translateX(-20px) rotate(270deg);
        opacity: 0.5;
    }
}

/* === MAIN ANIMATIONS === */
@keyframes logoFloat {
    0%, 100% {
        transform: translateY(0) scale(1);
    }
    50% {
        transform: translateY(-10px) scale(1.05);
    }
}

@keyframes glowPulse {
    0%, 100% {
        transform: scale(1);
        opacity: 0.5;
    }
    50% {
        transform: scale(1.3);
        opacity: 1;
    }
}

@keyframes progressFill {
    0% { width: 0%; }
    100% { width: 100%; }
}

@keyframes progressShimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}

/* === DECORATIVE BLOBS === */
.loading-screen::before,
.loading-screen::after {
    content: '';
    position: absolute;
    border-radius: 50%;
    opacity: 0.12;
    animation: blobFloat 8s ease-in-out infinite;
}

.loading-screen::before {
    width: 350px;
    height: 350px;
    background: linear-gradient(135deg, #EC407A 0%, #BA68C8 100%);
    top: -120px;
    right: -120px;
    animation-delay: 0s;
}

.loading-screen::after {
    width: 280px;
    height: 280px;
    background: linear-gradient(135deg, #BA68C8 0%, #FFB74D 100%);
    bottom: -100px;
    left: -100px;
    animation-delay: -4s;
}

[data-theme="dark"] .loading-screen::before,
[data-theme="dark"] .loading-screen::after {
    opacity: 0.18;
}

@keyframes blobFloat {
    0%, 100% {
        transform: translateY(0) rotate(0deg) scale(1);
    }
    33% {
        transform: translateY(-30px) rotate(10deg) scale(1.05);
    }
    66% {
        transform: translateY(20px) rotate(-5deg) scale(0.95);
    }
}

/* === MOBILE RESPONSIVENESS === */
@media (max-width: 600px) {
    .loading-logo {
        width: 50px;
        height: 50px;
    }
    
    .loading-ring {
        width: 120px;
        height: 120px;
    }
    
    .loading-logo-container {
        width: 90px;
        height: 90px;
    }
    
    .loading-logo-glow {
        width: 80px;
        height: 80px;
    }
    
    .loading-logo-glow2 {
        width: 110px;
        height: 110px;
    }
    
    .loading-progress-container {
        width: 160px;
    }
    
    .loading-text {
        font-size: 1rem;
    }
    
    .particle {
        display: none; /* Hide particles on mobile for performance */
    }
}
</style>

<script>
(function() {
    // Loading Screen Manager
    const loadingScreen = document.getElementById('loading-screen');
    const loadingLogo = document.querySelector('.loading-logo');

    function syncLoadingLogoByTheme() {
        if (!loadingLogo) return;
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        const light = loadingLogo.dataset.logoLight;
        const dark = loadingLogo.dataset.logoDark || light;
        
        const targetFilename = isDark ? dark : light;
        let basePath = '${pageContext.request.contextPath}';
        if (targetFilename.startsWith('logo-peruana') || targetFilename.startsWith('logo-roma')) {
            basePath += '/assets/';
        } else {
            basePath += '/uploads/logos/';
        }
        
        // Add onerror to capture detailed logs just in case it fails when dynamic setup runs
        loadingLogo.onerror = function() {
            console.error('FAILED TO LOAD LOGO (JSP JS Context).', 
                '\nAttempted URL:', this.src, 
                '\nPathname:', window.location.pathname,
                '\nContextPath:', '${pageContext.request.contextPath}'
            );
        };
        
        loadingLogo.src = basePath + targetFilename;
    }
    
    // Function to hide loading screen with smooth fade effect
    function hideLoadingScreen() {
        if (loadingScreen && !loadingScreen.classList.contains('fade-out')) {
            loadingScreen.classList.add('fade-out');
            setTimeout(() => {
                loadingScreen.classList.add('hidden');
                loadingScreen.classList.remove('fade-out');
            }, 800); // Longer duration for smoother effect
        }
    }
    
    // Function to show loading screen
    function showLoadingScreen() {
        if (loadingScreen) {
            loadingScreen.classList.remove('hidden');
            loadingScreen.classList.remove('fade-out');
            // Reset progress bar animation
            const progressBar = loadingScreen.querySelector('.loading-progress-bar');
            const progressGlow = loadingScreen.querySelector('.loading-progress-glow');
            if (progressBar) {
                progressBar.style.animation = 'none';
                progressBar.offsetHeight; // Trigger reflow
                progressBar.style.animation = 'progressFill 1.8s ease-out forwards, progressShimmer 2s ease-in-out infinite';
            }
            if (progressGlow) {
                progressGlow.style.animation = 'none';
                progressGlow.offsetHeight;
                progressGlow.style.animation = 'progressGlow 1.8s ease-out forwards';
            }
        }
    }
    
    // Expose functions globally for external use
    window.showLoadingScreen = showLoadingScreen;
    window.hideLoadingScreen = hideLoadingScreen;
    window.syncLoadingLogoByTheme = syncLoadingLogoByTheme;
    
    // Auto-hide when page finishes loading with smooth fade
    window.addEventListener('load', function() {
        syncLoadingLogoByTheme();
        // Wait a bit for content to render, then fade out smoothly
        setTimeout(hideLoadingScreen, 400);
    });

    // Handle bfcache (back-forward cache)
    window.addEventListener('pageshow', function(event) {
        if (event.persisted) {
            hideLoadingScreen();
        }
    });
    
    // Show loading screen when navigating away
    window.addEventListener('beforeunload', function() {
        showLoadingScreen();
    });
    
    // Handle form submissions (only non-AJAX forms)
    document.addEventListener('submit', function(e) {
        const form = e.target;
        if (!form.hasAttribute('data-ajax') && !e.defaultPrevented) {
            showLoadingScreen();
        }
    });
})();
</script>

