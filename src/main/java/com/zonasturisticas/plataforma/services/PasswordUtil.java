package com.zonasturisticas.plataforma.services;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Cifrado de contrasenas de los gestores (RNF06).
 * Aplica SHA-256 con sal fija de aplicacion sobre el correo del usuario.
 */
public final class PasswordUtil {

    private static final String SAL = "mtc-zonas-turisticas-2026";

    private PasswordUtil() {
    }

    public static String cifrar(String password) {
        if (password == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest((SAL + password).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    sb.append('0');
                }
                sb.append(hex);
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("No se pudo cifrar la contrasena", e);
        }
    }

    public static boolean coincide(String plano, String cifrado) {
        return cifrado != null && cifrado.equals(cifrar(plano));
    }
}
