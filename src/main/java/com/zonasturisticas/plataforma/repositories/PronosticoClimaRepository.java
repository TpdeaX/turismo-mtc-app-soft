package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.PronosticoClima;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

/** RF04 / RF11: cache del pronostico climatico por zona geografica. */
public interface PronosticoClimaRepository extends JpaRepository<PronosticoClima, Integer> {

    PronosticoClima findFirstByEstacionCodigoAndFecha(Integer estacion, LocalDate fecha);

    @Query("SELECT p FROM PronosticoClima p JOIN FETCH p.estacion "
            + "WHERE p.estacion.codigo = :estacion AND p.fecha >= :desde ORDER BY p.fecha ASC")
    List<PronosticoClima> listarDesde(@Param("estacion") Integer estacion, @Param("desde") LocalDate desde);

    /** Ultimo pronostico valido almacenado (flujo alternativo del CU-07). */
    PronosticoClima findFirstByEstacionCodigoOrderByFechaDesc(Integer estacion);

    void deleteByFechaBefore(LocalDate fecha);
}
