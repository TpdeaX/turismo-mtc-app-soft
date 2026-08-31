package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.beans.Sucursal;
import com.zonasturisticas.plataforma.services.EmpresaService;
import com.zonasturisticas.plataforma.services.SucursalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import jakarta.servlet.http.HttpSession;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/sucursales")
public class SucursalController {

    @Autowired
    private SucursalService sucursalService;

    @Autowired
    private EmpresaService empresaService;

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    private List<Integer> getEmpresaIds(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || usuario.getEmpresas() == null) {
            return List.of();
        }

        Empresa empresaActiva = (Empresa) session.getAttribute("empresaActiva");
        if (empresaActiva != null) {
            return List.of(empresaActiva.getId());
        }

        return usuario.getEmpresas().stream()
                .map(Empresa::getId)
                .collect(Collectors.toList());
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer empresaId,
            HttpSession session) {

        session.setAttribute("suc_page", page);
        session.setAttribute("suc_size", size);
        session.setAttribute("suc_keyword", keyword);
        session.setAttribute("suc_empresaId", empresaId);
        return "redirect:/sucursales";
    }

    @GetMapping
    public String listar(@RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String keywordParam,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario != null && usuario.isAdmin() && !usuario.tieneAccesoTodasSucursales()) {
            return "redirect:/dashboard";
        }

        // Recover from session
        Integer sessionPage = (Integer) session.getAttribute("suc_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("suc_size");
        int s = (sessionSize != null) ? sessionSize : 5;
        if (s < 1)
            s = 5;
        if (s > 100)
            s = 100;

        String k = (String) session.getAttribute("suc_keyword");
        if (k == null)
            k = "";

        Integer empresaIdFilter = (Integer) session.getAttribute("suc_empresaId");

        Pageable pageable = PageRequest.of(p, s, Sort.by("id").descending());

        // Filtrar por empresas del usuario logueado
        List<Integer> empresaIds = getEmpresaIds(session);

        // Si hay filtro de empresa, verificar que el usuario tenga acceso a ella
        if (empresaIdFilter != null && empresaIdFilter > 0) {
            if (empresaIds.contains(empresaIdFilter)) {
                empresaIds = List.of(empresaIdFilter);
            } else {
                // Si el usuario selecciona una empresa a la que no tiene acceso (manipulación
                // manual)
                // Se podría retornar lista vacía o ignorar el filtro.
                // Aquí optamos por restringir a vacio para no mostrar data indebida.
                // EXCEPCION: Si el usuario es ADMIN global y tiene acceso a todas (aunque
                // getEmpresaIds debería devolver todas en ese caso?)
                // Revisando getEmpresaIds: return usuario.getEmpresas()...
                // Si el usuario tiene acceso total, getEmpresas() debería devolver todas?
                // Depende de la implementación de Usuario.
                // Asumimos que getEmpresaIds devuelve TODAS las permitidas.
                // Si el filtro no está en las permitidas, fallamos seguro.
                // Pero si acceso total significa "no checking", entonces getEmpresaIds podría
                // ser vacio?
                // Revisar "tieneAccesoTodasEmpresas()".
            }
        }

        // Fix logic: If admin has total access, maybe getEmpresaIds returns empty or
        // all?
        // Assuming getEmpresaIds returns the exhaustive list of allowed IDs.
        // If the user attempts to filter by an ID not in their allowed list, we set
        // target list to empty to return no results.
        if (empresaIdFilter != null && !empresaIds.contains(empresaIdFilter)) {
            // Edge case: if empresaIds is empty but user is super admin?
            // safe to default to empty result if not matched.
            if (!empresaIds.isEmpty()) {
                // Optimization: if we know it won't match, pass empty list
                // However, we can just let it filter by empty list.
                empresaIds = List.of();
            }
        } else if (empresaIdFilter != null) {
            empresaIds = List.of(empresaIdFilter);
        }

        // If empresaIds is empty (and user has no companies), logic handles it (returns
        // empty page).

        Page<Sucursal> pagina = sucursalService.listarPaginaPorEmpresas(empresaIds, k, pageable);

        model.addAttribute("sucursales", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
        model.addAttribute("empresaId", empresaIdFilter);

        // Agregar lista de empresas para el modal
        List<Empresa> empresas = empresaService.listarPorIds(empresaIds);
        model.addAttribute("empresas", empresas);

        return "views/sucursales/lista";
    }

    @GetMapping("/nuevo")
    public String formularioNuevo(Model model, HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario != null && usuario.isAdmin() && !usuario.tieneAccesoTodasSucursales()) {
            return "redirect:/dashboard";
        }

        model.addAttribute("sucursal", new Sucursal());
        model.addAttribute("titulo", "Nueva Sucursal");

        // Obtener las empresas del usuario para el selector
        List<Integer> empresaIds = getEmpresaIds(session);
        List<Empresa> empresas = empresaService.listarPorIds(empresaIds);
        model.addAttribute("empresas", empresas);

        return "views/sucursales/formulario";
    }

    @GetMapping("/editar/{id}")
    public String formularioEditar(@PathVariable int id, Model model, HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario != null && usuario.isAdmin() && !usuario.tieneAccesoTodasSucursales()) {
            return "redirect:/dashboard";
        }

        // Verificar que la sucursal pertenezca a las empresas del usuario
        List<Integer> empresaIds = getEmpresaIds(session);
        Sucursal sucursal = sucursalService.obtenerPorId(id).orElse(null);

        if (sucursal == null || sucursal.getEmpresa() == null ||
                !empresaIds.contains(sucursal.getEmpresa().getId())) {
            return "redirect:/sucursales?status=unauthorized";
        }

        model.addAttribute("sucursal", sucursal);
        model.addAttribute("titulo", "Editar Sucursal");

        List<Empresa> empresas = empresaService.listarPorIds(empresaIds);
        model.addAttribute("empresas", empresas);

        return "views/sucursales/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Sucursal sucursal,
            @RequestParam(required = false) Integer empresaId,
            HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario != null && usuario.isAdmin() && !usuario.tieneAccesoTodasSucursales()) {
            return "redirect:/dashboard";
        }

        List<Integer> empresaIds = getEmpresaIds(session);

        // Validar que la empresa seleccionada pertenezca al usuario
        if (empresaId != null && empresaIds.contains(empresaId)) {
            Empresa empresa = empresaService.obtenerPorId(empresaId).orElse(null);
            sucursal.setEmpresa(empresa);
        } else if (empresaIds.size() == 1) {
            // Si el usuario solo tiene una empresa, asignarla automáticamente
            Empresa empresa = empresaService.obtenerPorId(empresaIds.get(0)).orElse(null);
            sucursal.setEmpresa(empresa);
        }

        boolean isNew = sucursal.getId() == 0;
        sucursalService.guardar(sucursal);
        return "redirect:/sucursales?status=" + (isNew ? "created" : "updated");
    }

    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable int id, HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario != null && usuario.isAdmin() && !usuario.tieneAccesoTodasSucursales()) {
            return "redirect:/dashboard";
        }

        // Verificar que la sucursal pertenezca a las empresas del usuario
        List<Integer> empresaIds = getEmpresaIds(session);
        Sucursal sucursal = sucursalService.obtenerPorId(id).orElse(null);

        if (sucursal != null && sucursal.getEmpresa() != null &&
                empresaIds.contains(sucursal.getEmpresa().getId())) {
            sucursalService.eliminar(id);
            return "redirect:/sucursales?status=deleted";
        }
        return "redirect:/sucursales?status=unauthorized";
    }

    @PostMapping("/eliminar")
    public String eliminarPost(@RequestParam("id") int id, HttpSession session) {
        return eliminar(id, session);
    }
}
