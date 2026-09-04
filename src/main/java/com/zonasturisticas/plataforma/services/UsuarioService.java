package com.zonasturisticas.plataforma.services;

import com.zonasturisticas.plataforma.beans.Usuario;
import com.zonasturisticas.plataforma.repositories.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * RNF06: autenticacion de los gestores autorizados del panel administrativo.
 */
@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    public UsuarioService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    /** Valida las credenciales y registra el acceso. Devuelve null si fallan. */
    @Transactional
    public Usuario autenticar(String correo, String password) {
        if (correo == null || password == null) {
            return null;
        }
        Usuario usuario = usuarioRepository.findFirstByCorreoIgnoreCaseAndPasswordAndEstadoTrue(
                correo.trim(), PasswordUtil.cifrar(password));
        if (usuario != null) {
            usuario.setUltimoAcceso(LocalDateTime.now());
            usuarioRepository.save(usuario);
        }
        return usuario;
    }

    public List<Usuario> listar() {
        return usuarioRepository.findAllByOrderByCodigoAsc();
    }

    public Usuario obtener(Integer codigo) {
        return codigo == null ? null : usuarioRepository.findById(codigo).orElse(null);
    }

    public boolean existeCorreo(String correo, Integer excluirCodigo) {
        Usuario u = usuarioRepository.findFirstByCorreoIgnoreCase(correo);
        return u != null && !u.getCodigo().equals(excluirCodigo);
    }

    /**
     * Guarda el gestor. Si {@code passwordPlano} viene vacio en una edicion se
     * conserva la contrasena anterior.
     */
    @Transactional
    public Usuario guardar(Usuario usuario, String passwordPlano) {
        if (usuario.getCorreo() == null || usuario.getCorreo().isBlank()) {
            throw new IllegalArgumentException("El correo del gestor es obligatorio.");
        }
        if (existeCorreo(usuario.getCorreo(), usuario.getCodigo())) {
            throw new IllegalArgumentException("Ya existe un gestor registrado con ese correo.");
        }
        if (passwordPlano != null && !passwordPlano.isBlank()) {
            usuario.setPassword(PasswordUtil.cifrar(passwordPlano));
        } else if (usuario.getCodigo() != null) {
            Usuario actual = obtener(usuario.getCodigo());
            if (actual != null) {
                usuario.setPassword(actual.getPassword());
            }
        }
        if (usuario.getPassword() == null || usuario.getPassword().isBlank()) {
            throw new IllegalArgumentException("Debe asignar una contraseña al gestor.");
        }
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public void eliminar(Integer codigo) {
        usuarioRepository.deleteById(codigo);
    }

    @Transactional
    public void registrarSiFalta(String correo, String passwordPlano, String nombre, String rol) {
        if (usuarioRepository.findFirstByCorreoIgnoreCase(correo) == null) {
            usuarioRepository.save(new Usuario(correo, PasswordUtil.cifrar(passwordPlano), nombre, rol));
        }
    }
}
