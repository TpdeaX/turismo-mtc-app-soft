package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable; // <--- 1. IMPORTANTE: Importar esto

@Entity
@Table(name = "permiso")
public class Permiso implements Serializable { // <--- 2. IMPORTANTE: Implementar la interfaz

    // 3. Recomendado: Agregar el ID de versión para evitar warnings
    private static final long serialVersionUID = 1L; 

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nombre;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
}
