package com.zonasturisticas.plataforma.services;

import java.util.List;
import org.springframework.stereotype.Service;
import com.zonasturisticas.plataforma.beans.PlantillaHorario;
import com.zonasturisticas.plataforma.repositories.PlantillaHorarioRepository;

@Service
public class PlantillaHorarioService {

    private final PlantillaHorarioRepository repository;

    public PlantillaHorarioService(PlantillaHorarioRepository repository) {
        this.repository = repository;
    }

    public List<PlantillaHorario> listarTodos() {
        return repository.findAll();
    }

    public PlantillaHorario obtenerPorId(int id) {
        return repository.findById(id).orElse(null);
    }

    public PlantillaHorario guardar(PlantillaHorario plantilla) {
        return repository.save(plantilla);
    }

    public void eliminar(int id) {
        repository.deleteById(id);
    }
}
