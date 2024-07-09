package pbd_keep;

import java.util.HashMap;
import java.util.Map;
import spark.ModelAndView;
import spark.template.mustache.MustacheTemplateEngine;

import static spark.Spark.get;

public class Main {
    public static void main(String[] args) {
        get("/", (request, response) -> {
           Map<String, Object> model = new HashMap<>();
            model.put("vetAnotacaoDTO",  new AnotacaoDAO().listar());
            return new ModelAndView(model, "index.html"); // hello.mustache file is in resources/templates directory
        }, new MustacheTemplateEngine());

        get("/copiar/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().copiar(id);
            response.redirect("/");
            return null;
        });


        get("/enviar_lixeira/:id", (request, response) -> {
            int id = Integer.parseInt(request.params(":id"));
            new AnotacaoDAO().enviarLixeira(id);
            response.redirect("/");
            return null;
        });

    }
}