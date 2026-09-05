package com.zonasturisticas.plataforma.services.integracion;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.ServicioFerroviario;
import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.repositories.EstacionRepository;
import com.zonasturisticas.plataforma.repositories.HorarioFerroviarioRepository;
import com.zonasturisticas.plataforma.repositories.ServicioFerroviarioRepository;
import com.zonasturisticas.plataforma.repositories.SincronizacionLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;

/**
 * RF10 / CU-06: obtencion periodica de los datos logisticos de PeruRail
 * (estaciones, horarios, tiempos de recorrido y tarifas).
 *
 * Modo SIMULADO: la fuente externa se representa mediante el dataset local
 * {@link DatasetPeruRail}, construido con la informacion publica de PeruRail.
 * El proceso realiza el mismo ciclo que exige el caso de uso: obtiene los
 * datos, valida su formato e integridad, y los almacena.
 *
 * Flujo alternativo: ante un fallo, conserva la ultima informacion valida
 * almacenada y registra el incidente en la bitacora para su revision.
 */
@Service
public class PeruRailSyncService {

    private static final Logger log = LoggerFactory.getLogger(PeruRailSyncService.class);

    private final EstacionRepository estacionRepository;
    private final ServicioFerroviarioRepository servicioRepository;
    private final HorarioFerroviarioRepository horarioRepository;
    private final SincronizacionLogRepository logRepository;

    @Value("${app.integracion.modo:SIMULADO}")
    private String modo;

    private final Random random = new Random();

    public PeruRailSyncService(EstacionRepository estacionRepository,
            ServicioFerroviarioRepository servicioRepository,
            HorarioFerroviarioRepository horarioRepository,
            SincronizacionLogRepository logRepository) {
        this.estacionRepository = estacionRepository;
        this.servicioRepository = servicioRepository;
        this.horarioRepository = horarioRepository;
        this.logRepository = logRepository;
    }

    @Transactional
    public ResultadoSincronizacion sincronizar() {
        long inicio = System.currentTimeMillis();
        int registros = 0;
        try {
            /* Paso 2 del CU-06: obtener la informacion actualizada de la fuente */
            List<DatasetPeruRail.EstacionFuente> estacionesFuente = DatasetPeruRail.estaciones();
            List<DatasetPeruRail.ServicioFuente> serviciosFuente = DatasetPeruRail.servicios();

            /* Paso 3 del CU-06: validar formato e integridad */
            validar(estacionesFuente, serviciosFuente);

            /* Paso 4 del CU-06: almacenar la informacion actualizada */
            registros += sincronizarEstaciones(estacionesFuente);
            registros += sincronizarServicios(serviciosFuente);

            long duracion = System.currentTimeMillis() - inicio;
            String mensaje = "Sincronización completada en modo " + modo + ": "
                    + registros + " registros procesados.";
            logRepository.save(new SincronizacionLog(SincronizacionLog.FUENTE_PERURAIL,
                    SincronizacionLog.ESTADO_EXITO, registros, duracion, mensaje));
            log.info("[PeruRail] {}", mensaje);
            return new ResultadoSincronizacion(SincronizacionLog.FUENTE_PERURAIL, true, registros, duracion, mensaje);

        } catch (Exception e) {
            /* Flujo alternativo: se conserva la ultima informacion valida */
            long duracion = System.currentTimeMillis() - inicio;
            String mensaje = "Fallo en la sincronización con PeruRail: " + e.getMessage()
                    + ". Se conserva la última información válida almacenada.";
            logRepository.save(new SincronizacionLog(SincronizacionLog.FUENTE_PERURAIL,
                    SincronizacionLog.ESTADO_FALLO, 0, duracion, recortar(mensaje)));
            log.warn("[PeruRail] {}", mensaje);
            return new ResultadoSincronizacion(SincronizacionLog.FUENTE_PERURAIL, false, 0, duracion, mensaje);
        }
    }

