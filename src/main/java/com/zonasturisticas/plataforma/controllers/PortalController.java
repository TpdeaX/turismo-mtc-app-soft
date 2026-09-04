package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.config.GlobalModelAdvice;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import com.zonasturisticas.plataforma.dto.ZonaResultadoDTO;
import com.zonasturisticas.plataforma.services.CategoriaService;
import com.zonasturisticas.plataforma.services.ClimaService;
import com.zonasturisticas.plataforma.services.EstacionService;
import com.zonasturisticas.plataforma.services.FerroviarioService;
import com.zonasturisticas.plataforma.services.RecomendacionService;
import com.zonasturisticas.plataforma.services.ZonaTuristicaService;
import com.zonasturisticas.plataforma.services.integracion.IntegracionScheduler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Modulo Cliente / Usuario Final.
 *
 * CU-01 Ingresar preferencias                (RF01)
 * CU-02 Consultar zonas turisticas           (RF02, RF03)
 * CU-03 Visualizar pronostico y ruta         (RF04, RF05, RF06)
 *
 * Acceso libre: la unica precondicion del CU-01 es haber ingresado a la
 * plataforma, por lo que el portal no exige autenticacion.
 */
@Controller
public class PortalController {

    private final CategoriaService categoriaService;
    private final EstacionService estacionService;
    private final ZonaTuristicaService zonaService;
    private final RecomendacionService recomendacionService;
    private final ClimaService climaService;
    private final FerroviarioService ferroviarioService;
    private final IntegracionScheduler integracionScheduler;

    public PortalController(CategoriaService categoriaService, EstacionService estacionService,
            ZonaTuristicaService zonaService, RecomendacionService recomendacionService,
            ClimaService climaService, FerroviarioService ferroviarioService,
            IntegracionScheduler integracionScheduler) {
        this.categoriaService = categoriaService;
        this.estacionService = estacionService;
        this.zonaService = zonaService;
        this.recomendacionService = recomendacionService;
        this.climaService = climaService;
        this.ferroviarioService = ferroviarioService;
        this.integracionScheduler = integracionScheduler;
    }

    /** Portada del asesor turistico. */
    @GetMapping("/")
    public String inicio(Model model) {
        model.addAttribute("categorias", categoriaService.listarDisponibles());
        model.addAttribute("estaciones", estacionService.listar());
        model.addAttribute("destacadas", zonaService.listarActivas().stream().limit(6).toList());
        model.addAttribute("totalZonas", zonaService.contarActivas());
        model.addAttribute("totalEstaciones", estacionService.contar());
        model.addAttribute("totalServicios", ferroviarioService.contarServiciosOperativos());
        model.addAttribute("actualizadoSenamhi",
                integracionScheduler.ultimaExitosa(SincronizacionLog.FUENTE_SENAMHI));
        model.addAttribute("actualizadoPeruRail",
                integracionScheduler.ultimaExitosa(SincronizacionLog.FUENTE_PERURAIL));
        return "portal/inicio";
    }

    /**
     * CU-01 pasos 3 a 5: el usuario selecciona sus categorias y el sistema las
     * almacena para la sesion de consulta actual.
     *
     * Flujo alternativo: si no selecciona ninguna, se continua mostrando todas
     * las zonas disponibles sin filtrar.
     */
    @PostMapping("/preferencias")
    public String guardarPreferencias(
            @RequestParam(value = "categorias", required = false) List<Integer> categorias,
            @RequestParam(value = "estacion", required = false) Integer estacion,
            @RequestParam(value = "dificultad", required = false) String dificultad,
            @RequestParam(value = "presupuesto", required = false) Integer presupuesto,
            HttpSession session, RedirectAttributes flash) {

        PreferenciasSesion preferencias = new PreferenciasSesion();
        Set<Integer> seleccion = new LinkedHashSet<>();
        if (categorias != null) {
            seleccion.addAll(categorias);
        }
        preferencias.setCategorias(seleccion);
        preferencias.setEstacionCodigo(estacion);
        preferencias.setDificultadMaxima(dificultad);
        preferencias.setPresupuesto(presupuesto);
        session.setAttribute(GlobalModelAdvice.ATTR_PREFERENCIAS, preferencias);

        flash.addFlashAttribute("toast", seleccion.isEmpty()
                ? "Sin filtros: se mostrarán todas las zonas turísticas disponibles."
                : "Preferencias guardadas: " + seleccion.size() + " categoría(s) seleccionada(s).");
        flash.addFlashAttribute("toastTipo", "success");

        if (estacion != null) {
            return "redirect:/explorar?estacion=" + estacion;
        }
        return "redirect:/explorar";
    }

