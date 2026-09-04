package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Estacion ferroviaria. Fuente de datos: PeruRail (RF10 / CU-06).
 *
 * Las columnas EstCodigo, EstNombre y EstUbicacion corresponden literalmente al
 * diccionario de datos del informe (seccion 2.4). Los campos de coordenadas y
 * region son la extension minima requerida para resolver el pronostico "por zona
 * geografica" que exige el RF04/RF11 y para dibujar la ruta caminable del RF05.
 */
@Entity
@Table(name = "Estacion")
public class Estacion implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "EstCodigo")
    private Integer codigo;

    @Column(name = "EstNombre", nullable = false, length = 50)
    private String nombre;

    @Column(name = "EstUbicacion", nullable = false, length = 50)
    private String ubicacion;

    /* --- Extension: zona geografica para SENAMHI (RF11) y mapa (RF05) --- */
    @Column(name = "EstRegion", length = 50)
    private String region;

    @Column(name = "EstLatitud")
    private Double latitud;

    @Column(name = "EstLongitud")
    private Double longitud;

    /* --- Extension: trazabilidad de la sincronizacion con PeruRail --- */
    @Column(name = "EstConexiones", length = 150)
    private String conexiones;

    @Column(name = "EstActualizado")
    private LocalDateTime actualizado;

    @OneToMany(mappedBy = "estacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Ruta> rutas = new ArrayList<>();

    public Estacion() {
    }

    public Estacion(String nombre, String ubicacion, String region, Double latitud, Double longitud,
            String conexiones) {
        this.nombre = nombre;
        this.ubicacion = ubicacion;
        this.region = region;
        this.latitud = latitud;
        this.longitud = longitud;
        this.conexiones = conexiones;
        this.actualizado = LocalDateTime.now();
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }

    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }

    public String getConexiones() { return conexiones; }
    public void setConexiones(String conexiones) { this.conexiones = conexiones; }

    public LocalDateTime getActualizado() { return actualizado; }
    public void setActualizado(LocalDateTime actualizado) { this.actualizado = actualizado; }

    public List<Ruta> getRutas() { return rutas; }
    public void setRutas(List<Ruta> rutas) { this.rutas = rutas; }
}
