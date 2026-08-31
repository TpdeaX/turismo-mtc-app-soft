<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${sessionScope.usuario == null}">
    <c:redirect url="/index.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mi Asistencia | Grupo Peruana</title>

<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">

<style>
/* ========================================
   EMPLOYEE DASHBOARD - Admin-Style Layout
   ======================================== */

body {
    font-family: 'Outfit', sans-serif;
    background-color: var(--md-sys-color-background, #F8F9FA);
    color: var(--md-sys-color-on-background, #1C1B1F);
}

.emp-dashboard {
    padding: 32px 40px;
    max-width: 1200px;
    width: 100%;
    margin: 0 auto;
    box-sizing: border-box;
    animation: empPageEnter 0.6s cubic-bezier(0.25, 0.8, 0.25, 1);
}

@keyframes empPageEnter {
    from { opacity: 0; transform: translateY(16px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes empFadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes empScaleIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}

@keyframes empPulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.05); }
}

@keyframes empFloat {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-8px); }
}

@keyframes empGradientBG {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

/* ===== WELCOME BANNER ===== */
.emp-welcome {
    background: linear-gradient(135deg, #FFF0F5 0%, #FCE4EC 100%);
    border-radius: 24px;
    padding: 36px 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    overflow: hidden;
    margin-bottom: 28px;
    border: 1px solid rgba(255, 255, 255, 0.5);
    box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.05);
    animation: empFadeIn 0.5s ease backwards;
}

.emp-welcome::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -10%;
    width: 280px;
    height: 280px;
    background: radial-gradient(circle, rgba(233,30,99,0.1) 0%, transparent 70%);
    border-radius: 50%;
    animation: empFloat 6s ease-in-out infinite;
}

