package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Pronostico climatologico por zona geografica provisto por SENAMHI
 * (RF04 / RF11 / CU-07).
 *
 * Este almacenamiento es el mecanismo de cache exigido por el analisis de
 * riesgos del informe: si la fuente no responde, el sistema conserva el ultimo
 * pronostico valido e informa la fecha de la ultima actualizacion exitosa.
 */
@Entity
@Table(name = "PronosticoClima",
        uniqueConstraints = @UniqueConstraint(columnNames = { "EstCodigo", "PrClFecha" }))
public class PronosticoClima implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PrClCodigo")
    private Integer codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "EstCodigo", nullable = false)
    private Estacion estacion;

    @Column(name = "PrClFecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "PrClTemperatura")
    private Integer temperatura;

    @Column(name = "PrClTempMin")
    private Integer temperaturaMin;

    @Column(name = "PrClTempMax")
    private Integer temperaturaMax;

    @Column(name = "PrClCondicion", length = 60)
    private String condicion;

    @Column(name = "PrClHumedad")
    private Integer humedad;

    @Column(name = "PrClViento")
    private Integer viento;

    @Column(name = "PrClVientoDir", length = 5)
    private String vientoDireccion;

    @Column(name = "PrClProbLluvia")
    private Integer probabilidadLluvia;

    @Column(name = "PrClIcono", length = 40)
    private String icono;

    @Column(name = "PrClActualizado")
    private LocalDateTime actualizado;

    public PronosticoClima() {
    }

    /** RN04 / RF05: senala si el clima es apto para un recorrido a pie. */
    @Transient
    public boolean isAptoParaCaminar() {
        boolean lluviaOk = probabilidadLluvia == null || probabilidadLluvia < 60;
        boolean tempOk = temperatura == null || (temperatura >= 5 && temperatura <= 30);
        return lluviaOk && tempOk;
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public Estacion getEstacion() { return estacion; }
    public void setEstacion(Estacion estacion) { this.estacion = estacion; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public Integer getTemperatura() { return temperatura; }
    public void setTemperatura(Integer temperatura) { this.temperatura = temperatura; }

    public Integer getTemperaturaMin() { return temperaturaMin; }
    public void setTemperaturaMin(Integer temperaturaMin) { this.temperaturaMin = temperaturaMin; }

    public Integer getTemperaturaMax() { return temperaturaMax; }
    public void setTemperaturaMax(Integer temperaturaMax) { this.temperaturaMax = temperaturaMax; }

    public String getCondicion() { return condicion; }
    public void setCondicion(String condicion) { this.condicion = condicion; }

    public Integer getHumedad() { return humedad; }
    public void setHumedad(Integer humedad) { this.humedad = humedad; }

    public Integer getViento() { return viento; }
    public void setViento(Integer viento) { this.viento = viento; }

    public String getVientoDireccion() { return vientoDireccion; }
    public void setVientoDireccion(String vientoDireccion) { this.vientoDireccion = vientoDireccion; }

    public Integer getProbabilidadLluvia() { return probabilidadLluvia; }
    public void setProbabilidadLluvia(Integer probabilidadLluvia) { this.probabilidadLluvia = probabilidadLluvia; }

    public String getIcono() { return icono; }
    public void setIcono(String icono) { this.icono = icono; }

    public LocalDateTime getActualizado() { return actualizado; }
    public void setActualizado(LocalDateTime actualizado) { this.actualizado = actualizado; }
}
