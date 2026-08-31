package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "asistencias")
public class Asistencia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "empleado_id", nullable = false)
    private Empleado empleado;

    @Column(nullable = false)
    private LocalDate fecha;

    @Column(name = "hora_entrada")
    private LocalTime horaEntrada;

    @Column(name = "hora_salida")
    private LocalTime horaSalida;

    @Column(name = "modo_entrada", nullable = false)
    private String modo;

    private Double latitud;
    private Double longitud;
    private String observacion;

    @Column(name = "foto_url")
    private String fotoUrl;

    @Column(name = "foto_url_salida")
    private String fotoUrlSalida;

    @Column(name = "dinero_descuento")
    private Double dineroDescuento;

    @Column(name = "dinero_bonificacion")
    private Double dineroBonificacion;

    @Column(name = "minutos_tardanza")
    private Long minutosTardanza;

    @Column(name = "minutos_extras")
    private Long minutosExtras;

    @Column(name = "sospechosa")
    private Boolean sospechosa = false;

    public Asistencia() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Empleado getEmpleado() {
        return empleado;
    }

    public void setEmpleado(Empleado empleado) {
        this.empleado = empleado;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public LocalTime getHoraEntrada() {
        return horaEntrada;
    }

    public void setHoraEntrada(LocalTime horaEntrada) {
        this.horaEntrada = horaEntrada;
    }

    public LocalTime getHoraSalida() {
        return horaSalida;
    }

    public void setHoraSalida(LocalTime horaSalida) {
        this.horaSalida = horaSalida;
    }

    public String getModo() {
        return modo;
    }

    public void setModo(String modo) {
        this.modo = modo;
    }

    public Double getLatitud() {
        return latitud;
    }

    public void setLatitud(Double latitud) {
        this.latitud = latitud;
    }

    public Double getLongitud() {
        return longitud;
    }

    public void setLongitud(Double longitud) {
        this.longitud = longitud;
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

    public Double getDineroDescuento() {
        return dineroDescuento;
    }

    public void setDineroDescuento(Double dineroDescuento) {
        this.dineroDescuento = dineroDescuento;
    }

    public Double getDineroBonificacion() {
        return dineroBonificacion;
    }

    public void setDineroBonificacion(Double dineroBonificacion) {
        this.dineroBonificacion = dineroBonificacion;
    }

    public Long getMinutosTardanza() {
        return minutosTardanza;
    }

    public void setMinutosTardanza(Long minutosTardanza) {
        this.minutosTardanza = minutosTardanza;
    }

    public Long getMinutosExtras() {
        return minutosExtras;
    }

    public void setMinutosExtras(Long minutosExtras) {
        this.minutosExtras = minutosExtras;
    }

    public Boolean getSospechosa() {
        return sospechosa;
    }

    public void setSospechosa(Boolean sospechosa) {
        this.sospechosa = sospechosa;
    }
}
