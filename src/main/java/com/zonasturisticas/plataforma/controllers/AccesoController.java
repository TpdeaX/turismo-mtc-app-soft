package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.services.UsuarioService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * RNF06: autenticacion de los gestores autorizados para acceder al panel
 * administrativo de Travel Group Peru, PeruRail y el MTC.
 */
@Controller
public class AccesoController {

    private static final String ATTR_DESTINO = "destino_login";

    private final UsuarioService usuarioService;

    public AccesoController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping("/acceso")
    public String formulario(HttpSession session, HttpServletResponse response, Model model) {
        // Refuerzo ademas del fix de bfcache en app.js: evita que el navegador
        // restaure esta pagina (con el formulario ya enviado) desde su cache
        // de retroceso en lugar de volver a consultar si la sesion es valida.
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");

        if (session.getAttribute("usuario") != null) {
            return "redirect:/panel";
        }
        return "acceso/login";
    }

    @PostMapping("/acceso")
    public String autenticar(@RequestParam String correo,
            @RequestParam String password,
            HttpSession session, Model model) {

        Usuario usuario = usuarioService.autenticar(correo, password);
        if (usuario == null) {
            model.addAttribute("error", "Credenciales incorrectas o cuenta desactivada.");
            model.addAttribute("correo", correo);
            return "acceso/login";
        }
        session.setAttribute("usuario", usuario);

        String destino = (String) session.getAttribute(ATTR_DESTINO);
        session.removeAttribute(ATTR_DESTINO);

        if (destino != null && destino.startsWith("/panel")) {
            return "redirect:" + destino;
        }
        return "redirect:/panel";
    }

    @GetMapping("/salir")
    public String salir(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }
}
