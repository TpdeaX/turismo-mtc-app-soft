package com.zonasturisticas.plataforma.services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zonasturisticas.plataforma.beans.Configuracion;
import com.zonasturisticas.plataforma.beans.Empresa;
import com.zonasturisticas.plataforma.repositories.ConfiguracionRepository;
import com.zonasturisticas.plataforma.repositories.EmpresaRepository;

import jakarta.annotation.PostConstruct;

@Service
public class ConfiguracionService {

    @Autowired
    private ConfiguracionRepository configuracionRepository;

    @Autowired
    private EmpresaRepository empresaRepository;

    public List<Configuracion> findAll() {
        return configuracionRepository.findAll();
    }

    public Configuracion findByClave(String clave) {
        return configuracionRepository.findByClave(clave);
    }

    public String getValor(String clave) {
        Configuracion conf = configuracionRepository.findByClave(clave);
        return conf != null ? conf.getValor() : null;
    }

    /**
     * Obtiene el valor de una configuración para una empresa específica.
     * Si no existe configuración específica de empresa, retorna la global.
     */
    public String getValor(String clave, Integer empresaId) {
        if (empresaId != null) {
            Configuracion conf = configuracionRepository.findByClaveAndEmpresaId(clave, empresaId);
            if (conf != null) {
                return conf.getValor();
            }
        }
        // Fallback a configuración global
        Configuracion global = configuracionRepository.findByClaveAndEmpresaIsNull(clave);
        return global != null ? global.getValor() : null;
    }

    public void guardar(Configuracion configuracion) {
        Configuracion existing = configuracionRepository.findByClave(configuracion.getClave());
        if (existing != null) {
            existing.setValor(configuracion.getValor());
            configuracionRepository.save(existing);
        } else {
            configuracionRepository.save(configuracion);
        }
    }

    public void actualizarValor(String clave, String valor) {
        Configuracion conf = configuracionRepository.findByClave(clave);
        if (conf != null) {
            conf.setValor(valor);
            configuracionRepository.save(conf);
        }
    }

    /**
     * Actualiza valor de configuración para una empresa específica.
     * Si la empresa es null, actualiza la configuración global.
     */
    public void actualizarValor(String clave, String valor, Integer empresaId) {
        Configuracion conf;
        if (empresaId != null) {
            conf = configuracionRepository.findByClaveAndEmpresaId(clave, empresaId);
            if (conf == null) {
                // Crear nueva configuración para esta empresa basada en la global
                Configuracion global = configuracionRepository.findByClaveAndEmpresaIsNull(clave);
                if (global != null) {
                    Empresa empresa = empresaRepository.findById(empresaId).orElse(null);
                    conf = new Configuracion(clave, valor, global.getDescripcion(), global.getTipo(), empresa);
                    configuracionRepository.save(conf);
                    return;
                }
            }
        } else {
            conf = configuracionRepository.findByClaveAndEmpresaIsNull(clave);
        }

        if (conf != null) {
            conf.setValor(valor);
            configuracionRepository.save(conf);
        }
    }

    public Map<String, String> getAllAsMap() {
        List<Configuracion> configs = configuracionRepository.findByEmpresaIsNull();
        Map<String, String> map = new HashMap<>();
        for (Configuracion c : configs) {
            map.put(c.getClave(), c.getValor());
        }
        return map;
    }

    /**
     * Obtiene todas las configuraciones como mapa para una empresa específica.
     * Si empresaId es null, retorna solo configuraciones globales.
     * Si empresaId tiene valor, retorna configs de empresa, con fallback a
     * globales.
     */
    public Map<String, String> getAllAsMap(Integer empresaId) {
        // Primero obtener configuraciones globales
        Map<String, String> map = new HashMap<>();
        List<Configuracion> globales = configuracionRepository.findByEmpresaIsNull();
        for (Configuracion c : globales) {
            map.put(c.getClave(), c.getValor());
        }

        // Si hay empresa específica, sobrescribir con sus configuraciones
        if (empresaId != null) {
            List<Configuracion> empresaConfigs = configuracionRepository.findByEmpresaId(empresaId);
            for (Configuracion c : empresaConfigs) {
                map.put(c.getClave(), c.getValor());
            }
        }

        return map;
    }

    @PostConstruct
    public void initDefaults() {
        createIfNotExists("descuento_falta_enabled", "true", "Habilitar descuento por faltas", "BOOLEAN");
        createIfNotExists("descuento_tardanza_enabled", "true", "Habilitar descuento por tardanzas", "BOOLEAN");
        createIfNotExists("ui_blur_modal", "true", "Activar efecto blur en fondo de modales", "BOOLEAN");

        createIfNotExists("asistencia_hora_entrada", "08:00", "Hora de entrada por defecto", "TIME");
        createIfNotExists("asistencia_tolerancia", "15", "Minutos de tolerancia para tardanza", "NUMBER");
        createIfNotExists("asistencia_permitir_extras", "false", "Permitir horas extras", "BOOLEAN");
    }

    private void createIfNotExists(String clave, String valor, String descripcion, String tipo) {
        if (configuracionRepository.findByClaveAndEmpresaIsNull(clave) == null) {
            configuracionRepository.save(new Configuracion(clave, valor, descripcion, tipo));
        }
    }
}
