package com.zonasturisticas.plataforma.services;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import com.zonasturisticas.plataforma.beans.TipoTurno;
import com.zonasturisticas.plataforma.repositories.TipoTurnoRepository;

@Service
public class TipoTurnoService {

    private final TipoTurnoRepository tipoTurnoRepository;

    public TipoTurnoService(TipoTurnoRepository tipoTurnoRepository) {
        this.tipoTurnoRepository = tipoTurnoRepository;
    }

    public List<TipoTurno> listarTipos() {
        return tipoTurnoRepository.findAll();
    }

    public Page<TipoTurno> listarTipos(Pageable pageable, String keyword) {
        if (keyword != null && !keyword.isBlank()) {
            return tipoTurnoRepository.findByNombreContainingIgnoreCase(keyword, pageable);
        }
        return tipoTurnoRepository.findAll(pageable);
    }

    public Page<TipoTurno> listarTipos(Pageable pageable, String keyword, Integer empresaId) {
        if (empresaId == null) {
            return listarTipos(pageable, keyword);
        }

        if (keyword != null && !keyword.isBlank()) {
            return tipoTurnoRepository.findByEmpresaIdAndNombreContainingIgnoreCase(empresaId, keyword, pageable);
        }
        return tipoTurnoRepository.findByEmpresaId(empresaId, pageable);
    }

    public Page<TipoTurno> listarTiposPorEmpresas(Pageable pageable, String keyword, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return listarTipos(pageable, keyword);
        }
        return tipoTurnoRepository.findGeneralesYPorEmpresas(empresaIds, keyword, pageable);
    }

    public TipoTurno obtenerPorId(int id) {
        return tipoTurnoRepository.findById(id).orElse(null);
    }

    public void guardarTipo(TipoTurno tipo) {
        tipoTurnoRepository.save(tipo);
    }

    public void eliminarTipo(int id) {
        tipoTurnoRepository.deleteById(id);
    }
}
