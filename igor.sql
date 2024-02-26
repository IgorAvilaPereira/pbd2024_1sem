DROP DATABASE IF EXISTS igor;

CREATE DATABASE igor;

\c igor;

CREATE TABLE pessoa (
    id      SERIAL PRIMARY KEY,
    nome    TEXT,
    cpf     CHARACTER(11) UNIQUE
);

INSERT INTO pessoa (nome,cpf) VALUES ('IGOR PEREIRA', '11111111111'); 

INSERT INTO pessoa (nome,cpf) VALUES ('RAFAEL BETITO', '22222222222'); 

CREATE OR REPLACE FUNCTION soma_produto (x integer, y integer, OUT soma INTEGER, OUT produto integer) as
$$
BEGIN
    soma := x + y;
    produto := x*y;
END;
$$ LANGUAGE 'plpgsql';
-- igor=# SELECT soma_produto(3,2);
-- igor=# SELECT * FROM soma_produto(3,2);


CREATE OR REPLACE FUNCTION exportar_csv() RETURNS text AS
$$
DECLARE
    resultado text;
    r_pessoa record;
BEGIN
    resultado := '';
    FOR r_pessoa in SELECT * FROM pessoa LOOP
    	raise notice '%', r_pessoa.nome;
        resultado := resultado || cast(r_pessoa.id as text)||','||r_pessoa.nome||','||r_pessoa.cpf || '<quebra_de_linha>';
    END LOOP;
    RETURN resultado;       
END;
$$ LANGUAGE 'plpgsql';


CREATE FUNCTION exibe(integer) RETURNS text AS
$$
DECLARE
    resultado text;
BEGIN
    SELECT nome||','||cpf FROM pessoa WHERE id = $1 INTO resultado;
    RETURN resultado;       
END;
$$ LANGUAGE 'plpgsql';


CREATE FUNCTION exibe_record(integer) RETURNS text AS
$$
DECLARE
    resultado RECORD;
BEGIN
    SELECT nome,cpf FROM pessoa WHERE id = $1 INTO resultado;
    RETURN resultado.nome||','||resultado.cpf;       
END;
$$ LANGUAGE 'plpgsql';



CREATE FUNCTION soma(text, text) RETURNS char AS
$$
DECLARE
    resultado text;
BEGIN
    resultado := $1 || ' ' || $2;
    RETURN resultado;       
END;
$$ LANGUAGE 'plpgsql';

