package com.zonasturisticas.plataforma.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zonasturisticas.plataforma.beans.EmpleadoPermiso;
import com.zonasturisticas.plataforma.repositories.EmpleadoPermisoRepository;
@Service
public class EmpleadoPermisoService {
	@Autowired
	private EmpleadoPermisoRepository empleadoPermisoRepository;

	public void actualizarPermisosEmpleado(Integer empleadoId, List<Integer> permisosIds) {

	    empleadoPermisoRepository.deleteByEmpleadoId(empleadoId);


	    if(permisosIds != null) {
	        for(Integer permisoId : permisosIds) {
	            empleadoPermisoRepository.save(new EmpleadoPermiso(empleadoId, permisoId));
	        }
	    }
	}


	public List<Integer> obtenerPermisosEmpleado(Integer empleadoId){
	    return empleadoPermisoRepository.findByEmpleadoId(empleadoId)
	            .stream()
	            .map(EmpleadoPermiso::getPermisoId)
	            .toList();
	}

}
