package com.zonasturisticas.plataforma.controllers;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.ArrayList;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Horario;
import com.zonasturisticas.plataforma.beans.TipoTurno;
import com.zonasturisticas.plataforma.beans.PlantillaDia;
import com.zonasturisticas.plataforma.beans.DetallePlantillaDia;
import com.zonasturisticas.plataforma.services.EmpleadoService;
import com.zonasturisticas.plataforma.services.HorarioService;
import com.zonasturisticas.plataforma.services.TipoTurnoService;
import com.zonasturisticas.plataforma.services.PlantillaHorarioService;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.services.PlantillaDiaService;
import java.util.Set;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/horarios")
public class HorarioController {

    private final HorarioService horarioService;
    private final EmpleadoService empleadoService;
    private final TipoTurnoService tipoTurnoService;
    private final PlantillaHorarioService plantillaService;
    private final PlantillaDiaService plantillaDiaService;

    public HorarioController(HorarioService horarioService, EmpleadoService empleadoService,
            TipoTurnoService tipoTurnoService, PlantillaHorarioService plantillaService,
            PlantillaDiaService plantillaDiaService) {
        this.horarioService = horarioService;
        this.empleadoService = empleadoService;
        this.tipoTurnoService = tipoTurnoService;
        this.plantillaService = plantillaService;
        this.plantillaDiaService = plantillaDiaService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    private boolean isAdmin(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        return usuario != null && ("ADMIN".equals(usuario.getRol()) || "SUPER_ADMIN".equals(usuario.getRol()));
    }

    @SuppressWarnings("unchecked")
    private List<Integer> getEmpresaIds(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || usuario.getEmpresas() == null || usuario.getEmpresas().isEmpty()) {
            return null;
        }
        Empresa empresaActiva = (Empresa) session.getAttribute("empresaActiva");
        if (empresaActiva != null) {
            return List.of(empresaActiva.getId());
        }
        return usuario.getEmpresas().stream().map(Empresa::getId).collect(Collectors.toList());
    }

    private Integer getSucursalIdForzada(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        if (usuario == null || !usuario.isAdmin() || usuario.tieneAccesoTodasSucursales()) {
            return null;
        }
        return usuario.getSucursal() != null ? usuario.getSucursal().getId() : null;
    }

    @GetMapping
    public String listar(@RequestParam(value = "fecha", required = false) String fechaStr,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        LocalDate fecha;

        // If parameter is present, save to session and redirect to clean URL
        if (fechaStr != null && !fechaStr.isEmpty()) {
            fecha = LocalDate.parse(fechaStr);
            session.setAttribute("fechaSeleccionada", fecha);
            return "redirect:/horarios";
        }

        // Retrieve from session or default to now
        LocalDate sessionDate = (LocalDate) session.getAttribute("fechaSeleccionada");
        fecha = (sessionDate != null) ? sessionDate : LocalDate.now();
        // Ensure session is updated (in case of default)
        session.setAttribute("fechaSeleccionada", fecha);

        List<Integer> empresaIds = getEmpresaIds(session);
        List<Horario> horarios = horarioService.listarPorFecha(fecha, empresaIds);
        Integer sucursalForzada = getSucursalIdForzada(session);
        List<Empleado> empleados = empleadoService.listarAvanzadoSinPaginacion("", null, null, sucursalForzada,
                empresaIds);
        List<TipoTurno> tiposTurno = tipoTurnoService
                .listarTiposPorEmpresas(org.springframework.data.domain.PageRequest.of(0, 500), "", empresaIds)
                .getContent();

        Map<String, String> turnoColors = tiposTurno.stream()
                .collect(Collectors.toMap(TipoTurno::getNombre, TipoTurno::getColor));

        model.addAttribute("horarios", horarios);
        model.addAttribute("empleados", empleados);
        model.addAttribute("fechaSeleccionada", fecha);
        model.addAttribute("turnoColors", turnoColors); // Pass colors to view

        model.addAttribute("isAdmin", isAdmin(session));

        return "views/admin/gestion_horarios";
    }

