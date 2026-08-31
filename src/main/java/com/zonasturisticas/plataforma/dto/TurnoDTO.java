package com.zonasturisticas.plataforma.dto;

import com.zonasturisticas.plataforma.beans.Asistencia;
import com.zonasturisticas.plataforma.beans.Horario;

public class TurnoDTO {
    private Horario horario;
    private Asistencia asistencia;
    private String estado; // PENDIENTE, ASISTIDO, FALTA, EN_CURSO
    private String mensajeEstado; // "Llegada Tardía", "Puntual", "Ingreso Temprano", etc.
    private String claseCss; // Para colorear en el front

    public TurnoDTO(Horario horario, Asistencia asistencia, String estado, String mensajeEstado, String claseCss) {
        this.horario = horario;
        this.asistencia = asistencia;
        this.estado = estado;
        this.mensajeEstado = mensajeEstado;
        this.claseCss = claseCss;
    }

    public Horario getHorario() {
        return horario;
    }

    public void setHorario(Horario horario) {
        this.horario = horario;
    }

    public Asistencia getAsistencia() {
        return asistencia;
    }

    public void setAsistencia(Asistencia asistencia) {
        this.asistencia = asistencia;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getMensajeEstado() {
        return mensajeEstado;
    }

    public void setMensajeEstado(String mensajeEstado) {
        this.mensajeEstado = mensajeEstado;
    }

    public String getClaseCss() {
        return claseCss;
    }

    public void setClaseCss(String claseCss) {
        this.claseCss = claseCss;
    }
}
