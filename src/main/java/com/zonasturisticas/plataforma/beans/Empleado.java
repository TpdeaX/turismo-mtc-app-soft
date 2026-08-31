package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "empleados")
public class Empleado implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, length = 100)
    private String nombres;

    @Column(nullable = false, length = 100)
    private String apellidos;

    @Column(nullable = false, length = 15, unique = true)
    private String dni;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 20)
    private String rol;

    @Column(columnDefinition = "tinyint(1) default 1")
    private int estado = 1;

    @Column(name = "sueldo_base", columnDefinition = "decimal(10,2) default 1025.00")
    private Double sueldoBase;

    @Column(name = "tipo_modalidad", length = 20, columnDefinition = "varchar(20) default 'OBLIGADO'")
    private String tipoModalidad = "OBLIGADO";

    @ManyToOne
    @JoinColumn(name = "id_sucursal")
    private Sucursal sucursal;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "empleado_permiso", joinColumns = @JoinColumn(name = "empleado_id"), inverseJoinColumns = @JoinColumn(name = "permiso_id"))
    private Set<Permiso> permisos = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "admin_empresas", joinColumns = @JoinColumn(name = "empleado_id"), inverseJoinColumns = @JoinColumn(name = "empresa_id"))
    private Set<Empresa> empresas = new HashSet<>();

    public Empleado() {
    }

    public Empleado(int id, String nombres, String apellidos, String dni, String rol) {
        this.id = id;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.dni = dni;
        this.rol = rol;
    }

    public Set<Permiso> getPermisos() {
        return permisos;
    }

    public void setPermisos(Set<Permiso> permisos) {
        this.permisos = permisos;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }

    public Double getSueldoBase() {
        return sueldoBase;
    }

    public void setSueldoBase(Double sueldoBase) {
        this.sueldoBase = sueldoBase;
    }

    public String getTipoModalidad() {
        return tipoModalidad;
    }

    public void setTipoModalidad(String tipoModalidad) {
        this.tipoModalidad = tipoModalidad;
    }

    public Sucursal getSucursal() {
        return sucursal;
    }

    public void setSucursal(Sucursal sucursal) {
        this.sucursal = sucursal;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }

    public String getPermisosString() {
        if (permisos == null || permisos.isEmpty()) {
            return "";
        }
        return permisos.stream().map(Permiso::getNombre).collect(java.util.stream.Collectors.joining(","));
    }

    public Set<Empresa> getEmpresas() {
        return empresas;
    }

    public void setEmpresas(Set<Empresa> empresas) {
        this.empresas = empresas;
    }

    public Empresa getEmpresaActiva() {
        if (empresas == null || empresas.isEmpty()) {
            return null;
        }
        if (empresas.size() == 1) {
            return empresas.iterator().next();
        }
        return empresas.stream()
                .filter(Empresa::isEsPrincipal)
                .findFirst()
                .orElse(empresas.iterator().next());
    }

    public boolean isSuperAdmin() {
        return "SUPER_ADMIN".equals(rol);
    }

    public boolean isAdmin() {
        return "ADMIN".equals(rol) || "SUPER_ADMIN".equals(rol);
    }

    public boolean tieneAccesoTodasEmpresas() {
        if ("SUPER_ADMIN".equals(rol)) {
            return true;
        }
        return empresas != null && empresas.size() > 1;
    }

    public boolean tieneAccesoTodasSucursales() {
        if ("SUPER_ADMIN".equals(rol)) {
            return true;
        }
        return "ADMIN".equals(rol) && sucursal == null;
    }

    public boolean tieneAccesoTotalSistema() {
        return "SUPER_ADMIN".equals(rol);
    }

    public Set<Integer> getEmpresaIdsAsignadas() {
        if (empresas == null || empresas.isEmpty()) {
            return Collections.emptySet();
        }
        Set<Integer> ids = new HashSet<>();
        for (Empresa empresa : empresas) {
            ids.add(empresa.getId());
        }
        return ids;
    }

    public boolean tieneAccesoEmpresa(int empresaId) {
        return getEmpresaIdsAsignadas().contains(empresaId);
    }
}
