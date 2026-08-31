package com.zonasturisticas.plataforma.services;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import java.util.Map;
import java.util.HashMap;

@Service
public class ConsultaDniService {

    public Map<String, Object> consultarDni(String dni) {
        Map<String, Object> resultado = new HashMap<>();

        if (dni == null || !dni.matches("\\d{8}")) {
            resultado.put("ok", false);
            resultado.put("mensaje", "El DNI debe contener exactamente 8 dígitos numéricos.");
            return resultado;
        }

        String url = "https://ww1.sunat.gob.pe/ol-ti-itfisdenreg/itfisdenreg.htm?accion=obtenerDatosDni&numDocumento="
                + dni;

        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
            headers.set("Referer", "https://ww1.sunat.gob.pe/");
            headers.set("Accept", "application/json, text/plain, */*");

            HttpEntity<String> entity = new HttpEntity<>(headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                Map<String, Object> data = mapper.readValue(response.getBody(), Map.class);

                if (data.containsKey("message") && "success".equals(data.get("message"))) {
                    java.util.List<Map<String, Object>> lista = (java.util.List<Map<String, Object>>) data.get("lista");
                    if (lista != null && !lista.isEmpty()) {
                        Map<String, Object> primerResultado = lista.get(0);
                        String nombresApellidos = (String) primerResultado.get("nombresapellidos");

                        if (nombresApellidos != null) {
                            String[] partes = nombresApellidos.split(",");
                            if (partes.length >= 2) {
                                String apellidos = partes[0].trim();
                                String nombres = partes[1].trim();

                                // Map to frontend expected fields
                                Map<String, Object> persona = new HashMap<>();
                                persona.put("nombres", nombres);
                                persona.put("apePaterno", apellidos); // Putting all surnames in apePaterno to display
                                                                      // safely in "Apellidos" field
                                persona.put("apeMaterno", "");

                                resultado.put("ok", true);
                                resultado.put("datos", persona);
                            } else {
                                // Fallback if format is unexpected but success
                                resultado.put("ok", false);
                                resultado.put("mensaje", "Formato de respuesta inesperado.");
                            }
                        } else {
                            resultado.put("ok", false);
                            resultado.put("mensaje", "No se encontraron nombres en la respuesta.");
                        }
                    } else {
                        resultado.put("ok", false);
                        resultado.put("mensaje", "Lista de resultados vacía.");
                    }
                } else if (data.containsKey("error")) {
                    resultado.put("ok", false);
                    resultado.put("mensaje", data.get("error"));
                } else {
                    resultado.put("ok", false);
                    resultado.put("mensaje", "Respuesta desconocida de SUNAT.");
                }
            } else {
                resultado.put("ok", false);
                resultado.put("mensaje", "No se encontraron datos o servicio no disponible.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resultado.put("ok", false);
            resultado.put("mensaje", "Error al consultar SUNAT: " + e.getMessage());
        }

        return resultado;
    }
}
