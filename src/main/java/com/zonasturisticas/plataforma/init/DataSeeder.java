package com.zonasturisticas.plataforma.init;

import com.zonasturisticas.plataforma.beans.Categoria;
import com.zonasturisticas.plataforma.beans.Estacion;
import com.zonasturisticas.plataforma.beans.Ruta;
import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.beans.ZonaTuristica;
import com.zonasturisticas.plataforma.repositories.CategoriaRepository;
import com.zonasturisticas.plataforma.repositories.EstacionRepository;
import com.zonasturisticas.plataforma.repositories.RutaRepository;
import com.zonasturisticas.plataforma.repositories.ZonaTuristicaRepository;
import com.zonasturisticas.plataforma.services.ConfiguracionService;
import com.zonasturisticas.plataforma.services.RutaService;
import com.zonasturisticas.plataforma.services.UsuarioService;
import com.zonasturisticas.plataforma.services.integracion.IntegracionScheduler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Carga inicial de la plataforma.
 *
 * 1. Catalogo de preferencias turisticas (RF01).
 * 2. Sincronizacion con PeruRail: estaciones, servicios y horarios (RF10).
 * 3. Rutas y zonas turisticas levantadas por Travel Group Peru (RF08).
 * 4. Sincronizacion con SENAMHI: pronostico por zona geografica (RF11).
 * 5. Gestores autorizados (RNF06) y parametros generales (RF12).
 */
