package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.services.PanelService;
import com.zonasturisticas.plataforma.services.integracion.IntegracionScheduler;
import com.zonasturisticas.plataforma.services.integracion.ResultadoSincronizacion;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * Panel de control administrativo.
 *
 * CU-06 / CU-07: ademas de la ejecucion periodica automatica en segundo plano,
 * el gestor puede disparar manualmente la sincronizacion con PeruRail y SENAMHI
 * desde los accesos rapidos del panel (no existe una pagina dedicada de
 * "Integraciones").
 */
@Controller
@RequestMapping("/panel")
public class PanelController {

    private final PanelService panelService;
    private final IntegracionScheduler integracionScheduler;

    public PanelController(PanelService panelService, IntegracionScheduler integracionScheduler) {
        this.panelService = panelService;
        this.integracionScheduler = integracionScheduler;
    }

    @GetMapping
    public String panel(HttpSession session, Model model) {
        model.addAttribute("resumen", panelService.resumen());
        if (session.getAttribute("toast_denegado") != null) {
            session.removeAttribute("toast_denegado");
            model.addAttribute("toast", "No cuenta con permisos para acceder a ese módulo.");
            model.addAttribute("toastTipo", "error");
        }
        return "panel/dashboard";
    }

    @PostMapping("/integraciones/sincronizar")
    public String sincronizar(@RequestParam(value = "fuente", required = false) String fuente,
            HttpServletRequest request, RedirectAttributes flash) {

        List<ResultadoSincronizacion> resultados;
        if (SincronizacionLog.FUENTE_PERURAIL.equals(fuente)) {
            resultados = List.of(integracionScheduler.sincronizarPeruRail());
        } else if (SincronizacionLog.FUENTE_SENAMHI.equals(fuente)) {
            resultados = List.of(integracionScheduler.sincronizarSenamhi());
        } else {
            resultados = integracionScheduler.sincronizarTodo();
        }

        boolean todoOk = resultados.stream().allMatch(ResultadoSincronizacion::isExitosa);
        int registros = resultados.stream().mapToInt(ResultadoSincronizacion::getRegistros).sum();

        flash.addFlashAttribute("toast", todoOk
                ? "Sincronización completada: " + registros + " registros actualizados."
                : "Una de las fuentes no respondió. Se conservó la última información válida.");
        flash.addFlashAttribute("toastTipo", todoOk ? "success" : "warning");

        // Vuelve a la pagina que disparo la sincronizacion (dashboard o estaciones);
        // ya no existe una pagina dedicada de "Integraciones". Se compara el
        // Referer contra rutas propias conocidas en lugar de reenviarlo tal cual,
        // para no abrir una redireccion abierta a partir de un encabezado externo.
        String referer = request.getHeader("Referer");
        boolean vieneDeEstaciones = referer != null && referer.contains("/panel/estaciones");
        return "redirect:/panel" + (vieneDeEstaciones ? "/estaciones" : "");
    }
}
