package com.zonasturisticas.plataforma.controllers;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.ConfiguracionService;
import com.zonasturisticas.plataforma.services.EmpresaService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/parametros")
public class ConfiguracionController {

    @Autowired
    private ConfiguracionService configuracionService;

    @Autowired
    private EmpresaService empresaService;

    /**
     * Determina el ID de empresa para configuraciones.
     * - Si admin tiene 1 sola empresa: retorna ese ID (configs específicas)
     * - Si admin tiene 2+ empresas: retorna null (configs globales)
     */
    private Integer getConfigEmpresaId(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || usuario.getEmpresas() == null) {
            return null;
        }

        // 1. Verificar si hay una empresa activa seleccionada en el contexto
        Empresa empresaActiva = (Empresa) session.getAttribute("empresaActiva");
        if (empresaActiva != null) {
            return empresaActiva.getId();
        }

        Set<Empresa> empresas = usuario.getEmpresas();
        if (empresas.size() == 1) {
            // Admin de una sola empresa: usa configs específicas de esa empresa
            return empresas.iterator().next().getId();
        }
        // Admin de múltiples empresas: usa configs globales (o All, si null)
        return null;
    }

    @GetMapping("/generales")
    public String verParametros(Model model, HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return "redirect:/index.jsp";
        }
        if (!usuario.tieneAccesoTotalSistema()) {
            return "redirect:/dashboard";
        }

        Integer empresaId = getConfigEmpresaId(session);
        Map<String, String> configs = configuracionService.getAllAsMap(empresaId);
        model.addAttribute("configs", configs);

        // Indicar al usuario qué tipo de configuración está viendo
        if (empresaId != null) {
            Empresa empresa = empresaService.obtenerPorId(empresaId).orElse(null);
            model.addAttribute("empresaActual", empresa);
            model.addAttribute("configTipo", "empresa");
        } else {
            model.addAttribute("configTipo", "global");
        }

        return "views/admin/parametros_generales";
    }

    @PostMapping("/generales/guardar")
    public String guardarParametros(@RequestParam Map<String, String> allParams,
            RedirectAttributes redirectAttributes, HttpSession session) {

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return "redirect:/index.jsp";
        }
        if (!usuario.tieneAccesoTotalSistema()) {
            return "redirect:/dashboard";
        }

        Integer empresaId = getConfigEmpresaId(session);

        // Explicitly handle known booleans
        String[] booleanKeys = {
                "descuento_falta_enabled",
                "descuento_tardanza_enabled",
                "ui_blur_modal",
                "asistencia_permitir_extras"
        };

        for (String key : booleanKeys) {
            String value = allParams.containsKey(key) ? "true" : "false";
            configuracionService.actualizarValor(key, value, empresaId);
        }

        // Handle text/number parameters
        String[] textKeys = {
                "asistencia_hora_entrada",
                "asistencia_tolerancia"
        };

        for (String key : textKeys) {
            if (allParams.containsKey(key)) {
                configuracionService.actualizarValor(key, allParams.get(key), empresaId);
            }
        }

        redirectAttributes.addFlashAttribute("mensaje", "Configuración guardada correctamente");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");

        return "redirect:/parametros/generales";
    }
}
