package com.zonasturisticas.plataforma.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class ReporteAsistenciaDTO {

    private LocalDate fecha;
    private String nombreEmpleado;
    private String dniEmpleado;
    private String sucursal;

    // Horario Programado
    private LocalTime horarioEntrada;
    private LocalTime horarioSalida;

    // Asistencia Real
    private LocalTime asistenciaEntrada;
    private LocalTime asistenciaSalida;

    // Cálculos
    private double horasProgramadas;
    private double horasTrabajadas;
    private double diferenciaHoras; // Positivo = Extra, Negativo = Deuda

    private String estado; // OK, TARDE, FALTA, FERIADO, FERIADO LABORADO
    private String observacion;

    private String fotoUrl;
    private String fotoUrlSalida;

    public ReporteAsistenciaDTO() {
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
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

    public LocalTime getHorarioEntrada() {
        return horarioEntrada;
    }

    public void setHorarioEntrada(LocalTime horarioEntrada) {
        this.horarioEntrada = horarioEntrada;
    }

    public LocalTime getHorarioSalida() {
        return horarioSalida;
    }

    public void setHorarioSalida(LocalTime horarioSalida) {
        this.horarioSalida = horarioSalida;
    }

    public LocalTime getAsistenciaEntrada() {
        return asistenciaEntrada;
    }

    public void setAsistenciaEntrada(LocalTime asistenciaEntrada) {
        this.asistenciaEntrada = asistenciaEntrada;
    }

    public LocalTime getAsistenciaSalida() {
        return asistenciaSalida;
    }

    public void setAsistenciaSalida(LocalTime asistenciaSalida) {
        this.asistenciaSalida = asistenciaSalida;
    }

    public double getHorasProgramadas() {
        return horasProgramadas;
    }

    public void setHorasProgramadas(double horasProgramadas) {
        this.horasProgramadas = horasProgramadas;
    }

    public double getHorasTrabajadas() {
        return horasTrabajadas;
    }

    public void setHorasTrabajadas(double horasTrabajadas) {
        this.horasTrabajadas = horasTrabajadas;
    }

    public double getDiferenciaHoras() {
        return diferenciaHoras;
    }

    public void setDiferenciaHoras(double diferenciaHoras) {
        this.diferenciaHoras = diferenciaHoras;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public String getFotoUrl() {
        return fotoUrl;
    }

    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }

    public String getFotoUrlSalida() {
        return fotoUrlSalida;
    }

    public void setFotoUrlSalida(String fotoUrlSalida) {
        this.fotoUrlSalida = fotoUrlSalida;
    }

    // Nuevos campos unificados
    private int minutosTardanza;
    private int minutosExtras;
    private double dineroDescuento;
    private double dineroBonificacion;
    private String modo; // QR, GPS, MIXTO

    public int getMinutosTardanza() {
        return minutosTardanza;
    }

    public void setMinutosTardanza(int minutosTardanza) {
        this.minutosTardanza = minutosTardanza;
    }

    public int getMinutosExtras() {
        return minutosExtras;
    }

    public void setMinutosExtras(int minutosExtras) {
        this.minutosExtras = minutosExtras;
    }

    public double getDineroDescuento() {
        return dineroDescuento;
    }

    public void setDineroDescuento(double dineroDescuento) {
        this.dineroDescuento = dineroDescuento;
    }

    public double getDineroBonificacion() {
        return dineroBonificacion;
    }

    public void setDineroBonificacion(double dineroBonificacion) {
        this.dineroBonificacion = dineroBonificacion;
    }

    public String getModo() {
        return modo;
    }

    public void setModo(String modo) {
        this.modo = modo;
    }
}
