package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.ServicioFerroviario;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.dto.PanelResumenDTO;
import com.zonasturisticas.plataforma.services.integracion.IntegracionScheduler;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Arma el resumen del panel de control administrativo, equivalente a la maqueta
 * "Panel de Control Administrativo" del informe (seccion 2.5).
 */
@Service
public class PanelService {

    private final ZonaTuristicaService zonaService;
    private final EstacionService estacionService;
    private final FerroviarioService ferroviarioService;
    private final RutaService rutaService;
    private final CategoriaService categoriaService;
    private final IntegracionScheduler integracionScheduler;

    public PanelService(ZonaTuristicaService zonaService, EstacionService estacionService,
            FerroviarioService ferroviarioService, RutaService rutaService,
            CategoriaService categoriaService, IntegracionScheduler integracionScheduler) {
        this.zonaService = zonaService;
        this.estacionService = estacionService;
        this.ferroviarioService = ferroviarioService;
        this.rutaService = rutaService;
        this.categoriaService = categoriaService;
        this.integracionScheduler = integracionScheduler;
    }

    public PanelResumenDTO resumen() {
        PanelResumenDTO r = new PanelResumenDTO();
        r.setZonasActivas(zonaService.contarActivas());
        r.setZonasTotales(zonaService.contar());
        r.setEstaciones(estacionService.contar());
        r.setServiciosOperativos(ferroviarioService.contarServiciosOperativos());
        r.setHorarios(ferroviarioService.contarHorarios());
        r.setRutas(rutaService.contar());
        r.setCategorias(categoriaService.contar());

        r.setUltimaSincronizacionPeruRail(integracionScheduler.ultima(SincronizacionLog.FUENTE_PERURAIL));
        r.setUltimaSincronizacionSenamhi(integracionScheduler.ultima(SincronizacionLog.FUENTE_SENAMHI));
        r.setBitacora(integracionScheduler.bitacora());
        r.setAlertas(construirAlertas(r));
        return r;
    }

    /** Bloque "Alertas del Sistema": incidencias derivadas del estado real. */
    private List<PanelResumenDTO.AlertaDTO> construirAlertas(PanelResumenDTO r) {
        List<PanelResumenDTO.AlertaDTO> alertas = new ArrayList<>();

        // Servicios con retraso reportado por la fuente
        for (ServicioFerroviario s : ferroviarioService.listarServicios()) {
            if ("RETRASO".equals(s.getEstado())) {
                alertas.add(new PanelResumenDTO.AlertaDTO("warning",
                        "Demora en " + s.getNombre(),
                        "PeruRail reporta retraso en el trayecto " + s.getTrayecto()
                                + ". Los horarios pueden variar.",
                        "Última sincronización", "warning"));
            }
        }

        // Fallos de integracion pendientes de revision (RNF05)
        for (String fuente : new String[] { SincronizacionLog.FUENTE_PERURAIL, SincronizacionLog.FUENTE_SENAMHI }) {
            SincronizacionLog ultima = integracionScheduler.ultima(fuente);
            if (ultima != null && !ultima.isExitosa()) {
                alertas.add(new PanelResumenDTO.AlertaDTO("error",
                        "Integración con " + fuente + " fallida",
                        ultima.getMensaje(), momento(ultima.getFecha()), "sync_problem"));
            }
        }

        // Zonas registradas pero aun no publicadas
        long ocultas = r.getZonasTotales() - r.getZonasActivas();
        if (ocultas > 0) {
            alertas.add(new PanelResumenDTO.AlertaDTO("info",
                    ocultas + " zona(s) sin publicar",
                    "Existen zonas turísticas registradas que aún no están visibles para el usuario final.",
                    "Ahora", "visibility_off"));
        }

        if (alertas.isEmpty()) {
            alertas.add(new PanelResumenDTO.AlertaDTO("success",
                    "Todos los sistemas operativos",
                    "Las integraciones con PeruRail y SENAMHI respondieron correctamente en la última ejecución.",
                    momento(r.getUltimaSincronizacionSenamhi() == null
                            ? null : r.getUltimaSincronizacionSenamhi().getFecha()),
                    "check_circle"));
        }
        return alertas;
    }

    /** Convierte una fecha en una etiqueta relativa: "hace 5 min", "hace 3 h". */
    public static String momento(LocalDateTime fecha) {
        if (fecha == null) {
            return "Sin registro";
        }
        Duration d = Duration.between(fecha, LocalDateTime.now());
        long minutos = d.toMinutes();
        if (minutos < 1) {
            return "Hace unos segundos";
        }
        if (minutos < 60) {
            return "Hace " + minutos + " min";
        }
        long horas = d.toHours();
        if (horas < 24) {
            return "Hace " + horas + " h";
        }
        return "Hace " + d.toDays() + " d";
    }
}
