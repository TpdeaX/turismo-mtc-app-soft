<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
/* ===========================
   NOTIFICATION PANEL STYLES
   =========================== */

/* Notification Container - Wrapper around bell icon */
.notification-container {
    position: relative;
}

/* Bell Icon Button */
.notification-btn {
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
    border: none;
    background: transparent;
}

.notification-btn:hover {
    background-color: var(--bg-hover);
}

/* Badge Counter */
.notification-badge {
    position: absolute;
    top: 6px;
    right: 6px;
    min-width: 18px;
    height: 18px;
    background-color: #B3261E;
    border-radius: 9px;
    border: 2px solid var(--bg-header, #FFFFFF);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 600;
    color: white;
    padding: 0 4px;
    opacity: 0;
    transform: scale(0);
    transition: opacity 0.3s ease, transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.notification-badge.show {
    opacity: 1;
    transform: scale(1);
}

/* Animation for new notification */
@keyframes notificationPulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.2); }
}

.notification-badge.pulse {
    animation: notificationPulse 0.5s ease-in-out;
}

/* Dropdown Panel */
.notification-panel {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    width: 380px;
    max-height: 480px;
    background-color: var(--bg-card, #FFFFFF);
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(0, 0, 0, 0.05);
    display: none;
    flex-direction: column;
    z-index: 1200;
    overflow: hidden;
    transform-origin: top right;
    animation: panelSlideIn 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

.notification-panel.show {
    display: flex;
}

@keyframes panelSlideIn {
    from { 
        opacity: 0; 
        transform: translateY(-10px) scale(0.95);
    }
    to { 
        opacity: 1; 
        transform: translateY(0) scale(1);
    }
}

.notification-panel.closing {
    animation: panelSlideOut 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes panelSlideOut {
    from { opacity: 1; transform: translateY(0) scale(1); }
    to { opacity: 0; transform: translateY(-10px) scale(0.95); }
}

/* Panel Header */
.notification-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid var(--border-color, rgba(0, 0, 0, 0.08));
    background: linear-gradient(135deg, #EC407A 0%, #D81B60 100%);
    color: white;
}

.notification-header h3 {
    margin: 0;
    font-size: 1rem;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
}

.notification-header h3 .material-symbols-outlined {
    font-size: 20px;
}

.mark-all-read-btn {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 4px;
}

.mark-all-read-btn:hover {
    background: rgba(255, 255, 255, 0.3);
}

.mark-all-read-btn .material-symbols-outlined {
    font-size: 14px;
}

/* Panel Body - List Container */
.notification-list {
    flex: 1;
    overflow-y: auto;
    padding: 8px;
    max-height: 360px;
}

/* Scrollbar Styling */
.notification-list::-webkit-scrollbar {
    width: 6px;
}

.notification-list::-webkit-scrollbar-track {
    background: transparent;
}

.notification-list::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.15);
    border-radius: 3px;
}

.notification-list::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 0, 0, 0.25);
}

/* Notification Item */
.notification-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px;
    border-radius: 12px;
    cursor: pointer;
    transition: background-color 0.2s;
    position: relative;
}

.notification-item:hover {
    background-color: var(--bg-hover, rgba(0, 0, 0, 0.04));
}

.notification-item.unread {
    background-color: rgba(236, 64, 122, 0.06);
}

.notification-item.unread::before {
    content: '';
    position: absolute;
    left: 4px;
    top: 50%;
    transform: translateY(-50%);
    width: 6px;
    height: 6px;
    background: #EC407A;
    border-radius: 50%;
}

/* Item Icon */
.notification-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    font-size: 20px;
}

/* Icon Colors by Priority/Type */
.notification-icon.info {
    background: rgba(100, 181, 246, 0.15);
    color: #1976D2;
}

.notification-icon.success {
    background: rgba(129, 199, 132, 0.15);
    color: #388E3C;
}

.notification-icon.warning {
    background: rgba(255, 183, 77, 0.15);
    color: #F57C00;
}

.notification-icon.error {
    background: rgba(239, 83, 80, 0.15);
    color: #D32F2F;
}

.notification-icon.primary {
    background: rgba(236, 64, 122, 0.12);
    color: #C2185B;
}

/* Item Content */
.notification-content {
    flex: 1;
    min-width: 0;
}

