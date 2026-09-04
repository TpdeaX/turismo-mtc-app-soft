package com.zonasturisticas.plataforma.dto;

import com.zonasturisticas.plataforma.beans.Ruta;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * RF05 / CU-03 paso 3: ruta caminable recomendada, de ida y vuelta, con su
 * tiempo estimado y dificultad ya calculados por el motor de recomendacion.
 *
 * RN01: un unico tramo, partiendo y retornando a la misma estacion.
 * RN04: recorrido exclusivamente peatonal.
 */
public class RutaRecomendadaDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Ruta ruta;
    private BigDecimal distanciaIdaKm;
    private BigDecimal distanciaTotalKm;
    private int minutosIda;
    private int minutosTotal;
    private String tiempoTotalTexto;
    private String dificultad;
    private int nivelDificultad;
    private String recomendacion;
    private boolean aptaSegunClima = true;

    public Ruta getRuta() { return ruta; }
    public void setRuta(Ruta ruta) { this.ruta = ruta; }

    public BigDecimal getDistanciaIdaKm() { return distanciaIdaKm; }
    public void setDistanciaIdaKm(BigDecimal distanciaIdaKm) { this.distanciaIdaKm = distanciaIdaKm; }

    public BigDecimal getDistanciaTotalKm() { return distanciaTotalKm; }
    public void setDistanciaTotalKm(BigDecimal distanciaTotalKm) { this.distanciaTotalKm = distanciaTotalKm; }

    public int getMinutosIda() { return minutosIda; }
    public void setMinutosIda(int minutosIda) { this.minutosIda = minutosIda; }

    public int getMinutosTotal() { return minutosTotal; }
    public void setMinutosTotal(int minutosTotal) { this.minutosTotal = minutosTotal; }

    public String getTiempoTotalTexto() { return tiempoTotalTexto; }
    public void setTiempoTotalTexto(String tiempoTotalTexto) { this.tiempoTotalTexto = tiempoTotalTexto; }

    public String getDificultad() { return dificultad; }
    public void setDificultad(String dificultad) { this.dificultad = dificultad; }

    public int getNivelDificultad() { return nivelDificultad; }
    public void setNivelDificultad(int nivelDificultad) { this.nivelDificultad = nivelDificultad; }

    public String getRecomendacion() { return recomendacion; }
    public void setRecomendacion(String recomendacion) { this.recomendacion = recomendacion; }

    public boolean isAptaSegunClima() { return aptaSegunClima; }
    public void setAptaSegunClima(boolean aptaSegunClima) { this.aptaSegunClima = aptaSegunClima; }
}
