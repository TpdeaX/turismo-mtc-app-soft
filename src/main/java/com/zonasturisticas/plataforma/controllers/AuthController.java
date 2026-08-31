package com.zonasturisticas.plataforma.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.EmpleadoService;
import com.zonasturisticas.plataforma.services.EmpresaService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/auth")
public class AuthController {

    private final EmpleadoService empleadoService;
    private final EmpresaService empresaService;

    public AuthController(EmpleadoService empleadoService, EmpresaService empresaService) {
        this.empleadoService = empleadoService;
        this.empresaService = empresaService;
    }

    @GetMapping
    public String auth(HttpSession session) {

        return "redirect:/login";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam("dni") String dni,
            @RequestParam("password") String password,
            @RequestParam(value = "empresaId", required = false) Integer empresaId,
            @RequestParam(value = "g-recaptcha-response", required = false) String recaptchaResponse,
            @RequestParam(value = "rememberMe", required = false) boolean rememberMe,
            HttpSession session,
            jakarta.servlet.http.HttpServletResponse response) {

        Empleado emp = empleadoService.validarLogin(dni, password);

        if (emp != null) {
            if (emp.isSuperAdmin() && (emp.getEmpresas() == null || emp.getEmpresas().isEmpty())) {
                emp.setEmpresas(new java.util.HashSet<>(empresaService.findAll()));
            }

            boolean empresaSeleccionValida = true;
            if (empresaId != null && empresaId > 0 && emp.getEmpresas() != null && !emp.getEmpresas().isEmpty()) {
                empresaSeleccionValida = emp.getEmpresas().stream().anyMatch(e -> e.getId() == empresaId);
            }

            if (!empresaSeleccionValida) {
                session.setAttribute("error", "No tienes acceso a la empresa seleccionada.");
                return "redirect:/login";
            }

            session.setAttribute("usuario", emp);

            // Contexto por empresa:
            // - 1 empresa: fija
            // - 2+ empresas: permitir modo "todas" (empresaActiva = null) o una seleccionada
            // - sin empresas: principal por defecto
            Empresa empresaActiva = null;
            if (emp.getEmpresas() == null || emp.getEmpresas().isEmpty()) {
                empresaActiva = empresaService.findPrincipal();
            } else if (emp.getEmpresas().size() == 1) {
                empresaActiva = emp.getEmpresas().iterator().next();
            } else if (empresaId != null && empresaId > 0) {
                for (Empresa empresa : emp.getEmpresas()) {
                    if (empresa.getId() == empresaId) {
                        empresaActiva = empresa;
                        break;
                    }
                }
            }

            session.setAttribute("empresaActiva", empresaActiva);
            if (emp.isSuperAdmin()) {
                session.setAttribute("empresasAdmin", new java.util.HashSet<>(empresaService.findAll()));
            } else {
                session.setAttribute("empresasAdmin", emp.getEmpresas());
            }
            session.setAttribute("esSuperAdmin", emp.isSuperAdmin());

            if (rememberMe) {
                // 30 dias en segundos
                int timeout = 30 * 24 * 60 * 60;
                session.setMaxInactiveInterval(timeout);

                // Persistir cookie SESSION (Spring Session) o JSESSIONID
                String encodedSessionId = java.util.Base64.getEncoder().encodeToString(session.getId().getBytes());

                jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("JSESSIONID", session.getId());
                cookie.setPath("/");
                cookie.setMaxAge(timeout);
                cookie.setHttpOnly(true);
                response.addCookie(cookie);

                // Por si acaso usan Spring Session con nombre SESSION
                jakarta.servlet.http.Cookie springCookie = new jakarta.servlet.http.Cookie("SESSION", encodedSessionId);
                springCookie.setPath("/");
                springCookie.setMaxAge(timeout);
                springCookie.setHttpOnly(true);
                response.addCookie(springCookie);
            }

            if ("ADMIN".equals(emp.getRol()) || "SUPER_ADMIN".equals(emp.getRol())) {
                return "redirect:/dashboard";
            } else if ("PERSONALIZADO".equals(emp.getRol())) {

                boolean puedeVerDash = emp.getPermisos().stream()
                        .anyMatch(p -> p.getNombre().equals("VER_DASHBOARD_TOTAL"));

                if (puedeVerDash) {
                    return "redirect:/dashboard";
                } else {
                    return "redirect:/empleado";
                }
            } else {

                return "redirect:/empleado";
            }

        } else {

            session.setAttribute("error", "Credenciales incorrectas");
            return "redirect:/login";
        }
    }
}
