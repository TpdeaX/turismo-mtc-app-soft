package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.EmpresaService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/empresas")
public class EmpresaApiController {

    private final EmpresaService empresaService;

    public EmpresaApiController(EmpresaService empresaService) {
        this.empresaService = empresaService;
    }

    private Empleado getUsuario(HttpSession session) {
        return (Empleado) session.getAttribute("usuario");
    }

    private boolean puedeGestionarEmpresa(HttpSession session, int empresaId) {
        Empleado usuario = getUsuario(session);
        return usuario != null && (usuario.isSuperAdmin() || usuario.tieneAccesoEmpresa(empresaId));
    }

    private boolean puedeCrearEliminar(HttpSession session) {
        Empleado usuario = getUsuario(session);
        return usuario != null && usuario.isSuperAdmin();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getEmpresa(@PathVariable("id") int id, HttpSession session) {
        if (!puedeGestionarEmpresa(session, id)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Acceso denegado"));
        }

        Optional<Empresa> empresa = empresaService.findById(id);
        if (empresa.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("success", false, "message", "Empresa no encontrada"));
        }
        return ResponseEntity.ok(empresa.get());
    }

    @PostMapping
    public ResponseEntity<?> crearEmpresa(@RequestBody Empresa empresa, HttpSession session) {
        if (!puedeCrearEliminar(session)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Solo SUPER_ADMIN puede crear empresas"));
        }
        return guardarInterno(0, empresa);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarEmpresa(@PathVariable("id") int id, @RequestBody Empresa empresa,
            HttpSession session) {
        if (!puedeGestionarEmpresa(session, id)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Acceso denegado"));
        }
        return guardarInterno(id, empresa);
    }

    private ResponseEntity<?> guardarInterno(int id, Empresa empresa) {
        try {
            if (empresa.getCodigo() == null || empresa.getCodigo().trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "El código es requerido"));
            }
            if (empresa.getNombre() == null || empresa.getNombre().trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "El nombre es requerido"));
            }

            if (empresa.getColorPrimario() == null || empresa.getColorPrimario().isEmpty()) {
                empresa.setColorPrimario("#EC407A");
            }
            if (empresa.getColorSecundario() == null || empresa.getColorSecundario().isEmpty()) {
                empresa.setColorSecundario("#BA68C8");
            }
            if (empresa.isUsarMismoLogoOscuro()) {
                empresa.setLogoDarkPath(empresa.getLogoPath());
            }
            if (empresa.isUsarMismoIconoOscuro()) {
                empresa.setIconDarkPath(empresa.getIconPath());
            }

            if (id > 0) {
                if (empresaService.findById(id).isEmpty()) {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND)
                            .body(Map.of("success", false, "message", "Empresa no encontrada"));
                }
                empresa.setId(id);
            }

            Empresa saved = empresaService.save(empresa);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", id > 0 ? "Empresa actualizada exitosamente" : "Empresa creada exitosamente",
                    "empresa", saved));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "Error al guardar empresa: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarEmpresa(@PathVariable("id") int id, HttpSession session) {
        if (!puedeCrearEliminar(session)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Solo SUPER_ADMIN puede eliminar empresas"));
        }

        try {
            Optional<Empresa> empresa = empresaService.findById(id);
            if (empresa.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("success", false, "message", "Empresa no encontrada"));
            }
            if (empresa.get().isEsPrincipal()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "No se puede eliminar la empresa principal"));
            }

            empresaService.deleteById(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Empresa eliminada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "Error al eliminar empresa: " + e.getMessage()));
        }
    }

    @PostMapping("/upload-logo")
    public ResponseEntity<?> uploadLogo(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file,
            @RequestParam("codigo") String codigo,
            HttpSession session) {

        Empleado usuario = getUsuario(session);
        if (usuario == null || !usuario.isAdmin()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Acceso denegado"));
        }

        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "No se proporcionó ningún archivo"));
            }
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "El archivo debe ser una imagen"));
            }
            if (file.getSize() > 2 * 1024 * 1024) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "El archivo es demasiado grande (máx 2MB)"));
            }

            java.nio.file.Path logosDir = java.nio.file.Paths.get("uploads", "logos");
            if (!java.nio.file.Files.exists(logosDir)) {
                java.nio.file.Files.createDirectories(logosDir);
            }

            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".png";
            String filename = "logo-" + codigo.toLowerCase().replaceAll("[^a-z0-9]", "-") + extension;

            java.nio.file.Path filePath = logosDir.resolve(filename);
            java.nio.file.Files.copy(file.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);

            return ResponseEntity.ok(Map.of("success", true, "message", "Logo subido exitosamente", "filename", filename));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "Error al subir logo: " + e.getMessage()));
        }
    }

    @PostMapping("/upload-image")
    public ResponseEntity<?> uploadImage(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file,
            @RequestParam("codigo") String codigo,
            @RequestParam("variant") String variant,
            HttpSession session) {

        Empleado usuario = getUsuario(session);
        if (usuario == null || !usuario.isAdmin()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Acceso denegado"));
        }

        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "No se proporcionó ningún archivo"));
            }
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "El archivo debe ser una imagen"));
            }
            if (file.getSize() > 2 * 1024 * 1024) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "El archivo es demasiado grande (máx 2MB)"));
            }

            if (variant == null || variant.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "El tipo de imagen es requerido"));
            }

            String safeVariant = variant.toLowerCase().replaceAll("[^a-z0-9_\\-]", "");
            if (!(safeVariant.equals("logo_light")
                    || safeVariant.equals("logo_dark")
                    || safeVariant.equals("icon_light")
                    || safeVariant.equals("icon_dark"))) {
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "Tipo de imagen inválido"));
            }

            java.nio.file.Path logosDir = java.nio.file.Paths.get("uploads", "logos");
            if (!java.nio.file.Files.exists(logosDir)) {
                java.nio.file.Files.createDirectories(logosDir);
            }

            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".png";
            String safeCode = codigo == null ? "" : codigo.toLowerCase().replaceAll("[^a-z0-9]", "-");
            String filename = safeVariant + "-" + safeCode + extension;

            java.nio.file.Path filePath = logosDir.resolve(filename);
            java.nio.file.Files.copy(file.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);

            return ResponseEntity.ok(Map.of("success", true, "message", "Imagen subida exitosamente", "filename", filename));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "Error al subir imagen: " + e.getMessage()));
        }
    }
}
