package com.zonasturisticas.plataforma.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.zonasturisticas.plataforma.beans.Notificacion;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Integer> {

    // Original methods
    List<Notificacion> findByEmpleadoIdOrderByCreadoEnDesc(Integer empleadoId);

    List<Notificacion> findByEmpleadoIdAndLeidoFalse(Integer empleadoId);

    // Global notifications for a specific role
    List<Notificacion> findByTargetRoleOrderByCreadoEnDesc(String targetRole);

    // Count unread for a specific employee
    long countByEmpleadoIdAndLeidoFalse(Integer empleadoId);

    // Count unread for employee + global role notifications
    @Query("SELECT COUNT(n) FROM Notificacion n WHERE " +
            "(n.empleado.id = :empleadoId OR n.targetRole = :rol) AND n.leido = false")
    long countNoLeidasByEmpleadoOrRol(@Param("empleadoId") Integer empleadoId, @Param("rol") String rol);

    // Get all notifications for a user (specific + global based on role)
    @Query("SELECT n FROM Notificacion n WHERE " +
            "n.empleado.id = :empleadoId OR n.targetRole = :rol " +
            "ORDER BY n.creadoEn DESC")
    List<Notificacion> findAllForUser(@Param("empleadoId") Integer empleadoId, @Param("rol") String rol);

    // Get recent notifications (last N) for a user
    @Query("SELECT n FROM Notificacion n WHERE " +
            "n.empleado.id = :empleadoId OR n.targetRole = :rol " +
            "ORDER BY n.creadoEn DESC " +
            "LIMIT :limit")
    List<Notificacion> findRecentForUser(@Param("empleadoId") Integer empleadoId,
            @Param("rol") String rol,
            @Param("limit") int limit);

    // Mark all as read for a user (specific + global)
    @Modifying
    @Query("UPDATE Notificacion n SET n.leido = true WHERE " +
            "(n.empleado.id = :empleadoId OR n.targetRole = :rol) AND n.leido = false")
    int marcarTodasLeidasByEmpleadoOrRol(@Param("empleadoId") Integer empleadoId, @Param("rol") String rol);

    // Find by type and employee (to avoid duplicate notifications)
    List<Notificacion> findByEmpleadoIdAndTipo(Integer empleadoId, String tipo);

    // Delete old notifications (older than X days)
    @Modifying
    @Query("DELETE FROM Notificacion n WHERE n.creadoEn < :fecha")
    int eliminarAntiguasDe(@Param("fecha") java.time.LocalDateTime fecha);
}
