<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- 
    SESSION SAVER COMPONENT
    Bridge logic to persist user session to LocalStorage after successful login.
    This is included in dashboards to capture the 'pending_auth' state from login.
--%>

<script>
(function() {
    try {
        // 1. Check if we have a pending authentication state from login page
        const pendingAuthJSON = sessionStorage.getItem('pending_auth');
        
        if (pendingAuthJSON && "${sessionScope.usuario}" !== "") {
            const authData = JSON.parse(pendingAuthJSON);
            const currentUser = {
                dni: "${sessionScope.usuario.dni}",
                nombres: "${sessionScope.usuario.nombres}",
                apellidos: "${sessionScope.usuario.apellidos}",
                rol: "${sessionScope.usuario.rol}",
                avatar: "${sessionScope.usuario.nombres}".charAt(0) + "${sessionScope.usuario.apellidos}".charAt(0)
            };

            // 2. Determine what to save based on "Remember Me"
            if (authData.remember) {
                // Save EVERYTHING including password
                currentUser.password = authData.password;
                currentUser.remember = true;
            } else {
                // Save ONLY user info, NO password
                currentUser.password = ""; 
                currentUser.remember = false;
            }

            // 3. Update Local Storage (Saved Sessions)
            let savedSessions = JSON.parse(localStorage.getItem('saved_sessions') || '[]');
            
            // Remove existing entry for this DNI if exists
            savedSessions = savedSessions.filter(u => u.dni !== currentUser.dni);
            
            // Add new/updated entry to top
            savedSessions.unshift(currentUser);
            
            // Limit to 5 accounts
            if (savedSessions.length > 5) savedSessions.pop();
            
            localStorage.setItem('saved_sessions', JSON.stringify(savedSessions));
            
            // 4. Cleanup
            sessionStorage.removeItem('pending_auth');
            console.log("Session saved successfully for:", currentUser.nombres);
        }
    } catch (e) {
        console.error("Error saving session:", e);
    }
})();
</script>
