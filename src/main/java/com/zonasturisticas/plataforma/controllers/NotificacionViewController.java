package com.zonasturisticas.plataforma.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Notificacion;
import com.zonasturisticas.plataforma.services.NotificacionService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/notificaciones")
public class NotificacionViewController {

    @Autowired
    private NotificacionService notificacionService;

    @GetMapping
    public String listaNotificaciones(HttpSession session, Model model) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            return "redirect:/login";
        }

        List<Notificacion> notificaciones = notificacionService.obtenerNotificacionesUsuario(
                usuario.getId(),
                usuario.getRol());

        long noLeidas = notificacionService.contarNoLeidas(usuario.getId(), usuario.getRol());

        model.addAttribute("notificaciones", notificaciones);
        model.addAttribute("noLeidas", noLeidas);
        model.addAttribute("total", notificaciones.size());

        return "views/notificaciones/lista";
    }
}
