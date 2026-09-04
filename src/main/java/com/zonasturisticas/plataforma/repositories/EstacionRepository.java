package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Estacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/** RF09 / CU-05: consulta del listado de estaciones. */
public interface EstacionRepository extends JpaRepository<Estacion, Integer> {

    List<Estacion> findAllByOrderByNombreAsc();

    @Query("SELECT e FROM Estacion e WHERE "
            + "LOWER(e.nombre) LIKE LOWER(CONCAT('%', :q, '%')) OR "
            + "LOWER(e.ubicacion) LIKE LOWER(CONCAT('%', :q, '%')) OR "
            + "LOWER(e.region) LIKE LOWER(CONCAT('%', :q, '%')) "
            + "ORDER BY e.nombre ASC")
    List<Estacion> buscar(@Param("q") String q);

    @Query("SELECT DISTINCT e.region FROM Estacion e WHERE e.region IS NOT NULL ORDER BY e.region ASC")
    List<String> listarRegiones();

    Estacion findFirstByNombre(String nombre);
}
