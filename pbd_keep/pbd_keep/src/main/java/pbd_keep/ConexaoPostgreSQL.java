package pbd_keep;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConexaoPostgreSQL {
    private String host;
    private String username;
    private String password;
    private String port;
    private String dbname;

    public ConexaoPostgreSQL(){
        this.host = "localhost";
        this.port = "5432";
        this.username = "postgres";
        this.dbname = "google_keep";
        this.password = "postgres";
    }

    public Connection getConexao(){
        String url = "jdbc:postgresql://"+this.host+":"+this.port+"/"+this.dbname;
        try {
            System.out.println("conectou!");
            return DriverManager.getConnection(url, username, password);   
        } catch (Exception e) {
            System.out.println("Deu xabum!");
            return null;
        }
        
    }
    
}
