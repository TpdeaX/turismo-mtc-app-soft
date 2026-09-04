package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.beans.SincronizacionLog;
import com.zonasturisticas.plataforma.services.PanelService;
import com.zonasturisticas.plataforma.services.integracion.IntegracionScheduler;
import com.zonasturisticas.plataforma.services.integracion.ResultadoSincronizacion;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * Panel de control administrativo y modulo de integracion de datos.
 *
 * CU-06 / CU-07: ademas de la ejecucion periodica automatica, el gestor puede
 * disparar manualmente la sincronizacion con PeruRail y SENAMHI.
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
    public String panel(@RequestParam(value = "denegado", required = false) String denegado, Model model) {
        model.addAttribute("resumen", panelService.resumen());
        if (denegado != null) {
            model.addAttribute("toast", "No cuenta con permisos para acceder a ese módulo.");
            model.addAttribute("toastTipo", "error");
        }
        return "panel/dashboard";
    }

    @GetMapping("/integraciones")
    public String integraciones(Model model) {
        model.addAttribute("bitacora", integracionScheduler.bitacora());
        model.addAttribute("ultimaPeruRail", integracionScheduler.ultima(SincronizacionLog.FUENTE_PERURAIL));
        model.addAttribute("ultimaSenamhi", integracionScheduler.ultima(SincronizacionLog.FUENTE_SENAMHI));
        return "panel/integraciones";
    }

    @PostMapping("/integraciones/sincronizar")
    public String sincronizar(@RequestParam(value = "fuente", required = false) String fuente,
            RedirectAttributes flash) {

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
        return "redirect:/panel/integraciones";
    }
}
