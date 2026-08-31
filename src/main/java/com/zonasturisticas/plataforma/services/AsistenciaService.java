package com.zonasturisticas.plataforma.services;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import jakarta.persistence.criteria.Predicate;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import com.zonasturisticas.plataforma.beans.Asistencia;
import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Horario;
import com.zonasturisticas.plataforma.dto.TurnoDTO;
import com.zonasturisticas.plataforma.repositories.AsistenciaRepository;
import com.zonasturisticas.plataforma.repositories.EmpleadoRepository;
import com.zonasturisticas.plataforma.repositories.HorarioRepository;
import com.zonasturisticas.plataforma.beans.Justificacion;

@Service
public class AsistenciaService {

    private final AsistenciaRepository asistenciaRepository;
    private final EmpleadoRepository empleadoRepository;
    private final HorarioRepository horarioRepository;
    private final ConfiguracionService configuracionService;

    @org.springframework.beans.factory.annotation.Value("${app.asistencia.factor-descuento:1.0}")
    private double factorDescuento;

    @org.springframework.beans.factory.annotation.Value("${app.asistencia.factor-bonificacion:1.0}")
    private double factorBonificacion;

    public AsistenciaService(AsistenciaRepository asistenciaRepository, EmpleadoRepository empleadoRepository,
            HorarioRepository horarioRepository, ConfiguracionService configuracionService) {
        this.asistenciaRepository = asistenciaRepository;
        this.empleadoRepository = empleadoRepository;
        this.horarioRepository = horarioRepository;
        this.configuracionService = configuracionService;
    }

    /**
     * Obtiene la tolerancia en minutos desde la configuraciÃ³n del sistema.
     * 
     * @return Minutos de tolerancia (default: 15)
     */
    private int getToleranciaMinutos() {
        String valor = configuracionService.getValor("asistencia_tolerancia");
        try {
            return valor != null ? Integer.parseInt(valor) : 15;
        } catch (NumberFormatException e) {
            return 15;
        }
    }

    /**
     * Verifica si los descuentos por falta están habilitados.
     */
    public boolean isDescuentoFaltaEnabled() {
        String valor = configuracionService.getValor("descuento_falta_enabled");
        return "true".equalsIgnoreCase(valor);
    }

    /**
     * Verifica si los descuentos por tardanza están habilitados.
     */
    public boolean isDescuentoTardanzaEnabled() {
        String valor = configuracionService.getValor("descuento_tardanza_enabled");
        return "true".equalsIgnoreCase(valor);
    }

    /**
     * Verifica si las horas extras están permitidas.
     */
    public boolean isHorasExtrasEnabled() {
        String valor = configuracionService.getValor("asistencia_permitir_extras");
        return "true".equalsIgnoreCase(valor);
    }

    // --- MÃ‰TODO NUEVO: PUENTE PARA EL CONTROLLER ---
    public boolean verificarSiMarcoHoy(int empleadoId) {
        return asistenciaRepository.existsByEmpleadoIdAndFecha(empleadoId, LocalDate.now());
    }

    public long contarAsistenciasFecha(LocalDate fecha) {
        return contarAsistenciasFecha(fecha, null);
    }

