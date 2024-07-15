package pbd_keep;

import java.time.LocalDateTime;

public class Anotacao {
    private int id;
    private String titulo;
    private String texto;
    private LocalDateTime dataHoraCriacao;
    private LocalDateTime dataHoraAviso;

    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getTitulo() {
        return titulo;
    }
    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
    public String getTexto() {
        return texto;
    }
    public void setTexto(String texto) {
        this.texto = texto;
    }
    public LocalDateTime getDataHoraCriacao() {
        return dataHoraCriacao;
    }
    public void setDataHoraCriacao(LocalDateTime dataHoraCriacao) {
        this.dataHoraCriacao = dataHoraCriacao;
    }
    public LocalDateTime getDataHoraAviso() {
        return dataHoraAviso;
    }
    public void setDataHoraAviso(LocalDateTime dataHoraAviso) {
        this.dataHoraAviso = dataHoraAviso;
    }
    @Override
    public String toString() {
        return "Anotacao [id=" + id + ", titulo=" + titulo + ", texto=" + texto + ", dataHoraCriacao=" + dataHoraCriacao
                + ", dataHoraAviso=" + dataHoraAviso + "]";
    }

    

    
    
}
