package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;

@Entity
@Table(name = "plantillas_horario")
public class PlantillaHorario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @OneToMany(mappedBy = "plantilla", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private java.util.List<DetallePlantilla> detalles = new java.util.ArrayList<>();

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

    public java.util.List<DetallePlantilla> getDetalles() {
        return detalles;
    }

    public void setDetalles(java.util.List<DetallePlantilla> detalles) {
        this.detalles = detalles;
        for (DetallePlantilla detalle : detalles) {
            detalle.setPlantilla(this);
        }
    }
}
