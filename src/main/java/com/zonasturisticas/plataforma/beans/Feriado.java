package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "feriados")
public class Feriado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private LocalDate fecha;

    @Column(length = 255)
    private String descripcion;

    public Feriado() {
    }

    public Feriado(int id, LocalDate fecha, String descripcion) {
        this.id = id;
        this.fecha = fecha;
        this.descripcion = descripcion;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "feriados_empresas", joinColumns = @JoinColumn(name = "feriado_id"), inverseJoinColumns = @JoinColumn(name = "empresa_id"))
    private java.util.List<Empresa> empresas;

    public java.util.List<Empresa> getEmpresas() {
        return empresas;
    }

    public void setEmpresas(java.util.List<Empresa> empresas) {
        this.empresas = empresas;
    }
}
