package com.zonasturisticas.plataforma.services;

import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import com.zonasturisticas.plataforma.beans.Horario;
import com.zonasturisticas.plataforma.repositories.HorarioRepository;

@Service
public class HorarioService {

    private final HorarioRepository horarioRepository;

    public HorarioService(HorarioRepository horarioRepository) {
        this.horarioRepository = horarioRepository;
    }

    public List<Horario> listarPorFecha(LocalDate fecha) {
        return listarPorFecha(fecha, null);
    }

    public List<Horario> listarPorFecha(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return horarioRepository.findByFechaOrderByHoraInicioAsc(fecha);
        }
        return horarioRepository.findByFechaConEmpresas(fecha, empresaIds);
    }

    public Horario obtenerPorId(int id) {
        return horarioRepository.findById(id).orElse(null);
    }

    public Horario guardar(Horario horario) {
        // Simple validation: End time must be after Start time
        if (horario.getHoraFin().isBefore(horario.getHoraInicio())) {
            throw new IllegalArgumentException("La hora de fin debe ser posterior a la hora de inicio.");
        }
        return horarioRepository.save(horario);
    }

    public void eliminar(int id) {
        horarioRepository.deleteById(id);
    }

    @org.springframework.transaction.annotation.Transactional
    public void eliminarPorEmpleadoYFecha(int empleadoId, LocalDate fecha) {
        horarioRepository.deleteByEmpleadoIdAndFecha(empleadoId, fecha);
    }
}
