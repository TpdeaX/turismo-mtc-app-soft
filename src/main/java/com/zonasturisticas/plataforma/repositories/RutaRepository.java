package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Ruta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

/** RF05: rutas caminables asociadas a cada estacion. */
public interface RutaRepository extends JpaRepository<Ruta, Integer> {

    List<Ruta> findByEstacionCodigoOrderByNombreAsc(Integer estacionCodigo);

    @Query("SELECT r FROM Ruta r JOIN FETCH r.estacion ORDER BY r.codigo ASC")
    List<Ruta> listarConEstacion();

    long countByEstacionCodigo(Integer estacionCodigo);
}
