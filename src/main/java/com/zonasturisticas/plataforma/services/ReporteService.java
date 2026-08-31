package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Asistencia;
import com.zonasturisticas.plataforma.beans.Empleado;
import com.zonasturisticas.plataforma.beans.Horario;
import com.zonasturisticas.plataforma.dto.ReporteAsistenciaDTO;
import com.zonasturisticas.plataforma.repositories.AsistenciaRepository;
import com.zonasturisticas.plataforma.repositories.HorarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

@Service
public class ReporteService {

    @Autowired
    private AsistenciaRepository asistenciaRepository;

    @Autowired
    private HorarioRepository horarioRepository;

    @Autowired
    private FeriadoService feriadoService;

    @Autowired
    private EmpleadoService empleadoService;

    public List<ReporteAsistenciaDTO> generarReporte(LocalDate inicio, LocalDate fin, Integer empleadoId,
            Integer sucursalId, String sort) {
        return generarReporte(inicio, fin, empleadoId, sucursalId, sort, null);
    }

    public List<ReporteAsistenciaDTO> generarReporte(LocalDate inicio, LocalDate fin, Integer empleadoId,
            Integer sucursalId, String sort, List<Integer> empresaIds) {
        List<ReporteAsistenciaDTO> reporte = new ArrayList<>();

        List<Empleado> empleados;
        if (empleadoId != null && empleadoId > 0) {
            Empleado emp = empleadoService.obtenerPorId(empleadoId);
            // Verify if admin has access to this employee's company
            if (emp != null) {
                if (empresaIds == null || empresaIds.isEmpty()
                        || empresaIds.contains(emp.getSucursal().getEmpresa().getId())) {
                    empleados = List.of(emp);
                } else {
                    empleados = new ArrayList<>();
                }
            } else {
                empleados = new ArrayList<>();
            }
        } else {
            // Filter list of employees by company if IDs provided
            if (empresaIds != null && !empresaIds.isEmpty()) {
                empleados = empleadoService.listarAvanzadoSinPaginacion("", null, null, null, empresaIds);
            } else {
                empleados = empleadoService.listarEmpleados();
            }
        }

        // 1. Filtrar por Sucursal si se solicita
        if (sucursalId != null && sucursalId > 0) {
            empleados = empleados.stream()
                    .filter(e -> e.getSucursal() != null && e.getSucursal().getId() == sucursalId)
                    .toList();
        }

        List<Horario> todosHorarios;
        List<Asistencia> todasAsistencias;

        // Optimization: Fetch only needed data?
        // For simplicity and correctness with "no-show" logic, we fetch range for all
        // (or specific emp)
        // Ideally we should filter DB side, but for now filtering locally as per
        // current design
        if (empresaIds != null && !empresaIds.isEmpty()) {
            todosHorarios = horarioRepository.findByFechaBetweenConEmpresas(inicio, fin, empresaIds);
            todasAsistencias = asistenciaRepository.findByFechaBetweenConEmpresas(inicio, fin, empresaIds);
        } else {
            todosHorarios = horarioRepository.findByFechaBetween(inicio, fin);
            todasAsistencias = asistenciaRepository.findByFechaBetweenOrderByFechaAsc(inicio, fin);
        }

        // Map data for quick access
        Map<Integer, Map<LocalDate, List<Horario>>> mapaHorarios = new HashMap<>();
        for (Horario h : todosHorarios) {
            mapaHorarios.computeIfAbsent(h.getEmpleado().getId(), k -> new HashMap<>())
                    .computeIfAbsent(h.getFecha(), k -> new ArrayList<>()).add(h);
        }

        Map<Integer, Map<LocalDate, List<Asistencia>>> mapaAsistencias = new HashMap<>();
        for (Asistencia a : todasAsistencias) {
            mapaAsistencias.computeIfAbsent(a.getEmpleado().getId(), k -> new HashMap<>())
                    .computeIfAbsent(a.getFecha(), k -> new ArrayList<>()).add(a);
        }

        for (Empleado emp : empleados) {
            for (LocalDate date = inicio; !date.isAfter(fin); date = date.plusDays(1)) {
                boolean esFeriado = feriadoService.esFeriado(date, empresaIds);

                List<Horario> horarios = mapaHorarios.getOrDefault(emp.getId(), new HashMap<>()).getOrDefault(date,
                        new ArrayList<>());
                List<Asistencia> asistencias = mapaAsistencias.getOrDefault(emp.getId(), new HashMap<>())
                        .getOrDefault(date, new ArrayList<>());

                if (horarios.isEmpty() && asistencias.isEmpty() && !esFeriado) {
                    continue; // Nada que reportar si no es feriado y no hay actividad
                }

                // Si es feriado o hay actividad, reportamos
                ReporteAsistenciaDTO dto = new ReporteAsistenciaDTO();
                dto.setFecha(date);
                dto.setNombreEmpleado(emp.getNombreCompleto());
                dto.setDniEmpleado(emp.getDni());
                dto.setSucursal(emp.getSucursal() != null ? emp.getSucursal().getNombre() : "Sin Sucursal");

                if (esFeriado) {
                    dto.setObservacion("Feriado");
                    dto.setEstado("FERIADO");
                }

                // Calcular horas programadas
                double scheduledHours = 0;
                if (!horarios.isEmpty()) {
                    Horario h = horarios.get(0);
                    dto.setHorarioEntrada(h.getHoraInicio());
                    dto.setHorarioSalida(h.getHoraFin());

                    for (Horario hor : horarios) {
                        scheduledHours += Duration.between(hor.getHoraInicio(), hor.getHoraFin()).toMinutes() / 60.0;
                    }
                    if (!esFeriado)
                        dto.setEstado("FALTA"); // Default
                }
                dto.setHorasProgramadas(Math.round(scheduledHours * 100.0) / 100.0);

                // Calcular horas trabajadas
                double workedHours = 0;
                if (!asistencias.isEmpty()) {
                    Asistencia a = asistencias.get(0);
                    Asistencia ult = asistencias.get(asistencias.size() - 1);

                    dto.setAsistenciaEntrada(a.getHoraEntrada());
                    dto.setFotoUrl(a.getFotoUrl()); // Set entry photo

                    dto.setAsistenciaSalida(ult.getHoraSalida());
                    dto.setFotoUrlSalida(ult.getFotoUrlSalida()); // Set exit photo

                    for (Asistencia asis : asistencias) {
                        if (asis.getHoraEntrada() != null && asis.getHoraSalida() != null) {
                            workedHours += Duration.between(asis.getHoraEntrada(), asis.getHoraSalida()).toMinutes()
                                    / 60.0;
                        }
                    }

                    if (esFeriado) {
                        dto.setEstado("FERIADO LABORADO");
                    } else if (scheduledHours > 0) {
                        // Check tardanza logic simple
                        if (horarios.size() > 0 && a.getHoraEntrada() != null
                                && a.getHoraEntrada().isAfter(horarios.get(0).getHoraInicio().plusMinutes(5))) {
                            dto.setEstado("TARDANZA");
                        } else {
                            dto.setEstado("ASISTIO");
                        }
                    } else {
                        dto.setEstado("EXTRA"); // Vino sin horario
                    }
                }

                dto.setHorasTrabajadas(Math.round(workedHours * 100.0) / 100.0);

                // Calcular totales de tiempo y dinero
                int totalTardanza = 0;
                int totalExtras = 0;
                double totalDescuento = 0;
                double totalBonificacion = 0;
                java.util.Set<String> modos = new java.util.HashSet<>();

                for (Asistencia asis : asistencias) {
                    if (asis.getMinutosTardanza() != null)
                        totalTardanza += asis.getMinutosTardanza();
                    if (asis.getMinutosExtras() != null)
                        totalExtras += asis.getMinutosExtras();
                    if (asis.getDineroDescuento() != null)
                        totalDescuento += asis.getDineroDescuento();
                    if (asis.getDineroBonificacion() != null)
                        totalBonificacion += asis.getDineroBonificacion();
                    if (asis.getModo() != null)
                        modos.add(asis.getModo());
                }

                dto.setMinutosTardanza(totalTardanza);
                dto.setMinutosExtras(totalExtras);
                dto.setDineroDescuento(Math.round(totalDescuento * 100.0) / 100.0);
                dto.setDineroBonificacion(Math.round(totalBonificacion * 100.0) / 100.0);

                if (modos.isEmpty())
                    dto.setModo("-");
                else if (modos.size() == 1)
                    dto.setModo(modos.iterator().next());
                else
                    dto.setModo("MIXTO");

                double diff = workedHours - scheduledHours;

                if (esFeriado) {
                    if (workedHours > 0)
                        diff = workedHours;
                    else
                        diff = 0;
                }

                dto.setDiferenciaHoras(Math.round(diff * 100.0) / 100.0);

                reporte.add(dto);
            }
        }

        // Ordenamiento
        if (sort != null && !sort.isEmpty()) {
            switch (sort) {
                case "fecha_asc":
                    reporte.sort(Comparator.comparing(ReporteAsistenciaDTO::getFecha));
                    break;
                case "fecha_desc":
                    reporte.sort(Comparator.comparing(ReporteAsistenciaDTO::getFecha).reversed());
                    break;
                case "nombre_asc":
                    reporte.sort(Comparator.comparing(ReporteAsistenciaDTO::getNombreEmpleado));
                    break;
                case "tardanza_desc":
                    reporte.sort(Comparator.comparingInt(ReporteAsistenciaDTO::getMinutosTardanza).reversed());
                    break;
                default:
                    reporte.sort(Comparator.comparing(ReporteAsistenciaDTO::getFecha).reversed());
            }
        } else {
            // Default sort
            reporte.sort(Comparator.comparing(ReporteAsistenciaDTO::getFecha).reversed());
        }

        return reporte;
    }

