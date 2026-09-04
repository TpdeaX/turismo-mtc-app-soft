package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Configuracion;
import com.zonasturisticas.plataforma.repositories.ConfiguracionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * RF12: panel de configuracion de parametros generales de la plataforma.
 */
@Service
public class ConfiguracionService {

    private final ConfiguracionRepository configuracionRepository;

    public ConfiguracionService(ConfiguracionRepository configuracionRepository) {
        this.configuracionRepository = configuracionRepository;
    }

    public List<Configuracion> listar() {
        return configuracionRepository.findAllByOrderByGrupoAscClaveAsc();
    }

    /** Parametros agrupados para renderizar el panel por secciones. */
    public Map<String, List<Configuracion>> listarAgrupado() {
        Map<String, List<Configuracion>> mapa = new LinkedHashMap<>();
        for (Configuracion c : listar()) {
            mapa.computeIfAbsent(c.getGrupo(), k -> new java.util.ArrayList<>()).add(c);
        }
        return mapa;
    }

    public Configuracion obtener(String clave) {
        return configuracionRepository.findById(clave).orElse(null);
    }

    public String getTexto(String clave, String porDefecto) {
        Configuracion c = obtener(clave);
        return (c == null || c.getValor() == null || c.getValor().isBlank()) ? porDefecto : c.getValor();
    }

    public double getDouble(String clave, double porDefecto) {
        try {
            return Double.parseDouble(getTexto(clave, String.valueOf(porDefecto)));
        } catch (NumberFormatException e) {
            return porDefecto;
        }
    }

    public int getEntero(String clave, int porDefecto) {
        try {
            return Integer.parseInt(getTexto(clave, String.valueOf(porDefecto)));
        } catch (NumberFormatException e) {
            return porDefecto;
        }
    }

    public boolean getBooleano(String clave, boolean porDefecto) {
        String v = getTexto(clave, String.valueOf(porDefecto));
        return "true".equalsIgnoreCase(v) || "1".equals(v);
    }

    @Transactional
    public Configuracion guardar(Configuracion configuracion) {
        configuracion.setActualizado(LocalDateTime.now());
        return configuracionRepository.save(configuracion);
    }

    @Transactional
    public void actualizarValor(String clave, String valor) {
        Configuracion c = obtener(clave);
        if (c != null) {
            c.setValor(valor);
            c.setActualizado(LocalDateTime.now());
            configuracionRepository.save(c);
        }
    }

    /** Guarda de una sola vez todos los parametros enviados por el panel. */
    @Transactional
    public int actualizarLote(Map<String, String> valores) {
        int actualizados = 0;
        for (Map.Entry<String, String> e : valores.entrySet()) {
            Configuracion c = obtener(e.getKey());
            if (c != null) {
                c.setValor(e.getValue());
                c.setActualizado(LocalDateTime.now());
                configuracionRepository.save(c);
                actualizados++;
            }
        }
        return actualizados;
    }

    /** Crea el parametro solo si aun no existe (usado por el sembrador). */
    @Transactional
    public void registrarSiFalta(String clave, String valor, String descripcion, String tipo, String grupo) {
        if (!configuracionRepository.existsById(clave)) {
            configuracionRepository.save(new Configuracion(clave, valor, descripcion, tipo, grupo));
        }
    }

    @Transactional
    public void eliminar(String clave) {
        configuracionRepository.deleteById(clave);
    }
}
