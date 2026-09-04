package com.zonasturisticas.plataforma.dto;

import java.io.Serializable;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * RF01 / CU-01: preferencias turisticas del usuario final.
 *
 * Segun la postcondicion del CU-01 las preferencias se almacenan "para la
 * sesion de consulta actual", por lo que este objeto vive en la HttpSession y
 * no se persiste en base de datos.
 */
public class PreferenciasSesion implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Codigos de Categoria seleccionados por el turista. */
    private Set<Integer> categorias = new LinkedHashSet<>();

    /** Estacion de partida elegida en el RF02 / CU-02. */
    private Integer estacionCodigo;

    /** Dificultad maxima aceptada por el turista: FACIL | MODERADA | ALTA. */
    private String dificultadMaxima;

    /** Presupuesto referencial en soles para el pasaje de tren. */
    private Integer presupuesto;

    public boolean isVacio() {
        return categorias == null || categorias.isEmpty();
    }

    public boolean tieneCategoria(Integer codigo) {
        return categorias != null && categorias.contains(codigo);
    }

    public int getTotalSeleccionadas() {
        return categorias == null ? 0 : categorias.size();
    }

    public Set<Integer> getCategorias() { return categorias; }
    public void setCategorias(Set<Integer> categorias) { this.categorias = categorias; }

    public Integer getEstacionCodigo() { return estacionCodigo; }
    public void setEstacionCodigo(Integer estacionCodigo) { this.estacionCodigo = estacionCodigo; }

    public String getDificultadMaxima() { return dificultadMaxima; }
    public void setDificultadMaxima(String dificultadMaxima) { this.dificultadMaxima = dificultadMaxima; }

    public Integer getPresupuesto() { return presupuesto; }
    public void setPresupuesto(Integer presupuesto) { this.presupuesto = presupuesto; }
}
