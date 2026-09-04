package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.repositories.ZonaTuristicaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;

/**
 * Verifica las validaciones obligatorias del registro de zonas turísticas
 * (RF08 / CU-04), que mitigan el riesgo de "información incompleta" señalado
 * en el análisis de riesgos del informe.
 */
class ZonaTuristicaServiceTest {

    private ZonaTuristicaService servicio;

    @BeforeEach
    void preparar() {
        servicio = new ZonaTuristicaService(
                mock(ZonaTuristicaRepository.class),
                mock(CategoriaService.class));
    }

    private ZonaTuristica zonaValida() {
        Estacion estacion = new Estacion("Estación Ollantaytambo", "Av. Ferrocarril", "Cusco",
                -13.25, -72.26, "Bus");
        Ruta ruta = new Ruta(estacion, "Camino al conjunto", new BigDecimal("1.20"), "35 min", "Fácil");

        ZonaTuristica zona = new ZonaTuristica();
        zona.setNombre("Conjunto Arqueológico de Ollantaytambo");
        zona.setDescripcion("Fortaleza y andenería inca del Valle Sagrado.");
        zona.setRuta(ruta);
        zona.setCategorias(Set.of(new Categoria("Historia", "", "history_edu", "#8A5A2B")));
        return zona;
    }

    @Test
    @DisplayName("Una zona completa no produce errores de validación")
    void aceptaZonaCompleta() {
        assertTrue(servicio.validar(zonaValida()).isEmpty());
    }

    @Test
    @DisplayName("El nombre es obligatorio")
    void rechazaNombreVacio() {
        ZonaTuristica zona = zonaValida();
        zona.setNombre("   ");

        List<String> errores = servicio.validar(zona);
        assertFalse(errores.isEmpty());
        assertTrue(errores.get(0).contains("nombre"));
    }

    @Test
    @DisplayName("La zona debe estar vinculada a una ruta de una estación")
    void rechazaZonaSinRuta() {
        ZonaTuristica zona = zonaValida();
        zona.setRuta(null);

        assertTrue(servicio.validar(zona).stream().anyMatch(e -> e.contains("ruta")));
    }

    @Test
    @DisplayName("RF03: la zona debe tener al menos una categoría de preferencia")
    void rechazaZonaSinCategorias() {
        ZonaTuristica zona = zonaValida();
        zona.setCategorias(Set.of());

        assertTrue(servicio.validar(zona).stream().anyMatch(e -> e.contains("categoría")));
    }

    @Test
    @DisplayName("Se respetan los límites de longitud del diccionario de datos")
    void respetaLongitudesDelDiccionario() {
        ZonaTuristica zona = zonaValida();
        zona.setNombre("N".repeat(101));
        zona.setDescripcion("D".repeat(501));

        List<String> errores = servicio.validar(zona);
        assertEquals(2, errores.size());
    }
}
