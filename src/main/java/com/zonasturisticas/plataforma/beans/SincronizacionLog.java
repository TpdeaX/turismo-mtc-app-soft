package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Bitacora de las sincronizaciones periodicas con las fuentes externas
 * (RF10 / RF11 / RNF02 / RNF05).
 *
 * Sustenta el flujo alternativo "Fallo en la sincronizacion" de los CU-06 y
 * CU-07: el incidente queda registrado para su revision y la plataforma puede
 * informar la fecha de la ultima actualizacion exitosa.
 */
@Entity
@Table(name = "SincronizacionLog")
public class SincronizacionLog implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String FUENTE_PERURAIL = "PERURAIL";
    public static final String FUENTE_SENAMHI = "SENAMHI";

    public static final String ESTADO_EXITO = "EXITO";
    public static final String ESTADO_FALLO = "FALLO";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SinCodigo")
    private Integer codigo;

    @Column(name = "SinFuente", nullable = false, length = 20)
    private String fuente;

    @Column(name = "SinFecha", nullable = false)
    private LocalDateTime fecha;

    @Column(name = "SinEstado", nullable = false, length = 20)
    private String estado;

    @Column(name = "SinRegistros")
    private Integer registros;

    @Column(name = "SinDuracionMs")
    private Long duracionMs;

    @Column(name = "SinMensaje", length = 300)
    private String mensaje;

    public SincronizacionLog() {
    }

    public SincronizacionLog(String fuente, String estado, Integer registros, Long duracionMs, String mensaje) {
        this.fuente = fuente;
        this.estado = estado;
        this.registros = registros;
        this.duracionMs = duracionMs;
        this.mensaje = mensaje;
        this.fecha = LocalDateTime.now();
    }

    @Transient
    public boolean isExitosa() {
        return ESTADO_EXITO.equals(estado);
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public String getFuente() { return fuente; }
    public void setFuente(String fuente) { this.fuente = fuente; }

    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Integer getRegistros() { return registros; }
    public void setRegistros(Integer registros) { this.registros = registros; }

    public Long getDuracionMs() { return duracionMs; }
    public void setDuracionMs(Long duracionMs) { this.duracionMs = duracionMs; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }
}
