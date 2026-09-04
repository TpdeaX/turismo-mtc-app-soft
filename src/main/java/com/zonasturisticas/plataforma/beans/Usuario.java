package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Usuario gestor del panel administrativo (RNF06).
 *
 * El turista NO se autentica: segun la precondicion del CU-01 solo requiere
 * ingresar a la plataforma. Esta tabla representa unicamente a los gestores
 * autorizados de Travel Group Peru (RF08), PeruRail (RF13) y al administrador
 * de la plataforma (RF12).
 */
@Entity
@Table(name = "Usuario")
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String ROL_ADMIN = "ADMIN";
    public static final String ROL_TRAVEL_GROUP = "TRAVEL_GROUP";
    public static final String ROL_PERURAIL = "PERURAIL";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "UsuCodigo")
    private Integer codigo;

    @Column(name = "UsuCorreo", nullable = false, length = 100, unique = true)
    private String correo;

    @Column(name = "UsuPassword", nullable = false, length = 100)
    private String password;

    /* --- Extension: separacion de responsabilidades exigida por la RN02 --- */
    @Column(name = "UsuNombre", length = 100)
    private String nombre;

    @Column(name = "UsuRol", nullable = false, length = 20)
    private String rol = ROL_TRAVEL_GROUP;

    @Column(name = "UsuEstado")
    private boolean estado = true;

    @Column(name = "UsuUltimoAcceso")
    private LocalDateTime ultimoAcceso;

    public Usuario() {
    }

    public Usuario(String correo, String password, String nombre, String rol) {
        this.correo = correo;
        this.password = password;
        this.nombre = nombre;
        this.rol = rol;
    }

    @Transient
    public boolean isAdmin() {
        return ROL_ADMIN.equals(rol);
    }

    /** RF08 / CU-04: solo Travel Group Peru (y el admin) mantiene zonas. */
    @Transient
    public boolean isPuedeGestionarZonas() {
        return isAdmin() || ROL_TRAVEL_GROUP.equals(rol);
    }

    /** RF13: solo PeruRail (y el admin) mantiene servicios, horarios y tarifas. */
    @Transient
    public boolean isPuedeGestionarFerroviario() {
        return isAdmin() || ROL_PERURAIL.equals(rol);
    }

    /** RF12: el panel de parametros generales queda reservado al administrador. */
    @Transient
    public boolean isPuedeConfigurarPlataforma() {
        return isAdmin();
    }

    @Transient
    public String getRolTexto() {
        if (ROL_ADMIN.equals(rol)) {
            return "Administrador MTC";
        }
        if (ROL_TRAVEL_GROUP.equals(rol)) {
            return "Travel Group Perú";
        }
        if (ROL_PERURAIL.equals(rol)) {
            return "PeruRail";
        }
        return rol;
    }

    @Transient
    public String getIniciales() {
        if (nombre == null || nombre.isBlank()) {
            return (correo != null && !correo.isBlank()) ? correo.substring(0, 1).toUpperCase() : "?";
        }
        String[] partes = nombre.trim().split("\\s+");
        String ini = partes[0].substring(0, 1);
        if (partes.length > 1) {
            ini = ini + partes[1].substring(0, 1);
        }
        return ini.toUpperCase();
    }

    public Integer getCodigo() { return codigo; }
    public void setCodigo(Integer codigo) { this.codigo = codigo; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public boolean isEstado() { return estado; }
    public void setEstado(boolean estado) { this.estado = estado; }

    public LocalDateTime getUltimoAcceso() { return ultimoAcceso; }
    public void setUltimoAcceso(LocalDateTime ultimoAcceso) { this.ultimoAcceso = ultimoAcceso; }
}
