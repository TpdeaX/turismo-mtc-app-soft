package com.zonasturisticas.plataforma.dto;

import com.zonasturisticas.plataforma.beans.SincronizacionLog;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Datos del panel de control administrativo, equivalente a la maqueta
 * "Panel de Control Administrativo" del informe (seccion 2.5).
 */
public class PanelResumenDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private long zonasActivas;
    private long zonasTotales;
    private long estaciones;
    private long serviciosOperativos;
    private long horarios;
    private long rutas;
    private long categorias;

    private SincronizacionLog ultimaSincronizacionPeruRail;
    private SincronizacionLog ultimaSincronizacionSenamhi;
    private List<SincronizacionLog> bitacora = new ArrayList<>();
    private List<AlertaDTO> alertas = new ArrayList<>();

    /** Alerta mostrada en el bloque "Alertas del Sistema" del panel. */
    public static class AlertaDTO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String tipo;
        private String titulo;
        private String detalle;
        private String momento;
        private String icono;

        public AlertaDTO(String tipo, String titulo, String detalle, String momento, String icono) {
            this.tipo = tipo;
            this.titulo = titulo;
            this.detalle = detalle;
            this.momento = momento;
            this.icono = icono;
        }

        public String getTipo() { return tipo; }
        public String getTitulo() { return titulo; }
        public String getDetalle() { return detalle; }
        public String getMomento() { return momento; }
        public String getIcono() { return icono; }
    }

    public long getZonasActivas() { return zonasActivas; }
    public void setZonasActivas(long zonasActivas) { this.zonasActivas = zonasActivas; }

    public long getZonasTotales() { return zonasTotales; }
    public void setZonasTotales(long zonasTotales) { this.zonasTotales = zonasTotales; }

    public long getEstaciones() { return estaciones; }
    public void setEstaciones(long estaciones) { this.estaciones = estaciones; }

    public long getServiciosOperativos() { return serviciosOperativos; }
    public void setServiciosOperativos(long serviciosOperativos) { this.serviciosOperativos = serviciosOperativos; }

    public long getHorarios() { return horarios; }
    public void setHorarios(long horarios) { this.horarios = horarios; }

    public long getRutas() { return rutas; }
    public void setRutas(long rutas) { this.rutas = rutas; }

    public long getCategorias() { return categorias; }
    public void setCategorias(long categorias) { this.categorias = categorias; }

    public SincronizacionLog getUltimaSincronizacionPeruRail() { return ultimaSincronizacionPeruRail; }
    public void setUltimaSincronizacionPeruRail(SincronizacionLog v) { this.ultimaSincronizacionPeruRail = v; }

    public SincronizacionLog getUltimaSincronizacionSenamhi() { return ultimaSincronizacionSenamhi; }
    public void setUltimaSincronizacionSenamhi(SincronizacionLog v) { this.ultimaSincronizacionSenamhi = v; }

    public List<SincronizacionLog> getBitacora() { return bitacora; }
    public void setBitacora(List<SincronizacionLog> bitacora) { this.bitacora = bitacora; }

    public List<AlertaDTO> getAlertas() { return alertas; }
    public void setAlertas(List<AlertaDTO> alertas) { this.alertas = alertas; }
}
