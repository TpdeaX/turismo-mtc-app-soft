package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** RNF05: trazabilidad de la disponibilidad de las integraciones externas. */
public interface SincronizacionLogRepository extends JpaRepository<SincronizacionLog, Integer> {

    List<SincronizacionLog> findTop20ByOrderByFechaDesc();

    SincronizacionLog findFirstByFuenteAndEstadoOrderByFechaDesc(String fuente, String estado);

    SincronizacionLog findFirstByFuenteOrderByFechaDesc(String fuente);
}
