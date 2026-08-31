package com.zonasturisticas.plataforma.init;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import com.zonasturisticas.plataforma.beans.TipoTurno;
import com.zonasturisticas.plataforma.repositories.TipoTurnoRepository;
import java.util.Arrays;
import java.util.List;

@Component
public class DataSeeder implements CommandLineRunner {

    private final TipoTurnoRepository tipoTurnoRepository;

    public DataSeeder(TipoTurnoRepository tipoTurnoRepository) {
        this.tipoTurnoRepository = tipoTurnoRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        if (tipoTurnoRepository.count() == 0) {
            System.out.println("--- Seeding TipoTurno Data ---");
            List<TipoTurno> tipos = Arrays.asList(
                    crear("Caja", "#ffb6c1"),
                    crear("Caja 2do Nivel", "#ff69b4"),
                    crear("Stock", "#ffc107"),
                    crear("Atencion", "#90ee90"),
                    crear("Pesado", "#dda0dd"),
                    crear("Despacho", "#87ceeb"),
                    crear("Despacho PreVenta", "#4682b4"),
                    crear("Refrigerio", "#f5f5dc"), // + color: black in CSS, but color code is enough
                    crear("Almacen", "#17a2b8"),
                    crear("Limpieza", "#17a2b8"),
                    crear("Seguridad", "#17a2b8"));
            tipoTurnoRepository.saveAll(tipos);
        }
    }

    private TipoTurno crear(String nombre, String color) {
        TipoTurno t = new TipoTurno();
        t.setNombre(nombre);
        t.setColor(color);
        return t;
    }
}
