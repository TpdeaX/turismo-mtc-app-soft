package com.zonasturisticas.plataforma.controllers.api;

import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.services.FerroviarioService;
import com.zonasturisticas.plataforma.services.RutaService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * Endpoints ligeros que alimentan los modales y las tablas desplegables del
 * panel sin recargar la pagina.
 */
@RestController
@RequestMapping("/api")
public class ApiController {

    private final RutaService rutaService;
    private final FerroviarioService ferroviarioService;

    public ApiController(RutaService rutaService, FerroviarioService ferroviarioService) {
        this.rutaService = rutaService;
        this.ferroviarioService = ferroviarioService;
    }

    /** Rutas de una estacion: alimenta el select en cascada del modal de zonas. */
    @GetMapping("/estaciones/{codigo}/rutas")
    public List<Map<String, Object>> rutasDeEstacion(@PathVariable Integer codigo) {
        return rutaService.listarPorEstacion(codigo).stream()
                .map(this::mapaRuta)
                .toList();
    }

    /** Horarios de un servicio: alimenta la fila desplegable de la tabla. */
    @GetMapping("/servicios/{codigo}/horarios")
    public List<Map<String, Object>> horariosDeServicio(@PathVariable Integer codigo) {
        return ferroviarioService.listarHorariosPorServicio(codigo).stream()
                .map(this::mapaHorario)
                .toList();
    }

    private Map<String, Object> mapaRuta(Ruta r) {
        return Map.of(
                "codigo", r.getCodigo(),
                "nombre", r.getNombre() == null ? "Ruta " + r.getCodigo() : r.getNombre(),
                "distanciaKm", r.getDistanciaKm(),
                "dificultad", r.getDificultad() == null ? "Fácil" : r.getDificultad(),
                "tiempoEstimado", r.getTiempoEstimado() == null ? "-" : r.getTiempoEstimado());
    }

    private Map<String, Object> mapaHorario(HorarioFerroviario h) {
        return Map.of(
                "codigo", h.getCodigo(),
                "salida", String.valueOf(h.getHoraSalida()),
                "llegada", String.valueOf(h.getHoraLlegada()),
                "duracion", h.getDuracionTexto(),
                "tarifa", h.getTarifa(),
                "frecuencia", h.getFrecuencia() == null ? "Diario" : h.getFrecuencia(),
                "estado", h.getEstado() == null ? "ACTIVO" : h.getEstado());
    }
}
