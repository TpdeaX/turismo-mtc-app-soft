package com.zonasturisticas.plataforma.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Configuracion de la capa de presentacion y habilitacion de las tareas
 * programadas de integracion (RNF02 / RNF05).
 */
@Configuration
@EnableScheduling
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/assets/**")
                .addResourceLocations("/assets/", "classpath:/static/assets/")
                .setCachePeriod(3600);

        // RF08: imagenes de zonas turisticas subidas desde el panel (fuera del WAR).
        // El directorio debe existir ANTES de pedirle la URI: Path.toUri() solo
        // agrega la barra final (necesaria para que Spring resuelva recursos
        // dentro de el) cuando puede comprobar que la ruta ya es un directorio.
        Path directorio = Path.of(uploadDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(directorio);
        } catch (IOException e) {
            throw new UncheckedIOException("No se pudo crear el directorio de subidas: " + directorio, e);
        }
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(directorio.toUri().toString())
                .setCachePeriod(3600);
    }
}
