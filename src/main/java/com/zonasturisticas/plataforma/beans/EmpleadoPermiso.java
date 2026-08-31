package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;

@Entity
@Table(name = "empleado_permiso")
public class EmpleadoPermiso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "empleado_id")
    private Integer empleadoId;

    @Column(name = "permiso_id")
    private Integer permisoId;

    public EmpleadoPermiso() {}

    public EmpleadoPermiso(Integer empleadoId, Integer permisoId) {
        this.empleadoId = empleadoId;
        this.permisoId = permisoId;
    }

    // Getters y Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getEmpleadoId() { return empleadoId; }
    public void setEmpleadoId(Integer empleadoId) { this.empleadoId = empleadoId; }

    public Integer getPermisoId() { return permisoId; }
    public void setPermisoId(Integer permisoId) { this.permisoId = permisoId; }
}
