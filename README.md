# Plataforma de Zonas Turísticas - MTC

![Status](https://img.shields.io/badge/Status-En%20Desarrollo-yellow)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.3-brightgreen)
![Java](https://img.shields.io/badge/Java-21-blue)

Plataforma Software Web orientada a fomentar el uso del transporte público y el turismo local, desarrollada por disposición del **Ministerio de Transportes y Comunicaciones (MTC)**.

El sistema funciona como un asesor especializado que proporciona a los usuarios rutas turísticas diseñadas para realizarse exclusivamente a pie desde diversas estaciones ferroviarias, integrando información en tiempo real.

## Características Principales

*   **Integración de Datos:**
    *   **PeruRail:** Estaciones, horarios, tiempos de recorrido y precios.
    *   **SENAMHI:** Pronóstico climático por zona geográfica.
    *   **Travel Group Perú:** Gestión y consulta de zonas turísticas.
*   **Módulo de Usuario Final:**
    *   Ingreso de preferencias turísticas (ej. naturaleza, historia, aventura).
    *   Visualización de rutas recomendadas, dificultad, clima y precios.
*   **Módulo de Informes:**
    *   Generación de reportes turísticos personalizados en formato PDF/HTML.
*   **Módulo Administrativo:**
    *   Gestión (CRUD) de Zonas Turísticas, Estaciones, y Horarios.

## Arquitectura (Por Definir)

> **Nota:** La arquitectura final (Monolito, Microservicios, etc.) y el framework del Frontend (JSP, Angular, React) están pendientes de definición por el equipo de arquitectura. La base actual utiliza Spring Boot.

### Estructura Base del Proyecto

```text
src/main/java/com/zonasturisticas/plataforma/
 ├── config/         # Configuraciones de seguridad, CORS, beans, etc.
 ├── controllers/    # Controladores REST y MVC
 ├── models/         # Entidades de dominio (JPA/Hibernate)
 ├── repositories/   # Interfaces de acceso a datos (Spring Data JPA)
 ├── services/       # Lógica de negocio e integración con APIs externas (SENAMHI, PeruRail)
 └── dto/            # Data Transfer Objects
```

## Requisitos Previos

*   Java 21
*   Maven 3.8+
*   MySQL 8.0+

## Configuración del Entorno

1. Clonar el repositorio.
2. Configurar las variables de entorno en el archivo `application.properties` para la conexión a la base de datos MySQL.
3. Ejecutar el proyecto mediante Maven:
   ```bash
   mvn spring-boot:run
   ```

## UI / Estilos

Este repositorio base ya incluye los estilos estandarizados aprobados para el proyecto. Los recursos estáticos (CSS, JS, imágenes base) se encuentran listos para ser integrados en las vistas finales.

---
*Desarrollado para la asignatura de Ingeniería de Software - CPIS Ingeniería de Sistemas.*
