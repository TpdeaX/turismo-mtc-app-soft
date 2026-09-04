package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalTime;

/**
 * Horario programado de un servicio ferroviario: salida, llegada, tiempo de
 * recorrido y tarifa (RF06 / RF10 / RF13).
 */
@Entity
@Table(name = "HorarioFerroviario")
public class HorarioFerroviario implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "HoFeCodigo")
    private Integer codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "SeFeCodigo", nullable = false)
    private ServicioFerroviario servicio;

    @Column(name = "HoFeHoraSalida", nullable = false, columnDefinition = "time(0)")
    private LocalTime horaSalida;

    @Column(name = "HoFeHoraLlegada", nullable = false, columnDefinition = "time(0)")
    private LocalTime horaLlegada;

    /**
     * El diccionario del informe declara time(7); MySQL admite como maximo
     * time(6), por lo que se usa la precision maxima disponible en el motor.
     */
    @Column(name = "HoFeTiempoRecorrido", columnDefinition = "time(6)")
    private LocalTime tiempoRecorrido;

    @Column(name = "HoFeTarifa", nullable = false, precision = 8, scale = 2)
    private BigDecimal tarifa;

    /* --- Extension: frecuencia y estado mostrados en la maqueta aprobada --- */
    @Column(name = "HoFeFrecuencia", length = 50)
    private String frecuencia = "Diario";

    @Column(name = "HoFeEstado", length = 20)
    private String estado = "ACTIVO";

    public HorarioFerroviario() {
    }

    public HorarioFerroviario(ServicioFerroviario servicio, LocalTime horaSalida, LocalTime horaLlegada,
            BigDecimal tarifa, String frecuencia) {
        this.servicio = servicio;
        this.horaSalida = horaSalida;
        this.horaLlegada = horaLlegada;
        this.tarifa = tarifa;
        this.frecuencia = frecuencia;
        recalcularTiempoRecorrido();
    }

    /** Calcula el tiempo de recorrido a partir de la salida y la llegada. */
    public void recalcularTiempoRecorrido() {
        if (horaSalida != null && horaLlegada != null) {
            Duration d = Duration.between(horaSalida, horaLlegada);
            if (d.isNegative()) {
                d = d.plusDays(1);
            }
            this.tiempoRecorrido = LocalTime.of((int) d.toHours(), d.toMinutesPart());
        }
    }

    /** Etiqueta legible del tiempo de recorrido, p. ej. "1h 22m". */
    @Transient
    public String getDuracionTexto() {
        if (tiempoRecorrido == null) {
            return "-";
        }
        int h = tiempoRecorrido.getHour();
        int m = tiempoRecorrido.getMinute();
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public ServicioFerroviario getServicio() { return servicio; }
    public void setServicio(ServicioFerroviario servicio) { this.servicio = servicio; }

    public LocalTime getHoraSalida() { return horaSalida; }
    public void setHoraSalida(LocalTime horaSalida) { this.horaSalida = horaSalida; }

    public LocalTime getHoraLlegada() { return horaLlegada; }
    public void setHoraLlegada(LocalTime horaLlegada) { this.horaLlegada = horaLlegada; }

    public LocalTime getTiempoRecorrido() { return tiempoRecorrido; }
    public void setTiempoRecorrido(LocalTime tiempoRecorrido) { this.tiempoRecorrido = tiempoRecorrido; }

    public BigDecimal getTarifa() { return tarifa; }
    public void setTarifa(BigDecimal tarifa) { this.tarifa = tarifa; }

    public String getFrecuencia() { return frecuencia; }
    public void setFrecuencia(String frecuencia) { this.frecuencia = frecuencia; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
