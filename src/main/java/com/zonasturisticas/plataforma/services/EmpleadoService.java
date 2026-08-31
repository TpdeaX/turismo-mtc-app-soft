package com.zonasturisticas.plataforma.services;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.beans.Permiso;
import com.zonasturisticas.plataforma.repositories.EmpleadoRepository;
import com.zonasturisticas.plataforma.repositories.EmpresaRepository;
import com.zonasturisticas.plataforma.repositories.PermisoRepository;

@Service
public class EmpleadoService {

    private final EmpleadoRepository empleadoRepository;
    private final PermisoRepository permisoRepository;
    private final EmpresaRepository empresaRepository;

    public EmpleadoService(EmpleadoRepository empleadoRepository, PermisoRepository permisoRepository,
            EmpresaRepository empresaRepository) {
        this.empleadoRepository = empleadoRepository;
        this.permisoRepository = permisoRepository;
        this.empresaRepository = empresaRepository;
    }

    public Empleado validarLogin(String dni, String password) {
        // Usar query con JOIN FETCH para cargar empresas (evita
        // LazyInitializationException)
        return empleadoRepository.findByDniAndPasswordWithEmpresas(dni, password);
    }

    public List<Empleado> listarEmpleados() {
        return empleadoRepository.findByEstadoOrderByApellidosAsc(1);
    }

    // Método para la paginación en la vista web (sobrecarga para compatibilidad)
    public Page<Empleado> listarAvanzado(String keyword, String rol, String modalidad, Integer sucursalId, int page,
            int size) {
        return listarAvanzado(keyword, rol, modalidad, sucursalId, null, page, size);
    }

    // Método con filtro por empresas del administrador
    public Page<Empleado> listarAvanzado(String keyword, String rol, String modalidad, Integer sucursalId,
            java.util.List<Integer> empresaIds, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("apellidos").ascending());
        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (rol != null && rol.trim().isEmpty())
            rol = null;
        if (modalidad != null && modalidad.trim().isEmpty())
            modalidad = null;

        // Si hay empresaIds, usar la query con filtro de empresas
        if (empresaIds != null && !empresaIds.isEmpty()) {
            return empleadoRepository.buscarAvanzadoConEmpresas(keyword, rol, modalidad, sucursalId, empresaIds,
                    pageable);
        }
        return empleadoRepository.buscarAvanzado(keyword, rol, modalidad, sucursalId, pageable);
    }

    // Sobrecarga para compatibilidad
    public List<Empleado> listarAvanzadoSinPaginacion(String keyword, String rol, String modalidad,
            Integer sucursalId) {
        return listarAvanzadoSinPaginacion(keyword, rol, modalidad, sucursalId, null);
    }

    // Método con filtro por empresas
    public List<Empleado> listarAvanzadoSinPaginacion(String keyword, String rol, String modalidad,
            Integer sucursalId, java.util.List<Integer> empresaIds) {

        Pageable pageable = PageRequest.of(0, 10000, Sort.by("apellidos").ascending());

        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (rol != null && rol.trim().isEmpty())
            rol = null;
        if (modalidad != null && modalidad.trim().isEmpty())
            modalidad = null;

        // Si hay empresaIds, usar la query con filtro de empresas
        if (empresaIds != null && !empresaIds.isEmpty()) {
            return empleadoRepository
                    .buscarAvanzadoConEmpresas(keyword, rol, modalidad, sucursalId, empresaIds, pageable).getContent();
        }
        return empleadoRepository.buscarAvanzado(keyword, rol, modalidad, sucursalId, pageable).getContent();
    }

    // Sobrecarga para compatibilidad
    public int registrarEmpleado(Empleado e, List<String> permisosSeleccionados) {
        return registrarEmpleado(e, permisosSeleccionados, null);
    }

    @Transactional
    public int registrarEmpleado(Empleado e, List<String> permisosSeleccionados, List<Integer> empresaIds) {
        try {
            e.setEstado(1);
            if (e.getPassword() == null || e.getPassword().trim().isEmpty()) {
                e.setPassword(e.getDni());
            }
            asignarPermisosLogica(e, permisosSeleccionados);
            asignarEmpresasLogica(e, empresaIds);
            empleadoRepository.save(e);
            return 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        }
    }

    // Sobrecarga para compatibilidad
    public int actualizarEmpleado(Empleado e, List<String> permisosSeleccionados) {
        return actualizarEmpleado(e, permisosSeleccionados, null);
    }

    // --- LÓGICA DE ACTUALIZACIÓN ---
    @Transactional
    public int actualizarEmpleado(Empleado e, List<String> permisosSeleccionados, List<Integer> empresaIds) {
        return empleadoRepository.findById(e.getId()).map(existing -> {
            existing.setNombres(e.getNombres());
            existing.setApellidos(e.getApellidos());
            existing.setDni(e.getDni());
            existing.setSueldoBase(e.getSueldoBase());
            existing.setRol(e.getRol());
            existing.setTipoModalidad(e.getTipoModalidad());
            existing.setSucursal(e.getSucursal());

            asignarPermisosLogica(existing, permisosSeleccionados);
            asignarEmpresasLogica(existing, empresaIds);

            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }

    // --- MÉTODO AUXILIAR ---
    private void asignarPermisosLogica(Empleado e, List<String> permisosSeleccionados) {
        if (e.getPermisos() == null) {
            e.setPermisos(new HashSet<>());
        } else {
            e.getPermisos().clear();
        }

        if ("ADMIN".equals(e.getRol()) || "SUPER_ADMIN".equals(e.getRol())) {
            List<Permiso> todos = permisoRepository.findAll();
            e.getPermisos().addAll(todos);
        } else if ("PERSONALIZADO".equals(e.getRol())) {
            if (permisosSeleccionados != null && !permisosSeleccionados.isEmpty()) {
                List<String> permisosLimpios = new ArrayList<>();
                for (String p : permisosSeleccionados) {
                    if (p != null)
                        permisosLimpios.add(p.trim());
                }
                List<Permiso> permisosEncontrados = permisoRepository.findByNombreIn(permisosLimpios);
                e.getPermisos().addAll(permisosEncontrados);
            }
        }
    }

    /**
     * Asigna empresas al empleado (solo cuando SUPER_ADMIN lo hace)
     */
    private void asignarEmpresasLogica(Empleado e, List<Integer> empresaIds) {
        if (empresaIds == null) {
            return; // No se proporcionaron empresas, no modificar
        }

        if (e.getEmpresas() == null) {
            e.setEmpresas(new HashSet<>());
        } else {
            e.getEmpresas().clear();
        }

        if (!empresaIds.isEmpty()) {
            List<Empresa> empresas = empresaRepository.findAllById(empresaIds);
            e.getEmpresas().addAll(empresas);
        }
    }

    public Empleado obtenerPorId(int id) {
        return empleadoRepository.findById(id).orElse(null);
    }

    public int eliminarEmpleado(int id) {
        return empleadoRepository.findById(id).map(existing -> {
            existing.setEstado(0);
            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }

    public int actualizarPassword(int id, String newPassword) {
        return empleadoRepository.findById(id).map(existing -> {
            existing.setPassword(newPassword);
            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }
}
