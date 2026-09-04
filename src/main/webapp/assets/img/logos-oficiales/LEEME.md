# Logotipos oficiales de las entidades

Esta carpeta es **para ti**. Deja aquí los archivos oficiales descargados de cada
entidad. La plataforma los toma automáticamente: no hay que tocar código.

## Archivos que espera la plataforma

| Archivo               | Entidad                                             | Dónde aparece                                   |
|-----------------------|-----------------------------------------------------|-------------------------------------------------|
| `mtc.svg`             | Ministerio de Transportes y Comunicaciones          | Pie del portal · pie del informe                |
| `senamhi.svg`         | SENAMHI                                             | Panel de fuentes del inicio · pies              |
| `perurail.svg`        | PeruRail                                            | Panel de fuentes del inicio · pies              |
| `travel-group-peru.svg` | Travel Group Perú                                 | Panel de fuentes del inicio · pies              |

## Reglas

1. **El nombre debe ser exactamente el de la tabla**, en minúsculas y con guiones.
2. Se prefiere `.svg`. Si solo tienes mapa de bits, usa el **mismo nombre con
   extensión `.png`** (`senamhi.png`); la plataforma lo intenta cuando no
   encuentra el `.svg`.
3. Formato horizontal (marca + nombre), fondo **transparente**, con los colores
   originales de la entidad. Los logotipos se muestran sobre una placa blanca,
   así que las versiones a todo color funcionan igual en tema claro y oscuro.
4. Proporción recomendada cercana a 4:1 (por ejemplo 232 × 56). Se escalan por
   altura, así que una relación muy distinta se verá desproporcionada frente a
   las demás.
5. Para `.png`, exporta a 3× la altura de uso (unos 120 px de alto) para que se
   vea nítido en pantallas de alta densidad.

## Mientras la carpeta esté vacía

No se inventa ningún logotipo. Si un archivo falta, en su lugar aparece una
placa tipográfica sobria con el nombre de la entidad, y así se queda hasta que
dejes el archivo oficial aquí. Basta con recargar la página después de copiarlo.

## Qué NO va en esta carpeta

El logotipo de la propia plataforma —el escudo que se ve en la barra superior y
en la pestaña del navegador— **no** es de una entidad externa: vive en
`assets/img/logo-mtc.svg` y se diseñó para este proyecto.
