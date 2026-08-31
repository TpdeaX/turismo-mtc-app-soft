package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "configuraciones")
public class Configuracion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String clave;

    private String valor;

    private String descripcion;

    // STRING, BOOLEAN, NUMBER
    private String tipo;

    // Relación con Empresa (nullable = configuración global)
    @ManyToOne
    @JoinColumn(name = "empresa_id")
    private Empresa empresa;

    public Configuracion() {
    }

    public Configuracion(String clave, String valor, String descripcion, String tipo) {
        this.clave = clave;
        this.valor = valor;
        this.descripcion = descripcion;
        this.tipo = tipo;
    }

    public Configuracion(String clave, String valor, String descripcion, String tipo, Empresa empresa) {
        this.clave = clave;
        this.valor = valor;
        this.descripcion = descripcion;
        this.tipo = tipo;
        this.empresa = empresa;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getClave() {
        return clave;
    }

    public void setClave(String clave) {
        this.clave = clave;
    }

    public String getValor() {
        return valor;
    }

    public void setValor(String valor) {
        this.valor = valor;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public Empresa getEmpresa() {
        return empresa;
    }

    public void setEmpresa(Empresa empresa) {
        this.empresa = empresa;
    }
}