    /** Paso 3 del CU-06: validacion de formato e integridad de los datos. */
    private void validar(List<DatasetPeruRail.EstacionFuente> estaciones,
            List<DatasetPeruRail.ServicioFuente> servicios) {
        if (estaciones == null || estaciones.isEmpty()) {
            throw new IllegalStateException("la fuente no devolvió estaciones");
        }
        for (DatasetPeruRail.EstacionFuente e : estaciones) {
            if (e.nombre() == null || e.nombre().isBlank()) {
                throw new IllegalStateException("estación sin nombre en la respuesta de la fuente");
            }
            if (e.latitud() == null || e.longitud() == null) {
                throw new IllegalStateException("estación " + e.nombre() + " sin coordenadas");
            }
        }
        for (DatasetPeruRail.ServicioFuente s : servicios) {
            if (s.horarios() == null || s.horarios().isEmpty()) {
                throw new IllegalStateException("servicio " + s.nombre() + " sin horarios programados");
            }
            for (DatasetPeruRail.HorarioFuente h : s.horarios()) {
                if (h.tarifa() == null || h.tarifa().signum() <= 0) {
                    throw new IllegalStateException("tarifa inválida en el servicio " + s.nombre());
                }
            }
        }
    }

    private int sincronizarEstaciones(List<DatasetPeruRail.EstacionFuente> fuente) {
        int n = 0;
        for (DatasetPeruRail.EstacionFuente ef : fuente) {
            Estacion e = estacionRepository.findFirstByNombre(ef.nombre());
            if (e == null) {
                e = new Estacion();
            }
            e.setNombre(ef.nombre());
            e.setUbicacion(ef.ubicacion());
            e.setRegion(ef.region());
            e.setLatitud(ef.latitud());
            e.setLongitud(ef.longitud());
            e.setConexiones(ef.conexiones());
            e.setActualizado(LocalDateTime.now());
            estacionRepository.save(e);
            n++;
        }
        return n;
    }

    private int sincronizarServicios(List<DatasetPeruRail.ServicioFuente> fuente) {
        int n = 0;
        for (DatasetPeruRail.ServicioFuente sf : fuente) {
            Estacion origen = estacionRepository.findFirstByNombre(sf.origen());
            Estacion destino = estacionRepository.findFirstByNombre(sf.destino());
            if (origen == null || destino == null) {
                continue;
            }
            ServicioFerroviario servicio = servicioRepository.listarCompleto().stream()
                    .filter(s -> s.getNombre().equals(sf.nombre()))
                    .findFirst()
                    .orElseGet(ServicioFerroviario::new);

            servicio.setNombre(sf.nombre());
            servicio.setOrigen(origen);
            servicio.setDestino(destino);
            // La fuente puede reportar retrasos operativos puntuales
            servicio.setEstado(random.nextInt(12) == 0 ? "RETRASO" : "ACTIVO");
            servicio = servicioRepository.save(servicio);
            n++;

            List<HorarioFerroviario> existentes =
                    horarioRepository.findByServicioCodigoOrderByHoraSalidaAsc(servicio.getCodigo());

            for (DatasetPeruRail.HorarioFuente hf : sf.horarios()) {
                final ServicioFerroviario srv = servicio;
                HorarioFerroviario horario = existentes.stream()
                        .filter(h -> h.getHoraSalida().equals(hf.salida()))
                        .findFirst()
                        .orElseGet(() -> {
                            HorarioFerroviario nuevo = new HorarioFerroviario();
                            nuevo.setServicio(srv);
                            return nuevo;
                        });
                horario.setHoraSalida(hf.salida());
                horario.setHoraLlegada(hf.llegada());
                horario.setTarifa(hf.tarifa());
                horario.setFrecuencia(hf.frecuencia());
                horario.setEstado("ACTIVO");
                horario.recalcularTiempoRecorrido();
                horarioRepository.save(horario);
                n++;
            }
        }
        return n;
    }

    private String recortar(String texto) {
        return texto.length() > 295 ? texto.substring(0, 295) : texto;
    }
}