    public ByteArrayInputStream generarReporteExcel(List<ReporteAsistenciaDTO> reporte) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Reporte de Asistencias");

            // Header
            // Header
            Row headerRow = sheet.createRow(0);
            String[] columns = { "Fecha", "Empleado", "DNI", "Sucursal", "Entrada P.", "Salida P.", "Entrada R.",
                    "Salida R.", "Horas P.", "Horas R.", "Diferencia", "Tardanza (min)", "Extras (min)", "Descuento",
                    "Bonif.", "Modo", "Estado" };
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
            }

            // Data
            int rowIdx = 1;
            for (ReporteAsistenciaDTO dato : reporte) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(dato.getFecha().toString());
                row.createCell(1).setCellValue(dato.getNombreEmpleado());
                row.createCell(2).setCellValue(dato.getDniEmpleado());
                row.createCell(3).setCellValue(dato.getSucursal());

                row.createCell(4)
                        .setCellValue(dato.getHorarioEntrada() != null ? dato.getHorarioEntrada().toString() : "");
                row.createCell(5)
                        .setCellValue(dato.getHorarioSalida() != null ? dato.getHorarioSalida().toString() : "");

                row.createCell(6).setCellValue(
                        dato.getAsistenciaEntrada() != null ? dato.getAsistenciaEntrada().toString() : "");
                row.createCell(7)
                        .setCellValue(dato.getAsistenciaSalida() != null ? dato.getAsistenciaSalida().toString() : "");

                row.createCell(8).setCellValue(dato.getHorasProgramadas());
                row.createCell(9).setCellValue(dato.getHorasTrabajadas());
                row.createCell(10).setCellValue(dato.getDiferenciaHoras());

                row.createCell(11).setCellValue(dato.getMinutosTardanza());
                row.createCell(12).setCellValue(dato.getMinutosExtras());
                row.createCell(13).setCellValue(dato.getDineroDescuento());
                row.createCell(14).setCellValue(dato.getDineroBonificacion());
                row.createCell(15).setCellValue(dato.getModo());

                row.createCell(16).setCellValue(dato.getEstado());
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        } catch (IOException e) {
            throw new RuntimeException("Error al generar Excel: " + e.getMessage());
        }
    }

    public ByteArrayInputStream generarReportePDF(List<ReporteAsistenciaDTO> reporte) {
        Document document = new Document();
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            // Font
            Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            Font fontBody = FontFactory.getFont(FontFactory.HELVETICA, 10);

            // Title
            Paragraph title = new Paragraph("Reporte de Asistencia",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18));
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(new Paragraph("\n"));

            // Table
            PdfPTable table = new PdfPTable(17); // Aumentar columnas
            table.setWidthPercentage(100);

            // Ajustar anchos relativos si es necesario, o dejar auto
            float[] widths = { 2f, 4f, 2f, 2f, 2f, 2f, 2f, 2f, 1.5f, 1.5f, 1.5f, 1.5f, 1.5f, 2f, 2f, 2f, 2f };
            try {
                table.setWidths(widths);
            } catch (Exception e) {
            } // Ignorar si falla

            String[] headers = { "Fech", "Emp", "DNI", "Suc", "E.P", "S.P", "E.R", "S.R", "HP",
                    "HR", "Dif", "Tar", "Ext", "Desc", "Bon", "Mod", "Est" };
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, fontHeader));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(cell);
            }

            for (ReporteAsistenciaDTO dato : reporte) {
                table.addCell(new Phrase(dato.getFecha().toString(), fontBody));
                table.addCell(new Phrase(dato.getNombreEmpleado(), fontBody));
                table.addCell(new Phrase(dato.getDniEmpleado(), fontBody));
                table.addCell(new Phrase(dato.getSucursal(), fontBody));

                table.addCell(new Phrase(dato.getHorarioEntrada() != null ? dato.getHorarioEntrada().toString() : "",
                        fontBody));
                table.addCell(new Phrase(dato.getHorarioSalida() != null ? dato.getHorarioSalida().toString() : "",
                        fontBody));

                table.addCell(new Phrase(
                        dato.getAsistenciaEntrada() != null ? dato.getAsistenciaEntrada().toString() : "", fontBody));
                table.addCell(new Phrase(
                        dato.getAsistenciaSalida() != null ? dato.getAsistenciaSalida().toString() : "", fontBody));

                table.addCell(new Phrase(String.valueOf(dato.getHorasProgramadas()), fontBody));
                table.addCell(new Phrase(String.valueOf(dato.getHorasTrabajadas()), fontBody));
                table.addCell(new Phrase(String.valueOf(dato.getDiferenciaHoras()), fontBody));

                table.addCell(new Phrase(String.valueOf(dato.getMinutosTardanza()), fontBody));
                table.addCell(new Phrase(String.valueOf(dato.getMinutosExtras()), fontBody));
                table.addCell(new Phrase(String.format("%.2f", dato.getDineroDescuento()), fontBody));
                table.addCell(new Phrase(String.format("%.2f", dato.getDineroBonificacion()), fontBody));
                table.addCell(new Phrase(dato.getModo(), fontBody));

                table.addCell(new Phrase(dato.getEstado(), fontBody));
            }

            document.add(table);
            document.close();

        } catch (DocumentException e) {
            throw new RuntimeException("Error al generar PDF: " + e.getMessage());
        }

        return new ByteArrayInputStream(out.toByteArray());
    }

    public ByteArrayInputStream generarListadoExcel(List<Asistencia> asistencias) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Listado de Asistencias");

            // Header
            Row headerRow = sheet.createRow(0);
            String[] columns = { "ID", "Empleado", "DNI", "Fecha", "Hora Entrada", "Hora Salida", "Modo", "Observacion",
                    "Foto Entrada", "Foto Salida" };
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
            }

            // Data
            int rowIdx = 1;
            for (Asistencia a : asistencias) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(a.getId());
                row.createCell(1).setCellValue(a.getEmpleado().getNombreCompleto());
                row.createCell(2).setCellValue(a.getEmpleado().getDni());
                row.createCell(3).setCellValue(a.getFecha().toString());
                row.createCell(4).setCellValue(a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "");
                row.createCell(5).setCellValue(a.getHoraSalida() != null ? a.getHoraSalida().toString() : "");
                row.createCell(6).setCellValue(a.getModo());
                row.createCell(7).setCellValue(a.getObservacion());
                row.createCell(8).setCellValue(a.getFotoUrl() != null ? a.getFotoUrl() : "");
                row.createCell(9).setCellValue(a.getFotoUrlSalida() != null ? a.getFotoUrlSalida() : "");
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        } catch (IOException e) {
            throw new RuntimeException("Error al generar Excel: " + e.getMessage());
        }
    }

    public ByteArrayInputStream generarListadoPDF(List<Asistencia> asistencias) {
        Document document = new Document();
        ByteArrayOutputStream out = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            Font fontBody = FontFactory.getFont(FontFactory.HELVETICA, 10);

            Paragraph title = new Paragraph("Listado de Asistencias",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18));
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(new Paragraph("\n"));

            PdfPTable table = new PdfPTable(8); // Reduced columns for PDF
            table.setWidthPercentage(100);

            String[] headers = { "ID", "Emp.", "Fecha", "Entrada", "Salida", "Modo", "Obs", "Fotos" };
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, fontHeader));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(cell);
            }

            for (Asistencia a : asistencias) {
                table.addCell(new Phrase(String.valueOf(a.getId()), fontBody));
                table.addCell(new Phrase(a.getEmpleado().getNombreCompleto(), fontBody));
                table.addCell(new Phrase(a.getFecha().toString(), fontBody));
                table.addCell(new Phrase(a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "", fontBody));
                table.addCell(new Phrase(a.getHoraSalida() != null ? a.getHoraSalida().toString() : "", fontBody));
                table.addCell(new Phrase(a.getModo(), fontBody));
                table.addCell(new Phrase(a.getObservacion(), fontBody));

                String fotos = (a.getFotoUrl() != null ? "Ent: SI " : "")
                        + (a.getFotoUrlSalida() != null ? "Sal: SI" : "");
                table.addCell(new Phrase(fotos, fontBody));
            }

            document.add(table);
            document.close();

        } catch (DocumentException e) {
            throw new RuntimeException("Error al generar PDF: " + e.getMessage());
        }

        return new ByteArrayInputStream(out.toByteArray());
    }
}
