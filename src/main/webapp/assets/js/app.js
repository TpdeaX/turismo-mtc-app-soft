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

            el.classList.add('open');
            el.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
            Modal.abiertos.push(el);

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
        selectRuta.innerHTML = '<option value="">Cargando rutas…</option>';

        if (!codigo) {
            selectRuta.innerHTML = '<option value="">Seleccione primero una estación</option>';
            return;
        }
        fetch(selectRuta.dataset.base.replace('{codigo}', codigo))
            .then(function (r) { return r.json(); })
            .then(function (rutas) {
                if (!rutas.length) {
                    selectRuta.innerHTML =
                        '<option value="">Esta estación aún no tiene rutas registradas</option>';
                    return;
                }
                selectRuta.innerHTML = '<option value="">Seleccione una ruta…</option>' +
                    rutas.map(function (r) {
                        return '<option value="' + r.codigo + '">' + r.nombre +
                            ' · ' + r.distanciaKm + ' km · ' + r.dificultad + '</option>';
                    }).join('');
                if (seleccionado) { selectRuta.value = seleccionado; }
            })
            .catch(function () {
                selectRuta.innerHTML = '<option value="">No se pudieron cargar las rutas</option>';
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
        'plaza de armas': 'https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80',
        'qorikancha': 'https://images.unsplash.com/photo-1526392060635-9d6019884377?auto=format&fit=crop&w=800&q=80',
        'san blas': 'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80',
        'poroy': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80',
        'ollantaytambo': 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80',
        'pueblo inca': 'https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80',
        'pinkuylluna': 'https://images.unsplash.com/photo-1528164344705-475426879c0d?auto=format&fit=crop&w=800&q=80',
        'mandor': 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
        'aguas calientes': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
        'termales': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
        'museo': 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80',
        'valle sagrado': 'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80',
        'uros': 'https://images.unsplash.com/photo-1533050487297-09b450131914?auto=format&fit=crop&w=800&q=80',
        'kuntur wasi': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
        'juliaca': 'https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=800&q=80',
        'monasterio': 'https://images.unsplash.com/photo-1587974928442-77dc3e0dba72?auto=format&fit=crop&w=800&q=80',
        'arequipa': 'https://images.unsplash.com/photo-1531968455001-5c5272a41129?auto=format&fit=crop&w=800&q=80',
        'catedral': 'https://images.unsplash.com/photo-1531968455001-5c5272a41129?auto=format&fit=crop&w=800&q=80',
        'yanahuara': 'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80'
    };
    var FOTOS_GENERALES = [
        'https://images.unsplash.com/photo-1526392060635-9d6019884377?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1587595431973-160d0d94add1?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1589556264800-08ae9e129a8c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1531968455001-5c5272a41129?auto=format&fit=crop&w=800&q=80'
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

        if (!img.dataset.fallbackAplicado) {
            img.dataset.fallbackAplicado = '1';
            img.src = obtenerFotoDestino(nombre, semilla);
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
       8. ARRANQUE
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

        /* --- Inicializar comboboxes con estilo mejorado --- */
        document.querySelectorAll('select.select').forEach(initCustomSelect);

        /* --- Inicializar autocompletado de destinos --- */
        document.querySelectorAll('input[data-autocomplete-destinos]').forEach(initAutocompleteDestinos);

        /* --- Inicializar selectores visuales de icono y color --- */
        document.querySelectorAll('[data-icon-picker]').forEach(initIconPicker);
        document.querySelectorAll('[data-color-picker]').forEach(initColorPicker);

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
