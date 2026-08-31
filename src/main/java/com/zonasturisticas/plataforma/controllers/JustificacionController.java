package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Justificacion;
import com.zonasturisticas.plataforma.services.ExportService;
import com.zonasturisticas.plataforma.services.JustificacionService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.data.domain.Page;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

@Controller
@RequestMapping("/justificaciones")
public class JustificacionController {

    private final JustificacionService justificacionService;

    // ... existing constructor ...
    private final ExportService exportService;

    public JustificacionController(JustificacionService justificacionService, ExportService exportService) {
        this.justificacionService = justificacionService;
        this.exportService = exportService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @PostMapping
    public String filtrar(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String fechaSolicitud,
            @RequestParam(required = false) String fechaInicio,
            @RequestParam(required = false) String fechaFin,
            @RequestParam(required = false) String estado,
            HttpSession session) {

        session.setAttribute("just_page", page);
        session.setAttribute("just_size", size);
        session.setAttribute("just_keyword", keyword);
        session.setAttribute("just_fechaSolicitud", fechaSolicitud);
        session.setAttribute("just_fechaInicio", fechaInicio);
        session.setAttribute("just_fechaFin", fechaFin);
        session.setAttribute("just_estado", estado);

        return "redirect:/justificaciones";
    }

    @GetMapping
    public String listar(HttpSession session, Model model,
            @RequestParam(required = false) String keywordParam, // Detect legacy/direct links
            @RequestParam(required = false) String estadoParam) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        // Legacy/Direct Link Support:
        if (keywordParam != null || estadoParam != null) {
            if (keywordParam != null)
                session.setAttribute("just_keyword", keywordParam);
            if (estadoParam != null)
                session.setAttribute("just_estado", estadoParam);
            return "redirect:/justificaciones";
        }

        Empleado usuario = (Empleado) session.getAttribute("usuario");

        // Recover from Session
        Integer pageObj = (Integer) session.getAttribute("just_page");
        int page = (pageObj != null) ? pageObj : 0;

        Integer sizeObj = (Integer) session.getAttribute("just_size");
        int size = (sizeObj != null) ? sizeObj : 10;
        if (size < 1)
            size = 10;
        if (size > 100)
            size = 100;

        String keyword = (String) session.getAttribute("just_keyword");
        if (keyword == null)
            keyword = "";

        String fechaSolicitud = (String) session.getAttribute("just_fechaSolicitud");
        String fechaInicio = (String) session.getAttribute("just_fechaInicio");
        String fechaFin = (String) session.getAttribute("just_fechaFin");
        String estado = (String) session.getAttribute("just_estado");

        Page<Justificacion> pageRes;
        Integer empId = null;

        if (!"ADMIN".equals(usuario.getRol()) && !"JEFE".equals(usuario.getRol())) {
            empId = usuario.getId();
        }

        pageRes = justificacionService.listarAvanzado(empId, keyword, fechaSolicitud, fechaInicio, fechaFin, estado,
                page, size);

        model.addAttribute("lista", pageRes.getContent());
        model.addAttribute("pagina", pageRes);

        // Pass back to view for form population
        model.addAttribute("keyword", keyword);
        model.addAttribute("fechaSolicitud", fechaSolicitud);
        model.addAttribute("fechaInicio", fechaInicio);
        model.addAttribute("fechaFin", fechaFin);
        model.addAttribute("estado", estado);
        model.addAttribute("size", size);

        return "views/justificaciones/lista";
    }

