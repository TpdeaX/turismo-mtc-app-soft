package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import com.zonasturisticas.plataforma.dto.RutaRecomendadaDTO;
import com.zonasturisticas.plataforma.dto.ZonaResultadoDTO;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Motor del asesor turistico.
 *
 * RF03 - filtra las zonas de una estacion segun las preferencias del turista.
 * RF05 - genera la ruta caminable recomendada de ida y vuelta con su tiempo
 *        estimado y su dificultad.
 *
 * RN01 - toda ruta parte y retorna a la misma estacion (un solo tramo).
 * RN04 - el recorrido es exclusivamente peatonal.
 */
@Service
public class RecomendacionService {

    private final ZonaTuristicaService zonaService;
    private final RutaService rutaService;
    private final ClimaService climaService;
    private final FerroviarioService ferroviarioService;

    public RecomendacionService(ZonaTuristicaService zonaService, RutaService rutaService,
            ClimaService climaService, FerroviarioService ferroviarioService) {
        this.zonaService = zonaService;
        this.rutaService = rutaService;
        this.climaService = climaService;
        this.ferroviarioService = ferroviarioService;
    }

    /**
     * CU-02 pasos 4 y 5: obtiene las zonas de la estacion y las filtra segun las
     * preferencias ingresadas. Si el turista no selecciono ninguna categoria se
     * devuelven todas las zonas disponibles (flujo alternativo del CU-01).
     */
    public List<ZonaResultadoDTO> consultarZonas(Integer estacionCodigo, PreferenciasSesion preferencias) {
        List<ZonaTuristica> zonas = zonaService.listarPorEstacion(estacionCodigo);
        List<ZonaResultadoDTO> resultados = new ArrayList<>();

        PronosticoClima clima = climaService.obtenerHoy(estacionCodigo);
        BigDecimal tarifaDesde = ferroviarioService.tarifaDesde(estacionCodigo);
        var proxima = ferroviarioService.proximaSalida(estacionCodigo, LocalTime.now());

        for (ZonaTuristica zona : zonas) {
            int coincidencias = contarCoincidencias(zona, preferencias);

            // Sin preferencias se muestra todo; con preferencias solo lo que coincide
            if (preferencias != null && !preferencias.isVacio() && coincidencias == 0) {
                continue;
            }
            if (!cumpleDificultad(zona, preferencias)) {
                continue;
            }

            ZonaResultadoDTO dto = new ZonaResultadoDTO(zona);
            dto.setCoincidencias(coincidencias);
            dto.setClima(clima);
            dto.setTarifaDesde(tarifaDesde);
            dto.setProximaSalida(proxima);
            dto.setRuta(calcularRuta(zona.getRuta(), clima));
            resultados.add(dto);
        }

        // Las zonas que mas coinciden con las preferencias se muestran primero
        resultados.sort(Comparator
                .comparingInt(ZonaResultadoDTO::getCoincidencias).reversed()
                .thenComparing(r -> r.getZona().getNombre()));
        return resultados;
    }

    /** Cuenta cuantas categorias de la zona coinciden con las preferencias. */
    public int contarCoincidencias(ZonaTuristica zona, PreferenciasSesion preferencias) {
        if (preferencias == null || preferencias.isVacio() || zona.getCategorias() == null) {
            return 0;
        }
        int total = 0;
        for (Categoria c : zona.getCategorias()) {
            if (preferencias.tieneCategoria(c.getCodigo())) {
                total++;
            }
        }
        return total;
    }

    /** Descarta rutas mas exigentes que la dificultad maxima aceptada. */
    private boolean cumpleDificultad(ZonaTuristica zona, PreferenciasSesion preferencias) {
        if (preferencias == null || preferencias.getDificultadMaxima() == null
                || preferencias.getDificultadMaxima().isBlank() || zona.getRuta() == null) {
            return true;
        }
        int maximo = rutaService.nivelDificultad(preferencias.getDificultadMaxima());
        int nivel = rutaService.nivelDificultad(zona.getRuta().getDificultad());
        return nivel <= maximo;
    }

    /**
     * RF05 / CU-03 paso 3: construye la ruta caminable recomendada de ida y
     * vuelta con su tiempo estimado, su dificultad y una recomendacion
     * contextual segun el clima informado por SENAMHI.
     */
    public RutaRecomendadaDTO calcularRuta(Ruta ruta, PronosticoClima clima) {
        if (ruta == null) {
            return null;
        }
        RutaRecomendadaDTO dto = new RutaRecomendadaDTO();
        dto.setRuta(ruta);

        BigDecimal ida = ruta.getDistanciaKm() == null ? BigDecimal.ZERO : ruta.getDistanciaKm();
        dto.setDistanciaIdaKm(ida.setScale(2, RoundingMode.HALF_UP));
        dto.setDistanciaTotalKm(ida.multiply(BigDecimal.valueOf(2)).setScale(2, RoundingMode.HALF_UP));

        int minutosTotal = rutaService.calcularMinutosIdaVuelta(ida, ruta.getDificultad());
        dto.setMinutosTotal(minutosTotal);
        dto.setMinutosIda(minutosTotal / 2);
        dto.setTiempoTotalTexto(rutaService.formatearDuracion(minutosTotal));

        dto.setDificultad(ruta.getDificultad() == null ? "Facil" : ruta.getDificultad());
        dto.setNivelDificultad(rutaService.nivelDificultad(ruta.getDificultad()));

        boolean apta = clima == null || clima.isAptoParaCaminar();
        dto.setAptaSegunClima(apta);
        dto.setRecomendacion(construirRecomendacion(dto, clima));
        return dto;
    }

    private String construirRecomendacion(RutaRecomendadaDTO dto, PronosticoClima clima) {
        StringBuilder sb = new StringBuilder();
        sb.append("Recorrido peatonal de ida y vuelta desde la misma estación (")
          .append(dto.getDistanciaTotalKm()).append(" km en total, aprox. ")
          .append(dto.getTiempoTotalTexto()).append("). ");

        if (clima == null) {
            sb.append("El pronóstico de SENAMHI no está disponible en este momento; ")
              .append("verifique las condiciones antes de iniciar el recorrido.");
            return sb.toString();
        }
        if (clima.getProbabilidadLluvia() != null && clima.getProbabilidadLluvia() >= 60) {
            sb.append("Alta probabilidad de lluvia (").append(clima.getProbabilidadLluvia())
              .append("%): lleve impermeable o considere reprogramar la caminata.");
        } else if (clima.getTemperatura() != null && clima.getTemperatura() > 26) {
            sb.append("Temperatura elevada: inicie temprano, use protector solar y lleve agua.");
        } else if (clima.getTemperatura() != null && clima.getTemperatura() < 8) {
            sb.append("Temperatura baja: abrigue bien y prefiera las horas centrales del día.");
        } else {
            sb.append("Condiciones favorables para realizar el recorrido a pie.");
        }
        if (dto.getNivelDificultad() >= 3) {
            sb.append(" La ruta es exigente: se recomienda calzado de trekking.");
        }
        return sb.toString();
    }
}
