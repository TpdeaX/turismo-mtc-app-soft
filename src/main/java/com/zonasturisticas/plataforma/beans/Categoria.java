package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;

/**
 * Categoria de preferencia turistica: naturaleza, historia, aventura, cultura...
 * Sustenta el RF01 (ingreso de preferencias) y el filtrado del RF03.
 * Tabla de extension no contemplada en el diccionario original.
 */
@Entity
@Table(name = "Categoria")
public class Categoria implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CatCodigo")
    private Integer codigo;

    @Column(name = "CatNombre", nullable = false, length = 50, unique = true)
    private String nombre;

    @Column(name = "CatDescripcion", length = 200)
    private String descripcion;

    /** Nombre del icono de Material Symbols usado en la interfaz. */
    @Column(name = "CatIcono", length = 50)
    private String icono;

    @Column(name = "CatColor", length = 20)
    private String color;

    @Column(name = "CatEstado")
    private boolean estado = true;

    public Categoria() {
    }

    public Categoria(String nombre, String descripcion, String icono, String color) {
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.icono = icono;
        this.color = color;
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getIcono() { return icono; }
    public void setIcono(String icono) { this.icono = icono; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public boolean isEstado() { return estado; }
    public void setEstado(boolean estado) { this.estado = estado; }
}
