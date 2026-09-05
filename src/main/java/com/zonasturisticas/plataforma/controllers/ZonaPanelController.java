package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.services.CategoriaService;
import com.zonasturisticas.plataforma.services.EstacionService;
import com.zonasturisticas.plataforma.services.RutaService;
import com.zonasturisticas.plataforma.services.ZonaTuristicaService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * RF08 / CU-04: modulo "Gestión de Zonas Turísticas" de Travel Group Peru.
 * Incluye tambien el mantenimiento de las rutas caminables (RF05) y del
 * catalogo de categorias de preferencia (RF01).
 */
@Controller
@RequestMapping("/panel")
public class ZonaPanelController {

    private final ZonaTuristicaService zonaService;
    private final RutaService rutaService;
    private final EstacionService estacionService;
    private final CategoriaService categoriaService;

    @Value("${app.upload.dir}")
    private String uploadDir;

    public ZonaPanelController(ZonaTuristicaService zonaService, RutaService rutaService,
            EstacionService estacionService, CategoriaService categoriaService) {
        this.zonaService = zonaService;
        this.rutaService = rutaService;
        this.estacionService = estacionService;
        this.categoriaService = categoriaService;
    }

    /* =========================== ZONAS =========================== */

    /** CU-04 paso 2: listado de zonas turisticas registradas. */
    @GetMapping("/zonas")
    public String zonas(Model model) {
        model.addAttribute("zonas", zonaService.listar());
        model.addAttribute("rutas", rutaService.listar());
        model.addAttribute("estaciones", estacionService.listar());
        model.addAttribute("categorias", categoriaService.listarDisponibles());
        return "panel/zonas";
    }

