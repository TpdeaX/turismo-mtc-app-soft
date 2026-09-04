package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/** RF06 / RF13: horarios, tiempos de recorrido y tarifas. */
public interface HorarioFerroviarioRepository extends JpaRepository<HorarioFerroviario, Integer> {

    @Query("SELECT h FROM HorarioFerroviario h "
            + "JOIN FETCH h.servicio s JOIN FETCH s.origen JOIN FETCH s.destino "
            + "ORDER BY h.horaSalida ASC")
    List<HorarioFerroviario> listarCompleto();

    List<HorarioFerroviario> findByServicioCodigoOrderByHoraSalidaAsc(Integer servicioCodigo);

    @Query("SELECT h FROM HorarioFerroviario h "
            + "JOIN FETCH h.servicio s JOIN FETCH s.origen JOIN FETCH s.destino "
            + "WHERE s.origen.codigo = :estacion OR s.destino.codigo = :estacion "
            + "ORDER BY h.horaSalida ASC")
    List<HorarioFerroviario> listarPorEstacion(@Param("estacion") Integer estacion);

    long countByServicioCodigo(Integer servicioCodigo);
}
