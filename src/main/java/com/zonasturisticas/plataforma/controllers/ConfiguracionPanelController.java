package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.services.ConfiguracionService;
import com.zonasturisticas.plataforma.services.UsuarioService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.Map;

/**
 * RF12: panel de configuracion de parametros generales de la plataforma y
 * administracion de los gestores autorizados (RNF06).
 */
@Controller
@RequestMapping("/panel")
public class ConfiguracionPanelController {

    private final ConfiguracionService configuracionService;
    private final UsuarioService usuarioService;

    public ConfiguracionPanelController(ConfiguracionService configuracionService, UsuarioService usuarioService) {
        this.configuracionService = configuracionService;
        this.usuarioService = usuarioService;
    }

    /* ========================= PARAMETROS ======================== */

    @GetMapping("/parametros")
    public String parametros(Model model) {
        model.addAttribute("grupos", configuracionService.listarAgrupado());
        return "panel/parametros";
    }

    /** Guarda de una sola vez todos los parametros del panel. */
    @PostMapping("/parametros/guardar")
    public String guardarParametros(@RequestParam Map<String, String> formulario, RedirectAttributes flash) {
        Map<String, String> valores = new HashMap<>();
        for (Map.Entry<String, String> e : formulario.entrySet()) {
            if (e.getKey().startsWith("param.")) {
                valores.put(e.getKey().substring("param.".length()), e.getValue());
            }
        }
        // Los interruptores no enviados equivalen a "false"
        for (var c : configuracionService.listar()) {
            if (c.isBooleano() && !valores.containsKey(c.getClave())) {
                valores.put(c.getClave(), "false");
            }
        }
        int n = configuracionService.actualizarLote(valores);
        flash.addFlashAttribute("toast", "Se actualizaron " + n + " parámetro(s) de la plataforma.");
        flash.addFlashAttribute("toastTipo", "success");
        return "redirect:/panel/parametros";
    }

    @PostMapping("/parametros/individual")
    public String guardarParametro(@RequestParam String clave, @RequestParam(required = false) String valor,
            RedirectAttributes flash) {
        configuracionService.actualizarValor(clave, valor == null ? "" : valor);
        flash.addFlashAttribute("toast", "Parámetro \"" + clave + "\" actualizado.");
        flash.addFlashAttribute("toastTipo", "success");
        return "redirect:/panel/parametros";
    }

    /* ========================== GESTORES ========================= */

    @GetMapping("/gestores")
    public String gestores(Model model) {
        model.addAttribute("gestores", usuarioService.listar());
        return "panel/gestores";
    }

    @PostMapping("/gestores/guardar")
    public String guardarGestor(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam String correo,
            @RequestParam(required = false) String password,
            @RequestParam String rol,
            @RequestParam(required = false) String estado,
            RedirectAttributes flash) {
        try {
            Usuario usuario = codigo == null ? new Usuario() : usuarioService.obtener(codigo);
            if (usuario == null) {
                throw new IllegalArgumentException("El gestor indicado no existe.");
            }
            usuario.setNombre(nombre);
            usuario.setCorreo(correo.trim());
            usuario.setRol(rol);
            usuario.setEstado(estado != null);
            usuarioService.guardar(usuario, password);

            flash.addFlashAttribute("toast", "Gestor guardado correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/gestores";
    }

    @PostMapping("/gestores/eliminar")
    public String eliminarGestor(@RequestParam Integer codigo, HttpSession session, RedirectAttributes flash) {
        Usuario sesion = (Usuario) session.getAttribute("usuario");
        if (sesion != null && sesion.getCodigo().equals(codigo)) {
            flash.addFlashAttribute("toast", "No puede eliminar su propia cuenta mientras está en sesión.");
            flash.addFlashAttribute("toastTipo", "error");
            return "redirect:/panel/gestores";
        }
        try {
            usuarioService.eliminar(codigo);
            flash.addFlashAttribute("toast", "Gestor eliminado.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/gestores";
    }
}
