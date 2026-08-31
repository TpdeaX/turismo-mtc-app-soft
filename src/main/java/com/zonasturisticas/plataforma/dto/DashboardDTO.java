package com.zonasturisticas.plataforma.dto;

import java.util.List;
import java.util.Map;

/**
 * DTO para encapsular todos los datos del dashboard
 */
public class DashboardDTO {
    // KPIs
    private long totalEmpleados;
    private long asistenciasHoy;
    private long inasistenciasHoy;
    private long tardanzasHoy;
    private long justificacionesPendientes;
    private double tasaPuntualidad; // Porcentaje 0-100

    // Mejor empleado
    private EmpleadoRankingDTO mejorEmpleado;

    // Listas detalladas
    private List<AsistenciaDetalleDTO> listaAsistencias;
    private List<AsistenciaDetalleDTO> listaTardanzas;
    private List<EmpleadoRankingDTO> listaInasistentes;

    // Datos para gráficos
    private List<Long> chartAsistenciaSemanal; // 7 días
    private List<Long> chartTardanzasSemanal; // 7 días
    private List<String> chartLabels; // Labels para los días
    private Map<String, Long> chartDistribucionModos; // QR, GPS, MANUAL
    private List<Long> chartSolicitudes; // Pendiente, Aprobado, Rechazado

    // Metadata
    private String rangoFechaInicio;
    private String rangoFechaFin;
    private String tipoRango; // HOY, SEMANA, MES, AÑO, PERSONALIZADO

    public DashboardDTO() {
    }

    // Getters and Setters
    public long getTotalEmpleados() {
        return totalEmpleados;
    }

    public void setTotalEmpleados(long totalEmpleados) {
        this.totalEmpleados = totalEmpleados;
    }

    public long getAsistenciasHoy() {
        return asistenciasHoy;
    }

    public void setAsistenciasHoy(long asistenciasHoy) {
        this.asistenciasHoy = asistenciasHoy;
    }

    public long getInasistenciasHoy() {
        return inasistenciasHoy;
    }

    public void setInasistenciasHoy(long inasistenciasHoy) {
        this.inasistenciasHoy = inasistenciasHoy;
    }

    public long getTardanzasHoy() {
        return tardanzasHoy;
    }

    public void setTardanzasHoy(long tardanzasHoy) {
        this.tardanzasHoy = tardanzasHoy;
    }

    public long getJustificacionesPendientes() {
        return justificacionesPendientes;
    }

    public void setJustificacionesPendientes(long justificacionesPendientes) {
        this.justificacionesPendientes = justificacionesPendientes;
    }

    public double getTasaPuntualidad() {
        return tasaPuntualidad;
    }

    public void setTasaPuntualidad(double tasaPuntualidad) {
        this.tasaPuntualidad = tasaPuntualidad;
    }

    public EmpleadoRankingDTO getMejorEmpleado() {
        return mejorEmpleado;
    }

    public void setMejorEmpleado(EmpleadoRankingDTO mejorEmpleado) {
        this.mejorEmpleado = mejorEmpleado;
    }

    public List<AsistenciaDetalleDTO> getListaAsistencias() {
        return listaAsistencias;
    }

    public void setListaAsistencias(List<AsistenciaDetalleDTO> listaAsistencias) {
        this.listaAsistencias = listaAsistencias;
    }

    public List<AsistenciaDetalleDTO> getListaTardanzas() {
        return listaTardanzas;
    }

    public void setListaTardanzas(List<AsistenciaDetalleDTO> listaTardanzas) {
        this.listaTardanzas = listaTardanzas;
    }

    public List<EmpleadoRankingDTO> getListaInasistentes() {
        return listaInasistentes;
    }

    public void setListaInasistentes(List<EmpleadoRankingDTO> listaInasistentes) {
        this.listaInasistentes = listaInasistentes;
    }

    public List<Long> getChartAsistenciaSemanal() {
        return chartAsistenciaSemanal;
    }

    public void setChartAsistenciaSemanal(List<Long> chartAsistenciaSemanal) {
        this.chartAsistenciaSemanal = chartAsistenciaSemanal;
    }

    public List<Long> getChartTardanzasSemanal() {
        return chartTardanzasSemanal;
    }

    public void setChartTardanzasSemanal(List<Long> chartTardanzasSemanal) {
        this.chartTardanzasSemanal = chartTardanzasSemanal;
    }

    public List<String> getChartLabels() {
        return chartLabels;
    }

    public void setChartLabels(List<String> chartLabels) {
        this.chartLabels = chartLabels;
    }

    public Map<String, Long> getChartDistribucionModos() {
        return chartDistribucionModos;
    }

    public void setChartDistribucionModos(Map<String, Long> chartDistribucionModos) {
        this.chartDistribucionModos = chartDistribucionModos;
    }

    public List<Long> getChartSolicitudes() {
        return chartSolicitudes;
    }

    public void setChartSolicitudes(List<Long> chartSolicitudes) {
        this.chartSolicitudes = chartSolicitudes;
    }

    public String getRangoFechaInicio() {
        return rangoFechaInicio;
    }

    public void setRangoFechaInicio(String rangoFechaInicio) {
        this.rangoFechaInicio = rangoFechaInicio;
    }

    public String getRangoFechaFin() {
        return rangoFechaFin;
    }

    public void setRangoFechaFin(String rangoFechaFin) {
        this.rangoFechaFin = rangoFechaFin;
    }

    public String getTipoRango() {
        return tipoRango;
    }

    public void setTipoRango(String tipoRango) {
        this.tipoRango = tipoRango;
    }
}
