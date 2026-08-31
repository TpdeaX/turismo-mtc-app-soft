package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Empresa;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EmpresaRepository extends JpaRepository<Empresa, Integer> {

    Optional<Empresa> findByCodigo(String codigo);

    Optional<Empresa> findByEsPrincipalTrue();

    Page<Empresa> findAll(Pageable pageable);

    Page<Empresa> findByNombreContainingIgnoreCaseOrCodigoContainingIgnoreCaseOrRucContainingIgnoreCase(
            String nombre, String codigo, String ruc, Pageable pageable);
}
