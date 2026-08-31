package com.zonasturisticas.plataforma.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zonasturisticas.plataforma.beans.Asistencia;
import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Justificacion;
import com.zonasturisticas.plataforma.beans.Sucursal;

/**
 * Service dedicated to generating automatic notifications based on system
 * events.
 * This centralizes all notification generation logic.
 */
@Service
public class NotificacionGeneratorService {

    @Autowired
    private NotificacionService notificacionService;

    // =====================================================
    // ATTENDANCE NOTIFICATIONS
    // =====================================================

    /**
     * Notify when an employee registers a late arrival
     */
    public void notificarTardanza(Empleado empleado, Asistencia asistencia) {
        String mensaje = empleado.getNombres() + " " + empleado.getApellidos() +
                " registró una tardanza a las " + asistencia.getHoraEntrada();

        // Notify the employee
        notificacionService.crearNotificacion(
                empleado,
                "TARDANZA_REGISTRADA",
                "Has registrado una tardanza. Hora de entrada: " + asistencia.getHoraEntrada(),
                "NORMAL",
                "schedule",
                "/empleado/asistencias");

        // Notify admins
        notificacionService.crearNotificacionGlobal(
                "TARDANZA_REGISTRADA",
                mensaje,
                "ADMIN",
                "NORMAL",
                "schedule");
    }

    /**
     * Notify when the first employee of the day marks attendance
     */
    public void notificarPrimerIngresoDia(Empleado empleado, Sucursal sucursal) {
        String nombreSucursal = sucursal != null ? sucursal.getNombre() : "la empresa";
        String mensaje = "¡" + empleado.getNombres() + " es el primero en llegar hoy a " + nombreSucursal + "!";

        notificacionService.crearNotificacionGlobal(
                "PRIMER_INGRESO_DIA",
                mensaje,
                "ADMIN",
                "LOW",
                "wb_sunny",
                null,
                sucursal != null ? "{\"sucursalId\":" + sucursal.getId() + "}" : null);
    }

    /**
     * Notify when employee successfully marks attendance
     */
    public void notificarAsistenciaMarcada(Empleado empleado, boolean esEntrada) {
        String tipo = esEntrada ? "entrada" : "salida";
        String mensaje = "Tu " + tipo + " ha sido registrada exitosamente.";

        notificacionService.crearNotificacion(
                empleado,
                "ASISTENCIA_MARCADA",
                mensaje,
                "LOW",
                "check_circle",
                "/empleado/dashboard");
    }

    /**
     * Notify when all employees have left for the day
     */
    public void notificarTodosSalieron(Sucursal sucursal, int totalEmpleados) {
        String nombreSucursal = sucursal != null ? sucursal.getNombre() : "la empresa";
        String mensaje = "Todos los " + totalEmpleados + " empleados han marcado salida en " + nombreSucursal + ".";

        notificacionService.crearNotificacionGlobal(
                "TODOS_EN_SALIDA",
                mensaje,
                "ADMIN",
                "NORMAL",
                "logout",
                null,
                sucursal != null ? "{\"sucursalId\":" + sucursal.getId() + "}" : null);
    }

    // =====================================================
    // JUSTIFICATION NOTIFICATIONS
    // =====================================================

    /**
     * Notify admins when a new justification is submitted
     */
    public void notificarJustificacionPendiente(Justificacion justificacion) {
        Empleado empleado = justificacion.getEmpleado();
        String mensaje = empleado.getNombres() + " " + empleado.getApellidos() +
                " ha enviado una justificación pendiente de aprobación.";

        notificacionService.crearNotificacionGlobal(
                "JUSTIFICACION_PENDIENTE",
                mensaje,
                "ADMIN",
                "HIGH",
                "pending_actions",
                "/justificaciones/lista");
    }

    /**
     * Notify employee when their justification is approved
     */
    public void notificarJustificacionAprobada(Justificacion justificacion) {
        notificacionService.crearNotificacion(
                justificacion.getEmpleado(),
                "JUSTIFICACION_APROBADA",
                "¡Tu justificación ha sido aprobada!",
                "NORMAL",
                "check_circle",
                "/justificaciones/lista");
    }

    /**
     * Notify employee when their justification is rejected
     */
    public void notificarJustificacionRechazada(Justificacion justificacion, String motivo) {
        String mensaje = "Tu justificación ha sido rechazada.";
        if (motivo != null && !motivo.isEmpty()) {
            mensaje += " Motivo: " + motivo;
        }

        notificacionService.crearNotificacion(
                justificacion.getEmpleado(),
                "JUSTIFICACION_RECHAZADA",
                mensaje,
                "HIGH",
                "cancel",
                "/justificaciones/lista");
    }

    // =====================================================
    // SCHEDULE NOTIFICATIONS
    // =====================================================

