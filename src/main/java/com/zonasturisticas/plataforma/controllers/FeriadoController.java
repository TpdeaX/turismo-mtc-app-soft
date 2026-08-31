package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Feriado;
import com.zonasturisticas.plataforma.services.FeriadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/feriados")
public class FeriadoController {

    @Autowired
    private FeriadoService feriadoService;

    @Autowired
    private com.zonasturisticas.plataforma.services.EmpresaService empresaService;

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @SuppressWarnings("unchecked")
    private java.util.List<Integer> getEmpresaIds(HttpSession session) {
        com.zonasturisticas.plataforma.beans.Empleado usuario = (com.zonasturisticas.plataforma.beans.Empleado) session
                .getAttribute("usuario");
        if (usuario == null || usuario.getEmpresas() == null || usuario.getEmpresas().isEmpty()) {
            return java.util.Collections.emptyList();
        }

        // 1. Verificar si hay una empresa activa seleccionada en el contexto
        com.zonasturisticas.plataforma.beans.Empresa empresaActiva = (com.zonasturisticas.plataforma.beans.Empresa) session
                .getAttribute("empresaActiva");
        if (empresaActiva != null) {
            return java.util.Collections.singletonList(empresaActiva.getId());
        }

        // 2. Si no hay empresa activa (modo "Todas"), retornar todas las asignadas
        return usuario.getEmpresas().stream().map(com.zonasturisticas.plataforma.beans.Empresa::getId)
                .collect(java.util.stream.Collectors.toList());
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword,
            HttpSession session) {

        session.setAttribute("fer_page", page);
        session.setAttribute("fer_size", size);
        session.setAttribute("fer_keyword", keyword);
        return "redirect:/feriados";
    }

    @GetMapping
    public String listar(Model model,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String keywordParam,
            HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        Integer sessionPage = (Integer) session.getAttribute("fer_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("fer_size");
        int s = (sessionSize != null) ? sessionSize : 10;
        if (s < 1)
            s = 10;
        if (s > 100)
            s = 100;

        String k = (String) session.getAttribute("fer_keyword");
        if (k == null)
            k = "";

        java.util.List<Integer> empresaIds = getEmpresaIds(session);
        Page<Feriado> pageRes = feriadoService.listar(k, p, s, empresaIds);

        model.addAttribute("feriados", pageRes.getContent());
        model.addAttribute("pagina", pageRes);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
        return "views/feriados/lista";
    }

    @GetMapping("/nuevo")
    public String formularioNuevo(Model model, HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        com.zonasturisticas.plataforma.beans.Empleado usuario = (com.zonasturisticas.plataforma.beans.Empleado) session
                .getAttribute("usuario");
        model.addAttribute("empresas", usuario.getEmpresas());

        model.addAttribute("feriado", new Feriado());
        model.addAttribute("titulo", "Nuevo Feriado");
        return "views/feriados/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Feriado feriado,
            @RequestParam(required = false) java.util.List<Integer> empresaIds,
            HttpSession session,
            RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        // Populate companies
        if (empresaIds != null && !empresaIds.isEmpty()) {
            java.util.List<com.zonasturisticas.plataforma.beans.Empresa> empresasSeleccionadas = new java.util.ArrayList<>();
            for (Integer id : empresaIds) {
                empresaService.obtenerPorId(id).ifPresent(empresasSeleccionadas::add);
            }
            feriado.setEmpresas(empresasSeleccionadas);
        } else {
            // Fallback: if user has only 1 company and didn't select check boxes (maybe
            // hidden), reuse logic?
            // Or if checkboxes were unchecked, it means NONE.
            // Default logic: Assign to all user's companies if new? Or require selection?
            // Prompt: "si digamos es de solo un admin de una empresa, modificaria y
            // añadiria solo sus feriados de la empresa"

            // If empresaIds param is missing completely, check user's companies.
            java.util.List<Integer> userEmpresas = getEmpresaIds(session);
            if (userEmpresas.size() == 1) {
                // Auto-assign
                java.util.List<com.zonasturisticas.plataforma.beans.Empresa> autoList = new java.util.ArrayList<>();
                empresaService.obtenerPorId(userEmpresas.get(0)).ifPresent(autoList::add);
                feriado.setEmpresas(autoList);
            } else {
                if (feriado.getId() == 0) { // Only force on create? Or validation error?
                    // Let's assume empty list is valid (global?) or just empty.
                    // But for safety based on prompt, let's try to keep what's submitted.
                }
            }
        }

        try {
            feriadoService.guardar(feriado);
            flash.addFlashAttribute("mensaje", "Feriado guardado correctamente.");
            flash.addFlashAttribute("tipoMensaje", "success");
        } catch (Exception e) {
            flash.addFlashAttribute("mensaje", "Error al guardar (posible duplicado de fecha): " + e.getMessage());
            flash.addFlashAttribute("tipoMensaje", "error");
        }
        return "redirect:/feriados";
    }

    @GetMapping("/editar/{id}")
    public String formularioEditar(@PathVariable int id, Model model, HttpSession session, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";
        try {
            Feriado feriado = feriadoService.obtenerPorId(id)
                    .orElseThrow(() -> new IllegalArgumentException("Feriado inválido Id:" + id));

            com.zonasturisticas.plataforma.beans.Empleado usuario = (com.zonasturisticas.plataforma.beans.Empleado) session
                    .getAttribute("usuario");
            model.addAttribute("empresas", usuario.getEmpresas());

            model.addAttribute("feriado", feriado);
            model.addAttribute("titulo", "Editar Feriado");
            return "views/feriados/formulario";
        } catch (Exception e) {
            flash.addFlashAttribute("mensaje", "Feriado no encontrado.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/feriados";
        }
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam int id, HttpSession session, RedirectAttributes flash) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        java.util.List<Integer> empresaIds = getEmpresaIds(session);
        Feriado feriado = feriadoService.obtenerPorId(id).orElse(null);
        if (feriado == null) {
            flash.addFlashAttribute("mensaje", "Feriado no encontrado.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/feriados";
        }

        boolean permitido = feriado.getEmpresas() == null || feriado.getEmpresas().isEmpty() ||
                feriado.getEmpresas().stream().allMatch(e -> empresaIds.contains(e.getId()));

        try {
            if (!permitido) {
                flash.addFlashAttribute("mensaje", "No tienes permiso para eliminar este feriado.");
                flash.addFlashAttribute("tipoMensaje", "error");
            } else {
                feriadoService.eliminar(id);
                flash.addFlashAttribute("mensaje", "Feriado eliminado correctamente.");
                flash.addFlashAttribute("tipoMensaje", "success");
            }
        } catch (Exception e) {
            flash.addFlashAttribute("mensaje", "Error al eliminar feriado.");
            flash.addFlashAttribute("tipoMensaje", "error");
        }
        return "redirect:/feriados";
    }
}
