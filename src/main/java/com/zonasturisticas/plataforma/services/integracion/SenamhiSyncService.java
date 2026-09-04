package com.zonasturisticas.plataforma.services.integracion;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.repositories.EstacionRepository;
import com.zonasturisticas.plataforma.repositories.PronosticoClimaRepository;
import com.zonasturisticas.plataforma.repositories.SincronizacionLogRepository;
import com.zonasturisticas.plataforma.services.ClimaService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;

/**
 * RF11 / CU-07: obtencion periodica del pronostico climatologico por zona
 * geografica provisto por SENAMHI.
 *
 * Modo SIMULADO: el pronostico se deriva de la latitud, la altitud aproximada
 * de la region y la estacion del ano peruana (temporada seca de mayo a
 * setiembre, temporada de lluvias de noviembre a marzo), de modo que los
 * valores generados son coherentes con la zona geografica consultada.
 *
 * Flujo alternativo: ante un fallo, conserva el ultimo pronostico valido
 * almacenado e informa la fecha de la ultima actualizacion exitosa.
 */
@Service
public class SenamhiSyncService {

    private static final Logger log = LoggerFactory.getLogger(SenamhiSyncService.class);

    private static final String[] CONDICIONES_SECA = {
            "Despejado", "Soleado", "Parcialmente nublado", "Nublado" };
    private static final String[] CONDICIONES_LLUVIA = {
            "Parcialmente nublado", "Nublado", "Lluvia ligera", "Lluvia moderada", "Tormenta eléctrica" };
    private static final String[] DIRECCIONES = { "N", "NE", "E", "SE", "S", "SO", "O", "NO" };

    private final EstacionRepository estacionRepository;
    private final PronosticoClimaRepository pronosticoRepository;
    private final SincronizacionLogRepository logRepository;

    @Value("${app.integracion.dias-pronostico:5}")
    private int diasPronostico;

    @Value("${app.integracion.modo:SIMULADO}")
    private String modo;

    public SenamhiSyncService(EstacionRepository estacionRepository,
            PronosticoClimaRepository pronosticoRepository,
            SincronizacionLogRepository logRepository) {
        this.estacionRepository = estacionRepository;
        this.pronosticoRepository = pronosticoRepository;
        this.logRepository = logRepository;
    }

    @Transactional
    public ResultadoSincronizacion sincronizar() {
        long inicio = System.currentTimeMillis();
        int registros = 0;
        try {
            List<Estacion> estaciones = estacionRepository.findAll();
            if (estaciones.isEmpty()) {
                throw new IllegalStateException("no hay zonas geográficas registradas para consultar");
            }

            LocalDate hoy = LocalDate.now();
            for (Estacion estacion : estaciones) {
                /* Paso 2 del CU-07: pronostico correspondiente a cada zona geografica */
                for (int dia = 0; dia < Math.max(1, diasPronostico); dia++) {
                    LocalDate fecha = hoy.plusDays(dia);
                    PronosticoClima p = generar(estacion, fecha);

                    /* Paso 3 del CU-07: validar formato e integridad */
                    validar(p);

                    /* Paso 4 del CU-07: almacenar el pronostico actualizado */
                    PronosticoClima existente = pronosticoRepository
                            .findFirstByEstacionCodigoAndFecha(estacion.getCodigo(), fecha);
                    if (existente != null) {
                        p.setCodigo(existente.getCodigo());
                    }
                    pronosticoRepository.save(p);
                    registros++;
                }
            }
            // Limpieza del cache: se descartan los pronosticos ya vencidos
            pronosticoRepository.deleteByFechaBefore(hoy.minusDays(2));

            long duracion = System.currentTimeMillis() - inicio;
            String mensaje = "Pronóstico actualizado en modo " + modo + " para "
                    + estaciones.size() + " zonas geográficas (" + registros + " registros).";
            logRepository.save(new SincronizacionLog(SincronizacionLog.FUENTE_SENAMHI,
                    SincronizacionLog.ESTADO_EXITO, registros, duracion, mensaje));
            log.info("[SENAMHI] {}", mensaje);
            return new ResultadoSincronizacion(SincronizacionLog.FUENTE_SENAMHI, true, registros, duracion, mensaje);

        } catch (Exception e) {
            long duracion = System.currentTimeMillis() - inicio;
            String mensaje = "Fallo en la sincronización con SENAMHI: " + e.getMessage()
                    + ". Se conserva el último pronóstico válido almacenado.";
            logRepository.save(new SincronizacionLog(SincronizacionLog.FUENTE_SENAMHI,
                    SincronizacionLog.ESTADO_FALLO, 0, duracion,
                    mensaje.length() > 295 ? mensaje.substring(0, 295) : mensaje));
            log.warn("[SENAMHI] {}", mensaje);
            return new ResultadoSincronizacion(SincronizacionLog.FUENTE_SENAMHI, false, 0, duracion, mensaje);
        }
    }

