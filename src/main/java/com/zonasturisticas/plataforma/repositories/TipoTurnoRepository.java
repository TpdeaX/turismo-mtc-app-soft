package com.zonasturisticas.plataforma.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import com.zonasturisticas.plataforma.beans.TipoTurno;

@Repository
public interface TipoTurnoRepository extends JpaRepository<TipoTurno, Integer> {
    TipoTurno findByNombre(String nombre);

    Page<TipoTurno> findByNombreContainingIgnoreCase(String nombre, Pageable pageable);

    Page<TipoTurno> findByEmpresaId(int empresaId, Pageable pageable);

    Page<TipoTurno> findByEmpresaIdAndNombreContainingIgnoreCase(int empresaId, String nombre, Pageable pageable);

    @Query("""
            SELECT t FROM TipoTurno t
            WHERE (t.empresa IS NULL OR t.empresa.id IN :empresaIds)
              AND (:keyword IS NULL OR :keyword = '' OR LOWER(t.nombre) LIKE LOWER(CONCAT('%', :keyword, '%')))
            """)
    Page<TipoTurno> findGeneralesYPorEmpresas(@Param("empresaIds") java.util.List<Integer> empresaIds,
            @Param("keyword") String keyword, Pageable pageable);
}
