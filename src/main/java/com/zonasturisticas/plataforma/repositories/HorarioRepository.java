package com.zonasturisticas.plataforma.repositories;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.zonasturisticas.plataforma.beans.Horario;

@Repository
public interface HorarioRepository extends JpaRepository<Horario, Integer> {

        Horario findFirstByEmpleadoIdAndFechaAndHoraFinAfterOrderByHoraInicioAsc(int empleadoId, LocalDate fecha,
                        LocalTime hora);

        List<Horario> findByFechaOrderByHoraInicioAsc(LocalDate fecha);

        List<Horario> findByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

        List<Horario> findByFechaBetween(LocalDate start, LocalDate end);

        List<Horario> findByEmpleadoIdAndFechaBetween(int empleadoId, LocalDate start, LocalDate end);

        void deleteByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

        @org.springframework.data.jpa.repository.Query("SELECT h FROM Horario h WHERE h.fecha = :fecha AND (:empresaIds IS NULL OR h.empleado.sucursal.empresa.id IN :empresaIds) ORDER BY h.horaInicio ASC")
        List<Horario> findByFechaConEmpresas(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("empresaIds") List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT h FROM Horario h WHERE h.fecha BETWEEN :start AND :end AND (:empresaIds IS NULL OR h.empleado.sucursal.empresa.id IN :empresaIds)")
        List<Horario> findByFechaBetweenConEmpresas(
                        @org.springframework.data.repository.query.Param("start") LocalDate start,
                        @org.springframework.data.repository.query.Param("end") LocalDate end,
                        @org.springframework.data.repository.query.Param("empresaIds") List<Integer> empresaIds);
}
