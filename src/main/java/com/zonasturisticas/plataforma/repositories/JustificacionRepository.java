package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Justificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface JustificacionRepository extends JpaRepository<Justificacion, Integer> {
        List<Justificacion> findByEmpleadoIdOrderByFechaSolicitudDesc(int empleadoId);

        List<Justificacion> findAllByOrderByFechaSolicitudDesc();

        long countByEstado(String estado);

        // Pagination Support
        org.springframework.data.domain.Page<Justificacion> findByEmpleadoIdOrderByFechaSolicitudDesc(int empleadoId,
                        org.springframework.data.domain.Pageable pageable);

        org.springframework.data.domain.Page<Justificacion> findAllByOrderByFechaSolicitudDesc(
                        org.springframework.data.domain.Pageable pageable);

        // Search for Admin (by Empleado Name or DNI)
        @org.springframework.data.jpa.repository.Query("SELECT j FROM Justificacion j WHERE LOWER(j.empleado.nombres) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(j.empleado.apellidos) LIKE LOWER(CONCAT('%', :keyword, '%')) OR j.empleado.dni LIKE %:keyword%")
        org.springframework.data.domain.Page<Justificacion> buscarPorKeyword(
                        @org.springframework.data.repository.query.Param("keyword") String keyword,
                        org.springframework.data.domain.Pageable pageable);

        @org.springframework.data.jpa.repository.Query("SELECT j FROM Justificacion j WHERE " +
                        "( :empleadoId IS NULL OR j.empleado.id = :empleadoId ) AND " +
                        "( COALESCE(:keyword, '') = '' OR LOWER(j.empleado.nombres) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(j.empleado.apellidos) LIKE LOWER(CONCAT('%', :keyword, '%')) OR j.empleado.dni LIKE %:keyword% ) AND "
                        +
                        "( :fechaSolicitud IS NULL OR j.fechaSolicitud = :fechaSolicitud ) AND " +
                        "( :fechaInicio IS NULL OR j.fechaInicio >= :fechaInicio ) AND " +
                        "( :fechaFin IS NULL OR j.fechaInicio <= :fechaFin ) AND " +
                        "( COALESCE(:estado, '') = '' OR j.estado = :estado )")
        org.springframework.data.domain.Page<Justificacion> buscarAvanzado(
                        @org.springframework.data.repository.query.Param("empleadoId") Integer empleadoId,
                        @org.springframework.data.repository.query.Param("keyword") String keyword,
                        @org.springframework.data.repository.query.Param("fechaSolicitud") java.time.LocalDate fechaSolicitud,
                        @org.springframework.data.repository.query.Param("fechaInicio") java.time.LocalDate fechaInicio,
                        @org.springframework.data.repository.query.Param("fechaFin") java.time.LocalDate fechaFin,
                        @org.springframework.data.repository.query.Param("estado") String estado,
                        org.springframework.data.domain.Pageable pageable);
}