    @PostMapping("/api/set-date")
    @ResponseBody
    public ResponseEntity<?> setDate(@RequestBody Map<String, String> payload, HttpSession session) {
        String fechaStr = payload.get("fecha");
        if (fechaStr != null && !fechaStr.isEmpty()) {
            try {
                session.setAttribute("fechaSeleccionada", LocalDate.parse(fechaStr));
                return ResponseEntity.ok(Map.of("status", "ok"));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body("Fecha invalida");
            }
        }
        return ResponseEntity.badRequest().body("Fecha requerida");
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        List<Integer> empresaIds = getEmpresaIds(session);
        Integer sucursalForzada = getSucursalIdForzada(session);
        model.addAttribute("empleados",
                empleadoService.listarAvanzadoSinPaginacion("", null, null, sucursalForzada, empresaIds));
        model.addAttribute("tiposTurno", tipoTurnoService
                .listarTiposPorEmpresas(org.springframework.data.domain.PageRequest.of(0, 500), "", empresaIds)
                .getContent());
        model.addAttribute("plantillas", plantillaService.listarTodos());
        return "views/admin/formulario_horario";
    }

    @GetMapping("/editar")
    public String editar(@RequestParam("id") int id, Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        Horario horario = horarioService.obtenerPorId(id);
        if (horario != null) {
            model.addAttribute("horario", horario);
            List<Integer> empresaIds = getEmpresaIds(session);
            Integer sucursalForzada = getSucursalIdForzada(session);
            model.addAttribute("empleados",
                    empleadoService.listarAvanzadoSinPaginacion("", null, null, sucursalForzada, empresaIds));
            model.addAttribute("tiposTurno", tipoTurnoService
                    .listarTiposPorEmpresas(org.springframework.data.domain.PageRequest.of(0, 500), "", empresaIds)
                    .getContent());
            model.addAttribute("plantillas", plantillaService.listarTodos());
            return "views/admin/formulario_horario";
        }
        return "redirect:/horarios";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(value = "id", required = false) Integer id,
            @RequestParam("empleadoId") int empleadoId,
            @RequestParam("fecha") String fechaStr,
            @RequestParam("horaInicio") String horaInicioStr,
            @RequestParam("horaFin") String horaFinStr,
            @RequestParam("tipoTurno") String tipoTurno,
            Model model, HttpSession session) {

        if (!isAdmin(session))
            return "redirect:/horarios";

        try {
            Horario h = (id != null) ? horarioService.obtenerPorId(id) : new Horario();
            if (h == null)
                h = new Horario();

            Empleado e = empleadoService.obtenerPorId(empleadoId);
            h.setEmpleado(e);

            LocalDate fecha = LocalDate.parse(fechaStr);
            h.setFecha(fecha);
            h.setHoraInicio(LocalTime.parse(horaInicioStr));
            h.setHoraFin(LocalTime.parse(horaFinStr));
            h.setTipoTurno(tipoTurno);

            // Update session date to stay on the same day
            session.setAttribute("fechaSeleccionada", fecha);

            horarioService.guardar(h);
            return "redirect:/horarios"; // Clean URL
        } catch (Exception e) {
            model.addAttribute("error", "Error al guardar: " + e.getMessage());
            List<Integer> empresaIds = getEmpresaIds(session);
            Integer sucursalForzada = getSucursalIdForzada(session);
            model.addAttribute("empleados",
                    empleadoService.listarAvanzadoSinPaginacion("", null, null, sucursalForzada, empresaIds));
            model.addAttribute("tiposTurno", tipoTurnoService
                    .listarTiposPorEmpresas(org.springframework.data.domain.PageRequest.of(0, 500), "", empresaIds)
                    .getContent());
            return "views/admin/formulario_horario";
        }
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        Horario h = horarioService.obtenerPorId(id);
        if (h != null) {
            // Update session date to stay on the same day
            session.setAttribute("fechaSeleccionada", h.getFecha());
            horarioService.eliminar(id);
        }
        return "redirect:/horarios"; // Clean URL
    }

