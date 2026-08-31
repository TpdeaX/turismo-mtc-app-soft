package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Justificacion;
import com.zonasturisticas.plataforma.repositories.JustificacionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

@Service
public class JustificacionService {

    private final JustificacionRepository justificacionRepository;
    private final AsistenciaService asistenciaService;
    private final NotificacionGeneratorService notificacionGenerator;

    public JustificacionService(JustificacionRepository justificacionRepository,
            AsistenciaService asistenciaService,
            NotificacionGeneratorService notificacionGenerator) {
        this.justificacionRepository = justificacionRepository;
        this.asistenciaService = asistenciaService;
        this.notificacionGenerator = notificacionGenerator;
    }

    public List<Justificacion> listarTodo() {
        return justificacionRepository.findAllByOrderByFechaSolicitudDesc();
    }

    public Page<Justificacion> listarAvanzado(Integer empleadoId, String keyword, String fechaSolicitudStr,
            String fechaInicioStr, String fechaFinStr, String estado, int page, int size) {
        Pageable pageable = PageRequest.of(page, size,
                org.springframework.data.domain.Sort.by("fechaSolicitud").descending());

        return listarAvanzadoInternal(empleadoId, keyword, fechaSolicitudStr, fechaInicioStr, fechaFinStr, estado,
                pageable);
    }

    public List<Justificacion> listarAvanzadoSinPaginacion(Integer empleadoId, String keyword, String fechaSolicitudStr,
            String fechaInicioStr, String fechaFinStr, String estado) {
        // Request a large page to get all results for export
        Pageable pageable = PageRequest.of(0, 10000,
                org.springframework.data.domain.Sort.by("fechaSolicitud").descending());
        return listarAvanzadoInternal(empleadoId, keyword, fechaSolicitudStr, fechaInicioStr, fechaFinStr, estado,
                pageable).getContent();
    }

    private Page<Justificacion> listarAvanzadoInternal(Integer empleadoId, String keyword, String fechaSolicitudStr,
            String fechaInicioStr, String fechaFinStr, String estado, Pageable pageable) {
        java.time.LocalDate fechaSolicitud = (fechaSolicitudStr != null && !fechaSolicitudStr.isEmpty())
                ? java.time.LocalDate.parse(fechaSolicitudStr)
                : null;
        java.time.LocalDate fechaInicio = (fechaInicioStr != null && !fechaInicioStr.isEmpty())
                ? java.time.LocalDate.parse(fechaInicioStr)
                : null;
        java.time.LocalDate fechaFin = (fechaFinStr != null && !fechaFinStr.isEmpty())
                ? java.time.LocalDate.parse(fechaFinStr)
                : null;

        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (estado != null && estado.trim().isEmpty())
            estado = null;

        return justificacionRepository.buscarAvanzado(empleadoId, keyword, fechaSolicitud, fechaInicio, fechaFin,
                estado, pageable);
    }

    public Page<Justificacion> listarTodo(int page, int size, String keyword) {
        return listarAvanzado(null, keyword, null, null, null, null, page, size);
    }

    public List<Justificacion> listarPorEmpleado(int empleadoId) {
        return justificacionRepository.findByEmpleadoIdOrderByFechaSolicitudDesc(empleadoId);
    }

    public Page<Justificacion> listarPorEmpleado(int empleadoId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return justificacionRepository.findByEmpleadoIdOrderByFechaSolicitudDesc(empleadoId, pageable);
    }

    public Justificacion obtenerPorId(int id) {
        return justificacionRepository.findById(id).orElse(null);
    }

    public void guardar(Justificacion justificacion) {
        if (justificacion.getDetalles() != null) {
            for (com.zonasturisticas.plataforma.beans.JustificacionDetalle detalle : justificacion.getDetalles()) {
                detalle.setJustificacion(justificacion);
            }
        }

        boolean isNew = justificacion.getId() == 0;
        justificacionRepository.save(justificacion);

        // Notify admins about new pending justification
        if (isNew && "PENDIENTE".equals(justificacion.getEstado())) {
            notificacionGenerator.notificarJustificacionPendiente(justificacion);
        }
    }

    public void eliminar(int id) {
        justificacionRepository.deleteById(id);
    }

    public String guardarEvidencia(MultipartFile file) {
        if (file == null || file.isEmpty())
            return null;
        try {
            String folder = "src/main/resources/static/uploads/justificaciones/";
            java.io.File directory = new java.io.File(folder);
            if (!directory.exists())
                directory.mkdirs();

            String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = Paths.get(folder + filename);
            Files.write(path, file.getBytes());

            return "uploads/justificaciones/" + filename;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean aprobar(int id, String comentario) {
        Optional<Justificacion> opt = justificacionRepository.findById(id);
        if (opt.isPresent()) {
            Justificacion j = opt.get();
            j.setEstado("ACEPTADA");
            j.setComentarioAprobacion(comentario);
            justificacionRepository.save(j);
            asistenciaService.aplicarJustificacion(j);

            // Notify employee that justification was approved
            notificacionGenerator.notificarJustificacionAprobada(j);
            return true;
        }
        return false;
    }

    public boolean rechazar(int id, String comentario) {
        Optional<Justificacion> opt = justificacionRepository.findById(id);
        if (opt.isPresent()) {
            Justificacion j = opt.get();
            j.setEstado("RECHAZADA");
            j.setComentarioAprobacion(comentario);
            justificacionRepository.save(j);

            // Notify employee that justification was rejected
            notificacionGenerator.notificarJustificacionRechazada(j, comentario);
            return true;
        }
        return false;
    }

    public long contarPendientes() {
        return justificacionRepository.countByEstado("PENDIENTE");
    }

    public List<Long> obtenerEstadisticasSolicitudes() {
        // [Pendiente, Aprobado, Rechazado]
        long pendientes = justificacionRepository.countByEstado("PENDIENTE");
        long aprobadas = justificacionRepository.countByEstado("ACEPTADA");
        long rechazadas = justificacionRepository.countByEstado("RECHAZADA");
        return List.of(pendientes, aprobadas, rechazadas);
    }
}