    @PostMapping("/preferencias/limpiar")
    public String limpiarPreferencias(HttpSession session, RedirectAttributes flash) {
        session.setAttribute(GlobalModelAdvice.ATTR_PREFERENCIAS, new PreferenciasSesion());
        flash.addFlashAttribute("toast", "Se limpiaron las preferencias de la sesión.");
        flash.addFlashAttribute("toastTipo", "info");
        return "redirect:/explorar";
    }

    /**
     * CU-02: seleccion de la estacion de partida (RF02) y consulta de las zonas
     * turisticas vinculadas, filtradas por preferencias (RF03).
     */
    @GetMapping("/explorar")
    public String explorar(@RequestParam(value = "estacion", required = false) Integer estacionCodigo,
            @RequestParam(value = "q", required = false) String busqueda,
            HttpSession session, Model model) {

        PreferenciasSesion preferencias = preferencias(session);
        if (estacionCodigo != null) {
            preferencias.setEstacionCodigo(estacionCodigo);
        }
        Integer seleccionada = preferencias.getEstacionCodigo();

        model.addAttribute("categorias", categoriaService.listarDisponibles());
        model.addAttribute("estaciones", estacionService.listar());
        model.addAttribute("preferencias", preferencias);
        model.addAttribute("busqueda", busqueda);

        if (seleccionada == null) {
            // RF02: aun no se elige estacion, se invita a seleccionarla
            model.addAttribute("resultados", List.of());
            model.addAttribute("estacionSeleccionada", null);
            return "portal/explorar";
        }

        Estacion estacion = estacionService.obtener(seleccionada);
        List<ZonaResultadoDTO> resultados = recomendacionService.consultarZonas(seleccionada, preferencias);

        if (busqueda != null && !busqueda.isBlank()) {
            String q = busqueda.toLowerCase();
            resultados = resultados.stream()
                    .filter(r -> r.getZona().getNombre().toLowerCase().contains(q)
                            || (r.getZona().getDescripcion() != null
                                    && r.getZona().getDescripcion().toLowerCase().contains(q)))
                    .toList();
        }

        model.addAttribute("estacionSeleccionada", estacion);
        model.addAttribute("resultados", resultados);
        model.addAttribute("clima", climaService.obtenerHoy(seleccionada));
        model.addAttribute("climaVigente", climaService.esVigente(climaService.obtenerHoy(seleccionada)));
        model.addAttribute("climaActualizado", climaService.ultimaActualizacionExitosa());
        model.addAttribute("horarios", ferroviarioService.listarHorariosPorEstacion(seleccionada));
        model.addAttribute("proximaSalida", ferroviarioService.proximaSalida(seleccionada, LocalTime.now()));
        return "portal/explorar";
    }

    /**
     * CU-03: detalle de la zona con el pronostico de SENAMHI, la ruta caminable
     * recomendada y los datos ferroviarios de PeruRail.
     */
    @GetMapping("/zona/{codigo}")
    public String detalleZona(@PathVariable Integer codigo, HttpSession session, Model model) {
        ZonaTuristica zona = zonaService.obtener(codigo);
        if (zona == null) {
            return "redirect:/explorar";
        }
        Estacion estacion = zona.getEstacion();
        Integer estacionCodigo = estacion == null ? null : estacion.getCodigo();

        var clima = climaService.obtenerHoy(estacionCodigo);

        model.addAttribute("zona", zona);
        model.addAttribute("estacion", estacion);
        model.addAttribute("ruta", recomendacionService.calcularRuta(zona.getRuta(), clima));
        model.addAttribute("clima", clima);
        model.addAttribute("climaVigente", climaService.esVigente(clima));
        model.addAttribute("climaActualizado", climaService.ultimaActualizacionExitosa());
        model.addAttribute("pronostico", climaService.obtenerPronostico(estacionCodigo));
        model.addAttribute("horarios", ferroviarioService.listarHorariosPorEstacion(estacionCodigo));
        model.addAttribute("servicios", ferroviarioService.listarServiciosPorEstacion(estacionCodigo));
        model.addAttribute("relacionadas", zonaService.listarPorEstacion(estacionCodigo).stream()
                .filter(z -> !z.getCodigo().equals(codigo)).limit(3).toList());
        model.addAttribute("preferencias", preferencias(session));
        return "portal/detalle";
    }

    private PreferenciasSesion preferencias(HttpSession session) {
        PreferenciasSesion p = (PreferenciasSesion) session.getAttribute(GlobalModelAdvice.ATTR_PREFERENCIAS);
        if (p == null) {
            p = new PreferenciasSesion();
            session.setAttribute(GlobalModelAdvice.ATTR_PREFERENCIAS, p);
        }
        return p;
    }
}
