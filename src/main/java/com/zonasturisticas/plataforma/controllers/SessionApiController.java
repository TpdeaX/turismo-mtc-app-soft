package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.EmpresaService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/session")
public class SessionApiController {

    private final EmpresaService empresaService;

    public SessionApiController(EmpresaService empresaService) {
        this.empresaService = empresaService;
    }

    @PutMapping("/context/empresa/{id}")
    public ResponseEntity<Map<String, Object>> switchCompanyContext(@PathVariable("id") int id, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null) {
            response.put("success", false);
            response.put("message", "No hay sesion activa");
            return ResponseEntity.status(401).body(response);
        }

        // Modo "todas" para admins con acceso a varias empresas.
        if (id <= 0) {
            if (!usuario.isAdmin() || usuario.getEmpresas() == null || usuario.getEmpresas().size() < 2) {
                response.put("success", false);
                response.put("message", "No tienes acceso al modo multiempresa");
                return ResponseEntity.status(403).body(response);
            }
            session.setAttribute("empresaActiva", null);
            response.put("success", true);
            response.put("message", "Contexto actualizado: todas las empresas asignadas");
            return ResponseEntity.ok(response);
        }

        Optional<Empresa> nuevaEmpresaOpt = empresaService.findById(id);
        if (nuevaEmpresaOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "Empresa no encontrada");
            return ResponseEntity.badRequest().body(response);
        }

        if (!usuario.isSuperAdmin() && !usuario.tieneAccesoEmpresa(id)) {
            response.put("success", false);
            response.put("message", "No tienes acceso a esta empresa");
            return ResponseEntity.status(403).body(response);
        }

        Empresa nuevaEmpresa = nuevaEmpresaOpt.get();
        session.setAttribute("empresaActiva", nuevaEmpresa);

        response.put("success", true);
        response.put("message", "Contexto de empresa actualizado a: " + nuevaEmpresa.getNombre());
        response.put("empresa", nuevaEmpresa);

        return ResponseEntity.ok(response);
    }
}
