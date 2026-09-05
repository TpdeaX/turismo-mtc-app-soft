package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.ServicioFerroviario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/** RF06 / RF13: servicios ferroviarios provistos por PeruRail. */
public interface ServicioFerroviarioRepository extends JpaRepository<ServicioFerroviario, Integer> {

    @Query("SELECT s FROM ServicioFerroviario s "
            + "JOIN FETCH s.origen JOIN FETCH s.destino ORDER BY s.codigo ASC")
    List<ServicioFerroviario> listarCompleto();

    /** CU-03 paso 4: servicios asociados a la estacion consultada. */
    @Query("SELECT s FROM ServicioFerroviario s JOIN FETCH s.origen JOIN FETCH s.destino "
            + "WHERE s.origen.codigo = :estacion OR s.destino.codigo = :estacion "
            + "ORDER BY s.nombre ASC")
    List<ServicioFerroviario> listarPorEstacion(@Param("estacion") Integer estacion);

    long countByEstado(String estado);
}
