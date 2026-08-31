package com.zonasturisticas.plataforma.utilitarios;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import io.github.cdimascio.dotenv.Dotenv;

public class Conexion {
    private static Conexion instance;
    private Connection connection;
    private String url;
    private String user;
    private String password;

    private Conexion() {
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();

        String hostEnv = dotenv.get("DB_HOST");
        String host = (hostEnv != null) ? hostEnv : "localhost";

        String portEnv = dotenv.get("DB_PORT");
        String port = (portEnv != null) ? portEnv : "3306";

        String dbNameEnv = dotenv.get("DB_NAME");
        String dbName = (dbNameEnv != null) ? dbNameEnv : "grupoperuana";
        
        String userEnv = dotenv.get("DB_USER");
        this.user = (userEnv != null) ? userEnv : "root";
        
        String passEnv = dotenv.get("DB_PASS");
        this.password = (passEnv != null) ? passEnv : "123456";

        this.url = "jdbc:mysql://" + host + ":" + port + "/" + dbName + 
                   "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            System.err.println("Error: Driver MySQL no encontrado.");
        }
    }

    public static Connection getConnection() throws SQLException {
        if (instance == null) {
            instance = new Conexion();
        }
        return instance.createConnection();
    }

    private Connection createConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection(url, user, password);
        }
        return connection;
    }
}
