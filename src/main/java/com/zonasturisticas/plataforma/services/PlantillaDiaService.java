package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.PlantillaDia;
import com.zonasturisticas.plataforma.repositories.PlantillaDiaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PlantillaDiaService {

    private final PlantillaDiaRepository plantillaDiaRepository;

    public PlantillaDiaService(PlantillaDiaRepository plantillaDiaRepository) {
        this.plantillaDiaRepository = plantillaDiaRepository;
    }

    public List<PlantillaDia> listarTodos() {
        return plantillaDiaRepository.findAllByOrderByFechaCreacionDesc();
    }

    public PlantillaDia obtenerPorId(int id) {
        return plantillaDiaRepository.findById(id).orElse(null);
    }

    public PlantillaDia guardar(PlantillaDia plantilla) {
        return plantillaDiaRepository.save(plantilla);
    }

    public void eliminar(int id) {
        plantillaDiaRepository.deleteById(id);
    }
}
