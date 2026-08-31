package com.zonasturisticas.plataforma.dto;

public class ReporteResumenDTO {
    private Integer empleadoId;
    private String nombreEmpleado;
    private String dniEmpleado;
    private String sucursal;

    // Contadores
    private double totalHorasProgramadas;
    private double totalHorasTrabajadas;
    private double totalHorasExtras; // Calculado como diferencia cuando tr > pr
    private double totalHorasDeuda; // Calculado como diferencia cuando pr > tr

    private int totalMinutosTardanza;
    private int diasAsistidos;
    private int diasFaltas;
    private int diasFeriadosLaborados;
    private int cantidadTardanzas;

    public ReporteResumenDTO() {
    }

    // Getters and Setters
    public Integer getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(Integer empleadoId) {
        this.empleadoId = empleadoId;
    }

    public String getNombreEmpleado() {
        return nombreEmpleado;
    }

    public void setNombreEmpleado(String nombreEmpleado) {
        this.nombreEmpleado = nombreEmpleado;
    }

    public String getDniEmpleado() {
        return dniEmpleado;
    }

    public void setDniEmpleado(String dniEmpleado) {
        this.dniEmpleado = dniEmpleado;
    }

    public String getSucursal() {
        return sucursal;
    }

    public void setSucursal(String sucursal) {
        this.sucursal = sucursal;
    }

    public double getTotalHorasProgramadas() {
        return totalHorasProgramadas;
    }

    public void setTotalHorasProgramadas(double totalHorasProgramadas) {
        this.totalHorasProgramadas = totalHorasProgramadas;
    }

    public double getTotalHorasTrabajadas() {
        return totalHorasTrabajadas;
    }

    public void setTotalHorasTrabajadas(double totalHorasTrabajadas) {
        this.totalHorasTrabajadas = totalHorasTrabajadas;
    }

    public double getTotalHorasExtras() {
        return totalHorasExtras;
    }

    public void setTotalHorasExtras(double totalHorasExtras) {
        this.totalHorasExtras = totalHorasExtras;
    }

    public double getTotalHorasDeuda() {
        return totalHorasDeuda;
    }

    public void setTotalHorasDeuda(double totalHorasDeuda) {
        this.totalHorasDeuda = totalHorasDeuda;
    }

    public int getTotalMinutosTardanza() {
        return totalMinutosTardanza;
    }

    public void setTotalMinutosTardanza(int totalMinutosTardanza) {
        this.totalMinutosTardanza = totalMinutosTardanza;
    }

    public int getDiasAsistidos() {
        return diasAsistidos;
    }

    public void setDiasAsistidos(int diasAsistidos) {
        this.diasAsistidos = diasAsistidos;
    }

    public int getDiasFaltas() {
        return diasFaltas;
    }

    public void setDiasFaltas(int diasFaltas) {
        this.diasFaltas = diasFaltas;
    }

    public int getDiasFeriadosLaborados() {
        return diasFeriadosLaborados;
    }

    public void setDiasFeriadosLaborados(int diasFeriadosLaborados) {
        this.diasFeriadosLaborados = diasFeriadosLaborados;
    }

    public int getCantidadTardanzas() {
        return cantidadTardanzas;
    }

    public void setCantidadTardanzas(int cantidadTardanzas) {
        this.cantidadTardanzas = cantidadTardanzas;
    }
}
