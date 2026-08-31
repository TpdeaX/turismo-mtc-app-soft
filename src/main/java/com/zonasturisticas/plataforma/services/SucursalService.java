package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Sucursal;
import com.zonasturisticas.plataforma.repositories.SucursalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SucursalService {

    @Autowired
    private SucursalRepository sucursalRepository;

    public List<Sucursal> listarTodas() {
        return sucursalRepository.findAll();
    }

    public List<Sucursal> listarPorEmpresas(List<Integer> empresaIds) {
        return sucursalRepository.findByEmpresaIdIn(empresaIds);
    }

    public Page<Sucursal> listarPagina(String keyword, Pageable pageable) {
        if (keyword != null && !keyword.isEmpty()) {
            return sucursalRepository.findByNombreContainingOrDireccionContainingOrTelefonoContaining(keyword, keyword,
                    keyword, pageable);
        }
        return sucursalRepository.findAll(pageable);
    }

    public Page<Sucursal> listarPaginaPorEmpresas(List<Integer> empresaIds, String keyword, Pageable pageable) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return Page.empty(pageable);
        }
        if (keyword != null && !keyword.isEmpty()) {
            return sucursalRepository
                    .findByEmpresaIdInAndNombreContainingIgnoreCaseOrEmpresaIdInAndDireccionContainingIgnoreCaseOrEmpresaIdInAndTelefonoContainingIgnoreCase(
                            empresaIds, keyword, empresaIds, keyword, empresaIds, keyword, pageable);
        }
        return sucursalRepository.findByEmpresaIdIn(empresaIds, pageable);
    }

    public Optional<Sucursal> obtenerPorId(int id) {
        return sucursalRepository.findById(id);
    }

    public Sucursal guardar(Sucursal sucursal) {
        return sucursalRepository.save(sucursal);
    }

    public void eliminar(int id) {
        sucursalRepository.deleteById(id);
    }
}
