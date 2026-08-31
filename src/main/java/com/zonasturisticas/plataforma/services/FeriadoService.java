package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Feriado;
import com.zonasturisticas.plataforma.repositories.FeriadoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

@Service
public class FeriadoService {

    @Autowired
    private FeriadoRepository feriadoRepository;

    public List<Feriado> listarTodos() {
        return feriadoRepository.findAll();
    }

    public Page<Feriado> listar(String keyword, int page, int size, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return feriadoRepository.findByDescripcionContaining(keyword,
                    PageRequest.of(page, size, Sort.by("fecha").descending()));
        }
        return feriadoRepository.findByDescripcionContainingAndEmpresas_IdIn(keyword, empresaIds,
                PageRequest.of(page, size, Sort.by("fecha").descending()));
    }

    // ... existing obtenerPorId ...
    public Optional<Feriado> obtenerPorId(int id) {
        return feriadoRepository.findById(id);
    }

    public Feriado guardar(Feriado feriado) {
        return feriadoRepository.save(feriado);
    }

    public void eliminar(int id) {
        feriadoRepository.deleteById(id);
    }

    public boolean esFeriado(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            // Fallback to global check if no company context (though logic suggests we
            // should always have context)
            // or maybe check if there is ANY holiday on that date for ANY of the provided
            // companies?
            // Since we added findByFechaAndEmpresas_IdIn, let's use it if IDs are present.
            return feriadoRepository.findByFecha(fecha).isPresent();
        }
        return feriadoRepository.findByFechaAndEmpresas_IdIn(fecha, empresaIds).isPresent();
    }
}
