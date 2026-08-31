package com.zonasturisticas.plataforma.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.zonasturisticas.plataforma.beans.Asistencia;

@Repository
public interface AsistenciaRepository extends JpaRepository<Asistencia, Integer>,
                org.springframework.data.jpa.repository.JpaSpecificationExecutor<Asistencia> {

        List<Asistencia> findByEmpleadoIdOrderByFechaDesc(int empleadoId);

        List<Asistencia> findAllByOrderByFechaDescHoraEntradaDesc();

        Optional<Asistencia> findByEmpleadoIdAndFechaAndHoraSalidaIsNull(int empleadoId, LocalDate fecha);

        // Encuentra el ultimo turno abierto (sin salida) sin importar la fecha (para
        // cerrar turnos de dias previos)
        Optional<Asistencia> findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(int empleadoId);

        List<Asistencia> findByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

        boolean existsByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

        long countByFecha(LocalDate fecha);

        long countByFechaAndMinutosTardanzaGreaterThan(LocalDate fecha, Long value);

        List<Asistencia> findByFechaBetweenOrderByFechaAsc(LocalDate start, LocalDate end);

        List<Asistencia> findByEmpleadoIdAndFechaBetweenOrderByFechaAsc(int empleadoId, LocalDate start, LocalDate end);

        // Dashboard methods
        List<Asistencia> findByFecha(LocalDate fecha);

        List<Asistencia> findByFechaAndMinutosTardanzaGreaterThan(LocalDate fecha, Long minutos);

        long countByFechaBetween(LocalDate start, LocalDate end);

        long countByFechaBetweenAndMinutosTardanzaGreaterThan(LocalDate start, LocalDate end, Long minutos);

        @org.springframework.data.jpa.repository.Query("SELECT a.modo, COUNT(a) FROM Asistencia a WHERE a.fecha = :fecha GROUP BY a.modo")
        List<Object[]> countByFechaGroupByModo(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha);

        @org.springframework.data.jpa.repository.Query("SELECT a.empleado.id, COUNT(a) as cnt FROM Asistencia a WHERE a.fecha BETWEEN :start AND :end AND (a.minutosTardanza IS NULL OR a.minutosTardanza = 0) GROUP BY a.empleado.id ORDER BY cnt DESC")
        List<Object[]> findTopEmpleadosPuntualesByFechaBetween(
                        @org.springframework.data.repository.query.Param("start") LocalDate start,
                        @org.springframework.data.repository.query.Param("end") LocalDate end,
                        org.springframework.data.domain.Pageable pageable);

        // --- MANEJO DE FILTROS POR EMPRESA (DASHBOARD MULTI-TENANT) ---

        @org.springframework.data.jpa.repository.Query("SELECT COUNT(a) FROM Asistencia a WHERE a.fecha = :fecha AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds)")
        long countByFechaConEmpresas(@org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT COUNT(a) FROM Asistencia a WHERE a.fecha = :fecha AND (a.minutosTardanza > :minutos) AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds)")
        long countByFechaAndMinutosTardanzaGreaterThanConEmpresas(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("minutos") Long minutos,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT a.modo, COUNT(a) FROM Asistencia a WHERE a.fecha = :fecha AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds) GROUP BY a.modo")
        List<Object[]> countByFechaGroupByModoConEmpresas(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT a.empleado.id, COUNT(a) as cnt FROM Asistencia a WHERE a.fecha BETWEEN :start AND :end AND (a.minutosTardanza IS NULL OR a.minutosTardanza = 0) AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds) GROUP BY a.empleado.id ORDER BY cnt DESC")
        List<Object[]> findTopEmpleadosPuntualesByFechaBetweenConEmpresas(
                        @org.springframework.data.repository.query.Param("start") LocalDate start,
                        @org.springframework.data.repository.query.Param("end") LocalDate end,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds,
                        org.springframework.data.domain.Pageable pageable);

        @org.springframework.data.jpa.repository.Query("SELECT a FROM Asistencia a WHERE a.fecha = :fecha AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds)")
        List<Asistencia> findByFechaConEmpresas(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT a FROM Asistencia a WHERE a.fecha = :fecha AND (a.minutosTardanza > 0) AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds)")
        List<Asistencia> findByFechaAndMinutosTardanzaGreaterThanConEmpresas(
                        @org.springframework.data.repository.query.Param("fecha") LocalDate fecha,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);

        @org.springframework.data.jpa.repository.Query("SELECT a FROM Asistencia a WHERE a.fecha BETWEEN :start AND :end AND (:empresaIds IS NULL OR a.empleado.sucursal.empresa.id IN :empresaIds) ORDER BY a.fecha ASC")
        List<Asistencia> findByFechaBetweenConEmpresas(
                        @org.springframework.data.repository.query.Param("start") LocalDate start,
                        @org.springframework.data.repository.query.Param("end") LocalDate end,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds);
}
