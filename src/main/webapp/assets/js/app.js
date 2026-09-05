/* ==========================================================================
   PLATAFORMA DE ZONAS TURISTICAS - MTC
   Capa de interaccion: tema, modales, tablas desplegables, toasts y
   utilidades de formulario. Sin dependencias externas.
   ========================================================================== */
(function () {
    'use strict';

    /* =====================================================================
       1. TEMA CLARO / OSCURO
       ===================================================================== */
    var Tema = {
        CLAVE: 'mtc-tema',

        inicial: function () {
            try {
                var guardado = localStorage.getItem(Tema.CLAVE);
                if (guardado) return guardado;
            } catch (e) { /* almacenamiento no disponible */ }
            return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
                ? 'dark' : 'light';
        },

        aplicar: function (valor, animar) {
            if (animar) {
                document.body.classList.add('theme-anim');
                setTimeout(function () { document.body.classList.remove('theme-anim'); }, 320);
            }
            document.documentElement.setAttribute('data-theme', valor);
            try { localStorage.setItem(Tema.CLAVE, valor); } catch (e) { /* noop */ }
            document.querySelectorAll('[data-tema-icono]').forEach(function (el) {
                el.textContent = valor === 'dark' ? 'light_mode' : 'dark_mode';
            });
        },

        alternar: function () {
            var actual = document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
            Tema.aplicar(actual === 'dark' ? 'light' : 'dark', true);
        }
    };

    /* =====================================================================
       2. TOASTS
       ===================================================================== */
    var ICONOS = {
        success: 'check_circle',
        error: 'error',
        warning: 'warning',
        info: 'info'
    };
    var TITULOS = {
        success: 'Operación exitosa',
        error: 'No se pudo completar',
        warning: 'Atención',
        info: 'Información'
    };

    function contenedorToast() {
        var c = document.querySelector('.toast-stack');
        if (!c) {
            c = document.createElement('div');
            c.className = 'toast-stack';
            document.body.appendChild(c);
        }
        return c;
    }

    function toast(mensaje, tipo, titulo, duracion) {
        tipo = ICONOS[tipo] ? tipo : 'info';
        duracion = duracion || 4600;

        var el = document.createElement('div');
        el.className = 'toast ' + tipo;
        el.setAttribute('role', tipo === 'error' ? 'alert' : 'status');
        el.innerHTML =
            '<div class="toast-ico"><span class="mi">' + ICONOS[tipo] + '</span></div>' +
            '<div class="grow">' +
                '<div class="toast-title"></div>' +
                '<div class="toast-msg"></div>' +
            '</div>' +
            '<button type="button" class="toast-x" aria-label="Cerrar"><span class="mi mi-sm">close</span></button>' +
            '<div class="toast-bar" style="animation-duration:' + duracion + 'ms"></div>';

        el.querySelector('.toast-title').textContent = titulo || TITULOS[tipo];
        el.querySelector('.toast-msg').textContent = mensaje;

        contenedorToast().appendChild(el);
        // setTimeout en lugar de requestAnimationFrame: este ultimo no se dispara
        // cuando la pestana esta en segundo plano y el toast quedaria invisible.
        setTimeout(function () { el.classList.add('show'); }, 20);

        var temporizador = setTimeout(cerrar, duracion);
        function cerrar() {
            clearTimeout(temporizador);
            el.classList.remove('show');
            setTimeout(function () { el.remove(); }, 420);
        }
        el.querySelector('.toast-x').addEventListener('click', cerrar);
        return cerrar;
    }

    /* =====================================================================
       3. MODALES
       ===================================================================== */
    var Modal = {
        abiertos: [],

        abrir: function (id) {
            var el = typeof id === 'string' ? document.getElementById(id) : id;
            if (!el) { return null; }

            el.querySelectorAll('select.select').forEach(initCustomSelect);
            el.querySelectorAll('[data-icon-picker]').forEach(initIconPicker);
            el.querySelectorAll('[data-color-picker]').forEach(initColorPicker);
            el.querySelectorAll('[data-image-upload]').forEach(initImageUpload);

            el.classList.add('open');
            el.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
            Modal.abiertos.push(el);

            // El mapa necesita el contenedor ya visible para medir su tamano.
            el.querySelectorAll('[data-map-picker]').forEach(initMapaPicker);

            var foco = el.querySelector('[data-autofocus], input:not([type=hidden]):not([disabled]), textarea, select, .c-select-trigger');
            if (foco) { setTimeout(function () { foco.focus(); }, 220); }
            return el;
        },

        cerrar: function (id) {
            var el = typeof id === 'string' ? document.getElementById(id) : id;
            if (!el) { return; }

            el.classList.remove('open');
            el.setAttribute('aria-hidden', 'true');
            Modal.abiertos = Modal.abiertos.filter(function (m) { return m !== el; });
            if (Modal.abiertos.length === 0) { document.body.style.overflow = ''; }
        },

        cerrarUltimo: function () {
            if (Modal.abiertos.length) {
                Modal.cerrar(Modal.abiertos[Modal.abiertos.length - 1]);
            }
        }
    };

    /**
     * Rellena un modal a partir de los data-* del boton pulsado.
     * Convencion: data-set-<nombreCampo> -> [name="<nombreCampo>"] dentro del modal.
     */
    function poblarModal(modal, disparador) {
        if (!modal || !disparador) { return; }

        var form = modal.querySelector('form');
        if (form) { form.reset(); }

        // Limpia selecciones multiples previas
        modal.querySelectorAll('input[type=checkbox][data-multi]').forEach(function (chk) {
            chk.checked = false;
        });

        /*
         * El navegador normaliza los nombres de atributo a minusculas, por lo que
         * el emparejamiento con name="..." y data-field="..." se hace sin
         * distinguir mayusculas.
         */
        var porNombre = {};   // nombre en minusculas -> [elementos]
        modal.querySelectorAll('[name], [data-field]').forEach(function (el) {
            var clave = (el.getAttribute('name') || el.getAttribute('data-field') || '').toLowerCase();
            if (!clave) { return; }
            (porNombre[clave] = porNombre[clave] || []).push(el);
        });

        Array.prototype.forEach.call(disparador.attributes, function (attr) {
            if (attr.name.indexOf('data-set-') !== 0) { return; }

            var campo = attr.name.slice('data-set-'.length).toLowerCase();
            var valor = attr.value;
            var destinos = porNombre[campo];
            if (!destinos || !destinos.length) { return; }

            // Listas separadas por coma para grupos de checkboxes
            if (destinos.length > 1 && destinos[0].type === 'checkbox') {
                var seleccion = valor ? valor.split(',').map(function (v) { return v.trim(); }) : [];
                destinos.forEach(function (chk) { chk.checked = seleccion.indexOf(chk.value) !== -1; });
                return;
            }

            var destino = destinos[0];
            if (destino.type === 'checkbox') {
                destino.checked = valor === 'true' || valor === '1';
            } else if (destino.tagName === 'INPUT' || destino.tagName === 'SELECT' || destino.tagName === 'TEXTAREA') {
                destino.value = valor;
                destino.dispatchEvent(new Event('change', { bubbles: true }));
            } else {
                destino.textContent = valor || '—';
            }
        });

        // Textos dinamicos del encabezado del modal
        var titulo = disparador.getAttribute('data-modal-title');
        if (titulo) {
            var h = modal.querySelector('[data-modal-title-target]');
            if (h) { h.textContent = titulo; }
        }
        var sub = disparador.getAttribute('data-modal-sub');
        if (sub) {
            var p = modal.querySelector('[data-modal-sub-target]');
            if (p) { p.textContent = sub; }
        }
    }

    /* =====================================================================
       4. TABLAS DESPLEGABLES
       ===================================================================== */
    function alternarDetalle(boton) {
        var objetivo = document.getElementById(boton.getAttribute('aria-controls'));
        if (!objetivo) { return; }

        var abierto = boton.getAttribute('aria-expanded') === 'true';
        boton.setAttribute('aria-expanded', abierto ? 'false' : 'true');
        objetivo.classList.toggle('open', !abierto);

        var fila = boton.closest('tr');
        if (fila) { fila.classList.toggle('open', !abierto); }

        // Carga diferida del contenido si la fila lo declara
        if (!abierto && objetivo.dataset.src && !objetivo.dataset.cargado) {
            cargarDetalle(objetivo);
        }
    }

    function cargarDetalle(contenedor) {
        var destino = contenedor.querySelector('[data-detail-body]');
        if (!destino) { return; }

        destino.innerHTML = '<div class="soft" style="padding:8px 0">Cargando…</div>';
        fetch(contenedor.dataset.src, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function (r) {
                if (!r.ok) { throw new Error('HTTP ' + r.status); }
                return r.json();
            })
            .then(function (datos) {
                contenedor.dataset.cargado = '1';
                destino.innerHTML = renderHorarios(datos);
            })
            .catch(function () {
                destino.innerHTML = '<div class="notice notice-danger">' +
                    '<span class="mi">error</span><div>No se pudo cargar el detalle. ' +
                    'Vuelva a intentarlo.</div></div>';
            });
    }

    function renderHorarios(lista) {
        if (!lista || !lista.length) {
            return '<div class="soft" style="padding:8px 0">Este servicio aún no tiene horarios programados.</div>';
        }
        var filas = lista.map(function (h) {
            var estado = h.estado === 'ACTIVO'
                ? '<span class="chip chip-success"><i class="dot"></i>Activo</span>'
                : '<span class="chip chip-warning"><i class="dot"></i>' + h.estado + '</span>';
            return '<tr>' +
                '<td class="mono cell-strong">' + h.salida + '</td>' +
                '<td class="mono">' + h.llegada + '</td>' +
                '<td>' + h.duracion + '</td>' +
                '<td>' + h.frecuencia + '</td>' +
                '<td><span class="chip chip-accent">S/ ' + h.tarifa + '</span></td>' +
                '<td>' + estado + '</td>' +
                '</tr>';
        }).join('');
        return '<div class="table-wrap"><table class="data">' +
            '<thead><tr><th>Salida</th><th>Llegada</th><th>Duración</th>' +
            '<th>Frecuencia</th><th>Tarifa</th><th>Estado</th></tr></thead>' +
            '<tbody>' + filas + '</tbody></table></div>';
    }

    /* =====================================================================
       5. SELECT EN CASCADA (estacion -> rutas)
       ===================================================================== */
    function cargarRutasDeEstacion(selectEstacion, selectRuta, seleccionado) {
        var codigo = selectEstacion.value;

        // El select cambia de valor en cada paso (a "" mientras carga, luego a
        // la ruta preseleccionada o de vuelta a ""): se avisa con "change" en
        // cada uno para que la validacion del modal (boton deshabilitado
        // mientras un campo obligatorio este vacio) se reevalue con el estado
        // real, en lugar de quedarse con la foto tomada antes de este fetch.
        function fijar(html, valor) {
            selectRuta.innerHTML = html;
            if (valor) { selectRuta.value = valor; }
            selectRuta.dispatchEvent(new Event('change', { bubbles: true }));
        }

        fijar('<option value="">Cargando rutas…</option>');

        if (!codigo) {
            fijar('<option value="">Seleccione primero una estación</option>');
            return;
        }
        fetch(selectRuta.dataset.base.replace('{codigo}', codigo))
            .then(function (r) { return r.json(); })
            .then(function (rutas) {
                if (!rutas.length) {
                    fijar('<option value="">Esta estación aún no tiene rutas registradas</option>');
                    return;
                }
                fijar('<option value="">Seleccione una ruta…</option>' +
                    rutas.map(function (r) {
                        return '<option value="' + r.codigo + '">' + r.nombre +
                            ' · ' + r.distanciaKm + ' km · ' + r.dificultad + '</option>';
                    }).join(''), seleccionado);
            })
            .catch(function () {
                fijar('<option value="">No se pudieron cargar las rutas</option>');
            });
    }

    /* =====================================================================
       6. IMAGEN DE RESPALDO PARA ZONAS SIN FOTOGRAFIA
       ===================================================================== */
    var PALETAS = [
        ['#0A1F3D', '#2A5A97'], ['#1F7A5C', '#0A1F3D'], ['#C2410C', '#6B2408'],
        ['#123159', '#C79A05'], ['#6D28D9', '#1B2D45'], ['#B91C4B', '#3D0F20']
    ];

    function tileZona(texto, semilla) {
        var i = Math.abs(semilla) % PALETAS.length;
        var p = PALETAS[i];
        var inicial = (texto || '?').trim().charAt(0).toUpperCase();
        var svg =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500">' +
            '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">' +
            '<stop offset="0" stop-color="' + p[0] + '"/><stop offset="1" stop-color="' + p[1] + '"/>' +
            '</linearGradient></defs>' +
            '<rect width="800" height="500" fill="url(#g)"/>' +
            '<path d="M0 380 L120 290 L210 350 L330 240 L430 330 L540 230 L650 340 L800 260 L800 500 L0 500Z" ' +
            'fill="rgba(255,255,255,.10)"/>' +
            '<path d="M0 430 L140 360 L280 420 L420 350 L560 425 L700 355 L800 400 L800 500 L0 500Z" ' +
            'fill="rgba(255,255,255,.08)"/>' +
            '<circle cx="662" cy="112" r="42" fill="rgba(245,197,24,.8)"/>' +
            '<text x="44" y="452" font-family="Georgia,serif" font-size="230" font-weight="700" ' +
            'fill="rgba(255,255,255,.13)">' + inicial + '</text>' +
            '</svg>';
        return 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
    }

    var FOTOS_PERU = {
        'plaza de armas': '/assets/img/zonas/plaza-armas-cusco.webp',
        'qorikancha': '/assets/img/zonas/qorikancha.webp',
        'san blas': '/assets/img/zonas/san-blas.webp',
        'poroy': '/assets/img/zonas/mirador-poroy.webp',
        'ruinas': '/assets/img/zonas/ollantaytambo-ruinas.webp',
        'ollantaytambo': '/assets/img/zonas/ollantaytambo-ruinas.webp',
        'pueblo inca': '/assets/img/zonas/ollantaytambo-pueblo.webp',
        'pinkuylluna': '/assets/img/zonas/pinkuylluna.webp',
        'mandor': '/assets/img/zonas/mandor.webp',
        'aguas calientes': '/assets/img/zonas/banos-termales.webp',
        'termales': '/assets/img/zonas/banos-termales.webp',
        'museo': '/assets/img/zonas/museo-machu-picchu.webp',
        'valle sagrado': '/assets/img/zonas/mirador-valle-sagrado.webp',
        'uros': '/assets/img/zonas/uros-puno.webp',
        'kuntur wasi': '/assets/img/zonas/kuntur-wasi.webp',
        'juliaca': '/assets/img/zonas/catedral-juliaca.webp',
        'santa catalina': '/assets/img/zonas/catedral-juliaca.webp',
        'monasterio': '/assets/img/zonas/monasterio-santa-catalina.webp',
        'arequipa': '/assets/img/zonas/catedral-arequipa.webp',
        'catedral': '/assets/img/zonas/catedral-arequipa.webp',
        'yanahuara': '/assets/img/zonas/yanahuara.webp'
    };
    var FOTOS_GENERALES = [
        '/assets/img/zonas/plaza-armas-cusco.webp',
        '/assets/img/zonas/qorikancha.webp',
        '/assets/img/zonas/ollantaytambo-ruinas.webp',
        '/assets/img/zonas/catedral-arequipa.webp',
        '/assets/img/zonas/mandor.webp'
    ];

    function obtenerFotoDestino(nombre, semilla) {
        var n = (nombre || '').toLowerCase();
        for (var clave in FOTOS_PERU) {
            if (n.indexOf(clave) !== -1) {
                return FOTOS_PERU[clave];
            }
        }
        var idx = Math.abs(semilla || 0) % FOTOS_GENERALES.length;
        return FOTOS_GENERALES[idx];
    }

    function respaldoImagen(img) {
        if (img.dataset.fallbackAplicado === '2') { return; }
        var nombre = img.getAttribute('alt') || '';
        var semilla = parseInt(img.dataset.seed || '0', 10) || nombre.length;
        var ctx = document.documentElement.getAttribute('data-context-path') || '';

        if (!img.dataset.fallbackAplicado) {
            img.dataset.fallbackAplicado = '1';
            var foto = obtenerFotoDestino(nombre, semilla);
            img.src = (foto && !foto.startsWith('http') && !foto.startsWith(ctx)) ? (ctx + foto) : foto;
        } else {
            img.dataset.fallbackAplicado = '2';
            img.src = tileZona(nombre, semilla);
        }
    }

    /* =====================================================================
       6.5. LOGOTIPOS OFICIALES PENDIENTES
       Los logotipos de SENAMHI, PeruRail, Travel Group Peru y el MTC los
       deposita el equipo en assets/img/logos-oficiales/. Mientras un archivo
       no exista NO se inventa una marca: la placa muestra el nombre de la
       entidad en tipografia sobria.
       ===================================================================== */
    function respaldoLogoOficial(img) {
        var placa = img.closest('.marca');
        var origen = img.getAttribute('src') || '';

        // Primer intento: la misma marca en mapa de bits
        if (/\.svg(\?.*)?$/i.test(origen) && !img.dataset.intentoPng) {
            img.dataset.intentoPng = '1';
            img.src = origen.replace(/\.svg(\?.*)?$/i, '.png');
            return;
        }
        if (!placa) { img.remove(); return; }

        placa.classList.add('marca-pendiente');
        placa.textContent = placa.getAttribute('data-marca') || img.getAttribute('alt') || '';
        placa.title = 'Pendiente: deja el logotipo oficial en assets/img/logos-oficiales/';
    }

    /* =====================================================================
       7. UTILIDADES
       ===================================================================== */
    function copiar(texto) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(texto).then(function () {
                toast('Copiado al portapapeles.', 'success');
            });
        }
    }

    function confirmarEnvio(form, mensaje) {
        if (window.confirm(mensaje)) { form.submit(); }
    }

    /** Filtra en vivo las filas de una tabla por el texto escrito. */
    function filtrarTabla(input) {
        var tabla = document.querySelector(input.dataset.filterTarget);
        if (!tabla) { return; }
        var q = input.value.trim().toLowerCase();
        var visibles = 0;

        tabla.querySelectorAll('tbody tr.main-row').forEach(function (fila) {
            var coincide = !q || fila.textContent.toLowerCase().indexOf(q) !== -1;
            fila.style.display = coincide ? '' : 'none';
            if (coincide) { visibles++; }

            var detalle = fila.nextElementSibling;
            if (detalle && detalle.classList.contains('detail-row')) {
                detalle.style.display = coincide ? '' : 'none';
            }
        });

        var vacio = document.querySelector(input.dataset.filterEmpty || '');
        if (vacio) { vacio.classList.toggle('hidden', visibles > 0); }
    }

    /* =====================================================================
       7.5. COMBOBOX PERSONALIZADO (Custom Select)
       ===================================================================== */
    function initCustomSelect(select) {
        if (!select || select.dataset.cSelectInit || select.multiple) { return; }
        select.dataset.cSelectInit = 'true';

        var wrap = document.createElement('div');
        wrap.className = 'c-select-wrap';
        if (select.classList.contains('span-full')) { wrap.classList.add('span-full'); }
        select.parentNode.insertBefore(wrap, select);
        wrap.appendChild(select);
        select.classList.add('c-select-native');

        var trigger = document.createElement('button');
        trigger.type = 'button';
        trigger.className = 'c-select-trigger';
        trigger.setAttribute('aria-haspopup', 'listbox');
        trigger.setAttribute('aria-expanded', 'false');

        var label = document.createElement('span');
        label.className = 'c-select-label';

        var arrow = document.createElement('span');
        arrow.className = 'mi mi-sm c-select-arrow';
        arrow.textContent = 'expand_more';

        trigger.appendChild(label);
        trigger.appendChild(arrow);
        wrap.appendChild(trigger);

        var menu = document.createElement('div');
        menu.className = 'c-select-menu';
        menu.setAttribute('role', 'listbox');
        wrap.appendChild(menu);

        function actualizarLabel() {
            var optSeleccionada = select.options[select.selectedIndex];
            label.textContent = optSeleccionada ? optSeleccionada.text : '';
            trigger.disabled = select.disabled;
            trigger.classList.remove('is-invalid');
            if (menu.children.length) {
                Array.prototype.forEach.call(menu.children, function (item) {
                    var val = item.getAttribute('data-value');
                    var match = (val === (optSeleccionada ? optSeleccionada.value : null));
                    item.classList.toggle('is-selected', match);
                    var chk = item.querySelector('.c-select-check');
                    if (match && !chk) {
                        var c = document.createElement('span');
                        c.className = 'mi mi-sm c-select-check';
                        c.textContent = 'check';
                        item.appendChild(c);
                    } else if (!match && chk) {
                        chk.remove();
                    }
                });
            }
        }

        function construirOpciones() {
            menu.innerHTML = '';
            Array.prototype.forEach.call(select.options, function (opt) {
                var item = document.createElement('div');
                item.className = 'c-select-option' + (opt.selected ? ' is-selected' : '') + (opt.disabled ? ' is-disabled' : '');
                item.setAttribute('role', 'option');
                item.setAttribute('data-value', opt.value);

                var span = document.createElement('span');
                span.className = 'c-select-text';
                span.textContent = opt.text;
                item.appendChild(span);

                if (opt.selected) {
                    var c = document.createElement('span');
                    c.className = 'mi mi-sm c-select-check';
                    c.textContent = 'check';
                    item.appendChild(c);
                }

                item.addEventListener('click', function (ev) {
                    ev.stopPropagation();
                    if (opt.disabled) { return; }
                    select.value = opt.value;
                    actualizarLabel();
                    cerrar();
                    trigger.focus();
                    select.dispatchEvent(new Event('change', { bubbles: true }));
                });

                menu.appendChild(item);
            });
            actualizarLabel();
        }

        function abrir() {
            document.querySelectorAll('.c-select-wrap.open').forEach(function (w) {
                if (w !== wrap) {
                    w.classList.remove('open');
                    var tr = w.querySelector('.c-select-trigger');
                    if (tr) { tr.setAttribute('aria-expanded', 'false'); }
                }
            });

            var rect = wrap.getBoundingClientRect();
            
            // Si está dentro de un modal con scroll interno, respetar los límites de su cuerpo
            var modalBody = wrap.closest('.modal-body');
            var maxBottom = window.innerHeight - 16;
            var minTop = 76;
            
            if (modalBody) {
                var mRect = modalBody.getBoundingClientRect();
                maxBottom = Math.min(maxBottom, mRect.bottom - 10);
                minTop = Math.max(minTop, mRect.top + 10);
            }

            var espAbajo = maxBottom - rect.bottom;
            var espArriba = rect.top - minTop;

            if (espAbajo < 160 && espArriba > espAbajo) {
                wrap.classList.add('open-up');
                var alt = Math.min(260, Math.max(120, Math.floor(espArriba - 8)));
                menu.style.maxHeight = alt + 'px';
            } else {
                wrap.classList.remove('open-up');
                var alt = Math.min(260, Math.max(120, Math.floor(espAbajo - 8)));
                menu.style.maxHeight = alt + 'px';
            }

            wrap.classList.add('open');
            trigger.setAttribute('aria-expanded', 'true');
            menu.style.overflowY = 'auto';

            var selItem = menu.querySelector('.c-select-option.is-selected');
            if (selItem) {
                selItem.scrollIntoView({ block: 'nearest' });
            }
        }

        function cerrar() {
            wrap.classList.remove('open');
            trigger.setAttribute('aria-expanded', 'false');
            menu.style.maxHeight = '';
        }

        trigger.addEventListener('click', function (ev) {
            ev.preventDefault();
            ev.stopPropagation();
            if (trigger.disabled) { return; }
            if (wrap.classList.contains('open')) {
                cerrar();
            } else {
                abrir();
            }
        });

        trigger.addEventListener('keydown', function (ev) {
            if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
                ev.preventDefault();
                if (!wrap.classList.contains('open')) {
                    abrir();
                } else {
                    var items = menu.querySelectorAll('.c-select-option:not(.is-disabled)');
                    if (!items.length) { return; }
                    var idx = -1;
                    items.forEach(function (it, i) {
                        if (it.classList.contains('is-focused') || it.classList.contains('is-selected')) { idx = i; }
                    });
                    items.forEach(function (it) { it.classList.remove('is-focused'); });
                    idx = ev.key === 'ArrowDown' ? (idx + 1) % items.length : (idx - 1 + items.length) % items.length;
                    items[idx].classList.add('is-focused');
                    items[idx].scrollIntoView({ block: 'nearest' });
                }
            } else if (ev.key === 'Enter' || ev.key === ' ') {
                if (wrap.classList.contains('open')) {
                    ev.preventDefault();
                    var focused = menu.querySelector('.c-select-option.is-focused') || menu.querySelector('.c-select-option.is-selected');
                    if (focused) { focused.click(); }
                }
            } else if (ev.key === 'Escape') {
                cerrar();
            }
        });

        select.addEventListener('focus', function () { trigger.focus(); });
        select.addEventListener('invalid', function () { trigger.classList.add('is-invalid'); });
        select.addEventListener('change', actualizarLabel);

        if (select.form) {
            select.form.addEventListener('reset', function () {
                setTimeout(actualizarLabel, 30);
            });
        }

        if ('MutationObserver' in window) {
            var mo = new MutationObserver(construirOpciones);
            mo.observe(select, { childList: true, subtree: true, characterData: true });
        }

        select._rebuildCustomSelect = construirOpciones;
        construirOpciones();
    }

    /* =====================================================================
       7.6. AUTOCOMPLETADO DE DESTINOS
       ===================================================================== */
    var DESTINOS_DATA = [
        { nombre: 'Machu Picchu Pueblo', estacion: 'Estación Machu Picchu Pueblo', region: 'Cusco (Urubamba)', icono: 'landscape', estacionCodigo: '4' },
        { nombre: 'Plaza de Armas del Cusco', estacion: 'Estación Wanchaq', region: 'Cusco', icono: 'account_balance', estacionCodigo: '1' },
        { nombre: 'Templo del Qorikancha', estacion: 'Estación Wanchaq', region: 'Cusco', icono: 'temple_hindu', estacionCodigo: '1' },
        { nombre: 'Barrio de San Blas', estacion: 'Estación Wanchaq', region: 'Cusco', icono: 'palette', estacionCodigo: '1' },
        { nombre: 'Mirador de Poroy', estacion: 'Estación Poroy', region: 'Cusco', icono: 'visibility', estacionCodigo: '2' },
        { nombre: 'Conjunto Arqueológico de Ollantaytambo', estacion: 'Estación Ollantaytambo', region: 'Cusco (Urubamba)', icono: 'fort', estacionCodigo: '3' },
        { nombre: 'Pueblo Inca Viviente', estacion: 'Estación Ollantaytambo', region: 'Cusco (Urubamba)', icono: 'cottage', estacionCodigo: '3' },
        { nombre: 'Graneros de Pinkuylluna', estacion: 'Estación Ollantaytambo', region: 'Cusco (Urubamba)', icono: 'landscape', estacionCodigo: '3' },
        { nombre: 'Cataratas de Mandor', estacion: 'Estación Machu Picchu Pueblo', region: 'Cusco (Urubamba)', icono: 'waterfall_chart', estacionCodigo: '4' },
        { nombre: 'Baños Termales de Aguas Calientes', estacion: 'Estación Machu Picchu Pueblo', region: 'Cusco (Urubamba)', icono: 'hot_tub', estacionCodigo: '4' },
        { nombre: 'Museo de Sitio Manuel Chávez Ballón', estacion: 'Estación Machu Picchu Pueblo', region: 'Cusco (Urubamba)', icono: 'museum', estacionCodigo: '4' },
        { nombre: 'Mirador del Valle Sagrado', estacion: 'Estación Urubamba', region: 'Cusco (Urubamba)', icono: 'landscape', estacionCodigo: '5' },
        { nombre: 'Embarcadero de los Uros', estacion: 'Estación Puno', region: 'Puno', icono: 'sailing', estacionCodigo: '6' },
        { nombre: 'Mirador Kuntur Wasi', estacion: 'Estación Puno', region: 'Puno', icono: 'visibility', estacionCodigo: '6' },
        { nombre: 'Catedral de Santa Catalina', estacion: 'Estación Juliaca', region: 'Puno (San Román)', icono: 'church', estacionCodigo: '7' },
        { nombre: 'Monasterio de Santa Catalina', estacion: 'Estación Arequipa', region: 'Arequipa', icono: 'church', estacionCodigo: '8' },
        { nombre: 'Basílica Catedral de Arequipa', estacion: 'Estación Arequipa', region: 'Arequipa', icono: 'account_balance', estacionCodigo: '8' },
        { nombre: 'Mirador de Yanahuara', estacion: 'Estación Arequipa', region: 'Arequipa', icono: 'visibility', estacionCodigo: '8' }
    ];

    function initAutocompleteDestinos(input) {
        if (!input || input.dataset.autocompleteInit) { return; }
        input.dataset.autocompleteInit = 'true';

        var wrap = input.closest('.autocomplete-wrap');
        if (!wrap) { return; }
        var menu = wrap.querySelector('.autocomplete-menu');
        if (!menu) { return; }

        function normalizar(str) {
            return (str || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
        }

        function cerrar() {
            menu.classList.remove('open');
            menu.innerHTML = '';
        }

        function seleccionar(item) {
            input.value = item.nombre;
            cerrar();

            var form = input.closest('form');
            if (form) {
                var selEstacion = form.querySelector('select[name="estacion"]');
                if (selEstacion && item.estacionCodigo) {
                    selEstacion.value = item.estacionCodigo;
                    selEstacion.dispatchEvent(new Event('change', { bubbles: true }));
                }
                form.submit();
            }
        }

        input.addEventListener('input', function () {
            var q = normalizar(input.value.trim());
            if (!q) {
                cerrar();
                return;
            }

            var matches = DESTINOS_DATA.filter(function (d) {
                return normalizar(d.nombre).indexOf(q) !== -1 ||
                       normalizar(d.region).indexOf(q) !== -1 ||
                       normalizar(d.estacion).indexOf(q) !== -1;
            });

            menu.innerHTML = '';
            if (!matches.length) {
                var empty = document.createElement('div');
                empty.className = 'autocomplete-empty';
                empty.innerHTML = '<span class="mi mi-sm" style="vertical-align:middle;margin-right:4px">search_off</span> No se encontraron atractivos para "<strong>' + input.value.replace(/</g, '&lt;') + '</strong>"';
                menu.appendChild(empty);
            } else {
                matches.slice(0, 6).forEach(function (d) {
                    var el = document.createElement('div');
                    el.className = 'autocomplete-item';
                    el.setAttribute('role', 'option');

                    var re = new RegExp('(' + q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
                    var tituloHtml = d.nombre.replace(re, '<mark style="background:rgba(245,197,24,.3);color:inherit;padding:0 2px;border-radius:2px">$1</mark>');

                    el.innerHTML =
                        '<div class="item-icon"><span class="mi mi-sm">' + d.icono + '</span></div>' +
                        '<div class="item-text">' +
                            '<div class="item-title">' + tituloHtml + '</div>' +
                            '<div class="item-sub">' + d.estacion + ' · ' + d.region + '</div>' +
                        '</div>' +
                        '<span class="mi mi-sm soft" style="font-size:16px">arrow_forward</span>';

                    el.addEventListener('click', function (ev) {
                        ev.stopPropagation();
                        seleccionar(d);
                    });

                    menu.appendChild(el);
                });
            }

            menu.classList.add('open');
        });

        input.addEventListener('focus', function () {
            if (input.value.trim().length > 0) {
                input.dispatchEvent(new Event('input'));
            }
        });

        input.addEventListener('keydown', function (ev) {
            if (!menu.classList.contains('open')) { return; }
            var items = menu.querySelectorAll('.autocomplete-item');
            if (!items.length) { return; }

            var current = menu.querySelector('.autocomplete-item.is-focused');
            var idx = Array.prototype.indexOf.call(items, current);

            if (ev.key === 'ArrowDown') {
                ev.preventDefault();
                idx = (idx + 1) % items.length;
                items.forEach(function (it) { it.classList.remove('is-focused'); });
                items[idx].classList.add('is-focused');
                items[idx].scrollIntoView({ block: 'nearest' });
            } else if (ev.key === 'ArrowUp') {
                ev.preventDefault();
                idx = (idx - 1 + items.length) % items.length;
                items.forEach(function (it) { it.classList.remove('is-focused'); });
                items[idx].classList.add('is-focused');
                items[idx].scrollIntoView({ block: 'nearest' });
            } else if (ev.key === 'Enter') {
                if (current) {
                    ev.preventDefault();
                    current.click();
                }
            } else if (ev.key === 'Escape') {
                cerrar();
            }
        });

        document.addEventListener('click', function (ev) {
            if (!wrap.contains(ev.target)) {
                cerrar();
            }
        });

        window.addEventListener('scroll', function () {
            cerrar();
        }, { passive: true });
    }

    /* =====================================================================
       7.7. SELECTOR VISUAL DE ICONOS
       El gestor elegia el icono escribiendo su nombre en Material Symbols.
       Ahora se muestra un catalogo navegable y buscable en espanol: el campo
       real sigue siendo un input oculto, por lo que el formulario no cambia.
       ===================================================================== */
    var ICONOS_CATALOGO = [
        {
            grupo: 'Naturaleza',
            iconos: [
                ['forest', 'bosque arboles selva jungla'],
                ['park', 'parque area verde jardin'],
                ['landscape', 'paisaje montana mirador vista'],
                ['terrain', 'cerro cordillera relieve montana'],
                ['volcano', 'volcan crater'],
                ['grass', 'pasto pradera campo'],
                ['local_florist', 'flor flora jardin botanico'],
                ['eco', 'ecologia hoja sostenible reserva'],
                ['pets', 'fauna animales huella'],
                ['water', 'agua rio manantial'],
                ['waves', 'lago olas laguna mar'],
                ['water_drop', 'gota agua catarata'],
                ['tsunami', 'ola mar oceano'],
                ['beach_access', 'playa costa sombrilla'],
                ['hot_tub', 'aguas termales bano caliente'],
                ['spa', 'relajacion bienestar naturaleza'],
                ['ac_unit', 'nieve glaciar nevado frio'],
                ['wb_sunny', 'sol soleado clima']
            ]
        },
        {
            grupo: 'Cultura e historia',
            iconos: [
                ['account_balance', 'templo museo edificio historico columnas'],
                ['museum', 'museo galeria exposicion'],
                ['castle', 'castillo fortaleza ruinas'],
                ['fort', 'fortaleza ruinas arqueologia inca'],
                ['temple_buddhist', 'templo santuario'],
                ['temple_hindu', 'templo santuario qorikancha'],
                ['church', 'iglesia catedral basilica'],
                ['mosque', 'mezquita templo'],
                ['synagogue', 'sinagoga templo'],
                ['architecture', 'arquitectura patrimonio diseno'],
                ['history_edu', 'historia patrimonio legado'],
                ['auto_stories', 'relato libro historia'],
                ['menu_book', 'libro guia lectura'],
                ['local_library', 'biblioteca archivo'],
                ['theater_comedy', 'teatro artes escenicas folclore'],
                ['palette', 'arte pintura artesania'],
                ['brush', 'artesania pintura taller'],
                ['music_note', 'musica folclore danza'],
                ['festival', 'festival fiesta carnaval'],
                ['attractions', 'atraccion feria entretenimiento']
            ]
        },
        {
            grupo: 'Aventura',
            iconos: [
                ['hiking', 'caminata trekking senderismo'],
                ['directions_walk', 'caminar peatonal ruta a pie'],
                ['backpack', 'mochila excursion'],
                ['explore', 'explorar brujula descubrir'],
                ['tour', 'recorrido tour bandera'],
                ['flag', 'meta bandera hito'],
                ['directions_bike', 'bicicleta ciclismo'],
                ['pedal_bike', 'bicicleta ciclismo paseo'],
                ['downhill_skiing', 'esqui nieve montana'],
                ['snowboarding', 'snowboard nieve'],
                ['paragliding', 'parapente vuelo aventura'],
                ['kayaking', 'kayak remo rio'],
                ['rowing', 'remo bote rio'],
                ['sailing', 'navegacion vela lago'],
                ['surfing', 'surf ola mar'],
                ['scuba_diving', 'buceo submarinismo'],
                ['fitness_center', 'deporte exigencia fisica'],
                ['sports_score', 'meta llegada logro']
            ]
        },
        {
            grupo: 'Gastronomía',
            iconos: [
                ['restaurant', 'restaurante comida cubiertos'],
                ['restaurant_menu', 'carta menu gastronomia'],
                ['local_dining', 'comida tipica almuerzo'],
                ['lunch_dining', 'almuerzo sandwich comida'],
                ['dinner_dining', 'cena plato gastronomia'],
                ['brunch_dining', 'desayuno brunch'],
                ['ramen_dining', 'sopa caldo plato'],
                ['bakery_dining', 'panaderia pan reposteria'],
                ['icecream', 'helado postre'],
                ['local_cafe', 'cafe cafeteria bebida'],
                ['coffee', 'cafe bebida caliente'],
                ['local_bar', 'bar coctel bebida'],
                ['wine_bar', 'vino bodega cata'],
                ['liquor', 'licor pisco destileria'],
                ['local_drink', 'bebida jugo refresco'],
                ['nightlife', 'vida nocturna bar'],
                ['local_pizza', 'pizza comida'],
                ['set_meal', 'plato menu comida']
            ]
        },
        {
            grupo: 'Transporte',
            iconos: [
                ['train', 'tren ferrocarril perurail'],
                ['tram', 'tren estacion ferroviaria'],
                ['directions_railway', 'ferrocarril via tren'],
                ['subway', 'metro tren urbano'],
                ['departure_board', 'horarios salidas anden'],
                ['directions_bus', 'bus autobus transporte'],
                ['directions_boat', 'barco bote lancha'],
                ['flight', 'avion vuelo aeropuerto'],
                ['directions_car', 'auto carretera vehiculo'],
                ['local_taxi', 'taxi transporte'],
                ['two_wheeler', 'moto motocicleta'],
                ['commute', 'traslado transporte combinado'],
                ['route', 'ruta trayecto recorrido'],
                ['alt_route', 'ruta alterna desvio'],
                ['map', 'mapa plano ubicacion'],
                ['place', 'lugar ubicacion pin'],
                ['pin_drop', 'punto ubicacion marcador'],
                ['near_me', 'cercano proximidad'],
                ['signpost', 'senal indicaciones letrero'],
                ['travel_explore', 'explorar destinos mundo'],
                ['luggage', 'equipaje maleta viaje'],
                ['public', 'mundo global destino']
            ]
        },
        {
            grupo: 'Servicios',
            iconos: [
                ['hotel', 'hotel alojamiento hospedaje'],
                ['king_bed', 'habitacion cama alojamiento'],
                ['cottage', 'casa rural pueblo vivienda'],
                ['villa', 'casa hospedaje campo'],
                ['holiday_village', 'pueblo comunidad casas'],
                ['apartment', 'edificio departamento'],
                ['storefront', 'tienda comercio mercado'],
                ['store', 'tienda artesania mercado'],
                ['shopping_bag', 'compras artesania souvenir'],
                ['local_mall', 'centro comercial compras'],
                ['local_hospital', 'salud hospital emergencia'],
                ['local_pharmacy', 'farmacia botica salud'],
                ['local_police', 'policia seguridad'],
                ['currency_exchange', 'cambio moneda dinero'],
                ['local_atm', 'cajero dinero banco'],
                ['wifi', 'internet conexion'],
                ['wc', 'servicios higienicos bano'],
                ['accessible', 'accesibilidad inclusivo'],
                ['family_restroom', 'familia ninos servicios'],
                ['support_agent', 'orientacion guia atencion'],
                ['photo_camera', 'foto camara mirador'],
                ['local_activity', 'entrada boleto actividad'],
                ['confirmation_number', 'ticket boleto entrada'],
                ['event', 'evento calendario fecha'],
                ['schedule', 'horario tiempo duracion'],
                ['groups', 'grupo visitantes turistas']
            ]
        },
        {
            grupo: 'Clima',
            iconos: [
                ['sunny', 'sol despejado soleado'],
                ['partly_cloudy_day', 'parcialmente nublado sol nubes'],
                ['cloud', 'nublado nubes cielo'],
                ['rainy', 'lluvia lluvioso precipitacion'],
                ['thunderstorm', 'tormenta rayo electrica'],
                ['foggy', 'niebla neblina bruma'],
                ['air', 'viento brisa aire'],
                ['umbrella', 'lluvia paraguas proteccion'],
                ['severe_cold', 'frio helada baja temperatura'],
                ['thermostat', 'temperatura termometro'],
                ['wb_twilight', 'amanecer atardecer'],
                ['nights_stay', 'noche luna'],
                ['storm', 'tormenta ciclon']
            ]
        },
        {
            grupo: 'Marcadores',
            iconos: [
                ['sell', 'etiqueta categoria'],
                ['label', 'etiqueta clasificacion'],
                ['category', 'categoria grupo clasificacion'],
                ['interests', 'intereses preferencias gustos'],
                ['star', 'destacado favorito estrella'],
                ['favorite', 'favorito corazon preferido'],
                ['bookmark', 'guardado marcador'],
                ['verified', 'verificado oficial certificado'],
                ['workspace_premium', 'premium distincion sello'],
                ['military_tech', 'reconocimiento medalla'],
                ['emoji_events', 'trofeo logro premio'],
                ['diamond', 'exclusivo premium joya'],
                ['auto_awesome', 'destacado especial brillo'],
                ['celebration', 'celebracion fiesta'],
                ['visibility', 'mirador vista observacion'],
                ['info', 'informacion dato']
            ]
        }
    ];

    function normalizarTexto(str) {
        return (str || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    /**
     * Descarta los simbolos que la fuente no resuelve: una ligadura no soportada
     * se dibuja como el nombre literal y ocuparia mucho mas que un glifo.
     */
    function depurarIconosNoSoportados(grid) {
        var opciones = grid.querySelectorAll('.icon-picker-opt');
        opciones.forEach(function (op) {
            var glifo = op.querySelector('.mi');
            if (!glifo) { return; }
            var ancho = glifo.getBoundingClientRect().width;
            var alto = glifo.getBoundingClientRect().height;
            if (alto > 0 && ancho > alto * 1.9) { op.remove(); }
        });
    }

    function initIconPicker(raiz) {
        if (!raiz || raiz.dataset.iconPickerInit) { return; }
        raiz.dataset.iconPickerInit = 'true';

        var hidden = raiz.querySelector('input[type="hidden"]');
        var preview = raiz.querySelector('.icon-picker-preview .mi');
        var nombre = raiz.querySelector('.icon-picker-name');
        var buscador = raiz.querySelector('.icon-picker-search input');
        var tabs = raiz.querySelector('.icon-picker-tabs');
        var grid = raiz.querySelector('.icon-picker-grid');
        if (!hidden || !grid || !tabs) { return; }

        var grupoActivo = 'Todos';

        function sincronizarCabecera() {
            var valor = hidden.value || 'tour';
            if (preview) { preview.textContent = valor; }
            if (nombre) { nombre.textContent = valor; }
            grid.querySelectorAll('.icon-picker-opt').forEach(function (op) {
                op.classList.toggle('is-active', op.dataset.icono === valor);
            });
        }

        function seleccionar(valor) {
            hidden.value = valor;
            sincronizarCabecera();
            var activo = grid.querySelector('.icon-picker-opt.is-active');
            if (activo) { activo.scrollIntoView({ block: 'nearest' }); }
        }

        function listaVisible() {
            var q = normalizarTexto(buscador ? buscador.value.trim() : '');
            var salida = [];
            ICONOS_CATALOGO.forEach(function (g) {
                if (grupoActivo !== 'Todos' && g.grupo !== grupoActivo) { return; }
                g.iconos.forEach(function (par) {
                    if (!q || normalizarTexto(par[0] + ' ' + par[1] + ' ' + g.grupo).indexOf(q) !== -1) {
                        salida.push({ icono: par[0], titulo: par[1], grupo: g.grupo });
                    }
                });
            });
            return salida;
        }

        function pintar() {
            var items = listaVisible();
            grid.innerHTML = '';

            if (!items.length) {
                var vacio = document.createElement('div');
                vacio.className = 'icon-picker-empty';
                vacio.textContent = 'Ningún icono coincide con la búsqueda.';
                grid.appendChild(vacio);
                return;
            }

            items.forEach(function (it) {
                var op = document.createElement('button');
                op.type = 'button';
                op.className = 'icon-picker-opt';
                op.dataset.icono = it.icono;
                op.title = it.grupo + ' · ' + it.icono;
                op.setAttribute('aria-label', it.icono);
                op.innerHTML = '<span class="mi">' + it.icono + '</span>';
                op.addEventListener('click', function () { seleccionar(it.icono); });
                grid.appendChild(op);
            });

            sincronizarCabecera();

            if (document.fonts && document.fonts.ready) {
                document.fonts.ready.then(function () { depurarIconosNoSoportados(grid); });
            }
        }

        /* --- Pestanas de grupo --- */
        var grupos = ['Todos'].concat(ICONOS_CATALOGO.map(function (g) { return g.grupo; }));
        grupos.forEach(function (g) {
            var b = document.createElement('button');
            b.type = 'button';
            b.className = 'icon-picker-tab' + (g === grupoActivo ? ' is-active' : '');
            b.textContent = g;
            b.addEventListener('click', function () {
                grupoActivo = g;
                tabs.querySelectorAll('.icon-picker-tab').forEach(function (t) {
                    t.classList.toggle('is-active', t === b);
                });
                grid.scrollTop = 0;
                pintar();
            });
            tabs.appendChild(b);
        });

        if (buscador) {
            buscador.addEventListener('input', function () { grid.scrollTop = 0; pintar(); });
            buscador.addEventListener('keydown', function (ev) {
                if (ev.key === 'Enter') {
                    ev.preventDefault();
                    var primera = grid.querySelector('.icon-picker-opt');
                    if (primera) { primera.click(); }
                }
            });
        }

        // poblarModal escribe en el input oculto y emite "change"
        hidden.addEventListener('change', sincronizarCabecera);
        if (hidden.form) {
            hidden.form.addEventListener('reset', function () { setTimeout(sincronizarCabecera, 30); });
        }

        pintar();
    }

    /* =====================================================================
       7.8. SELECTOR DE COLOR
       Muestras de la paleta institucional + rueda nativa para color libre.
       ===================================================================== */
    var COLORES_PALETA = [
        '#0A1F3D', '#123159', '#1B4278', '#2A5A97', '#1B7FD4', '#0EA5B5',
        '#12805C', '#1F7A5C', '#2AA983', '#65A30D', '#C79A05', '#F5C518',
        '#E08A00', '#C2410C', '#D9481F', '#C2273B', '#E8112D', '#A21C6B',
        '#6D28D9', '#4C1D95', '#475569', '#0F1B2D'
    ];

    function normalizarHex(valor, respaldo) {
        var v = (valor || '').trim();
        if (v && v.charAt(0) !== '#') { v = '#' + v; }
        if (/^#[0-9a-fA-F]{3}$/.test(v)) {
            v = '#' + v[1] + v[1] + v[2] + v[2] + v[3] + v[3];
        }
        return /^#[0-9a-fA-F]{6}$/.test(v) ? v.toUpperCase() : (respaldo || '#0A1F3D');
    }

    /** Luminancia relativa aproximada, para decidir el color del check. */
    function esColorClaro(hex) {
        var r = parseInt(hex.substr(1, 2), 16);
        var g = parseInt(hex.substr(3, 2), 16);
        var b = parseInt(hex.substr(5, 2), 16);
        return (0.299 * r + 0.587 * g + 0.114 * b) > 165;
    }

    function initColorPicker(raiz) {
        if (!raiz || raiz.dataset.colorPickerInit) { return; }
        raiz.dataset.colorPickerInit = 'true';

        var hidden = raiz.querySelector('input[type="hidden"]');
        var preview = raiz.querySelector('.color-preview');
        var hex = raiz.querySelector('.color-hex');
        var nativo = raiz.querySelector('input[type="color"]');
        var muestras = raiz.querySelector('.color-swatches');
        var personalizado = raiz.querySelector('.color-custom');
        var formulario = raiz.closest('form');
        var previsualizacionIcono = formulario
            ? formulario.querySelector('[data-icon-picker] .icon-picker-preview')
            : null;
        if (!hidden || !muestras) { return; }

        function sincronizar(desdeCampo) {
            var valor = normalizarHex(hidden.value, '#0A1F3D');
            hidden.value = valor;
            if (preview) {
                preview.style.background = valor;
                preview.style.color = esColorClaro(valor) ? '#0F1B2D' : '#FFFFFF';
            }
            if (hex && !desdeCampo) { hex.value = valor; }
            if (nativo) { nativo.value = valor; }
            muestras.querySelectorAll('.color-swatch').forEach(function (s) {
                s.classList.toggle('is-active', (s.dataset.color || '').toUpperCase() === valor);
            });
            // El selector de icono del mismo formulario adopta el color elegido,
            // igual que la insignia de la tarjeta de categoria en el panel.
            if (previsualizacionIcono) {
                previsualizacionIcono.style.background = valor + '1F';
                previsualizacionIcono.style.color = valor;
            }
        }

        function aplicar(valor, desdeCampo) {
            hidden.value = normalizarHex(valor, hidden.value);
            sincronizar(desdeCampo);
        }

        COLORES_PALETA.forEach(function (c) {
            var b = document.createElement('button');
            b.type = 'button';
            b.className = 'color-swatch';
            b.dataset.color = c;
            b.style.background = c;
            b.title = c;
            b.setAttribute('aria-label', 'Color ' + c);
            b.addEventListener('click', function () { aplicar(c, false); });
            // La rueda de color libre queda siempre al final de la paleta
            if (personalizado) { muestras.insertBefore(b, personalizado); } else { muestras.appendChild(b); }
        });

        if (hex) {
            hex.addEventListener('input', function () {
                var v = hex.value.trim();
                if (/^#?[0-9a-fA-F]{6}$/.test(v) || /^#?[0-9a-fA-F]{3}$/.test(v)) {
                    aplicar(v, true);
                }
            });
            hex.addEventListener('blur', function () { sincronizar(false); });
        }
        if (nativo) {
            nativo.addEventListener('input', function () { aplicar(nativo.value, false); });
        }

        hidden.addEventListener('change', function () { sincronizar(false); });
        if (hidden.form) {
            hidden.form.addEventListener('reset', function () { setTimeout(function () { sincronizar(false); }, 30); });
        }

        sincronizar(false);
    }

    /* =====================================================================
       7.9. CARTOGRAFIA (MapLibre GL)
       Fuentes sin clave de API: imagen satelital y etiquetas de Esri para la
       vista 3D, base cartografica clara de CARTO para la vista 2D y el modelo
       de elevacion publico de AWS Terrain Tiles para el relieve.
       ===================================================================== */
    var CENTRO_PERU = [-71.9785, -13.5170]; // MapLibre trabaja en [lng, lat]

    var TESELAS_SATELITE = [
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
    ];
    var TESELAS_ETIQUETAS = [
        'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}'
    ];
    // Base topografica: relieve sombreado y curvas de nivel ya dibujados, mucho
    // mas legible que una base clara para un recorrido de montana.
    var TESELAS_TOPO = [
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}'
    ];
    var TESELAS_RELIEVE = ['https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png'];
    var TESELAS_FERROVIARIA = ['https://tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png'];

    var ATRIB_TOPO = 'Cartografía &copy; Esri, USGS, NGA, &copy; OpenStreetMap';
    var ATRIB_SATELITE = 'Imágenes &copy; Esri, Maxar, Earthstar Geographics';
    var ATRIB_FERROVIARIA = 'Vías &copy; <a href="https://www.openrailwaymap.org/">OpenRailwayMap</a>';

    /** Ruteo peatonal publico de FOSSGIS (OSRM), sin clave de API. */
    var RUTEO_PEATONAL = 'https://routing.openstreetmap.de/routed-foot/route/v1/foot/';

    /** Base legible para el selector de coordenadas de los modales. */
    function estiloPlano() {
        return {
            version: 8,
            sources: {
                topo: { type: 'raster', tiles: TESELAS_TOPO, tileSize: 256, maxzoom: 19, attribution: ATRIB_TOPO }
            },
            layers: [{ id: 'base-topo', type: 'raster', source: 'topo' }]
        };
    }

    /**
     * Estilo del recorrido con las dos vistas cargadas a la vez: alternar entre
     * 3D y 2D solo cambia la visibilidad de las capas, asi no hay que recargar
     * el estilo ni volver a crear el trazo.
     */
    function estiloRecorrido() {
        return {
            version: 8,
            sources: {
                topo: { type: 'raster', tiles: TESELAS_TOPO, tileSize: 256, maxzoom: 19, attribution: ATRIB_TOPO },
                satelite: { type: 'raster', tiles: TESELAS_SATELITE, tileSize: 256, maxzoom: 19, attribution: ATRIB_SATELITE },
                etiquetas: { type: 'raster', tiles: TESELAS_ETIQUETAS, tileSize: 256, maxzoom: 19 },
                ferroviaria: {
                    type: 'raster', tiles: TESELAS_FERROVIARIA, tileSize: 256,
                    maxzoom: 19, attribution: ATRIB_FERROVIARIA
                },
                relieve: {
                    type: 'raster-dem', tiles: TESELAS_RELIEVE, tileSize: 256,
                    maxzoom: 14, encoding: 'terrarium', attribution: 'Relieve &copy; AWS Terrain Tiles'
                }
            },
            layers: [
                // Vista 2D: carta topografica (ya trae curvas de nivel y sombreado)
                { id: 'base-topo', type: 'raster', source: 'topo', layout: { visibility: 'none' } },
                // Vista 3D: satelite real drapeado sobre el terreno + toponimia
                { id: 'base-satelite', type: 'raster', source: 'satelite' },
                { id: 'toponimia', type: 'raster', source: 'etiquetas', paint: { 'raster-opacity': 0.9 } },
                // Capa conmutable con el trazado exacto de las vias ferreas
                {
                    id: 'via-ferrea', type: 'raster', source: 'ferroviaria',
                    layout: { visibility: 'none' }, paint: { 'raster-opacity': 0.95 }
                }
            ]
        };
    }

    function hayMapLibre() {
        return typeof maplibregl !== 'undefined'
            && (typeof maplibregl.supported !== 'function' || maplibregl.supported());
    }

    /** Marcador con la estetica de los alfileres del esquema del recorrido. */
    function pinMapa(tipo, icono, etiqueta, subtitulo) {
        var el = document.createElement('div');
        el.className = 'geomap-marca geomap-marca-' + tipo + (etiqueta ? ' geomap-marca-pulso' : '');
        var texto = '';
        if (etiqueta) {
            texto = '<span class="geomap-etiqueta"><b></b><i></i></span>';
        }
        el.innerHTML = '<span class="geomap-punto"><span class="mi mi-sm">' + icono + '</span></span>' + texto;
        if (etiqueta) {
            el.querySelector('.geomap-etiqueta b').textContent = etiqueta;
            el.querySelector('.geomap-etiqueta i').textContent = subtitulo || '';
        }
        return el;
    }

    /**
     * Control propio: alterna vista 3D/2D (excluyentes) y enciende o apaga la
     * capa con el trazado de las vias ferreas (independiente de la vista).
     */
    function controlVista(alCambiarVista, alAlternarVia) {
        return {
            onAdd: function () {
                var caja = document.createElement('div');
                caja.className = 'maplibregl-ctrl maplibregl-ctrl-group geomap-vista';

                var vistas = [];
                ['3D', '2D'].forEach(function (modo) {
                    var b = document.createElement('button');
                    b.type = 'button';
                    b.textContent = modo;
                    b.title = modo === '3D'
                        ? 'Vista con relieve e imagen satelital'
                        : 'Carta topográfica plana';
                    b.className = modo === '3D' ? 'is-activo' : '';
                    b.addEventListener('click', function () {
                        vistas.forEach(function (o) { o.classList.remove('is-activo'); });
                        b.classList.add('is-activo');
                        alCambiarVista(modo.toLowerCase());
                    });
                    vistas.push(b);
                    caja.appendChild(b);
                });

                var via = document.createElement('button');
                via.type = 'button';
                via.className = 'geomap-vista-via';
                via.title = 'Mostrar el trazado de las vías férreas';
                via.setAttribute('aria-label', 'Mostrar el trazado de las vías férreas');
                via.innerHTML = '<span class="mi mi-sm">tram</span>';
                via.addEventListener('click', function () {
                    var encendida = via.classList.toggle('is-activo');
                    alAlternarVia(encendida);
                });
                caja.appendChild(via);

                this._caja = caja;
                return caja;
            },
            onRemove: function () {
                if (this._caja && this._caja.parentNode) { this._caja.parentNode.removeChild(this._caja); }
            }
        };
    }

    /* =====================================================================
       7.9.1. SELECTOR DE COORDENADAS EN MAPA
       Mapa pequeno con un marcador arrastrable que llena los inputs numericos
       de latitud/longitud ya existentes. Se usa en los modales de Estacion y
       Zona turistica (RF05 / RF11). Se mantiene plano (sin inclinacion) para
       que el clic caiga exactamente donde apunta el gestor.
       ===================================================================== */
    function initMapaPicker(root) {
        if (!root || !hayMapLibre()) { return; }

        var mapEl = root.querySelector('[data-map-target]');
        var latInput = root.querySelector('[data-map-lat]');
        var lngInput = root.querySelector('[data-map-lng]');
        if (!mapEl || !latInput || !lngInput) { return; }

        if (root.dataset.mapPickerInit) {
            if (root._mapaPickerInvalidate) { setTimeout(root._mapaPickerInvalidate, 60); }
            return;
        }
        root.dataset.mapPickerInit = 'true';

        var lat = parseFloat(latInput.value);
        var lng = parseFloat(lngInput.value);
        var tieneValor = !isNaN(lat) && !isNaN(lng);
        var centro = tieneValor ? [lng, lat] : CENTRO_PERU;

        var mapa = new maplibregl.Map({
            container: mapEl,
            style: estiloPlano(),
            center: centro,
            zoom: tieneValor ? 14 : 5,
            attributionControl: false
        });
        mapa.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-right');

        var marcador = new maplibregl.Marker({
            element: pinMapa('zona', 'place'), draggable: true, anchor: 'bottom'
        }).setLngLat(centro).addTo(mapa);

        function fijarCampos(lngLat) {
            latInput.value = lngLat.lat.toFixed(6);
            lngInput.value = lngLat.lng.toFixed(6);
        }

        marcador.on('drag', function () { fijarCampos(marcador.getLngLat()); });
        mapa.on('click', function (ev) {
            marcador.setLngLat(ev.lngLat);
            fijarCampos(ev.lngLat);
        });

        // poblarModal() emite "change" al rellenar el formulario en modo edicion
        function sincronizarDesdeCampos() {
            var la = parseFloat(latInput.value);
            var lo = parseFloat(lngInput.value);
            if (!isNaN(la) && !isNaN(lo)) {
                marcador.setLngLat([lo, la]);
                mapa.jumpTo({ center: [lo, la], zoom: Math.max(mapa.getZoom(), 14) });
            }
        }
        latInput.addEventListener('change', sincronizarDesdeCampos);
        lngInput.addEventListener('change', sincronizarDesdeCampos);

        root._mapaPickerInvalidate = function () { mapa.resize(); };
        setTimeout(root._mapaPickerInvalidate, 60);
    }

    /* =====================================================================
       7.10. MAPA DEL RECORRIDO (portal publico)
       Vista 3D: imagen satelital drapeada sobre el modelo de elevacion, con la
       camara inclinada y orientada a lo largo del tramo, de modo que se aprecia
       el desnivel real entre la estacion y la zona turistica.
       Vista 2D: carta topografica con curvas de nivel y relieve sombreado.
       El trazo no es una recta: se pide el recorrido real por caminos a un
       servicio de ruteo peatonal (ver trazarRutaReal). Un boton adicional
       superpone el trazado exacto de las vias ferreas.
       El selector 3D/2D solo alterna capas y camara sobre el mismo estilo.
       Sustituye al esquema SVG siempre que ambos puntos tengan coordenadas
       (ver shared/mapa-recorrido.jsp).
       ===================================================================== */
    var CAPAS_3D = ['base-satelite', 'toponimia'];
    var CAPAS_2D = ['base-topo'];

    function initGeomap(el) {
        if (!el || el.dataset.geomapInit) { return; }

        var estLat = parseFloat(el.dataset.estLat), estLng = parseFloat(el.dataset.estLng);
        var zonaLat = parseFloat(el.dataset.zonaLat), zonaLng = parseFloat(el.dataset.zonaLng);
        if (isNaN(estLat) || isNaN(estLng) || isNaN(zonaLat) || isNaN(zonaLng)) { return; }

        if (!hayMapLibre()) {
            mostrarEsquemaDeRespaldo(el, 'Tu navegador no puede mostrar el mapa.');
            return;
        }
        el.dataset.geomapInit = 'true';

        var estacion = [estLng, estLat];
        var zona = [zonaLng, zonaLat];
        var rumbo = rumboEntre(estacion, zona);

        // Estado compartido por el selector de vista y por el ruteo: evita
        // pasarse los mismos datos entre callbacks y que se desincronicen.
        el._geo = { estacion: estacion, zona: zona, rumbo: rumbo, puntos: null, modo: '3d' };

        var loader = el.querySelector('[data-geomap-loader]');

        var mapa = new maplibregl.Map({
            container: el,
            style: estiloRecorrido(),
            center: [(estLng + zonaLng) / 2, (estLat + zonaLat) / 2],
            zoom: 14,
            pitch: 64,          // camara inclinada: es lo que da la sensacion 3D
            maxPitch: 80,       // por defecto MapLibre corta en 60
            bearing: rumbo,
            attributionControl: true,
            cooperativeGestures: true,  // la rueda solo hace zoom con Ctrl
            fadeDuration: 300           // suaviza la transicion entre teselas
        });

        // Red de seguridad: si el lienzo WebGL no llega a dibujarse (sin GPU
        // disponible, contexto perdido o la pestana nunca se pinta), se muestra
        // el esquema en lugar de dejar un recuadro vacio.
        var vigilante = setTimeout(function () {
            if (!mapa.isStyleLoaded()) {
                if (loader) { loader.classList.add('is-hidden'); }
                try { mapa.remove(); } catch (e) { /* ya destruido */ }
                mostrarEsquemaDeRespaldo(el, 'No se pudo cargar el mapa.');
            }
        }, 12000);
        mapa.on('style.load', function () { clearTimeout(vigilante); });
        mapa.on('webglcontextlost', function () {
            clearTimeout(vigilante);
            if (loader) { loader.classList.add('is-hidden'); }
            mostrarEsquemaDeRespaldo(el, 'No se pudo cargar el mapa.');
        });

        mapa.addControl(new maplibregl.NavigationControl({ visualizePitch: true }), 'top-right');
        mapa.addControl(new maplibregl.FullscreenControl(), 'top-right');
        mapa.addControl(controlVista(
            function (modo) { aplicarVista(mapa, el, modo); },
            function (encendida) {
                if (mapa.getLayer('via-ferrea')) {
                    mapa.setLayoutProperty('via-ferrea', 'visibility', encendida ? 'visible' : 'none');
                }
            }
        ), 'top-left');
        el._mapa = mapa;   // accesible para depuracion desde la consola

        mapa.on('load', function () {
            // Ocultar el spinner de carga con transicion suave
            if (loader) { loader.classList.add('is-hidden'); }

            aplicarVista(mapa, el, '3d');

            // Se dibuja de inmediato el tramo recto y luego se reemplaza por el
            // trazado real por caminos, para no dejar el mapa vacio mientras
            // responde el servicio de ruteo.
            mapa.addSource('recorrido', {
                type: 'geojson',
                data: {
                    type: 'Feature', properties: {},
                    geometry: { type: 'LineString', coordinates: [estacion, zona] }
                }
            });
            mapa.addLayer({
                id: 'recorrido-borde', type: 'line', source: 'recorrido',
                layout: { 'line-cap': 'round', 'line-join': 'round' },
                paint: { 'line-color': '#0A1F3D', 'line-width': 11, 'line-opacity': 0.45, 'line-blur': 2 }
            });
            mapa.addLayer({
                id: 'recorrido-base', type: 'line', source: 'recorrido',
                layout: { 'line-cap': 'round', 'line-join': 'round' },
                paint: { 'line-color': '#FFFFFF', 'line-width': 6, 'line-opacity': 0.85 }
            });
            mapa.addLayer({
                id: 'recorrido-trazo', type: 'line', source: 'recorrido',
                layout: { 'line-cap': 'butt', 'line-join': 'round' },
                paint: { 'line-color': '#F5C518', 'line-width': 3.4, 'line-dasharray': [1.4, 1.1] }
            });

            encuadrarRecorrido(mapa, el, false);
            trazarRutaReal(mapa, el, estacion, zona);
        });

        mapa.on('error', function (ev) {
            // Las teselas de relieve pueden fallar sin invalidar el mapa base
            if (ev && ev.sourceId === 'relieve') { return; }
        });

        new maplibregl.Marker({
            element: pinMapa('estacion', 'tram', el.dataset.estNombre, 'Salida y retorno'),
            anchor: 'bottom'
        }).setLngLat(estacion).addTo(mapa);

        new maplibregl.Marker({
            element: pinMapa('zona', 'flag', el.dataset.zonaNombre, 'Destino'),
            anchor: 'bottom'
        }).setLngLat(zona).addTo(mapa);
    }

    /**
     * Sustituye el tramo recto por el trazado real por caminos y senderos
     * (servicio publico de ruteo peatonal sobre datos de OpenStreetMap).
     *
     * Es una mejora progresiva: si el servicio no responde, tarda demasiado o
     * devuelve un recorrido incoherente con la distancia registrada por Travel
     * Group Peru (RN01), se conserva la linea recta. La distancia y el tiempo
     * que muestra la ficha siguen saliendo de la ruta almacenada, no de aqui.
     */
    function trazarRutaReal(mapa, el, estacion, zona) {
        if (!window.fetch || !window.AbortController) { return; }

        var kmRegistrados = parseFloat(el.dataset.rutaKm);
        var control = new AbortController();
        var corte = setTimeout(function () { control.abort(); }, 6000);
        var url = RUTEO_PEATONAL + estacion.join(',') + ';' + zona.join(',')
            + '?overview=full&geometries=geojson';

        fetch(url, { signal: control.signal })
            .then(function (r) { return r.ok ? r.json() : null; })
            .then(function (datos) {
                var ruta = datos && datos.code === 'Ok' && datos.routes && datos.routes[0];
                var puntos = ruta && ruta.geometry && ruta.geometry.coordinates;
                if (!puntos || puntos.length < 3) { return; }

                // Descarta desvios absurdos: el trazado no deberia superar el
                // triple de la distancia registrada para ese tramo.
                if (!isNaN(kmRegistrados) && kmRegistrados > 0
                        && ruta.distance > kmRegistrados * 1000 * 3) {
                    return;
                }
                var fuente = mapa.getSource('recorrido');
                if (!fuente) { return; }
                fuente.setData({
                    type: 'Feature', properties: {},
                    geometry: { type: 'LineString', coordinates: puntos }
                });
                el.dataset.rutaReal = 'true';
                if (el._geo) { el._geo.puntos = puntos; }
                encuadrarRecorrido(mapa, el, true);
            })
            .catch(function () { /* se mantiene el tramo recto */ })
            .finally(function () { clearTimeout(corte); });
    }

    var PITCH_3D = 64;

    /**
     * Alterna entre relieve + satelite (3D) y carta topografica plana (2D).
     *
     * Todo el cambio se resuelve en una sola orden de camara: encadenar un
     * easeTo con un reencuadre diferido hacia que, al volver rapido a 3D, el
     * temporizador pendiente moviera la camara a mitad de la animacion.
     * El terreno tampoco se desmonta (setTerrain(null) y volver a montarlo deja
     * el lienzo en un estado inconsistente): se deja declarado y se aplana
     * llevando la exageracion a cero.
     */
    function aplicarVista(mapa, el, modo) {
        var geo = el._geo;
        if (!geo) { return; }
        geo.modo = modo === '2d' ? '2d' : '3d';
        var tresD = geo.modo === '3d';

        CAPAS_3D.forEach(function (id) {
            if (mapa.getLayer(id)) {
                mapa.setLayoutProperty(id, 'visibility', tresD ? 'visible' : 'none');
            }
        });
        CAPAS_2D.forEach(function (id) {
            if (mapa.getLayer(id)) {
                mapa.setLayoutProperty(id, 'visibility', tresD ? 'none' : 'visible');
            }
        });

        try {
            mapa.setTerrain({ source: 'relieve', exaggeration: tresD ? 1.4 : 0 });
        } catch (e) { /* sin relieve disponible */ }

        encuadrarRecorrido(mapa, el, true);
    }

    /** Rumbo (grados) de A hacia B, para orientar la camara a lo largo del tramo. */
    function rumboEntre(a, b) {
        var rad = Math.PI / 180;
        var dLng = (b[0] - a[0]) * rad;
        var lat1 = a[1] * rad, lat2 = b[1] * rad;
        var y = Math.sin(dLng) * Math.cos(lat2);
        var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLng);
        return (Math.atan2(y, x) / rad + 360) % 360;
    }

    /**
     * Encuadra estacion, zona y —si ya llego— el trazado real, con la
     * inclinacion y el rumbo que corresponden al modo vigente. Se calcula el
     * destino con cameraForBounds y se aplica en un unico movimiento, de modo
     * que nunca hay dos animaciones de camara compitiendo.
     */
    function encuadrarRecorrido(mapa, el, animar) {
        var geo = el._geo;
        if (!geo) { return; }
        var tresD = geo.modo !== '2d';
        var rumbo = tresD ? geo.rumbo : 0;

        var limites = new maplibregl.LngLatBounds(geo.estacion, geo.estacion).extend(geo.zona);
        (geo.puntos || []).forEach(function (p) { limites.extend(p); });

        var camara = mapa.cameraForBounds(limites, {
            padding: { top: 110, bottom: 90, left: 80, right: 80 },
            bearing: rumbo,
            maxZoom: 16
        });
        if (!camara) { return; }

        camara.bearing = rumbo;
        camara.pitch = tresD ? PITCH_3D : 0;
        camara.duration = animar ? 800 : 0;
        if (typeof camara.zoom === 'number') {
            camara.zoom = Math.min(camara.zoom, 16);
        }
        mapa.easeTo(camara);
    }

    /**
     * Si el mapa 3D no puede dibujarse, se revela el esquema del recorrido.
     * La busqueda se limita al bloque del propio mapa: el informe consolidado
     * puede mostrar varios recorridos en la misma pagina.
     */
    function mostrarEsquemaDeRespaldo(el, motivo) {
        var bloque = el.closest('.route-map-wrap') || document;
        var respaldo = bloque.querySelector('[data-geomap-fallback]');
        if (respaldo) {
            respaldo.hidden = false;
            el.remove();
        } else {
            el.innerHTML = '<div class="geomap-aviso">' + motivo + '</div>';
        }
    }

    /**
     * Los mapas se crean solo cuando se acercan a la pantalla: el informe
     * consolidado puede listar varios recorridos y cada mapa consume un
     * contexto WebGL (el navegador limita cuantos puede haber a la vez).
     */
    function observarGeomaps() {
        var mapas = document.querySelectorAll('[data-geomap]');
        if (!mapas.length) { return; }

        if (!('IntersectionObserver' in window)) {
            mapas.forEach(initGeomap);
            return;
        }
        var obs = new IntersectionObserver(function (entradas) {
            entradas.forEach(function (e) {
                if (e.isIntersecting) {
                    obs.unobserve(e.target);
                    initGeomap(e.target);
                }
            });
        }, { rootMargin: '300px 0px' });
        mapas.forEach(function (m) { obs.observe(m); });
    }

    /* =====================================================================
       7.11. SUBIR / ARRASTRAR IMAGEN (zonas turisticas)
       Complementa al input de URL existente: no cambia el contrato del
       formulario, solo llena el mismo input con la URL resultante.

       El campo de enlace es solo para imagenes alojadas fuera de la
       plataforma. Si la foto ya vive aqui -subida al modulo o incluida en
       assets- su ruta interna no se muestra: no es algo que el gestor deba
       escribir, y para cambiarla basta con quitar la imagen.
       ===================================================================== */
    function initImageUpload(root) {
        if (!root || root.dataset.imageUploadInit) { return; }
        root.dataset.imageUploadInit = 'true';

        var urlInput = document.getElementById(root.dataset.imageUrlInput);
        var fileInput = root.querySelector('input[type=file]');
        var preview = root.querySelector('.image-drop-preview');
        var previewImg = preview ? preview.querySelector('img') : null;
        var vacio = root.querySelector('.image-drop-empty');
        var estadoEl = root.querySelector('.image-drop-status');
        var campoEnlace = (root.closest('.field') || document).querySelector('[data-image-url-wrap]');
        var url = root.dataset.uploadUrl;
        if (!urlInput || !fileInput || !preview || !vacio || !url) { return; }

        function ctxPath() { return document.documentElement.getAttribute('data-context-path') || ''; }

        function resolverSrc(u) {
            if (!u) { return ''; }
            var c = ctxPath();
            return (u.charAt(0) === '/' && c && u.indexOf(c) !== 0) ? (c + u) : u;
        }

        /** Interna = servida por la plataforma (subida o incluida en assets). */
        function esInterna(valor) { return valor.charAt(0) === '/'; }

        function mostrarPreview(src) {
            if (!src) {
                preview.hidden = true;
                vacio.hidden = false;
                return;
            }
            previewImg.src = src;
            preview.hidden = false;
            vacio.hidden = true;
        }

        /**
         * Refleja el valor actual: vista previa + visibilidad del enlace.
         * Solo se oculta el enlace ante una ruta interna; mientras el gestor
         * escribe una direccion externa el campo tiene que seguir a la vista.
         */
        function sincronizar() {
            var valor = urlInput.value.trim();
            mostrarPreview(resolverSrc(valor));
            if (campoEnlace) { campoEnlace.hidden = esInterna(valor); }
        }

        function estado(texto) {
            if (!estadoEl) { return; }
            if (texto) {
                estadoEl.hidden = false;
                estadoEl.textContent = texto;
                preview.hidden = true;
                vacio.hidden = true;
            } else {
                estadoEl.hidden = true;
            }
        }

        function subir(archivo) {
            if (!archivo.type || archivo.type.indexOf('image/') !== 0) {
                toast('Selecciona un archivo de imagen válido.', 'error');
                return;
            }
            var datos = new FormData();
            datos.append('archivo', archivo);
            estado('Subiendo imagen…');

            fetch(url, { method: 'POST', body: datos, headers: { 'X-Requested-With': 'XMLHttpRequest' } })
                .then(function (r) { return r.json().then(function (j) { return { ok: r.ok, cuerpo: j }; }); })
                .then(function (res) {
                    if (!res.ok) { throw new Error(res.cuerpo.error || 'No se pudo subir la imagen.'); }
                    urlInput.value = res.cuerpo.url;
                    sincronizar();
                })
                .catch(function (e) {
                    toast(e.message || 'No se pudo subir la imagen.', 'error');
                    sincronizar();
                })
                .finally(function () { estado(''); });
        }

        root.addEventListener('click', function (ev) {
            if (ev.target.closest('[data-image-remove]')) {
                ev.preventDefault();
                ev.stopPropagation();
                urlInput.value = '';
                sincronizar();   // al quitarla vuelve a ofrecerse el enlace externo
                return;
            }
            fileInput.click();
        });
        fileInput.addEventListener('click', function (ev) { ev.stopPropagation(); });
        fileInput.addEventListener('change', function () {
            if (fileInput.files && fileInput.files[0]) { subir(fileInput.files[0]); }
            fileInput.value = '';
        });

        ['dragenter', 'dragover'].forEach(function (tipo) {
            root.addEventListener(tipo, function (ev) {
                ev.preventDefault(); ev.stopPropagation();
                root.classList.add('is-dragover');
            });
        });
        ['dragleave', 'drop'].forEach(function (tipo) {
            root.addEventListener(tipo, function (ev) {
                ev.preventDefault(); ev.stopPropagation();
                root.classList.remove('is-dragover');
            });
        });
        root.addEventListener('drop', function (ev) {
            var archivo = ev.dataTransfer && ev.dataTransfer.files && ev.dataTransfer.files[0];
            if (archivo) { subir(archivo); }
        });

        urlInput.addEventListener('input', sincronizar);
        // poblarModal() emite "change" al abrir el modal en modo edicion
        urlInput.addEventListener('change', sincronizar);

        sincronizar();
    }

    /* =====================================================================
       7.12. VALIDACION DE FORMULARIOS EN MODALES
       Desactiva el boton de guardar mientras falten campos obligatorios
       (incluyendo un grupo de checkboxes marcado con un asterisco en su
       etiqueta) y muestra un mensaje breve bajo el campo. Opera sobre la
       convencion data-submit-once que ya tienen todos los formularios de
       modal, sin necesidad de tocar cada JSP.
       ===================================================================== */
    function gruposCheckboxRequeridos(form) {
        var grupos = [];
        form.querySelectorAll('.field').forEach(function (campo) {
            var marcaReq = campo.querySelector('label .req');
            var checks = campo.querySelectorAll('input[type=checkbox][data-multi]');
            if (marcaReq && checks.length) { grupos.push(checks); }
        });
        return grupos;
    }

    function grupoValido(checks) {
        return Array.prototype.some.call(checks, function (c) { return c.checked; });
    }

    function esCampoValidable(el) {
        return !!(el && el.matches && el.matches('input, select, textarea') &&
            el.type !== 'hidden' && el.type !== 'submit' && el.type !== 'button' &&
            !(el.type === 'checkbox' && el.hasAttribute('data-multi')));
    }

    function mensajeCampo(field) {
        var v = field.validity;
        if (v.valueMissing) {
            return field.tagName === 'SELECT' ? 'Selecciona una opción.' : 'Este campo es obligatorio.';
        }
        if (v.typeMismatch) {
            if (field.type === 'email') { return 'Ingresa un correo electrónico válido.'; }
            if (field.type === 'url') { return 'Ingresa una URL válida (debe iniciar con http:// o https://).'; }
            return 'El valor ingresado no es válido.';
        }
        if (v.rangeUnderflow) { return 'El valor es menor al mínimo permitido (' + field.min + ').'; }
        if (v.rangeOverflow) { return 'El valor supera el máximo permitido (' + field.max + ').'; }
        if (v.patternMismatch) { return 'El formato ingresado no es válido.'; }
        if (v.tooShort) { return 'Escribe al menos ' + field.minLength + ' caracteres.'; }
        if (v.tooLong) { return 'No puede superar los ' + field.maxLength + ' caracteres.'; }
        return 'Revisa este campo.';
    }

    function anclaDe(field) {
        return field.closest('.c-select-wrap') || field.closest('.input-icon') || field;
    }

    function marcarInvalido(field, invalido) {
        var wrap = field.closest('.c-select-wrap');
        if (wrap) {
            var trigger = wrap.querySelector('.c-select-trigger');
            if (trigger) { trigger.classList.toggle('is-invalid', invalido); }
            return;
        }
        field.classList.toggle('is-invalid', invalido);
    }

    function mostrarError(field) {
        var ancla = anclaDe(field);
        var msg = ancla.nextElementSibling;
        if (!msg || !msg.classList.contains('field-error')) {
            msg = document.createElement('span');
            msg.className = 'field-error';
            ancla.insertAdjacentElement('afterend', msg);
        }
        msg.textContent = mensajeCampo(field);
        marcarInvalido(field, true);
    }

    function ocultarError(field) {
        var ancla = anclaDe(field);
        var msg = ancla.nextElementSibling;
        if (msg && msg.classList.contains('field-error')) { msg.remove(); }
        marcarInvalido(field, false);
    }

    function mostrarErrorGrupo(campoDiv, texto) {
        var msg = campoDiv.querySelector(':scope > .field-error');
        if (!msg) {
            msg = document.createElement('span');
            msg.className = 'field-error';
            campoDiv.appendChild(msg);
        }
        msg.textContent = texto;
    }

    function ocultarErrorGrupo(campoDiv) {
        var msg = campoDiv.querySelector(':scope > .field-error');
        if (msg) { msg.remove(); }
    }

    function initValidacionModal(form) {
        if (!form || form.dataset.validacionInit) { return; }
        form.dataset.validacionInit = 'true';

        var boton = form.querySelector('button[type=submit]');
        if (!boton) { return; }

        form._gruposCheckboxReq = gruposCheckboxRequeridos(form);

        // Se lee field.validity.valid campo por campo (en vez de
        // form.checkValidity()) porque checkValidity() dispara el evento
        // "invalid" en cada control invalido -incluso sin que el usuario haya
        // tocado nada- y eso encenderia los bordes en rojo apenas se abre el
        // modal. El mensaje solo debe aparecer si el usuario deja el campo
        // vacio (ver el listener de "blur" mas abajo).
        function actualizar() {
            var valido = true;
            form.querySelectorAll('input, select, textarea').forEach(function (el) {
                if (esCampoValidable(el) && !el.validity.valid) { valido = false; }
            });
            form._gruposCheckboxReq.forEach(function (checks) {
                if (!grupoValido(checks)) { valido = false; }
            });
            boton.disabled = !valido;
            boton.classList.toggle('is-disabled', !valido);
        }

        // Blur no burbujea: se delega en fase de captura para llegar tanto a
        // los campos normales como al boton visible de los combobox (el
        // <select> real queda oculto detras de ese boton).
        form.addEventListener('blur', function (ev) {
            var t = ev.target;
            if (t.classList && t.classList.contains('c-select-trigger')) {
                var wrap = t.closest('.c-select-wrap');
                var sel = wrap ? wrap.querySelector('select') : null;
                if (sel) { sel.checkValidity() ? ocultarError(sel) : mostrarError(sel); }
                return;
            }
            if (esCampoValidable(t)) { t.checkValidity() ? ocultarError(t) : mostrarError(t); }
        }, true);

        form.addEventListener('input', function (ev) {
            if (esCampoValidable(ev.target)) {
                if (ev.target.checkValidity()) { ocultarError(ev.target); }
                actualizar();
            }
        });

        form.addEventListener('change', function (ev) {
            var t = ev.target;
            if (esCampoValidable(t)) {
                if (t.checkValidity()) { ocultarError(t); }
                actualizar();
            } else if (t.matches && t.matches('input[type=checkbox][data-multi]')) {
                var campoDiv = t.closest('.field');
                if (campoDiv) {
                    var checks = campoDiv.querySelectorAll('input[type=checkbox][data-multi]');
                    grupoValido(checks) ? ocultarErrorGrupo(campoDiv)
                        : mostrarErrorGrupo(campoDiv, 'Selecciona al menos una opción.');
                }
                actualizar();
            }
        });

        // poblarModal() llama a form.reset() y luego rellena los campos (alta o
        // edicion): se reevalua un instante despues, cuando ya quedo poblado.
        form.addEventListener('reset', function () {
            setTimeout(function () {
                form.querySelectorAll('.field-error').forEach(function (m) { m.remove(); });
                form.querySelectorAll('.is-invalid').forEach(function (el) { el.classList.remove('is-invalid'); });
                actualizar();
            }, 30);
        });

        actualizar();
    }

    /* =====================================================================
       8. RECUPERACION TRAS EL BOTON "ATRAS" (bfcache)
       Si el navegador restaura la pagina desde su cache de retroceso, un
       formulario recien enviado queda "congelado" en su estado de envio
       (boton en "Guardando…"), y el login puede no redirigir aunque la
       sesion ya sea valida (la restauracion no vuelve a ejecutar el
       controlador). Se fuerza una recarga real contra el servidor.
       ===================================================================== */
    window.addEventListener('pageshow', function (ev) {
        if (ev.persisted) { window.location.reload(); }
    });

    /* =====================================================================
       9. ARRANQUE
       ===================================================================== */
    Tema.aplicar(Tema.inicial(), false);

    var modalMouseDownTarget = null;
    document.addEventListener('mousedown', function (ev) {
        modalMouseDownTarget = ev.target;
    });

    document.addEventListener('DOMContentLoaded', function () {

        /* --- Delegacion global de eventos --- */
        document.addEventListener('click', function (ev) {
            var el;

            // Cerrar comboboxes personalizados al hacer clic afuera
            document.querySelectorAll('.c-select-wrap.open').forEach(function (w) {
                if (!w.contains(ev.target)) {
                    w.classList.remove('open');
                    var tr = w.querySelector('.c-select-trigger');
                    if (tr) tr.setAttribute('aria-expanded', 'false');
                }
            });

            // Abrir modal
            el = ev.target.closest('[data-modal-open]');
            if (el) {
                ev.preventDefault();
                var modal = Modal.abrir(el.getAttribute('data-modal-open'));
                poblarModal(modal, el);
                return;
            }

            // Cerrar modal
            el = ev.target.closest('[data-modal-close]');
            if (el) {
                ev.preventDefault();
                var destino = el.getAttribute('data-modal-close');
                Modal.cerrar(destino && destino !== 'true' ? destino : el.closest('.modal'));
                return;
            }

            // Clic en el telon de fondo: solo cerrar si mousedown Y click fueron directamente en el telon (.modal)
            // Esto evita que presionar dentro del modal y soltar afuera lo cierre por error.
            if (ev.target.classList && ev.target.classList.contains('modal')) {
                if (modalMouseDownTarget === ev.target) {
                    Modal.cerrar(ev.target);
                }
                modalMouseDownTarget = null;
                return;
            }

            // Fila desplegable
            el = ev.target.closest('[data-expand]');
            if (el) {
                ev.preventDefault();
                alternarDetalle(el);
                return;
            }

            // Alternar tema
            el = ev.target.closest('[data-tema]');
            if (el) {
                ev.preventDefault();
                Tema.alternar();
                return;
            }

            // Barra lateral en movil
            el = ev.target.closest('[data-sidebar-toggle]');
            if (el) {
                ev.preventDefault();
                document.querySelector('.sidebar').classList.toggle('open');
                document.querySelector('.sidebar-backdrop').classList.toggle('open');
                return;
            }
            if (ev.target.classList && ev.target.classList.contains('sidebar-backdrop')) {
                document.querySelector('.sidebar').classList.remove('open');
                ev.target.classList.remove('open');
                return;
            }

            // Copiar al portapapeles
            el = ev.target.closest('[data-copiar]');
            if (el) {
                ev.preventDefault();
                copiar(el.getAttribute('data-copiar'));
                return;
            }

            // Popovers / Tooltips
            var popTrigger = ev.target.closest('.popover-trigger');
            var popClose = ev.target.closest('.popover-close');
            var inPopover = ev.target.closest('.popover-wrap');

            if (popTrigger) {
                ev.preventDefault();
                var pWrap = popTrigger.closest('.popover-wrap');
                if (pWrap) {
                    var pBox = pWrap.querySelector('.popover-box');
                    if (pBox) pBox.classList.toggle('open');
                }
                return;
            }
            if (popClose) {
                ev.preventDefault();
                var pBoxClose = popClose.closest('.popover-box');
                if (pBoxClose) pBoxClose.classList.remove('open');
                return;
            }
            if (!inPopover) {
                document.querySelectorAll('.popover-box.open').forEach(function (b) {
                    b.classList.remove('open');
                });
            }
        });

        /* --- Teclado --- */
        document.addEventListener('keydown', function (ev) {
            if (ev.key === 'Escape') {
                Modal.cerrarUltimo();
                document.querySelectorAll('.popover-box.open').forEach(function (b) {
                    b.classList.remove('open');
                });
            }
        });

        /* --- Envio de formularios: evita doble clic --- */
        document.querySelectorAll('form[data-submit-once]').forEach(function (form) {
            form.addEventListener('submit', function () {
                var btn = form.querySelector('[type=submit]');
                if (btn) {
                    btn.classList.add('is-disabled');
                    btn.innerHTML = '<span class="mi mi-sm">progress_activity</span> Guardando…';
                }
            });
        });

        /* --- Filtro en vivo de tablas --- */
        document.querySelectorAll('[data-filter-target]').forEach(function (input) {
            input.addEventListener('input', function () { filtrarTabla(input); });
        });

        /* --- Selects en cascada --- */
        document.querySelectorAll('[data-cascade-source]').forEach(function (sel) {
            var destino = document.querySelector(sel.getAttribute('data-cascade-source'));
            if (!destino) { return; }
            sel.addEventListener('change', function () {
                cargarRutasDeEstacion(sel, destino, destino.dataset.preseleccion || '');
                destino.dataset.preseleccion = '';
            });
        });

        /* --- Logotipos oficiales aun no depositados --- */
        document.querySelectorAll('img[data-logo-oficial]').forEach(function (img) {
            img.addEventListener('error', function () { respaldoLogoOficial(img); });
            if (img.complete && img.naturalWidth === 0) { respaldoLogoOficial(img); }
        });

        /* --- Imagenes con respaldo generado --- */
        document.querySelectorAll('img[data-fallback]').forEach(function (img) {
            img.addEventListener('error', function () { respaldoImagen(img); });
            if (!img.getAttribute('src')) { respaldoImagen(img); }
        });

        /* --- Revelado al desplazar --- */
        var aRevelar = document.querySelectorAll('.reveal');
        function revelarTodo() {
            aRevelar.forEach(function (el) { el.classList.add('seen'); });
        }
        if ('IntersectionObserver' in window) {
            var obs = new IntersectionObserver(function (entradas) {
                entradas.forEach(function (e) {
                    if (e.isIntersecting) {
                        e.target.classList.add('seen');
                        obs.unobserve(e.target);
                    }
                });
            }, { threshold: 0, rootMargin: '0px 0px -8% 0px' });
            aRevelar.forEach(function (el) { obs.observe(el); });
            // Red de seguridad: nada puede quedar invisible por un fallo del observador
            setTimeout(revelarTodo, 2500);
        } else {
            revelarTodo();
        }

        /* --- Sombra de la barra superior al desplazar --- */
        var topnav = document.querySelector('.topnav');
        if (topnav) {
            var onScroll = function () { topnav.classList.toggle('scrolled', window.scrollY > 12); };
            window.addEventListener('scroll', onScroll, { passive: true });
            onScroll();
        }

        /* --- Cerrar selects abiertos al desplazar la pagina --- */
        window.addEventListener('scroll', function () {
            document.querySelectorAll('.c-select-wrap.open').forEach(function (w) {
                w.classList.remove('open');
                var tr = w.querySelector('.c-select-trigger');
                if (tr) { tr.setAttribute('aria-expanded', 'false'); }
                var m = w.querySelector('.c-select-menu');
                if (m) { m.style.maxHeight = ''; }
            });
        }, { passive: true });

        /* --- Tooltip flotante para categorias adicionales (+N) --- */
        (function initFloatingTooltips() {
            var tooltipEl = null;
            var activeTrigger = null;
            var hideTimeout = null;

            function getOrCreateTooltip() {
                if (!tooltipEl) {
                    tooltipEl = document.createElement('div');
                    tooltipEl.className = 'floating-tooltip';
                    tooltipEl.setAttribute('role', 'tooltip');
                    document.body.appendChild(tooltipEl);

                    tooltipEl.addEventListener('mouseenter', function () {
                        clearTimeout(hideTimeout);
                    });
                    tooltipEl.addEventListener('mouseleave', function () {
                        scheduleHide();
                    });
                }
                return tooltipEl;
            }

            function showTooltip(trigger) {
                clearTimeout(hideTimeout);
                var targetId = trigger.getAttribute('data-tooltip-html');
                if (!targetId) return;
                var tpl = document.getElementById(targetId);
                if (!tpl) return;

                var tip = getOrCreateTooltip();
                tip.innerHTML = tpl.innerHTML;

                activeTrigger = trigger;
                trigger.classList.add('active');

                tip.className = 'floating-tooltip visible';
                var rect = trigger.getBoundingClientRect();
                var tipRect = tip.getBoundingClientRect();

                var spaceAbove = rect.top;
                var spaceBelow = window.innerHeight - rect.bottom;
                var placeAbove = spaceAbove >= (tipRect.height + 12) || spaceAbove > spaceBelow;

                var topPos, arrowClass;
                if (placeAbove) {
                    topPos = rect.top - tipRect.height - 8 + window.scrollY;
                    arrowClass = 'arrow-bottom';
                } else {
                    topPos = rect.bottom + 8 + window.scrollY;
                    arrowClass = 'arrow-top';
                }

                var leftPos = rect.left + (rect.width / 2) - (tipRect.width / 2) + window.scrollX;
                var minLeft = 12 + window.scrollX;
                var maxLeft = document.documentElement.clientWidth - tipRect.width - 12 + window.scrollX;
                var clampedLeft = Math.max(minLeft, Math.min(maxLeft, leftPos));

                var arrowX = (rect.left + rect.width / 2 + window.scrollX) - clampedLeft;
                arrowX = Math.max(12, Math.min(tipRect.width - 12, arrowX));

                tip.className = 'floating-tooltip visible ' + arrowClass;
                tip.style.top = Math.round(topPos) + 'px';
                tip.style.left = Math.round(clampedLeft) + 'px';
                tip.style.setProperty('--arrow-x', Math.round(arrowX) + 'px');
            }

            function scheduleHide() {
                clearTimeout(hideTimeout);
                hideTimeout = setTimeout(hideTooltip, 120);
            }

            function hideTooltip() {
                if (tooltipEl) {
                    tooltipEl.classList.remove('visible');
                }
                if (activeTrigger) {
                    activeTrigger.classList.remove('active');
                    activeTrigger = null;
                }
            }

            document.addEventListener('mouseenter', function (ev) {
                var tr = ev.target.closest('[data-tooltip-html]');
                if (tr) {
                    showTooltip(tr);
                }
            }, true);

            document.addEventListener('mouseleave', function (ev) {
                var tr = ev.target.closest('[data-tooltip-html]');
                if (tr) {
                    scheduleHide();
                }
            }, true);

            document.addEventListener('focusin', function (ev) {
                var tr = ev.target.closest('[data-tooltip-html]');
                if (tr) {
                    showTooltip(tr);
                }
            });

            document.addEventListener('focusout', function (ev) {
                var tr = ev.target.closest('[data-tooltip-html]');
                if (tr) {
                    scheduleHide();
                }
            });

            document.addEventListener('click', function (ev) {
                var tr = ev.target.closest('[data-tooltip-html]');
                if (tr) {
                    ev.preventDefault();
                    ev.stopPropagation();
                    if (activeTrigger === tr && tooltipEl && tooltipEl.classList.contains('visible')) {
                        hideTooltip();
                    } else {
                        showTooltip(tr);
                    }
                    return;
                }
                if (tooltipEl && !tooltipEl.contains(ev.target)) {
                    hideTooltip();
                }
            });

            window.addEventListener('scroll', function () {
                if (tooltipEl && tooltipEl.classList.contains('visible')) {
                    hideTooltip();
                }
            }, { passive: true });
        })();

        /* --- Inicializar comboboxes con estilo mejorado --- */
        document.querySelectorAll('select.select').forEach(initCustomSelect);

        /* --- Inicializar autocompletado de destinos --- */
        document.querySelectorAll('input[data-autocomplete-destinos]').forEach(initAutocompleteDestinos);

        /* --- Inicializar selectores visuales de icono y color --- */
        document.querySelectorAll('[data-icon-picker]').forEach(initIconPicker);
        document.querySelectorAll('[data-color-picker]').forEach(initColorPicker);

        /* --- Mapa 3D del recorrido (portal publico), creado al acercarse --- */
        observarGeomaps();

        /* --- Validacion de campos obligatorios en los modales --- */
        document.querySelectorAll('.modal form[data-submit-once]').forEach(initValidacionModal);

        /* --- Toast enviado por el servidor (flash attribute) --- */
        var flash = document.getElementById('flash-toast');
        if (flash && flash.dataset.mensaje) {
            toast(flash.dataset.mensaje, flash.dataset.tipo || 'info');
        }
    });

    /* --- API publica --- */
    window.MTC = {
        toast: toast,
        modal: Modal,
        tema: Tema,
        confirmarEnvio: confirmarEnvio,
        tileZona: tileZona
    };
})();