    /** Paso 3 del CU-07: validacion del formato e integridad del pronostico. */
    private void validar(PronosticoClima p) {
        if (p.getTemperatura() == null || p.getTemperatura() < -25 || p.getTemperatura() > 50) {
            throw new IllegalStateException("temperatura fuera de rango para "
                    + p.getEstacion().getNombre());
        }
        if (p.getCondicion() == null || p.getCondicion().isBlank()) {
            throw new IllegalStateException("condición climática vacía");
        }
        if (p.getHumedad() != null && (p.getHumedad() < 0 || p.getHumedad() > 100)) {
            throw new IllegalStateException("humedad relativa inválida");
        }
    }

    /**
     * Genera el pronostico de una zona geografica. El generador es determinista
     * por estacion y fecha, de modo que dos consultas del mismo dia devuelven el
     * mismo valor (coherencia exigida por el RNF03 y el cacheo del informe).
     */
    private PronosticoClima generar(Estacion estacion, LocalDate fecha) {
        Random r = new Random(estacion.getCodigo() * 100003L + fecha.toEpochDay());

        boolean temporadaLluvias = esTemporadaDeLluvias(fecha);
        int baseTemperatura = temperaturaBase(estacion);

        String[] condiciones = temporadaLluvias ? CONDICIONES_LLUVIA : CONDICIONES_SECA;
        String condicion = condiciones[r.nextInt(condiciones.length)];

        int temperatura = baseTemperatura + r.nextInt(7) - 3;
        int minima = temperatura - (4 + r.nextInt(5));
        int maxima = temperatura + (3 + r.nextInt(5));

        PronosticoClima p = new PronosticoClima();
        p.setEstacion(estacion);
        p.setFecha(fecha);
        p.setTemperatura(temperatura);
        p.setTemperaturaMin(minima);
        p.setTemperaturaMax(maxima);
        p.setCondicion(condicion);
        p.setHumedad(temporadaLluvias ? 60 + r.nextInt(30) : 35 + r.nextInt(30));
        p.setViento(5 + r.nextInt(18));
        p.setVientoDireccion(DIRECCIONES[r.nextInt(DIRECCIONES.length)]);
        p.setProbabilidadLluvia(probabilidadLluvia(condicion, r));
        p.setIcono(ClimaService.iconoDe(condicion));
        p.setActualizado(LocalDateTime.now());
        return p;
    }

    /** Temporada de lluvias en la sierra peruana: noviembre a marzo. */
    private boolean esTemporadaDeLluvias(LocalDate fecha) {
        int mes = fecha.getMonthValue();
        return mes >= 11 || mes <= 3;
    }

    /** Temperatura media aproximada segun la altitud tipica de la region. */
    private int temperaturaBase(Estacion estacion) {
        String region = estacion.getRegion() == null ? "" : estacion.getRegion().toLowerCase();
        if (region.contains("puno")) {
            return 11;
        }
        if (region.contains("aguas calientes")) {
            return 21;
        }
        if (region.contains("urubamba")) {
            return 19;
        }
        if (region.contains("arequipa")) {
            return 18;
        }
        if (region.contains("cusco")) {
            return 16;
        }
        return 17;
    }

    private int probabilidadLluvia(String condicion, Random r) {
        String c = condicion.toLowerCase();
        if (c.contains("tormenta")) {
            return 75 + r.nextInt(20);
        }
        if (c.contains("moderada")) {
            return 60 + r.nextInt(20);
        }
        if (c.contains("ligera")) {
            return 40 + r.nextInt(20);
        }
        if (c.contains("nublado")) {
            return 15 + r.nextInt(25);
        }
        return r.nextInt(12);
    }
}
