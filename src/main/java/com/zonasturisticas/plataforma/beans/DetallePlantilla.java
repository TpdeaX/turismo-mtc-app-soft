package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "detalle_plantilla")
public class DetallePlantilla {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "id_plantilla", nullable = false)
    private PlantillaHorario plantilla;

    @Column(name = "dia_semana", nullable = false)
    private int diaSemana; // 1 = Monday, 7 = Sunday (ISO)

    @Column(name = "hora_inicio")
    private LocalTime horaInicio;

    @Column(name = "hora_fin")
    private LocalTime horaFin;

    @Column(name = "tipo_turno")
    private String tipoTurno;

    @Column(name = "es_descanso")
    private boolean esDescanso;

    // Getters and Setters

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public PlantillaHorario getPlantilla() {
        return plantilla;
    }

    public void setPlantilla(PlantillaHorario plantilla) {
        this.plantilla = plantilla;
    }

    public int getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(int diaSemana) {
        this.diaSemana = diaSemana;
    }

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public LocalTime getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(LocalTime horaFin) {
        this.horaFin = horaFin;
    }

    public String getTipoTurno() {
        return tipoTurno;
    }

    public void setTipoTurno(String tipoTurno) {
        this.tipoTurno = tipoTurno;
    }

    public boolean isEsDescanso() {
        return esDescanso;
    }

    public void setEsDescanso(boolean esDescanso) {
        this.esDescanso = esDescanso;
    }
}
