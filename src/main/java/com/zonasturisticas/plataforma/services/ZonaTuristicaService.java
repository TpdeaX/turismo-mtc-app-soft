package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.repositories.ZonaTuristicaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;

/**
 * RF08 / CU-04: registro, actualizacion y eliminacion (CRUD) de zonas
 * turisticas por parte de Travel Group Peru.
 *
 * Mitigacion del riesgo "registro de informacion incompleta": el metodo
 * {@link #validar} impone los campos obligatorios antes de persistir.
 */
@Service
public class ZonaTuristicaService {

    private final ZonaTuristicaRepository zonaRepository;
    private final CategoriaService categoriaService;

    public ZonaTuristicaService(ZonaTuristicaRepository zonaRepository, CategoriaService categoriaService) {
        this.zonaRepository = zonaRepository;
        this.categoriaService = categoriaService;
    }

    public List<ZonaTuristica> listar() {
        return zonaRepository.listarCompleto();
    }

    public List<ZonaTuristica> listarActivas() {
        return zonaRepository.listarActivas();
    }

    /** CU-02 paso 4: zonas vinculadas a la estacion seleccionada. */
    public List<ZonaTuristica> listarPorEstacion(Integer estacionCodigo) {
        return zonaRepository.listarPorEstacion(estacionCodigo);
    }

    public ZonaTuristica obtener(Integer codigo) {
        return codigo == null ? null : zonaRepository.findById(codigo).orElse(null);
    }

    public long contar() {
        return zonaRepository.count();
    }

    public long contarActivas() {
        return zonaRepository.countByEstadoTrue();
    }

    /**
     * CU-04 paso 6: valida los datos antes de almacenar o actualizar.
     * Devuelve la lista de errores encontrados; vacia si el registro es valido.
     */
    public List<String> validar(ZonaTuristica zona) {
        List<String> errores = new ArrayList<>();
        if (zona.getNombre() == null || zona.getNombre().isBlank()) {
            errores.add("El nombre de la zona turística es obligatorio.");
        } else if (zona.getNombre().length() > 100) {
            errores.add("El nombre no puede superar los 100 caracteres.");
        }
        if (zona.getDescripcion() != null && zona.getDescripcion().length() > 500) {
            errores.add("La descripción no puede superar los 500 caracteres.");
        }
        if (zona.getRuta() == null) {
            errores.add("Debe vincular la zona a una ruta de una estación ferroviaria.");
        }
        if (zona.getCategorias() == null || zona.getCategorias().isEmpty()) {
            errores.add("Seleccione al menos una categoría de preferencia turística.");
        }
        return errores;
    }

    @Transactional
    public ZonaTuristica guardar(ZonaTuristica zona, Collection<Integer> categoriaCodigos) {
        Set<Categoria> categorias = categoriaService.obtenerVarias(categoriaCodigos);
        zona.setCategorias(categorias);

        List<String> errores = validar(zona);
        if (!errores.isEmpty()) {
            throw new IllegalArgumentException(String.join(" ", errores));
        }
        return zonaRepository.save(zona);
    }

    /** CU-04 flujo alternativo: eliminacion previa confirmacion del gestor. */
    @Transactional
    public void eliminar(Integer codigo) {
        zonaRepository.deleteById(codigo);
    }

    /** Publica o retira la zona del listado disponible para el usuario final. */
    @Transactional
    public ZonaTuristica alternarEstado(Integer codigo) {
        ZonaTuristica zona = obtener(codigo);
        if (zona == null) {
            throw new IllegalArgumentException("La zona turistica no existe.");
        }
        zona.setEstado(!zona.isEstado());
        return zonaRepository.save(zona);
    }
}
