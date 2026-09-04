package com.zonasturisticas.plataforma.dto;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * RF07 / CU-03 paso 5: informe consolidado dirigido al usuario final y a
 * Travel Group Peru. Integra en un unico objeto los datos turisticos,
 * climaticos (SENAMHI) y ferroviarios (PeruRail) de la consulta realizada.
 */
public class InformeConsolidadoDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String folio;
    private LocalDateTime generado;

    /* --- Bloque turistico (Travel Group Peru) --- */
    private ZonaTuristica zona;
    private Estacion estacion;
    private RutaRecomendadaDTO rutaRecomendada;

    /* --- Bloque climatico (SENAMHI) --- */
    private PronosticoClima climaActual;
    private List<PronosticoClima> pronostico = new ArrayList<>();
    private boolean climaDisponible = true;
    private String climaMensaje;
    private LocalDateTime climaActualizado;

    /* --- Bloque ferroviario (PeruRail) --- */
    private List<HorarioFerroviario> horarios = new ArrayList<>();
    private boolean ferroviarioDisponible = true;
    private LocalDateTime ferroviarioActualizado;
    private java.math.BigDecimal tarifaMinima;
    private java.math.BigDecimal tarifaMaxima;

    /* --- Preferencias aplicadas en la consulta --- */
    private String preferenciasTexto;

    public boolean isTieneHorarios() {
        return horarios != null && !horarios.isEmpty();
    }

    public String getFolio() { return folio; }
    public void setFolio(String folio) { this.folio = folio; }

    public LocalDateTime getGenerado() { return generado; }
    public void setGenerado(LocalDateTime generado) { this.generado = generado; }

    public ZonaTuristica getZona() { return zona; }
    public void setZona(ZonaTuristica zona) { this.zona = zona; }

    public Estacion getEstacion() { return estacion; }
    public void setEstacion(Estacion estacion) { this.estacion = estacion; }

    public RutaRecomendadaDTO getRutaRecomendada() { return rutaRecomendada; }
    public void setRutaRecomendada(RutaRecomendadaDTO rutaRecomendada) { this.rutaRecomendada = rutaRecomendada; }

    public PronosticoClima getClimaActual() { return climaActual; }
    public void setClimaActual(PronosticoClima climaActual) { this.climaActual = climaActual; }

    public List<PronosticoClima> getPronostico() { return pronostico; }
    public void setPronostico(List<PronosticoClima> pronostico) { this.pronostico = pronostico; }

    public boolean isClimaDisponible() { return climaDisponible; }
    public void setClimaDisponible(boolean climaDisponible) { this.climaDisponible = climaDisponible; }

    public String getClimaMensaje() { return climaMensaje; }
    public void setClimaMensaje(String climaMensaje) { this.climaMensaje = climaMensaje; }

    public LocalDateTime getClimaActualizado() { return climaActualizado; }
    public void setClimaActualizado(LocalDateTime climaActualizado) { this.climaActualizado = climaActualizado; }

    public List<HorarioFerroviario> getHorarios() { return horarios; }
    public void setHorarios(List<HorarioFerroviario> horarios) { this.horarios = horarios; }

    public boolean isFerroviarioDisponible() { return ferroviarioDisponible; }
    public void setFerroviarioDisponible(boolean ferroviarioDisponible) { this.ferroviarioDisponible = ferroviarioDisponible; }

    public LocalDateTime getFerroviarioActualizado() { return ferroviarioActualizado; }
    public void setFerroviarioActualizado(LocalDateTime ferroviarioActualizado) { this.ferroviarioActualizado = ferroviarioActualizado; }

    public java.math.BigDecimal getTarifaMinima() { return tarifaMinima; }
    public void setTarifaMinima(java.math.BigDecimal tarifaMinima) { this.tarifaMinima = tarifaMinima; }

    public java.math.BigDecimal getTarifaMaxima() { return tarifaMaxima; }
    public void setTarifaMaxima(java.math.BigDecimal tarifaMaxima) { this.tarifaMaxima = tarifaMaxima; }

    public String getPreferenciasTexto() { return preferenciasTexto; }
    public void setPreferenciasTexto(String preferenciasTexto) { this.preferenciasTexto = preferenciasTexto; }
}
