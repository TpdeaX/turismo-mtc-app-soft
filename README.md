# <img src="https://icongr.am/feather/map.svg?size=36&color=0366d6" align="center"> Plataforma de Zonas Turísticas - MTC

![Status](https://img.shields.io/badge/Status-En%20Desarrollo-yellow)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.3-brightgreen)
![Java](https://img.shields.io/badge/Java-21-blue)

Plataforma Software Web orientada a fomentar el uso del transporte público y el turismo local, desarrollada por disposición del **Ministerio de Transportes y Comunicaciones (MTC)**.

El sistema funciona como un asesor especializado que proporciona a los usuarios rutas turísticas diseñadas para realizarse exclusivamente a pie desde diversas estaciones ferroviarias, integrando información en tiempo real.

## <img src="https://icongr.am/feather/star.svg?size=24&color=0366d6" align="center"> Características Principales

*   **<img src="https://icongr.am/feather/database.svg?size=16&color=555555" align="center"> Integración de Datos:**
    *   **PeruRail:** Estaciones, horarios, tiempos de recorrido y precios.
    *   **SENAMHI:** Pronóstico climático por zona geográfica.
    *   **Travel Group Perú:** Gestión y consulta de zonas turísticas.
*   **<img src="https://icongr.am/feather/users.svg?size=16&color=555555" align="center"> Módulo de Usuario Final:**
    *   Ingreso de preferencias turísticas (ej. naturaleza, historia, aventura).
    *   Visualización de rutas recomendadas, dificultad, clima y precios.
*   **<img src="https://icongr.am/feather/file-text.svg?size=16&color=555555" align="center"> Módulo de Informes:**
    *   Generación de reportes turísticos personalizados en formato PDF/HTML.
*   **<img src="https://icongr.am/feather/settings.svg?size=16&color=555555" align="center"> Módulo Administrativo:**
    *   Gestión (CRUD) de Zonas Turísticas, Estaciones, y Horarios.

## <img src="https://icongr.am/feather/layers.svg?size=24&color=0366d6" align="center"> Arquitectura (Por Definir)

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

## <img src="https://icongr.am/feather/check-circle.svg?size=24&color=0366d6" align="center"> Requisitos Previos

*   Java 21
*   Maven 3.8+
*   MySQL 8.0+

## <img src="https://icongr.am/feather/tool.svg?size=24&color=0366d6" align="center"> Configuración del Entorno

1. Clonar el repositorio.
2. Configurar las variables de entorno en el archivo `application.properties` para la conexión a la base de datos MySQL.
3. Ejecutar el proyecto mediante Maven:
   ```bash
   mvn spring-boot:run
   ```

## <img src="https://icongr.am/feather/layout.svg?size=24&color=0366d6" align="center"> UI / Estilos

Este repositorio base ya incluye los estilos estandarizados aprobados para el proyecto. Los recursos estáticos (CSS, JS, imágenes base) se encuentran listos para ser integrados en las vistas finales.

---
*Desarrollado para la asignatura de Ingeniería de Software - CPIS Ingeniería de Sistemas.*
