DROP DATABASE IF EXISTS doces_mary;

CREATE DATABASE doces_mary;

\c doces_mary;

CREATE TABLE cliente (
    id serial primary key,
    nome text not null
);
INSERT INTO cliente (nome) VALUES
('VINICIUS FRITZEN');

CREATE TABLE pedido (
    id serial primary key,
    data_hora timestamp default current_timestamp,
    cliente_id integer references cliente (id)
);
INSERT INTO pedido (cliente_id) values
(1);

CREATE TABLE doce (
    id serial primary key,
    nome character varying(100) not null,
    preco money check (cast(preco as numeric(8,2)) >= 0),
    estoque integer check (estoque >= 0)
);
INSERT INTO doce (nome, preco, estoque) VALUES
('BOMBOM', 1.99, 100);

CREATE TABLE item (
    pedido_id integer references pedido (id),
    doce_id integer references doce (id),
    qtde integer check (qtde >= 0),
    preco_unitario_atual money check (cast(preco_unitario_atual as numeric(8,2)) >= 0),
    primary key (pedido_id, doce_id)
);

CREATE OR REPLACE FUNCTION testa_estoque() RETURNS TRIGGER AS
$$
DECLARE
    qtde_estoque integer;
BEGIN
    SELECT estoque INTO qtde_estoque FROM doce where id = NEW.doce_id;
    
    IF TG_OP = 'INSERT' THEN
        IF (NEW.qtde <= qtde_estoque) THEN
            UPDATE doce SET estoque = estoque - NEW.qtde where id = NEW.doce_id;
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Deu xabum no INSERT!';
   ELSE
        IF TG_OP = 'UPDATE' THEN
            IF (qtde_estoque + OLD.qtde >= NEW.qtde) THEN
               UPDATE doce SET estoque = estoque + OLD.qtde - NEW.qtde where id = NEW.doce_id;
                RETURN NEW;                
            ELSE
                RAISE EXCEPTION 'Deu xabum no UPDATE!';
            END IF;
        ELSE 
            IF TG_OP = 'DELETE' THEN
                  UPDATE doce SET estoque = estoque + OLD.qtde where id = OLD.doce_id;
                RETURN OLD;   
            END IF;
        END IF;
   END IF;
   
   
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER testa_estoque_trigger1 BEFORE INSERT OR UPDATE on item 
FOR EACH ROW EXECUTE PROCEDURE testa_estoque();

CREATE TRIGGER testa_estoque_trigger2 BEFORE DELETE on item 
FOR EACH ROW EXECUTE PROCEDURE testa_estoque();

