<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Mi Historial | Grupo Peruana</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">

    <style>
    body {
        font-family: 'Outfit', sans-serif;
        background-color: var(--md-sys-color-background, #F8F9FA);
    }

    .historial-container {
        padding: 32px 40px;
        max-width: 1200px;
        width: 100%;
        margin: 0 auto;
        box-sizing: border-box;
        animation: histFadeIn 0.6s ease;
    }

    @keyframes histFadeIn {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes histCardIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Page header */
    .hist-page-header {
        margin-bottom: 28px;
    }

    .hist-page-header h1 {
        font-size: 1.8rem;
        font-weight: 700;
        color: var(--md-sys-color-on-surface, #1C1B1F);
        margin: 0 0 4px 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .hist-page-header h1 .material-symbols-rounded {
        color: #EC407A;
    }

    .hist-page-header p {
        font-size: 0.95rem;
        color: var(--md-sys-color-on-surface-variant, #49454F);
        margin: 0;
    }

    /* Cards */
    .hist-list {
        display: flex;
        flex-direction: column;
        gap: 14px;
    }

    .hist-card {
        background: var(--md-sys-color-surface, #FFFFFF);
        border-radius: 16px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.05);
        border: 1px solid var(--md-sys-color-outline-variant, #C4C7C5);
        border-left: 5px solid #4CAF50;
        animation: histCardIn 0.4s ease backwards;
        transition: box-shadow 0.2s, transform 0.2s;
    }

    .hist-card:hover {
        box-shadow: 0 2px 6px rgba(0,0,0,0.15), 0 1px 2px rgba(0,0,0,0.3);
        transform: translateY(-2px);
    }

    .hist-card:nth-child(1) { animation-delay: 0.05s; }
    .hist-card:nth-child(2) { animation-delay: 0.1s; }
    .hist-card:nth-child(3) { animation-delay: 0.15s; }
    .hist-card:nth-child(4) { animation-delay: 0.2s; }
    .hist-card:nth-child(5) { animation-delay: 0.25s; }

    .hist-card-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 14px;
    }

    .hist-date {
        font-size: 1.05rem;
        font-weight: 600;
        color: var(--md-sys-color-on-surface, #1C1B1F);
    }

    .hist-method {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 12px;
        border-radius: 16px;
        font-size: 0.75rem;
        font-weight: 600;
        text-transform: uppercase;
    }

    .hist-method.qr { background: rgba(76,175,80,0.12); color: #2E7D32; }
    .hist-method.gps { background: rgba(33,150,243,0.12); color: #1565C0; }
    .hist-method .material-symbols-rounded { font-size: 14px; }

    [data-theme="dark"] .hist-method.qr { background: rgba(76,175,80,0.2); color: #81C784; }
    [data-theme="dark"] .hist-method.gps { background: rgba(33,150,243,0.2); color: #64B5F6; }

    .hist-times {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 14px;
    }

    .hist-time-block {
        background: var(--md-sys-color-surface-container-low, #F7F2FA);
        padding: 12px 14px;
        border-radius: 12px;
    }

    [data-theme="dark"] .hist-time-block {
        background: var(--md-sys-color-surface-container, #211F26);
    }

    .hist-time-label {
        font-size: 0.78rem;
        color: var(--md-sys-color-on-surface-variant, #49454F);
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .hist-time-label .material-symbols-rounded { font-size: 14px; }

    .hist-time-value {
        font-size: 1.15rem;
        font-weight: 700;
    }

    .hist-time-value.entry { color: #4CAF50; }
    .hist-time-value.exit { color: #EC407A; }
    .hist-time-value.pending { color: var(--md-sys-color-on-surface-variant, #49454F); font-style: italic; font-weight: 400; }

    .hist-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 12px;
        border-top: 1px solid var(--md-sys-color-outline-variant, #C4C7C5);
    }

    .hist-extras { display: flex; flex-direction: column; gap: 4px; }

    .hist-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-size: 0.82rem;
        font-weight: 600;
    }

    .hist-badge.late { color: #F44336; }
    .hist-badge.overtime { color: #4CAF50; }
    .hist-badge .material-symbols-rounded { font-size: 16px; }

    .hist-actions { display: flex; gap: 8px; }

    .hist-action-link {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: var(--md-sys-color-surface-container-low, #F7F2FA);
        color: var(--md-sys-color-on-surface-variant, #49454F);
        text-decoration: none;
        transition: all 0.2s;
    }

    .hist-action-link:hover {
        background: rgba(236,64,122,0.12);
        color: #EC407A;
    }

    .hist-action-link .material-symbols-rounded { font-size: 20px; }

    .hist-obs {
        margin-top: 12px;
        padding: 10px 14px;
        background: rgba(255,152,0,0.08);
        border-radius: 12px;
        font-size: 0.85rem;
        color: #E65100;
    }

    [data-theme="dark"] .hist-obs {
        background: rgba(255,152,0,0.12);
        color: #FFB74D;
    }

    .hist-obs::before { content: "📝 "; }

    /* Empty state */
    .hist-empty {
        text-align: center;
        padding: 60px 24px;
    }

    .hist-empty .material-symbols-rounded {
        font-size: 64px;
        color: var(--md-sys-color-outline-variant, #C4C7C5);
        margin-bottom: 16px;
    }

    .hist-empty h3 {
        font-size: 1.15rem;
        color: var(--md-sys-color-on-surface, #1C1B1F);
        margin: 0 0 8px 0;
    }

    .hist-empty p {
        font-size: 0.9rem;
        color: var(--md-sys-color-on-surface-variant, #49454F);
        margin: 0;
    }

    @media (max-width: 768px) {
        .historial-container { padding: 16px 20px; }
    }
    </style>
</head>
<body>

<jsp:include page="../shared/loading-screen.jsp"/>
<jsp:include page="../shared/sidebar.jsp"/>

<div class="main-content">
    <jsp:include page="../shared/header.jsp"/>

    <div class="historial-container">
        <div class="hist-page-header">
            <h1>
                <span class="material-symbols-rounded">history</span>
                Mi Historial
            </h1>
            <p>Registro de tus asistencias</p>
        </div>

        <c:choose>
            <c:when test="${empty listaAsistencia}">
                <div class="hist-empty">
                    <span class="material-symbols-rounded">event_busy</span>
                    <h3>Sin registros</h3>
                    <p>No tienes asistencias registradas todavía</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="hist-list">
                    <c:forEach items="${listaAsistencia}" var="a">
                        <div class="hist-card">
                            <div class="hist-card-header">
                                <span class="hist-date">${a.fecha}</span>
                                <c:choose>
                                    <c:when test="${a.modo == 'QR' || a.modo == 'QR_DINAMICO'}">
                                        <span class="hist-method qr">
                                            <span class="material-symbols-rounded">qr_code</span>
                                            QR
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="hist-method gps">
                                            <span class="material-symbols-rounded">location_on</span>
                                            GPS
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="hist-times">
                                <div class="hist-time-block">
                                    <div class="hist-time-label">
                                        <span class="material-symbols-rounded">login</span>
                                        Entrada
                                    </div>
                                    <div class="hist-time-value entry">${a.horaEntrada}</div>
                                </div>
                                <div class="hist-time-block">
                                    <div class="hist-time-label">
                                        <span class="material-symbols-rounded">logout</span>
                                        Salida
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty a.horaSalida}">
                                            <div class="hist-time-value exit">${a.horaSalida}</div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="hist-time-value pending">--:--</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="hist-footer">
                                <div class="hist-extras">
                                    <c:if test="${not empty a.minutosTardanza && a.minutosTardanza > 0}">
                                        <span class="hist-badge late">
                                            <span class="material-symbols-rounded">schedule</span>
                                            +${a.minutosTardanza} min tardanza
                                        </span>
                                    </c:if>
                                    <c:if test="${not empty a.minutosExtras && a.minutosExtras > 0}">
                                        <span class="hist-badge overtime">
                                            <span class="material-symbols-rounded">add_circle</span>
                                            +${a.minutosExtras} min extra
                                        </span>
                                    </c:if>
                                </div>

                                <div class="hist-actions">
                                    <c:if test="${not empty a.latitud}">
                                        <a href="https://www.google.com/maps?q=${a.latitud},${a.longitud}"
                                           target="_blank"
                                           class="hist-action-link"
                                           title="Ver ubicación">
                                            <span class="material-symbols-rounded">map</span>
                                        </a>
                                    </c:if>
                                    <c:if test="${not empty a.fotoUrl}">
                                        <a href="${a.fotoUrl}"
                                           target="_blank"
                                           class="hist-action-link"
                                           title="Ver foto">
                                            <span class="material-symbols-rounded">photo_camera</span>
                                        </a>
                                    </c:if>
                                </div>
                            </div>

                            <c:if test="${not empty a.observacion}">
                                <div class="hist-obs">${a.observacion}</div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>

</body>
</html>
