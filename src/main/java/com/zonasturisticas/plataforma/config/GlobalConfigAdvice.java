package com.zonasturisticas.plataforma.config;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.zonasturisticas.plataforma.services.ConfiguracionService;

/**
 * Controlador global que inyecta las configuraciones del sistema
 * a todas las vistas de la aplicación.
 * 
 * Esto permite que cualquier JSP acceda a las configuraciones usando
 * la variable ${configs['clave']}
 */
@ControllerAdvice
public class GlobalConfigAdvice {

    @Autowired
    private ConfiguracionService configuracionService;

    /**
     * Inyecta el mapa de configuraciones a todas las vistas.
     * 
     * @return Mapa con todas las configuraciones del sistema (clave -> valor)
     */
    @ModelAttribute("configs")
    public Map<String, String> addConfigurations() {
        return configuracionService.getAllAsMap();
    }
}
