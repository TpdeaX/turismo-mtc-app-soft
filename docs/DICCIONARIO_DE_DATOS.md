# Diccionario de Datos — Plataforma de Zonas Turísticas MTC

> Actualiza la sección **2.4 Diccionario de Datos** del informe.
>
> Las seis tablas originales conservan **exactamente** los nombres definidos en el documento.
> Los atributos añadidos se señalan con **(+)** y responden a requerimientos que el modelo inicial
> no cubría. Al final se listan las cuatro tablas de extensión.

---

## 1. Tablas del modelo original

### Tabla: `Estacion`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| EstCodigo | int | PK | No nulo | Identificador único de la estación. |
| EstNombre | varchar(50) | – | No nulo | Nombre de la estación. |
| EstUbicacion | varchar(50) | – | No nulo | Ubicación geográfica o dirección de la estación. |
| **(+)** EstRegion | varchar(50) | – | Nulo | Región a la que pertenece. Determina la zona geográfica consultada al SENAMHI (RF11). |
| **(+)** EstLatitud | double | – | Nulo | Latitud de la estación. Necesaria para resolver el pronóstico por zona geográfica (RF04). |
| **(+)** EstLongitud | double | – | Nulo | Longitud de la estación. |
| **(+)** EstConexiones | varchar(150) | – | Nulo | Medios de conexión disponibles en la estación, provistos por PeruRail. |
| **(+)** EstActualizado | datetime | – | Nulo | Marca de la última sincronización exitosa con PeruRail (CU-06). |

---

### Tabla: `Ruta`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| RutaCodigo | int | PK | No nulo | Identificador único de la ruta. |
| EstCodigo | int | FK | No nulo | Estación desde la que parte y a la que retorna la ruta (RN01). |
| RutaDistanciaKm | decimal(8,2) | – | No nulo | Distancia del tramo de ida, en kilómetros. |
| RutaTiempoEstimado | varchar(50) | – | Nulo | Tiempo estimado de ida y vuelta. Se calcula automáticamente, no se ingresa. |
| RutaDificultad | varchar(50) | – | Nulo | Nivel de dificultad del recorrido (Fácil, Moderada, Alta). |
| **(+)** RutaNombre | varchar(100) | – | Nulo | Nombre visible de la ruta en el portal y el panel. |
| **(+)** RutaTrazado | text | – | Nulo | Descripción o secuencia de puntos del trazado peatonal. |

---

### Tabla: `ZonaTuristica`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| ZoTuCodigo | int | PK | No nulo | Identificador único de la zona turística. |
| RutCodigo | int | FK | No nulo | Ruta a la que pertenece la zona. |
| ZoTuNombre | varchar(100) | – | No nulo | Nombre del atractivo o zona turística. |
| ZoTuDescripcion | varchar(500) | – | Nulo | Descripción detallada de las características del lugar. |
| ZoTuUbicacion | varchar(50) | – | Nulo | Referencia específica de la ubicación dentro de la ruta. |
| **(+)** ZoTuImagen | varchar(400) | – | Nulo | URL de la fotografía de portada. Si está vacía, la interfaz genera una portada. |
| **(+)** ZoTuCostoReferencial | decimal(8,2) | – | Nulo | Costo referencial de ingreso al atractivo. El sistema no gestiona su pago. |
| **(+)** ZoTuEstado | boolean | – | No nulo | Indica si la zona está publicada para el usuario final (CU-04). |
| **(+)** ZoTuRegistrado | datetime | – | Nulo | Fecha de registro por Travel Group Perú. |
| **(+)** ZoTuActualizado | datetime | – | Nulo | Fecha de la última actualización. |

---

### Tabla: `ServicioFerroviario`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| SeFeCodigo | int | PK | No nulo | Identificador único del servicio ferroviario. |
| EstCodigoOrigen | int | FK | No nulo | Estación de donde parte el tren. |
| EstCodigoDestino | int | FK | No nulo | Estación donde finaliza el recorrido. |
| SeFeNombre | varchar(50) | – | No nulo | Nombre descriptivo del servicio (ej. "Vistadome 31"). |
| **(+)** SeFeEstado | varchar(20) | – | Nulo | Estado operativo reportado por la fuente (ACTIVO, RETRASO, SUSPENDIDO). |
| **(+)** SeFeCorredor | varchar(50) | – | Nulo | Corredor comercial al que pertenece el servicio. |

