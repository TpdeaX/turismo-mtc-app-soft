package com.zonasturisticas.plataforma.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.zonasturisticas.plataforma.beans.Configuracion;

@Repository
public interface ConfiguracionRepository extends JpaRepository<Configuracion, Long> {
    Configuracion findByClave(String clave);

    // Buscar por clave y empresa específica
    Configuracion findByClaveAndEmpresaId(String clave, Integer empresaId);

    // Buscar configuraciones globales (sin empresa)
    Configuracion findByClaveAndEmpresaIsNull(String clave);

    // Listar todas las configuraciones de una empresa
    List<Configuracion> findByEmpresaId(Integer empresaId);

    // Listar configuraciones globales
    List<Configuracion> findByEmpresaIsNull();

    // Listar configuraciones por empresa o globales
    List<Configuracion> findByEmpresaIdOrEmpresaIsNull(Integer empresaId);
}
