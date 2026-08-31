package com.zonasturisticas.plataforma.beans;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "notificaciones")
public class Notificacion {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer id;

	@ManyToOne
	@JoinColumn(name = "empleado_id")
	@JsonIgnoreProperties({ "password", "permisos", "sucursal" })
	private Empleado empleado;

	private String tipo;

	@Column(length = 500)
	private String mensaje;

	private boolean leido = false;

	@Column(name = "creado_en", updatable = false)
	@CreationTimestamp
	private LocalDateTime creadoEn;

	// === NEW FIELDS ===

	// Priority: LOW, NORMAL, HIGH, URGENT
	@Column(length = 20)
	private String prioridad = "NORMAL";

	// Target role for global notifications (null = specific to empleado, "ADMIN" =
	// all admins)
	@Column(name = "target_role", length = 20)
	private String targetRole;

	// JSON metadata for additional info (e.g., sucursalId, related empleadoId)
	@Column(columnDefinition = "TEXT")
	private String metadata;

	// Custom icon (material icon name)
	@Column(length = 50)
	private String icono;

	// Action URL (for navigation on click)
	@Column(name = "action_url", length = 200)
	private String actionUrl;

	// === GETTERS & SETTERS ===

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Empleado getEmpleado() {
		return empleado;
	}

	public void setEmpleado(Empleado empleado) {
		this.empleado = empleado;
	}

	public String getTipo() {
		return tipo;
	}

	public void setTipo(String tipo) {
		this.tipo = tipo;
	}

	public String getMensaje() {
		return mensaje;
	}

	public void setMensaje(String mensaje) {
		this.mensaje = mensaje;
	}

	public boolean isLeido() {
		return leido;
	}

	public void setLeido(boolean leido) {
		this.leido = leido;
	}

	public LocalDateTime getCreadoEn() {
		return creadoEn;
	}

	public void setCreadoEn(LocalDateTime creadoEn) {
		this.creadoEn = creadoEn;
	}

	public String getPrioridad() {
		return prioridad;
	}

	public void setPrioridad(String prioridad) {
		this.prioridad = prioridad;
	}

	public String getTargetRole() {
		return targetRole;
	}

	public void setTargetRole(String targetRole) {
		this.targetRole = targetRole;
	}

	public String getMetadata() {
		return metadata;
	}

	public void setMetadata(String metadata) {
		this.metadata = metadata;
	}

	public String getIcono() {
		return icono;
	}

	public void setIcono(String icono) {
		this.icono = icono;
	}

	public String getActionUrl() {
		return actionUrl;
	}

	public void setActionUrl(String actionUrl) {
		this.actionUrl = actionUrl;
	}
}
