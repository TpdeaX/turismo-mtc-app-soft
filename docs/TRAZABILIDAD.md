# Matriz de Trazabilidad — Plataforma de Zonas Turísticas MTC

Enlaza cada elemento del informe con el artefacto de software que lo implementa.
Sirve como evidencia de cobertura para la fase de pruebas de la metodología en cascada.

---

## 1. Requerimientos Funcionales

| RF | Requerimiento | Implementación (backend) | Interfaz | Prioridad AHP |
|----|---------------|--------------------------|----------|---------------|
| RF01 | Ingreso de preferencias turísticas | `PreferenciasSesion`, `CategoriaService`, `PortalController.guardarPreferencias` | `portal/inicio.jsp`, modal de preferencias en `portal/explorar.jsp` | MEDIA |
| RF02 | Selección de estación de partida | `EstacionService.listar`, `PortalController.explorar` | Selector en `portal/inicio.jsp` y `portal/explorar.jsp` | MEDIA |
| RF03 | Consulta de zonas por estación, filtrada | `RecomendacionService.consultarZonas`, `ZonaTuristicaRepository.listarPorEstacion` | Cuadrícula de resultados en `portal/explorar.jsp` | BAJA |
| RF04 | Visualización del pronóstico climático | `ClimaService.obtenerHoy` / `obtenerPronostico` | Bloque de clima en `portal/explorar.jsp` y `portal/detalle.jsp` | ALTA |
| RF05 | Visualización de la ruta caminable recomendada | `RecomendacionService.calcularRuta`, `RutaService.calcularMinutosIdaVuelta` | Línea de tiempo del recorrido en `portal/detalle.jsp` | ALTA |
| RF06 | Visualización de datos ferroviarios | `FerroviarioService.listarHorariosPorEstacion` | Tabla desplegable en `portal/detalle.jsp`, modal de horarios en `portal/explorar.jsp` | MEDIA |
| RF07 | Generación de informe consolidado | `InformeService.generar`, `InformePdfService.generar` | `portal/informe.jsp` y descarga PDF | BAJA |
| RF08 | CRUD de zonas turísticas (Travel Group) | `ZonaTuristicaService`, `ZonaPanelController` | `panel/zonas.jsp` con modales de alta, edición y eliminación | BAJA |
| RF09 | Consulta del listado de estaciones | `EstacionService.buscar`, `FerroviarioPanelController.estaciones` | `panel/estaciones.jsp` (solo lectura salvo Admin) | MEDIA |
| RF10 | Obtención periódica de datos de PeruRail | `PeruRailSyncService`, `DatasetPeruRail`, `IntegracionScheduler` | `panel/integraciones.jsp` | ALTA |
| RF11 | Obtención periódica del pronóstico SENAMHI | `SenamhiSyncService`, `IntegracionScheduler` | `panel/integraciones.jsp` | ALTA |
| RF12 | Panel de configuración para gestores | `ConfiguracionService`, `ConfiguracionPanelController` | `panel/parametros.jsp` | BAJA |
| RF13 | CRUD de horarios y precios ferroviarios | `FerroviarioService`, `FerroviarioPanelController` | `panel/ferroviario.jsp` con modales y ajuste masivo de tarifas | — |

---

## 2. Requerimientos No Funcionales

| RNF | Requerimiento | Cómo se cumple |
|-----|---------------|----------------|
| RNF01 | Diseño web responsive | `theme.css` §19: puntos de corte en 1100, 960 y 760 px. La barra lateral pasa a cajón, los modales a hojas inferiores y las tablas conservan desplazamiento horizontal propio. |
| RNF02 | Actualización diaria de datos | `IntegracionScheduler.sincronizacionDiaria` con `@Scheduled(cron = "0 0 3 * * *", zone = "America/Lima")`, configurable en `app.integracion.cron`. |
| RNF03 | Tiempo de respuesta menor a 2 segundos | Los datos externos se consultan de la base local, nunca en línea durante la petición del usuario. Las consultas usan `JOIN FETCH` para evitar el problema N+1. |
| RNF04 | Usabilidad y accesibilidad | Flujo guiado en dos pasos, estados vacíos explicativos, `aria-expanded` en las filas desplegables, `aria-modal` y cierre con `Escape` en los modales, foco automático, y respeto de `prefers-reduced-motion`. |
| RNF05 | Disponibilidad de la integración externa | Bitácora `SincronizacionLog` con estado, duración y mensaje de cada ejecución; panel de monitoreo con disparo manual por fuente. |
| RNF06 | Seguridad en accesos administrativos | `AuthFilter` protege todo `/panel/**`; contraseñas cifradas con SHA-256 más sal (`PasswordUtil`); autorización por rol. |
| RNF07 | Portabilidad del informe generado | El mismo informe se entrega en HTML (`portal/informe.jsp`) y en PDF (`InformePdfService`, OpenPDF), más una hoja de impresión en `theme.css` §20. |

