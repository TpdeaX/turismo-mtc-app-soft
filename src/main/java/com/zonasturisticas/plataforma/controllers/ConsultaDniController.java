package com.zonasturisticas.plataforma.controllers;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import com.zonasturisticas.plataforma.services.ConsultaDniService;
import com.zonasturisticas.plataforma.repositories.EmpleadoRepository;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/dni")
public class ConsultaDniController {

    private final ConsultaDniService consultaDniService;
    private final EmpleadoRepository empleadoRepository;

    public ConsultaDniController(ConsultaDniService consultaDniService, EmpleadoRepository empleadoRepository) {
        this.consultaDniService = consultaDniService;
        this.empleadoRepository = empleadoRepository;
    }

    @GetMapping("/{dni}")
    public ResponseEntity<Map<String, Object>> buscarDni(@PathVariable String dni) {
        Map<String, Object> response = consultaDniService.consultarDni(dni);
        if ((Boolean) response.get("ok")) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/check/{dni}")
    public ResponseEntity<Map<String, Boolean>> checkDuplicate(@PathVariable String dni) {
        boolean exists = empleadoRepository.existsByDni(dni);
        Map<String, Boolean> response = new HashMap<>();
        response.put("exists", exists);
        return ResponseEntity.ok(response);
    }
}
