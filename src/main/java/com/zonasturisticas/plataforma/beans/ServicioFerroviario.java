package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Servicio ferroviario entre dos estaciones. Datos provistos por PeruRail
 * (RF06 / RF10) y mantenidos por el gestor autorizado de PeruRail (RF13).
 */
@Entity
@Table(name = "ServicioFerroviario")
public class ServicioFerroviario implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SeFeCodigo")
    private Integer codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "EstCodigoOrigen", nullable = false)
    private Estacion origen;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "EstCodigoDestino", nullable = false)
    private Estacion destino;

    @Column(name = "SeFeNombre", nullable = false, length = 50)
    private String nombre;

    /* --- Extension: estado operativo mostrado en la interfaz --- */
    @Column(name = "SeFeEstado", length = 20)
    private String estado = "ACTIVO";

    @Column(name = "SeFeCorredor", length = 50)
    private String corredor;

    @OneToMany(mappedBy = "servicio", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<HorarioFerroviario> horarios = new ArrayList<>();

    public ServicioFerroviario() {
    }

    public ServicioFerroviario(Estacion origen, Estacion destino, String nombre, String corredor) {
        this.origen = origen;
        this.destino = destino;
        this.nombre = nombre;
        this.corredor = corredor;
    }

    @Transient
    public String getTrayecto() {
        String o = origen != null ? origen.getNombre() : "?";
        String d = destino != null ? destino.getNombre() : "?";
        return o + " \u2192 " + d;
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public Estacion getOrigen() { return origen; }
    public void setOrigen(Estacion origen) { this.origen = origen; }

    public Estacion getDestino() { return destino; }
    public void setDestino(Estacion destino) { this.destino = destino; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getCorredor() { return corredor; }
    public void setCorredor(String corredor) { this.corredor = corredor; }

    public List<HorarioFerroviario> getHorarios() { return horarios; }
    public void setHorarios(List<HorarioFerroviario> horarios) { this.horarios = horarios; }
}
