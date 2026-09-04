package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** RF01: catalogo de preferencias turisticas. */
public interface CategoriaRepository extends JpaRepository<Categoria, Integer> {

    List<Categoria> findByEstadoTrueOrderByNombreAsc();

    List<Categoria> findAllByOrderByNombreAsc();

    Categoria findFirstByNombre(String nombre);
}
