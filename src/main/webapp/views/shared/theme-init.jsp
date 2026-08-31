<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
    theme-init.jsp - Inline script to prevent FOUC (Flash of Unstyled Content)
    Must be included in <head> BEFORE any stylesheets for best results.
    This script runs synchronously and applies the theme immediately.
--%>
<script>
// Apply theme immediately to prevent flash
(function() {
    try {
        var theme = localStorage.getItem('theme');
        if (theme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
        }

        var currentUserId = '${sessionScope.usuario.id}';
        var pinned = localStorage.getItem('sidebarPinned_' + currentUserId);
        
        // If there's no user, fallback to generic
        if (currentUserId === '') {
            pinned = localStorage.getItem('sidebarPinned');
        }

        if (pinned === null || pinned === 'true') {
            document.documentElement.classList.add('sidebar-pinned');
        }
        
        var minimized = localStorage.getItem('sidebarMinimized_' + currentUserId);
        if (currentUserId === '') {
            minimized = localStorage.getItem('sidebarMinimized');
        }
        
        if (minimized === 'true') {
            document.documentElement.classList.add('sidebar-minimized');
        }
    } catch (e) {
        // localStorage might not be available (private browsing, etc.)
    }
})();
</script>
