package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.beans.TipoTurno;
import com.zonasturisticas.plataforma.services.TipoTurnoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/tipoturno")
public class TipoTurnoController {

    private final TipoTurnoService tipoTurnoService;

    public TipoTurnoController(TipoTurnoService tipoTurnoService) {
        this.tipoTurnoService = tipoTurnoService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    private List<Integer> getEmpresaIds(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || usuario.getEmpresas() == null || usuario.getEmpresas().isEmpty()) {
            return List.of();
        }
        Empresa empresaActiva = (Empresa) session.getAttribute("empresaActiva");
        if (empresaActiva != null) {
            return List.of(empresaActiva.getId());
        }
        return usuario.getEmpresas().stream().map(Empresa::getId).toList();
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(defaultValue = "") String keyword,
            HttpSession session) {

        session.setAttribute("turno_page", page);
        session.setAttribute("turno_size", size);
        session.setAttribute("turno_keyword", keyword);
        return "redirect:/tipoturno";
    }

    @GetMapping
    public String listar(Model model, HttpSession session) {
        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        Integer sessionPage = (Integer) session.getAttribute("turno_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("turno_size");
        int s = (sessionSize != null) ? sessionSize : 5;
        if (s < 1) {
            s = 5;
        }
        if (s > 100) {
            s = 100;
        }

        String k = (String) session.getAttribute("turno_keyword");
        if (k == null) {
            k = "";
        }

        Pageable pageable = PageRequest.of(p, s);
        Page<TipoTurno> pagina = tipoTurnoService.listarTiposPorEmpresas(pageable, k, getEmpresaIds(session));

        model.addAttribute("lista", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
        model.addAttribute("tipos", pagina.getContent());
        return "views/admin/gestion_tipoturno";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute TipoTurno tipoTurno, HttpSession session,
            RedirectAttributes redirectAttributes) {
        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        Empresa empresaActiva = (Empresa) session.getAttribute("empresaActiva");
        if (tipoTurno.getId() == 0) {
            // Sin empresa activa => tipo general
            tipoTurno.setEmpresa(empresaActiva);
        } else {
            TipoTurno existente = tipoTurnoService.obtenerPorId(tipoTurno.getId());
            if (existente != null) {
                tipoTurno.setEmpresa(existente.getEmpresa());
            }
        }

        tipoTurnoService.guardarTipo(tipoTurno);
        redirectAttributes.addFlashAttribute("mensaje", "Tipo de turno guardado correctamente.");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/tipoturno";
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id, HttpSession session, RedirectAttributes redirectAttributes) {
        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        TipoTurno existente = tipoTurnoService.obtenerPorId(id);
        List<Integer> empresaIds = getEmpresaIds(session);
        boolean permitido = existente == null ||
                existente.getEmpresa() == null ||
                empresaIds.contains(existente.getEmpresa().getId());

        if (!permitido) {
            redirectAttributes.addFlashAttribute("mensaje", "No tienes permiso para eliminar este turno.");
            redirectAttributes.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/tipoturno";
        }

        tipoTurnoService.eliminarTipo(id);
        redirectAttributes.addFlashAttribute("mensaje", "Tipo de turno eliminado correctamente.");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/tipoturno";
    }
}
