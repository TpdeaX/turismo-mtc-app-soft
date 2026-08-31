package com.zonasturisticas.plataforma.repositories;

import java.util.List;
import com.zonasturisticas.plataforma.beans.Sucursal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SucursalRepository extends JpaRepository<Sucursal, Integer> {
    Page<Sucursal> findByNombreContainingOrDireccionContainingOrTelefonoContaining(String nombre, String direccion,
            String telefono, Pageable pageable);

    List<Sucursal> findByEmpresaIdIn(List<Integer> empresaIds);

    // Métodos paginados filtrados por empresa
    Page<Sucursal> findByEmpresaIdIn(List<Integer> empresaIds, Pageable pageable);

    Page<Sucursal> findByEmpresaIdInAndNombreContainingIgnoreCaseOrEmpresaIdInAndDireccionContainingIgnoreCaseOrEmpresaIdInAndTelefonoContainingIgnoreCase(
            List<Integer> empresaIds1, String nombre,
            List<Integer> empresaIds2, String direccion,
            List<Integer> empresaIds3, String telefono,
            Pageable pageable);
}
