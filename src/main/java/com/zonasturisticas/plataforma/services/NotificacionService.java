package com.zonasturisticas.plataforma.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Notificacion;
import com.zonasturisticas.plataforma.repositories.NotificacionRepository;

@Service
public class NotificacionService {

    @Autowired
    private NotificacionRepository repo;

    /**
     * Create a notification for a specific employee
     */
    public Notificacion crearNotificacion(Empleado empleado, String tipo, String mensaje) {
        Notificacion n = new Notificacion();
        n.setEmpleado(empleado);
        n.setTipo(tipo);
        n.setMensaje(mensaje);
        return repo.save(n);
    }

    /**
     * Create a notification with all options
     */
    public Notificacion crearNotificacion(Empleado empleado, String tipo, String mensaje,
            String prioridad, String icono, String actionUrl) {
        Notificacion n = new Notificacion();
        n.setEmpleado(empleado);
        n.setTipo(tipo);
        n.setMensaje(mensaje);
        n.setPrioridad(prioridad);
        n.setIcono(icono);
        n.setActionUrl(actionUrl);
        return repo.save(n);
    }

    /**
     * Create a global notification for a role (e.g., all ADMINs)
     */
    public Notificacion crearNotificacionGlobal(String tipo, String mensaje, String targetRole,
            String prioridad, String icono) {
        Notificacion n = new Notificacion();
        n.setEmpleado(null); // No specific employee
        n.setTipo(tipo);
        n.setMensaje(mensaje);
        n.setTargetRole(targetRole);
        n.setPrioridad(prioridad);
        n.setIcono(icono);
        return repo.save(n);
    }

    /**
     * Create a global notification with action URL (no metadata)
     */
    public Notificacion crearNotificacionGlobal(String tipo, String mensaje, String targetRole,
            String prioridad, String icono, String actionUrl) {
        return crearNotificacionGlobal(tipo, mensaje, targetRole, prioridad, icono, actionUrl, null);
    }

    /**
     * Create a global notification with action URL
     */
    public Notificacion crearNotificacionGlobal(String tipo, String mensaje, String targetRole,
            String prioridad, String icono, String actionUrl, String metadata) {
        Notificacion n = new Notificacion();
        n.setEmpleado(null);
        n.setTipo(tipo);
        n.setMensaje(mensaje);
        n.setTargetRole(targetRole);
        n.setPrioridad(prioridad);
        n.setIcono(icono);
        n.setActionUrl(actionUrl);
        n.setMetadata(metadata);
        return repo.save(n);
    }

    /**
     * Get all notifications for an employee (original method)
     */
    public List<Notificacion> obtenerNotificacionesEmpleado(Integer empleadoId) {
        return repo.findByEmpleadoIdOrderByCreadoEnDesc(empleadoId);
    }

    /**
     * Get all notifications for a user (specific + global based on role)
     */
    public List<Notificacion> obtenerNotificacionesUsuario(Integer empleadoId, String rol) {
        return repo.findAllForUser(empleadoId, rol);
    }

    /**
     * Get recent notifications for a user (limited)
     */
    public List<Notificacion> obtenerNotificacionesRecientes(Integer empleadoId, String rol, int limit) {
        return repo.findRecentForUser(empleadoId, rol, limit);
    }

    /**
     * Get unread notifications for an employee (original method)
     */
    public List<Notificacion> obtenerNoLeidas(Integer empleadoId) {
        return repo.findByEmpleadoIdAndLeidoFalse(empleadoId);
    }

    /**
     * Count unread notifications for a user (specific + global)
     */
    public long contarNoLeidas(Integer empleadoId, String rol) {
        return repo.countNoLeidasByEmpleadoOrRol(empleadoId, rol);
    }

    /**
     * Mark a single notification as read
     */
    public void marcarComoLeida(Integer id) {
        Notificacion n = repo.findById(id).orElseThrow();
        n.setLeido(true);
        repo.save(n);
    }

    /**
     * Mark all notifications as read for a user
     */
    @Transactional
    public int marcarTodasComoLeidas(Integer empleadoId, String rol) {
        return repo.marcarTodasLeidasByEmpleadoOrRol(empleadoId, rol);
    }

    /**
     * Delete a notification
     */
    public void eliminar(Integer id) {
        repo.deleteById(id);
    }

    /**
     * Delete old notifications (cleanup)
     */
    @Transactional
    public int eliminarNotificacionesAntiguas(int diasAntiguedad) {
        java.time.LocalDateTime fechaLimite = java.time.LocalDateTime.now().minusDays(diasAntiguedad);
        return repo.eliminarAntiguasDe(fechaLimite);
    }
}
