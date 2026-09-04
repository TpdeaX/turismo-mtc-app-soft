package com.zonasturisticas.plataforma.dto;

import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Tarjeta de resultado del CU-02: zona turistica ya combinada con su clima
 * (SENAMHI), su proxima salida de tren (PeruRail) y su tarifa referencial,
 * tal como lo muestra la maqueta aprobada del informe (seccion 2.5).
 */
public class ZonaResultadoDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private ZonaTuristica zona;
    private PronosticoClima clima;
    private HorarioFerroviario proximaSalida;
    private BigDecimal tarifaDesde;
    private RutaRecomendadaDTO ruta;
    /** Puntaje de coincidencia con las preferencias del turista (RF03). */
    private int coincidencias;

    public ZonaResultadoDTO(ZonaTuristica zona) {
        this.zona = zona;
    }

    public ZonaTuristica getZona() { return zona; }
    public void setZona(ZonaTuristica zona) { this.zona = zona; }

    public PronosticoClima getClima() { return clima; }
    public void setClima(PronosticoClima clima) { this.clima = clima; }

    public HorarioFerroviario getProximaSalida() { return proximaSalida; }
    public void setProximaSalida(HorarioFerroviario proximaSalida) { this.proximaSalida = proximaSalida; }

    public BigDecimal getTarifaDesde() { return tarifaDesde; }
    public void setTarifaDesde(BigDecimal tarifaDesde) { this.tarifaDesde = tarifaDesde; }

    public RutaRecomendadaDTO getRuta() { return ruta; }
    public void setRuta(RutaRecomendadaDTO ruta) { this.ruta = ruta; }

    public int getCoincidencias() { return coincidencias; }
    public void setCoincidencias(int coincidencias) { this.coincidencias = coincidencias; }
}