    public long contarAsistenciasFecha(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return asistenciaRepository.countByFecha(fecha);
        }
        return asistenciaRepository.countByFechaConEmpresas(fecha, empresaIds);
    }

    public long contarTardanzasFecha(LocalDate fecha) {
        return contarTardanzasFecha(fecha, null);
    }

    public long contarTardanzasFecha(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThan(fecha, 0L);
        }
        return asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThanConEmpresas(fecha, 0L, empresaIds);
    }

    public List<Long> obtenerAsistenciasUltimos5Dias() {
        List<Long> counts = new ArrayList<>();
        LocalDate today = LocalDate.now();
        // Lunes a Viernes de la semana actual o ultimos 5 dias habiles?
        // El requisito dice "Tendencia de Asistencia" line chart.
        // Vamos a devolver los ultimos 5 dias incluyendo hoy.
        // O mejor, los 5 dias de la semana laboral (L-V).
        // Por simplicidad, ultimos 5 dias naturales hacia atras.

        // Vamos a hacerlo fijo Lunes, Mar, Mie, Jue, Vie de esta semana.
        LocalDate startOfWeek = today
                .with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));

        for (int i = 0; i < 5; i++) {
            LocalDate d = startOfWeek.plusDays(i);
            // Si el dia es futuro, 0
            if (d.isAfter(today)) {
                counts.add(0L);
            } else {
                counts.add(asistenciaRepository.countByFecha(d));
            }
        }
        return counts;
    }

    // === DASHBOARD STATISTICS METHODS ===

    public List<Asistencia> listarAsistenciasFecha(LocalDate fecha) {
        return listarAsistenciasFecha(fecha, null);
    }

    public List<Asistencia> listarAsistenciasFecha(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return asistenciaRepository.findByFecha(fecha);
        }
        return asistenciaRepository.findByFechaConEmpresas(fecha, empresaIds);
    }

    public List<Asistencia> listarTardanzasFecha(LocalDate fecha) {
        return listarTardanzasFecha(fecha, null);
    }

    public List<Asistencia> listarTardanzasFecha(LocalDate fecha, List<Integer> empresaIds) {
        if (empresaIds == null || empresaIds.isEmpty()) {
            return asistenciaRepository.findByFechaAndMinutosTardanzaGreaterThan(fecha, 0L);
        }
        return asistenciaRepository.findByFechaAndMinutosTardanzaGreaterThanConEmpresas(fecha, empresaIds);
    }

    public java.util.Map<String, Long> obtenerDistribucionModos(LocalDate fecha) {
        return obtenerDistribucionModos(fecha, null);
    }

    public java.util.Map<String, Long> obtenerDistribucionModos(LocalDate fecha, List<Integer> empresaIds) {
        java.util.Map<String, Long> result = new java.util.HashMap<>();
        List<Object[]> rows;
        if (empresaIds == null || empresaIds.isEmpty()) {
            rows = asistenciaRepository.countByFechaGroupByModo(fecha);
        } else {
            rows = asistenciaRepository.countByFechaGroupByModoConEmpresas(fecha, empresaIds);
        }
        for (Object[] row : rows) {
            String modo = (String) row[0];
            Long count = (Long) row[1];
            result.put(modo != null ? modo : "OTRO", count);
        }
        return result;
    }

    public List<Long> obtenerAsistenciasUltimos7Dias() {
        return obtenerAsistenciasUltimos7Dias(null);
    }

    public List<Long> obtenerAsistenciasUltimos7Dias(List<Integer> empresaIds) {
        List<Long> counts = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            if (empresaIds == null || empresaIds.isEmpty()) {
                counts.add(asistenciaRepository.countByFecha(d));
            } else {
                counts.add(asistenciaRepository.countByFechaConEmpresas(d, empresaIds));
            }
        }
        return counts;
    }

    public List<Long> obtenerTardanzasUltimos7Dias() {
        return obtenerTardanzasUltimos7Dias(null);
    }

    public List<Long> obtenerTardanzasUltimos7Dias(List<Integer> empresaIds) {
        List<Long> counts = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            if (empresaIds == null || empresaIds.isEmpty()) {
                counts.add(asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThan(d, 0L));
            } else {
                counts.add(
                        asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThanConEmpresas(d, 0L, empresaIds));
            }
        }
        return counts;
    }

    public List<String> obtenerLabelsUltimos7Dias() {
        List<String> labels = new ArrayList<>();
        LocalDate today = LocalDate.now();
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("EEE",
                new java.util.Locale("es", "ES"));
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            String label = d.format(formatter);
            // Capitalize first letter
            labels.add(label.substring(0, 1).toUpperCase() + label.substring(1));
        }
        return labels;
    }

    public com.zonasturisticas.plataforma.dto.EmpleadoRankingDTO obtenerMejorEmpleadoRango(LocalDate inicio, LocalDate fin) {
        return obtenerMejorEmpleadoRango(inicio, fin, null);
    }

    public com.zonasturisticas.plataforma.dto.EmpleadoRankingDTO obtenerMejorEmpleadoRango(LocalDate inicio, LocalDate fin,
            List<Integer> empresaIds) {
        List<Object[]> rows;
        if (empresaIds == null || empresaIds.isEmpty()) {
            rows = asistenciaRepository.findTopEmpleadosPuntualesByFechaBetween(
                    inicio, fin, org.springframework.data.domain.PageRequest.of(0, 1));
        } else {
            rows = asistenciaRepository.findTopEmpleadosPuntualesByFechaBetweenConEmpresas(
                    inicio, fin, empresaIds, org.springframework.data.domain.PageRequest.of(0, 1));
        }

        if (rows.isEmpty())
            return null;

        Object[] row = rows.get(0);
        Integer empId = (Integer) row[0];
        Long count = (Long) row[1];

        return empleadoRepository.findById(empId).map(emp -> {
            com.zonasturisticas.plataforma.dto.EmpleadoRankingDTO dto = new com.zonasturisticas.plataforma.dto.EmpleadoRankingDTO();
            dto.setId(emp.getId());
            dto.setNombres(emp.getNombres());
            dto.setApellidos(emp.getApellidos());
            dto.setDni(emp.getDni());
            dto.setTotalAsistencias(count.intValue());
            dto.setPromedioPuntualidad(100.0); // Puntual = 100%
            return dto;
        }).orElse(null);
    }

    public double calcularTasaPuntualidad(LocalDate fecha) {
        return calcularTasaPuntualidad(fecha, null);
    }

    public double calcularTasaPuntualidad(LocalDate fecha, List<Integer> empresaIds) {
        long total;
        long tardanzas;
        if (empresaIds == null || empresaIds.isEmpty()) {
            total = asistenciaRepository.countByFecha(fecha);
            if (total == 0)
                return 0.0;
            tardanzas = asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThan(fecha, 0L);
        } else {
            total = asistenciaRepository.countByFechaConEmpresas(fecha, empresaIds);
            if (total == 0)
                return 0.0;
            tardanzas = asistenciaRepository.countByFechaAndMinutosTardanzaGreaterThanConEmpresas(fecha, 0L,
                    empresaIds);
        }

        return Math.round((double) (total - tardanzas) / total * 1000.0) / 10.0; // Round to 1 decimal
    }

    public List<com.zonasturisticas.plataforma.dto.AsistenciaDetalleDTO> convertirAsistenciasADetalle(
            List<Asistencia> asistencias) {
        List<com.zonasturisticas.plataforma.dto.AsistenciaDetalleDTO> result = new ArrayList<>();
        for (Asistencia a : asistencias) {
            com.zonasturisticas.plataforma.dto.AsistenciaDetalleDTO dto = new com.zonasturisticas.plataforma.dto.AsistenciaDetalleDTO();
            dto.setId(a.getId());
            dto.setEmpleadoId(a.getEmpleado().getId());
            dto.setEmpleadoNombre(a.getEmpleado().getNombres());
            dto.setEmpleadoApellido(a.getEmpleado().getApellidos());
            dto.setEmpleadoDni(a.getEmpleado().getDni());
            dto.setFecha(a.getFecha().toString());
            dto.setHoraEntrada(a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "");
            dto.setHoraSalida(a.getHoraSalida() != null ? a.getHoraSalida().toString() : "");
            dto.setModo(a.getModo());
            dto.setMinutosTardanza(a.getMinutosTardanza() != null ? a.getMinutosTardanza() : 0);
            if (a.getEmpleado().getSucursal() != null) {
                dto.setSucursalNombre(a.getEmpleado().getSucursal().getNombre());
            }
            result.add(dto);
        }
        return result;
    }

    public List<Asistencia> listarTodo() {
        return asistenciaRepository.findAllByOrderByFechaDescHoraEntradaDesc();
    }

    public List<Asistencia> listarPorEmpleado(int idEmpleado) {
        return asistenciaRepository.findByEmpleadoIdOrderByFechaDesc(idEmpleado);
    }

    public Page<Asistencia> listarAsistenciasPaginado(Pageable pageable, String keyword, Integer sucursalId,
            LocalDate fechaInicio, LocalDate fechaFin) {
        return listarAsistenciasPaginado(pageable, keyword, sucursalId, fechaInicio, fechaFin, null);
    }

    public Page<Asistencia> listarAsistenciasPaginado(Pageable pageable, String keyword, Integer sucursalId,
            LocalDate fechaInicio, LocalDate fechaFin, List<Integer> empresaIds) {
        Specification<Asistencia> spec = crearEspecificacionFiltros(keyword, sucursalId, fechaInicio, fechaFin,
                empresaIds);
        return asistenciaRepository.findAll(spec, pageable);
    }

    public List<Asistencia> listarAsistenciasFiltradas(String keyword, Integer sucursalId, LocalDate fechaInicio,
            LocalDate fechaFin) {
        return listarAsistenciasFiltradas(keyword, sucursalId, fechaInicio, fechaFin, null);
    }

    public List<Asistencia> listarAsistenciasFiltradas(String keyword, Integer sucursalId, LocalDate fechaInicio,
            LocalDate fechaFin, List<Integer> empresaIds) {
        Specification<Asistencia> spec = crearEspecificacionFiltros(keyword, sucursalId, fechaInicio, fechaFin,
                empresaIds);
        // Ensure default sort matches the paginated one: Fecha Desc, HoraEntrada Desc
        Sort sort = Sort.by("fecha").descending().and(Sort.by("horaEntrada").descending());
        return asistenciaRepository.findAll(spec, sort);
    }

    private Specification<Asistencia> crearEspecificacionFiltros(String keyword, Integer sucursalId,
            LocalDate fechaInicio, LocalDate fechaFin, List<Integer> empresaIds) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (sucursalId != null) {
                predicates.add(cb.equal(root.get("empleado").get("sucursal").get("id"), sucursalId));
            }

            if (fechaInicio != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("fecha"), fechaInicio));
            }

            if (fechaFin != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("fecha"), fechaFin));
            }

            if (keyword != null && !keyword.isEmpty()) {
                String likePattern = "%" + keyword.toLowerCase() + "%";
                Predicate nombre = cb.like(cb.lower(root.get("empleado").get("nombres")), likePattern);
                Predicate apellido = cb.like(cb.lower(root.get("empleado").get("apellidos")), likePattern);
                Predicate dni = cb.like(root.get("empleado").get("dni"), likePattern);
                predicates.add(cb.or(nombre, apellido, dni));
            }

            if (empresaIds != null && !empresaIds.isEmpty()) {
                predicates.add(root.get("empleado").get("sucursal").get("empresa").get("id").in(empresaIds));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    public String marcarAsistencia(int idEmpleado, String modo, double lat, double lon, String observacion,
            MultipartFile foto, boolean sospechosa) {
        System.out.println("DEBUG_ASISTENCIA: --- INICIO MARCA ---");
        System.out.println("DEBUG_ASISTENCIA: Empleado ID: " + idEmpleado);
        System.out.println("DEBUG_ASISTENCIA: Hora Servidor: " + java.time.LocalDateTime.now());

        LocalDate hoy = LocalDate.now();
        LocalTime ahora = LocalTime.now();

        // 1. Buscamos el ULTIMO turno ABIERTO (sin hora de salida), sin importar la
        // fecha
        Optional<Asistencia> abierta = asistenciaRepository
                .findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(idEmpleado);

        if (abierta.isPresent()) {
            boolean esTurnoAntiguo = !abierta.get().getFecha().isEqual(hoy);

            System.out.println("DEBUG_ASISTENCIA: Encontrado turno ABIERTO (ID: " + abierta.get().getId() + ", Fecha: "
                    + abierta.get().getFecha() + ")");
            // --- CERRAR TURNO ACTUAL (SALIDA) ---
            Asistencia a = abierta.get();
            a.setHoraSalida(ahora);

            // Si cerramos turno de hoy, guardar en fotoUrlSalida
            if (!esTurnoAntiguo && foto != null) {
                a.setFotoUrlSalida(guardarFoto(foto));
            }

            // --- CÃLCULO DE DESCUENTOS Y BONIFICACIONES ---
            // Recuperamos el Horario Objetivo asociado a la asistencia?
            // Necesitamos saber cual era el horario original para calcular tardanzas/extras
            List<Horario> posibles = horarioRepository.findByEmpleadoIdAndFecha(idEmpleado, a.getFecha());
            Horario horarioTurno = null;
            // Buscamos colisiÃ³n
            for (Horario h : posibles) {
                if (a.getHoraEntrada().isBefore(h.getHoraFin()) &&
                        Duration.between(a.getHoraEntrada(), h.getHoraInicio()).abs().toHours() <= 4) {
                    horarioTurno = h;
                    break;
                }
            }

            if (horarioTurno != null) {
                long minutosTardanza = 0;
                long minutosExtras = 0;

                // 1. Tardanza: Si entrÃ³ despuÃ©s de la hora inicio
                if (a.getHoraEntrada().isAfter(horarioTurno.getHoraInicio())) {
                    minutosTardanza = Duration.between(horarioTurno.getHoraInicio(), a.getHoraEntrada()).toMinutes();
                    // Tolerancia 5 min opcional? No especificado, calculamos directo
                    if (minutosTardanza < 0)
                        minutosTardanza = 0;
                }

                // 2. Extras: Si saliÃ³ despuÃ©s de la hora fin
                if (ahora.isAfter(horarioTurno.getHoraFin())) {
                    minutosExtras = Duration.between(horarioTurno.getHoraFin(), ahora).toMinutes();
                    if (minutosExtras < 0)
                        minutosExtras = 0;
                }

                // --- LÃ“GICA POR TIPO DE MODALIDAD ---
                // LIBRE: No genera descuentos ni bonificaciones, solo registro de horas
                // OBLIGADO / FIJO: Aplica reglas estrictas de horario
                if (a.getEmpleado().getTipoModalidad() != null &&
                        "LIBRE".equalsIgnoreCase(a.getEmpleado().getTipoModalidad())) {
                    minutosTardanza = 0;
                    minutosExtras = 0;
                }

                a.setMinutosTardanza(minutosTardanza);
                a.setMinutosExtras(minutosExtras);

                // Calculo Monetario
                // CostoMinuto = Sueldo / 30 / 8 / 60 = Sueldo / 14400
                // Asumimos 30 dÃ­as, 8 horas.
                Double sueldo = a.getEmpleado().getSueldoBase();
                if (sueldo == null)
                    sueldo = 1025.00; // Default sueldo minimo

                double costoMinuto = sueldo / 30.0 / 8.0 / 60.0;

                // Aplicar descuento solo si está habilitado en configuraciÃ³n
                double descuento = 0.0;
                if (isDescuentoTardanzaEnabled()) {
                    descuento = minutosTardanza * costoMinuto * factorDescuento;
                }

                // Aplicar bonificaciÃ³n solo si horas extras están permitidas
                double bonificacion = 0.0;
                if (isHorasExtrasEnabled()) {
                    bonificacion = minutosExtras * costoMinuto * factorBonificacion;
                }

                // Redondear a 2 decimales
                a.setDineroDescuento(Math.round(descuento * 100.0) / 100.0);
                a.setDineroBonificacion(Math.round(bonificacion * 100.0) / 100.0);
            }

            asistenciaRepository.save(a);
            System.out.println("DEBUG_ASISTENCIA: Turno CERRADO exitosamente. (Antiguo: " + esTurnoAntiguo + ")");

            if (!esTurnoAntiguo) {
                // Si el turno cerrado es de HOY, retornamos SALIDA (flujo normal)
                // Verificamos si hay otro turno próximo inmediatamente para sugerir marcar
                Horario proximo = obtenerproximoTurnoInmediato(idEmpleado, ahora);
                if (proximo != null) {
                    System.out.println("DEBUG_ASISTENCIA: Se detecto proximo turno inmediato (ID: " + proximo.getId() + ")");
                    return "SALIDA_CON_PROXIMO"; // Indicar al controller que pregunte
                }
                return "SALIDA";
            } else {
                // Si el turno cerrado era de DÍAS ANTERIORES, lo dejamos cerrado pero CONTINUAMOS
                // para crear la asistencia de entrada de HOY.
                System.out.println("DEBUG_ASISTENCIA: El turno cerrado era antiguo. Continuando para crear nueva ENTRADA de hoy.");
            }
        }

        System.out.println("DEBUG_ASISTENCIA: No hay turno abierto (o era antiguo). Intentando crear ENTRADA de hoy.");
        // --- ABRIR NUEVO TURNO (ENTRADA) ---

            // 2. Buscamos el horario "objetivo" más cercano que NO haya sido marcado aÃºn
            // Refactor: Usamos la lÃ³gica estricta del reporte para determinar quÃ© turnos
            // están REALMENTE pendientes.
            List<TurnoDTO> reporte = obtenerReporteDiario(idEmpleado);
            Horario horarioObjetivo = null;

            // 2. Buscamos el horario "objetivo" más cercano que NO haya sido marcado aÃºn
            // Refactor: Buscar el el PENDIENTE con inicio más cercano a 'ahora'.
            TurnoDTO candidato = null;
            long minDiff = Long.MAX_VALUE;

            for (TurnoDTO t : reporte) {
                if ("PENDIENTE".equals(t.getEstado())) {
                    long diff = Duration.between(ahora, t.getHorario().getHoraInicio()).abs().toMinutes();
                    if (diff < minDiff) {
                        minDiff = diff;
                        candidato = t;
                    }
                }
            }

            if (candidato != null) {
                horarioObjetivo = candidato.getHorario();
                System.out.println("DEBUG_ASISTENCIA: Horario encontrado (Más cercano): " + horarioObjetivo.getId()
                        + " Diff: " + minDiff + "min");
            }

            // --- NUEVA LÃ“GICA: PERMITIR SIEMPRE MARCAR CON ADVERTENCIAS ---
            Empleado e = empleadoRepository.findById(idEmpleado).orElse(null);
            if (e == null)
                return "ERROR";

            String codigoRetorno = sospechosa ? "ENTRADA_SOSPECHOSA" : "ENTRADA";
            String obsBase = observacion != null ? observacion : "Entrada Regular";

            if (horarioObjetivo == null) {
                System.out.println("DEBUG_ASISTENCIA: No hay turno PENDIENTE válido.");

                // Verificar tipo de modalidad del empleado
                boolean esLibre = "LIBRE".equalsIgnoreCase(e.getTipoModalidad());

                // Obtener todos los turnos de hoy para diagnÃ³stico
                List<Horario> turnosHoy = horarioRepository.findByEmpleadoIdAndFecha(idEmpleado, hoy);

                if (esLibre) {
                    // Empleado LIBRE: puede marcar sin restricciones
                    System.out.println("DEBUG_ASISTENCIA: Empleado LIBRE - permitiendo marca sin horario.");
                    codigoRetorno = "ENTRADA_LIBRE";
                    obsBase = "Entrada (Empleado Libre)";
                } else if (turnosHoy.isEmpty()) {
                    // Sin turnos programados para hoy
                    System.out.println("DEBUG_ASISTENCIA: SIN TURNOS HOY - permitiendo con advertencia.");
                    codigoRetorno = "SIN_TURNO_ADVERTENCIA";
                    obsBase = "âš ï¸ Entrada sin turno programado";
                } else {
                    // Tiene turnos pero todos ya pasaron (FALTA)
                    System.out.println("DEBUG_ASISTENCIA: TURNOS PASADOS - permitiendo con advertencia.");
                    codigoRetorno = "TURNOS_PASADOS";
                    obsBase = "âš ï¸ Entrada tardÃ­a (turnos vencidos)";
                }
            }

            // Crear la asistencia
            Asistencia a = new Asistencia();
            a.setEmpleado(e);
            a.setFecha(hoy);
            a.setHoraEntrada(ahora);
            a.setModo(modo);
            a.setLatitud(lat);
            a.setLongitud(lon);

            // Handle suspicious attendance
            if (sospechosa) {
                a.setSospechosa(true);
                a.setObservacion("âš ï¸ SOSPECHOSA - " + obsBase);
            } else {
                a.setObservacion(obsBase);
            }
            if (foto != null)
                a.setFotoUrl(guardarFoto(foto));
            asistenciaRepository.save(a);
            System.out.println(
                    "DEBUG_ASISTENCIA: Nueva asistencia (" + codigoRetorno + ") guardada.");
            return codigoRetorno;
    }

    private Horario obtenerproximoTurnoInmediato(int idEmpleado, LocalTime ahora) {
        // Busca si hay un horario que empiece pronto (ej. en menos de 1 hora)
        // Usamos obtenerReporteDiario para saber cuales siguen pendientes
        List<TurnoDTO> reporte = obtenerReporteDiario(idEmpleado);

        for (TurnoDTO t : reporte) {
            Horario h = t.getHorario();
            // Solo nos interesan los PENDIENTES
            if ("PENDIENTE".equals(t.getEstado())) {
                if (h.getHoraInicio().isAfter(ahora)) {
                    // Si empieza dentro de los proximos 60 min
                    long minutosParaInicio = Duration.between(ahora, h.getHoraInicio()).toMinutes();
                    if (minutosParaInicio < 60) {
                        return h;
                    }
                }
            }
        }
        return null;
    }

    public Horario obtenerProximoTurno(int idEmpleado) {
        return horarioRepository.findFirstByEmpleadoIdAndFechaAndHoraFinAfterOrderByHoraInicioAsc(idEmpleado,
                LocalDate.now(), LocalTime.now());
    }

    public List<TurnoDTO> obtenerReporteDiario(int empleadoId) {
        LocalDate hoy = LocalDate.now();
        List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(empleadoId, hoy);
        List<Asistencia> asistencias = asistenciaRepository.findByEmpleadoIdAndFecha(empleadoId, hoy);
        List<TurnoDTO> reporte = new ArrayList<>();

        horarios.sort(Comparator.comparing(Horario::getHoraInicio));

        // --- ALGORITMO BEST-MATCH (MEJOR AJUSTE) ---
        // Asigna asistencias por orden temporal a la primera ventana de turno valida.
        // Ventana de un turno: [horaInicio - 4h, horaFin].
        // Esto evita que una marca cercana al inicio del siguiente turno "robe"
        // una marca que en realidad pertenece al turno anterior consecutivo.
        java.util.Map<Integer, Asistencia> assignments = new java.util.HashMap<>();
        java.util.Set<Integer> usedHorarios = new java.util.HashSet<>();

        asistencias.sort(Comparator.comparing(Asistencia::getHoraEntrada));

        for (Asistencia a : asistencias) {
            Horario horarioElegido = null;

            for (Horario h : horarios) {
                if (usedHorarios.contains(h.getId())) {
                    continue;
                }

                LocalTime inicioVentana = h.getHoraInicio().minusHours(4);
                boolean dentroVentana = !a.getHoraEntrada().isBefore(inicioVentana)
                        && !a.getHoraEntrada().isAfter(h.getHoraFin());

                if (dentroVentana) {
                    horarioElegido = h;
                    break;
                }
            }

            if (horarioElegido != null) {
                assignments.put(horarioElegido.getId(), a);
                usedHorarios.add(horarioElegido.getId());
            }
        }

        for (Horario h : horarios) {
            Asistencia asistenciaEncontrada = assignments.get(h.getId());

            String estado = "PENDIENTE";
            String mensaje = "Pendiente";
            String css = "status-pending";

            if (asistenciaEncontrada != null) {
                long diffMinutos = Duration.between(h.getHoraInicio(), asistenciaEncontrada.getHoraEntrada())
                        .toMinutes();
                int tolerancia = getToleranciaMinutos();

                if ("JUSTIFICACION".equals(asistenciaEncontrada.getModo())) {
                    estado = "JUSTIFICADA";
                    mensaje = "Falta Justificada";
                    css = "status-ontime";
                } else if (diffMinutos < -tolerancia) {
                    estado = "ASISTIDO";
                    mensaje = "Ingreso Temprano";
                    css = "status-early";
                } else if (diffMinutos >= -tolerancia && diffMinutos <= tolerancia) {
                    estado = "ASISTIDO";
                    mensaje = "Puntual";
                    css = "status-ontime";
                } else {
                    estado = "ASISTIDO";
                    mensaje = "Tardanza";
                    css = "status-late";
                }
            } else {
                int tolerancia = getToleranciaMinutos();
                if (LocalTime.now().isAfter(h.getHoraInicio().plusMinutes(tolerancia))) {
                    if (LocalTime.now().isAfter(h.getHoraFin())) {
                        estado = "FALTA";
                        mensaje = "No Marcado";
                        css = "status-missed";
                    } else {
                        estado = "PENDIENTE";
                        mensaje = "Retrasado";
                        css = "status-warning";
                    }
                }
            }
            reporte.add(new TurnoDTO(h, asistenciaEncontrada, estado, mensaje, css));
        }
        return reporte;
    }

    // --- LÃ³gica de Fin de Jornada ---
    public boolean verificarFinJornada(int empleadoId) {
        // 1. Si hay turno abierto (entrada sin salida), NO ha terminado jornada (debe
        // marcar salida).
        boolean turnoAbierto = asistenciaRepository.findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(empleadoId)
                .isPresent();
        if (turnoAbierto)
            return false;

        // 2. Reutilizamos la lÃ³gica de "Reporte Diario" para ver el estado REAL de
        // cada
        // horario
        // Esto evita el bug donde verificarFinJornada usaba un matching "laxo" y creÃ­a
        // que
        // un turno nuevo ya estaba cubierto por una asistencia antigua cercana.
        List<TurnoDTO> turnos = obtenerReporteDiario(empleadoId);

        for (TurnoDTO t : turnos) {
            // Si hay algun turno PENDIENTE, significa que aun se puede marcar entrada
            if ("PENDIENTE".equals(t.getEstado())) {
                return false;
            }
        }

        // Si no hay pendientes (solo ASISTIDO o FALTA), entonces sÃ­ terminÃ³ jornada
        return true;
    }

    // --- Manejo de Fotos ---
    public String guardarFoto(MultipartFile foto) {
        if (foto == null || foto.isEmpty())
            return null;
        try {
            String folder = "uploads/evidencias/";
            java.io.File directory = new java.io.File(folder);
            if (!directory.exists())
                directory.mkdirs();

            String filename = System.currentTimeMillis() + "_" + foto.getOriginalFilename();
            Path path = Paths.get(folder + filename);
            Files.write(path, foto.getBytes());

            return "uploads/evidencias/" + filename;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String procesarQrDinamico(int idEmpleado, String tokenQrRecibido, MultipartFile foto) {

        String fechaHoy = LocalDate.now().toString();
        String tokenEsperado = "GRUPO_PERUANA_" + fechaHoy;

        if (!tokenEsperado.equals(tokenQrRecibido)) {
            return "ERROR: El cÃ³digo QR ha caducado o no es válido.";
        }

        // QR ahora permite multiples marcas, igual que GPS
        // Reusamos lÃ³gica similar pero simplificada para QR

        // 1. Check abierto GLOBAL
        Optional<Asistencia> abierta = asistenciaRepository
                .findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(idEmpleado);

        if (abierta.isPresent()) {
            boolean esTurnoAntiguo = !abierta.get().getFecha().isEqual(LocalDate.now());

            Asistencia a = abierta.get();
            a.setHoraSalida(LocalTime.now());
            if (!esTurnoAntiguo && foto != null) {
                a.setFotoUrlSalida(guardarFoto(foto));
            }
            asistenciaRepository.save(a);

            if (!esTurnoAntiguo) {
                // Check proximo (copia logica GPS)
                if (obtenerproximoTurnoInmediato(idEmpleado, LocalTime.now()) != null)
                    return "EXITO_CON_PROXIMO";

                return "EXITO_SALIDA";
            }
        }

        // 2. Check entrada (busca turno)
        // ... (SimplificaciÃ³n: QR asume entrada regular si no hay abierto)
        // DeberÃ­amos validar si hay turno disponible igual que en GPS

        if (verificarFinJornada(idEmpleado))
            return "ERROR: Jornada finalizada o sin turnos.";

        Asistencia asistencia = new Asistencia();
        Empleado empleado = empleadoRepository.findById(idEmpleado).orElse(null);
        if (empleado == null)
            return "ERROR: Empleado no encontrado.";

        asistencia.setEmpleado(empleado);
        asistencia.setFecha(LocalDate.now());
        asistencia.setHoraEntrada(LocalTime.now());
        asistencia.setModo("QR_DINAMICO");
        asistencia.setObservacion("Ingreso QR");
        if (foto != null)
            asistencia.setFotoUrl(guardarFoto(foto));

        asistenciaRepository.save(asistencia);

        return "EXITO";
    }

    public void aplicarJustificacion(Justificacion j) {
        System.out.println("DEBUG_JUSTIFICACION: --- APLICANDO JUSTIFICACION ---");
        System.out.println("DEBUG_JUSTIFICACION: Justificacion ID: " + j);
        System.out.println("DEBUG_JUSTIFICACION: Empleado ID: " + j.getEmpleado().getId());
        System.out.println("DEBUG_JUSTIFICACION: Rango: " + j.getFechaInicio() + " - " + j.getFechaFin());

        LocalDate start = j.getFechaInicio();
        LocalDate end = j.getFechaFin();

        // Loop through dates
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            System.out.println("DEBUG_JUSTIFICACION: Procesando fecha: " + date);
            try {
                List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(j.getEmpleado().getId(), date);
                System.out.println("DEBUG_JUSTIFICACION: Horarios encontrados: " + horarios.size());

                List<Asistencia> asistenciasExistentes = asistenciaRepository
                        .findByEmpleadoIdAndFecha(j.getEmpleado().getId(), date);
                System.out.println("DEBUG_JUSTIFICACION: Asistencias existentes: " + asistenciasExistentes.size());

                // --- ALGORITMO MATCHING (SIMPLIFICADO) ---
                // Mapeamos Horario -> Asistencia para asegurar 1-a-1
                java.util.Map<Integer, Asistencia> mapaAsistencia = new java.util.HashMap<>();
                java.util.Set<Integer> asistenciasUsadas = new java.util.HashSet<>();

                // 1. Encontramos mejor candidato para cada asistencia
                // (Reusamos logica de reporte para consistencia)
                for (Horario h : horarios) {
                    Asistencia mejorCandidato = null;
                    long menorDiff = Long.MAX_VALUE;

                    for (Asistencia a : asistenciasExistentes) {
                        if (asistenciasUsadas.contains(a.getId()))
                            continue;

                        // Check null safety
                        if (h.getHoraInicio() == null || a.getHoraEntrada() == null)
                            continue;

                        long diff = Duration.between(h.getHoraInicio(), a.getHoraEntrada()).abs().toMinutes();
                        if (diff < 120 && diff < menorDiff) {
                            menorDiff = diff;
                            mejorCandidato = a;
                        }
                    }

                    if (mejorCandidato != null) {
                        System.out.println("DEBUG_JUSTIFICACION: Match Horario(" + h.getId() + ") -> Asistencia("
                                + mejorCandidato.getId() + ")");
                        mapaAsistencia.put(h.getId(), mejorCandidato);
                        asistenciasUsadas.add(mejorCandidato.getId());
                    }
                }

                for (Horario h : horarios) {
                    System.out.println("DEBUG_JUSTIFICACION: Aplicando a Horario ID: " + h.getId());
                    // RELAXED RULE: If there is a justification for the day, IT APPLIES TO ALL
                    // SHIFTS.
                    boolean match = true;

                    if (match) {
                        Asistencia target = mapaAsistencia.get(h.getId());

                        if (target == null) {
                            System.out
                                    .println("DEBUG_JUSTIFICACION: Creando NUEVA Asistencia para Horario " + h.getId());
                            target = new Asistencia();
                            target.setEmpleado(j.getEmpleado());
                            target.setFecha(date);
                            // Add to map to prevent re-creation or confusion in subsequent logic if we were
                            // to loop again
                            mapaAsistencia.put(h.getId(), target);
                        } else {
                            System.out.println("DEBUG_JUSTIFICACION: Actualizando Asistencia " + target.getId());
                        }

                        // Update fields
                        target.setModo("JUSTIFICACION");
                        target.setHoraEntrada(h.getHoraInicio());
                        target.setHoraSalida(h.getHoraFin()); // Set exit time too to close it
                        target.setObservacion("Falta Justificada: " + j.getMotivo());
                        target.setDineroDescuento(0.0);
                        target.setDineroBonificacion(0.0);
                        target.setMinutosTardanza(0L);
                        target.setMinutosExtras(0L);

                        asistenciaRepository.save(target);
                        System.out.println("DEBUG_JUSTIFICACION: Guardado Exitoso.");
                    }
                }
            } catch (Exception e) {
                System.err.println("ERROR_JUSTIFICACION: Error procesando fecha " + date);
                e.printStackTrace();
            }
        }
    }

}
