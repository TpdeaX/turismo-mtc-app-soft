<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Cálculo de Asistencia</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <script type="importmap">
    {
      "imports": {
        "@material/web/": "https://esm.run/@material/web/"
      }
    }
    </script>
    <script type="module">
        import '@material/web/all.js';
        import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
        document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

    <style>
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        
        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
        }

        .compact-table th, .compact-table td { padding: 8px 12px !important; font-size: 0.85rem; }
        .actions-cell { display: flex; gap: 4px; justify-content: center; }

        /* Status Badges */
        .badge { padding: 4px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
        .badge-asistio { background-color: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
        .badge-tardanza { background-color: #fff8e1; color: #f57f17; border: 1px solid #ffe0b2; }
        .badge-falta { background-color: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }
        .badge-feriado { background-color: #e3f2fd; color: #1565c0; border: 1px solid #bbdefb; }
        
        .time-badge {
            background-color: var(--md-sys-color-surface-container);
            color: var(--md-sys-color-on-surface);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 0.8rem;
        }
        
        .diff-pos { color: #2e7d32; font-weight: 600; }
        .diff-neg { color: #c62828; font-weight: 600; }

        /* Animations */
        @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
        .fade-in { animation: fade-in 0.3s ease-out forwards; }
    </style>
</head>
<body>
    <div id="toast-mount-point" style="display:none;"></div>
    <jsp:include page="../shared/loading-screen.jsp" />
    <jsp:include page="../shared/console-warning.jsp" />
    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="container">
            <!-- Header -->
            <div class="page-header" style="flex-wrap: wrap; gap: 16px;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Reporte de Cálculo</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Detalle de horas trabajadas, tardanzas y horas extras.</p>
                </div>
                
                <div style="display: flex; gap: 12px; align-items: center;">
                    <md-outlined-button onclick="exportarExcel()">
                        <md-icon slot="icon">table_view</md-icon>
                        Excel
                    </md-outlined-button>
                    <md-outlined-button onclick="exportarPDF()">
                        <md-icon slot="icon">picture_as_pdf</md-icon>
                        PDF
                    </md-outlined-button>
                </div>
            </div>

            <!-- Filters -->
            <div class="card" style="margin-bottom: 24px; padding: 24px;">
                <form id="filterForm" action="${pageContext.request.contextPath}/reportes/calculo" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
                    <div style="display: grid; grid-template-columns: repeat(12, 1fr); gap: 16px; align-items: center;">
                        
                        <!-- Empleado -->
                        <div style="grid-column: span 3;">
                            <md-outlined-select label="Empleado" name="empleadoId" style="width: 100%;">
                                <md-select-option value="" ${empty empleadoId ? 'selected' : ''}>
                                    <div slot="headline">Todos</div>
                                </md-select-option>
                                <c:forEach var="e" items="${empleados}">
                                    <md-select-option value="${e.id}" ${empleadoId == e.id ? 'selected' : ''}>
                                        <div slot="headline">${e.apellidos}, ${e.nombres}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Sucursal -->
                        <div style="grid-column: span 3;">
                            <md-outlined-select label="Sucursal" name="sucursalId" style="width: 100%;">
                                <md-select-option value="" ${empty sucursalId ? 'selected' : ''}>
                                    <div slot="headline">Todas</div>
                                </md-select-option>
                                <c:forEach var="s" items="${sucursales}">
                                    <md-select-option value="${s.id}" ${sucursalId == s.id ? 'selected' : ''}>
                                        <div slot="headline">${s.nombre}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Fechas -->
                        <div style="grid-column: span 2;">
                            <md-outlined-text-field label="Desde" type="date" name="fechaInicio" value="${fechaInicio}" style="width: 100%;"></md-outlined-text-field>
                        </div>
                        <div style="grid-column: span 2;">
                            <md-outlined-text-field label="Hasta" type="date" name="fechaFin" value="${fechaFin}" style="width: 100%;"></md-outlined-text-field>
                        </div>

                        <div style="grid-column: span 2; display: flex; justify-content: flex-end;">
                           <md-filled-button type="button" onclick="submitFilter()" style="height: 56px; width: 100%;">
                                <md-icon>search</md-icon>
                                Generar
                            </md-filled-button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- List View (Table) -->
            <c:if test="${not empty reporteGenerado}">
                <div class="card fade-in">
                    <div class="table-container" style="overflow-x: auto;">
                        <table class="compact-table" style="width: 100%; min-width: 1000px;">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Empleado</th>
                                    <th>Sucursal</th>
                                    <th style="text-align: center;">Horario</th>
                                    <th style="text-align: center;">Marcaciones</th>
                                    <th style="text-align: right;">Prog.</th>
                                    <th style="text-align: right;">Trab.</th>
                                    <th style="text-align: right;">Dif/Extra</th>
                                    <th style="text-align: right;">Tard.(min)</th>
                                    <th style="text-align: center;">Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${reporte}">
                                    <tr>
                                        <td>
                                            <div style="font-weight: 500;">${r.fecha}</div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 500; font-size: 0.8rem;">${r.nombreEmpleado}</div>
                                            <div style="font-size: 0.7rem; color: var(--md-sys-color-secondary);">${r.dniEmpleado}</div>
                                        </td>
                                        <td>${r.sucursal}</td>
                                        
                                        <!-- Horario -->
                                        <td style="text-align: center;">
                                            <span class="time-badge">${r.horarioEntrada != null ? r.horarioEntrada : '--:--'}</span> - 
                                            <span class="time-badge">${r.horarioSalida != null ? r.horarioSalida : '--:--'}</span>
                                        </td>
                                        
                                        <!-- Marcaciones -->
                                        <td style="text-align: center;">
                                            <span class="time-badge" style="${r.asistenciaEntrada != null && r.horarioEntrada != null && r.asistenciaEntrada.isAfter(r.horarioEntrada.plusMinutes(5)) ? 'color: #c62828;' : ''}">${r.asistenciaEntrada != null ? r.asistenciaEntrada : '--:--'}</span> - 
                                            <span class="time-badge">${r.asistenciaSalida != null ? r.asistenciaSalida : '--:--'}</span>
                                        </td>

                                        <td style="text-align: right;"><fmt:formatNumber value="${r.horasProgramadas}" type="number" maxFractionDigits="2"/></td>
                                        <td style="text-align: right;"><fmt:formatNumber value="${r.horasTrabajadas}" type="number" maxFractionDigits="2"/></td>
                                        
                                        <td style="text-align: right;">
                                            <span class="${r.diferenciaHoras > 0 ? 'diff-pos' : (r.diferenciaHoras < 0 ? 'diff-neg' : '')}">
                                                ${r.diferenciaHoras > 0 ? '+' : ''}<fmt:formatNumber value="${r.diferenciaHoras}" type="number" maxFractionDigits="2"/>
                                            </span>
                                        </td>

                                        <td style="text-align: right; color: ${r.minutosTardanza > 0 ? '#c62828' : 'inherit'}; font-weight: ${r.minutosTardanza > 0 ? '600' : '400'};">
                                            ${r.minutosTardanza}
                                        </td>

                                        <td style="text-align: center;">
                                            <span class="badge ${r.estado == 'ASISTIO' ? 'badge-asistio' : (r.estado == 'TARDANZA' ? 'badge-tardanza' : (r.estado == 'FALTA' ? 'badge-falta' : 'badge-feriado'))}">
                                                ${r.estado}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty reporte}">
                                    <tr>
                                        <td colspan="10" style="text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                                            No se encontraron registros.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div style="padding: 16px 24px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px; border-top: 1px solid var(--md-sys-color-outline-variant);">
                        <div style="display: flex; align-items: center; gap: 24px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas:</span>
                                <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                    <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                                    <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
                                    <md-select-option value="50" ${size == 50 ? 'selected' : ''}><div slot="headline">50</div></md-select-option>
                                    <md-select-option value="100" ${size == 100 ? 'selected' : ''}><div slot="headline">100</div></md-select-option>
                                </md-outlined-select>
                            </div>
                            <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                                Pág ${pagina.number + 1} de ${pagina.totalPages}
                            </div>
                        </div>
                        
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                <md-icon>chevron_left</md-icon>
                            </md-icon-button>
                            <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                <md-icon>chevron_right</md-icon>
                            </md-icon-button>
                        </div>
                    </div>
                </div>
            </c:if>
            <c:if test="${empty reporteGenerado}">
                 <div style="text-align: center; padding: 60px; color: var(--md-sys-color-secondary);">
                    <md-icon style="font-size: 48px; margin-bottom: 16px; color: var(--md-sys-color-outline);">analytics</md-icon>
                    <p style="font-size: 1.1rem;">Seleccione filtros y haga clic en "Generar" para ver el reporte.</p>
                 </div>
            </c:if>
        </div>

        <script>
            function submitFilter() {
                document.getElementById('pageInput').value = 0;
                document.getElementById('filterForm').submit();
            }

            function changePage(page) {
                const totalPages = ${pagina.totalPages != null ? pagina.totalPages : 0};
                if (page < 0 || (totalPages > 0 && page >= totalPages)) {
                    showToast('Error', 'Página inválida', 'error', 'error');
                    return;
                }
                document.getElementById('pageInput').value = page;
                document.getElementById('filterForm').submit();
            }

            function changeSize(size) {
                document.getElementById('sizeInput').value = size;
                document.getElementById('pageInput').value = 0;
                document.getElementById('filterForm').submit();
            }

            function exportarExcel() {
                window.location.href = '${pageContext.request.contextPath}/reportes/exportar/excel';
            }
            
            function exportarPDF() {
                window.location.href = '${pageContext.request.contextPath}/reportes/exportar/pdf';
            }
        </script>
        
        <!-- Shared Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    </div>
</body>
</html>
