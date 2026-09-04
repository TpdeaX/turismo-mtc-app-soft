package com.zonasturisticas.plataforma.services;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPCellEvent;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfShading;
import com.lowagie.text.pdf.PdfShadingPattern;
import com.lowagie.text.pdf.PdfTemplate;
import com.lowagie.text.pdf.PdfWriter;
import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.HorarioFerroviario;
import com.zonasturisticas.plataforma.beans.PronosticoClima;
import com.zonasturisticas.plataforma.dto.InformeConsolidadoDTO;
import com.zonasturisticas.plataforma.dto.RutaRecomendadaDTO;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * RNF07: portabilidad del informe consolidado. Exporta el informe del RF07 a
 * PDF con la identidad grafica de la plataforma: membrete institucional
 * repetido en cada pagina, secciones numeradas, fichas de datos redondeadas y
 * pie con folio y numeracion de paginas.
 */
@Service
public class InformePdfService {

    /* --------------------------- paleta de marca --------------------------- */
    private static final Color AZUL = new Color(10, 31, 61);
    private static final Color AZUL_MEDIO = new Color(27, 66, 120);
    private static final Color AZUL_SUAVE = new Color(238, 243, 250);
    private static final Color ROJO = new Color(232, 17, 45);
    private static final Color AMBAR = new Color(245, 197, 24);
    private static final Color ORO = new Color(199, 154, 5);
    private static final Color GRIS = new Color(110, 122, 138);
    private static final Color GRIS_CLARO = new Color(168, 180, 196);
    private static final Color LINEA = new Color(223, 230, 238);
    private static final Color TEXTO = new Color(26, 35, 50);
    private static final Color FONDO = new Color(246, 249, 253);
    private static final Color JADE = new Color(18, 128, 92);

    /* ------------------------------ geometria ------------------------------ */
    private static final float MARGEN_X = 42f;
    private static final float MARGEN_SUP = 96f;
    private static final float MARGEN_INF = 58f;
    private static final float BANDA_ALTO = 78f;

    private static final DateTimeFormatter FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DIA = DateTimeFormatter.ofPattern("EEE dd/MM", new Locale("es", "PE"));

