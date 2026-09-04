package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.services.UsuarioService;
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

    private final UsuarioService usuarioService;

    public AccesoController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping("/acceso")
    public String formulario(@RequestParam(value = "destino", required = false) String destino,
            HttpSession session, Model model) {
        if (session.getAttribute("usuario") != null) {
            return "redirect:/panel";
        }
        model.addAttribute("destino", destino);
        return "acceso/login";
    }

    @PostMapping("/acceso")
    public String autenticar(@RequestParam String correo,
            @RequestParam String password,
            @RequestParam(value = "destino", required = false) String destino,
            HttpSession session, Model model) {

        Usuario usuario = usuarioService.autenticar(correo, password);
        if (usuario == null) {
            model.addAttribute("error", "Credenciales incorrectas o cuenta desactivada.");
            model.addAttribute("correo", correo);
            model.addAttribute("destino", destino);
            return "acceso/login";
        }
        session.setAttribute("usuario", usuario);

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
