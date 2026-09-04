package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.repositories.RutaRepository;
import com.zonasturisticas.plataforma.repositories.ZonaTuristicaRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * RF05: rutas turisticas caminables.
 *
 * RN01 - un solo tramo de ida y vuelta desde la misma estacion.
 * RN04 - recorrido exclusivamente peatonal, por lo que el tiempo estimado se
 *        calcula con una velocidad de caminata parametrizable (RF12).
 */
@Service
public class RutaService {

    private final RutaRepository rutaRepository;
    private final ZonaTuristicaRepository zonaRepository;
    private final ConfiguracionService configuracionService;

    @Value("${app.ruta.velocidad-caminata-kmh:4.2}")
    private double velocidadPorDefecto;

    public RutaService(RutaRepository rutaRepository, ZonaTuristicaRepository zonaRepository,
            ConfiguracionService configuracionService) {
        this.rutaRepository = rutaRepository;
        this.zonaRepository = zonaRepository;
        this.configuracionService = configuracionService;
    }

    public List<Ruta> listar() {
        return rutaRepository.listarConEstacion();
    }

    public List<Ruta> listarPorEstacion(Integer estacionCodigo) {
        return rutaRepository.findByEstacionCodigoOrderByNombreAsc(estacionCodigo);
    }

    public Ruta obtener(Integer codigo) {
        return codigo == null ? null : rutaRepository.findById(codigo).orElse(null);
    }

    public long contar() {
        return rutaRepository.count();
    }

    /** Velocidad de caminata vigente, tomada del panel de parametros (RF12). */
    public double getVelocidadCaminata() {
        return configuracionService.getDouble("ruta.velocidad_caminata_kmh", velocidadPorDefecto);
    }

    /**
     * Calcula los minutos de recorrido de ida y vuelta a partir de la distancia
     * del tramo, aplicando un recargo segun la dificultad del terreno.
     */
    public int calcularMinutosIdaVuelta(BigDecimal distanciaTramoKm, String dificultad) {
        if (distanciaTramoKm == null) {
            return 0;
        }
        double kmTotal = distanciaTramoKm.doubleValue() * 2d;
        double minutos = (kmTotal / getVelocidadCaminata()) * 60d;
        return (int) Math.round(minutos * factorDificultad(dificultad));
    }

    /** Recargo de tiempo por pendiente y estado del camino. */
    public double factorDificultad(String dificultad) {
        if (dificultad == null) {
            return 1.0;
        }
        String d = dificultad.toUpperCase();
        if (d.contains("ALTA") || d.contains("DIF")) {
            return 1.35;
        }
        if (d.contains("MODERAD")) {
            return 1.15;
        }
        return 1.0;
    }

    /** Nivel numerico 1..3 usado por la interfaz para pintar el indicador. */
    public int nivelDificultad(String dificultad) {
        if (dificultad == null) {
            return 1;
        }
        String d = dificultad.toUpperCase();
        if (d.contains("ALTA") || d.contains("DIF")) {
            return 3;
        }
        if (d.contains("MODERAD")) {
            return 2;
        }
        return 1;
    }

    public String formatearDuracion(int minutos) {
        int h = minutos / 60;
        int m = minutos % 60;
        if (h > 0 && m > 0) {
            return h + " h " + m + " min";
        }
        if (h > 0) {
            return h + " h";
        }
        return m + " min";
    }

    @Transactional
    public Ruta guardar(Ruta ruta) {
        if (ruta.getDistanciaKm() != null) {
            ruta.setDistanciaKm(ruta.getDistanciaKm().setScale(2, RoundingMode.HALF_UP));
        }
        // El tiempo estimado siempre se deriva de la distancia y la dificultad
        int minutos = calcularMinutosIdaVuelta(ruta.getDistanciaKm(), ruta.getDificultad());
        ruta.setTiempoEstimado(formatearDuracion(minutos));
        return rutaRepository.save(ruta);
    }

    @Transactional
    public void eliminar(Integer codigo) {
        if (zonaRepository.countByRutaCodigo(codigo) > 0) {
            throw new IllegalStateException(
                    "No se puede eliminar: la ruta tiene zonas turísticas asociadas.");
        }
        rutaRepository.deleteById(codigo);
    }
}
