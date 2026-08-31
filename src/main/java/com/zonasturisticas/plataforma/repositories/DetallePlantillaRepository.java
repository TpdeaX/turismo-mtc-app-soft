package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.DetallePlantilla;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DetallePlantillaRepository extends JpaRepository<DetallePlantilla, Integer> {
    List<DetallePlantilla> findByPlantillaId(int plantillaId);
}
