<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Notificaciones | Grupo Peruana</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <!-- Material Web Components -->
    <script type="importmap">
    {
      "imports": {
        "@material/web/": "https://esm.run/@material/web/"
      }
    }
    </script>
    <script type="module">
        import '@material/web/all.js';
        import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
        document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

    <style>
        .page-header {
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--md-sys-color-surface);
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: 16px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .stat-icon.primary {
            background: rgba(236, 64, 122, 0.12);
            color: #EC407A;
        }

        .stat-icon.info {
            background: rgba(33, 150, 243, 0.12);
            color: #2196F3;
        }

        .stat-content h3 {
            font-size: 1.75rem;
            font-weight: 700;
            margin: 0;
            color: var(--md-sys-color-on-surface);
        }

        .stat-content p {
            font-size: 0.875rem;
            color: var(--md-sys-color-secondary);
            margin: 4px 0 0 0;
        }

        /* Notification List */
        .notification-list-container {
            padding: 16px;
        }

        .notification-item {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            padding: 16px;
            border-radius: 12px;
            cursor: pointer;
            transition: background-color 0.2s;
            position: relative;
            border-bottom: 1px solid var(--md-sys-color-outline-variant);
        }

        .notification-item:last-child {
            border-bottom: none;
        }

        .notification-item:hover {
            background-color: var(--md-sys-color-surface-variant);
        }

        .notification-item.unread {
            background-color: rgba(236, 64, 122, 0.04);
        }

        .notification-item.unread::before {
            content: '';
            position: absolute;
            left: 8px;
            top: 50%;
            transform: translateY(-50%);
            width: 8px;
            height: 8px;
            background: #EC407A;
            border-radius: 50%;
        }

        .notif-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .notif-icon.info { background: rgba(100, 181, 246, 0.15); color: #1976D2; }
        .notif-icon.success { background: rgba(129, 199, 132, 0.15); color: #388E3C; }
        .notif-icon.warning { background: rgba(255, 183, 77, 0.15); color: #F57C00; }
        .notif-icon.error { background: rgba(239, 83, 80, 0.15); color: #D32F2F; }
        .notif-icon.primary { background: rgba(236, 64, 122, 0.12); color: #C2185B; }

        .notif-content {
            flex: 1;
            min-width: 0;
        }

        .notif-message {
            font-size: 0.95rem;
            color: var(--md-sys-color-on-surface);
            line-height: 1.5;
            margin: 0 0 6px 0;
        }

        .notif-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 0.8rem;
            color: var(--md-sys-color-secondary);
        }

        .notif-meta span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .notif-actions {
            display: flex;
            gap: 4px;
            opacity: 0;
            transition: opacity 0.2s;
        }

        .notification-item:hover .notif-actions {
            opacity: 1;
        }

        /* Empty State */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 80px 24px;
            text-align: center;
        }

        .empty-state .material-symbols-outlined {
            font-size: 72px;
            color: rgba(0, 0, 0, 0.15);
            margin-bottom: 16px;
        }

        [data-theme="dark"] .empty-state .material-symbols-outlined {
            color: rgba(255, 255, 255, 0.15);
        }

        .empty-state h3 {
            margin: 0 0 8px 0;
            font-size: 1.25rem;
            color: var(--md-sys-color-on-surface);
        }

        .empty-state p {
            margin: 0;
            color: var(--md-sys-color-secondary);
        }

        /* Animations */
        @keyframes fade-in-up {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .notification-item {
            animation: fade-in-up 0.4s ease-out forwards;
            opacity: 0;
        }

        .notification-item:nth-child(1) { animation-delay: 0.05s; }
        .notification-item:nth-child(2) { animation-delay: 0.1s; }
        .notification-item:nth-child(3) { animation-delay: 0.15s; }
        .notification-item:nth-child(4) { animation-delay: 0.2s; }
        .notification-item:nth-child(5) { animation-delay: 0.25s; }
        .notification-item:nth-child(6) { animation-delay: 0.3s; }
        .notification-item:nth-child(7) { animation-delay: 0.35s; }
        .notification-item:nth-child(8) { animation-delay: 0.4s; }
        .notification-item:nth-child(9) { animation-delay: 0.45s; }
        .notification-item:nth-child(10) { animation-delay: 0.5s; }
    </style>
</head>
<body>

    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/console-warning.jsp" />
    
    <%-- Conditional Layout based on role --%>
    <c:choose>
        <c:when test="${sessionScope.usuario.rol == 'ADMIN' || sessionScope.usuario.rol == 'JEFE'}">
            <jsp:include page="../shared/sidebar.jsp" />
            <div class="main-content">
                <jsp:include page="../shared/header.jsp" />
                <div class="container">
                
                <div class="page-header">
                    <div style="flex: 1;">
                        <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem; margin: 0;">
                            <span class="material-symbols-outlined" style="vertical-align: middle; margin-right: 8px; color: #EC407A;">notifications</span>
                            Notificaciones
                        </h1>
                        <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Centro de notificaciones del sistema</p>
                    </div>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <md-outlined-button type="button" onclick="marcarTodasLeidas()">
                            <md-icon slot="icon">done_all</md-icon>
                            Marcar todas como leídas
                        </md-outlined-button>
                    </div>
                </div>

                <!-- Stats -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon primary">
                            <span class="material-symbols-outlined">mark_email_unread</span>
                        </div>
                        <div class="stat-content">
                            <h3>${noLeidas}</h3>
                            <p>Sin leer</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon info">
                            <span class="material-symbols-outlined">all_inbox</span>
                        </div>
                        <div class="stat-content">
                            <h3>${total}</h3>
                            <p>Total</p>
                        </div>
                    </div>
                </div>

                <!-- Notification List -->
                <div class="card">
                    <div class="notification-list-container" id="notificationListContainer">
                        <c:choose>
                            <c:when test="${empty notificaciones}">
                                <div class="empty-state">
                                    <span class="material-symbols-outlined">notifications_off</span>
                                    <h3>No hay notificaciones</h3>
                                    <p>Estás al día con todo. Las nuevas notificaciones aparecerán aquí.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="n" items="${notificaciones}">
                                    <div class="notification-item ${n.leido ? '' : 'unread'}" data-id="${n.id}">
                                        <div class="notif-icon ${n.prioridad == 'HIGH' || n.prioridad == 'URGENT' ? 'error' : 
                                            (n.tipo.contains('APROBADA') || n.tipo.contains('MARCADA') || n.tipo.contains('COMPLETA') ? 'success' : 
                                            (n.tipo.contains('RECHAZADA') || n.tipo.contains('BAJO') ? 'error' : 
                                            (n.tipo.contains('TARDANZA') || n.tipo.contains('CAMBIADO') || n.tipo.contains('WARNING') ? 'warning' : 
                                            (n.tipo.contains('PENDIENTE') ? 'primary' : 'info'))))}">
                                            <span class="material-symbols-outlined">
                                                <c:choose>
                                                    <c:when test="${not empty n.icono}">${n.icono}</c:when>
                                                    <c:when test="${n.tipo == 'JUSTIFICACION_PENDIENTE'}">pending_actions</c:when>
                                                    <c:when test="${n.tipo == 'JUSTIFICACION_APROBADA'}">check_circle</c:when>
                                                    <c:when test="${n.tipo == 'JUSTIFICACION_RECHAZADA'}">cancel</c:when>
                                                    <c:when test="${n.tipo == 'TARDANZA_REGISTRADA'}">schedule</c:when>
                                                    <c:when test="${n.tipo == 'HORARIO_ASIGNADO'}">calendar_month</c:when>
                                                    <c:when test="${n.tipo == 'HORARIO_CAMBIADO'}">edit_calendar</c:when>
                                                    <c:when test="${n.tipo == 'BAJO_DESEMPENO'}">trending_down</c:when>
                                                    <c:when test="${n.tipo == 'ALTO_DESEMPENO'}">emoji_events</c:when>
                                                    <c:when test="${n.tipo == 'ASISTENCIA_MARCADA'}">check_circle</c:when>
                                                    <c:otherwise>notifications</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="notif-content" onclick="handleNotificationClick(${n.id}, '${n.actionUrl}')">
                                            <p class="notif-message">${fn:escapeXml(n.mensaje)}</p>
                                            <div class="notif-meta">
                                                <span>
                                                    <span class="material-symbols-outlined" style="font-size: 16px;">schedule</span>
                                                    ${n.creadoEn}
                                                </span>
                                                <c:if test="${not empty n.tipo}">
                                                    <span>
                                                        <span class="material-symbols-outlined" style="font-size: 16px;">label</span>
                                                        ${fn:replace(fn:toLowerCase(n.tipo), '_', ' ')}
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="notif-actions">
                                            <c:if test="${!n.leido}">
                                                <md-icon-button onclick="marcarLeida(${n.id})" title="Marcar como leída">
                                                    <md-icon>mark_email_read</md-icon>
                                                </md-icon-button>
                                            </c:if>
                                            <md-icon-button onclick="eliminarNotificacion(${n.id})" title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);">
                                                <md-icon>delete</md-icon>
                                            </md-icon-button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            </div>
        </c:when>
        <c:otherwise>
            <%-- Mobile Layout for Employees --%>
            <jsp:include page="../shared/mobile-layout.jsp" />
            <main class="mobile-content">
                <div class="page-header" style="margin-bottom: 20px;">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin: 0 0 4px 0;">
                        <span class="material-symbols-outlined" style="vertical-align: middle; margin-right: 4px; color: #EC407A;">notifications</span>
                        Notificaciones
                    </h1>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); margin: 0;">${noLeidas} sin leer de ${total} total</p>
                </div>
                
                <button onclick="marcarTodasLeidas()" 
                   style="display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; background: var(--surface, #fff); color: #EC407A; padding: 14px 24px; border-radius: 12px; border: 1px solid #EC407A; font-weight: 600; margin-bottom: 20px; cursor: pointer;">
                    <span class="material-symbols-outlined" style="font-size: 20px;">done_all</span>
                    Marcar todas como leídas
                </button>
                
                <c:choose>
                    <c:when test="${empty notificaciones}">
                        <div style="text-align: center; padding: 48px 24px;">
                            <span class="material-symbols-outlined" style="font-size: 64px; color: #CAC4D0;">notifications_off</span>
                            <h3 style="font-size: 1.1rem; color: var(--text-primary); margin: 16px 0 8px 0;">Sin notificaciones</h3>
                            <p style="font-size: 0.9rem; color: var(--text-secondary); margin: 0;">Estás al día con todo</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 12px;">
                            <c:forEach var="n" items="${notificaciones}">
                                <div style="background: var(--surface, #fff); border-radius: 16px; padding: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); 
                                    ${!n.leido ? 'border-left: 4px solid #EC407A;' : ''}" 
                                    data-id="${n.id}" onclick="handleNotificationClick(${n.id}, '${n.actionUrl}')">
                                    <div style="display: flex; gap: 12px;">
                                        <div style="width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
                                            background: ${n.tipo.contains('APROBADA') || n.tipo.contains('MARCADA') ? 'rgba(76,175,80,0.12)' : 
                                                (n.tipo.contains('RECHAZADA') || n.tipo.contains('BAJO') ? 'rgba(244,67,54,0.12)' : 
                                                (n.tipo.contains('PENDIENTE') ? 'rgba(236,64,122,0.12)' : 'rgba(33,150,243,0.12)'))};
                                            color: ${n.tipo.contains('APROBADA') || n.tipo.contains('MARCADA') ? '#388E3C' : 
                                                (n.tipo.contains('RECHAZADA') || n.tipo.contains('BAJO') ? '#D32F2F' : 
                                                (n.tipo.contains('PENDIENTE') ? '#C2185B' : '#1976D2'))};">
                                            <span class="material-symbols-outlined" style="font-size: 22px;">
                                                <c:choose>
                                                    <c:when test="${not empty n.icono}">${n.icono}</c:when>
                                                    <c:when test="${n.tipo == 'JUSTIFICACION_APROBADA'}">check_circle</c:when>
                                                    <c:when test="${n.tipo == 'JUSTIFICACION_RECHAZADA'}">cancel</c:when>
                                                    <c:when test="${n.tipo == 'ASISTENCIA_MARCADA'}">check_circle</c:when>
                                                    <c:otherwise>notifications</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div style="flex: 1; min-width: 0;">
                                            <p style="font-size: 0.9rem; color: var(--text-primary); line-height: 1.4; margin: 0 0 6px 0; ${!n.leido ? 'font-weight: 600;' : ''}">${fn:escapeXml(n.mensaje)}</p>
                                            <span style="font-size: 0.75rem; color: var(--text-secondary);">${n.creadoEn}</span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </main>
        </c:otherwise>
    </c:choose>

    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';

        async function handleNotificationClick(id, actionUrl) {
            try {
                await fetch(contextPath + '/api/notificaciones/marcar-leida/' + id, { method: 'PUT' });
                
                const item = document.querySelector('[data-id="' + id + '"]');
                if (item) item.classList.remove('unread');
                
                if (actionUrl && actionUrl.trim() !== '') {
                    window.location.href = contextPath + actionUrl;
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }

        async function marcarLeida(id) {
            event.stopPropagation();
            try {
                await fetch(contextPath + '/api/notificaciones/marcar-leida/' + id, { method: 'PUT' });
                const item = document.querySelector('[data-id="' + id + '"]');
                if (item) {
                    item.classList.remove('unread');
                    const btn = item.querySelector('md-icon-button[title="Marcar como leída"]');
                    if (btn) btn.remove();
                }
                updateNoLeidasCount();
            } catch (error) {
                console.error('Error:', error);
            }
        }

        async function marcarTodasLeidas() {
            try {
                await fetch(contextPath + '/api/notificaciones/marcar-todas-leidas', { method: 'PUT' });
                document.querySelectorAll('.notification-item.unread, [data-id].unread').forEach(item => {
                    item.classList.remove('unread');
                });
                document.querySelectorAll('md-icon-button[title="Marcar como leída"]').forEach(btn => btn.remove());
                
                // Update stats
                const noLeidasEl = document.querySelector('.stat-card:first-child h3');
                if (noLeidasEl) noLeidasEl.textContent = '0';
                
                if (typeof showToast === 'function') {
                    showToast('Éxito', 'Todas las notificaciones marcadas como leídas', 'success', 'check_circle');
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }

        async function eliminarNotificacion(id) {
            event.stopPropagation();
            if (!confirm('¿Eliminar esta notificación?')) return;
            
            try {
                await fetch(contextPath + '/api/notificaciones/' + id, { method: 'DELETE' });
                const item = document.querySelector('[data-id="' + id + '"]');
                if (item) {
                    item.style.opacity = '0';
                    item.style.transform = 'translateX(20px)';
                    item.style.transition = 'all 0.3s ease';
                    setTimeout(() => {
                        item.remove();
                        checkEmpty();
                    }, 300);
                }
                updateTotalCount();
            } catch (error) {
                console.error('Error:', error);
            }
        }

        function checkEmpty() {
            const container = document.getElementById('notificationListContainer');
            const items = container.querySelectorAll('.notification-item');
            if (items.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <span class="material-symbols-outlined">notifications_off</span>
                        <h3>No hay notificaciones</h3>
                        <p>Estás al día con todo.</p>
                    </div>
                `;
            }
        }

        function updateNoLeidasCount() {
            const unreadItems = document.querySelectorAll('.notification-item.unread, [data-id].unread').length;
            const noLeidasEl = document.querySelector('.stat-card:first-child h3');
            if (noLeidasEl) noLeidasEl.textContent = unreadItems;
        }

        function updateTotalCount() {
            const totalItems = document.querySelectorAll('.notification-item, [data-id]').length;
            const totalEl = document.querySelector('.stat-card:nth-child(2) h3');
            if (totalEl) totalEl.textContent = totalItems;
        }
    </script>
</body>
</html>
