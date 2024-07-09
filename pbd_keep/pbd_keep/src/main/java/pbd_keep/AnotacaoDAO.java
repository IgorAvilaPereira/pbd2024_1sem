package pbd_keep;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class AnotacaoDAO {

    public ArrayList<AnotacaoDTO> listar() throws SQLException {
        ArrayList<AnotacaoDTO> vetAnotacao = new ArrayList<>();
        String sql = "SELECT id, titulo, texto, formataTimeStamp(data_hora_criacao) as dataHoraCriacao, formataTimeStamp(data_hora_aviso) as dataHoraAviso from anotacao where lixeira is false";
        Connection connection = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        try (ResultSet rs = preparedStatement.executeQuery()) {
            while (rs.next()) {
                System.out.println("ok");
                AnotacaoDTO anotacaoDTO = new AnotacaoDTO(rs.getInt("id"), rs.getString("titulo"),
                        rs.getString("texto"), rs.getString("dataHoraCriacao"), rs.getString("dataHoraAviso"));
                vetAnotacao.add(anotacaoDTO);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());

        }
        preparedStatement.close();
        connection.close();
        System.out.println("passou aqui!.");
        System.out.println(vetAnotacao.size());
        return vetAnotacao;
    }

    public void copiar(int id) throws SQLException {
        String sql = "select copiarAnotacao(?);";
        Connection connection = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        preparedStatement.execute();
        preparedStatement.close();
        connection.close();
    }

    public void enviarLixeira(int id) throws SQLException {
        String sql = "select enviarLixeira(?);";
        Connection connection = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        preparedStatement.execute();
        preparedStatement.close();
        connection.close();
    }

}
