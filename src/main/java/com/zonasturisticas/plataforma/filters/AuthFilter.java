package com.zonasturisticas.plataforma.filters;

import com.zonasturisticas.plataforma.beans.Usuario;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * RNF06: proteccion del panel administrativo mediante autenticacion de usuario.
 *
 * El portal del turista es de acceso libre (precondicion del CU-01: basta con
 * ingresar a la plataforma). Todo lo que cuelga de /panel exige sesion y,
 * ademas, el rol correspondiente segun la RN02:
 *   - /panel/zonas, /panel/rutas   -> Travel Group Peru (RF08) o administrador
 *   - /panel/servicios, /panel/horarios -> PeruRail (RF13) o administrador
 *   - /panel/parametros, /panel/gestores -> solo administrador (RF12)
 */
@Component
@Order(1)
public class AuthFilter implements Filter {

    private static final String PREFIJO_PANEL = "/panel";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Recursos estaticos y portal publico: sin restriccion
        if (!path.startsWith(PREFIJO_PANEL)) {
            chain.doFilter(request, response);
            return;
        }

        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");

        HttpSession session = req.getSession(false);
        Usuario usuario = session == null ? null : (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            if (esPeticionAjax(req)) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sesión expirada");
            } else {
                res.sendRedirect(req.getContextPath() + "/acceso?destino="
                        + java.net.URLEncoder.encode(path, java.nio.charset.StandardCharsets.UTF_8));
            }
            return;
        }

        if (!tienePermiso(usuario, path)) {
            res.sendRedirect(req.getContextPath() + "/panel?denegado=1");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean tienePermiso(Usuario usuario, String path) {
        if (usuario.isAdmin()) {
            return true;
        }
        if (path.startsWith("/panel/zonas") || path.startsWith("/panel/rutas")
                || path.startsWith("/panel/categorias")) {
            return usuario.isPuedeGestionarZonas();
        }
        if (path.startsWith("/panel/ferroviario") || path.startsWith("/panel/servicios")
                || path.startsWith("/panel/horarios")) {
            return usuario.isPuedeGestionarFerroviario();
        }
        if (path.startsWith("/panel/parametros") || path.startsWith("/panel/gestores")
                || path.startsWith("/panel/estaciones/guardar") || path.startsWith("/panel/estaciones/eliminar")) {
            return usuario.isPuedeConfigurarPlataforma();
        }
        // Panel principal, listado de estaciones (RF09, solo lectura) y bitacora
        return true;
    }

    private boolean esPeticionAjax(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                || (accept != null && accept.contains("application/json"));
    }
}
