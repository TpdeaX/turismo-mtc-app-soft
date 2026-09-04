package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.repositories.PronosticoClimaRepository;
import com.zonasturisticas.plataforma.repositories.SincronizacionLogRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * RF04 / CU-03 paso 2: lectura del pronostico climatico integrado desde SENAMHI.
 *
 * Flujo alternativo "Clima no disponible": si no hay pronostico vigente para la
 * fecha, se devuelve el ultimo pronostico valido almacenado y la vista informa
 * la fecha de la ultima actualizacion exitosa.
 */
@Service
public class ClimaService {

    private final PronosticoClimaRepository pronosticoRepository;
    private final SincronizacionLogRepository logRepository;

    public ClimaService(PronosticoClimaRepository pronosticoRepository,
            SincronizacionLogRepository logRepository) {
        this.pronosticoRepository = pronosticoRepository;
        this.logRepository = logRepository;
    }

    /** Pronostico del dia para la zona geografica de la estacion. */
    public PronosticoClima obtenerHoy(Integer estacionCodigo) {
        if (estacionCodigo == null) {
            return null;
        }
        PronosticoClima hoy = pronosticoRepository.findFirstByEstacionCodigoAndFecha(
                estacionCodigo, LocalDate.now());
        if (hoy != null) {
            return hoy;
        }
        // Cache: ultimo pronostico valido almacenado
        return pronosticoRepository.findFirstByEstacionCodigoOrderByFechaDesc(estacionCodigo);
    }

    /** Pronostico extendido usado en el informe consolidado (RF07). */
    public List<PronosticoClima> obtenerPronostico(Integer estacionCodigo) {
        if (estacionCodigo == null) {
            return List.of();
        }
        return pronosticoRepository.listarDesde(estacionCodigo, LocalDate.now());
    }

    /** true si el dato mostrado corresponde realmente al dia de hoy. */
    public boolean esVigente(PronosticoClima clima) {
        return clima != null && LocalDate.now().equals(clima.getFecha());
    }

    /** Fecha de la ultima sincronizacion exitosa con SENAMHI. */
    public LocalDateTime ultimaActualizacionExitosa() {
        SincronizacionLog log = logRepository.findFirstByFuenteAndEstadoOrderByFechaDesc(
                SincronizacionLog.FUENTE_SENAMHI, SincronizacionLog.ESTADO_EXITO);
        return log == null ? null : log.getFecha();
    }

    /** Icono de Material Symbols correspondiente a la condicion informada. */
    public static String iconoDe(String condicion) {
        if (condicion == null) {
            return "cloud";
        }
        String c = condicion.toLowerCase();
        if (c.contains("desp") || c.contains("solea")) {
            return "sunny";
        }
        if (c.contains("parcial")) {
            return "partly_cloudy_day";
        }
        if (c.contains("tormenta")) {
            return "thunderstorm";
        }
        if (c.contains("lluvia") || c.contains("llovizna")) {
            return "rainy";
        }
        if (c.contains("niebla") || c.contains("neblina")) {
            return "foggy";
        }
        if (c.contains("nieve") || c.contains("granizo")) {
            return "weather_snowy";
        }
        return "cloud";
    }
}
