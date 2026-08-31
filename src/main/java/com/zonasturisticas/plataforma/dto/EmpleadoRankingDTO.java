package com.zonasturisticas.plataforma.dto;

/**
 * DTO para representar el ranking de empleados por puntualidad/asistencia
 */
public class EmpleadoRankingDTO {
    private int id;
    private String nombres;
    private String apellidos;
    private String dni;
    private int totalAsistencias;
    private long minutosTardanzaTotal;
    private double promedioPuntualidad; // 0-100%

    public EmpleadoRankingDTO() {
    }

    public EmpleadoRankingDTO(int id, String nombres, String apellidos, String dni) {
        this.id = id;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.dni = dni;
    }

    // Getters and Setters
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

    public int getTotalAsistencias() {
        return totalAsistencias;
    }

    public void setTotalAsistencias(int totalAsistencias) {
        this.totalAsistencias = totalAsistencias;
    }

    public long getMinutosTardanzaTotal() {
        return minutosTardanzaTotal;
    }

    public void setMinutosTardanzaTotal(long minutosTardanzaTotal) {
        this.minutosTardanzaTotal = minutosTardanzaTotal;
    }

    public double getPromedioPuntualidad() {
        return promedioPuntualidad;
    }

    public void setPromedioPuntualidad(double promedioPuntualidad) {
        this.promedioPuntualidad = promedioPuntualidad;
    }

    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }
}
