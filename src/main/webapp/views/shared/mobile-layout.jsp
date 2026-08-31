<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    String currentPath = (String) request.getAttribute("jakarta.servlet.forward.servlet_path");
    if (currentPath == null) {
        currentPath = request.getServletPath();
    }
    
    boolean isDashboard = currentPath.contains("/empleado") && !currentPath.contains("/escanear") && !currentPath.contains("/historial");
    boolean isEscanear = currentPath.contains("/escanear");
    boolean isHistorial = currentPath.contains("/historial") || currentPath.contains("/asistencias");
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">

<style>
/* ========================================
   MOBILE LAYOUT - Premium MD3 Design
   ======================================== */

:root {
    /* Premium Color Palette */
    --mobile-primary: #EC407A;
    --mobile-primary-soft: rgba(236, 64, 122, 0.12);
    --mobile-primary-container: #FCE4EC;
    --mobile-on-primary: #FFFFFF;
    --mobile-gradient-start: #FF6B9D;
    --mobile-gradient-end: #C7396D;
    
    /* Surface Colors */
    --mobile-surface: #FFFFFF;
    --mobile-surface-container: #F8F9FA;
    --mobile-background: linear-gradient(180deg, #FFF5F8 0%, #FFFFFF 100%);
    
    /* Text */
    --mobile-text-primary: #1C1B1F;
    --mobile-text-secondary: #49454F;
    
    /* Navbar */
    --navbar-height: 64px;
    --navbar-safe-area: env(safe-area-inset-bottom, 0px);
    
    /* Animation */
    --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
    --ease-smooth: cubic-bezier(0.25, 0.8, 0.25, 1);
}

/* Dark Mode */
[data-theme="dark"] {
    --mobile-surface: #1E1E1E;
    --mobile-surface-container: #2C2C2C;
    --mobile-background: linear-gradient(180deg, #1A1A1A 0%, #121212 100%);
    --mobile-text-primary: #E6E1E5;
    --mobile-text-secondary: #CAC4D0;
    --mobile-primary-soft: rgba(236, 64, 122, 0.2);
    --mobile-primary-container: rgba(236, 64, 122, 0.15);
}

/* ===== BODY RESET ===== */
body.mobile-layout {
    margin: 0;
    padding: 0;
    font-family: 'Outfit', sans-serif;
    background: var(--mobile-background);
    min-height: 100vh;
    padding-bottom: calc(var(--navbar-height) + var(--navbar-safe-area) + 16px);
    -webkit-font-smoothing: antialiased;
}

/* ===== MOBILE HEADER ===== */
.mobile-header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: var(--mobile-surface);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(0,0,0,0.06);
    padding: 12px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

[data-theme="dark"] .mobile-header {
    background: rgba(30, 30, 30, 0.95);
    border-bottom-color: rgba(255,255,255,0.08);
}

.mobile-header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}

.mobile-header-logo {
    height: 36px;
    width: auto;
}

.mobile-header-time {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
}

.mobile-time-display {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--mobile-primary);
    line-height: 1;
    letter-spacing: -0.5px;
}

.mobile-date-display {
    font-size: 0.75rem;
    color: var(--mobile-text-secondary);
    text-transform: capitalize;
}

.mobile-header-actions {
    display: flex;
    align-items: center;
    gap: 8px;
}

.mobile-icon-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    cursor: pointer;
    color: var(--mobile-text-secondary);
    transition: all 0.2s var(--ease-smooth);
    position: relative;
}

.mobile-icon-btn:active {
    transform: scale(0.92);
    background: var(--mobile-primary-soft);
}

.mobile-icon-btn .material-symbols-rounded {
    font-size: 24px;
}

.mobile-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--mobile-primary) 0%, #AB47BC 100%);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 0.95rem;
    text-transform: uppercase;
    box-shadow: 0 4px 12px rgba(236, 64, 122, 0.3);
}

/* ===== MOBILE CONTENT ===== */
.mobile-content {
    padding: 16px 20px;
    max-width: 600px;
    margin: 0 auto;
    animation: fadeInUp 0.5s var(--ease-smooth);
}

@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

/* ===== BOTTOM NAVBAR ===== */
.bottom-navbar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: calc(var(--navbar-height) + var(--navbar-safe-area));
    background: var(--mobile-surface);
    border-top: 1px solid rgba(0,0,0,0.06);
    display: flex;
    align-items: flex-start;
    justify-content: space-around;
    padding-top: 8px;
    padding-bottom: var(--navbar-safe-area);
    z-index: 1000;
    box-shadow: 0 -4px 20px rgba(0,0,0,0.06);
}

[data-theme="dark"] .bottom-navbar {
    background: var(--mobile-surface);
    border-top-color: rgba(255,255,255,0.08);
    box-shadow: 0 -4px 20px rgba(0,0,0,0.3);
}