---

## 3. Reglas de Negocio

| RN | Regla | Dónde se hace cumplir |
|----|-------|----------------------|
| RN01 | Modelo de trayecto único (ida y vuelta desde la misma estación) | `Ruta.getDistanciaIdaVueltaKm` duplica siempre el tramo; `RutaService.calcularMinutosIdaVuelta` calcula sobre esa distancia; la ruta se ancla a una única `Estacion`, sin campo de destino. |
| RN02 | Fuentes de datos autorizadas | `AuthFilter.tienePermiso` separa los módulos por rol; las estaciones son de solo lectura para Travel Group; `Usuario.UsuRol` modela la separación. |
| RN03 | Actualización periódica obligatoria | `IntegracionScheduler` + banderas `integracion.perurail_activa` / `integracion.senamhi_activa` en el panel de parámetros. |
| RN04 | Alcance exclusivamente peatonal | El tiempo se calcula con una velocidad de caminata (`ruta.velocidad_caminata_kmh`), nunca con una velocidad vehicular. `PronosticoClima.isAptoParaCaminar` evalúa la viabilidad del recorrido a pie. |

---

## 4. Casos de Uso

| CU | Caso de uso | Actor | Controlador | Vista |
|----|-------------|-------|-------------|-------|
| CU-01 | Ingresar preferencias | Usuario final | `PortalController.guardarPreferencias` | `portal/inicio.jsp` |
| CU-02 | Consultar zonas turísticas desde una estación | Usuario final | `PortalController.explorar` | `portal/explorar.jsp` |
| CU-03 | Visualizar pronóstico y ruta caminable | Usuario final | `PortalController.detalleZona`, `InformeController` | `portal/detalle.jsp`, `portal/informe.jsp` |
| CU-04 | Registrar zonas turísticas | Travel Group Perú | `ZonaPanelController` | `panel/zonas.jsp` |
| CU-05 | Consultar listado de estaciones | Travel Group Perú | `FerroviarioPanelController.estaciones` | `panel/estaciones.jsp` |
| CU-06 | Obtener datos de PeruRail | PeruRail (sistema) | `PeruRailSyncService`, `IntegracionScheduler` | `panel/integraciones.jsp` |
| CU-07 | Obtener pronóstico climático del SENAMHI | SENAMHI (sistema) | `SenamhiSyncService`, `IntegracionScheduler` | `panel/integraciones.jsp` |

### Flujos alternativos implementados

| Caso de uso | Flujo alternativo | Implementación |
|-------------|-------------------|----------------|
| CU-01 | Sin selección de preferencias | `RecomendacionService.consultarZonas` devuelve todas las zonas cuando `PreferenciasSesion.isVacio()`. |
| CU-02 | Estación sin zonas registradas | Estado vacío diferenciado en `portal/explorar.jsp`, distinguiendo "sin zonas" de "sin coincidencias con el filtro". |
| CU-03 | Clima no disponible | `InformeService.generar` marca `climaDisponible = false` y entrega el informe con los datos turísticos y ferroviarios más el aviso correspondiente. |
| CU-04 | Eliminación de zona turística | Modal de confirmación explícita en `panel/zonas.jsp`, con alternativa no destructiva de ocultar la zona. |
| CU-05 | Sin conexión con PeruRail | `panel/estaciones.jsp` muestra el último listado almacenado y la columna "Actualizada" con su antigüedad relativa. |
| CU-06 | Fallo en la sincronización | `PeruRailSyncService` captura la excepción, conserva los datos previos y registra el incidente como `FALLO`. |
| CU-07 | Fallo en la sincronización | `ClimaService.obtenerHoy` recurre al último pronóstico válido; la vista informa la fecha de la última actualización exitosa. |

---

## 5. Análisis de riesgos

| Riesgo del informe | Mitigación implementada |
|--------------------|------------------------|
| Caída o demora en la actualización de SENAMHI o PeruRail | Caché en `PronosticoClima` y persistencia de la última información válida; la interfaz muestra siempre la fecha de vigencia del dato. |
| Registro de información incompleta por Travel Group Perú | `ZonaTuristicaService.validar` impone nombre, ruta y al menos una categoría, y respeta los límites de longitud del diccionario. El estado `ZoTuEstado` permite revisar antes de publicar. |
| Tiempos de respuesta superiores a 2 segundos | Las fuentes externas se consultan fuera de la petición del usuario, en una tarea programada. Las consultas de lectura usan `JOIN FETCH`. |

---

## 6. Cobertura de pruebas automatizadas

| Clase de prueba | Qué verifica |
|-----------------|--------------|
| `RutaServiceTest` | RN01 (cálculo de ida y vuelta), recargo por dificultad, normalización de niveles y formato de duración. |
| `ZonaTuristicaServiceTest` | RF08 / CU-04: campos obligatorios, vínculo con la ruta, categoría mínima y límites del diccionario de datos. |

```bash
mvn test
```
