DROP DATABASE IF EXISTS google_keep;

CREATE DATABASE google_keep;

\c google_keep;

/*
===============
Google Keep -> Tabajara
> Anotação
    > id: serial
    > titulo: character varying(100)
    > texto: text
    > data/hora_criação: timestamp default timestamp
    > data/hora_atualização: timestamp
    > data/hora_aviso: timestamp
    > lixeira: boolean default false
====================
*/
CREATE TABLE anotacao (
    id serial primary key,
    titulo character varying(100),
    texto text,
    data_hora_criacao timestamp default current_timestamp,
    data_hora_aviso timestamp,
    lixeira BOOLEAN DEFAULT false
);

CREATE TABLE log (
    id serial primary key,
    texto text
);

INSERT INTO anotacao (titulo, texto, data_hora_aviso) VALUES
('ATIVIDADE AVALIADA DE PBD - DIA MARCADO', 'DIA 29/07', current_timestamp + interval '7 days');

CREATE OR REPLACE FUNCTION formataTimeStamp(data_hora timestamp) RETURNS CHARACTER VARYING(19) AS
$$
BEGIN
    RETURN TO_CHAR(data_hora,'dd/mm/yyyy HH:MI:SS')::CHARACTER VARYING(19);
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION copiarAnotacao(bigint) RETURNS VOID AS 
$$
DECLARE
    registro anotacao%ROWTYPE;
BEGIN
    select * from anotacao where id = $1 into registro;
    INSERT INTO anotacao (titulo, texto, data_hora_criacao, data_hora_aviso) VALUES
(registro.titulo, registro.texto, registro.data_hora_criacao, registro.data_hora_aviso); 
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION enviarLixeira(bigint) RETURNS boolean AS 
$$
BEGIN
    BEGIN
        UPDATE anotacao SET lixeira = TRUE where id = $1;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN RAISE NOTICE 'DEU XABUM';
        RETURN FALSE;
    END;    
END;
$$ language 'plpgsql';

CREATE OR REPLACE function excluirDeVez(bigint) returns boolean as
$$
DECLARE
    registro record;
begin
    BEGIN
        select into registro * from anotacao where id = $1;
        DELETE FROM anotacao where id = $1;
        INSERT INTO log (texto) values ('deletando de vez a anotação: '|| registro.id || ',' || registro.titulo);
        return TRUE;
    EXCEPTION
        WHEN OTHERS THEN RAISE NOTICE 'DEU XABUM';
        RETURN FALSE;
    END; 
end;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION alterar(bigint, character varying(100), text, timestamp) returns boolean as
$$
begin
    BEGIN
        UPDATE anotacao set titulo = $2, texto = $3, data_hora_aviso = $4 where id = $1;
        return TRUE;
    EXCEPTION
        WHEN OTHERS THEN RAISE NOTICE 'DEU XABUM';
        RETURN FALSE;
    END; 
end;
$$ language 'plpgsql';


CREATE OR REPLACE FUNCTION adicionar( character varying(100), text, timestamp) returns boolean as
$$
begin
    BEGIN
        INSERT INTO anotacao (titulo, texto, data_hora_aviso) VALUES
        ($1, $2, $3);
        return TRUE;
    EXCEPTION
        WHEN OTHERS THEN RAISE NOTICE 'DEU XABUM';
        RETURN FALSE;
    END; 
end;
$$ language 'plpgsql';