    /**
     * Notify when a schedule is assigned
     */
    public void notificarHorarioAsignado(Empleado empleado, String detalleHorario) {
        String mensaje = "Se te ha asignado un nuevo horario: " + detalleHorario;

        notificacionService.crearNotificacion(
                empleado,
                "HORARIO_ASIGNADO",
                mensaje,
                "NORMAL",
                "calendar_month",
                "/empleado/horarios");
    }

    /**
     * Notify when a schedule is changed
     */
    public void notificarHorarioCambiado(Empleado empleado, String cambios) {
        String mensaje = "Tu horario ha sido modificado. " + cambios;

        notificacionService.crearNotificacion(
                empleado,
                "HORARIO_CAMBIADO",
                mensaje,
                "HIGH",
                "edit_calendar",
                "/empleado/horarios");
    }

    // =====================================================
    // PERFORMANCE NOTIFICATIONS
    // =====================================================

    /**
     * Notify about low performance (multiple tardies)
     */
    public void notificarBajoDesempeno(Empleado empleado, int cantidadTardanzas, String periodo) {
        String mensaje = empleado.getNombres() + " " + empleado.getApellidos() +
                " ha registrado " + cantidadTardanzas + " tardanzas " + periodo + ".";

        notificacionService.crearNotificacionGlobal(
                "BAJO_DESEMPENO",
                mensaje,
                "ADMIN",
                "HIGH",
                "trending_down",
                "/reportes/asistencia",
                "{\"empleadoId\":" + empleado.getId() + "}");
    }

    /**
     * Notify about high performance (perfect punctuality)
     */
    public void notificarAltoDesempeno(Empleado empleado, String periodo) {
        // Notify admins
        String mensajeAdmin = empleado.getNombres() + " " + empleado.getApellidos() +
                " ha mantenido 100% puntualidad " + periodo + ". ¡Excelente!";

        notificacionService.crearNotificacionGlobal(
                "ALTO_DESEMPENO",
                mensajeAdmin,
                "ADMIN",
                "NORMAL",
                "emoji_events",
                "/reportes/asistencia",
                "{\"empleadoId\":" + empleado.getId() + "}");

        // Notify the employee
        notificacionService.crearNotificacion(
                empleado,
                "ALTO_DESEMPENO",
                "¡Felicitaciones! Has mantenido una puntualidad perfecta " + periodo + ". ¡Sigue así!",
                "NORMAL",
                "emoji_events",
                null);
    }

    // =====================================================
    // BRANCH STATUS NOTIFICATIONS
    // =====================================================

    /**
     * Notify when a branch has low staff
     */
    public void notificarBajoPersonalSucursal(Sucursal sucursal, int presentes, int esperados) {
        int porcentaje = esperados > 0 ? (presentes * 100 / esperados) : 0;
        String mensaje = sucursal.getNombre() + " cuenta con solo " + presentes +
                " de " + esperados + " empleados (" + porcentaje + "%).";

        notificacionService.crearNotificacionGlobal(
                "BAJO_PERSONAL_SUCURSAL",
                mensaje,
                "ADMIN",
                "HIGH",
                "group_off",
                "/sucursales/lista",
                "{\"sucursalId\":" + sucursal.getId() + "}");
    }

    /**
     * Notify when all expected employees are present at a branch
     */
    public void notificarSucursalCompleta(Sucursal sucursal, int totalEmpleados) {
        String mensaje = "¡" + sucursal.getNombre() + " está al 100%! Los " + totalEmpleados +
                " empleados programados están presentes.";

        notificacionService.crearNotificacionGlobal(
                "SUCURSAL_COMPLETA",
                mensaje,
                "ADMIN",
                "NORMAL",
                "groups",
                null,
                "{\"sucursalId\":" + sucursal.getId() + "}");
    }

    /**
     * Notify when majority of employees are on break
     */
    public void notificarMayoriaEnRefrigerio(Sucursal sucursal, int enRefrigerio, int total) {
        int porcentaje = total > 0 ? (enRefrigerio * 100 / total) : 0;
        String nombreSucursal = sucursal != null ? sucursal.getNombre() : "la empresa";
        String mensaje = porcentaje + "% del personal (" + enRefrigerio + "/" + total +
                ") está en refrigerio en " + nombreSucursal + ".";

        notificacionService.crearNotificacionGlobal(
                "MAYORIA_EN_REFRIGERIO",
                mensaje,
                "ADMIN",
                "NORMAL",
                "restaurant",
                null,
                sucursal != null ? "{\"sucursalId\":" + sucursal.getId() + "}" : null);
    }

    // =====================================================
    // REMINDER NOTIFICATIONS
    // =====================================================

    /**
     * Remind employee about upcoming shift
     */
    public void notificarProximoTurno(Empleado empleado, String horaInicio) {
        String mensaje = "Tu turno comienza en 30 minutos (" + horaInicio + "). ¡Prepárate!";

        notificacionService.crearNotificacion(
                empleado,
                "PROXIMO_TURNO",
                mensaje,
                "NORMAL",
                "alarm",
                "/empleado/dashboard");
    }
}
