package com.zonasturisticas.plataforma.config;

import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Expone a todas las vistas el gestor autenticado y las preferencias vigentes
 * de la sesion del turista, evitando repetir esa lectura en cada controlador.
 */
@ControllerAdvice
public class GlobalModelAdvice {

    public static final String ATTR_USUARIO = "usuario";
    public static final String ATTR_PREFERENCIAS = "preferencias";

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
}
