package com.zonasturisticas.plataforma.controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Notificacion;
import com.zonasturisticas.plataforma.services.NotificacionService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/notificaciones")
public class NotificacionController {

    @Autowired
    private NotificacionService service;

    /**
     * Get notifications for a specific employee (legacy endpoint)
     */
    @GetMapping("/{empleadoId}")
    public List<Notificacion> getNotificaciones(@PathVariable Integer empleadoId) {
        return service.obtenerNotificacionesEmpleado(empleadoId);
    }

    /**
     * Get unread notifications for a specific employee (legacy endpoint)
     */
    @GetMapping("/no-leidas/{empleadoId}")
    public List<Notificacion> getNoLeidas(@PathVariable Integer empleadoId) {
        return service.obtenerNoLeidas(empleadoId);
    }

    /**
     * Create a notification (legacy endpoint)
     */
    @PostMapping("/crear")
    public Notificacion crear(@RequestBody Map<String, String> body) {
        Empleado emp = new Empleado();
        emp.setId(Integer.parseInt(body.get("empleadoId")));
        return service.crearNotificacion(emp, body.get("tipo"), body.get("mensaje"));
    }

    /**
     * Mark a single notification as read (legacy endpoint)
     */
    @PutMapping("/marcar-leida/{id}")
    public void marcarComoLeida(@PathVariable Integer id) {
        service.marcarComoLeida(id);
    }

    // ========================================
    // NEW ENDPOINTS FOR NOTIFICATION PANEL
    // ========================================

    /**
     * Get notifications for the current logged-in user (specific + global based on
     * role)
     */
    @GetMapping("/mis-notificaciones")
    public ResponseEntity<List<Notificacion>> getMisNotificaciones(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        List<Notificacion> notificaciones = service.obtenerNotificacionesUsuario(
                usuario.getId(),
                usuario.getRol());
        return ResponseEntity.ok(notificaciones);
    }

    /**
     * Get recent notifications for the current user (limited)
     */
    @GetMapping("/recientes")
    public ResponseEntity<List<Notificacion>> getRecientes(
            HttpSession session,
            @RequestParam(defaultValue = "20") int limit) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        List<Notificacion> notificaciones = service.obtenerNotificacionesRecientes(
                usuario.getId(),
                usuario.getRol(),
                limit);
        return ResponseEntity.ok(notificaciones);
    }

    /**
     * Get count of unread notifications for the current user
     */
    @GetMapping("/count-no-leidas")
    public ResponseEntity<Map<String, Long>> getCountNoLeidas(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        long count = service.contarNoLeidas(usuario.getId(), usuario.getRol());

        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        return ResponseEntity.ok(response);
    }

    /**
     * Mark all notifications as read for the current user
     */
    @PutMapping("/marcar-todas-leidas")
    public ResponseEntity<Map<String, Object>> marcarTodasLeidas(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return ResponseEntity.status(401).build();
        }

        int updated = service.marcarTodasComoLeidas(usuario.getId(), usuario.getRol());

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("updated", updated);
        return ResponseEntity.ok(response);
    }

    /**
     * Delete a notification by ID
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Boolean>> eliminar(@PathVariable Integer id) {
        try {
            service.eliminar(id);
            Map<String, Boolean> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Boolean> response = new HashMap<>();
            response.put("success", false);
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * Create a notification with full options (for testing/admin)
     */
    @PostMapping("/crear-completa")
    public ResponseEntity<Notificacion> crearCompleta(@RequestBody Map<String, String> body, HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || !"ADMIN".equals(usuario.getRol())) {
            return ResponseEntity.status(403).build();
        }

        String targetRole = body.get("targetRole");
        String tipo = body.get("tipo");
        String mensaje = body.get("mensaje");
        String prioridad = body.getOrDefault("prioridad", "NORMAL");
        String icono = body.get("icono");
        String actionUrl = body.get("actionUrl");

        Notificacion n;
        if (targetRole != null && !targetRole.isEmpty()) {
            // Global notification
            n = service.crearNotificacionGlobal(tipo, mensaje, targetRole, prioridad, icono);
        } else {
            // Specific employee notification
            String empleadoIdStr = body.get("empleadoId");
            if (empleadoIdStr != null) {
                Empleado emp = new Empleado();
                emp.setId(Integer.parseInt(empleadoIdStr));
                n = service.crearNotificacion(emp, tipo, mensaje, prioridad, icono, actionUrl);
            } else {
                return ResponseEntity.badRequest().build();
            }
        }

        return ResponseEntity.ok(n);
    }
}
