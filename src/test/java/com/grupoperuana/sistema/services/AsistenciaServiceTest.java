package com.zonasturisticas.plataforma.services;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import com.zonasturisticas.plataforma.beans.Asistencia;
import com.zonasturisticas.plataforma.beans.Horario;
import com.zonasturisticas.plataforma.dto.TurnoDTO;
import com.zonasturisticas.plataforma.repositories.AsistenciaRepository;
import com.zonasturisticas.plataforma.repositories.EmpleadoRepository;
import com.zonasturisticas.plataforma.repositories.HorarioRepository;
import com.zonasturisticas.plataforma.services.ConfiguracionService;

class AsistenciaServiceTest {

    @Mock
    private AsistenciaRepository asistenciaRepository;

    @Mock
    private EmpleadoRepository empleadoRepository;

    @Mock
    private HorarioRepository horarioRepository;

    @Mock
    private ConfiguracionService configuracionService;

    @InjectMocks
    private AsistenciaService asistenciaService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        when(configuracionService.getValor("asistencia_tolerancia")).thenReturn("15");
    }

    @Test
    void testObtenerReporteDiario_DuplicatedAttendance() {
        int empleadoId = 1;
        LocalDate hoy = LocalDate.now();

        // Shift 1: 08:00 - 12:00
        Horario h1 = new Horario();
        h1.setId(1);
        h1.setHoraInicio(LocalTime.of(8, 0));
        h1.setHoraFin(LocalTime.of(12, 0));

        // Shift 2: 12:00 - 16:00 (Back to back)
        Horario h2 = new Horario();
        h2.setId(2);
        h2.setHoraInicio(LocalTime.of(12, 0));
        h2.setHoraFin(LocalTime.of(16, 0));

        when(horarioRepository.findByEmpleadoIdAndFecha(empleadoId, hoy))
                .thenReturn(Arrays.asList(h1, h2));

        // Attendance at 11:50 (Should belong to Shift 1, but currently matches Shift 2
        // as well)
        Asistencia a1 = new Asistencia();
        a1.setId(100);
        a1.setHoraEntrada(LocalTime.of(11, 50));

        when(asistenciaRepository.findByEmpleadoIdAndFecha(empleadoId, hoy))
                .thenReturn(Arrays.asList(a1));

        List<TurnoDTO> reporte = asistenciaService.obtenerReporteDiario(empleadoId);

        assertEquals(2, reporte.size());

        // Check Shift 1
        assertNotNull(reporte.get(0).getAsistencia(), "Shift 1 should have attendance");
        assertEquals(100, reporte.get(0).getAsistencia().getId());

        // Check Shift 2 - BUG REPRODUCTION
        // Ideally this should be NULL, but with current logic it might be the same
        // attendance
        // We assert what we EXPECT to happen (fix), or we can assert the bug to prove
        // it fails.
        // Let's assert the FIX behavior (it should be null). If it fails, we confirmed
        // the bug.
        assertNull(reporte.get(1).getAsistencia(), "Shift 2 should NOT have the same attendance");
    }

    @Test
    void testObtenerReporteDiario_EarlyMark() {
        int empleadoId = 1;
        LocalDate hoy = LocalDate.now();

        // Shift: 08:00 - 12:00
        Horario h1 = new Horario();
        h1.setId(1);
        h1.setHoraInicio(LocalTime.of(8, 0));
        h1.setHoraFin(LocalTime.of(12, 0));

        when(horarioRepository.findByEmpleadoIdAndFecha(empleadoId, hoy))
                .thenReturn(Arrays.asList(h1));

        // Attendance at 05:00 (3 hours early). Should match because window is 4 hours.
        Asistencia a1 = new Asistencia();
        a1.setId(100);
        a1.setHoraEntrada(LocalTime.of(5, 0));

        when(asistenciaRepository.findByEmpleadoIdAndFecha(empleadoId, hoy))
                .thenReturn(Arrays.asList(a1));

        List<TurnoDTO> reporte = asistenciaService.obtenerReporteDiario(empleadoId);

        assertEquals(1, reporte.size());
        assertNotNull(reporte.get(0).getAsistencia(), "Should match early attendance");
        assertEquals(100, reporte.get(0).getAsistencia().getId());
        assertEquals("ASISTIDO", reporte.get(0).getEstado());
        assertEquals("Ingreso Temprano", reporte.get(0).getMensajeEstado());
    }
}