.nav-tab {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    text-decoration: none;
    color: var(--mobile-text-secondary);
    font-size: 0.7rem;
    font-weight: 500;
    padding: 4px 16px;
    border-radius: 16px;
    transition: all 0.3s var(--ease-spring);
    position: relative;
}

.nav-tab .material-symbols-rounded {
    font-size: 26px;
    transition: transform 0.3s var(--ease-spring);
}

.nav-tab.active {
    color: var(--mobile-primary);
}

.nav-tab.active .material-symbols-rounded {
    transform: scale(1.1);
    font-variation-settings: 'FILL' 1;
}

/* Active indicator pill */
.nav-tab.active::before {
    content: '';
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 48px;
    height: 32px;
    background: var(--mobile-primary-soft);
    border-radius: 16px;
    z-index: -1;
    animation: pillExpand 0.3s var(--ease-spring);
}

@keyframes pillExpand {
    from { width: 32px; opacity: 0; }
    to { width: 48px; opacity: 1; }
}

.nav-tab:active {
    transform: scale(0.92);
}

/* Ripple effect */
.nav-tab::after {
    content: '';
    position: absolute;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle, var(--mobile-primary-soft) 0%, transparent 70%);
    opacity: 0;
    transform: scale(0);
    transition: transform 0.4s, opacity 0.4s;
    pointer-events: none;
}

.nav-tab:active::after {
    opacity: 1;
    transform: scale(2);
}

/* ===== PROFILE DROPDOWN ===== */
.mobile-profile-dropdown {
    position: fixed;
    top: 60px;
    right: 16px;
    width: 240px;
    background: #D81B60; /* Admin Pink Theme */
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.15);
    padding: 8px;
    z-index: 2000;
    display: none;
    animation: dropdownSlide 0.3s var(--ease-spring);
}

[data-theme="dark"] .mobile-profile-dropdown {
    background: #C2185B; /* Darker Pink for Dark Mode */
    box-shadow: 0 8px 32px rgba(0,0,0,0.4);
}

.mobile-profile-dropdown.show {
    display: block;
}

@keyframes dropdownSlide {
    from { opacity: 0; transform: translateY(-10px) scale(0.95); }
    to { opacity: 1; transform: translateY(0) scale(1); }
}

.dropdown-profile-header {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    border-bottom: 1px solid rgba(255,255,255,0.2);
    margin-bottom: 8px;
}

[data-theme="dark"] .dropdown-profile-header {
    border-bottom-color: rgba(255,255,255,0.2);
}

.dropdown-profile-header .mobile-avatar {
    width: 48px;
    height: 48px;
    font-size: 1.1rem;
}

.dropdown-profile-info {
    flex: 1;
}

.dropdown-profile-name {
    font-weight: 600;
    color: #FFFFFF;
    font-size: 0.95rem;
}

.dropdown-profile-role {
    font-size: 0.75rem;
    color: rgba(255,255,255,0.8);
}

.dropdown-menu-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    border-radius: 12px;
    color: #FFFFFF;
    font-size: 0.9rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    text-decoration: none;
    border: 1px solid transparent;
}

.dropdown-menu-item:hover {
    background: rgba(255,255,255,0.1);
    border-color: rgba(255,255,255,0.2);
}

.dropdown-menu-item .material-symbols-rounded {
    font-size: 22px;
    color: rgba(255,255,255,0.9);
}

.dropdown-menu-item.danger {
    color: #E53935;
}

.dropdown-menu-item.danger .material-symbols-rounded {
    color: #E53935;
}

/* Theme toggle in dropdown */
.theme-toggle-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px;
    border-radius: 12px;
}

.theme-toggle-row:hover {
    background: var(--mobile-primary-soft);
}

.theme-toggle-left {
    display: flex;
    align-items: center;
    gap: 12px;
    color: #FFFFFF;
    font-size: 0.9rem;
    font-weight: 500;
}

.theme-toggle-left .material-symbols-rounded {
    font-size: 22px;
    color: rgba(255,255,255,0.9);
}

/* Toggle Switch */
.mobile-toggle {
    width: 44px;
    height: 24px;
    background: #E0E0E0;
    border-radius: 12px;
    position: relative;
    cursor: pointer;
    transition: background 0.3s;
}

[data-theme="dark"] .mobile-toggle {
    background: #555;
}

.mobile-toggle.active {
    background: var(--mobile-primary);
}

.mobile-toggle::after {
    content: '';
    position: absolute;
    top: 2px;
    left: 2px;
    width: 20px;
    height: 20px;
    background: white;
    border-radius: 50%;
    transition: transform 0.3s var(--ease-spring);
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.mobile-toggle.active::after {
    transform: translateX(20px);
}

/* Overlay */
.mobile-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.3);
    z-index: 1500;
    display: none;
}

.mobile-overlay.show {
    display: block;
}
</style>

