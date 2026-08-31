package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.PlantillaDia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlantillaDiaRepository extends JpaRepository<PlantillaDia, Integer> {
    List<PlantillaDia> findAllByOrderByFechaCreacionDesc();
}