.notification-message {
    font-size: 0.875rem;
    color: var(--text-primary, #1a1a1a);
    line-height: 1.4;
    margin: 0 0 4px 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.notification-time {
    font-size: 0.75rem;
    color: var(--text-secondary, #666);
}

/* Delete Button */
.notification-delete {
    opacity: 0;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    color: var(--text-secondary);
    cursor: pointer;
    transition: opacity 0.2s, background-color 0.2s;
    border: none;
    background: transparent;
}

.notification-item:hover .notification-delete {
    opacity: 1;
}

.notification-delete:hover {
    background-color: rgba(0, 0, 0, 0.08);
    color: #D32F2F;
}

.notification-delete .material-symbols-outlined {
    font-size: 18px;
}

/* Empty State */
.notification-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 48px 24px;
    text-align: center;
    color: var(--text-secondary, #666);
}

.notification-empty .material-symbols-outlined {
    font-size: 56px;
    color: rgba(0, 0, 0, 0.15);
    margin-bottom: 16px;
}

.notification-empty h4 {
    margin: 0 0 4px 0;
    color: var(--text-primary);
    font-weight: 500;
}

.notification-empty p {
    margin: 0;
    font-size: 0.875rem;
}

/* Loading State */
.notification-loading {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
}

.notification-loading .spinner {
    width: 32px;
    height: 32px;
    border: 3px solid rgba(236, 64, 122, 0.2);
    border-top-color: #EC407A;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

/* Panel Footer */
.notification-footer {
    padding: 12px 16px;
    border-top: 1px solid var(--border-color, rgba(0, 0, 0, 0.08));
    text-align: center;
}

.view-all-btn {
    color: #EC407A;
    font-size: 0.875rem;
    font-weight: 500;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    transition: color 0.2s;
}

.view-all-btn:hover {
    color: #C2185B;
}

.view-all-btn .material-symbols-outlined {
    font-size: 18px;
    transition: transform 0.2s;
}

.view-all-btn:hover .material-symbols-outlined {
    transform: translateX(4px);
}

/* Dark Mode Overrides */
[data-theme="dark"] .notification-panel {
    background-color: #2C2C2C;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.08);
}

[data-theme="dark"] .notification-item.unread {
    background-color: rgba(236, 64, 122, 0.1);
}

[data-theme="dark"] .notification-empty .material-symbols-outlined {
    color: rgba(255, 255, 255, 0.2);
}

/* Responsive */
@media (max-width: 480px) {
    .notification-panel {
        width: 100vw;
        right: -16px;
        border-radius: 0 0 16px 16px;
        max-height: 70vh;
    }
}
</style>

<div class="notification-container" id="notificationContainer">
    <!-- Bell Button -->
    <button class="notification-btn" onclick="toggleNotificationPanel()" title="Notificaciones">
        <span class="material-symbols-outlined">notifications</span>
        <span class="notification-badge" id="notificationBadge">0</span>
    </button>
    
    <!-- Dropdown Panel -->
    <div class="notification-panel" id="notificationPanel">
        <!-- Header -->
        <div class="notification-header">
            <h3>
                <span class="material-symbols-outlined">notifications</span>
                Notificaciones
            </h3>
            <button class="mark-all-read-btn" onclick="markAllNotificationsRead()" title="Marcar todas como leídas">
                <span class="material-symbols-outlined">done_all</span>
                Leer todas
            </button>
        </div>
        
        <!-- Notification List -->
        <div class="notification-list" id="notificationList">
            <!-- Loading state -->
            <div class="notification-loading" id="notificationLoading">
                <div class="spinner"></div>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="notification-footer">
            <a href="${pageContext.request.contextPath}/notificaciones" class="view-all-btn">
                Ver todas
                <span class="material-symbols-outlined">arrow_forward</span>
            </a>
        </div>
    </div>
</div>

<script>
(function() {
    const contextPath = '${pageContext.request.contextPath}';
    let notificationPollInterval = null;
    let currentNotifications = [];
    let isPanelOpen = false;

    // Initialize on DOM load
    document.addEventListener('DOMContentLoaded', function() {
        // Initial fetch
        fetchNotificationCount();
        
        // Start polling every 30 seconds
        notificationPollInterval = setInterval(fetchNotificationCount, 30000);
        
        // Close panel when clicking outside
        document.addEventListener('click', handleOutsideClick);
    });

    // Toggle notification panel
    window.toggleNotificationPanel = function() {
        const panel = document.getElementById('notificationPanel');
        
        if (panel.classList.contains('show')) {
            closeNotificationPanel();
        } else {
            openNotificationPanel();
        }
    };

    function openNotificationPanel() {
        const panel = document.getElementById('notificationPanel');
        panel.classList.remove('closing');
        panel.classList.add('show');
        isPanelOpen = true;
        
        // Load notifications
        fetchNotifications();
    }

    function closeNotificationPanel() {
        const panel = document.getElementById('notificationPanel');
        panel.classList.add('closing');
        
        setTimeout(() => {
            panel.classList.remove('show', 'closing');
            isPanelOpen = false;
        }, 200);
    }

    function handleOutsideClick(event) {
        const container = document.getElementById('notificationContainer');
        if (isPanelOpen && !container.contains(event.target)) {
            closeNotificationPanel();
        }
    }

    // Fetch notification count
    async function fetchNotificationCount() {
        try {
            const response = await fetch(contextPath + '/api/notificaciones/count-no-leidas');
            if (response.ok) {
                const data = await response.json();
                updateBadge(data.count);
            }
        } catch (error) {
            console.error('Error fetching notification count:', error);
        }
    }

    // Fetch notifications list
    async function fetchNotifications() {
        const listContainer = document.getElementById('notificationList');
        const loading = document.getElementById('notificationLoading');
        
        loading.style.display = 'flex';
        
        try {
            const response = await fetch(contextPath + '/api/notificaciones/recientes?limit=15');
            if (response.ok) {
                currentNotifications = await response.json();
                renderNotifications(currentNotifications);
            }
        } catch (error) {
            console.error('Error fetching notifications:', error);
            listContainer.innerHTML = '<div class="notification-empty"><p>Error al cargar notificaciones</p></div>';
        } finally {
            loading.style.display = 'none';
        }
    }

    // Render notifications
    function renderNotifications(notifications) {
        const listContainer = document.getElementById('notificationList');
        
        if (!notifications || notifications.length === 0) {
            listContainer.innerHTML = `
                <div class="notification-empty">
                    <span class="material-symbols-outlined">notifications_off</span>
                    <h4>Sin notificaciones</h4>
                    <p>Estás al día con todo</p>
                </div>
            `;
            return;
        }
        
        listContainer.innerHTML = notifications.map(n => createNotificationItem(n)).join('');
    }

    // Create notification item HTML
    function createNotificationItem(notification) {
        const iconClass = getIconClass(notification.tipo, notification.prioridad);
        const icon = notification.icono || getDefaultIcon(notification.tipo);
        const timeAgo = formatTimeAgo(notification.creadoEn);
        const unreadClass = notification.leido ? '' : 'unread';
        const mensaje = escapeHtml(notification.mensaje || '');
        
        return '<div class="notification-item ' + unreadClass + '" ' +
                 'data-id="' + notification.id + '" ' +
                 'onclick="handleNotificationClick(' + notification.id + ', \'' + (notification.actionUrl || '') + '\')">' +
                '<div class="notification-icon ' + iconClass + '">' +
                    '<span class="material-symbols-outlined">' + icon + '</span>' +
                '</div>' +
                '<div class="notification-content">' +
                    '<p class="notification-message">' + mensaje + '</p>' +
                    '<span class="notification-time">' + timeAgo + '</span>' +
                '</div>' +
                '<button class="notification-delete" onclick="deleteNotification(event, ' + notification.id + ')" title="Eliminar">' +
                    '<span class="material-symbols-outlined">close</span>' +
                '</button>' +
            '</div>';
    }

    // Get icon class based on type/priority
    function getIconClass(tipo, prioridad) {
        if (prioridad === 'URGENT' || prioridad === 'HIGH') return 'error';
        
        const typeClasses = {
            'JUSTIFICACION_APROBADA': 'success',
            'ASISTENCIA_MARCADA': 'success',
            'ALTO_DESEMPENO': 'success',
            'SUCURSAL_COMPLETA': 'success',
            'JUSTIFICACION_RECHAZADA': 'error',
            'BAJO_DESEMPENO': 'error',
            'BAJO_PERSONAL_SUCURSAL': 'warning',
            'TARDANZA_REGISTRADA': 'warning',
            'HORARIO_CAMBIADO': 'warning',
            'JUSTIFICACION_PENDIENTE': 'primary',
            'HORARIO_ASIGNADO': 'info'
        };
        
        return typeClasses[tipo] || 'info';
    }

    // Get default icon based on type
    function getDefaultIcon(tipo) {
        const icons = {
            'JUSTIFICACION_PENDIENTE': 'pending_actions',
            'JUSTIFICACION_APROBADA': 'check_circle',
            'JUSTIFICACION_RECHAZADA': 'cancel',
            'TARDANZA_REGISTRADA': 'schedule',
            'HORARIO_ASIGNADO': 'calendar_month',
            'HORARIO_CAMBIADO': 'edit_calendar',
            'BAJO_DESEMPENO': 'trending_down',
            'ALTO_DESEMPENO': 'emoji_events',
            'BAJO_PERSONAL_SUCURSAL': 'group_off',
            'SUCURSAL_COMPLETA': 'groups',
            'MAYORIA_EN_REFRIGERIO': 'restaurant',
            'PRIMER_INGRESO_DIA': 'wb_sunny',
            'TODOS_EN_SALIDA': 'logout',
            'ASISTENCIA_MARCADA': 'check_circle',
            'PROXIMO_TURNO': 'alarm'
        };
        
        return icons[tipo] || 'notifications';
    }

    // Format time ago
    function formatTimeAgo(dateString) {
        if (!dateString) return '';
        
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);
        
        if (diffMins < 1) return 'Ahora';
        if (diffMins < 60) return `Hace ${diffMins} min`;
        if (diffHours < 24) return `Hace ${diffHours}h`;
        if (diffDays < 7) return `Hace ${diffDays}d`;
        
        return date.toLocaleDateString('es-PE', { day: '2-digit', month: 'short' });
    }

    // Update badge
    function updateBadge(count) {
        const badge = document.getElementById('notificationBadge');
        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.classList.add('show');
            
            // Pulse animation for new notifications
            if (count > parseInt(badge.dataset.lastCount || 0)) {
                badge.classList.add('pulse');
                setTimeout(() => badge.classList.remove('pulse'), 500);
            }
            badge.dataset.lastCount = count;
        } else {
            badge.classList.remove('show');
        }
    }

    // Handle notification click
    window.handleNotificationClick = async function(id, actionUrl) {
        // Mark as read
        try {
            await fetch(contextPath + '/api/notificaciones/marcar-leida/' + id, { method: 'PUT' });
            
            // Update UI
            const item = document.querySelector(`.notification-item[data-id="${id}"]`);
            if (item) item.classList.remove('unread');
            
            // Update count
            fetchNotificationCount();
            
            // Navigate if action URL exists
            if (actionUrl) {
                window.location.href = contextPath + actionUrl;
            }
        } catch (error) {
            console.error('Error marking notification as read:', error);
        }
    };

    // Delete notification
    window.deleteNotification = async function(event, id) {
        event.stopPropagation();
        
        try {
            await fetch(contextPath + '/api/notificaciones/' + id, { method: 'DELETE' });
            
            // Remove from UI
            const item = document.querySelector(`.notification-item[data-id="${id}"]`);
            if (item) {
                item.style.opacity = '0';
                item.style.transform = 'translateX(20px)';
                setTimeout(() => {
                    item.remove();
                    // Check if empty
                    const list = document.getElementById('notificationList');
                    if (!list.querySelector('.notification-item')) {
                        renderNotifications([]);
                    }
                }, 200);
            }
            
            // Update count
            fetchNotificationCount();
        } catch (error) {
            console.error('Error deleting notification:', error);
        }
    };

    // Mark all as read
    window.markAllNotificationsRead = async function() {
        try {
            await fetch(contextPath + '/api/notificaciones/marcar-todas-leidas', { method: 'PUT' });
            
            // Update UI
            document.querySelectorAll('.notification-item.unread').forEach(item => {
                item.classList.remove('unread');
            });
            
            // Update count
            updateBadge(0);
        } catch (error) {
            console.error('Error marking all as read:', error);
        }
    };

    // Escape HTML
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
})();
</script>