---

### Tabla: `HorarioFerroviario`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| HoFeCodigo | int | PK | No nulo | Identificador único del horario programado. |
| SeFeCodigo | int | FK | No nulo | Servicio ferroviario que realiza el recorrido. |
| HoFeHoraSalida | time | – | No nulo | Hora exacta de partida del servicio. |
| HoFeHoraLlegada | time | – | No nulo | Hora exacta de llegada a la estación de destino. |
| HoFeTiempoRecorrido | time | – | Nulo | Duración total del viaje. Se calcula a partir de la salida y la llegada. |
| HoFeTarifa | decimal(8,2) | – | No nulo | Costo del pasaje para este horario específico. |
| **(+)** HoFeFrecuencia | varchar(50) | – | Nulo | Días de operación (ej. "Diario", "Mar, Jue, Dom"). |
| **(+)** HoFeEstado | varchar(20) | – | Nulo | Estado del horario (ACTIVO, RETRASO, SUSPENDIDO). |

---

### Tabla: `Usuario`

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| UsuCodigo | int | PK | No nulo | Identificador único del usuario. |
| UsuCorreo | varchar(100) | – | No nulo | Correo electrónico del gestor (usado para inicio de sesión). |
| UsuPassword | varchar(100) | – | No nulo | Contraseña cifrada con SHA-256 más sal de aplicación. |
| **(+)** UsuNombre | varchar(100) | – | Nulo | Nombre completo del gestor. |
| **(+)** UsuRol | varchar(20) | – | No nulo | ADMIN, TRAVEL_GROUP o PERURAIL. Implementa la separación de la RN02. |
| **(+)** UsuEstado | boolean | – | No nulo | Indica si la cuenta está habilitada. |
| **(+)** UsuUltimoAcceso | datetime | – | Nulo | Fecha del último inicio de sesión. |

> **Nota.** La tabla `Usuario` representa únicamente a los gestores autorizados del panel
> administrativo. El turista **no se autentica**: la precondición del CU-01 solo exige haber
> ingresado a la plataforma, y sus preferencias viven en la sesión de consulta.

---

## 2. Tablas de extensión

Cuatro tablas nuevas que cubren requerimientos no representados en el modelo lógico inicial.

### Tabla: `Categoria` — sustenta RF01 y RF03

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| CatCodigo | int | PK | No nulo | Identificador único de la categoría. |
| CatNombre | varchar(50) | – | No nulo | Nombre de la preferencia (Naturaleza, Historia, Aventura…). |
| CatDescripcion | varchar(200) | – | Nulo | Descripción del tipo de atractivos que agrupa. |
| CatIcono | varchar(50) | – | Nulo | Icono mostrado en el formulario de preferencias. |
| CatColor | varchar(20) | – | Nulo | Color distintivo en la interfaz. |
| CatEstado | boolean | – | No nulo | Indica si se despliega al turista. |

### Tabla: `ZonaCategoria` — relación N:M

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| ZoTuCodigo | int | PK, FK | No nulo | Zona turística. |
| CatCodigo | int | PK, FK | No nulo | Categoría de preferencia asociada. |

Permite que una zona pertenezca a varias categorías y que el filtro del RF03 cuente coincidencias
para ordenar los resultados por relevancia.

### Tabla: `PronosticoClima` — sustenta RF04, RF11 y el flujo alternativo del CU-07

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| PrClCodigo | int | PK | No nulo | Identificador único del pronóstico. |
| EstCodigo | int | FK | No nulo | Estación (zona geográfica) a la que corresponde. |
| PrClFecha | date | – | No nulo | Fecha del pronóstico. Junto a EstCodigo forma una clave única. |
| PrClTemperatura | int | – | Nulo | Temperatura prevista en grados Celsius. |
| PrClTempMin | int | – | Nulo | Temperatura mínima prevista. |
| PrClTempMax | int | – | Nulo | Temperatura máxima prevista. |
| PrClCondicion | varchar(60) | – | Nulo | Condición climática descrita por la fuente. |
| PrClHumedad | int | – | Nulo | Humedad relativa (%). |
| PrClViento | int | – | Nulo | Velocidad del viento (km/h). |
| PrClVientoDir | varchar(5) | – | Nulo | Dirección del viento. |
| PrClProbLluvia | int | – | Nulo | Probabilidad de precipitación (%). |
| PrClIcono | varchar(40) | – | Nulo | Icono asociado a la condición. |
| PrClActualizado | datetime | – | Nulo | Momento en que se almacenó el registro. |

