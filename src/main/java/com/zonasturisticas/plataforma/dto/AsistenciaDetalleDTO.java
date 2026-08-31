package com.zonasturisticas.plataforma.dto;

/**
 * DTO para detalles de asistencia en el dashboard
 */
public class AsistenciaDetalleDTO {
    private int id;
    private int empleadoId;
    private String empleadoNombre;
    private String empleadoApellido;
    private String empleadoDni;
    private String fecha;
    private String horaEntrada;
    private String horaSalida;
    private String modo;
    private long minutosTardanza;
    private String sucursalNombre;

    public AsistenciaDetalleDTO() {
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(int empleadoId) {
        this.empleadoId = empleadoId;
    }

    public String getEmpleadoNombre() {
        return empleadoNombre;
    }

    public void setEmpleadoNombre(String empleadoNombre) {
        this.empleadoNombre = empleadoNombre;
    }

    public String getEmpleadoApellido() {
        return empleadoApellido;
    }

    public void setEmpleadoApellido(String empleadoApellido) {
        this.empleadoApellido = empleadoApellido;
    }

    public String getEmpleadoDni() {
        return empleadoDni;
    }

    public void setEmpleadoDni(String empleadoDni) {
        this.empleadoDni = empleadoDni;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getHoraEntrada() {
        return horaEntrada;
    }

    public void setHoraEntrada(String horaEntrada) {
        this.horaEntrada = horaEntrada;
    }

    public String getHoraSalida() {
        return horaSalida;
    }

    public void setHoraSalida(String horaSalida) {
        this.horaSalida = horaSalida;
    }

    public String getModo() {
        return modo;
    }

    public void setModo(String modo) {
        this.modo = modo;
    }

    public long getMinutosTardanza() {
        return minutosTardanza;
    }

    public void setMinutosTardanza(long minutosTardanza) {
        this.minutosTardanza = minutosTardanza;
    }

    public String getSucursalNombre() {
        return sucursalNombre;
    }

    public void setSucursalNombre(String sucursalNombre) {
        this.sucursalNombre = sucursalNombre;
    }

    public String getNombreCompleto() {
        return empleadoNombre + " " + empleadoApellido;
    }
}