@Component
public class DataSeeder implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final CategoriaRepository categoriaRepository;
    private final EstacionRepository estacionRepository;
    private final RutaRepository rutaRepository;
    private final ZonaTuristicaRepository zonaRepository;
    private final RutaService rutaService;
    private final UsuarioService usuarioService;
    private final ConfiguracionService configuracionService;
    private final IntegracionScheduler integracionScheduler;

    @Value("${app.integracion.sincronizar-al-inicio:true}")
    private boolean sincronizarAlInicio;

    public DataSeeder(CategoriaRepository categoriaRepository, EstacionRepository estacionRepository,
            RutaRepository rutaRepository, ZonaTuristicaRepository zonaRepository,
            RutaService rutaService, UsuarioService usuarioService,
            ConfiguracionService configuracionService, IntegracionScheduler integracionScheduler) {
        this.categoriaRepository = categoriaRepository;
        this.estacionRepository = estacionRepository;
        this.rutaRepository = rutaRepository;
        this.zonaRepository = zonaRepository;
        this.rutaService = rutaService;
        this.usuarioService = usuarioService;
        this.configuracionService = configuracionService;
        this.integracionScheduler = integracionScheduler;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        sembrarParametros();
        sembrarGestores();
        sembrarCategorias();

        if (sincronizarAlInicio || estacionRepository.count() == 0) {
            integracionScheduler.sincronizarPeruRail();
        }

        if (zonaRepository.count() == 0) {
            sembrarRutasYZonas();
        } else {
            actualizarImagenesZonas();
        }

        if (sincronizarAlInicio) {
            integracionScheduler.sincronizarSenamhi();
        }

        log.info("Plataforma lista: {} estaciones, {} rutas, {} zonas turísticas",
                estacionRepository.count(), rutaRepository.count(), zonaRepository.count());
    }

    /* ----------------------------- RF12 ------------------------------ */

    private void sembrarParametros() {
        configuracionService.registrarSiFalta("plataforma.nombre", "MTC Perú",
                "Nombre visible de la plataforma en la cabecera.", "TEXTO", "IDENTIDAD");
        configuracionService.registrarSiFalta("plataforma.lema",
                "Plataforma Oficial de Turismo y Transporte",
                "Lema mostrado bajo el nombre de la plataforma.", "TEXTO", "IDENTIDAD");
        configuracionService.registrarSiFalta("plataforma.entidad",
                "Ministerio de Transportes y Comunicaciones",
                "Entidad responsable mostrada en el pie de página.", "TEXTO", "IDENTIDAD");

        configuracionService.registrarSiFalta("ruta.velocidad_caminata_kmh", "4.2",
                "Velocidad promedio de caminata usada para estimar el tiempo de las rutas (km/h).",
                "NUMERO", "RUTAS");
        configuracionService.registrarSiFalta("ruta.distancia_maxima_km", "25",
                "Distancia máxima de ida y vuelta admitida para una ruta peatonal.", "NUMERO", "RUTAS");
        configuracionService.registrarSiFalta("ruta.mostrar_dificultad", "true",
                "Mostrar el indicador de dificultad en las tarjetas de resultados.", "BOOLEANO", "RUTAS");

        configuracionService.registrarSiFalta("integracion.perurail_activa", "true",
                "Habilita la sincronización periódica con PeruRail (RF10).", "BOOLEANO", "INTEGRACIONES");
        configuracionService.registrarSiFalta("integracion.senamhi_activa", "true",
                "Habilita la sincronización periódica con SENAMHI (RF11).", "BOOLEANO", "INTEGRACIONES");
        configuracionService.registrarSiFalta("integracion.dias_pronostico", "5",
                "Cantidad de días de pronóstico que conserva la plataforma por zona.", "NUMERO", "INTEGRACIONES");

        configuracionService.registrarSiFalta("portal.resultados_por_pagina", "9",
                "Cantidad de zonas turísticas mostradas por página en el portal.", "NUMERO", "PORTAL");
        configuracionService.registrarSiFalta("portal.mostrar_tarifas", "true",
                "Mostrar las tarifas ferroviarias en las tarjetas del portal.", "BOOLEANO", "PORTAL");
        configuracionService.registrarSiFalta("portal.aviso_legal",
                "El sistema no realiza venta ni reserva de boletos de tren.",
                "Aviso mostrado en el pie del portal público.", "TEXTO", "PORTAL");
    }

    /* ----------------------------- RNF06 ----------------------------- */

    private void sembrarGestores() {
        usuarioService.registrarSiFalta("admin@mtc.gob.pe", "admin123",
                "Administrador MTC", Usuario.ROL_ADMIN);
        usuarioService.registrarSiFalta("gestor@travelgroup.pe", "travel123",
                "María Ascarza", Usuario.ROL_TRAVEL_GROUP);
        usuarioService.registrarSiFalta("operaciones@perurail.com", "rail123",
                "Carlos Ordóñez", Usuario.ROL_PERURAIL);
    }

    /* ------------------------------ RF01 ----------------------------- */

    private void sembrarCategorias() {
        if (categoriaRepository.count() > 0) {
            return;
        }
        categoriaRepository.saveAll(List.of(
                new Categoria("Naturaleza", "Paisajes, miradores, lagunas y áreas protegidas.",
                        "forest", "#2E7D5B"),
                new Categoria("Historia", "Sitios arqueológicos y legado inca y colonial.",
                        "history_edu", "#8A5A2B"),
                new Categoria("Aventura", "Senderos exigentes, trekking y recorridos de altura.",
                        "hiking", "#C2410C"),
                new Categoria("Cultura", "Comunidades vivas, museos, textilería y tradiciones.",
                        "theater_comedy", "#6D28D9"),
                new Categoria("Gastronomía", "Mercados, picanterías y cocina regional.",
                        "restaurant", "#B91C4B"),
                new Categoria("Arquitectura", "Templos, conventos y centros históricos.",
                        "account_balance", "#1D4ED8")));
    }

    /* ------------------------------ RF08 ----------------------------- */

    private void sembrarRutasYZonas() {
        // --- Cusco: Estación Wanchaq -------------------------------------
        Ruta centroCusco = ruta("Estación Wanchaq", "Circuito Centro Histórico del Cusco",
                "2.80", "Fácil");
        zona(centroCusco, "Plaza de Armas del Cusco",
                "Corazón de la ciudad imperial, rodeada por la Catedral y el Templo de la Compañía de Jesús. "
                        + "Punto de partida natural para recorrer a pie el centro histórico.",
                "Centro histórico", "45.00", true,
                "https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80",
                "Historia", "Arquitectura", "Cultura");
        zona(centroCusco, "Templo del Qorikancha",
                "Antiguo templo del Sol inca sobre el que se levantó el Convento de Santo Domingo. "
                        + "Muestra el ensamblaje de piedra más fino de la arquitectura inca.",
                "Av. El Sol", "40.00", true,
                "https://images.unsplash.com/photo-1526392060635-9d6019884377?auto=format&fit=crop&w=800&q=80",
                "Historia", "Arquitectura");
        zona(centroCusco, "Barrio de San Blas",
                "Barrio de artesanos con calles empedradas, talleres de imaginería y miradores hacia la ciudad.",
                "San Blas", "0.00", true,
                "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80",
                "Cultura", "Gastronomía");

        // --- Cusco: Estación Poroy ---------------------------------------
        Ruta poroy = ruta("Estación Poroy", "Sendero Mirador de Poroy", "3.50", "Moderada");
        zona(poroy, "Mirador de Poroy",
                "Ascenso corto sobre la meseta de Poroy con vista panorámica del valle del Cusco "
                        + "y de la cordillera del Vilcanota.",
                "Poroy alto", "0.00", true,
                "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80",
                "Naturaleza", "Aventura");

        // --- Cusco: Estación Ollantaytambo -------------------------------
        Ruta ollanta = ruta("Estación Ollantaytambo", "Camino al Conjunto Arqueológico",
                "1.20", "Fácil");
        zona(ollanta, "Conjunto Arqueológico de Ollantaytambo",
                "Fortaleza, templo y andenería inca que domina el Valle Sagrado. Uno de los pocos lugares "
                        + "donde los incas resistieron con éxito el avance español.",
                "Ollantaytambo", "70.00", true,
                "https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80",
                "Historia", "Arquitectura");
        zona(ollanta, "Pueblo Inca Viviente",
                "Traza urbana inca aún habitada, con canchas, canales de agua originales y calles empedradas.",
                "Casco urbano", "0.00", true,
                "https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80",
                "Cultura", "Historia");

        Ruta pinkuylluna = ruta("Estación Ollantaytambo", "Sendero Pinkuylluna", "2.00", "Alta");
        zona(pinkuylluna, "Graneros de Pinkuylluna",
                "Ascenso exigente hacia los antiguos colcas incas talladas en la ladera. "
                        + "Ofrece la mejor vista aérea del pueblo y de la fortaleza.",
                "Cerro Pinkuylluna", "0.00", true,
                "https://images.unsplash.com/photo-1528164344705-475426879c0d?auto=format&fit=crop&w=800&q=80",
                "Aventura", "Historia", "Naturaleza");

        // --- Machu Picchu Pueblo -----------------------------------------
        Ruta mandor = ruta("Estación Machu Picchu Pueblo", "Sendero Jardín de Mandor", "5.50", "Moderada");
        zona(mandor, "Cataratas de Mandor",
                "Caminata siguiendo la vía férrea y el río Vilcanota hasta un jardín botánico "
                        + "de ceja de selva con una catarata de 20 metros.",
                "Km 114 vía férrea", "10.00", true,
                "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80",
                "Naturaleza", "Aventura");

        Ruta termales = ruta("Estación Machu Picchu Pueblo", "Circuito Aguas Termales", "1.00", "Fácil");
        zona(termales, "Baños Termales de Aguas Calientes",
                "Pozas de aguas termales que dan nombre al pueblo, ideales para recuperarse tras el recorrido.",
                "Av. Pachacútec", "20.00", true,
                "https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80",
                "Naturaleza", "Cultura");

        Ruta museo = ruta("Estación Machu Picchu Pueblo", "Sendero al Museo de Sitio", "2.50", "Moderada");
        zona(museo, "Museo de Sitio Manuel Chávez Ballón",
                "Colección de piezas halladas en el santuario histórico y jardín botánico de orquídeas nativas.",
                "Puente Ruinas", "22.00", true,
                "https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80",
                "Historia", "Cultura", "Naturaleza");

        // --- Urubamba ------------------------------------------------------
        Ruta urubamba = ruta("Estación Urubamba", "Sendero Mirador del Valle Sagrado", "4.00", "Moderada");
        zona(urubamba, "Mirador del Valle Sagrado",
                "Recorrido entre chacras y andenes hasta un balcón natural sobre el río Urubamba "
                        + "y el nevado Chicón.",
                "Urubamba alto", "0.00", true,
                "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80",
                "Naturaleza", "Aventura");

        // --- Puno ----------------------------------------------------------
        Ruta malecon = ruta("Estación Puno", "Malecón Ecoturístico Bahía de Puno", "3.20", "Fácil");
        zona(malecon, "Embarcadero de los Uros",
                "Punto de partida hacia las islas flotantes de totora del pueblo Uros, "
                        + "accesible a pie desde la estación por el malecón.",
                "Puerto lacustre", "15.00", true,
                "https://images.unsplash.com/photo-1533050487297-09b450131914?auto=format&fit=crop&w=800&q=80",
                "Cultura", "Naturaleza");

        Ruta kunturWasi = ruta("Estación Puno", "Ascenso al Mirador Kuntur Wasi", "2.40", "Alta");
        zona(kunturWasi, "Mirador Kuntur Wasi",
                "Más de 600 escalones hasta el cóndor de piedra que corona la ciudad, "
                        + "con vista completa del lago Titicaca.",
                "Cerro Huajsapata", "5.00", true,
                "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80",
                "Aventura", "Naturaleza");

        // --- Juliaca --------------------------------------------------------
        Ruta juliaca = ruta("Estación Juliaca", "Circuito Plaza Bolognesi", "2.00", "Fácil");
        zona(juliaca, "Catedral de Santa Catalina",
                "Templo de piedra en el corazón comercial del altiplano, junto al mercado tradicional.",
                "Plaza Bolognesi", "0.00", true,
                "https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=800&q=80",
                "Arquitectura", "Cultura");

        // --- Arequipa --------------------------------------------------------
        Ruta sillar = ruta("Estación Arequipa", "Circuito Centro Histórico del Sillar", "3.00", "Fácil");
        zona(sillar, "Monasterio de Santa Catalina",
                "Ciudadela religiosa del siglo XVI construida en sillar, con calles, plazas "
                        + "y claustros de color añil y almagre.",
                "Calle Santa Catalina", "45.00", true,
                "https://images.unsplash.com/photo-1587974928442-77dc3e0dba72?auto=format&fit=crop&w=800&q=80",
                "Historia", "Arquitectura", "Cultura");
        zona(sillar, "Basílica Catedral de Arequipa",
                "Fachada de sillar blanco que ocupa todo un lado de la Plaza de Armas, "
                        + "reconstruida tras los sismos del siglo XIX.",
                "Plaza de Armas", "15.00", true,
                "https://images.unsplash.com/photo-1531968455001-5c5272a41129?auto=format&fit=crop&w=800&q=80",
                "Arquitectura", "Historia");

        Ruta yanahuara = ruta("Estación Arequipa", "Sendero Mirador de Yanahuara", "2.60", "Moderada");
        zona(yanahuara, "Mirador de Yanahuara",
                "Arcos de sillar con vista directa al volcán Misti, rodeados de picanterías tradicionales.",
                "Yanahuara", "0.00", true,
                "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80",
                "Naturaleza", "Gastronomía", "Arquitectura");
    }

    private void actualizarImagenesZonas() {
        for (ZonaTuristica z : zonaRepository.findAll()) {
            if (z.getImagen() == null || z.getImagen().isBlank() || z.getImagen().contains("wikimedia.org")) {
                String n = z.getNombre().toLowerCase();
                String url = "https://images.unsplash.com/photo-1526392060635-9d6019884377?auto=format&fit=crop&w=800&q=80";
                if (n.contains("plaza de armas")) {
                    url = "https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("qorikancha")) {
                    url = "https://images.unsplash.com/photo-1526392060635-9d6019884377?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("san blas")) {
                    url = "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("poroy")) {
                    url = "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("ollantaytambo")) {
                    url = "https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("pueblo inca")) {
                    url = "https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("pinkuylluna")) {
                    url = "https://images.unsplash.com/photo-1528164344705-475426879c0d?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("mandor")) {
                    url = "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("aguas calientes") || n.contains("termales")) {
                    url = "https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("museo")) {
                    url = "https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("valle sagrado")) {
                    url = "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("uros")) {
                    url = "https://images.unsplash.com/photo-1533050487297-09b450131914?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("kuntur wasi")) {
                    url = "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("juliaca") || n.contains("catedral de santa catalina")) {
                    url = "https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("monasterio")) {
                    url = "https://images.unsplash.com/photo-1587974928442-77dc3e0dba72?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("arequipa") || n.contains("basílica")) {
                    url = "https://images.unsplash.com/photo-1531968455001-5c5272a41129?auto=format&fit=crop&w=800&q=80";
                } else if (n.contains("yanahuara")) {
                    url = "https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80";
                }
                z.setImagen(url);
                zonaRepository.save(z);
            }
        }
    }

    /* --------------------------- utilidades -------------------------- */

    private Ruta ruta(String nombreEstacion, String nombreRuta, String distanciaKm, String dificultad) {
        Estacion estacion = estacionRepository.findFirstByNombre(nombreEstacion);
        if (estacion == null) {
            throw new IllegalStateException("No se encontró la estación " + nombreEstacion);
        }
        Ruta r = new Ruta(estacion, nombreRuta, new BigDecimal(distanciaKm), null, dificultad);
        int minutos = rutaService.calcularMinutosIdaVuelta(r.getDistanciaKm(), dificultad);
        r.setTiempoEstimado(rutaService.formatearDuracion(minutos));
        return rutaRepository.save(r);
    }

    private void zona(Ruta ruta, String nombre, String descripcion, String ubicacion,
            String costo, boolean estado, String imagen, String... categorias) {
        ZonaTuristica z = new ZonaTuristica();
        z.setRuta(ruta);
        z.setNombre(nombre);
        z.setDescripcion(descripcion);
        z.setUbicacion(ubicacion);
        z.setCostoReferencial(new BigDecimal(costo));
        z.setEstado(estado);
        z.setImagen(imagen);

        Set<Categoria> set = new LinkedHashSet<>();
        for (String nombreCategoria : categorias) {
            Categoria c = categoriaRepository.findFirstByNombre(nombreCategoria);
            if (c != null) {
                set.add(c);
            }
        }
        z.setCategorias(set);
        zonaRepository.save(z);
    }
}
