package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.dto.InformeConsolidadoDTO;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import com.zonasturisticas.plataforma.repositories.SincronizacionLogRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * RF07 / CU-03 paso 5: generacion del informe consolidado dirigido al usuario
 * final y a Travel Group Peru, integrando los datos turisticos, climaticos y
 * ferroviarios de la consulta realizada.
 */
@Service
public class InformeService {

    private static final DateTimeFormatter FOLIO_FMT = DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss");

    private final ZonaTuristicaService zonaService;
    private final RecomendacionService recomendacionService;
    private final ClimaService climaService;
    private final FerroviarioService ferroviarioService;
    private final CategoriaService categoriaService;
    private final SincronizacionLogRepository logRepository;

    public InformeService(ZonaTuristicaService zonaService, RecomendacionService recomendacionService,
            ClimaService climaService, FerroviarioService ferroviarioService,
            CategoriaService categoriaService, SincronizacionLogRepository logRepository) {
        this.zonaService = zonaService;
        this.recomendacionService = recomendacionService;
        this.climaService = climaService;
        this.ferroviarioService = ferroviarioService;
        this.categoriaService = categoriaService;
        this.logRepository = logRepository;
    }

    /**
     * Construye el informe consolidado de una zona turistica.
     *
     * Flujo alternativo del CU-03: si SENAMHI no tiene datos vigentes, el
     * informe se entrega igualmente con los datos ferroviarios y turisticos,
     * indicando que el pronostico no se encuentra disponible.
     */
    public InformeConsolidadoDTO generar(Integer zonaCodigo, PreferenciasSesion preferencias) {
        ZonaTuristica zona = zonaService.obtener(zonaCodigo);
        if (zona == null) {
            return null;
        }
        Estacion estacion = zona.getEstacion();

        InformeConsolidadoDTO informe = new InformeConsolidadoDTO();
        informe.setFolio("MTC-" + LocalDateTime.now().format(FOLIO_FMT) + "-Z" + zona.getCodigo());
        informe.setGenerado(LocalDateTime.now());
        informe.setZona(zona);
        informe.setEstacion(estacion);

        /* --- Bloque climatico (SENAMHI) --- */
        PronosticoClima clima = estacion == null ? null : climaService.obtenerHoy(estacion.getCodigo());
        informe.setClimaActual(clima);
        informe.setPronostico(estacion == null ? List.of() : climaService.obtenerPronostico(estacion.getCodigo()));
        informe.setClimaActualizado(climaService.ultimaActualizacionExitosa());

        if (clima == null) {
            informe.setClimaDisponible(false);
            informe.setClimaMensaje("El pronóstico climático de SENAMHI no se encuentra disponible en este momento.");
        } else if (!climaService.esVigente(clima)) {
            informe.setClimaDisponible(false);
            informe.setClimaMensaje("Mostrando el último pronóstico válido almacenado ("
                    + clima.getFecha() + "). SENAMHI no ha respondido en la última sincronización.");
        }

        /* --- Bloque turistico y ruta caminable (RF05) --- */
        informe.setRutaRecomendada(recomendacionService.calcularRuta(zona.getRuta(), clima));

        /* --- Bloque ferroviario (PeruRail) --- */
        List<HorarioFerroviario> horarios = estacion == null
                ? List.of()
                : ferroviarioService.listarHorariosPorEstacion(estacion.getCodigo());
        informe.setHorarios(horarios);
        informe.setFerroviarioDisponible(!horarios.isEmpty());

        List<BigDecimal> tarifas = horarios.stream()
                .map(HorarioFerroviario::getTarifa).filter(Objects::nonNull).sorted().toList();
        if (!tarifas.isEmpty()) {
            informe.setTarifaMinima(tarifas.get(0));
            informe.setTarifaMaxima(tarifas.get(tarifas.size() - 1));
        }

        SincronizacionLog logRail = logRepository.findFirstByFuenteAndEstadoOrderByFechaDesc(
                SincronizacionLog.FUENTE_PERURAIL, SincronizacionLog.ESTADO_EXITO);
        informe.setFerroviarioActualizado(logRail == null ? null : logRail.getFecha());

        /* --- Preferencias aplicadas --- */
        informe.setPreferenciasTexto(describirPreferencias(preferencias));
        return informe;
    }

    private String describirPreferencias(PreferenciasSesion preferencias) {
        if (preferencias == null || preferencias.isVacio()) {
            return "Sin filtro de preferencias (se consideraron todas las categorías)";
        }
        return preferencias.getCategorias().stream()
                .map(categoriaService::obtener)
                .filter(Objects::nonNull)
                .map(Categoria::getNombre)
                .collect(Collectors.joining(", "));
    }
}
