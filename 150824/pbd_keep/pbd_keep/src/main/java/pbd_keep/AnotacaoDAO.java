package pbd_keep;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

public class AnotacaoDAO {

    public ArrayList<AnotacaoDTO> listar(boolean lixeira) throws SQLException {
        ArrayList<AnotacaoDTO> vetAnotacao = new ArrayList<>();
        String sql = "SELECT id, titulo, texto, formataTimeStamp(data_hora_criacao) as dataHoraCriacao, formataTimeStamp(data_hora_aviso) as dataHoraAviso from anotacao where lixeira is "
                + lixeira;
        Connection connection = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        try (ResultSet rs = preparedStatement.executeQuery()) {
            while (rs.next()) {
                AnotacaoDTO anotacaoDTO = new AnotacaoDTO(rs.getInt("id"), rs.getString("titulo"),
                        rs.getString("texto"), rs.getString("dataHoraCriacao"), rs.getString("dataHoraAviso"));
                vetAnotacao.add(anotacaoDTO);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());

        }
        preparedStatement.close();
        connection.close();
        // System.out.println("passou aqui!.");
        // System.out.println(vetAnotacao.size());
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

    public void excluirDeVez(int id) throws SQLException {
        String sql = "select excluirDeVez(?);";
        Connection connection = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        preparedStatement.execute();
        preparedStatement.close();
        connection.close();
    }

    public ArrayList<AnotacaoDTO> listarLixeira() {
        try {
            return this.listar(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void restaurar(int id) {
        String sql = "UPDATE anotacao set lixeira = false where id = ?";

        try {
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, id);
            preparedStatement.execute();
            preparedStatement.close();
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    public boolean adicionar(Anotacao anotacao) {
        String sql = "select adicionar(?,?,?);";
        try {
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, anotacao.getTitulo());
            preparedStatement.setString(2, anotacao.getTexto());
            preparedStatement.setTimestamp(3, Timestamp.valueOf(anotacao.getDataHoraAviso()));
            preparedStatement.execute();
            preparedStatement.close();
            connection.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();

        }
        return false;
    }

    public Anotacao obter(int id) {
        Anotacao anotacao = new Anotacao();
        String sql = "SELECT * from anotacao where id = ?";
        try {
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, id);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                anotacao.setId(rs.getInt("id"));
                anotacao.setTexto(rs.getString("texto"));
                anotacao.setTitulo(rs.getString("titulo"));
                anotacao.setDataHoraAviso(rs.getTimestamp("data_hora_aviso").toLocalDateTime());
            }
            preparedStatement.close();
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return anotacao;
    }

    public boolean alterar(Anotacao anotacao) {
        String sql = "select alterar(?,?,?,?);";
        try {
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, anotacao.getId());
            preparedStatement.setString(2, anotacao.getTitulo());
            preparedStatement.setString(3, anotacao.getTexto());
            preparedStatement.setTimestamp(4, Timestamp.valueOf(anotacao.getDataHoraAviso()));
            preparedStatement.execute();
            preparedStatement.close();
            connection.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}
