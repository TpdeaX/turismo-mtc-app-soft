package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Ruta turistica caminable asociada a una estacion (RF05).
 *
 * RN01: toda ruta es de un unico tramo de ida y vuelta desde la misma estacion.
 * RN04: el recorrido es exclusivamente peatonal.
 */
@Entity
@Table(name = "Ruta")
public class Ruta implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RutaCodigo")
    private Integer codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "EstCodigo", nullable = false)
    private Estacion estacion;

    @Column(name = "RutaDistanciaKm", nullable = false, precision = 8, scale = 2)
    private BigDecimal distanciaKm;

    @Column(name = "RutaTiempoEstimado", length = 50)
    private String tiempoEstimado;

    @Column(name = "RutaDificultad", length = 50)
    private String dificultad;

    /* --- Extension: nombre visible de la ruta y trazo para el mapa (RF05) --- */
    @Column(name = "RutaNombre", length = 100)
    private String nombre;

    @Lob
    @Column(name = "RutaTrazado")
    private String trazado;

    @OneToMany(mappedBy = "ruta", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ZonaTuristica> zonas = new ArrayList<>();

    public Ruta() {
    }

    public Ruta(Estacion estacion, String nombre, BigDecimal distanciaKm, String tiempoEstimado, String dificultad) {
        this.estacion = estacion;
        this.nombre = nombre;
        this.distanciaKm = distanciaKm;
        this.tiempoEstimado = tiempoEstimado;
        this.dificultad = dificultad;
    }

    /** RN01: la distancia total recorrida es ida + vuelta sobre el mismo tramo. */
    @Transient
    public BigDecimal getDistanciaIdaVueltaKm() {
        return distanciaKm == null ? BigDecimal.ZERO : distanciaKm.multiply(BigDecimal.valueOf(2));
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public Estacion getEstacion() { return estacion; }
    public void setEstacion(Estacion estacion) { this.estacion = estacion; }

    public BigDecimal getDistanciaKm() { return distanciaKm; }
    public void setDistanciaKm(BigDecimal distanciaKm) { this.distanciaKm = distanciaKm; }

    public String getTiempoEstimado() { return tiempoEstimado; }
    public void setTiempoEstimado(String tiempoEstimado) { this.tiempoEstimado = tiempoEstimado; }

    public String getDificultad() { return dificultad; }
    public void setDificultad(String dificultad) { this.dificultad = dificultad; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getTrazado() { return trazado; }
    public void setTrazado(String trazado) { this.trazado = trazado; }

    public List<ZonaTuristica> getZonas() { return zonas; }
    public void setZonas(List<ZonaTuristica> zonas) { this.zonas = zonas; }
}
