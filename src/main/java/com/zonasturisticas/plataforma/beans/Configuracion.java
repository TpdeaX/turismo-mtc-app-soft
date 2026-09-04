package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Parametro general de la plataforma (RF12 / panel de configuracion).
 * Tabla de extension no contemplada en el diccionario original.
 */
@Entity
@Table(name = "Configuracion")
public class Configuracion implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "ConfClave", length = 60)
    private String clave;

    @Column(name = "ConfValor", length = 255)
    private String valor;

    @Column(name = "ConfDescripcion", length = 255)
    private String descripcion;

    /** TEXTO | NUMERO | BOOLEANO */
    @Column(name = "ConfTipo", length = 20)
    private String tipo = "TEXTO";

    @Column(name = "ConfGrupo", length = 40)
    private String grupo = "GENERAL";

    @Column(name = "ConfActualizado")
    private LocalDateTime actualizado;

    public Configuracion() {
    }

    public Configuracion(String clave, String valor, String descripcion, String tipo, String grupo) {
        this.clave = clave;
        this.valor = valor;
        this.descripcion = descripcion;
        this.tipo = tipo;
        this.grupo = grupo;
        this.actualizado = LocalDateTime.now();
    }

    @Transient
    public boolean isBooleano() {
        return "BOOLEANO".equals(tipo);
    }

    @Transient
    public boolean isActivo() {
        return "true".equalsIgnoreCase(valor) || "1".equals(valor);
    }

    public String getClave() { return clave; }
    public void setClave(String clave) { this.clave = clave; }

    public String getValor() { return valor; }
    public void setValor(String valor) { this.valor = valor; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }

    public LocalDateTime getActualizado() { return actualizado; }
    public void setActualizado(LocalDateTime actualizado) { this.actualizado = actualizado; }
}
