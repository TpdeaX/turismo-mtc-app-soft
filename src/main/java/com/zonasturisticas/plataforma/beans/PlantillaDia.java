package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "plantilla_dia")
public class PlantillaDia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(name = "fecha_origen")
    private LocalDate fechaOrigen;

    @Column(name = "fecha_creacion")
    private LocalDate fechaCreacion;

    @OneToMany(mappedBy = "plantillaDia", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<DetallePlantillaDia> detalles = new ArrayList<>();

    // Getters and Setters

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public LocalDate getFechaOrigen() {
        return fechaOrigen;
    }

    public void setFechaOrigen(LocalDate fechaOrigen) {
        this.fechaOrigen = fechaOrigen;
    }

    public LocalDate getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDate fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public List<DetallePlantillaDia> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetallePlantillaDia> detalles) {
        this.detalles = detalles;
        for (DetallePlantillaDia detalle : detalles) {
            detalle.setPlantillaDia(this);
        }
    }

    public void addDetalle(DetallePlantillaDia detalle) {
        detalles.add(detalle);
        detalle.setPlantillaDia(this);
    }
}
