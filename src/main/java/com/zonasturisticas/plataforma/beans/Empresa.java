package com.zonasturisticas.plataforma.beans;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "empresas")
public class Empresa implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, length = 20, unique = true)
    private String codigo;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(name = "color_primario", length = 10, columnDefinition = "varchar(10) default '#EC407A'")
    private String colorPrimario = "#EC407A";

    @Column(name = "color_secundario", length = 10, columnDefinition = "varchar(10) default '#BA68C8'")
    private String colorSecundario = "#BA68C8";

    @Column(length = 11, unique = true)
    private String ruc;

    @Column(length = 50)
    private String sector;

    @Column(name = "logo_path", length = 100)
    private String logoPath;

    @Column(name = "logo_dark_path", length = 100)
    private String logoDarkPath;

    @Column(name = "icon_path", length = 100)
    private String iconPath;

    @Column(name = "icon_dark_path", length = 100)
    private String iconDarkPath;

    @Column(name = "usar_mismo_logo_oscuro", columnDefinition = "tinyint(1) default 1")
    private boolean usarMismoLogoOscuro = true;

    @Column(name = "usar_mismo_icono_oscuro", columnDefinition = "tinyint(1) default 1")
    private boolean usarMismoIconoOscuro = true;

    @Column(name = "es_principal", columnDefinition = "tinyint(1) default 0")
    private boolean esPrincipal = false;

    public Empresa() {
    }

    public Empresa(String codigo, String nombre) {
        this.codigo = codigo;
        this.nombre = nombre;
    }

    // Getters y Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getColorPrimario() {
        return colorPrimario;
    }

    public void setColorPrimario(String colorPrimario) {
        this.colorPrimario = colorPrimario;
    }

    public String getColorSecundario() {
        return colorSecundario;
    }

    public void setColorSecundario(String colorSecundario) {
        this.colorSecundario = colorSecundario;
    }

    public String getLogoPath() {
        return logoPath;
    }

    public void setLogoPath(String logoPath) {
        this.logoPath = logoPath;
    }

    public String getIconPath() {
        return iconPath;
    }

    public void setIconPath(String iconPath) {
        this.iconPath = iconPath;
    }

    public String getLogoDarkPath() {
        return logoDarkPath;
    }

    public void setLogoDarkPath(String logoDarkPath) {
        this.logoDarkPath = logoDarkPath;
    }

    public String getIconDarkPath() {
        return iconDarkPath;
    }

    public void setIconDarkPath(String iconDarkPath) {
        this.iconDarkPath = iconDarkPath;
    }

    public boolean isUsarMismoLogoOscuro() {
        return usarMismoLogoOscuro;
    }

    public void setUsarMismoLogoOscuro(boolean usarMismoLogoOscuro) {
        this.usarMismoLogoOscuro = usarMismoLogoOscuro;
    }

    public boolean isUsarMismoIconoOscuro() {
        return usarMismoIconoOscuro;
    }

    public void setUsarMismoIconoOscuro(boolean usarMismoIconoOscuro) {
        this.usarMismoIconoOscuro = usarMismoIconoOscuro;
    }

    public String getLogoPathForDark() {
        if (usarMismoLogoOscuro || logoDarkPath == null || logoDarkPath.isBlank()) {
            return logoPath;
        }
        return logoDarkPath;
    }

    public String getIconPathForDark() {
        if (usarMismoIconoOscuro || iconDarkPath == null || iconDarkPath.isBlank()) {
            return iconPath;
        }
        return iconDarkPath;
    }

    public boolean isEsPrincipal() {
        return esPrincipal;
    }

    public void setEsPrincipal(boolean esPrincipal) {
        this.esPrincipal = esPrincipal;
    }

    public String getRuc() {
        return ruc;
    }

    public void setRuc(String ruc) {
        this.ruc = ruc;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }
}