[data-theme="dark"] .emp-welcome {
    background: linear-gradient(135deg, #300020 0%, #1a0010 100%);
    border-color: rgba(255,255,255,0.1);
}

.emp-welcome-text h1 {
    font-size: 2rem;
    font-weight: 700;
    color: #880E4F;
    margin: 0 0 8px 0;
}

[data-theme="dark"] .emp-welcome-text h1 { color: #F48FB1; }

.emp-welcome-text p {
    color: #AD1457;
    font-size: 1.05rem;
    margin: 0;
}

[data-theme="dark"] .emp-welcome-text p { color: #F8BBD0; }

.emp-clock-badge {
    background: #fff;
    padding: 16px 28px;
    border-radius: 50px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.06);
    z-index: 1;
}

[data-theme="dark"] .emp-clock-badge {
    background: var(--md-sys-color-surface-container-high, #2B2930);
}

.emp-clock-time {
    font-size: 2rem;
    font-weight: 700;
    color: #EC407A;
    line-height: 1;
    letter-spacing: -1px;
}

.emp-clock-date {
    font-size: 0.85rem;
    color: #78909C;
    text-transform: capitalize;
}

[data-theme="dark"] .emp-clock-date { color: #CAC4D0; }

/* ===== SECTION TITLES ===== */
.emp-section-title {
    font-size: 1.15rem;
    font-weight: 600;
    color: var(--md-sys-color-on-surface, #1C1B1F);
    margin: 0 0 16px 0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.emp-section-title .material-symbols-rounded {
    font-size: 22px;
    color: #EC407A;
}

/* ===== SHIFT CARDS ===== */
.emp-shifts {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 32px;
}

.emp-shift-card {
    background: var(--md-sys-color-surface, #FFFFFF);
    border-radius: 16px;
    padding: 18px 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid var(--md-sys-color-outline-variant, #C4C7C5);
    border-left: 5px solid var(--md-sys-color-outline, #79747E);
    display: flex;
    justify-content: space-between;
    align-items: center;
    animation: empFadeIn 0.4s ease backwards;
    transition: box-shadow 0.2s, transform 0.2s;
}

.emp-shift-card:hover {
    box-shadow: 0 2px 6px rgba(0,0,0,0.15), 0 1px 2px rgba(0,0,0,0.3);
    transform: translateY(-2px);
}

.emp-shift-card:nth-child(1) { animation-delay: 0.1s; }
.emp-shift-card:nth-child(2) { animation-delay: 0.2s; }
.emp-shift-card:nth-child(3) { animation-delay: 0.3s; }

.emp-shift-card.status-pending { border-left-color: #FF9800; }
.emp-shift-card.status-ontime,
.emp-shift-card.completed { border-left-color: #4CAF50; }
.emp-shift-card.status-late { border-left-color: #F44336; }
.emp-shift-card.status-early { border-left-color: #2196F3; }
.emp-shift-card.status-warning { border-left-color: #FF9800; }
.emp-shift-card.status-missed { border-left-color: #9E9E9E; }

.emp-shift-type {
    font-size: 1rem;
    font-weight: 600;
    color: var(--md-sys-color-on-surface, #1C1B1F);
    margin-bottom: 4px;
}

.emp-shift-time {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.88rem;
    color: var(--md-sys-color-on-surface-variant, #49454F);
}

.emp-shift-time .material-symbols-rounded { font-size: 16px; }

.emp-shift-badge {
    display: inline-flex;
    align-items: center;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 0.78rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.emp-shift-badge.status-pending { background: rgba(255,152,0,0.12); color: #E65100; }
.emp-shift-badge.status-ontime { background: rgba(76,175,80,0.12); color: #2E7D32; }
.emp-shift-badge.status-late { background: rgba(244,67,54,0.12); color: #C62828; }
.emp-shift-badge.status-early { background: rgba(33,150,243,0.12); color: #1565C0; }
.emp-shift-badge.status-warning { background: rgba(255,152,0,0.12); color: #E65100; }
.emp-shift-badge.status-missed { background: rgba(158,158,158,0.12); color: #616161; }
.emp-shift-badge.pending { background: rgba(255,152,0,0.12); color: #E65100; }

[data-theme="dark"] .emp-shift-badge.status-pending,
[data-theme="dark"] .emp-shift-badge.pending { background: rgba(255,152,0,0.2); color: #FFB74D; }
[data-theme="dark"] .emp-shift-badge.status-ontime { background: rgba(76,175,80,0.2); color: #81C784; }
[data-theme="dark"] .emp-shift-badge.status-late { background: rgba(244,67,54,0.2); color: #E57373; }
[data-theme="dark"] .emp-shift-badge.status-early { background: rgba(33,150,243,0.2); color: #64B5F6; }

/* Empty shifts */
.emp-empty-shifts {
    background: rgba(255,152,0,0.08);
    border: 1px dashed rgba(255,152,0,0.3);
    border-radius: 16px;
    padding: 32px;
    text-align: center;
    color: #E65100;
    animation: empFadeIn 0.4s ease;
    margin-bottom: 32px;
}

[data-theme="dark"] .emp-empty-shifts {
    background: rgba(255,152,0,0.1);
    color: #FFB74D;
}

.emp-empty-shifts .material-symbols-rounded {
    font-size: 48px;
    margin-bottom: 12px;
    animation: empFloat 3s ease-in-out infinite;
}

/* ===== ACTIVE SHIFT BANNER ===== */
.emp-active-banner {
    background: linear-gradient(135deg, #FFB74D 0%, #FF9800 100%);
    border-radius: 20px;
    padding: 24px 28px;
    color: white;
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 20px;
    box-shadow: 0 8px 24px rgba(255,152,0,0.3);
    animation: empScaleIn 0.4s cubic-bezier(0.34,1.56,0.64,1);
}

.emp-active-banner .material-symbols-rounded {
    font-size: 48px;
    animation: empPulse 2s ease-in-out infinite;
}

.emp-active-banner h3 {
    margin: 0 0 4px 0;
    font-size: 1.25rem;
    font-weight: 700;
}

.emp-active-banner p {
    margin: 0;
    opacity: 0.9;
    font-size: 0.95rem;
}

/* ===== ACTION BUTTONS GRID ===== */
.emp-actions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    margin-bottom: 32px;
}

.emp-action-card {
    background: var(--md-sys-color-surface, #FFFFFF);
    border-radius: 16px;
    padding: 28px 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid var(--md-sys-color-outline-variant, #C4C7C5);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 14px;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.3s cubic-bezier(0.34,1.56,0.64,1);
    animation: empScaleIn 0.4s ease backwards;
    position: relative;
    overflow: hidden;
}

.emp-action-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
    transition: left 0.5s;
}

.emp-action-card:hover::before { left: 100%; }

.emp-action-card:nth-child(1) { animation-delay: 0.15s; }
.emp-action-card:nth-child(2) { animation-delay: 0.25s; }
.emp-action-card:nth-child(3) { animation-delay: 0.35s; }

.emp-action-card:hover {
    transform: translateY(-6px) scale(1.02);
    box-shadow: 0 8px 30px rgba(236,64,122,0.15), 0 4px 12px rgba(0,0,0,0.08);
}

.emp-action-card:active {
    transform: scale(0.97);
}

.emp-action-icon {
    width: 56px;
    height: 56px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    transition: all 0.3s;
}

.emp-action-card:hover .emp-action-icon {
    transform: scale(1.1) rotate(5deg);
}

.emp-action-icon.location { background: rgba(0,188,212,0.12); color: #00BCD4; }
.emp-action-icon.qr { background: rgba(76,175,80,0.12); color: #4CAF50; }
.emp-action-icon.justify { background: rgba(255,152,0,0.12); color: #FF9800; }
.emp-action-icon.exit { background: rgba(244,67,54,0.12); color: #F44336; }

[data-theme="dark"] .emp-action-icon.location { background: rgba(0,188,212,0.2); }
[data-theme="dark"] .emp-action-icon.qr { background: rgba(76,175,80,0.2); }
[data-theme="dark"] .emp-action-icon.justify { background: rgba(255,152,0,0.2); }
[data-theme="dark"] .emp-action-icon.exit { background: rgba(244,67,54,0.2); }

.emp-action-label {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--md-sys-color-on-surface, #1C1B1F);
    text-align: center;
}

.emp-action-desc {
    font-size: 0.8rem;
    color: var(--md-sys-color-on-surface-variant, #49454F);
    text-align: center;
    margin-top: -8px;
}

/* Exit button full width */
.emp-action-card.exit-full {
    grid-column: 1 / -1;
    flex-direction: row;
    padding: 20px 28px;
    gap: 20px;
}

.emp-action-card.exit-full .emp-action-label {
    font-size: 1.05rem;
}

/* ===== ATTENDANCE MODAL (STANDARD HTML) ===== */
.emp-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(8px);
    z-index: 10000;
    align-items: center;
    justify-content: center;
    animation: empModalBgIn 0.3s ease;
}

.emp-modal-overlay.show {
    display: flex;
}

@keyframes empModalBgIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.emp-modal {
    background: var(--md-sys-color-surface, #FFFFFF);
    border-radius: 28px;
    width: 92%;
    max-width: 440px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
    animation: empModalPop 0.4s cubic-bezier(0.34,1.56,0.64,1);
}

@keyframes empModalPop {
    0% { opacity: 0; transform: scale(0.85) translateY(20px); }
    100% { opacity: 1; transform: scale(1) translateY(0); }
}

.emp-modal-header {
    background: linear-gradient(135deg, #EC407A 0%, #C7396D 100%);
    padding: 20px 24px;
    color: white;
    text-align: center;
    position: relative;
    border-radius: 28px 28px 0 0;
}

.emp-modal-header h3 {
    margin: 0;
    font-size: 1.15rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}

.emp-modal-header p {
    margin: 4px 0 0 0;
    opacity: 0.9;
    font-size: 0.85rem;
}

.emp-modal-close {
    position: absolute;
    top: 12px;
    right: 12px;
    background: rgba(255,255,255,0.2);
    border: none;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    color: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.2s;
    font-size: 20px;
}

.emp-modal-close:hover {
    background: rgba(255,255,255,0.3);
}

.emp-modal-body {
    padding: 24px;
}

/* Camera Container */
.emp-camera-wrap {
    background: #000;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    position: relative;
    aspect-ratio: 3/4;
    width: 100%;
    margin-bottom: 20px;
}

.emp-camera-wrap video,
.emp-camera-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.emp-camera-wrap canvas {
    display: none;
}

/* Camera overlay gradient */
.emp-camera-overlay-bottom {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 100px;
    background: linear-gradient(to top, rgba(0,0,0,0.7), transparent);
    pointer-events: none;
}

/* Camera controls */
.emp-camera-controls {
    position: absolute;
    bottom: 16px;
    left: 0;
    right: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 24px;
    z-index: 10;
}

.emp-capture-btn {
    background: white;
    border: 4px solid rgba(255,255,255,0.3);
    width: 64px;
    height: 64px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

.emp-capture-btn:active { transform: scale(0.9); }

.emp-capture-btn-inner {
    width: 50px;
    height: 50px;
    background: white;
    border-radius: 50%;
    border: 2px solid #333;
}

.emp-retake-btn {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: rgba(255,255,255,0.2);
    border: none;
    color: white;
    cursor: pointer;
    display: none;
    align-items: center;
    justify-content: center;
    font-size: 24px;
}

.emp-retake-btn:hover { background: rgba(255,255,255,0.3); }

/* Location badge */
.emp-location-badge {
    position: absolute;
    top: 12px;
    left: 12px;
    right: 12px;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(8px);
    padding: 8px 12px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    color: white;
    font-size: 0.78rem;
    border: 1px solid rgba(255,255,255,0.1);
}

.emp-location-badge .spinner {
    width: 14px;
    height: 14px;
    border: 2px solid rgba(255,255,255,0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: empSpin 0.8s linear infinite;
}

@keyframes empSpin {
    to { transform: rotate(360deg); }
}

/* Warning box */
.emp-warning-box {
    display: none;
    background: #FFF3E0;
    border: 1px solid #FFE0B2;
    border-radius: 14px;
    padding: 14px;
    margin-bottom: 16px;
}

[data-theme="dark"] .emp-warning-box {
    background: rgba(255,152,0,0.1);
    border-color: rgba(255,152,0,0.3);
}

.emp-warning-inner {
    display: flex;
    gap: 12px;
    align-items: flex-start;
}

.emp-warning-icon {
    background: #FFE0B2;
    width: 28px;
    height: 28px;
    min-width: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.emp-warning-icon .material-symbols-rounded { font-size: 16px; color: #F57C00; }

.emp-warning-title { color: #E65100; font-weight: 700; font-size: 0.85rem; margin-bottom: 2px; }
.emp-warning-text { color: #EF6C00; font-size: 0.78rem; line-height: 1.3; }

/* Note textarea */
.emp-note-field {
    width: 100%;
    padding: 14px 16px;
    border: 1px solid var(--md-sys-color-outline, #79747E);
    border-radius: 14px;
    font-family: 'Outfit', sans-serif;
    font-size: 0.9rem;
    resize: vertical;
    min-height: 60px;
    background: var(--md-sys-color-surface, #FFFFFF);
    color: var(--md-sys-color-on-surface, #1C1B1F);
    margin-bottom: 20px;
    box-sizing: border-box;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.emp-note-field:focus {
    outline: none;
    border-color: #EC407A;
    box-shadow: 0 0 0 3px rgba(236,64,122,0.15);
}

/* Submit button */
.emp-submit-btn {
    width: 100%;
    height: 52px;
    border: none;
    border-radius: 16px;
    background: linear-gradient(135deg, #EC407A 0%, #C7396D 100%);
    color: white;
    font-family: 'Outfit', sans-serif;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: all 0.2s;
    box-shadow: 0 4px 16px rgba(236,64,122,0.3);
}

.emp-submit-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 6px 24px rgba(236,64,122,0.4);
}

.emp-submit-btn:active:not(:disabled) {
    transform: scale(0.98);
}

.emp-submit-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    box-shadow: none;
}

.emp-submit-btn.suspicious {
    background: linear-gradient(135deg, #FF9800 0%, #E65100 100%);
    box-shadow: 0 4px 16px rgba(255,152,0,0.3);
}

.emp-submit-btn .material-symbols-rounded { font-size: 22px; }

/* ===== TOAST ===== */
.emp-toast {
    position: fixed;
    bottom: 32px;
    left: 50%;
    transform: translateX(-50%) translateY(80px);
    background: var(--md-sys-color-surface, #FFFFFF);
    color: var(--md-sys-color-on-surface, #1C1B1F);
    padding: 16px 28px;
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.15);
    z-index: 11000;
    display: flex;
    align-items: center;
    gap: 12px;
    font-weight: 500;
    opacity: 0;
    transition: all 0.5s cubic-bezier(0.34,1.56,0.64,1);
    border-left: 5px solid transparent;
}

.emp-toast.show {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
}

.emp-toast.success { border-left-color: #4CAF50; }
.emp-toast.success .material-symbols-rounded { color: #4CAF50; }
.emp-toast.error { border-left-color: #F44336; }
.emp-toast.error .material-symbols-rounded { color: #F44336; }
.emp-toast.warning { border-left-color: #FF9800; }
.emp-toast.warning .material-symbols-rounded { color: #FF9800; }

.emp-toast .material-symbols-rounded { font-size: 24px; }

/* ===== DARK MODE ===== */
[data-theme="dark"] .emp-shift-card,
[data-theme="dark"] .emp-action-card {
    background: var(--md-sys-color-surface, #141218);
    border-color: var(--md-sys-color-outline-variant, #49454F);
}

[data-theme="dark"] .emp-modal {
    background: var(--md-sys-color-surface-container-high, #2B2930);
}

/* ===== RESPONSIVE ===== */
@media (max-width: 768px) {
    .emp-dashboard { padding: 16px 20px; }
    .emp-welcome { padding: 24px; flex-direction: column; gap: 16px; align-items: flex-start; }
    .emp-actions-grid { grid-template-columns: 1fr 1fr; }
    .emp-action-card.exit-full { grid-column: 1 / -1; }
}

@media (max-width: 480px) {
    .emp-actions-grid { grid-template-columns: 1fr; }
}
</style>
</head>

<body>

<jsp:include page="../shared/session-saver.jsp"/>

<!-- Loading Screen -->
<jsp:include page="../shared/loading-screen.jsp"/>

<!-- Shared Sidebar & Header (same as admin) -->
<jsp:include page="../shared/sidebar.jsp"/>

<div class="main-content">
    <jsp:include page="../shared/header.jsp"/>

    <div class="emp-dashboard">
        <!-- Welcome Banner -->
        <div class="emp-welcome">
            <div class="emp-welcome-text">
                <h1>¡Hola, ${sessionScope.usuario.nombres}!</h1>
                <p>Tu panel de asistencia y marcación</p>
            </div>
            <div class="emp-clock-badge">
                <span class="emp-clock-time" id="empTime">00:00</span>
                <span class="emp-clock-date" id="empDate">---</span>
            </div>
        </div>

        <!-- My Shifts Today -->
        <h3 class="emp-section-title">
            <span class="material-symbols-rounded">schedule</span>
            Mis Turnos de Hoy
        </h3>

        <c:choose>
            <c:when test="${empty reporteDiario}">
                <div class="emp-empty-shifts">
                    <span class="material-symbols-rounded">event_busy</span>
                    <div><strong>Sin turnos programados</strong></div>
                    <div style="font-size: 0.9rem; opacity: 0.8; margin-top: 4px;">No tienes turnos asignados para hoy</div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="emp-shifts">
                    <c:forEach var="turno" items="${reporteDiario}">
                        <div class="emp-shift-card ${turno.claseCss}">
                            <div>
                                <div class="emp-shift-type">${turno.horario.tipoTurno}</div>
                                <div class="emp-shift-time">
                                    <span class="material-symbols-rounded">schedule</span>
                                    ${turno.horario.horaInicio} - ${turno.horario.horaFin}
                                </div>
                            </div>
                            <div class="emp-shift-badge ${turno.estado == 'PENDIENTE' ? 'pending' : turno.claseCss}">
                                ${turno.mensajeEstado}
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Mark Attendance Section -->
        <h3 class="emp-section-title">
            <span class="material-symbols-rounded">touch_app</span>
            Marcar Asistencia
        </h3>

        <c:choose>
            <c:when test="${hayTurnoAbierto == true}">
                <div class="emp-active-banner">
                    <span class="material-symbols-rounded">timelapse</span>
                    <div>
                        <h3>Turno en Curso</h3>
                        <p>Tienes una actividad activa. Marca tu salida cuando termines.</p>
                    </div>
                </div>

                <div class="emp-actions-grid">
                    <div class="emp-action-card exit-full" onclick="abrirModalAsistencia('SALIDA')">
                        <div class="emp-action-icon exit">
                            <span class="material-symbols-rounded">logout</span>
                        </div>
                        <div>
                            <div class="emp-action-label">Marcar Salida</div>
                            <div class="emp-action-desc">Registrar fin de turno</div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <c:if test="${finJornada == true && !esDiaJustificado}">
                    <div style="background: rgba(76,175,80,0.08); border: 1px solid rgba(76,175,80,0.2); border-radius: 16px; padding: 24px; text-align: center; margin-bottom: 20px; color: #2E7D32;">
                        <span class="material-symbols-rounded" style="font-size: 40px; margin-bottom: 8px; display: block;">task_alt</span>
                        <strong>Jornada Completada</strong>
                        <div style="font-size: 0.9rem; opacity: 0.8; margin-top: 4px;">Todos tus turnos de hoy están completos</div>
                    </div>
                </c:if>

                <div class="emp-actions-grid">
                    <div class="emp-action-card" onclick="abrirModalAsistencia('ENTRADA')">
                        <div class="emp-action-icon location">
                            <span class="material-symbols-rounded">location_on</span>
                        </div>
                        <span class="emp-action-label">Entrada con Foto</span>
                        <span class="emp-action-desc">GPS + Cámara</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/empleado/escanear" class="emp-action-card" style="color: inherit;">
                        <div class="emp-action-icon qr">
                            <span class="material-symbols-rounded">qr_code_scanner</span>
                        </div>
                        <span class="emp-action-label">Escanear QR</span>
                        <span class="emp-action-desc">Código dinámico</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/justificaciones" class="emp-action-card" style="color: inherit;">
                        <div class="emp-action-icon justify">
                            <span class="material-symbols-rounded">assignment_late</span>
                        </div>
                        <span class="emp-action-label">Justificar</span>
                        <span class="emp-action-desc">Ausencias</span>
                    </a>
                </div>
            </c:otherwise>
        </c:choose>

    </div><!-- /emp-dashboard -->
</div><!-- /main-content -->

<!-- ========================================
     MODAL: Marcar Asistencia (Standard HTML)
     ======================================== -->
<div class="emp-modal-overlay" id="modalAsistencia">
    <div class="emp-modal">
        <div class="emp-modal-header">
            <button class="emp-modal-close" onclick="cerrarModalAsistencia()">
                <span class="material-symbols-rounded">close</span>
            </button>
            <h3>
                <span class="material-symbols-rounded" id="modalIcon">photo_camera</span>
                <span id="modalTitle">Marcar Asistencia</span>
            </h3>
            <p>Verifica tu identidad y ubicación</p>
        </div>

        <div class="emp-modal-body">
            <form id="formAsistencia" method="post" action="${pageContext.request.contextPath}/asistencias/marcar" enctype="multipart/form-data">
                <input type="hidden" name="accion" value="marcar">
                <input type="hidden" name="modo" id="inputModo">
                <input type="hidden" name="latitud" id="inputLat">
                <input type="hidden" name="longitud" id="inputLng">
                <input type="hidden" name="sospechosa" id="inputSospechosa" value="false">

                <!-- Camera -->
                <div class="emp-camera-wrap">
                    <video id="cameraVideo" autoplay playsinline></video>
                    <canvas id="cameraCanvas"></canvas>
                    <img id="cameraPreview" style="display:none;">

                    <div class="emp-camera-overlay-bottom"></div>

                    <div class="emp-camera-controls">
                        <button type="button" class="emp-retake-btn" id="btnRetake" onclick="reiniciarCamara()">
                            <span class="material-symbols-rounded">refresh</span>
                        </button>
                        <button type="button" class="emp-capture-btn" id="btnCapture" onclick="tomarFoto()">
                            <div class="emp-capture-btn-inner"></div>
                        </button>
                    </div>

                    <div class="emp-location-badge" id="locationStatus">
                        <div class="spinner"></div>
                        <span>Ubicando...</span>
                    </div>
                </div>

                <!-- Suspicious warning -->
                <div class="emp-warning-box" id="suspiciousWarning">
                    <div class="emp-warning-inner">
                        <div class="emp-warning-icon">
                            <span class="material-symbols-rounded">warning</span>
                        </div>
                        <div>
                            <div class="emp-warning-title">Ubicación Irregular</div>
                            <div class="emp-warning-text">Estás lejos del rango permitido. Se marcará como sospechosa.</div>
                        </div>
                    </div>
                </div>

                <!-- Notes -->
                <textarea class="emp-note-field" name="observacion" placeholder="Nota (Opcional)" rows="2"></textarea>

                <!-- Hidden photo input -->
                <input type="file" name="foto" id="inputFoto" style="display:none;">

                <!-- Submit -->
                <button type="button" class="emp-submit-btn" id="btnSubmit" onclick="enviarAsistencia()" disabled>
                    <span>Registrar</span>
                    <span class="material-symbols-rounded">check</span>
                </button>
            </form>
        </div>
    </div>
</div>

<!-- Toast -->
<div id="empToast" class="emp-toast ${tipoMensaje}">
    <span class="material-symbols-rounded">${tipoMensaje == 'success' ? 'check_circle' : (tipoMensaje == 'warning' ? 'warning' : 'error')}</span>
    <span>${mensaje}</span>
</div>

<!-- ========================================
     JAVASCRIPT
     ======================================== -->
<script>
// === CLOCK ===
function updateEmpClock() {
    var now = new Date();
    var timeStr = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    var dateStr = now.toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' });

    var timeEl = document.getElementById('empTime');
    var dateEl = document.getElementById('empDate');

    if (timeEl) timeEl.textContent = timeStr.substring(0, 5);
    if (dateEl) dateEl.textContent = dateStr;
}
updateEmpClock();
setInterval(updateEmpClock, 1000);

// === TOAST ===
window.addEventListener('load', function() {
    var msgEl = document.getElementById('empToast');
    var msg = "${mensaje}";
    if (msg && msg.trim() !== "") {
        setTimeout(function() {
            msgEl.classList.add('show');
        }, 500);
        setTimeout(function() {
            msgEl.classList.remove('show');
        }, 5000);
    }
    <% session.removeAttribute("mensaje"); session.removeAttribute("tipoMensaje"); %>
});

// === ATTENDANCE MODAL LOGIC ===
var stream = null;
var currentLat = null;
var currentLng = null;

// Sucursal data from session
var SUCURSAL_LAT = ${sessionScope.usuario.sucursal != null && sessionScope.usuario.sucursal.latitud != null ? sessionScope.usuario.sucursal.latitud : 0};
var SUCURSAL_LNG = ${sessionScope.usuario.sucursal != null && sessionScope.usuario.sucursal.longitud != null ? sessionScope.usuario.sucursal.longitud : 0};
var TOLERANCIA = ${sessionScope.usuario.sucursal != null && sessionScope.usuario.sucursal.toleranciaMetros != null ? sessionScope.usuario.sucursal.toleranciaMetros : 100};

function abrirModalAsistencia(modo) {
    var modal = document.getElementById('modalAsistencia');
    var inputModo = document.getElementById('inputModo');
    var title = document.getElementById('modalTitle');
    var icon = document.getElementById('modalIcon');
    var btnSubmit = document.getElementById('btnSubmit');

    inputModo.value = modo;

    if (modo === 'ENTRADA') {
        title.innerText = 'Marcar Entrada';
        icon.innerText = 'login';
        btnSubmit.querySelector('span:first-child').innerText = 'Registrar Entrada';
    } else {
        title.innerText = 'Marcar Salida';
        icon.innerText = 'logout';
        btnSubmit.querySelector('span:first-child').innerText = 'Registrar Salida';
    }

    modal.classList.add('show');
    document.body.style.overflow = 'hidden';
    iniciarCamara();
    obtenerUbicacion();
}

function cerrarModalAsistencia() {
    var modal = document.getElementById('modalAsistencia');
    modal.classList.remove('show');
    document.body.style.overflow = '';
    detenerCamara();

    // Reset state
    currentLat = null;
    currentLng = null;
    document.getElementById('btnSubmit').disabled = true;
    document.getElementById('suspiciousWarning').style.display = 'none';
    document.getElementById('inputSospechosa').value = 'false';
}

// Close modal on overlay click
document.addEventListener('click', function(e) {
    if (e.target.id === 'modalAsistencia') {
        cerrarModalAsistencia();
    }
});

// === CAMERA ===
async function iniciarCamara() {
    try {
        stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'user' },
            audio: false
        });
        var video = document.getElementById('cameraVideo');
        video.srcObject = stream;

        // Reset visual states
        video.style.display = 'block';
        document.getElementById('cameraPreview').style.display = 'none';
        document.getElementById('btnCapture').style.display = 'flex';
        document.getElementById('btnRetake').style.display = 'none';
    } catch (err) {
        console.error("Error cámara:", err);
        // Fallback for when camera access is denied or not available (e.g. HTTP)
        var video = document.getElementById('cameraVideo');
        if (video) video.style.display = 'none';
        var btnCap = document.getElementById('btnCapture');
        if (btnCap) btnCap.style.display = 'none';
        
        var fileInp = document.getElementById('inputFoto');
        if(fileInp) {
            fileInp.style.display = 'block';
            fileInp.setAttribute('capture', 'user');
            fileInp.setAttribute('accept', 'image/*');
            fileInp.style.padding = '10px';
            fileInp.onchange = function() { validarEstado(); };
        }
        window.cameraFallback = true;
        validarEstado();
    }
}

function detenerCamara() {
    if (stream) {
        stream.getTracks().forEach(function(track) { track.stop(); });
        stream = null;
    }
}

function reiniciarCamara() {
    var video = document.getElementById('cameraVideo');
    video.style.display = 'block';
    document.getElementById('cameraPreview').style.display = 'none';
    document.getElementById('btnCapture').style.display = 'flex';
    document.getElementById('btnRetake').style.display = 'none';
    document.getElementById('btnSubmit').disabled = true;
    document.getElementById('inputFoto').value = '';
}

function tomarFoto() {
    var video = document.getElementById('cameraVideo');
    var canvas = document.getElementById('cameraCanvas');
    var preview = document.getElementById('cameraPreview');

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);

    // Show preview
    preview.src = canvas.toDataURL('image/jpeg');
    video.style.display = 'none';
    preview.style.display = 'block';

    // Toggle buttons
    document.getElementById('btnCapture').style.display = 'none';
    document.getElementById('btnRetake').style.display = 'flex';

    // Create file for upload
    canvas.toBlob(function(blob) {
        var file = new File([blob], "asistencia_" + Date.now() + ".jpg", { type: "image/jpeg" });
        var dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        document.getElementById('inputFoto').files = dataTransfer.files;

        // Validate state
        validarEstado();
    }, 'image/jpeg', 0.8);
}

// === LOCATION ===
function obtenerUbicacion() {
    var statusDiv = document.getElementById('locationStatus');
    statusDiv.innerHTML = '<div class="spinner"></div><span>Obteniendo ubicación...</span>';

    if (!navigator.geolocation) {
        statusDiv.innerHTML = '<span class="material-symbols-rounded" style="font-size:16px;color:#F44336;">location_off</span><span>Geolocalización no soportada</span>';
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function(position) {
            currentLat = position.coords.latitude;
            currentLng = position.coords.longitude;

            document.getElementById('inputLat').value = currentLat;
            document.getElementById('inputLng').value = currentLng;

            var dist = calcularDistancia(currentLat, currentLng, SUCURSAL_LAT, SUCURSAL_LNG);
            console.log("Distancia: " + dist + "m, Tolerancia: " + TOLERANCIA + "m");

            if (dist <= TOLERANCIA) {
                statusDiv.innerHTML = '<span class="material-symbols-rounded" style="font-size:16px;color:#4CAF50;">my_location</span><span>Ubicación verificada (' + Math.round(dist) + 'm)</span>';
                statusDiv.style.background = 'rgba(76,175,80,0.2)';
            } else {
                statusDiv.innerHTML = '<span class="material-symbols-rounded" style="font-size:16px;color:#F44336;">wrong_location</span><span>Fuera de rango (' + Math.round(dist) + 'm)</span>';
                statusDiv.style.background = 'rgba(244,67,54,0.2)';
            }
            validarEstado();
        },
        function(error) {
            console.warn("Error Geolocation:", error);
            statusDiv.innerHTML = '<span class="material-symbols-rounded" style="font-size:16px;color:#F44336;">location_disabled</span><span>Error de ubicación. Estableciendo a por defecto.</span>';
            // Fallback so the user can still mark attendance (will be marked as suspicious)
            currentLat = 0;
            currentLng = 0;
            document.getElementById('inputLat').value = currentLat;
            document.getElementById('inputLng').value = currentLng;
            validarEstado();
        },
        { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
    );
}

function calcularDistancia(lat1, lon1, lat2, lon2) {
    var R = 6371e3;
    var p1 = lat1 * Math.PI / 180;
    var p2 = lat2 * Math.PI / 180;
    var dp = (lat2 - lat1) * Math.PI / 180;
    var dl = (lon2 - lon1) * Math.PI / 180;

    var a = Math.sin(dp/2) * Math.sin(dp/2) +
            Math.cos(p1) * Math.cos(p2) *
            Math.sin(dl/2) * Math.sin(dl/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c;
}

function validarEstado() {
    var preview = document.getElementById('cameraPreview');
    var hasPhoto = preview && preview.style.display === 'block';
    var hasLocation = currentLat !== null && currentLng !== null;

    // Check out of range
    var isOutOfRange = false;
    if (hasLocation) {
        var dist = calcularDistancia(currentLat, currentLng, SUCURSAL_LAT, SUCURSAL_LNG);
        isOutOfRange = dist > TOLERANCIA;
    }

    // Suspicious flag
    var sospechosaInput = document.getElementById('inputSospechosa');
    if (sospechosaInput) {
        sospechosaInput.value = isOutOfRange ? 'true' : 'false';
    }

    // Warning display
    var warningDiv = document.getElementById('suspiciousWarning');
    if (warningDiv) {
        warningDiv.style.display = isOutOfRange ? 'block' : 'none';
    }

    // Update button
    var btn = document.getElementById('btnSubmit');
    var modo = document.getElementById('inputModo').value;

    if (btn) {
        if (isOutOfRange) {
            btn.querySelector('span:first-child').innerText = modo === 'ENTRADA' ? '⚠️ Registrar (Sospechosa)' : '⚠️ Registrar Salida';
            btn.classList.add('suspicious');
        } else {
            btn.querySelector('span:first-child').innerText = modo === 'ENTRADA' ? 'Registrar Entrada' : 'Registrar Salida';
            btn.classList.remove('suspicious');
        }
        // If camera failed, don't strictly require a photo to prevent blocking the user
        var photoReady = window.cameraFallback ? true : hasPhoto;
        btn.disabled = !(photoReady && hasLocation);
    }
}

function enviarAsistencia() {
    var btn = document.getElementById('btnSubmit');
    btn.disabled = true;
    btn.querySelector('span:first-child').innerText = 'Enviando...';
    
    var form = document.getElementById('formAsistencia');
    var formData = new FormData(form);
    
    console.log("=== Enviando Asistencia ===");
    for (var pair of formData.entries()) {
        if (pair[0] === 'foto') {
            console.log(pair[0] + ', Archivo: ' + (pair[1] ? pair[1].name : 'ninguno') + ' (' + (pair[1] ? pair[1].size : 0) + ' bytes)');
        } else {
            console.log(pair[0] + ', ' + pair[1]);
        }
    }
    
    fetch(form.action, {
        method: 'POST',
        body: formData,
        redirect: 'follow'
    })
    .then(response => {
        console.log("Respuesta recibida:", response);
        if (response.ok) {
            console.log("Asistencia registrada. La pagina se recargara en 3 segundos para que puedas ver este log.");
            var msgEl = document.getElementById('empToast');
            msgEl.querySelector('span:last-child').innerText = "Solicitud enviada. Revisa la consola.";
            msgEl.className = "emp-toast show success";
            
            setTimeout(function() {
                window.location.href = "${pageContext.request.contextPath}/empleado";
            }, 3000);
        } else {
            console.error("Error en la respuesta:", response.status);
            alert("Ocurrio un error al registrar asistencia. Revisa la consola.");
            btn.disabled = false;
            btn.querySelector('span:first-child').innerText = 'Reintentar';
        }
    })
    .catch(error => {
        console.error("Error en la peticion fetch:", error);
        alert("Error de conexion. Revisa la consola.");
        btn.disabled = false;
        btn.querySelector('span:first-child').innerText = 'Reintentar';
    });
}
</script>

<!-- Toast JS -->
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>

</body>
</html>
