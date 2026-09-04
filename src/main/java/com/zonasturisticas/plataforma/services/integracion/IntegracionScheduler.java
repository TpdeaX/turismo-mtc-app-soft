package com.zonasturisticas.plataforma.services.integracion;

import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.repositories.SincronizacionLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * RNF02 / RNF05: mecanismo automatizado y periodico que asegura la
 * disponibilidad de la integracion con PeruRail y SENAMHI.
 *
 * La tarea se ejecuta a diario segun el cron configurado en
 * {@code app.integracion.cron} (por defecto 03:00 hora de Lima) y tambien puede
 * dispararse manualmente desde el panel administrativo.
 */
@Component
public class IntegracionScheduler {

    private static final Logger log = LoggerFactory.getLogger(IntegracionScheduler.class);

    private final PeruRailSyncService peruRailSyncService;
    private final SenamhiSyncService senamhiSyncService;
    private final SincronizacionLogRepository logRepository;

    public IntegracionScheduler(PeruRailSyncService peruRailSyncService,
            SenamhiSyncService senamhiSyncService,
            SincronizacionLogRepository logRepository) {
        this.peruRailSyncService = peruRailSyncService;
        this.senamhiSyncService = senamhiSyncService;
        this.logRepository = logRepository;
    }

    /** Sincronizacion diaria de ambas fuentes externas (CU-06 y CU-07). */
    @Scheduled(cron = "${app.integracion.cron:0 0 3 * * *}", zone = "America/Lima")
    public void sincronizacionDiaria() {
        log.info("Iniciando sincronización periódica de fuentes externas");
        sincronizarTodo();
    }

    /** Ejecuta ambas integraciones y devuelve sus resultados. */
    public List<ResultadoSincronizacion> sincronizarTodo() {
        ResultadoSincronizacion rail = peruRailSyncService.sincronizar();
        ResultadoSincronizacion clima = senamhiSyncService.sincronizar();
        return List.of(rail, clima);
    }

    public ResultadoSincronizacion sincronizarPeruRail() {
        return peruRailSyncService.sincronizar();
    }

    public ResultadoSincronizacion sincronizarSenamhi() {
        return senamhiSyncService.sincronizar();
    }

    /** Ultima sincronizacion registrada de una fuente, exitosa o fallida. */
    public SincronizacionLog ultima(String fuente) {
        return logRepository.findFirstByFuenteOrderByFechaDesc(fuente);
    }

    /** Ultima sincronizacion EXITOSA, usada para informar la vigencia del dato. */
    public LocalDateTime ultimaExitosa(String fuente) {
        SincronizacionLog l = logRepository.findFirstByFuenteAndEstadoOrderByFechaDesc(
                fuente, SincronizacionLog.ESTADO_EXITO);
        return l == null ? null : l.getFecha();
    }

    public List<SincronizacionLog> bitacora() {
        return logRepository.findTop20ByOrderByFechaDesc();
    }
}
