package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/** RF03 / RF08: consulta y mantenimiento de zonas turisticas. */
public interface ZonaTuristicaRepository extends JpaRepository<ZonaTuristica, Integer> {

    @Query("SELECT DISTINCT z FROM ZonaTuristica z "
            + "LEFT JOIN FETCH z.categorias "
            + "JOIN FETCH z.ruta r JOIN FETCH r.estacion "
            + "ORDER BY z.codigo DESC")
    List<ZonaTuristica> listarCompleto();

    /** CU-02 paso 4: zonas vinculadas a la estacion seleccionada. */
    @Query("SELECT DISTINCT z FROM ZonaTuristica z "
            + "LEFT JOIN FETCH z.categorias "
            + "JOIN FETCH z.ruta r JOIN FETCH r.estacion e "
            + "WHERE e.codigo = :estacion AND z.estado = true "
            + "ORDER BY z.nombre ASC")
    List<ZonaTuristica> listarPorEstacion(@Param("estacion") Integer estacion);

    @Query("SELECT DISTINCT z FROM ZonaTuristica z "
            + "LEFT JOIN FETCH z.categorias "
            + "JOIN FETCH z.ruta r JOIN FETCH r.estacion "
            + "WHERE z.estado = true ORDER BY z.nombre ASC")
    List<ZonaTuristica> listarActivas();

    long countByEstadoTrue();

    long countByRutaCodigo(Integer rutaCodigo);
}
