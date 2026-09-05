package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.ServicioFerroviario;
import com.zonasturisticas.plataforma.repositories.HorarioFerroviarioRepository;
import com.zonasturisticas.plataforma.repositories.ServicioFerroviarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * RF06: visualizacion de datos ferroviarios.
 * RF13: mantenimiento (CRUD) de servicios, horarios y tarifas por parte de los
 *       gestores autorizados de PeruRail.
 */
@Service
public class FerroviarioService {

    private final ServicioFerroviarioRepository servicioRepository;
    private final HorarioFerroviarioRepository horarioRepository;

    public FerroviarioService(ServicioFerroviarioRepository servicioRepository,
            HorarioFerroviarioRepository horarioRepository) {
        this.servicioRepository = servicioRepository;
        this.horarioRepository = horarioRepository;
    }

    /* ------------------------- Servicios ------------------------- */

    public List<ServicioFerroviario> listarServicios() {
        return servicioRepository.listarCompleto();
    }

    public List<ServicioFerroviario> listarServiciosPorEstacion(Integer estacionCodigo) {
        return servicioRepository.listarPorEstacion(estacionCodigo);
    }

    public ServicioFerroviario obtenerServicio(Integer codigo) {
        return codigo == null ? null : servicioRepository.findById(codigo).orElse(null);
    }

    public long contarServiciosOperativos() {
        return servicioRepository.countByEstado("ACTIVO");
    }

    public long contarServicios() {
        return servicioRepository.count();
    }

    @Transactional
    public ServicioFerroviario guardarServicio(ServicioFerroviario servicio) {
        if (servicio.getOrigen() == null || servicio.getDestino() == null) {
            throw new IllegalArgumentException("Debe indicar la estación de origen y la de destino.");
        }
        if (servicio.getOrigen().getCodigo().equals(servicio.getDestino().getCodigo())) {
            throw new IllegalArgumentException("La estación de origen y la de destino no pueden ser la misma.");
        }
        return servicioRepository.save(servicio);
    }

    @Transactional
    public void eliminarServicio(Integer codigo) {
        if (horarioRepository.countByServicioCodigo(codigo) > 0) {
            throw new IllegalStateException(
                    "No se puede eliminar: el servicio tiene horarios programados. Elimine primero sus horarios.");
        }
        servicioRepository.deleteById(codigo);
    }

    /* ------------------------- Horarios -------------------------- */

    public List<HorarioFerroviario> listarHorarios() {
        return horarioRepository.listarCompleto();
    }

    public List<HorarioFerroviario> listarHorariosPorServicio(Integer servicioCodigo) {
        return horarioRepository.findByServicioCodigoOrderByHoraSalidaAsc(servicioCodigo);
    }

    /** CU-03 paso 4: horarios y tarifas asociados a la estacion consultada. */
    public List<HorarioFerroviario> listarHorariosPorEstacion(Integer estacionCodigo) {
        return horarioRepository.listarPorEstacion(estacionCodigo);
    }

    public HorarioFerroviario obtenerHorario(Integer codigo) {
        return codigo == null ? null : horarioRepository.findById(codigo).orElse(null);
    }

    public long contarHorarios() {
        return horarioRepository.count();
    }

    /** Proxima salida disponible desde la estacion respecto de la hora actual. */
    public HorarioFerroviario proximaSalida(Integer estacionCodigo, LocalTime referencia) {
        List<HorarioFerroviario> horarios = listarHorariosPorEstacion(estacionCodigo);
        if (horarios.isEmpty()) {
            return null;
        }
        LocalTime ahora = referencia == null ? LocalTime.now() : referencia;
        return horarios.stream()
                .filter(h -> "ACTIVO".equals(h.getEstado()))
                .filter(h -> h.getHoraSalida() != null && !h.getHoraSalida().isBefore(ahora))
                .min(Comparator.comparing(HorarioFerroviario::getHoraSalida))
                // Si ya paso la ultima salida del dia, se ofrece la primera del dia siguiente
                .orElseGet(() -> horarios.stream()
                        .min(Comparator.comparing(HorarioFerroviario::getHoraSalida))
                        .orElse(null));
    }

    /** Tarifa mas economica disponible desde la estacion (RF06). */
    public BigDecimal tarifaDesde(Integer estacionCodigo) {
        return listarHorariosPorEstacion(estacionCodigo).stream()
                .map(HorarioFerroviario::getTarifa)
                .filter(java.util.Objects::nonNull)
                .min(BigDecimal::compareTo)
                .orElse(null);
    }

    @Transactional
    public HorarioFerroviario guardarHorario(HorarioFerroviario horario) {
        List<String> errores = new ArrayList<>();
        if (horario.getServicio() == null) {
            errores.add("Debe seleccionar el servicio ferroviario.");
        }
        if (horario.getHoraSalida() == null || horario.getHoraLlegada() == null) {
            errores.add("La hora de salida y la de llegada son obligatorias.");
        }
        if (horario.getTarifa() == null || horario.getTarifa().signum() < 0) {
            errores.add("La tarifa debe ser un valor válido.");
        }
        if (!errores.isEmpty()) {
            throw new IllegalArgumentException(String.join(" ", errores));
        }
        horario.recalcularTiempoRecorrido();
        return horarioRepository.save(horario);
    }

    @Transactional
    public void eliminarHorario(Integer codigo) {
        horarioRepository.deleteById(codigo);
    }

    /** Ajuste porcentual masivo de tarifas de todos los horarios (accion "Update Prices"). */
    @Transactional
    public int ajustarTarifas(double porcentaje) {
        List<HorarioFerroviario> horarios = listarHorarios();
        int afectados = 0;
        for (HorarioFerroviario h : horarios) {
            if (h.getTarifa() != null) {
                BigDecimal factor = BigDecimal.valueOf(1 + (porcentaje / 100d));
                h.setTarifa(h.getTarifa().multiply(factor).setScale(2, java.math.RoundingMode.HALF_UP));
                horarioRepository.save(h);
                afectados++;
            }
        }
        return afectados;
    }
}
