package com.zonasturisticas.plataforma.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.zonasturisticas.plataforma.beans.PlantillaHorario;

import com.zonasturisticas.plataforma.services.PlantillaHorarioService;
import com.zonasturisticas.plataforma.services.TipoTurnoService;

import jakarta.servlet.http.HttpSession;
import com.zonasturisticas.plataforma.beans.Empleado;

import java.time.LocalTime;

@Controller
@RequestMapping("/plantillas")
public class PlantillaHorarioController {

    private final PlantillaHorarioService service;
    private final TipoTurnoService tipoTurnoService;

    public PlantillaHorarioController(PlantillaHorarioService service, TipoTurnoService tipoTurnoService) {
        this.service = service;
        this.tipoTurnoService = tipoTurnoService;
    }

    private boolean isAdmin(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        return usuario != null && "ADMIN".equals(usuario.getRol());
    }

    @GetMapping
    public String listar(Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/index.jsp";
        model.addAttribute("plantillas", service.listarTodos());
        return "views/admin/plantillas/lista";
    }

    @GetMapping("/nueva")
    public String nueva(Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/index.jsp";
        model.addAttribute("tiposTurno", tipoTurnoService.listarTipos());
        return "views/admin/plantillas/formulario";
    }

    @GetMapping("/editar")
    public String editar(@RequestParam("id") int id, Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/index.jsp";
        PlantillaHorario plantilla = service.obtenerPorId(id);
        if (plantilla != null) {
            model.addAttribute("plantilla", plantilla);
            model.addAttribute("tiposTurno", tipoTurnoService.listarTipos());
            return "views/admin/plantillas/formulario";
        }
        return "redirect:/plantillas";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(value = "id", required = false) Integer id,
            @RequestParam("nombre") String nombre,
            @RequestParam("horaInicio") java.util.List<String> horasInicio,
            @RequestParam("horaFin") java.util.List<String> horasFin,
            @RequestParam("tipoTurno") java.util.List<String> tiposTurno,
            Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/index.jsp";

        try {
            PlantillaHorario p = (id != null) ? service.obtenerPorId(id) : new PlantillaHorario();
            if (p == null)
                p = new PlantillaHorario();

            p.setNombre(nombre);

            // Clear existing details (since we are replacing them)
            p.getDetalles().clear();

            // Iterate 7 days (indices 0-6 in lists correspond to Mon-Sun)
            for (int i = 0; i < 7; i++) {
                String inicio = horasInicio.get(i);
                String fin = horasFin.get(i);
                String tipo = tiposTurno.get(i);

                com.zonasturisticas.plataforma.beans.DetallePlantilla d = new com.zonasturisticas.plataforma.beans.DetallePlantilla();
                d.setDiaSemana(i + 1); // 1-7
                d.setPlantilla(p);

                if (inicio != null && !inicio.isEmpty() && fin != null && !fin.isEmpty()) {
                    d.setHoraInicio(LocalTime.parse(inicio));
                    d.setHoraFin(LocalTime.parse(fin));
                    d.setTipoTurno(tipo);
                    d.setEsDescanso(false);
                } else {
                    d.setEsDescanso(true);
                }

                p.getDetalles().add(d);
            }

            service.guardar(p);
            return "redirect:/plantillas";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "Error al guardar: " + e.getMessage());
            model.addAttribute("tiposTurno", tipoTurnoService.listarTipos());
            return "views/admin/plantillas/formulario";
        }
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/index.jsp";
        service.eliminar(id);
        return "redirect:/plantillas";
    }
}
