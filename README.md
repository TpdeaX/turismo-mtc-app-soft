# Plataforma de Zonas Turísticas — MTC

![Estado](https://img.shields.io/badge/Estado-Funcional-2E7D5B)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.3-6DB33F)
![Java](https://img.shields.io/badge/Java-17-0A1F3D)
![Vistas](https://img.shields.io/badge/Vistas-JSP%20%2B%20JSTL-F5C518)
![BD](https://img.shields.io/badge/BD-MySQL%208%20%2F%20H2-1B4278)

Plataforma software web dispuesta por el **Ministerio de Transportes y Comunicaciones (MTC)**
para fomentar el uso del transporte público y el turismo local.

Funciona como un **asesor turístico especializado**: cruza el pronóstico del **SENAMHI**, la
logística ferroviaria de **PeruRail** y las zonas turísticas levantadas por **Travel Group Perú**
para recomendar al viajero rutas **exclusivamente peatonales, de un solo tramo de ida y vuelta**,
partiendo desde la estación ferroviaria que elija.

---

## Puesta en marcha

### Opción A — Demo inmediata (sin instalar base de datos)

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=demo
```

Levanta H2 en memoria, siembra el catálogo completo (8 estaciones, 13 rutas, 17 zonas,
7 servicios ferroviarios y 40 pronósticos) y queda disponible en <http://localhost:8081>.
La consola de H2 está en `/h2-console` (`jdbc:h2:mem:turismo`, usuario `sa`, sin contraseña).

### Opción B — MySQL (entorno del informe)

Requiere MySQL 8. La base `turismo_mtc` se crea sola gracias a `createDatabaseIfNotExist=true`.

```bash
mvn spring-boot:run
```

Credenciales por defecto: `root` / `123456`. Se sobreescriben con variables de entorno:

| Variable  | Por defecto   |
|-----------|---------------|
| `DB_HOST` | `localhost`   |
| `DB_PORT` | `3306`        |
| `DB_NAME` | `turismo_mtc` |
| `DB_USER` | `root`        |
| `DB_PASS` | `123456`      |

### Pruebas

```bash
mvn test
```

---

## Accesos

El **portal del turista es de acceso libre** (precondición del CU-01: basta con ingresar a la
plataforma). Solo el panel administrativo exige autenticación (RNF06).

| Rol | Correo | Contraseña | Puede administrar |
|-----|--------|-----------|-------------------|
| Administrador MTC | `admin@mtc.gob.pe` | `admin123` | Todo, incluidos parámetros y gestores |
| Travel Group Perú | `gestor@travelgroup.pe` | `travel123` | Zonas, rutas y categorías. Estaciones en solo lectura |
| PeruRail | `operaciones@perurail.com` | `rail123` | Servicios, horarios y tarifas |

> Las contraseñas se almacenan cifradas con SHA-256 más sal de aplicación.

---

## Recorrido funcional

### Portal del turista

| Ruta | Caso de uso | Qué hace |
|------|-------------|----------|
| `/` | — | Portada con el planificador en dos pasos |
| `POST /preferencias` | CU-01 | Guarda las preferencias en la sesión de consulta (RF01) |
| `/explorar?estacion=N` | CU-02 | Selecciona la estación (RF02) y lista las zonas filtradas (RF03) |
| `/zona/{id}` | CU-03 | Clima SENAMHI (RF04), ruta caminable (RF05) y datos ferroviarios (RF06) |
| `/informe/{id}` | CU-03 | Informe consolidado en HTML (RF07) |
| `/informe/{id}/pdf` | CU-03 | El mismo informe en PDF (RNF07) |

### Panel administrativo

| Ruta | Caso de uso | Rol |
|------|-------------|-----|
| `/panel` | — | Todos |
| `/panel/zonas` | CU-04 | Travel Group / Admin |
| `/panel/rutas` | RF05 | Travel Group / Admin |
| `/panel/categorias` | RF01 | Travel Group / Admin |
| `/panel/estaciones` | CU-05 | Todos (edición solo Admin) |
| `/panel/ferroviario` | RF13 | PeruRail / Admin |
| `/panel/parametros` | RF12 | Admin |
| `/panel/gestores` | RNF06 | Admin |
| `/panel/integraciones` | CU-06 / CU-07 | Todos |

---

## Integración con las fuentes externas

Los procesos de los **CU-06** y **CU-07** se ejecutan mediante una tarea programada
(`@Scheduled`, por defecto a las 03:00 hora de Lima) y también pueden dispararse a mano desde
`/panel/integraciones`.

Ambos siguen el mismo ciclo que exige el informe: **obtener → validar formato e integridad →
almacenar**, dejando registro en la bitácora `SincronizacionLog`.

### Modo de operación

`app.integracion.modo=SIMULADO` (valor por defecto). Las fuentes externas se representan
localmente:

- **PeruRail** → `DatasetPeruRail`, construido con la información pública real del corredor sur
  (Vistadome, Expedition, Hiram Bingham, Andean Explorer, Titicaca, Valle Sagrado).
- **SENAMHI** → generador determinista por estación y fecha, que considera la altitud típica de
  la región y la temporada seca/lluviosa peruana, de modo que dos consultas del mismo día
  devuelven el mismo pronóstico.

`PeruRailSyncService` y `SenamhiSyncService` están aislados detrás de esa frontera: sustituirlos
por un cliente HTTP real no obliga a tocar el resto de la plataforma.

### Tolerancia a fallos

Si una fuente no responde, la plataforma **conserva la última información válida almacenada**,
registra el incidente en la bitácora y muestra al usuario la fecha de la última actualización
exitosa — exactamente el flujo alternativo descrito en los CU-06 y CU-07 y la mitigación
planteada en el análisis de riesgos.

---

## Arquitectura

Arquitectura **en capas**, como establece la sección 2.1 del informe.

```text
src/main/java/com/zonasturisticas/plataforma/
├── beans/                      Entidades JPA (columnas del diccionario de datos)
├── repositories/               Acceso a datos (Spring Data JPA)
├── services/                   Lógica de negocio
│   └── integracion/            Adaptadores de PeruRail y SENAMHI + planificador
├── controllers/                Capa de presentación (MVC)
│   └── api/                    Endpoints JSON para modales y tablas desplegables
├── dto/                        Objetos de transferencia
├── config/                     Configuración web y atributos globales de vista
├── filters/                    AuthFilter: autenticación y autorización por rol
├── util/                       Funciones de presentación expuestas a las JSP
└── init/                       Carga inicial de datos

src/main/webapp/
├── assets/css/theme.css        Sistema de diseño completo
├── assets/js/app.js            Modales, tablas desplegables, toasts, tema
├── WEB-INF/mtc.tld             Funciones EL de formato
└── views/
    ├── shared/                 Cabecera, navegación, barra lateral, pie
    ├── portal/                 Inicio, explorar, detalle, informe
    ├── acceso/                 Inicio de sesión
    └── panel/                  Nueve módulos administrativos
```

### Decisiones de diseño relevantes

- **El tiempo estimado de una ruta nunca se ingresa a mano.** Se deriva de la distancia del tramo,
  duplicada por el retorno (RN01), dividida por la velocidad de caminata configurable en el panel
  de parámetros (RF12) y ajustada por un recargo según la dificultad (+15 % moderada, +35 % alta).
- **El informe consolidado se genera al vuelo**, no se persiste. Cada consulta produce un folio
  propio con la marca de tiempo.
- **El pronóstico climático se cachea en base de datos** (`PronosticoClima`). Esa tabla *es* el
  mecanismo de tolerancia a fallos del CU-07.

---

## Sistema de diseño

La interfaz fusiona dos fuentes:

- Las **maquetas aprobadas del propio informe** (sección 2.5) y la identidad visual de PeruRail:
  azul marino institucional `#0A1F3D`, ámbar de acento `#F5C518`, fondo `#F4F7FB`, fotografía a
  sangre, tarjetas flotantes y tipografía editorial (*Fraunces* para titulares, *Inter* para la
  interfaz).
- La **arquitectura del tema previo del repositorio**: tokens semánticos tipo Material Design 3,
  modo oscuro por atributo `data-theme`, escala de elevación, toasts, animación escalonada de
  filas de tabla y barra de desplazamiento propia.

Todo está construido sin dependencias de terceros en el navegador (salvo la fuente de iconos
Material Symbols): los modales, las tablas desplegables, los interruptores y las notificaciones
son componentes propios en `theme.css` + `app.js`.

**Componentes destacados**

- **Modales completos** para alta, edición, eliminación y acciones masivas en cada módulo, con
  precarga automática de datos vía atributos `data-set-*`, selects en cascada y confirmación
  explícita en los borrados.
- **Tablas con filas desplegables** (`data-expand`) que revelan el detalle sin recargar la página;
  en el detalle ferroviario el contenido se carga bajo demanda desde `/api/servicios/{id}/horarios`.
- **Modo claro y oscuro** con persistencia en `localStorage` y sin destello al cargar.
- **Diseño adaptable** (RNF01): en móvil la barra lateral se convierte en cajón, los modales en
  hojas inferiores y las tablas conservan desplazamiento horizontal propio.

---

## Documentación complementaria

- [`docs/DICCIONARIO_DE_DATOS.md`](docs/DICCIONARIO_DE_DATOS.md) — diccionario actualizado, con las
  tablas originales del informe y las de extensión, listo para incorporarse al documento.
- [`docs/TRAZABILIDAD.md`](docs/TRAZABILIDAD.md) — matriz que enlaza cada RF, RNF, RN y CU con la
  clase y la vista que lo implementan.

---

## Requisitos previos

- Java 17
- Maven 3.8+
- MySQL 8 *(solo para el perfil por defecto; el perfil `demo` no lo necesita)*

---

*Desarrollado para la asignatura de Ingeniería de Software — CPIS Ingeniería de Sistemas.*
