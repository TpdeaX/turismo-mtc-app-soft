package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.repositories.EstacionRepository;
import com.zonasturisticas.plataforma.repositories.RutaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * RF09 / CU-05: consulta del listado de estaciones ferroviarias.
 *
 * Para Travel Group Peru el listado es de SOLO LECTURA (RN02: las estaciones
 * provienen exclusivamente de PeruRail). El mantenimiento manual queda
 * reservado al administrador de la plataforma.
 */
@Service
public class EstacionService {

    private final EstacionRepository estacionRepository;
    private final RutaRepository rutaRepository;

    public EstacionService(EstacionRepository estacionRepository, RutaRepository rutaRepository) {
        this.estacionRepository = estacionRepository;
        this.rutaRepository = rutaRepository;
    }

    public List<Estacion> listar() {
        return estacionRepository.findAllByOrderByNombreAsc();
    }

    public List<Estacion> buscar(String termino) {
        if (termino == null || termino.isBlank()) {
            return listar();
        }
        return estacionRepository.buscar(termino.trim());
    }

    public List<String> listarRegiones() {
        return estacionRepository.listarRegiones();
    }

    public Estacion obtener(Integer codigo) {
        if (codigo == null) {
            return null;
        }
        return estacionRepository.findById(codigo).orElse(null);
    }

    public long contar() {
        return estacionRepository.count();
    }

    public long contarRutas(Integer estacionCodigo) {
        return rutaRepository.countByEstacionCodigo(estacionCodigo);
    }

    @Transactional
    public Estacion guardar(Estacion estacion) {
        estacion.setActualizado(java.time.LocalDateTime.now());
        return estacionRepository.save(estacion);
    }

    /**
     * Elimina una estacion. Se bloquea si aun tiene rutas turisticas asociadas
     * para no dejar zonas huerfanas (integridad exigida por el CU-04).
     */
    @Transactional
    public void eliminar(Integer codigo) {
        if (rutaRepository.countByEstacionCodigo(codigo) > 0) {
            throw new IllegalStateException(
                    "No se puede eliminar: la estación tiene rutas turísticas asociadas.");
        }
        estacionRepository.deleteById(codigo);
    }
}
