package com.zonasturisticas.plataforma.config;

import com.zonasturisticas.plataforma.beans.Feriado;
import com.zonasturisticas.plataforma.beans.Permiso;
import com.zonasturisticas.plataforma.repositories.FeriadoRepository;
import com.zonasturisticas.plataforma.repositories.PermisoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private FeriadoRepository feriadoRepository;

    @Autowired
    private PermisoRepository permisoRepository;

    @Override
    public void run(String... args) throws Exception {
        initializeFeriados();
        initializePermisos();
    }

    private void initializeFeriados() {
        // Range of years to generate holidays for
        int startYear = 2024;
        int endYear = 2030;

        for (int year = startYear; year <= endYear; year++) {
            addFixedHolidays(year);
            addMovableHolidays(year);
        }
    }

    private void initializePermisos() {
        String[] permisos = {
                "GESTIONAR_EMPLEADOS",
                "VER_REPORTES",
                "APROBAR_JUSTIFICACIONES",
                "CONFIGURACION_SISTEMA",
                "EDITAR_HORARIOS",
                "VER_DASHBOARD_TOTAL"
        };

        for (String nombre : permisos) {
            if (permisoRepository.findByNombre(nombre).isEmpty()) {
                Permiso p = new Permiso();
                p.setNombre(nombre);
                permisoRepository.save(p);
                System.out.println("Permiso agregado: " + nombre);
            }
        }
    }

    private void addFixedHolidays(int year) {
        addFeriadoIfMissing(LocalDate.of(year, 1, 1), "Año Nuevo");
        addFeriadoIfMissing(LocalDate.of(year, 5, 1), "Día del Trabajo");
        addFeriadoIfMissing(LocalDate.of(year, 6, 29), "San Pedro y San Pablo");
        addFeriadoIfMissing(LocalDate.of(year, 7, 28), "Fiestas Patrias");
        addFeriadoIfMissing(LocalDate.of(year, 7, 29), "Fiestas Patrias");
        addFeriadoIfMissing(LocalDate.of(year, 8, 6), "Batalla de Junín");
        addFeriadoIfMissing(LocalDate.of(year, 8, 30), "Santa Rosa de Lima");
        addFeriadoIfMissing(LocalDate.of(year, 10, 8), "Combate de Angamos");
        addFeriadoIfMissing(LocalDate.of(year, 11, 1), "Día de Todos los Santos");
        addFeriadoIfMissing(LocalDate.of(year, 12, 8), "Inmaculada Concepción");
        addFeriadoIfMissing(LocalDate.of(year, 12, 9), "Batalla de Ayacucho");
        addFeriadoIfMissing(LocalDate.of(year, 12, 25), "Navidad");
    }

    private void addMovableHolidays(int year) {
        // Hardcoded Holy Week dates (Jueves Santo and Viernes Santo)
        Map<Integer, LocalDate[]> semanaSantaDates = new HashMap<>();
        semanaSantaDates.put(2024, new LocalDate[] { LocalDate.of(2024, 3, 28), LocalDate.of(2024, 3, 29) });
        semanaSantaDates.put(2025, new LocalDate[] { LocalDate.of(2025, 4, 17), LocalDate.of(2025, 4, 18) });
        semanaSantaDates.put(2026, new LocalDate[] { LocalDate.of(2026, 4, 2), LocalDate.of(2026, 4, 3) });
        semanaSantaDates.put(2027, new LocalDate[] { LocalDate.of(2027, 3, 25), LocalDate.of(2027, 3, 26) });
        semanaSantaDates.put(2028, new LocalDate[] { LocalDate.of(2028, 4, 13), LocalDate.of(2028, 4, 14) });
        semanaSantaDates.put(2029, new LocalDate[] { LocalDate.of(2029, 3, 29), LocalDate.of(2029, 3, 30) });
        semanaSantaDates.put(2030, new LocalDate[] { LocalDate.of(2030, 4, 18), LocalDate.of(2030, 4, 19) });

        if (semanaSantaDates.containsKey(year)) {
            LocalDate[] dates = semanaSantaDates.get(year);
            addFeriadoIfMissing(dates[0], "Jueves Santo");
            addFeriadoIfMissing(dates[1], "Viernes Santo");
        }
    }

    private void addFeriadoIfMissing(LocalDate fecha, String descripcion) {
        if (feriadoRepository.findByFecha(fecha).isEmpty()) {
            Feriado feriado = new Feriado();
            feriado.setFecha(fecha);
            feriado.setDescripcion(descripcion);
            feriadoRepository.save(feriado);
            System.out.println("Feriado agregado: " + fecha + " - " + descripcion);
        }
    }
}