    /** CU-04 pasos 5 y 6: alta y edicion de una zona turistica. */
    @PostMapping("/zonas/guardar")
    public String guardarZona(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam(required = false) String descripcion,
            @RequestParam(required = false) String ubicacion,
            @RequestParam(required = false) String imagen,
            @RequestParam(required = false) String costoReferencial,
            @RequestParam(required = false) String latitud,
            @RequestParam(required = false) String longitud,
            @RequestParam Integer rutaCodigo,
            @RequestParam(value = "categorias", required = false) List<Integer> categorias,
            @RequestParam(required = false) String estado,
            RedirectAttributes flash) {

        try {
            ZonaTuristica zona = codigo == null ? new ZonaTuristica() : zonaService.obtener(codigo);
            if (zona == null) {
                throw new IllegalArgumentException("La zona turística indicada no existe.");
            }
            Ruta ruta = rutaService.obtener(rutaCodigo);
            if (ruta == null) {
                throw new IllegalArgumentException("Debe seleccionar una ruta válida.");
            }

            zona.setNombre(nombre);
            zona.setDescripcion(descripcion);
            zona.setUbicacion(ubicacion);
            zona.setImagen(imagen == null || imagen.isBlank() ? null : imagen.trim());
            zona.setRuta(ruta);
            zona.setEstado(estado != null);
            zona.setCostoReferencial(costoReferencial == null || costoReferencial.isBlank()
                    ? BigDecimal.ZERO : new BigDecimal(costoReferencial));
            zona.setLatitud(latitud == null || latitud.isBlank() ? null : Double.parseDouble(latitud));
            zona.setLongitud(longitud == null || longitud.isBlank() ? null : Double.parseDouble(longitud));

            zonaService.guardar(zona, categorias);

            flash.addFlashAttribute("toast", codigo == null
                    ? "Zona turística registrada correctamente."
                    : "Zona turística actualizada correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (NumberFormatException e) {
            flash.addFlashAttribute("toast", "El costo referencial y las coordenadas deben ser números válidos.");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/zonas";
    }

    /** RF08: subida de la fotografia de una zona (alternativa a pegar una URL). */
    @PostMapping("/zonas/imagen")
    @ResponseBody
    public ResponseEntity<Map<String, String>> subirImagenZona(@RequestParam("archivo") MultipartFile archivo) {
        if (archivo.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "No se recibió ningún archivo."));
        }
        String tipo = archivo.getContentType();
        if (tipo == null || !tipo.startsWith("image/")) {
            return ResponseEntity.badRequest().body(Map.of("error", "El archivo debe ser una imagen."));
        }
        try {
            Path carpeta = Path.of(uploadDir, "zonas");
            Files.createDirectories(carpeta);
            String nombreArchivo = UUID.randomUUID() + extensionDe(archivo.getOriginalFilename(), tipo);
            archivo.transferTo(carpeta.resolve(nombreArchivo));
            return ResponseEntity.ok(Map.of("url", "/uploads/zonas/" + nombreArchivo));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "No se pudo guardar la imagen."));
        }
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseBody
    public ResponseEntity<Map<String, String>> imagenDemasiadoGrande() {
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                .body(Map.of("error", "La imagen supera el tamaño máximo permitido (5 MB)."));
    }

    private String extensionDe(String nombreOriginal, String tipoContenido) {
        if (nombreOriginal != null) {
            int punto = nombreOriginal.lastIndexOf('.');
            if (punto >= 0) {
                String ext = nombreOriginal.substring(punto).toLowerCase();
                if (ext.matches("\\.(jpg|jpeg|png|gif|webp|avif)")) {
                    return ext;
                }
            }
        }
        return switch (tipoContenido) {
            case "image/png" -> ".png";
            case "image/gif" -> ".gif";
            case "image/webp" -> ".webp";
            case "image/avif" -> ".avif";
            default -> ".jpg";
        };
    }

    /** CU-04 flujo alternativo: eliminacion previa confirmacion. */
    @PostMapping("/zonas/eliminar")
    public String eliminarZona(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            zonaService.eliminar(codigo);
            flash.addFlashAttribute("toast", "Zona turística eliminada del listado.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", "No se pudo eliminar la zona: " + e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/zonas";
    }

    @PostMapping("/zonas/estado")
    public String alternarEstado(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            ZonaTuristica zona = zonaService.alternarEstado(codigo);
            flash.addFlashAttribute("toast", zona.isEstado()
                    ? "La zona ahora es visible para el usuario final."
                    : "La zona se retiró del listado público.");
            flash.addFlashAttribute("toastTipo", "info");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/zonas";
    }

    /* =========================== RUTAS =========================== */

    @GetMapping("/rutas")
    public String rutas(Model model) {
        model.addAttribute("rutas", rutaService.listar());
        model.addAttribute("estaciones", estacionService.listar());
        model.addAttribute("velocidad", rutaService.getVelocidadCaminata());
        return "panel/rutas";
    }

    @PostMapping("/rutas/guardar")
    public String guardarRuta(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam Integer estacionCodigo,
            @RequestParam String distanciaKm,
            @RequestParam String dificultad,
            RedirectAttributes flash) {
        try {
            Ruta ruta = codigo == null ? new Ruta() : rutaService.obtener(codigo);
            if (ruta == null) {
                throw new IllegalArgumentException("La ruta indicada no existe.");
            }
            var estacion = estacionService.obtener(estacionCodigo);
            if (estacion == null) {
                throw new IllegalArgumentException("Debe seleccionar una estación válida.");
            }
            BigDecimal distancia = new BigDecimal(distanciaKm);
            if (distancia.signum() <= 0) {
                throw new IllegalArgumentException("La distancia del tramo debe ser mayor a cero.");
            }
            ruta.setNombre(nombre);
            ruta.setEstacion(estacion);
            ruta.setDistanciaKm(distancia);
            ruta.setDificultad(dificultad);
            rutaService.guardar(ruta);

            flash.addFlashAttribute("toast", codigo == null
                    ? "Ruta caminable registrada. El tiempo estimado se calculó automáticamente."
                    : "Ruta actualizada. El tiempo estimado se recalculó automáticamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (NumberFormatException e) {
            flash.addFlashAttribute("toast", "La distancia debe ser un número válido (por ejemplo 2.50).");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/rutas";
    }

    @PostMapping("/rutas/eliminar")
    public String eliminarRuta(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            rutaService.eliminar(codigo);
            flash.addFlashAttribute("toast", "Ruta eliminada correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/rutas";
    }

    /* ========================= CATEGORIAS ======================== */

    @GetMapping("/categorias")
    public String categorias(Model model) {
        model.addAttribute("categorias", categoriaService.listarTodas());
        return "panel/categorias";
    }

    @PostMapping("/categorias/guardar")
    public String guardarCategoria(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam(required = false) String descripcion,
            @RequestParam(required = false) String icono,
            @RequestParam(required = false) String color,
            @RequestParam(required = false) String estado,
            RedirectAttributes flash) {
        try {
            Categoria categoria = codigo == null ? new Categoria() : categoriaService.obtener(codigo);
            if (categoria == null) {
                throw new IllegalArgumentException("La categoría indicada no existe.");
            }
            categoria.setNombre(nombre);
            categoria.setDescripcion(descripcion);
            categoria.setIcono(icono == null || icono.isBlank() ? "tour" : icono);
            categoria.setColor(color == null || color.isBlank() ? "#0A1F3D" : color);
            categoria.setEstado(estado != null);
            categoriaService.guardar(categoria);

            flash.addFlashAttribute("toast", "Categoría guardada correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", "No se pudo guardar la categoría: " + e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/categorias";
    }

    @PostMapping("/categorias/eliminar")
    public String eliminarCategoria(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            categoriaService.eliminar(codigo);
            flash.addFlashAttribute("toast", "Categoría eliminada.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast",
                    "No se puede eliminar: la categoría está asociada a zonas turísticas.");
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/categorias";
    }
}
