package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.repositories.CategoriaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** RF01: catalogo de preferencias turisticas disponibles. */
@Service
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    public CategoriaService(CategoriaRepository categoriaRepository) {
        this.categoriaRepository = categoriaRepository;
    }

    /** CU-01 paso 2: categorias que se despliegan al turista. */
    public List<Categoria> listarDisponibles() {
        return categoriaRepository.findByEstadoTrueOrderByNombreAsc();
    }

    public List<Categoria> listarTodas() {
        return categoriaRepository.findAllByOrderByNombreAsc();
    }

    public Categoria obtener(Integer codigo) {
        return codigo == null ? null : categoriaRepository.findById(codigo).orElse(null);
    }

    public Set<Categoria> obtenerVarias(Collection<Integer> codigos) {
        Set<Categoria> resultado = new LinkedHashSet<>();
        if (codigos == null) {
            return resultado;
        }
        for (Integer codigo : codigos) {
            Categoria c = obtener(codigo);
            if (c != null) {
                resultado.add(c);
            }
        }
        return resultado;
    }

    public long contar() {
        return categoriaRepository.count();
    }

    @Transactional
    public Categoria guardar(Categoria categoria) {
        return categoriaRepository.save(categoria);
    }

    @Transactional
    public void eliminar(Integer codigo) {
        categoriaRepository.deleteById(codigo);
    }
}
