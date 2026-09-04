package com.zonasturisticas.plataforma.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.Locale;

/**
 * Funciones de presentacion expuestas a las vistas JSP mediante la librería de
 * etiquetas {@code /WEB-INF/mtc.tld}.
 *
 * Existen porque la JSTL estándar ({@code fmt:formatDate}) solo admite
 * {@code java.util.Date} y el dominio del sistema usa la API {@code java.time}.
 */
public final class Formato {

    private static final Locale PE = Locale.forLanguageTag("es-PE");

    private static final DateTimeFormatter F_LARGA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm", PE);
    private static final DateTimeFormatter F_CORTA = DateTimeFormatter.ofPattern("dd/MM HH:mm", PE);
    private static final DateTimeFormatter F_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy", PE);
    private static final DateTimeFormatter F_HORA = DateTimeFormatter.ofPattern("HH:mm", PE);

    private Formato() {
    }

    /** "02/09/2026 21:30" */
    public static String fecha(LocalDateTime f) {
        return f == null ? "—" : f.format(F_LARGA);
    }

    /** "02/09 21:30" */
    public static String fechaCorta(LocalDateTime f) {
        return f == null ? "—" : f.format(F_CORTA);
    }

    /** "02/09/2026" */
    public static String soloFecha(LocalDate f) {
        return f == null ? "—" : f.format(F_FECHA);
    }

    /** "07:05" */
    public static String hora(LocalTime h) {
        return h == null ? "—" : h.format(F_HORA);
    }

    /** "MIÉ 03" — usado en la tira de pronóstico extendido. */
    public static String diaCorto(LocalDate f) {
        if (f == null) {
            return "—";
        }
        String dia = f.getDayOfWeek().getDisplayName(TextStyle.SHORT, PE)
                .replace(".", "").toUpperCase(PE);
        return dia + " " + String.format("%02d", f.getDayOfMonth());
    }

    /** true si la fecha corresponde al día de hoy. */
    public static boolean esHoy(LocalDate f) {
        return f != null && f.equals(LocalDate.now());
    }

    /** "Hace 5 min", "Hace 3 h", "Hace 2 d". */
    public static String relativo(LocalDateTime f) {
        if (f == null) {
            return "Sin registro";
        }
        Duration d = Duration.between(f, LocalDateTime.now());
        long min = d.toMinutes();
        if (min < 1) {
            return "Hace instantes";
        }
        if (min < 60) {
            return "Hace " + min + " min";
        }
        long h = d.toHours();
        if (h < 24) {
            return "Hace " + h + " h";
        }
        return "Hace " + d.toDays() + " d";
    }

    /** "S/ 245.00" */
    public static String soles(BigDecimal valor) {
        if (valor == null) {
            return "—";
        }
        return "S/ " + valor.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    /** "245" — para etiquetas compactas de precio. */
    public static String solesCorto(BigDecimal valor) {
        if (valor == null) {
            return "—";
        }
        return valor.setScale(0, RoundingMode.HALF_UP).toPlainString();
    }

    /** Recorta un texto largo añadiendo puntos suspensivos. */
    public static String recorte(String texto, int largo) {
        if (texto == null) {
            return "";
        }
        return texto.length() <= largo ? texto : texto.substring(0, largo).trim() + "…";
    }
}