Esta tabla **es** el mecanismo de caché exigido por el análisis de riesgos: si SENAMHI no responde,
el sistema entrega el último pronóstico válido almacenado indicando su fecha.

### Tabla: `SincronizacionLog` — sustenta RNF02 y RNF05

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| SinCodigo | int | PK | No nulo | Identificador único de la ejecución. |
| SinFuente | varchar(20) | – | No nulo | PERURAIL o SENAMHI. |
| SinFecha | datetime | – | No nulo | Momento de la ejecución. |
| SinEstado | varchar(20) | – | No nulo | EXITO o FALLO. |
| SinRegistros | int | – | Nulo | Cantidad de registros procesados. |
| SinDuracionMs | bigint | – | Nulo | Duración de la ejecución en milisegundos. |
| SinMensaje | varchar(300) | – | Nulo | Detalle del resultado o del incidente registrado. |

### Tabla: `Configuracion` — sustenta RF12

| Atributo | Tipo de dato | Llave | Nulo / No nulo | Descripción |
|---|---|---|---|---|
| ConfClave | varchar(60) | PK | No nulo | Identificador del parámetro. |
| ConfValor | varchar(255) | – | Nulo | Valor vigente del parámetro. |
| ConfDescripcion | varchar(255) | – | Nulo | Texto explicativo mostrado en el panel. |
| ConfTipo | varchar(20) | – | Nulo | TEXTO, NUMERO o BOOLEANO. Define el control de edición. |
| ConfGrupo | varchar(40) | – | Nulo | Sección del panel (IDENTIDAD, RUTAS, INTEGRACIONES, PORTAL). |
| ConfActualizado | datetime | – | Nulo | Fecha del último cambio. |

---

## 3. Nota sobre la correspondencia con el código

Las clases Java usan nombres de propiedad legibles (`codigo`, `nombre`, `ubicacion`) y mapean las
columnas físicas mediante `@Column(name = "...")`. El **modelo físico de la base de datos coincide
íntegramente con este diccionario**; la diferencia es únicamente de estilo de codificación.

Para que Hibernate respete los nombres al pie de la letra —y no los convierta a `snake_case`— la
aplicación fija en `application.properties`:

```properties
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

Verificado en MySQL 8:

```text
mysql> DESCRIBE Estacion;
+---------------+-------------+------+-----+
| Field         | Type        | Null | Key |
+---------------+-------------+------+-----+
| EstCodigo     | int         | NO   | PRI |
| EstNombre     | varchar(50) | NO   |     |
| EstUbicacion  | varchar(50) | NO   |     |
| EstRegion     | varchar(50) | YES  |     |
| EstLatitud    | double      | YES  |     |
| EstLongitud   | double      | YES  |     |
| EstConexiones | varchar(150)| YES  |     |
| EstActualizado| datetime(6) | YES  |     |
+---------------+-------------+------+-----+
```

### Dos salvedades del motor

1. **Nombres de tabla en minúscula.** En Windows, MySQL se instala con
   `lower_case_table_names=1`, por lo que almacena los identificadores de tabla en minúscula
   (`zonaturistica` en lugar de `ZonaTuristica`). Es una característica del sistema operativo, no
   del modelo. En Linux se conservan tal cual. Los **nombres de columna sí respetan la
   capitalización** en ambos sistemas.
2. **`time(7)` no existe en MySQL.** El diccionario original declara `HoFeTiempoRecorrido time(7)`,
   sintaxis propia de SQL Server. MySQL admite como máximo `time(6)`, que es la precisión usada.
   `HoFeHoraSalida` y `HoFeHoraLlegada` conservan `time(0)` tal como indica el informe.

Ejemplo:

```java
@Entity
@Table(name = "Estacion")
public class Estacion {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "EstCodigo")
    private Integer codigo;

    @Column(name = "EstNombre", nullable = false, length = 50)
    private String nombre;
}
```
