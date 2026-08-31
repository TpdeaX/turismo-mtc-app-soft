<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
    Console Warning - Mensaje de advertencia para desarrolladores
    Este componente muestra un mensaje de advertencia en la consola del navegador
    para disuadir a usuarios no técnicos de manipular el código.
    
    Uso: <jsp:include page="/views/shared/console-warning.jsp" />
--%>
<script>
    // Mensaje de advertencia para la consola del navegador
    (function() {
        console.log(
            "%c¡Detente!", 
            "color: #ff0000; font-size: 60px; font-weight: bold; text-shadow: 2px 2px 0px black; font-family: sans-serif;"
        );

        console.log(
            "%cEsta función del navegador está pensada para desarrolladores. Este código pertenece a la Empresa Grupo Peruana, si usted toca algún código no tendrá efectos en el sistema, sino solo en su propio navegador.", 
            "font-size: 16px; padding: 10px; border-radius: 5px; line-height: 1.5; font-family: sans-serif;"
        );
    })();
</script>
