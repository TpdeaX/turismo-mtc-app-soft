package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.repositories.RutaRepository;
import com.zonasturisticas.plataforma.repositories.ZonaTuristicaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Verifica el motor de cálculo de rutas caminables (RF05).
 *
 * RN01: la distancia recorrida siempre es el doble del tramo (ida y vuelta).
 * RN04: el tiempo se deriva de una velocidad de caminata, no de un vehículo.
 */
class RutaServiceTest {

    private RutaService rutaService;

    @BeforeEach
    void preparar() {
        RutaRepository rutaRepository = mock(RutaRepository.class);
        ZonaTuristicaRepository zonaRepository = mock(ZonaTuristicaRepository.class);
        ConfiguracionService configuracionService = mock(ConfiguracionService.class);

        // El panel de parámetros (RF12) define la velocidad; aquí se fija en 4.2 km/h
        when(configuracionService.getDouble(anyString(), anyDouble())).thenReturn(4.2);

        rutaService = new RutaService(rutaRepository, zonaRepository, configuracionService);
        ReflectionTestUtils.setField(rutaService, "velocidadPorDefecto", 4.2);
    }

    @Test
    @DisplayName("RN01: el tiempo estimado corresponde al tramo de ida y vuelta")
    void calculaIdaYVuelta() {
        // 2.10 km de tramo => 4.20 km totales => 60 min exactos a 4.2 km/h en dificultad fácil
        int minutos = rutaService.calcularMinutosIdaVuelta(new BigDecimal("2.10"), "Fácil");
        assertEquals(60, minutos);
    }

    @Test
    @DisplayName("La dificultad aplica un recargo de tiempo sobre el recorrido base")
    void aplicaRecargoPorDificultad() {
        BigDecimal tramo = new BigDecimal("2.10");

        int facil = rutaService.calcularMinutosIdaVuelta(tramo, "Fácil");
        int moderada = rutaService.calcularMinutosIdaVuelta(tramo, "Moderada");
        int alta = rutaService.calcularMinutosIdaVuelta(tramo, "Alta");

        assertEquals(60, facil);
        assertEquals(69, moderada);   // 60 * 1.15
        assertEquals(81, alta);       // 60 * 1.35
        assertTrue(facil < moderada && moderada < alta);
    }

    @Test
    @DisplayName("El nivel de dificultad se normaliza a la escala 1-3 de la interfaz")
    void normalizaNivelDeDificultad() {
        assertEquals(1, rutaService.nivelDificultad("Fácil"));
        assertEquals(2, rutaService.nivelDificultad("Moderada"));
        assertEquals(3, rutaService.nivelDificultad("Alta"));
        assertEquals(1, rutaService.nivelDificultad(null));
    }

    @Test
    @DisplayName("La duración se presenta en formato legible para el usuario final")
    void formateaDuracion() {
        assertEquals("45 min", rutaService.formatearDuracion(45));
        assertEquals("1 h", rutaService.formatearDuracion(60));
        assertEquals("1 h 20 min", rutaService.formatearDuracion(80));
        assertEquals("3 h 1 min", rutaService.formatearDuracion(181));
    }

    @Test
    @DisplayName("Una distancia nula no rompe el cálculo")
    void toleraDistanciaNula() {
        assertEquals(0, rutaService.calcularMinutosIdaVuelta(null, "Fácil"));
    }
}