    public byte[] generar(InformeConsolidadoDTO informe) {
        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4, MARGEN_X, MARGEN_X, MARGEN_SUP, MARGEN_INF);
        try {
            PdfWriter writer = PdfWriter.getInstance(doc, salida);
            writer.setPageEvent(new Membrete(informe));
            doc.addTitle("Informe consolidado " + informe.getFolio());
            doc.addAuthor("Ministerio de Transportes y Comunicaciones del Perú");
            doc.addSubject("Ruta turística caminable recomendada");
            doc.open();

            portada(doc, informe);
            bloqueZona(doc, informe);
            bloqueRuta(doc, informe);
            bloqueClima(doc, informe);
            bloqueFerroviario(doc, informe);
            bloqueFuentes(doc);

            doc.close();
        } catch (Exception e) {
            throw new IllegalStateException("No se pudo generar el informe en PDF", e);
        }
        return salida.toByteArray();
    }

    /* ====================================================================== */
    /*  Membrete institucional y pie, repetidos en todas las paginas          */
    /* ====================================================================== */

    private static final class Membrete extends PdfPageEventHelper {

        private final InformeConsolidadoDTO informe;
        private PdfTemplate totalPaginas;

        private Membrete(InformeConsolidadoDTO informe) {
            this.informe = informe;
        }

        @Override
        public void onOpenDocument(PdfWriter writer, Document document) {
            totalPaginas = writer.getDirectContent().createTemplate(36, 12);
        }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContentUnder();
            Rectangle pagina = document.getPageSize();
            float ancho = pagina.getWidth();
            float alto = pagina.getHeight();
            float bandaY = alto - BANDA_ALTO;

            /* --- Banda superior azul con degradado simulado en dos tonos --- */
            cb.saveState();
            PdfShadingPattern degradado = new PdfShadingPattern(
                    PdfShading.simpleAxial(writer, 0, bandaY, ancho, bandaY, AZUL, AZUL_MEDIO));
            cb.setShadingFill(degradado);
            cb.rectangle(0, bandaY, ancho, BANDA_ALTO);
            cb.fill();
            cb.restoreState();

            /* --- Filete dorado inferior de la banda --- */
            cb.setColorFill(AMBAR);
            cb.rectangle(0, bandaY - 3f, ancho, 3f);
            cb.fill();

            /* --- Escudo institucional --- */
            float ex = MARGEN_X;
            float ey = bandaY + 19f;
            cb.setColorFill(ROJO);
            cb.roundRectangle(ex, ey, 36f, 40f, 6f);
            cb.fill();
            // Filete blanco superior: guino a la banda central de la bandera peruana
            cb.setColorFill(Color.WHITE);
            cb.rectangle(ex + 6f, ey + 34f, 24f, 1.6f);
            cb.fill();
            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    new Phrase("MTC", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11.5f, Color.WHITE)),
                    ex + 18f, ey + 22f, 0);
            ColumnText.showTextAligned(cb, Element.ALIGN_CENTER,
                    new Phrase("PERÚ", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 5.6f, new Color(255, 220, 224))),
                    ex + 18f, ey + 9f, 0);

            /* --- Denominacion institucional --- */
            float tx = ex + 48f;
            cb.beginText();
            cb.setFontAndSize(FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.6f).getBaseFont(), 6.6f);
            cb.setColorFill(AMBAR);
            cb.setCharacterSpacing(1.15f);
            cb.setTextMatrix(tx, bandaY + 51f);
            cb.showText("MINISTERIO DE TRANSPORTES Y COMUNICACIONES");
            cb.setCharacterSpacing(0f);
            cb.endText();

            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                    new Phrase("Plataforma de Zonas Turísticas",
                            FontFactory.getFont(FontFactory.HELVETICA_BOLD, 15f, Color.WHITE)),
                    tx, bandaY + 33f, 0);
            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                    new Phrase("Asesor de rutas turísticas a pie desde estaciones ferroviarias",
                            FontFactory.getFont(FontFactory.HELVETICA, 7.4f, new Color(169, 189, 216))),
                    tx, bandaY + 20f, 0);

            /* --- Folio a la derecha --- */
            float dx = ancho - MARGEN_X;
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                    new Phrase("INFORME CONSOLIDADO",
                            FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.4f, new Color(169, 189, 216))),
                    dx, bandaY + 51f, 0);
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                    new Phrase(informe.getFolio() == null ? "-" : informe.getFolio(),
                            FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12.5f, AMBAR)),
                    dx, bandaY + 33f, 0);
            if (informe.getGenerado() != null) {
                ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                        new Phrase(informe.getGenerado().format(FECHA),
                                FontFactory.getFont(FontFactory.HELVETICA, 7.4f, new Color(169, 189, 216))),
                        dx, bandaY + 20f, 0);
            }

            /* --- Pie de pagina --- */
            cb.setColorFill(LINEA);
            cb.rectangle(MARGEN_X, 44f, ancho - MARGEN_X * 2, 0.7f);
            cb.fill();

            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT,
                    new Phrase("Documento generado automáticamente · El sistema no realiza venta ni reserva de boletos",
                            FontFactory.getFont(FontFactory.HELVETICA, 7f, GRIS_CLARO)),
                    MARGEN_X, 32f, 0);

            Font fPag = FontFactory.getFont(FontFactory.HELVETICA, 7.4f, GRIS);
            float xTotal = dx - 14f;
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                    new Phrase("Página " + writer.getPageNumber() + " de ", fPag), xTotal, 32f, 0);
            cb.addTemplate(totalPaginas, xTotal, 32f);
        }

        @Override
        public void onCloseDocument(PdfWriter writer, Document document) {
            totalPaginas.beginText();
            totalPaginas.setFontAndSize(FontFactory.getFont(FontFactory.HELVETICA, 7.4f).getBaseFont(), 7.4f);
            totalPaginas.setColorFill(GRIS);
            totalPaginas.setTextMatrix(0, 0);
            // Al cerrar el documento el contador ya apunta a la pagina siguiente
            totalPaginas.showText(String.valueOf(writer.getPageNumber() - 1));
            totalPaginas.endText();
        }
    }

    /**
     * Pinta un fondo redondeado detras de una celda. OpenPDF no tiene bordes
     * redondeados nativos, asi que se dibujan en el lienzo de la propia celda.
     */
    private static final class FondoRedondeado implements PdfPCellEvent {

        private final Color fondo;
        private final Color borde;
        private final float radio;
        private final Color barra;

        private FondoRedondeado(Color fondo, Color borde, float radio, Color barra) {
            this.fondo = fondo;
            this.borde = borde;
            this.radio = radio;
            this.barra = barra;
        }

        @Override
        public void cellLayout(PdfPCell cell, Rectangle p, PdfContentByte[] lienzos) {
            PdfContentByte cb = lienzos[PdfPTable.BACKGROUNDCANVAS];
            cb.saveState();
            if (fondo != null) {
                cb.setColorFill(fondo);
                cb.roundRectangle(p.getLeft(), p.getBottom(), p.getWidth(), p.getHeight(), radio);
                cb.fill();
            }
            if (borde != null) {
                cb.setColorStroke(borde);
                cb.setLineWidth(0.8f);
                cb.roundRectangle(p.getLeft() + 0.4f, p.getBottom() + 0.4f,
                        p.getWidth() - 0.8f, p.getHeight() - 0.8f, radio);
                cb.stroke();
            }
            if (barra != null) {
                cb.setColorFill(barra);
                cb.roundRectangle(p.getLeft(), p.getBottom() + 4f, 3f, p.getHeight() - 8f, 1.5f);
                cb.fill();
            }
            cb.restoreState();
        }
    }

    /* ====================================================================== */
    /*  Bloques del informe                                                    */
    /* ====================================================================== */

    private void portada(Document doc, InformeConsolidadoDTO i) throws Exception {
        PdfPTable ficha = new PdfPTable(1);
        ficha.setWidthPercentage(100);

        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(18f);
        c.setPaddingBottom(20f);
        c.setCellEvent(new FondoRedondeado(AZUL_SUAVE, LINEA, 10f, AMBAR));

        c.addElement(etiqueta("RUTA TURÍSTICA RECOMENDADA"));

        Paragraph nombre = new Paragraph(i.getZona() == null ? "-" : i.getZona().getNombre(),
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 21f, AZUL));
        nombre.setLeading(24f);
        nombre.setSpacingBefore(3f);
        c.addElement(nombre);

        StringBuilder ubic = new StringBuilder();
        if (i.getZona() != null && i.getZona().getUbicacion() != null) {
            ubic.append(i.getZona().getUbicacion());
        }
        if (i.getEstacion() != null) {
            if (ubic.length() > 0) {
                ubic.append("   ·   ");
            }
            ubic.append("Parte de ").append(i.getEstacion().getNombre());
        }
        Paragraph sub = new Paragraph(ubic.toString(),
                FontFactory.getFont(FontFactory.HELVETICA, 9f, GRIS));
        sub.setSpacingBefore(4f);
        c.addElement(sub);

        String cats = i.getZona() == null ? null : i.getZona().getCategoriasTexto();
        if (cats != null && !cats.isBlank()) {
            c.addElement(etiquetasCategorias(i));
        }

        ficha.addCell(c);
        ficha.setSpacingAfter(12f);
        doc.add(ficha);

        /* --- Tira de metadatos de la consulta --- */
        PdfPTable meta = new PdfPTable(new float[] { 1f, 1f, 1.35f });
        meta.setWidthPercentage(100);
        meta.setSpacingAfter(16f);
        meta.addCell(metaCelda("FOLIO DEL INFORME", i.getFolio()));
        meta.addCell(metaCelda("FECHA DE EMISIÓN",
                i.getGenerado() == null ? "-" : i.getGenerado().format(FECHA)));
        meta.addCell(metaCelda("PREFERENCIAS APLICADAS", i.getPreferenciasTexto()));
        doc.add(meta);
    }

    private void bloqueZona(Document doc, InformeConsolidadoDTO i) throws Exception {
        doc.add(seccion(1, "Zona turística", "Catálogo de Travel Group Perú"));

        if (i.getZona() != null && i.getZona().getDescripcion() != null) {
            doc.add(parrafo(i.getZona().getDescripcion()));
        }

        PdfPTable t = new PdfPTable(new float[] { 1f, 1f, 1f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(8f);
        t.setSpacingAfter(16f);
        t.addCell(dato("Estación de partida",
                i.getEstacion() == null ? "-" : i.getEstacion().getNombre(), AZUL));
        t.addCell(dato("Región",
                i.getEstacion() == null ? "-" : i.getEstacion().getRegion(), AZUL));
        t.addCell(dato("Costo referencial",
                i.getZona() == null || i.getZona().getCostoReferencial() == null
                        ? "Sin costo" : "S/ " + i.getZona().getCostoReferencial(), JADE));
        doc.add(t);
    }

    private void bloqueRuta(Document doc, InformeConsolidadoDTO i) throws Exception {
        doc.add(seccion(2, "Ruta caminable de ida y vuelta", "Cálculo de la plataforma"));

        RutaRecomendadaDTO r = i.getRutaRecomendada();
        if (r == null) {
            doc.add(aviso("No hay una ruta caminable registrada para esta zona turística.", AMBAR));
            return;
        }

        PdfPTable t = new PdfPTable(new float[] { 1f, 1f, 1f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(4f);
        t.addCell(dato("Distancia total", r.getDistanciaTotalKm() + " km", AZUL));
        t.addCell(dato("Tiempo estimado", r.getTiempoTotalTexto(), AZUL));
        t.addCell(dato("Dificultad", r.getDificultad(), colorDificultad(r.getNivelDificultad())));
        doc.add(t);

        if (r.getRecomendacion() != null) {
            Paragraph p = parrafo(r.getRecomendacion());
            p.setSpacingBefore(10f);
            doc.add(p);
        }
        doc.add(nota("Modalidad: recorrido exclusivamente peatonal de un solo tramo, que parte y retorna "
                + "a la misma estación ferroviaria."));
    }

    private void bloqueClima(Document doc, InformeConsolidadoDTO i) throws Exception {
        doc.add(seccion(3, "Pronóstico climático", "Fuente: SENAMHI"));

        if (!i.isClimaDisponible()) {
            doc.add(aviso(i.getClimaMensaje() == null
                    ? "El pronóstico climático no se encuentra disponible en este momento."
                    : i.getClimaMensaje(), AMBAR));
        }

        PronosticoClima c = i.getClimaActual();
        if (c == null) {
            return;
        }

        PdfPTable t = new PdfPTable(new float[] { 1f, 1.25f, 1f, 1.2f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(4f);
        t.addCell(dato("Temperatura", c.getTemperatura() == null ? "-" : c.getTemperatura() + " °C", AZUL));
        t.addCell(dato("Condición", c.getCondicion(), AZUL));
        t.addCell(dato("Humedad", c.getHumedad() == null ? "-" : c.getHumedad() + " %", AZUL));
        t.addCell(dato("Viento", c.getViento() == null ? "-"
                : c.getViento() + " km/h " + (c.getVientoDireccion() == null ? "" : c.getVientoDireccion()), AZUL));
        doc.add(t);

        if (i.getPronostico() != null && i.getPronostico().size() > 1) {
            PdfPTable f = new PdfPTable(new float[] { 1.3f, 2.2f, 1f, 1f, 1.2f });
            f.setWidthPercentage(100);
            f.setSpacingBefore(12f);
            f.setHeaderRows(1);
            for (String h : new String[] { "Día", "Condición", "Mínima", "Máxima", "Prob. lluvia" }) {
                f.addCell(th(h));
            }
            int fila = 0;
            for (PronosticoClima d : i.getPronostico()) {
                Color fondo = (fila++ % 2 == 0) ? Color.WHITE : FONDO;
                f.addCell(td(d.getFecha() == null ? "-" : d.getFecha().format(DIA), fondo, true));
                f.addCell(td(d.getCondicion(), fondo, false));
                f.addCell(td(d.getTemperaturaMin() == null ? "-" : d.getTemperaturaMin() + " °C", fondo, false));
                f.addCell(td(d.getTemperaturaMax() == null ? "-" : d.getTemperaturaMax() + " °C", fondo, false));
                f.addCell(td(d.getProbabilidadLluvia() == null ? "-" : d.getProbabilidadLluvia() + " %", fondo, false));
            }
            doc.add(f);
        }

        if (i.getClimaActualizado() != null) {
            doc.add(nota("Última sincronización exitosa con SENAMHI: " + i.getClimaActualizado().format(FECHA) + "."));
        }
    }

    private void bloqueFerroviario(Document doc, InformeConsolidadoDTO i) throws Exception {
        doc.add(seccion(4, "Servicio ferroviario", "Fuente: PeruRail"));

        if (!i.isTieneHorarios()) {
            doc.add(aviso("No se registran horarios ferroviarios vigentes para esta estación.", AMBAR));
            return;
        }

        PdfPTable t = new PdfPTable(new float[] { 2.4f, 2.6f, 1f, 1f, 1.1f, 1.2f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(4f);
        t.setHeaderRows(1);
        for (String h : new String[] { "Servicio", "Trayecto", "Salida", "Llegada", "Duración", "Tarifa" }) {
            t.addCell(th(h));
        }
        int fila = 0;
        for (HorarioFerroviario h : i.getHorarios()) {
            Color fondo = (fila++ % 2 == 0) ? Color.WHITE : FONDO;
            t.addCell(td(h.getServicio().getNombre(), fondo, true));
            t.addCell(td(h.getServicio().getTrayecto(), fondo, false));
            t.addCell(td(String.valueOf(h.getHoraSalida()), fondo, false));
            t.addCell(td(String.valueOf(h.getHoraLlegada()), fondo, false));
            t.addCell(td(h.getDuracionTexto(), fondo, false));
            t.addCell(td("S/ " + h.getTarifa(), fondo, true));
        }
        doc.add(t);

        if (i.getTarifaMinima() != null) {
            PdfPTable rango = new PdfPTable(1);
            rango.setWidthPercentage(100);
            rango.setSpacingBefore(10f);
            PdfPCell c = new PdfPCell();
            c.setBorder(Rectangle.NO_BORDER);
            c.setPadding(11f);
            c.setCellEvent(new FondoRedondeado(new Color(255, 249, 226), null, 8f, ORO));
            c.setPaddingLeft(16f);
            c.addElement(new Paragraph("Rango tarifario vigente",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 7f, new Color(122, 90, 8))));
            c.addElement(new Paragraph("S/ " + i.getTarifaMinima() + "  –  S/ " + i.getTarifaMaxima(),
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13f, AZUL)));
            rango.addCell(c);
            doc.add(rango);
        }
        if (i.getFerroviarioActualizado() != null) {
            doc.add(nota("Datos sincronizados con PeruRail el " + i.getFerroviarioActualizado().format(FECHA) + "."));
        }
    }

    private void bloqueFuentes(Document doc) throws Exception {
        PdfPTable t = new PdfPTable(new float[] { 1f, 1f, 1f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(20f);
        t.addCell(fuente("SENAMHI", "Pronóstico climático oficial", new Color(27, 127, 212)));
        t.addCell(fuente("PeruRail", "Horarios, trayectos y tarifas", AZUL));
        t.addCell(fuente("Travel Group Perú", "Catálogo de zonas turísticas", JADE));
        doc.add(t);

        Paragraph legal = new Paragraph(
                "Informe emitido por la Plataforma de Zonas Turísticas del Ministerio de Transportes y "
                        + "Comunicaciones del Perú, dirigido al usuario final y a Travel Group Perú. Las rutas "
                        + "descritas son peatonales y de un solo tramo. El sistema no realiza venta ni reserva "
                        + "de boletos de tren.",
                FontFactory.getFont(FontFactory.HELVETICA, 7.4f, GRIS));
        legal.setAlignment(Element.ALIGN_JUSTIFIED);
        legal.setSpacingBefore(14f);
        legal.setLeading(10.5f);
        doc.add(legal);
    }

    /* ============================== helpers =============================== */

    /** Encabezado de seccion: distintivo dorado numerado + titulo y fuente. */
    private PdfPTable seccion(int numero, String titulo, String fuente) {
        PdfPTable t = new PdfPTable(new float[] { 26f, 500f });
        t.setWidthPercentage(100);
        t.setSpacingBefore(6f);
        t.setSpacingAfter(8f);

        PdfPCell n = new PdfPCell(new Phrase(String.valueOf(numero),
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11f, AZUL)));
        n.setBorder(Rectangle.NO_BORDER);
        n.setHorizontalAlignment(Element.ALIGN_CENTER);
        n.setVerticalAlignment(Element.ALIGN_MIDDLE);
        n.setFixedHeight(24f);
        n.setCellEvent(new FondoRedondeado(AMBAR, null, 6f, null));
        t.addCell(n);

        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPaddingLeft(11f);
        c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        c.setFixedHeight(24f);
        Paragraph p = new Paragraph();
        p.add(new Phrase(titulo, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12.5f, AZUL)));
        p.add(new Phrase("    " + fuente, FontFactory.getFont(FontFactory.HELVETICA, 8f, GRIS)));
        c.addElement(p);
        t.addCell(c);
        return t;
    }

    private Paragraph etiqueta(String texto) {
        Paragraph p = new Paragraph(texto, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.8f, ORO));
        p.setLeading(8f);
        return p;
    }

    /** Lista las categorias de la zona como una linea de marcas separadas. */
    private Paragraph etiquetasCategorias(InformeConsolidadoDTO i) {
        Paragraph p = new Paragraph();
        p.setSpacingBefore(9f);
        boolean primero = true;
        for (Categoria cat : i.getZona().getCategorias()) {
            if (!primero) {
                p.add(new Phrase("   ", FontFactory.getFont(FontFactory.HELVETICA, 8f, GRIS)));
            }
            p.add(new Phrase("• ", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13f, colorHex(cat.getColor()))));
            p.add(new Phrase(cat.getNombre(), FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8.4f, AZUL)));
            primero = false;
        }
        return p;
    }

    private Paragraph parrafo(String texto) {
        Paragraph p = new Paragraph(texto, FontFactory.getFont(FontFactory.HELVETICA, 9.5f, TEXTO));
        p.setAlignment(Element.ALIGN_JUSTIFIED);
        p.setLeading(14f);
        return p;
    }

    private Paragraph nota(String texto) {
        Paragraph p = new Paragraph(texto, FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 7.8f, GRIS));
        p.setSpacingBefore(8f);
        p.setSpacingAfter(16f);
        return p;
    }

    private PdfPCell metaCelda(String etiqueta, String valor) {
        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(10f);
        c.setPaddingLeft(14f);
        c.setCellEvent(new FondoRedondeado(null, LINEA, 8f, null));
        c.addElement(new Paragraph(etiqueta, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.6f, GRIS)));
        Paragraph v = new Paragraph(valor == null || valor.isBlank() ? "-" : valor,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9f, AZUL));
        v.setSpacingBefore(2f);
        v.setLeading(11f);
        c.addElement(v);
        return c;
    }

    /** Ficha de dato destacado con fondo redondeado y barra de color lateral. */
    private PdfPCell dato(String etiqueta, String valor, Color acento) {
        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(11f);
        c.setPaddingLeft(15f);
        c.setCellEvent(new FondoRedondeado(FONDO, LINEA, 8f, acento));
        c.addElement(new Paragraph(etiqueta.toUpperCase(),
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.6f, GRIS)));
        Paragraph v = new Paragraph(valor == null || valor.isBlank() ? "-" : valor,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12.5f, acento));
        v.setSpacingBefore(3f);
        v.setLeading(14f);
        c.addElement(v);
        return c;
    }

    private PdfPCell fuente(String nombre, String detalle, Color acento) {
        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(10f);
        c.setPaddingLeft(14f);
        c.setCellEvent(new FondoRedondeado(null, LINEA, 8f, acento));
        c.addElement(new Paragraph("FUENTE INTEGRADA",
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6f, GRIS_CLARO)));
        Paragraph n = new Paragraph(nombre, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10.5f, acento));
        n.setSpacingBefore(2f);
        c.addElement(n);
        c.addElement(new Paragraph(detalle, FontFactory.getFont(FontFactory.HELVETICA, 7.4f, GRIS)));
        return c;
    }

    private PdfPCell th(String texto) {
        PdfPCell c = new PdfPCell(new Phrase(texto,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 7.6f, Color.WHITE)));
        c.setBackgroundColor(AZUL);
        c.setPadding(8f);
        c.setBorder(Rectangle.NO_BORDER);
        return c;
    }

    private PdfPCell td(String texto, Color fondo, boolean fuerte) {
        Font f = fuerte
                ? FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8.4f, AZUL)
                : FontFactory.getFont(FontFactory.HELVETICA, 8.4f, TEXTO);
        PdfPCell c = new PdfPCell(new Phrase(texto == null ? "-" : texto, f));
        c.setBackgroundColor(fondo);
        c.setPadding(7f);
        c.setBorder(Rectangle.BOTTOM);
        c.setBorderColor(LINEA);
        c.setBorderWidth(0.6f);
        return c;
    }

    private PdfPTable aviso(String mensaje, Color acento) {
        PdfPTable t = new PdfPTable(1);
        t.setWidthPercentage(100);
        t.setSpacingBefore(4f);
        t.setSpacingAfter(16f);
        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(12f);
        c.setPaddingLeft(16f);
        c.setCellEvent(new FondoRedondeado(new Color(255, 249, 226), null, 8f, acento));
        c.addElement(new Paragraph(mensaje,
                FontFactory.getFont(FontFactory.HELVETICA, 8.8f, new Color(122, 90, 8))));
        t.addCell(c);
        return t;
    }

    private Color colorDificultad(int nivel) {
        if (nivel >= 3) {
            return new Color(194, 39, 59);
        }
        if (nivel == 2) {
            return new Color(180, 83, 9);
        }
        return JADE;
    }

    /** Traduce el color hexadecimal de una categoria; azul institucional si falla. */
    private Color colorHex(String hex) {
        if (hex != null && hex.matches("#[0-9a-fA-F]{6}")) {
            return new Color(Integer.parseInt(hex.substring(1), 16));
        }
        return AZUL;
    }
}
