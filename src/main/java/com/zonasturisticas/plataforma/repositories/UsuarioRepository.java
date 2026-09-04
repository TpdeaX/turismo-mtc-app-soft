package com.zonasturisticas.plataforma.repositories;

import com.zonasturisticas.plataforma.beans.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** RNF06: autenticacion de los gestores del panel administrativo. */
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    Usuario findFirstByCorreoIgnoreCase(String correo);

    Usuario findFirstByCorreoIgnoreCaseAndPasswordAndEstadoTrue(String correo, String password);

    List<Usuario> findAllByOrderByCodigoAsc();
}
