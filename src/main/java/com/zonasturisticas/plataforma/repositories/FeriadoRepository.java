package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Feriado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
public interface FeriadoRepository extends JpaRepository<Feriado, Integer> {
    Optional<Feriado> findByFecha(LocalDate fecha);

    Optional<Feriado> findByFechaAndEmpresas_IdIn(LocalDate fecha, java.util.List<Integer> empresaIds);

    Page<Feriado> findByDescripcionContainingAndEmpresas_IdIn(String descripcion, java.util.List<Integer> empresaIds,
            Pageable pageable);

    Page<Feriado> findByDescripcionContaining(String descripcion, Pageable pageable);
}
