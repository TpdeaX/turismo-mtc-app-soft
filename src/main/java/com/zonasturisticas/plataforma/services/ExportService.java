package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Justificacion;
import com.zonasturisticas.plataforma.beans.Empleado;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.util.IOUtils;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ExportService {

    public byte[] generateJustificacionesExcel(List<Justificacion> justificaciones) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Justificaciones");

            // Styles
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setAlignment(HorizontalAlignment.LEFT);

            // Add Logo
            try (InputStream is = getClass().getResourceAsStream("/static/img/logo-peruana.png")) {
                if (is != null) {
                    byte[] bytes = IOUtils.toByteArray(is);

                    // Create rows 0-3 for logo and set height to match ~3.5cm total (4 * 25pt =
                    // 100pt)
                    for (int i = 0; i < 4; i++) {
                        Row row = sheet.getRow(i);
                        if (row == null)
                            row = sheet.createRow(i);
                        row.setHeightInPoints(25);
                    }

                    int pictureIdx = workbook.addPicture(bytes, Workbook.PICTURE_TYPE_PNG);
                    Drawing<?> drawing = sheet.createDrawingPatriarch();
                    ClientAnchor anchor = workbook.getCreationHelper().createClientAnchor();
                    anchor.setCol1(0);
                    anchor.setRow1(0);
                    anchor.setCol2(3);
                    anchor.setRow2(4); // Spans rows 0, 1, 2, 3

                    drawing.createPicture(anchor, pictureIdx); // Create picture, anchor handles size
                }
            } catch (Exception e) {
                System.err.println("Error loading logo for Excel: " + e.getMessage());
            }

            // Title Row - moved to row 5 (index 5)
            Row titleRow = sheet.getRow(5);
            if (titleRow == null)
                titleRow = sheet.createRow(5);

            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Reporte de Justificaciones");
            CellStyle titleStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 16);
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(5, 5, 0, 7));

            // Header Row - moved to row 7 (index 7)
            int rowIdx = 7;
            Row headerRow = sheet.createRow(rowIdx++);
            String[] headers = { "ID", "Empleado", "Fecha Solicitud", "Tipo", "Fechas", "Horas", "Motivo", "Estado" };
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

            for (Justificacion just : justificaciones) {
                Row row = sheet.createRow(rowIdx++);

                createCell(row, 0, String.valueOf(just.getId()), dataStyle);
                createCell(row, 1, just.getEmpleado().getNombres() + " " + just.getEmpleado().getApellidos(),
                        dataStyle);
                createCell(row, 2, just.getFechaSolicitud().format(dateFormatter), dataStyle);
                createCell(row, 3, just.isEsPorHoras() ? "Por Horas" : "Por Días", dataStyle);

                String fechas = just.getFechaInicio().format(dateFormatter);
                if (!just.getFechaInicio().equals(just.getFechaFin())) {
                    fechas += " - " + just.getFechaFin().format(dateFormatter);
                }
                createCell(row, 4, fechas, dataStyle);

                String horas = "-";
                if (just.isEsPorHoras() && just.getHoraInicio() != null && just.getHoraFin() != null) {
                    horas = just.getHoraInicio().format(timeFormatter) + " - "
                            + just.getHoraFin().format(timeFormatter);
                }
                createCell(row, 5, horas, dataStyle);

                createCell(row, 6, just.getMotivo(), dataStyle);
                createCell(row, 7, just.getEstado(), dataStyle);
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    private void createCell(Row row, int column, String value, CellStyle style) {
        Cell cell = row.createCell(column);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    public byte[] generateJustificacionesPdf(List<Justificacion> justificaciones) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, out);
            document.open();

            // Logo
            try (InputStream is = getClass().getResourceAsStream("/static/img/logo-peruana.png")) {
                if (is != null) {
                    byte[] bytes = IOUtils.toByteArray(is);
                    Image logo = Image.getInstance(bytes);
                    // 1 cm = ~28.35 points.
                    // H: 3.12 cm * 28.35 = 88.45 points
                    // W: 4.58 cm * 28.35 = 129.84 points
                    logo.scaleAbsolute(129.84f, 88.45f);
                    logo.setAlignment(Element.ALIGN_LEFT);
                    document.add(logo);
                }
            } catch (Exception e) {
                System.err.println("Error loading logo for PDF: " + e.getMessage());
            }

            // Spacing - Increased to avoid overlap
            document.add(new Paragraph("\n\n"));

            // Title
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, Color.DARK_GRAY);
            Paragraph title = new Paragraph("Reporte de Justificaciones", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            // Table
            PdfPTable table = new PdfPTable(8);
            table.setWidthPercentage(100);
            table.setWidths(new float[] { 1, 3, 2, 2, 3, 2, 4, 2 });

            // Header
            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.WHITE);
            String[] headers = { "ID", "Empleado", "Solicitado", "Tipo", "Fechas", "Horas", "Motivo", "Estado" };

            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
                cell.setBackgroundColor(new Color(0, 51, 102)); // Dark Blue
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(5);
                table.addCell(cell);
            }

            // Data
            Font dataFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

            boolean alternate = false;
            Color lightGray = new Color(240, 240, 240);

            for (Justificacion just : justificaciones) {
                addCell(table, String.valueOf(just.getId()), dataFont, alternate, lightGray);
                addCell(table, just.getEmpleado().getNombres() + " " + just.getEmpleado().getApellidos(), dataFont,
                        alternate, lightGray);
                addCell(table, just.getFechaSolicitud().format(dateFormatter), dataFont, alternate, lightGray);
                addCell(table, just.isEsPorHoras() ? "Por Horas" : "Por Días", dataFont, alternate, lightGray);

                String fechas = just.getFechaInicio().format(dateFormatter);
                if (!just.getFechaInicio().equals(just.getFechaFin())) {
                    fechas += "\n" + just.getFechaFin().format(dateFormatter);
                }
                addCell(table, fechas, dataFont, alternate, lightGray);

                String horas = "-";
                if (just.isEsPorHoras() && just.getHoraInicio() != null && just.getHoraFin() != null) {
                    horas = just.getHoraInicio().format(timeFormatter) + " - "
                            + just.getHoraFin().format(timeFormatter);
                }
                addCell(table, horas, dataFont, alternate, lightGray);

                addCell(table, just.getMotivo(), dataFont, alternate, lightGray);
                addCell(table, just.getEstado(), dataFont, alternate, lightGray);

                alternate = !alternate;
            }

            document.add(table);

            // Footer
            Paragraph footer = new Paragraph(
                    "Generado el: "
                            + java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")),
                    FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 8));
            footer.setAlignment(Element.ALIGN_RIGHT);
            footer.setSpacingBefore(10);
            document.add(footer);

            document.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating PDF", e);
        }
    }

    public byte[] generateEmpleadosExcel(List<Empleado> empleados) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Empleados");

            // Styles
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setAlignment(HorizontalAlignment.LEFT);

            // Add Logo
            try (InputStream is = getClass().getResourceAsStream("/static/img/logo-peruana.png")) {
                if (is != null) {
                    byte[] bytes = IOUtils.toByteArray(is);
                    for (int i = 0; i < 4; i++) {
                        Row row = sheet.getRow(i);
                        if (row == null)
                            row = sheet.createRow(i);
                        row.setHeightInPoints(25);
                    }
                    int pictureIdx = workbook.addPicture(bytes, Workbook.PICTURE_TYPE_PNG);
                    Drawing<?> drawing = sheet.createDrawingPatriarch();
                    ClientAnchor anchor = workbook.getCreationHelper().createClientAnchor();
                    anchor.setCol1(0);
                    anchor.setRow1(0);
                    anchor.setCol2(3);
                    anchor.setRow2(4);
                    drawing.createPicture(anchor, pictureIdx);
                }
            } catch (Exception e) {
                System.err.println("Error loading logo: " + e.getMessage());
            }

            // Title Row
            Row titleRow = sheet.getRow(5);
            if (titleRow == null)
                titleRow = sheet.createRow(5);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Reporte de Personal");

            CellStyle titleStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 16);
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(5, 5, 0, 6));

            // Header
            int rowIdx = 7;
            Row headerRow = sheet.createRow(rowIdx++);
            String[] headers = { "ID", "Apellidos y Nombres", "DNI", "Rol", "Modalidad", "Sucursal", "Sueldo Base" };
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data
            for (Empleado e : empleados) {
                Row row = sheet.createRow(rowIdx++);
                createCell(row, 0, String.valueOf(e.getId()), dataStyle);
                createCell(row, 1, e.getApellidos() + ", " + e.getNombres(), dataStyle);
                createCell(row, 2, e.getDni(), dataStyle);
                createCell(row, 3, e.getRol(), dataStyle);
                createCell(row, 4, e.getTipoModalidad(), dataStyle);
                createCell(row, 5, e.getSucursal() != null ? e.getSucursal().getNombre() : "-", dataStyle);
                createCell(row, 6, String.valueOf(e.getSueldoBase()), dataStyle);
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    public byte[] generateEmpleadosPdf(List<Empleado> empleados) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, out);
            document.open();

            // Logo
            try (InputStream is = getClass().getResourceAsStream("/static/img/logo-peruana.png")) {
                if (is != null) {
                    byte[] bytes = IOUtils.toByteArray(is);
                    Image logo = Image.getInstance(bytes);
                    logo.scaleAbsolute(129.84f, 88.45f);
                    logo.setAlignment(Element.ALIGN_LEFT);
                    document.add(logo);
                }
            } catch (Exception e) {
            }

            document.add(new Paragraph("\n\n"));

            // Title
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, Color.DARK_GRAY);
            Paragraph title = new Paragraph("Reporte de Personal", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            // Table
            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[] { 1, 4, 2, 2, 2, 3, 2 }); // relative widths

            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.WHITE);
            String[] headers = { "ID", "Apellidos y Nombres", "DNI", "Rol", "Modalidad", "Sucursal", "Sueldo" };

            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
                cell.setBackgroundColor(new Color(0, 51, 102));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(5);
                table.addCell(cell);
            }

            Font dataFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);
            boolean alternate = false;
            Color lightGray = new Color(240, 240, 240);

            for (Empleado e : empleados) {
                addCell(table, String.valueOf(e.getId()), dataFont, alternate, lightGray);
                addCell(table, e.getApellidos() + ", " + e.getNombres(), dataFont, alternate, lightGray);
                addCell(table, e.getDni(), dataFont, alternate, lightGray);
                addCell(table, e.getRol(), dataFont, alternate, lightGray);
                addCell(table, e.getTipoModalidad(), dataFont, alternate, lightGray);
                addCell(table, e.getSucursal() != null ? e.getSucursal().getNombre() : "-", dataFont, alternate,
                        lightGray);
                addCell(table, String.valueOf(e.getSueldoBase()), dataFont, alternate, lightGray);
                alternate = !alternate;
            }

            document.add(table);

            // Footer
            Paragraph footer = new Paragraph(
                    "Generado el: "
                            + java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")),
                    FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 8));
            footer.setAlignment(Element.ALIGN_RIGHT);
            footer.setSpacingBefore(10);
            document.add(footer);

            document.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating PDF", e);
        }
    }

    private void addCell(PdfPTable table, String text, Font font, boolean alternate, Color color) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "", font));
        if (alternate) {
            cell.setBackgroundColor(color);
        }
        cell.setPadding(3);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        table.addCell(cell);
    }
}
