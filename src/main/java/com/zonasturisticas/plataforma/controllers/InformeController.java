package com.zonasturisticas.plataforma.controllers;

import com.zonasturisticas.plataforma.config.GlobalModelAdvice;
import com.zonasturisticas.plataforma.dto.InformeConsolidadoDTO;
import com.zonasturisticas.plataforma.dto.PreferenciasSesion;
import com.zonasturisticas.plataforma.services.InformePdfService;
import com.zonasturisticas.plataforma.services.InformeService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * RF07 / CU-03 paso 6: informe consolidado visualizable y descargable.
 * RNF07: el mismo informe se entrega en HTML y en PDF.
 */
@Controller
public class InformeController {

    private final InformeService informeService;
    private final InformePdfService informePdfService;

    public InformeController(InformeService informeService, InformePdfService informePdfService) {
        this.informeService = informeService;
        this.informePdfService = informePdfService;
    }

    /** Version HTML del informe consolidado. */
    @GetMapping("/informe/{codigo}")
    public String verInforme(@PathVariable Integer codigo, HttpSession session, Model model) {
        InformeConsolidadoDTO informe = informeService.generar(codigo, preferencias(session));
        if (informe == null) {
            return "redirect:/explorar";
        }
        model.addAttribute("informe", informe);
        return "portal/informe";
    }

    /** Version PDF del informe consolidado (RNF07). */
    @GetMapping("/informe/{codigo}/pdf")
    public ResponseEntity<byte[]> descargarInforme(@PathVariable Integer codigo, HttpSession session) {
        InformeConsolidadoDTO informe = informeService.generar(codigo, preferencias(session));
        if (informe == null) {
            return ResponseEntity.notFound().build();
        }
        byte[] pdf = informePdfService.generar(informe);
        String archivo = "Informe-" + informe.getFolio() + ".pdf";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", archivo);
        headers.setContentLength(pdf.length);
        return new ResponseEntity<>(pdf, headers, org.springframework.http.HttpStatus.OK);
    }

    private PreferenciasSesion preferencias(HttpSession session) {
        PreferenciasSesion p = (PreferenciasSesion) session.getAttribute(GlobalModelAdvice.ATTR_PREFERENCIAS);
        return p == null ? new PreferenciasSesion() : p;
    }
}