    @RequestMapping(value = "/export/excel", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<byte[]> exportarExcel(HttpSession session) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        Integer empId = null;
        if (!"ADMIN".equals(usuario.getRol()) && !"JEFE".equals(usuario.getRol())) {
            empId = usuario.getId();
        }

        // NOTA: Aquí estás leyendo de la SESIÓN, no de lo que envía el formulario en ese instante.
        // Asegúrate de que los datos en sesión estén actualizados.
        String keyword = (String) session.getAttribute("just_keyword");
        if (keyword == null) keyword = "";
        
        String fechaSolicitud = (String) session.getAttribute("just_fechaSolicitud");
        String fechaInicio = (String) session.getAttribute("just_fechaInicio");
        String fechaFin = (String) session.getAttribute("just_fechaFin");
        String estado = (String) session.getAttribute("just_estado");

        List<Justificacion> list = justificacionService.listarAvanzadoSinPaginacion(empId, keyword, fechaSolicitud,
                fechaInicio, fechaFin, estado);

        try {
            byte[] bytes = exportService.generateJustificacionesExcel(list);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=justificaciones.xlsx")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

 
    @RequestMapping(value = "/export/pdf", method = {RequestMethod.GET, RequestMethod.POST})
    public ResponseEntity<byte[]> exportarPdf(HttpSession session) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        Integer empId = null;
        if (!"ADMIN".equals(usuario.getRol()) && !"JEFE".equals(usuario.getRol())) {
            empId = usuario.getId();
        }

        String keyword = (String) session.getAttribute("just_keyword");
        if (keyword == null) keyword = "";
        
        String fechaSolicitud = (String) session.getAttribute("just_fechaSolicitud");
        String fechaInicio = (String) session.getAttribute("just_fechaInicio");
        String fechaFin = (String) session.getAttribute("just_fechaFin");
        String estado = (String) session.getAttribute("just_estado");

        List<Justificacion> list = justificacionService.listarAvanzadoSinPaginacion(empId, keyword, fechaSolicitud,
                fechaInicio, fechaFin, estado);

        try {
            byte[] bytes = exportService.generateJustificacionesPdf(list);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=justificaciones.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
    @GetMapping("/nuevo")
    public String nuevo(HttpSession session, Model model, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
      
        if ("JEFE".equals(usuario.getRol()) || "ADMIN".equals(usuario.getRol())) {
            flash.addFlashAttribute("mensaje",
                    "Los Administradores y Jefes no pueden crear solicitudes de justificación.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/justificaciones";
        }

        model.addAttribute("justificacion", new Justificacion());
        return "views/justificaciones/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Justificacion justificacion,
            @RequestParam(value = "evidencia", required = false) MultipartFile evidencia,
            HttpSession session,
            RedirectAttributes flash,
            Model model) {

        if (!checkSession(session))
            return "redirect:/index.jsp";
        Empleado usuario = (Empleado) session.getAttribute("usuario");

        // Set default values if new
        if (justificacion.getId() == 0) {
            // New Justification Checks

            // 1. Restrict JEFE and ADMIN
            if ("JEFE".equals(usuario.getRol()) || "ADMIN".equals(usuario.getRol())) {
                flash.addFlashAttribute("mensaje", "Acción no permitida para Administradores o Jefes.");
                flash.addFlashAttribute("tipoMensaje", "error");
                return "redirect:/justificaciones";
            }

            // 2. Mandatory File
            if (evidencia == null || evidencia.isEmpty()) {
                model.addAttribute("mensaje", "Es OBLIGATORIO subir un archivo de evidencia.");
                model.addAttribute("tipoMensaje", "error");
                model.addAttribute("justificacion", justificacion); // Preserve input
                return "views/justificaciones/formulario"; // Return view directly
            }

            justificacion.setEmpleado(usuario);
            justificacion.setEstado("PENDIENTE");
        } else {
            // If editing, ensure we don't overwrite critical fields if they aren't in form
            // (though they should be)
            // Ideally we'd fetch and update, but for now assuming hidden fields or
            // re-submission
            Justificacion existing = justificacionService.obtenerPorId(justificacion.getId());
            if (existing != null) {
                justificacion.setEmpleado(existing.getEmpleado());
                justificacion.setEstado(existing.getEstado()); // Keep status or reset to Pending? Usually reset to
                                                               // Pending if edited.
                justificacion.setFechaSolicitud(existing.getFechaSolicitud());
                if (evidencia == null || evidencia.isEmpty()) {
                    justificacion.setEvidenciaUrl(existing.getEvidenciaUrl());
                }
            }
        }

        if (evidencia != null && !evidencia.isEmpty()) {
            String url = justificacionService.guardarEvidencia(evidencia);
            if (url != null) {
                justificacion.setEvidenciaUrl(url);
            }
        }

        justificacionService.guardar(justificacion);
        flash.addFlashAttribute("mensaje", "Justificación guardada correctamente.");
        flash.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/justificaciones";
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable int id, HttpSession session, Model model, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        Justificacion j = justificacionService.obtenerPorId(id);

        if (j == null) {
            flash.addFlashAttribute("error", "No encontrada");
            return "redirect:/justificaciones";
        }

        // Only owner can edit, and only if PENDING
        if (usuario.getId() != j.getEmpleado().getId()) {
            flash.addFlashAttribute("mensaje", "No tienes permiso para editar esta justificación.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/justificaciones";
        }

        if (!"PENDIENTE".equals(j.getEstado())) {
            flash.addFlashAttribute("mensaje", "No se puede editar una justificación que ya ha sido procesada.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/justificaciones";
        }

        model.addAttribute("justificacion", j);
        return "views/justificaciones/formulario";
    }

    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable int id, HttpSession session, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        Justificacion j = justificacionService.obtenerPorId(id);

        if (j != null) {
            // Only owner can delete
            if (usuario.getId() != j.getEmpleado().getId()) {
                flash.addFlashAttribute("mensaje", "No tienes permiso para eliminar esta justificación.");
                flash.addFlashAttribute("tipoMensaje", "error");
                return "redirect:/justificaciones";
            }

            // Only delete if PENDING
            if ("PENDIENTE".equals(j.getEstado())) {
                justificacionService.eliminar(id);
                flash.addFlashAttribute("mensaje", "Eliminado correctamente");
                flash.addFlashAttribute("tipoMensaje", "success");
            } else {
                flash.addFlashAttribute("mensaje", "No se puede eliminar una justificación procesada");
                flash.addFlashAttribute("tipoMensaje", "error");
            }
        }
        return "redirect:/justificaciones";
    }

    @PostMapping("/admin/{id}/aprobar")
    public String aprobar(@PathVariable int id, @RequestParam(value = "comentario", required = false) String comentario,
            HttpSession session, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (!"ADMIN".equals(usuario.getRol()) && !"JEFE".equals(usuario.getRol()))
            return "redirect:/justificaciones";

        justificacionService.aprobar(id, comentario);
        flash.addFlashAttribute("mensaje", "Justificación Aprobada");
        flash.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/justificaciones";
    }

    @PostMapping("/admin/{id}/rechazar")
    public String rechazar(@PathVariable int id,
            @RequestParam(value = "comentario", required = false) String comentario, HttpSession session,
            RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (!"ADMIN".equals(usuario.getRol()) && !"JEFE".equals(usuario.getRol()))
            return "redirect:/justificaciones";

        justificacionService.rechazar(id, comentario);
        flash.addFlashAttribute("mensaje", "Justificación Rechazada");
        flash.addFlashAttribute("tipoMensaje", "warning"); // Warning or success? Stick to existing pattern
        return "redirect:/justificaciones";
    }
}