<!-- Mobile Header -->
<header class="mobile-header">
    <div class="mobile-header-left">
        <img src="${pageContext.request.contextPath}/assets/logo-peruana-icon.png" alt="GP" class="mobile-header-logo">
    </div>
    
    <div class="mobile-header-time">
        <div class="mobile-time-display" id="mobileTimeDisplay">00:00</div>
        <div class="mobile-date-display" id="mobileDateDisplay">---</div>
    </div>
    
    <div class="mobile-header-actions">
        <button class="mobile-icon-btn" onclick="toggleMobileNotifications()">
            <span class="material-symbols-rounded">notifications</span>
        </button>
        <div class="mobile-avatar" onclick="toggleMobileProfile()">
            <c:set var="initials" value="${not empty sessionScope.usuario.nombres ? sessionScope.usuario.nombres.substring(0,1) : 'U'}${not empty sessionScope.usuario.apellidos ? sessionScope.usuario.apellidos.substring(0,1) : ''}" />
            ${initials}
        </div>
    </div>
</header>

<!-- Profile Dropdown -->
<div class="mobile-overlay" id="mobileOverlay" onclick="closeMobileDropdowns()"></div>
<div class="mobile-profile-dropdown" id="mobileProfileDropdown">
    <div class="dropdown-profile-header">
        <div class="mobile-avatar">
            ${initials}
        </div>
        <div class="dropdown-profile-info">
            <div class="dropdown-profile-name">${sessionScope.usuario.nombres} ${sessionScope.usuario.apellidos}</div>
            <div class="dropdown-profile-role">Empleado</div>
        </div>
    </div>
    
    <div class="theme-toggle-row" onclick="toggleMobileTheme(event)">
        <div class="theme-toggle-left">
            <span class="material-symbols-rounded">dark_mode</span>
            <span>Tema Oscuro</span>
        </div>
        <div class="mobile-toggle" id="mobileThemeToggle"></div>
    </div>
    
    <a href="${pageContext.request.contextPath}/auth/logout" class="dropdown-menu-item danger">
        <span class="material-symbols-rounded">logout</span>
        <span>Cerrar Sesión</span>
    </a>
</div>

<!-- Bottom Navigation Bar -->
<nav class="bottom-navbar">
    <a href="${pageContext.request.contextPath}/empleado" class="nav-tab <%= isDashboard ? "active" : "" %>">
        <span class="material-symbols-rounded">home</span>
        <span>Inicio</span>
    </a>
    <a href="${pageContext.request.contextPath}/empleado/escanear" class="nav-tab <%= isEscanear ? "active" : "" %>">
        <span class="material-symbols-rounded">qr_code_scanner</span>
        <span>Escanear</span>
    </a>
    <a href="${pageContext.request.contextPath}/asistencias?rol=empleado" class="nav-tab <%= isHistorial ? "active" : "" %>">
        <span class="material-symbols-rounded">history</span>
        <span>Historial</span>
    </a>
    <a href="${pageContext.request.contextPath}/justificaciones" class="nav-tab">
        <span class="material-symbols-rounded">event_busy</span>
        <span>Justificar</span>
    </a>
</nav>

<script>
// Clock Update
function updateMobileClock() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit' });
    const dateStr = now.toLocaleDateString('es-PE', { weekday: 'short', day: 'numeric', month: 'short' });
    
    const timeEl = document.getElementById('mobileTimeDisplay');
    const dateEl = document.getElementById('mobileDateDisplay');
    
    if (timeEl) timeEl.textContent = timeStr;
    if (dateEl) dateEl.textContent = dateStr;
}

updateMobileClock();
setInterval(updateMobileClock, 1000);

// Profile Dropdown
function toggleMobileProfile() {
    const dropdown = document.getElementById('mobileProfileDropdown');
    const overlay = document.getElementById('mobileOverlay');
    
    dropdown.classList.toggle('show');
    overlay.classList.toggle('show');
}

function closeMobileDropdowns() {
    document.getElementById('mobileProfileDropdown').classList.remove('show');
    document.getElementById('mobileOverlay').classList.remove('show');
}

function toggleMobileNotifications() {
    // Placeholder for notifications
    console.log('Notifications clicked');
}

// Theme Toggle
function toggleMobileTheme(e) {
    if (e) e.stopPropagation();
    
    const toggle = document.getElementById('mobileThemeToggle');
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    
    if (isDark) {
        document.documentElement.removeAttribute('data-theme');
        localStorage.setItem('theme', 'light');
        toggle.classList.remove('active');
    } else {
        document.documentElement.setAttribute('data-theme', 'dark');
        localStorage.setItem('theme', 'dark');
        toggle.classList.add('active');
    }
}

// Initialize theme state
(function initMobileTheme() {
    const savedTheme = localStorage.getItem('theme');
    const toggle = document.getElementById('mobileThemeToggle');
    
    if (savedTheme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        if (toggle) toggle.classList.add('active');
    }
})();

// Add mobile-layout class to body
document.body.classList.add('mobile-layout');
</script>
