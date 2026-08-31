package com.zonasturisticas.plataforma.repositories;

import java.util.List;
import java.util.Optional; // Importante
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.zonasturisticas.plataforma.beans.Permiso;

@Repository
public interface PermisoRepository extends JpaRepository<Permiso, Integer> {
    
    
    List<Permiso> findByNombreIn(List<String> nombres);

 
    Optional<Permiso> findByNombre(String nombre);
}
