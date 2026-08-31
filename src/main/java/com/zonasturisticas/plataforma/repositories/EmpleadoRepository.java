package com.zonasturisticas.plataforma.repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.zonasturisticas.plataforma.beans.Empleado;

@Repository
public interface EmpleadoRepository extends JpaRepository<Empleado, Integer> {

        Empleado findByDniAndPasswordAndEstado(String dni, String password, int estado);

        // Query para login que carga empresas eagerly para evitar
        // LazyInitializationException
        @org.springframework.data.jpa.repository.Query("SELECT DISTINCT e FROM Empleado e " +
                        "LEFT JOIN FETCH e.permisos " +
                        "LEFT JOIN FETCH e.empresas " +
                        "WHERE e.dni = :dni AND e.password = :password AND e.estado = 1")
        Empleado findByDniAndPasswordWithEmpresas(
                        @org.springframework.data.repository.query.Param("dni") String dni,
                        @org.springframework.data.repository.query.Param("password") String password);

        List<Empleado> findByEstadoOrderByApellidosAsc(int estado);

        Empleado findByDni(String dni);

        boolean existsByDni(String dni);

        @org.springframework.data.jpa.repository.Query("SELECT DISTINCT e FROM Empleado e LEFT JOIN FETCH e.permisos WHERE "
                        +
                        "( e.estado = 1 ) AND " +
                        "( COALESCE(:keyword, '') = '' OR LOWER(e.nombres) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(e.apellidos) LIKE LOWER(CONCAT('%', :keyword, '%')) OR e.dni LIKE %:keyword% ) AND "
                        +
                        "( COALESCE(:rol, '') = '' OR e.rol = :rol ) AND " +
                        "( COALESCE(:modalidad, '') = '' OR e.tipoModalidad = :modalidad ) AND " +
                        "( :sucursalId IS NULL OR e.sucursal.id = :sucursalId )")
        org.springframework.data.domain.Page<Empleado> buscarAvanzado(
                        @org.springframework.data.repository.query.Param("keyword") String keyword,
                        @org.springframework.data.repository.query.Param("rol") String rol,
                        @org.springframework.data.repository.query.Param("modalidad") String modalidad,
                        @org.springframework.data.repository.query.Param("sucursalId") Integer sucursalId,
                        org.springframework.data.domain.Pageable pageable);

        // Query avanzada con filtro por empresas del administrador
        // Si empresaIds está vacío o es null, retorna todos los empleados
        // (comportamiento original)
        // Si tiene valores, solo retorna empleados cuya sucursal pertenezca a alguna de
        // esas empresas
        @org.springframework.data.jpa.repository.Query("SELECT DISTINCT e FROM Empleado e LEFT JOIN FETCH e.permisos WHERE "
                        +
                        "( e.estado = 1 ) AND " +
                        "( COALESCE(:keyword, '') = '' OR LOWER(e.nombres) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(e.apellidos) LIKE LOWER(CONCAT('%', :keyword, '%')) OR e.dni LIKE %:keyword% ) AND "
                        +
                        "( COALESCE(:rol, '') = '' OR e.rol = :rol ) AND " +
                        "( COALESCE(:modalidad, '') = '' OR e.tipoModalidad = :modalidad ) AND " +
                        "( :sucursalId IS NULL OR e.sucursal.id = :sucursalId ) AND " +
                        "( :empresaIds IS NULL OR e.sucursal.empresa.id IN :empresaIds )")
        org.springframework.data.domain.Page<Empleado> buscarAvanzadoConEmpresas(
                        @org.springframework.data.repository.query.Param("keyword") String keyword,
                        @org.springframework.data.repository.query.Param("rol") String rol,
                        @org.springframework.data.repository.query.Param("modalidad") String modalidad,
                        @org.springframework.data.repository.query.Param("sucursalId") Integer sucursalId,
                        @org.springframework.data.repository.query.Param("empresaIds") java.util.List<Integer> empresaIds,
                        org.springframework.data.domain.Pageable pageable);
}
