package com.zonasturisticas.plataforma.config;

import com.zonasturisticas.plataforma.beans.Configuracion;
import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import com.zonasturisticas.plataforma.services.ConfiguracionService;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Expone a todas las vistas el gestor autenticado, las preferencias vigentes
 * de la sesion del turista, y los parametros generales de la plataforma,
 * evitando repetir esa lectura en cada controlador.
 *
 * Acceso en JSP: ${parametros['plataforma.nombre']}, ${parametros['portal.aviso_legal']}, etc.
 */
@ControllerAdvice
public class GlobalModelAdvice {

    public static final String ATTR_USUARIO = "usuario";
    public static final String ATTR_PREFERENCIAS = "preferencias";

    private final ConfiguracionService configuracionService;

    public GlobalModelAdvice(ConfiguracionService configuracionService) {
        this.configuracionService = configuracionService;
    }

    @ModelAttribute("usuarioSesion")
    public Usuario usuarioSesion(HttpSession session) {
        return (Usuario) session.getAttribute(ATTR_USUARIO);
    }

    @ModelAttribute("preferenciasSesion")
    public PreferenciasSesion preferenciasSesion(HttpSession session) {
        PreferenciasSesion p = (PreferenciasSesion) session.getAttribute(ATTR_PREFERENCIAS);
        if (p == null) {
            p = new PreferenciasSesion();
            session.setAttribute(ATTR_PREFERENCIAS, p);
        }
        return p;
    }

    /**
     * Expone todos los parametros de configuracion de la plataforma (RF12)
     * como un mapa clave-valor accesible desde cualquier vista.
     */
    @ModelAttribute("parametros")
    public Map<String, String> parametros() {
        Map<String, String> mapa = new LinkedHashMap<>();
        for (Configuracion c : configuracionService.listar()) {
            mapa.put(c.getClave(), c.getValor());
        }
        return mapa;
    }
}
