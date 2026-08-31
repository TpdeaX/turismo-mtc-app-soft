package com.zonasturisticas.plataforma.filters;

import java.io.IOException;
import java.util.Collection;

import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Permiso;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
@Order(1)
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");

        String path = req.getRequestURI().substring(req.getContextPath().length());

        if ("/index.jsp".equals(path) || "/".equals(path)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        boolean isStaticResource = path.startsWith("/assets/") ||
                path.startsWith("/css/") ||
                path.startsWith("/js/") ||
                path.endsWith(".css") ||
                path.endsWith(".js") ||
                path.endsWith(".png") ||
                path.endsWith(".jpg") ||
                path.endsWith(".jpeg") ||
                path.endsWith(".ico");

        boolean isPublicPage = path.equals("/login") ||
                path.equals("/auth/login") ||
                path.equals("/auth/logout") ||
                path.startsWith("/views/components/") ||
                path.startsWith("/views/shared/");

        if (isStaticResource) {
            chain.doFilter(request, response);
            return;
        }

        Empleado usuario = (session != null) ? (Empleado) session.getAttribute("usuario") : null;
        boolean isLoggedIn = usuario != null;

        if (!isLoggedIn && !isPublicPage) {
            if (path.startsWith("/api/")) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        if (isLoggedIn && (path.equals("/login") || path.equals("/auth/login"))) {
            if (usuario.isAdmin()) {
                res.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                res.sendRedirect(req.getContextPath() + "/empleado");
            }
            return;
        }

        boolean isAdminRoute = path.startsWith("/views/admin/") ||
                path.equals("/dashboard") ||
                path.startsWith("/empleados") ||
                path.startsWith("/sucursales") ||
                path.startsWith("/reportes") ||
                path.startsWith("/plantillas") ||
                path.startsWith("/horarios") ||
                path.startsWith("/tipoturno") ||
                path.startsWith("/feriados") ||
                path.startsWith("/parametros") ||
                path.startsWith("/empresas") ||
                path.startsWith("/admin/asistencias") ||
                path.startsWith("/asistencias");

        if (isLoggedIn && isAdminRoute) {
            boolean tieneAcceso = false;

            if (usuario.isAdmin()) {
                tieneAcceso = true;

                if (path.startsWith("/empresas")) {
                    tieneAcceso = usuario.isSuperAdmin() || usuario.tieneAccesoTodasEmpresas();
                } else if (path.startsWith("/sucursales")) {
                    tieneAcceso = usuario.isSuperAdmin() || usuario.tieneAccesoTodasSucursales();
                } else if (path.startsWith("/parametros")) {
                    tieneAcceso = usuario.tieneAccesoTotalSistema();
                }
            } else if ("PERSONALIZADO".equals(usuario.getRol())) {
                Collection<Permiso> permisos = usuario.getPermisos();
                if (permisos != null) {
                    if (path.startsWith("/empleados") &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("GESTIONAR_EMPLEADOS"))) {
                        tieneAcceso = true;
                    } else if (path.startsWith("/reportes") &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("VER_REPORTES"))) {
                        tieneAcceso = true;
                    } else if (path.startsWith("/justificaciones/admin") &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("APROBAR_JUSTIFICACIONES"))) {
                        tieneAcceso = true;
                    } else if ((path.startsWith("/sucursales") || path.startsWith("/parametros")
                            || path.startsWith("/plantillas")) &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("CONFIGURACION_SISTEMA"))) {
                        tieneAcceso = true;
                    } else if ((path.startsWith("/horarios") || path.startsWith("/tipoturno")
                            || path.startsWith("/asistencias")) &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("EDITAR_HORARIOS"))) {
                        tieneAcceso = true;
                    } else if (path.startsWith("/dashboard") &&
                            permisos.stream().anyMatch(p -> p.getNombre().equals("VER_DASHBOARD_TOTAL"))) {
                        tieneAcceso = true;
                    }
                }
            }

            if (!tieneAcceso) {
                res.sendRedirect(req.getContextPath() + "/empleado");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
