package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "detalle_plantilla_dia")
public class DetallePlantillaDia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "id_plantilla_dia", nullable = false)
    private PlantillaDia plantillaDia;

    @Column(name = "empleado_id", nullable = false)
    private int empleadoId;

    @Column(name = "hora_inicio")
    private LocalTime horaInicio;

    @Column(name = "hora_fin")
    private LocalTime horaFin;

    @Column(name = "tipo_turno", length = 50)
    private String tipoTurno;

    // Getters and Setters

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public PlantillaDia getPlantillaDia() {
        return plantillaDia;
    }

    public void setPlantillaDia(PlantillaDia plantillaDia) {
        this.plantillaDia = plantillaDia;
    }

    public int getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(int empleadoId) {
        this.empleadoId = empleadoId;
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
}
