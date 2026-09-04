package com.zonasturisticas.plataforma.services.integracion;

/**
 * Resultado de un proceso periodico de sincronizacion con una fuente externa
 * (CU-06 / CU-07).
 */
public class ResultadoSincronizacion {

    private final String fuente;
    private final boolean exitosa;
    private final int registros;
    private final long duracionMs;
    private final String mensaje;

    public ResultadoSincronizacion(String fuente, boolean exitosa, int registros, long duracionMs, String mensaje) {
        this.fuente = fuente;
        this.exitosa = exitosa;
        this.registros = registros;
        this.duracionMs = duracionMs;
        this.mensaje = mensaje;
    }

    public String getFuente() { return fuente; }
    public boolean isExitosa() { return exitosa; }
    public int getRegistros() { return registros; }
    public long getDuracionMs() { return duracionMs; }
    public String getMensaje() { return mensaje; }
}
