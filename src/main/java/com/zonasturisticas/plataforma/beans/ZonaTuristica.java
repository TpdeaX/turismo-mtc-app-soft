package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Zona turistica registrada y mantenida por Travel Group Peru (RF08 / CU-04).
 * Se consulta filtrada por preferencias en el RF03 / CU-02.
 */
@Entity
@Table(name = "ZonaTuristica")
public class ZonaTuristica implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ZoTuCodigo")
    private Integer codigo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "RutCodigo", nullable = false)
    private Ruta ruta;

    @Column(name = "ZoTuNombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "ZoTuDescripcion", length = 500)
    private String descripcion;

    @Column(name = "ZoTuUbicacion", length = 50)
    private String ubicacion;

    /* --- Extension: soporte visual y ciclo de vida del registro --- */
    @Column(name = "ZoTuImagen", length = 400)
    private String imagen;

    /* --- Extension: coordenadas para el mapa geografico del recorrido (RF05) --- */
    @Column(name = "ZoTuLatitud")
    private Double latitud;

    @Column(name = "ZoTuLongitud")
    private Double longitud;

    @Column(name = "ZoTuCostoReferencial", precision = 8, scale = 2)
    private java.math.BigDecimal costoReferencial;

    @Column(name = "ZoTuEstado")
    private boolean estado = true;

    @Column(name = "ZoTuRegistrado")
    private LocalDateTime registrado;

    @Column(name = "ZoTuActualizado")
    private LocalDateTime actualizado;

    /** RF03: una zona puede pertenecer a varias categorias de preferencia. */
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "ZonaCategoria",
            joinColumns = @JoinColumn(name = "ZoTuCodigo"),
            inverseJoinColumns = @JoinColumn(name = "CatCodigo"))
    private Set<Categoria> categorias = new LinkedHashSet<>();

    public ZonaTuristica() {
    }

    @PrePersist
    public void alRegistrar() {
        this.registrado = LocalDateTime.now();
        this.actualizado = this.registrado;
    }

    @PreUpdate
    public void alActualizar() {
        this.actualizado = LocalDateTime.now();
    }

    /** Etiqueta legible de categorias, usada en tablas e informes. */
    @Transient
    public String getCategoriasTexto() {
        if (categorias == null || categorias.isEmpty()) {
            return "Sin categoria";
        }
        return categorias.stream().map(Categoria::getNombre).collect(Collectors.joining(", "));
    }

    @Transient
    public Estacion getEstacion() {
        return ruta != null ? ruta.getEstacion() : null;
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public Ruta getRuta() { return ruta; }
    public void setRuta(Ruta ruta) { this.ruta = ruta; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public String getImagen() { return imagen; }
    public void setImagen(String imagen) { this.imagen = imagen; }

    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }

    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }

    public java.math.BigDecimal getCostoReferencial() { return costoReferencial; }
    public void setCostoReferencial(java.math.BigDecimal costoReferencial) { this.costoReferencial = costoReferencial; }

    public boolean isEstado() { return estado; }
    public void setEstado(boolean estado) { this.estado = estado; }

    public LocalDateTime getRegistrado() { return registrado; }
    public void setRegistrado(LocalDateTime registrado) { this.registrado = registrado; }

    public LocalDateTime getActualizado() { return actualizado; }
    public void setActualizado(LocalDateTime actualizado) { this.actualizado = actualizado; }

    public Set<Categoria> getCategorias() { return categorias; }
    public void setCategorias(Set<Categoria> categorias) { this.categorias = categorias; }
}
