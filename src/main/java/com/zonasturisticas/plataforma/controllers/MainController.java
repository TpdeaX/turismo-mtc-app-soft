package com.zonasturisticas.plataforma.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.EmpresaService;
import jakarta.servlet.http.HttpSession;

import java.util.Comparator;
import java.util.List;

@Controller
public class MainController {

    private final EmpresaService empresaService;

    public MainController(EmpresaService empresaService) {
        this.empresaService = empresaService;
    }

    @GetMapping("/login")
    public String loginPage(@RequestParam(value = "empresa", required = false) String empresaCodigo,
            HttpSession session, Model model) {
        if (session.getAttribute("usuario") != null) {
            // Already logged in
            return "redirect:/dashboard";
        }

        Empresa loginEmpresa = null;
        boolean loginEmpresaFija = empresaCodigo != null && !empresaCodigo.isBlank();
        if (loginEmpresaFija) {
            loginEmpresa = empresaService.findByCodigo(empresaCodigo.trim()).orElse(null);
        }
        if (loginEmpresa == null) {
            loginEmpresa = empresaService.findPrincipal();
            loginEmpresaFija = false;
        }

        List<Empresa> empresasLogin = empresaService.findAll().stream()
                .sorted(Comparator.comparing(Empresa::getNombre, String.CASE_INSENSITIVE_ORDER))
                .toList();

        model.addAttribute("loginEmpresa", loginEmpresa);
        model.addAttribute("loginEmpresaFija", loginEmpresaFija);
        model.addAttribute("empresasLogin", empresasLogin);
        model.addAttribute("mostrarSelectorEmpresaLogin", !loginEmpresaFija && empresasLogin.size() > 1);
        return "index"; // Maps to /index.jsp
    }

    @GetMapping("/")
    public String root() {
        return "redirect:/login";
    }
}
