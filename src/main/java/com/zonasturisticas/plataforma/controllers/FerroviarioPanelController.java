package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.ServicioFerroviario;
import com.zonasturisticas.plataforma.services.EstacionService;
import com.zonasturisticas.plataforma.services.FerroviarioService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalTime;

/**
 * RF09 / CU-05: consulta del listado de estaciones (solo lectura para Travel
 * Group Peru; mantenimiento reservado al administrador).
 * RF13: mantenimiento de servicios, horarios y tarifas por parte de PeruRail.
 */
@Controller
@RequestMapping("/panel")
public class FerroviarioPanelController {

    private final EstacionService estacionService;
    private final FerroviarioService ferroviarioService;

    public FerroviarioPanelController(EstacionService estacionService, FerroviarioService ferroviarioService) {
        this.estacionService = estacionService;
        this.ferroviarioService = ferroviarioService;
    }

    /* ========================= ESTACIONES ======================== */

    /** CU-05: listado de estaciones con buscador. */
    @GetMapping("/estaciones")
    public String estaciones(@RequestParam(value = "q", required = false) String q, Model model) {
        model.addAttribute("estaciones", estacionService.buscar(q));
        model.addAttribute("regiones", estacionService.listarRegiones());
        model.addAttribute("q", q);
        return "panel/estaciones";
    }

    @PostMapping("/estaciones/guardar")
    public String guardarEstacion(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam String ubicacion,
            @RequestParam(required = false) String region,
            @RequestParam(required = false) String latitud,
            @RequestParam(required = false) String longitud,
            @RequestParam(required = false) String conexiones,
            RedirectAttributes flash) {
        try {
            Estacion estacion = codigo == null ? new Estacion() : estacionService.obtener(codigo);
            if (estacion == null) {
                throw new IllegalArgumentException("La estación indicada no existe.");
            }
            estacion.setNombre(nombre);
            estacion.setUbicacion(ubicacion);
            estacion.setRegion(region);
            estacion.setConexiones(conexiones);
            estacion.setLatitud(latitud == null || latitud.isBlank() ? null : Double.parseDouble(latitud));
            estacion.setLongitud(longitud == null || longitud.isBlank() ? null : Double.parseDouble(longitud));
            estacionService.guardar(estacion);

            flash.addFlashAttribute("toast", "Estación guardada correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (NumberFormatException e) {
            flash.addFlashAttribute("toast", "Latitud y longitud deben ser números decimales válidos.");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/estaciones";
    }

    @PostMapping("/estaciones/eliminar")
    public String eliminarEstacion(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            estacionService.eliminar(codigo);
            flash.addFlashAttribute("toast", "Estación eliminada.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/estaciones";
    }

    /* ====================== SERVICIOS / HORARIOS ================= */

    /** Modulo "Horarios y Precios Ferroviarios" (RF13). */
    @GetMapping("/ferroviario")
    public String ferroviario(Model model) {
        model.addAttribute("servicios", ferroviarioService.listarServicios());
        model.addAttribute("horarios", ferroviarioService.listarHorarios());
        model.addAttribute("estaciones", estacionService.listar());
        return "panel/ferroviario";
    }

    @PostMapping("/servicios/guardar")
    public String guardarServicio(@RequestParam(required = false) Integer codigo,
            @RequestParam String nombre,
            @RequestParam Integer origenCodigo,
            @RequestParam Integer destinoCodigo,
            @RequestParam(required = false) String estado,
            RedirectAttributes flash) {
        try {
            ServicioFerroviario servicio = codigo == null
                    ? new ServicioFerroviario() : ferroviarioService.obtenerServicio(codigo);
            if (servicio == null) {
                throw new IllegalArgumentException("El servicio indicado no existe.");
            }
            servicio.setNombre(nombre);
            servicio.setOrigen(estacionService.obtener(origenCodigo));
            servicio.setDestino(estacionService.obtener(destinoCodigo));
            servicio.setEstado(estado == null || estado.isBlank() ? "ACTIVO" : estado);
            ferroviarioService.guardarServicio(servicio);

            flash.addFlashAttribute("toast", "Servicio ferroviario guardado correctamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/ferroviario";
    }

    @PostMapping("/servicios/eliminar")
    public String eliminarServicio(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            ferroviarioService.eliminarServicio(codigo);
            flash.addFlashAttribute("toast", "Servicio ferroviario eliminado.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/ferroviario";
    }

    @PostMapping("/horarios/guardar")
    public String guardarHorario(@RequestParam(required = false) Integer codigo,
            @RequestParam Integer servicioCodigo,
            @RequestParam String horaSalida,
            @RequestParam String horaLlegada,
            @RequestParam String tarifa,
            @RequestParam(required = false) String frecuencia,
            @RequestParam(required = false) String estado,
            RedirectAttributes flash) {
        try {
            HorarioFerroviario horario = codigo == null
                    ? new HorarioFerroviario() : ferroviarioService.obtenerHorario(codigo);
            if (horario == null) {
                throw new IllegalArgumentException("El horario indicado no existe.");
            }
            horario.setServicio(ferroviarioService.obtenerServicio(servicioCodigo));
            horario.setHoraSalida(LocalTime.parse(horaSalida));
            horario.setHoraLlegada(LocalTime.parse(horaLlegada));
            horario.setTarifa(new BigDecimal(tarifa));
            horario.setFrecuencia(frecuencia == null || frecuencia.isBlank() ? "Diario" : frecuencia);
            horario.setEstado(estado == null || estado.isBlank() ? "ACTIVO" : estado);
            ferroviarioService.guardarHorario(horario);

            flash.addFlashAttribute("toast",
                    "Horario guardado. El tiempo de recorrido se calculó automáticamente.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (NumberFormatException e) {
            flash.addFlashAttribute("toast", "La tarifa debe ser un número válido.");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (java.time.format.DateTimeParseException e) {
            flash.addFlashAttribute("toast", "Las horas deben tener el formato HH:mm.");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/ferroviario";
    }

    @PostMapping("/horarios/eliminar")
    public String eliminarHorario(@RequestParam Integer codigo, RedirectAttributes flash) {
        try {
            ferroviarioService.eliminarHorario(codigo);
            flash.addFlashAttribute("toast", "Horario eliminado.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/ferroviario";
    }

    /** Ajuste porcentual masivo de tarifas ("Update Prices" de la maqueta). */
    @PostMapping("/horarios/tarifas")
    public String ajustarTarifas(@RequestParam String porcentaje,
            RedirectAttributes flash) {
        try {
            double p = Double.parseDouble(porcentaje);
            if (p < -90 || p > 200) {
                throw new IllegalArgumentException("El ajuste debe estar entre -90% y 200%.");
            }
            int afectados = ferroviarioService.ajustarTarifas(p);
            flash.addFlashAttribute("toast",
                    "Se actualizaron " + afectados + " tarifa(s) en " + p + "%.");
            flash.addFlashAttribute("toastTipo", "success");
        } catch (NumberFormatException e) {
            flash.addFlashAttribute("toast", "Ingrese un porcentaje válido (por ejemplo 5 o -3.5).");
            flash.addFlashAttribute("toastTipo", "error");
        } catch (RuntimeException e) {
            flash.addFlashAttribute("toast", e.getMessage());
            flash.addFlashAttribute("toastTipo", "error");
        }
        return "redirect:/panel/ferroviario";
    }
}