    @GetMapping("/api/list")
    @ResponseBody
    public List<Map<String, Object>> listarApi(@RequestParam(value = "fecha", required = false) String fechaStr,
            HttpSession session) {
        LocalDate fecha = (fechaStr != null && !fechaStr.isEmpty()) ? LocalDate.parse(fechaStr) : LocalDate.now();
        List<Integer> empresaIds = getEmpresaIds(session);
        List<Horario> horarios = horarioService.listarPorFecha(fecha, empresaIds);
        List<TipoTurno> tiposTurno = tipoTurnoService
                .listarTiposPorEmpresas(org.springframework.data.domain.PageRequest.of(0, 500), "", empresaIds)
                .getContent();
        Map<String, String> turnoColors = tiposTurno.stream()
                .collect(Collectors.toMap(TipoTurno::getNombre, TipoTurno::getColor));

        return horarios.stream().map(h -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", h.getId());
            map.put("empleadoId", h.getEmpleado().getId());
            map.put("empleadoNombre", h.getEmpleado().getNombres()); // Assuming Nombres is sufficient for display
            map.put("fecha", h.getFecha().toString());
            map.put("horaInicio", h.getHoraInicio().toString());
            map.put("horaFin", h.getHoraFin().toString());
            map.put("tipoTurno", h.getTipoTurno());
            map.put("color", turnoColors.getOrDefault(h.getTipoTurno(), "#cccccc"));
            return map;
        }).collect(Collectors.toList());
    }

    @PostMapping("/api/guardar")
    @ResponseBody
    public ResponseEntity<?> guardarApi(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            Integer id = null;
            if (idObj != null && !idObj.toString().isEmpty()) {
                try {
                    id = Integer.parseInt(idObj.toString());
                } catch (NumberFormatException e) {
                    // ignore, implies new record
                }
            }

            int empleadoId = Integer.parseInt(payload.get("empleadoId").toString());
            String fechaStr = (String) payload.get("fecha");
            String horaInicioStr = (String) payload.get("horaInicio");
            String horaFinStr = (String) payload.get("horaFin");
            String tipoTurno = (String) payload.get("tipoTurno");

            Horario h = (id != null) ? horarioService.obtenerPorId(id) : new Horario();
            if (h == null)
                h = new Horario();

            Empleado e = empleadoService.obtenerPorId(empleadoId);
            h.setEmpleado(e);
            h.setFecha(LocalDate.parse(fechaStr));
            h.setHoraInicio(LocalTime.parse(horaInicioStr));
            h.setHoraFin(LocalTime.parse(horaFinStr));
            h.setTipoTurno(tipoTurno);

            horarioService.guardar(h);

            // Return the saved object structure
            Map<String, Object> response = new HashMap<>();
            response.put("status", "ok");
            response.put("id", h.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/eliminar")
    @ResponseBody
    public ResponseEntity<?> eliminarApi(@RequestBody Map<String, Object> payload) {
        try {
            Integer id = Integer.parseInt(payload.get("id").toString());
            horarioService.eliminar(id);
            return ResponseEntity.ok(Map.of("status", "ok"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/eliminar-turnos-empleado")
    @ResponseBody
    public ResponseEntity<?> eliminarTurnosEmpleadoApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            int empleadoId = Integer.parseInt(payload.get("empleadoId").toString());
            String fechaStr = (String) payload.get("fecha");
            LocalDate fecha = LocalDate.parse(fechaStr);

            horarioService.eliminarPorEmpleadoYFecha(empleadoId, fecha);
            return ResponseEntity.ok(Map.of("status", "ok"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    // --- New APIs for Templates and Copy ---

    @GetMapping("/api/plantillas")
    @ResponseBody
    public List<Map<String, Object>> listarPlantillasApi() {
        return plantillaService.listarTodos().stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", p.getId());
            map.put("nombre", p.getNombre());
            map.put("detalles", p.getDetalles().stream().map(d -> {
                Map<String, Object> det = new HashMap<>();
                det.put("diaSemana", d.getDiaSemana());
                det.put("horaInicio", d.getHoraInicio() != null ? d.getHoraInicio().toString() : null);
                det.put("horaFin", d.getHoraFin() != null ? d.getHoraFin().toString() : null);
                det.put("tipoTurno", d.getTipoTurno());
                det.put("esDescanso", d.isEsDescanso());
                return det;
            }).collect(Collectors.toList()));
            return map;
        }).collect(Collectors.toList());
    }

    @PostMapping("/api/aplicar-plantilla")
    @ResponseBody
    public ResponseEntity<?> aplicarPlantillaApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            int plantillaId = Integer.parseInt(payload.get("plantillaId").toString());
            String fechaStr = (String) payload.get("fecha");
            int empleadoId = Integer.parseInt(payload.get("empleadoId").toString());
            LocalDate fecha = LocalDate.parse(fechaStr);

            var plantilla = plantillaService.obtenerPorId(plantillaId);
            if (plantilla == null) {
                return ResponseEntity.badRequest().body("Plantilla no encontrada");
            }

            // Get day of week (1=Monday, 7=Sunday)
            int diaSemana = fecha.getDayOfWeek().getValue();

            // Find detail for this day
            var detalleOpt = plantilla.getDetalles().stream()
                    .filter(d -> d.getDiaSemana() == diaSemana && !d.isEsDescanso())
                    .findFirst();

            if (detalleOpt.isPresent()) {
                var detalle = detalleOpt.get();
                Empleado emp = empleadoService.obtenerPorId(empleadoId);

                Horario h = new Horario();
                h.setEmpleado(emp);
                h.setFecha(fecha);
                h.setHoraInicio(detalle.getHoraInicio());
                h.setHoraFin(detalle.getHoraFin());
                h.setTipoTurno(detalle.getTipoTurno());
                horarioService.guardar(h);
            }

            return ResponseEntity.ok(Map.of("status", "ok"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/copiar-dia")
    @ResponseBody
    public ResponseEntity<?> copiarDiaApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            String fechaOrigenStr = (String) payload.get("fechaOrigen");
            String fechaDestinoStr = (String) payload.get("fechaDestino");

            LocalDate fechaOrigen = LocalDate.parse(fechaOrigenStr);
            LocalDate fechaDestino = LocalDate.parse(fechaDestinoStr);

            List<Horario> horariosOrigen = horarioService.listarPorFecha(fechaOrigen, getEmpresaIds(session));
            int copiados = 0;

            for (Horario orig : horariosOrigen) {
                Horario nuevo = new Horario();
                nuevo.setEmpleado(orig.getEmpleado());
                nuevo.setFecha(fechaDestino);
                nuevo.setHoraInicio(orig.getHoraInicio());
                nuevo.setHoraFin(orig.getHoraFin());
                nuevo.setTipoTurno(orig.getTipoTurno());
                horarioService.guardar(nuevo);
                copiados++;
            }

            return ResponseEntity.ok(Map.of("status", "ok", "copiados", copiados));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/copiar-turno")
    @ResponseBody
    public ResponseEntity<?> copiarTurnoApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            int turnoId = Integer.parseInt(payload.get("turnoId").toString());
            String fechaDestinoStr = (String) payload.get("fechaDestino");
            LocalDate fechaDestino = LocalDate.parse(fechaDestinoStr);

            Horario orig = horarioService.obtenerPorId(turnoId);
            if (orig == null) {
                return ResponseEntity.badRequest().body("Turno no encontrado");
            }

            Horario nuevo = new Horario();
            nuevo.setEmpleado(orig.getEmpleado());
            nuevo.setFecha(fechaDestino);
            nuevo.setHoraInicio(orig.getHoraInicio());
            nuevo.setHoraFin(orig.getHoraFin());
            nuevo.setTipoTurno(orig.getTipoTurno());
            horarioService.guardar(nuevo);

            return ResponseEntity.ok(Map.of("status", "ok", "nuevoId", nuevo.getId()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    // --- Day Template (PlantillaDia) APIs ---

    @GetMapping("/api/plantillas-dia")
    @ResponseBody
    public List<Map<String, Object>> listarPlantillasDiaApi() {
        return plantillaDiaService.listarTodos().stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", p.getId());
            map.put("nombre", p.getNombre());
            map.put("fechaOrigen", p.getFechaOrigen() != null ? p.getFechaOrigen().toString() : null);
            map.put("fechaCreacion", p.getFechaCreacion() != null ? p.getFechaCreacion().toString() : null);
            map.put("cantidadTurnos", p.getDetalles().size());
            return map;
        }).collect(Collectors.toList());
    }

    @PostMapping("/api/guardar-plantilla-dia")
    @ResponseBody
    public ResponseEntity<?> guardarPlantillaDiaApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            String nombre = (String) payload.get("nombre");
            String fechaStr = (String) payload.get("fecha");
            LocalDate fecha = LocalDate.parse(fechaStr);

            // Get all shifts for this date
            List<Horario> horarios = horarioService.listarPorFecha(fecha, getEmpresaIds(session));
            if (horarios.isEmpty()) {
                return ResponseEntity.badRequest().body("No hay turnos para guardar en esta fecha");
            }

            // Create new PlantillaDia
            PlantillaDia plantilla = new PlantillaDia();
            plantilla.setNombre(nombre);
            plantilla.setFechaOrigen(fecha);
            plantilla.setFechaCreacion(LocalDate.now());

            // Add all shifts as details
            for (Horario h : horarios) {
                DetallePlantillaDia detalle = new DetallePlantillaDia();
                detalle.setEmpleadoId(h.getEmpleado().getId());
                detalle.setHoraInicio(h.getHoraInicio());
                detalle.setHoraFin(h.getHoraFin());
                detalle.setTipoTurno(h.getTipoTurno());
                plantilla.addDetalle(detalle);
            }

            plantillaDiaService.guardar(plantilla);

            return ResponseEntity.ok(Map.of("status", "ok", "id", plantilla.getId(), "turnos", horarios.size()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/aplicar-plantilla-dia")
    @ResponseBody
    public ResponseEntity<?> aplicarPlantillaDiaApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            int plantillaId = Integer.parseInt(payload.get("plantillaId").toString());
            String fechaDestinoStr = (String) payload.get("fechaDestino");
            LocalDate fechaDestino = LocalDate.parse(fechaDestinoStr);

            PlantillaDia plantilla = plantillaDiaService.obtenerPorId(plantillaId);
            if (plantilla == null) {
                return ResponseEntity.badRequest().body("Plantilla no encontrada");
            }

            int creados = 0;
            for (DetallePlantillaDia detalle : plantilla.getDetalles()) {
                Empleado emp = empleadoService.obtenerPorId(detalle.getEmpleadoId());
                if (emp == null)
                    continue; // Skip if employee no longer exists

                Horario h = new Horario();
                h.setEmpleado(emp);
                h.setFecha(fechaDestino);
                h.setHoraInicio(detalle.getHoraInicio());
                h.setHoraFin(detalle.getHoraFin());
                h.setTipoTurno(detalle.getTipoTurno());
                horarioService.guardar(h);
                creados++;
            }

            return ResponseEntity.ok(Map.of("status", "ok", "creados", creados));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/eliminar-plantilla-dia")
    @ResponseBody
    public ResponseEntity<?> eliminarPlantillaDiaApi(@RequestBody Map<String, Object> payload, HttpSession session) {
        if (!isAdmin(session)) {
            return ResponseEntity.status(403).body("No autorizado");
        }
        try {
            int id = Integer.parseInt(payload.get("id").toString());
            plantillaDiaService.eliminar(id);
            return ResponseEntity.ok(Map.of("status", "ok"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}
