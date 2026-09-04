package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Configuracion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** RF12: parametros generales de la plataforma. */
public interface ConfiguracionRepository extends JpaRepository<Configuracion, String> {

    List<Configuracion> findAllByOrderByGrupoAscClaveAsc();

    List<Configuracion> findByGrupoOrderByClaveAsc(String grupo);
}
