package pbd_keep;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import spark.ModelAndView;
import spark.template.mustache.MustacheTemplateEngine;

import static spark.Spark.get;
import static spark.Spark.post;
import static spark.Spark.put;

public class Main {
    public static void main(String[] args) {

        get("/", (request, response) -> {
            Map<String, Object> template = new HashMap<>();
            template.put("titulo", "Minhas Anotações");
            template.put("vetAnotacaoDTO", new AnotacaoDAO().listar(false));
            return new ModelAndView(template, "index.html"); // hello.mustache file is in resources/templates directory
        }, new MustacheTemplateEngine());

        get("/lixeira", (request, response) -> {
            Map<String, Object> template = new HashMap<>();
            template.put("titulo", "Lixeira");
            template.put("exibir_lixeira", true);
            template.put("vetAnotacaoDTO", new AnotacaoDAO().listarLixeira());
            return new ModelAndView(template, "index.html"); // hello.mustache file is in resources/templates directory
        }, new MustacheTemplateEngine());

        get("/tela_adicionar", (request, response) -> {
            return new ModelAndView(new HashMap(), "tela.html"); // hello.mustache file is in
                                                                           // resources/templates directory
        }, new MustacheTemplateEngine());

        get("/tela_alterar/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            Anotacao anotacao = new AnotacaoDAO().obter(id);
            Map<String, Object> template = new HashMap<>();
            template.put("anotacao", anotacao);
            return new ModelAndView(template, "tela.html"); // hello.mustache file is in
                                                                           // resources/templates directory
        }, new MustacheTemplateEngine());

        get("/copiar/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().copiar(id);
            response.redirect("/");
            return null;
        });

        post("/adicionar", (request, response) -> {
            String titulo = request.queryParams("titulo");
            String texto = request.queryParams("texto");
            String dataHoraAviso = request.queryParams("dataHoraAviso");            
            Anotacao anotacao = new Anotacao();
            anotacao.setTexto(texto);
            anotacao.setTitulo(titulo);
            anotacao.setDataHoraAviso(LocalDateTime.parse(dataHoraAviso));
            new AnotacaoDAO().adicionar(anotacao);

            response.redirect("/");
            return null;
        });



        post("/alterar", (request, response) -> {
            int id = Integer.parseInt(request.queryParams("id"));
            String titulo = request.queryParams("titulo");
            String texto = request.queryParams("texto");
            String dataHoraAviso = request.queryParams("dataHoraAviso");            
            Anotacao anotacao = new Anotacao();
            anotacao.setId(id);
            anotacao.setTexto(texto);
            anotacao.setTitulo(titulo);
            anotacao.setDataHoraAviso(LocalDateTime.parse(dataHoraAviso));
            new AnotacaoDAO().alterar(anotacao);

            response.redirect("/");
            return null;
        });

        get("/enviar_lixeira/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().enviarLixeira(id);
            response.redirect("/");
            return null;
        });

        get("/restaurar/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().restaurar(id);
            response.redirect("/");
            return null;
        });

        get("/excluir/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().excluirDeVez(id);
            response.redirect("/");
            return null;
        });

    }
}