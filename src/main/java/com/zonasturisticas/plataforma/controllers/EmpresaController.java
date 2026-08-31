package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.EmpresaService;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Controller
@RequestMapping("/empresas")
public class EmpresaController {

    private final EmpresaService empresaService;

    public EmpresaController(EmpresaService empresaService) {
        this.empresaService = empresaService;
    }

    private Empleado getUsuario(HttpSession session) {
        return (Empleado) session.getAttribute("usuario");
    }

    private boolean isSuperAdmin(HttpSession session) {
        Empleado usuario = getUsuario(session);
        return usuario != null && usuario.isSuperAdmin();
    }

    private boolean puedeGestionarEmpresa(HttpSession session, int empresaId) {
        Empleado usuario = getUsuario(session);
        return usuario != null && (usuario.isSuperAdmin() || usuario.tieneAccesoEmpresa(empresaId));
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String keyword,
            HttpSession session) {

        session.setAttribute("emp_page", page);
        session.setAttribute("emp_size", size);
        session.setAttribute("emp_keyword", keyword);
        return "redirect:/empresas";
    }

    @GetMapping
    public String listar(Model model, HttpSession session) {
        Empleado usuario = getUsuario(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        Integer sessionPage = (Integer) session.getAttribute("emp_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("emp_size");
        int s = (sessionSize != null) ? sessionSize : 5;
        if (s < 1) {
            s = 5;
        }
        if (s > 100) {
            s = 100;
        }

        String k = (String) session.getAttribute("emp_keyword");
        if (k == null) {
            k = "";
        }

        Page<Empresa> pagina;
        if (usuario.isSuperAdmin()) {
            Pageable pageable = PageRequest.of(p, s, Sort.by("id").descending());
            pagina = empresaService.listarPagina(k, pageable);
        } else if ("ADMIN".equals(usuario.getRol())) {
            Set<Integer> ids = usuario.getEmpresaIdsAsignadas();
            if (ids.isEmpty()) {
                return "redirect:/dashboard";
            }

            List<Empresa> empresas = empresaService.listarPorIds(new ArrayList<>(ids));
            if (!k.isBlank()) {
                String keyword = k.toLowerCase();
                empresas = empresas.stream()
                        .filter(e -> (e.getNombre() != null && e.getNombre().toLowerCase().contains(keyword))
                                || (e.getCodigo() != null && e.getCodigo().toLowerCase().contains(keyword))
                                || (e.getRuc() != null && e.getRuc().toLowerCase().contains(keyword)))
                        .toList();
            }
            empresas = empresas.stream().sorted((a, b) -> Integer.compare(b.getId(), a.getId())).toList();

            int start = Math.min(p * s, empresas.size());
            int end = Math.min(start + s, empresas.size());
            List<Empresa> content = empresas.subList(start, end);
            pagina = new PageImpl<>(content, PageRequest.of(p, s), empresas.size());
        } else {
            return "redirect:/dashboard";
        }

        model.addAttribute("empresas", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
        model.addAttribute("puedeCrearEliminar", isSuperAdmin(session));

        return "views/empresas/lista";
    }

    @GetMapping("/nuevo")
    public String formularioNuevo(Model model, HttpSession session) {
        if (!isSuperAdmin(session)) {
            return "redirect:/empresas";
        }

        model.addAttribute("empresa", new Empresa());
        model.addAttribute("modoEdicion", false);
        return "views/empresas/formulario";
    }

    @GetMapping("/editar/{id}")
    public String formularioEditar(@PathVariable("id") int id, Model model, HttpSession session) {
        if (!puedeGestionarEmpresa(session, id)) {
            return "redirect:/empresas";
        }

        Optional<Empresa> empresa = empresaService.findById(id);
        if (empresa.isEmpty()) {
            return "redirect:/empresas";
        }

        model.addAttribute("empresa", empresa.get());
        model.addAttribute("modoEdicion", true);
        model.addAttribute("puedeCrearEliminar", isSuperAdmin(session));
        return "views/empresas/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Empresa empresa, HttpSession session) {
        Empleado usuario = getUsuario(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        if (empresa.getId() == 0 && !usuario.isSuperAdmin()) {
            return "redirect:/empresas";
        }

        if (empresa.getId() > 0 && !puedeGestionarEmpresa(session, empresa.getId())) {
            return "redirect:/empresas";
        }

        if (empresa.isUsarMismoLogoOscuro()) {
            empresa.setLogoDarkPath(empresa.getLogoPath());
        }
        if (empresa.isUsarMismoIconoOscuro()) {
            empresa.setIconDarkPath(empresa.getIconPath());
        }

        empresaService.save(empresa);
        return "redirect:/empresas";
    }

    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable("id") int id, HttpSession session) {
        if (!isSuperAdmin(session)) {
            return "redirect:/empresas";
        }

        Optional<Empresa> empresa = empresaService.findById(id);
        if (empresa.isPresent() && !empresa.get().isEsPrincipal()) {
            empresaService.deleteById(id);
        }

        return "redirect:/empresas";
    }
}
