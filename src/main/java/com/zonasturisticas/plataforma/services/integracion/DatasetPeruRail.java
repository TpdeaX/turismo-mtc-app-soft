package com.zonasturisticas.plataforma.services.integracion;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

/**
 * Representacion local de la fuente de datos de PeruRail (RF10 / CU-06).
 *
 * En modo SIMULADO esta clase cumple el rol del proveedor externo: entrega
 * estaciones, servicios, horarios, tiempos de recorrido y tarifas con la misma
 * estructura que consumiria un cliente HTTP real. Sustituir esta clase por un
 * cliente remoto no obliga a modificar el resto de la plataforma.
 */
public final class DatasetPeruRail {

    private DatasetPeruRail() {
    }

    public record EstacionFuente(String nombre, String ubicacion, String region,
            Double latitud, Double longitud, String conexiones) {
    }

    public record HorarioFuente(LocalTime salida, LocalTime llegada, BigDecimal tarifa, String frecuencia) {
    }

    public record ServicioFuente(String nombre, String origen, String destino, String corredor,
            List<HorarioFuente> horarios) {
    }

    public static List<EstacionFuente> estaciones() {
        return List.of(
                new EstacionFuente("Estación Wanchaq", "Av. Pachacútec s/n, Cusco", "Cusco",
                        -13.5266, -71.9673, "Bus urbano, Taxi, Circuito turístico"),
                new EstacionFuente("Estación Poroy", "Carretera Cusco-Poroy Km 12", "Cusco",
                        -13.4747, -72.0472, "Bus interurbano, Taxi"),
                new EstacionFuente("Estación Ollantaytambo", "Av. Ferrocarril s/n, Ollantaytambo", "Cusco (Urubamba)",
                        -13.2585, -72.2646, "Bus, Colectivo, Peatonal"),
                new EstacionFuente("Estación Machu Picchu Pueblo", "Av. Imperio de los Incas, Aguas Calientes",
                        "Cusco (Aguas Calientes)", -13.1547, -72.5250, "Bus Consettur, Peatonal"),
                new EstacionFuente("Estación Urubamba", "Carretera Urubamba-Ollantaytambo", "Cusco (Urubamba)",
                        -13.3050, -72.1167, "Bus, Colectivo"),
                new EstacionFuente("Estación Puno", "Av. La Torre 224, Puno", "Puno",
                        -15.8402, -70.0219, "Taxi, Triciclo turístico, Peatonal"),
                new EstacionFuente("Estación Juliaca", "Jr. San Martín, Juliaca", "Puno",
                        -15.4939, -70.1330, "Bus interprovincial, Taxi"),
                new EstacionFuente("Estación Arequipa", "Av. Tacna y Arica s/n, Arequipa", "Arequipa",
                        -16.3989, -71.5350, "Bus urbano, Taxi"));
    }

    public static List<ServicioFuente> servicios() {
        return List.of(
                new ServicioFuente("Vistadome 31", "Estación Ollantaytambo", "Estación Machu Picchu Pueblo",
                        "Cusco - Machupicchu", List.of(
                                new HorarioFuente(LocalTime.of(7, 5), LocalTime.of(8, 27),
                                        new BigDecimal("245.00"), "Diario"),
                                new HorarioFuente(LocalTime.of(10, 32), LocalTime.of(11, 56),
                                        new BigDecimal("245.00"), "Diario"),
                                new HorarioFuente(LocalTime.of(13, 27), LocalTime.of(14, 51),
                                        new BigDecimal("232.00"), "Diario"))),

                new ServicioFuente("Expedition 33", "Estación Poroy", "Estación Machu Picchu Pueblo",
                        "Cusco - Machupicchu", List.of(
                                new HorarioFuente(LocalTime.of(8, 25), LocalTime.of(11, 45),
                                        new BigDecimal("198.00"), "Lun - Sáb"),
                                new HorarioFuente(LocalTime.of(15, 20), LocalTime.of(18, 38),
                                        new BigDecimal("186.00"), "Lun - Sáb"))),

                new ServicioFuente("Hiram Bingham 11", "Estación Poroy", "Estación Machu Picchu Pueblo",
                        "Cusco - Machupicchu", List.of(
                                new HorarioFuente(LocalTime.of(9, 5), LocalTime.of(12, 24),
                                        new BigDecimal("1520.00"), "Mar, Jue, Dom"))),

                new ServicioFuente("Valle Sagrado Express", "Estación Urubamba", "Estación Ollantaytambo",
                        "Valle Sagrado", List.of(
                                new HorarioFuente(LocalTime.of(6, 40), LocalTime.of(7, 15),
                                        new BigDecimal("75.00"), "Diario"),
                                new HorarioFuente(LocalTime.of(16, 10), LocalTime.of(16, 46),
                                        new BigDecimal("75.00"), "Diario"))),

                new ServicioFuente("Andean Explorer 01", "Estación Wanchaq", "Estación Puno",
                        "Cusco - Puno", List.of(
                                new HorarioFuente(LocalTime.of(8, 0), LocalTime.of(18, 0),
                                        new BigDecimal("1120.00"), "Mié, Sáb"))),

                new ServicioFuente("Titicaca 21", "Estación Puno", "Estación Juliaca",
                        "Lago Titicaca", List.of(
                                new HorarioFuente(LocalTime.of(7, 30), LocalTime.of(8, 20),
                                        new BigDecimal("60.00"), "Diario"),
                                new HorarioFuente(LocalTime.of(14, 45), LocalTime.of(15, 38),
                                        new BigDecimal("60.00"), "Diario"))),

                new ServicioFuente("Arequipa - Juliaca 09", "Estación Arequipa", "Estación Juliaca",
                        "Sur Andino", List.of(
                                new HorarioFuente(LocalTime.of(7, 15), LocalTime.of(14, 40),
                                        new BigDecimal("310.00"), "Lun, Vie"))));
    }
}
