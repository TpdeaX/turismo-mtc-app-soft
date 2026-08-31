package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.repositories.EmpresaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EmpresaService {

    private final EmpresaRepository empresaRepository;

    public EmpresaService(EmpresaRepository empresaRepository) {
        this.empresaRepository = empresaRepository;
    }

    public List<Empresa> findAll() {
        return empresaRepository.findAll();
    }

    public Optional<Empresa> findById(int id) {
        return empresaRepository.findById(id);
    }

    public Optional<Empresa> findByCodigo(String codigo) {
        return empresaRepository.findByCodigo(codigo);
    }

    public Empresa findPrincipal() {
        return empresaRepository.findByEsPrincipalTrue()
                .orElseGet(() -> {
                    // Fallback: La Peruana por defecto
                    Empresa fallback = new Empresa("PERUANA", "La Peruana");
                    fallback.setColorPrimario("#EC407A");
                    fallback.setColorSecundario("#BA68C8");
                    fallback.setLogoPath("logo-peruana.png");
                    fallback.setLogoDarkPath("logo-peruana-dm.png");
                    fallback.setIconPath("logo-peruana-icon.png");
                    fallback.setIconDarkPath("logo-peruana-icon.png");
                    fallback.setUsarMismoLogoOscuro(false);
                    fallback.setUsarMismoIconoOscuro(true);
                    fallback.setEsPrincipal(true);
                    return fallback;
                });
    }

    public Empresa save(Empresa empresa) {
        return empresaRepository.save(empresa);
    }

    public void deleteById(int id) {
        empresaRepository.deleteById(id);
    }

    public List<Empresa> listarPorIds(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return empresaRepository.findAllById(ids);
    }

    public Optional<Empresa> obtenerPorId(int id) {
        return empresaRepository.findById(id);
    }

    public Page<Empresa> listarPagina(String keyword, Pageable pageable) {
        if (keyword != null && !keyword.isEmpty()) {
            return empresaRepository
                    .findByNombreContainingIgnoreCaseOrCodigoContainingIgnoreCaseOrRucContainingIgnoreCase(
                            keyword, keyword, keyword, pageable);
        }
        return empresaRepository.findAll(pageable);
    }
}
