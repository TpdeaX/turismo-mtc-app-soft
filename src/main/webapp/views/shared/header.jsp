<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
<style>
    /* Header Styles */
    .app-header {
        height: 64px;
        background-color: var(--bg-header);
        display: flex;
        align-items: center;
        padding: 0 24px;
        border-bottom: 1px solid var(--border-color);
        position: sticky;
        top: 0;
        z-index: 1100;
        justify-content: space-between;
        transition: padding 0.3s, background-color 0.3s, border-color 0.3s;
    }

    .header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .header-logo-container {
        display: flex; /* Changed from 'none' to flex, controlled by body class */
        align-items: center;
        gap: 12px;
        opacity: 0;
        width: 0;
        overflow: hidden;
        transition: opacity 0.3s ease, width 0.3s ease;
        pointer-events: none;
    }

    /* Show logo when sidebar is NOT pinned */
    html:not(.sidebar-pinned) .header-logo-container {
        opacity: 1;
        width: auto;
        pointer-events: auto;
        margin-left: 8px;
    }

    /* Hide menu button in header when sidebar is Pinned */
    html.sidebar-pinned .header-menu-toggle {
        display: none !important;
    }

    .header-logo {
        height: 80px;
        width: auto;
    }

    .header-title-text {
        font-size: 1.1rem;
        font-weight: 500;
        color: var(--text-primary);
        margin: 0;
        display: flex;
        flex-direction: column;
        line-height: 1.2;
    }
    
    .header-subtitle {
        font-size: 0.75rem;
        color: var(--text-secondary);
    }

    /* Right Side Actions */
    .header-actions {
        display: flex;
        align-items: center;
        gap: 8px;
        height: 100%;
    }

    .company-switcher-wrap {
        position: relative;
        margin-right: 8px;
    }

    .company-switcher-btn {
        height: 36px;
        padding: 0 10px;
        border-radius: 10px;
        border: 1px solid transparent;
        background: transparent;
        color: var(--text-primary);
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        font-weight: 600;
        font-size: 0.9rem;
        transition: background-color 0.2s ease, border-color 0.2s ease;
    }

    .company-switcher-btn:hover {
        background: var(--bg-hover);
        border-color: var(--md-sys-color-outline-variant);
    }

    .company-switcher-label {
        max-width: 128px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        text-align: left;
    }

    .company-switcher-btn .arrow {
        font-size: 20px;
        transition: transform 0.2s ease;
    }

    .company-switcher-wrap.open .company-switcher-btn .arrow {
        transform: rotate(180deg);
    }

    .company-switcher-menu {
        position: absolute;
        top: 42px;
        right: 0;
        min-width: 220px;
        padding: 6px;
        border-radius: 12px;
        border: 1px solid var(--md-sys-color-outline-variant);
        background: var(--md-sys-color-surface-container-high);
        box-shadow: 0 12px 24px rgba(0,0,0,0.22);
        display: none;
        z-index: 1150;
    }

    .company-switcher-wrap.open .company-switcher-menu {
        display: block;
        animation: companyMenuIn 0.18s ease-out;
    }

    @keyframes companyMenuIn {
        from { opacity: 0; transform: translateY(-4px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .company-switcher-item {
        width: 100%;
        border: none;
        background: transparent;
        color: var(--text-primary);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 9px 10px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 0.9rem;
        text-align: left;
    }

    .company-switcher-item:hover {
        background: var(--bg-hover);
    }

    .company-switcher-item.active {
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        font-weight: 700;
    }

    .company-switcher-item.active::after {
        content: "done";
        font-family: 'Material Symbols Outlined';
        font-size: 16px;
    }

    [data-theme="dark"] .company-switcher-menu {
        background: #2C2C2C;
        border-color: rgba(255,255,255,0.12);
    }

    .icon-btn {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        cursor: pointer;
        color: var(--icon-color);
        position: relative;
        transition: background-color 0.2s, color 0.3s;
    }

    .icon-btn:hover {
        background-color: var(--bg-hover);
    }
    
    .notification-badge {
        position: absolute;
        top: 8px;
        right: 8px;
        width: 8px;
        height: 8px;
        background-color: #B3261E; /* Error/Notification red */
        border-radius: 50%;
        border: 2px solid #FFFFFF;
    }
    
    /* User Profile */
    .user-profile-container {
         position: relative;
         margin-left: 8px;
         height: 100%;
         display: flex;
         align-items: center;
     }

    .user-profile-btn {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 0 16px 0 12px;
        border-radius: 0; /* Full height requires 0 radius at edges usually, or simpler look */
        cursor: pointer;
        transition: all 0.2s;
        border: none; /* No border */
        background-color: var(--md-sys-color-surface-container-high); /* Light mode default */
        height: 100%;
        min-width: 220px;
        justify-content: space-between;
    }

    .user-profile-btn:hover, .user-profile-btn.active {
        background-color: var(--bg-hover); /* Slightly darker indigo on hover */
    }

    /* Dark Mode Override for Super Admin / User Profile - Lighter than header (#1E1E1E) */
    [data-theme="dark"] .user-profile-btn {
        background-color: #2C2C2C; /* Distinctly lighter/greyer than header */
        border: 1px solid rgba(255,255,255,0.1); /* Subtle border for definition */
    }
    
    [data-theme="dark"] .user-profile-btn:hover {
        background-color: #383838;
    }

    .user-avatar {
        width: 36px;
        height: 36px;
        background-color: #E91E63; /* Pink matching the reference avatar */
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 0.95rem;
        text-transform: uppercase;
        flex-shrink: 0;
    }

    .user-info {
        display: flex;
        flex-direction: column;
        text-align: left;
        margin-right: auto; /* Push arrow to right */
        margin-left: 8px;
    }
    
    .user-name {
        font-weight: 700; /* Bolder */
        font-size: 1rem; /* Larger */
        color: var(--text-primary);
        line-height: normal;
    }

    /* Dropdown - Pink Theme */
    .header-dropdown {
        position: absolute;
        top: 100%;
        right: 0;
        left: 0; /* Full width of container */
        margin-top: 4px;
        background-color: #D81B60; /* Pink background */
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        width: 100%; /* Match container width EXACTLY */
        min-width: auto; /* Remove fixed min-width to respect container */
        display: none;
        flex-direction: column;
        z-index: -1; /* Behind header */
        overflow: hidden;
        transform-origin: top center;
        animation: slideDown 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; /* Smooth cubic-bezier */
        padding: 8px;
        border: 1px solid #C2185B;
        box-sizing: border-box; /* padding included in width */
    }
    
    @keyframes slideDown {
        from { opacity: 0; transform: translateY(-100%); }
        to { opacity: 1; transform: translateY(0); }
    }

    .header-dropdown.show {
        display: flex;
    }
    
    .header-dropdown.closing {
        display: flex; /* Keep it visible during closing animation */
        animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    
    @keyframes slideUp {
        from { opacity: 1; transform: translateY(0); }
        to { opacity: 0; transform: translateY(-100%); }
    }

    .dropdown-body {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .dropdown-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px 12px;
        cursor: pointer;
        color: #FFFFFF; /* White text */
        font-size: 0.9rem;
        font-weight: 500;
        text-decoration: none;
        border-radius: 6px;
        border: 1px solid rgba(255,255,255,0.4); /* White border outline style */
        transition: background 0.2s;
    }
    
    .dropdown-item.action-logout {
         border: none;
         margin-top: 4px;
         justify-content: flex-start;
         gap: 12px;
         background-color: rgba(0,0,0,0.1); /* Slight darker for separation? Or just transparent */
         background-color: transparent;
    }
    
    .dropdown-item:hover {
        background-color: rgba(255, 255, 255, 0.15);
    }
    
    /* Toggle Switch Style - Updated for Pink Theme */
    .toggle-switch {
        position: relative;
        width: 36px;
        height: 20px;
    }
    
    .toggle-switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(255,255,255,0.3);
        transition: .4s;
        border-radius: 34px;
    }
    
    .slider:before {
        position: absolute;
        content: "";
        height: 14px;
        width: 14px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }
    
    input:checked + .slider {
        background-color: #FFFFFF; /* When checked, knob becomes pink, track white? Reverse */
        background-color: rgba(255,255,255, 0.8);
    }
    
    input:checked + .slider:before {
        transform: translateX(16px);
        background-color: var(--dynamic-brand-color, #E91E63); /* Dynamic color with Pink fallback */
    }
    
    /* Arrow Rotation */
    .user-profile-btn .arrow-icon {
        transition: transform 0.3s ease;
    }
    
    .user-profile-btn.active .arrow-icon {
        transform: rotate(180deg);
    }

</style>

<header class="app-header">
    <div class="header-left">
        <div class="icon-btn header-menu-toggle" onclick="window.toggleSidebarGlobal()">
            <span class="material-symbols-outlined">menu</span>
        </div>
        
        <!-- Logo Container (controlled by CSS) -->
        <div class="header-logo-container">
            <img src="${pageContext.request.contextPath}/assets/${not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana.png'}"
                 data-logo-light="${not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana.png'}"
                 data-logo-dark="${not empty sessionScope.empresaActiva.logoPathForDark ? sessionScope.empresaActiva.logoPathForDark : (not empty sessionScope.empresaActiva.logoPath ? sessionScope.empresaActiva.logoPath : 'logo-peruana-dm.png')}"
                 alt="${not empty sessionScope.empresaActiva.nombre ? sessionScope.empresaActiva.nombre : 'Grupo Peruana'}" class="header-logo">
        </div>
    </div>

    <div class="header-actions">
        <c:if test="${(sessionScope.usuario.rol == 'ADMIN' or sessionScope.usuario.rol == 'SUPER_ADMIN') && not empty sessionScope.empresasAdmin && sessionScope.empresasAdmin.size() > 1}">
            <div class="company-switcher-wrap" id="companySwitcherWrap">
                <button type="button" class="company-switcher-btn" onclick="toggleCompanyMenu(event)" aria-label="Cambiar empresa">
                    <span class="material-symbols-outlined" style="font-size:18px;color:var(--text-secondary);">domain</span>
                    <span class="company-switcher-label">
                        <c:choose>
                            <c:when test="${sessionScope.empresaActiva == null}">Todas</c:when>
                            <c:otherwise>${sessionScope.empresaActiva.nombre}</c:otherwise>
                        </c:choose>
                    </span>
                    <span class="material-symbols-outlined arrow">expand_more</span>
                </button>
                <div class="company-switcher-menu" id="companySwitcherMenu">
                    <button type="button"
                            class="company-switcher-item ${sessionScope.empresaActiva == null ? 'active' : ''}"
                            onclick="switchCompanyHeader('-1')">Todas</button>
                    <c:forEach items="${sessionScope.empresasAdmin}" var="emp">
                        <button type="button"
                                class="company-switcher-item ${sessionScope.empresaActiva != null && sessionScope.empresaActiva.id == emp.id ? 'active' : ''}"
                                onclick="switchCompanyHeader('${emp.id}')">${emp.nombre}</button>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Notifications Panel -->
        <jsp:include page="/views/shared/notification-panel.jsp" />
        
        <!-- User Profile -->
        <div class="user-profile-container">
            <!-- Main Button -->
            <div class="user-profile-btn" onclick="toggleHeaderDropdown()">
                <!-- Initials Logic: First char of Nombres + First char of Apellidos -->
                <div class="user-avatar" id="userAvatarHeader">
                   <c:set var="initials" value="${not empty sessionScope.usuario.nombres ? sessionScope.usuario.nombres.substring(0,1) : 'U'}${not empty sessionScope.usuario.apellidos ? sessionScope.usuario.apellidos.substring(0,1) : ''}" />
                   ${initials}
                </div>
                <div class="user-info">
                     <span class="user-name">${sessionScope.usuario.nombres} ${sessionScope.usuario.apellidos}</span>
                </div>
                <span class="material-symbols-outlined arrow-icon" style="font-size: 40px;">arrow_drop_down</span>
            </div>
            
            <!-- Dropdown Menu -->
            <div class="header-dropdown" id="headerDropdown">
                <div class="dropdown-body">
                     <!-- Theme Toggle Item -->
                     <div class="dropdown-item" onclick="handleThemeClick(event)">
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <span class="material-symbols-outlined" style="color: white;">dark_mode</span>
                            <span>Tema Oscuro</span>
                        </div>
                        <label class="toggle-switch">
                            <input type="checkbox" id="themeToggle" onchange="toggleTheme(event)">
                            <span class="slider"></span>
                        </label>
                     </div>
                     
                     <!-- Logout Item -->
                     <a href="${pageContext.request.contextPath}/auth/logout" class="dropdown-item action-logout">
                        <span class="material-symbols-outlined" style="color: white;">logout</span>
                        <span>Salir</span>
                     </a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    // Color Palette for Avatars - La Peruana Brand Colors
    const avatarColors = [
        '#E91E63', // Pink
        '#FF9800', // Orange 
        '#9C27B0'  // Purple
    ];

    function setRandomAvatarColor() {
        // Elements
        const avatar = document.getElementById('userAvatarHeader');
        const dropdown = document.getElementById('headerDropdown');
        
        if(avatar) {
            // Random color
            const randomColor = avatarColors[Math.floor(Math.random() * avatarColors.length)];
            
            // Apply to Avatar
            avatar.style.backgroundColor = randomColor;
            
            // Apply to Dropdown (Background & Border)
            if(dropdown) {
                dropdown.style.backgroundColor = randomColor;
                dropdown.style.borderColor = randomColor; // Or darker? User said "color del fondo ... igual".
            }
            
            // Apply to Slider Knob Active State (Dynamic CSS)
            // Since pseudo-elements can't be set via inline style, we inject a style tag or variables.
            // Converting to CSS variable is best way here.
            document.documentElement.style.setProperty('--dynamic-brand-color', randomColor);
        }
    }
    
    setRandomAvatarColor();

    function toggleHeaderDropdown() {
        const dropdown = document.getElementById('headerDropdown');
        const btn = document.querySelector('.user-profile-btn');
        
        if (dropdown.classList.contains('show')) {
            // Initiate Close Animation
            closeDropdownWithAnimation(dropdown, btn);
        } else {
            // Open
            dropdown.classList.add('show');
            btn.classList.add('active');
            document.addEventListener('click', closeDropdownOutside);
        }
    }
    
    function closeDropdownWithAnimation(dropdown, btn) {
        // Prevent double-firing if already closing
        if (dropdown.classList.contains('closing')) return;
        
        dropdown.classList.add('closing');
        btn.classList.remove('active'); // Remove active state from button immediately or after? Immediately feels snappier.
        
        // Wait for animation end
        dropdown.addEventListener('animationend', function() {
            dropdown.classList.remove('show');
            dropdown.classList.remove('closing');
            document.removeEventListener('click', closeDropdownOutside);
        }, { once: true });
    }
    
    function closeDropdownOutside(event) {
        const dropdown = document.getElementById('headerDropdown');
        const btn = document.querySelector('.user-profile-btn');
        if (!dropdown.contains(event.target) && !btn.contains(event.target)) {
            closeDropdownWithAnimation(dropdown, btn);
        }
    }
    
    function updateLogos(isDark) {
        const headerLogo = document.querySelector('.header-logo');
        if (headerLogo) {
            const light = headerLogo.dataset.logoLight || 'logo-peruana.png';
            const dark = headerLogo.dataset.logoDark || light;
            headerLogo.src = '${pageContext.request.contextPath}/assets/' + (isDark ? dark : light);
        }

        const sidebarLogos = document.querySelectorAll('.sidebar-logo.full-logo');
        sidebarLogos.forEach(logo => {
            const light = logo.dataset.logoLight || 'logo-peruana.png';
            const dark = logo.dataset.logoDark || light;
            logo.src = '${pageContext.request.contextPath}/assets/' + (isDark ? dark : light);
        });

        const sidebarIconLogos = document.querySelectorAll('.sidebar-logo.icon-logo');
        sidebarIconLogos.forEach(logo => {
            const light = logo.dataset.iconLight || 'logo-peruana-icon.png';
            const dark = logo.dataset.iconDark || light;
            logo.src = '${pageContext.request.contextPath}/assets/' + (isDark ? dark : light);
        });
    }

    function toggleCompanyMenu(event) {
        event.stopPropagation();
        const wrap = document.getElementById('companySwitcherWrap');
        if (!wrap) return;
        wrap.classList.toggle('open');
        if (wrap.classList.contains('open')) {
            document.addEventListener('click', closeCompanyMenuOutside);
        } else {
            document.removeEventListener('click', closeCompanyMenuOutside);
        }
    }

    function closeCompanyMenuOutside(event) {
        const wrap = document.getElementById('companySwitcherWrap');
        if (!wrap) return;
        if (!wrap.contains(event.target)) {
            wrap.classList.remove('open');
            document.removeEventListener('click', closeCompanyMenuOutside);
        }
    }

    function switchCompanyHeader(id) {
        const wrap = document.getElementById('companySwitcherWrap');
        if (wrap) wrap.classList.remove('open');
        document.removeEventListener('click', closeCompanyMenuOutside);
        fetch('${pageContext.request.contextPath}/api/session/context/empresa/' + id, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('Error al cambiar de empresa: ' + data.message);
            }
        })
        .catch(() => alert('No se pudo cambiar el contexto de empresa.'));
    }

    // Handler for the DIV click (Text area)
    function handleThemeClick(e) {
        // If clicking the toggle switch (label, slider, input), let native behavior handle it.
        // The input 'change' event will fire toggleTheme().
        if (e.target.closest('.toggle-switch')) {
            return;
        }
        
        // If clicking the text/row, manually toggle
        const checkbox = document.getElementById('themeToggle');
        checkbox.checked = !checkbox.checked;
        checkbox.dispatchEvent(new Event('change'));
    }

    // Main Logic - Called by Input Change
    function toggleTheme(e) {
        // Enable transition for interaction
        document.body.classList.add('theme-transition');
        
        // Remove the class after transition completes
        setTimeout(() => {
            document.body.classList.remove('theme-transition');
        }, 300);
        
        // Get state directly from checkbox
        const checkbox = document.getElementById('themeToggle');
        const isDark = checkbox.checked;
        
        if (isDark) {
            document.documentElement.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
        } else {
            document.documentElement.removeAttribute('data-theme');
            localStorage.setItem('theme', 'light');
        }
        
        updateLogos(isDark);
        if (typeof window.syncLoadingLogoByTheme === 'function') {
            window.syncLoadingLogoByTheme();
        }
    }

    // Initialize Theme
    (function initTheme() {
        const savedTheme = localStorage.getItem('theme');
        const checkbox = document.getElementById('themeToggle');
        const isDark = savedTheme === 'dark';
        
        if (isDark) {
            document.documentElement.setAttribute('data-theme', 'dark');
            if(checkbox) checkbox.checked = true;
        } else {
             document.documentElement.removeAttribute('data-theme');
             if(checkbox) checkbox.checked = false;
        }
        
        // Update logos without transition
        updateLogos(isDark);
        if (typeof window.syncLoadingLogoByTheme === 'function') {
            window.syncLoadingLogoByTheme();
        }
        
        // Remove transition class after a moment to ensure no initial flush
        // though strictly we haven't added it yet. But just to be clean.
        document.body.classList.remove('theme-transition');
    })();
</script>

<jsp:include page="/views/shared/config-vars.jsp" />
<jsp:include page="/views/shared/image-loader.jsp" />
