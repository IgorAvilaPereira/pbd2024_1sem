DROP DATABASE IF EXISTS locadora110522;


CREATE DATABASE locadora110522;

\c locadora110522;

DROP TABLE IF EXISTS  LOCACAO;
DROP TABLE IF EXISTS  RESERVA;
DROP TABLE IF EXISTS  DVD;
DROP TABLE IF EXISTS  STATUS;
DROP TABLE IF EXISTS  FILME;
DROP TABLE IF EXISTS  CATEGORIA;
DROP TABLE IF EXISTS  CLIENTE;


CREATE TABLE  CLIENTE
   (    CODCLIENTE serial, 
    	NOME_CLIENTE VARCHAR(30) NOT NULL, 
    	ENDERECO VARCHAR(50) NOT NULL, 
    	TELEFONE VARCHAR(12) NOT NULL, 
    	DATA_NASC DATE NOT NULL, 
    	CPF VARCHAR(11) NOT NULL, 
     	CONSTRAINT PK_CLIENTE PRIMARY KEY (CODCLIENTE),
	CONSTRAINT CPF_UNIQUE UNIQUE (CPF)
   );

CREATE TABLE  CATEGORIA 
   (    CODCATEGORIA serial, 
    	NOME_CATEGORIA VARCHAR(100) NOT NULL, 
     	CONSTRAINT CATEGORIA_PK PRIMARY KEY (CODCATEGORIA), 
     	CONSTRAINT CHECK_NOME_CATEGORIA CHECK ( NOME_CATEGORIA in ('drama','terror','ação','aventura','comédia'))
   );

CREATE TABLE  FILME 
   (    CODFILME serial, 
    	CODCATEGORIA int, 
    	NOME_FILME VARCHAR(100) NOT NULL, 
    	DIARIA numeric(10,2) NOT NULL, 
     	CONSTRAINT PK_FILME PRIMARY KEY (CODFILME), 
     	CONSTRAINT FK_FIL_CAT FOREIGN KEY (CODCATEGORIA)
      		REFERENCES  CATEGORIA (CODCATEGORIA)
		ON DELETE NO ACTION ON UPDATE CASCADE
   );

CREATE TABLE  STATUS 
   (    CODSTATUS SERIAL, 
    	NOME_STATUS VARCHAR(30) NOT NULL, 
     	CONSTRAINT PK_STATUS PRIMARY KEY (CODSTATUS),
     	CONSTRAINT CHECK_NOME_STATUS CHECK ( NOME_STATUS in ('reservado','disponível','indisponível','locado'))

   );

CREATE TABLE  DVD 
   (    CODDVD SERIAL, 
    	CODFILME int NOT NULL, 
    	CODSTATUS int NOT NULL, 
     	CONSTRAINT PK_DVD PRIMARY KEY (CODDVD), 
     	CONSTRAINT FK_DVD_FIL FOREIGN KEY (CODFILME)
      		REFERENCES  FILME (CODFILME) ON UPDATE CASCADE, 
     	CONSTRAINT FK_DVD_STA FOREIGN KEY (CODSTATUS)
      		REFERENCES  STATUS (CODSTATUS) ON UPDATE CASCADE
   );

CREATE TABLE  LOCACAO 
   (    CODLOCACAO SERIAL, 
    	CODDVD int NOT NULL, 
    	CODCLIENTE int NOT NULL, 
    	DATA_LOCACAO DATE NOT NULL DEFAULT NOW(), 
    	DATA_DEVOLUCAO DATE, 
     	CONSTRAINT PK_LOCACAO PRIMARY KEY (CODLOCACAO), 
     	CONSTRAINT FK_LOC_DVD FOREIGN KEY (CODDVD)
      		REFERENCES  DVD (CODDVD) ON DELETE SET NULL ON UPDATE CASCADE, 
     	CONSTRAINT FK_LOC_CLI FOREIGN KEY (CODCLIENTE)
      		REFERENCES  CLIENTE (CODCLIENTE) ON DELETE SET NULL ON UPDATE CASCADE
   );

CREATE TABLE  RESERVA 
   (    CODRESERVA SERIAL, 
    	CODDVD int NOT NULL, 
    	CODCLIENTE int NOT NULL, 
 	DATA_RESERVA DATE DEFAULT NOW(), 
    	DATA_VALIDADE DATE NOT NULL, 
     	CONSTRAINT PK_RESERVA PRIMARY KEY (CODRESERVA), 
     	CONSTRAINT FK_RES_DVD FOREIGN KEY (CODDVD)
      		REFERENCES  DVD (CODDVD) ON DELETE SET NULL ON UPDATE CASCADE, 
     	CONSTRAINT FK_RES_CLI FOREIGN KEY (CODCLIENTE)
      		REFERENCES  CLIENTE (CODCLIENTE) ON DELETE SET NULL ON UPDATE CASCADE
   );

--inserts

INSERT INTO STATUS (NOME_STATUS) VALUES ('reservado');
INSERT INTO STATUS (NOME_STATUS) VALUES ('disponível');    
INSERT INTO STATUS (NOME_STATUS) VALUES ('locado');
INSERT INTO STATUS (NOME_STATUS) VALUES ('indisponível');
    
INSERT INTO CATEGORIA (NOME_CATEGORIA) VALUES ('comédia');    
INSERT INTO CATEGORIA (NOME_CATEGORIA) VALUES ( 'aventura');
INSERT INTO CATEGORIA (NOME_CATEGORIA) VALUES ( 'terror');    
INSERT INTO CATEGORIA (NOME_CATEGORIA) VALUES ( 'ação');
INSERT INTO CATEGORIA (NOME_CATEGORIA) VALUES ( 'drama');

INSERT INTO CLIENTE (NOME_CLIENTE,ENDERECO,TELEFONE,DATA_NASC,CPF ) VALUES ('João Paulo', 'rua XV de novembro, n:18', '88119922','05-02-1990','09328457398');
INSERT INTO CLIENTE (NOME_CLIENTE,ENDERECO,TELEFONE,DATA_NASC,CPF ) VALUES ('Maria', 'rua XV de novembro, n:20', '88225422','07-01-1991','93573923168');
INSERT INTO CLIENTE (NOME_CLIENTE,ENDERECO,TELEFONE,DATA_NASC,CPF ) VALUES ('Joana', 'rua XV de novembro, n:10', '99778122','09-07-1980','71398987234');
INSERT INTO CLIENTE (NOME_CLIENTE,ENDERECO,TELEFONE,DATA_NASC,CPF ) VALUES ('Jeferson', 'rua XV de novembro, n:118', '84549922','09-12-1982','02128443298');
INSERT INTO CLIENTE (NOME_CLIENTE,ENDERECO,TELEFONE,DATA_NASC,CPF ) VALUES ('Paula', 'rua XV de novembro, n:128', '82324232','11-04-1970','57398093284');

INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (1,'Entrando numa fria', 1.50);    
INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (2,'O Hobbit', 3.00);    
INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (3,'Sobrenatural 2', 4.50);    
INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (5,'Um sonho de liberdade', 1.50);
INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (2,'Thor 2', 4.50);
INSERT INTO FILME (CODCATEGORIA, NOME_FILME,DIARIA ) VALUES (4,'Velozes e Furiosos', 1.50);

INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (1,1);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (2,2);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (2,3);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (3,2);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (4,2);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (4,3);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (5,1);
INSERT INTO DVD (CODFILME,CODSTATUS) VALUES (6,3);

INSERT INTO RESERVA (CODDVD,CODCLIENTE,DATA_RESERVA,DATA_VALIDADE) VALUES(1,2,current_date,(current_date+4)); 
INSERT INTO RESERVA (CODDVD,CODCLIENTE,DATA_RESERVA,DATA_VALIDADE) VALUES(5,1,current_date,(current_date+4)); 
INSERT INTO RESERVA (CODDVD,CODCLIENTE,DATA_RESERVA,DATA_VALIDADE) VALUES(6,2,(current_date-30),(current_date-26)); 
INSERT INTO RESERVA (CODDVD,CODCLIENTE,DATA_RESERVA,DATA_VALIDADE) VALUES(6,3,(current_date-4),(current_date-1)); 
INSERT INTO RESERVA (CODDVD,CODCLIENTE,DATA_RESERVA,DATA_VALIDADE) VALUES(6,1,(current_date-20),(current_date-16)); 

INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(1,1,(current_date-30),(current_date-28));
INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(2,3,(current_date-25),(current_date-23));
INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(1,1,(current_date-1),current_date);
INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(3,2,(current_date-1),null); 
INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(6,2,current_date,null); 
INSERT INTO LOCACAO (CODDVD,CODCLIENTE,DATA_LOCACAO, DATA_DEVOLUCAO) VALUES(8,2,current_date,null);



--create or replace procedure delete_cliente(cliente_idAux integer) as 
--$$
--begin 
--	delete from reserva where codcliente = cliente_idAux;
--	delete from locacao where codcliente = cliente_idAux;
--	delete from cliente where codcliente = cliente_idAux;
--end;
--$$ language 'plpgsql';
--
--call delete_cliente(3);

--select * from cliente;


create or replace function insert_cliente(nome_clienteAux varchar(30), enderecoAux varchar(50), telefoneAux varchar(12), data_nascAux date, cpfAux varchar(11)) returns boolean as 
$$
begin	
	begin 
		raise notice '%,%,%,%,%', nome_clienteAux, enderecoAux, telefoneAux, data_nascAux, cpfAux;
		INSERT INTO cliente (nome_cliente, endereco, telefone, data_nasc, cpf) VALUES(nome_clienteAux, enderecoAux, telefoneAux, data_nascAux, cpfAux);
			raise notice 'ok';
			return TRUE;
	exception
		when others then raise notice 'DEU RUIM';
		return false;
	end;
end;
$$
language 'plpgsql';

select insert_cliente('IGOR PEREIRA', 'ALFREDO HUCH', '539999999999', cast('1987-01-20' as date), '17658586072');

select * from cliente;


drop function qtdeDVDsPorFilme;

create or replace function qtdeDVDsPorFilme(x integer) 
returns table (nome_categoriaAux varchar(100), codFilmeAux integer, nome_filmeAux varchar(100), qtde bigint) as $$
begin
	return query select categoria.nome_categoria, filme.codfilme, filme.nome_filme, count(*) as qtde 
	from filme inner join dvd on (filme.codfilme = dvd.codfilme) inner join 
	categoria on (categoria.codcategoria = filme.codcategoria) where filme.codcategoria  = x group by categoria.nome_categoria, filme.codfilme, filme.nome_filme order by filme.codfilme;
end;
$$ language 'plpgsql';

select * from qtdeDvdsPorFilme(2);

create or replace function filme_mais_locado() returns table (nome varchar(100), qtde bigint)  as
$$
begin	
	return query select filme.nome_filme, count(locacao.codlocacao) as qtde from filme natural join dvd natural join locacao
group by filme.codfilme,filme.nome_filme having count(*) = 
(select count(*) from filme natural join dvd natural join locacao
group by filme.codfilme order by count(*) desc limit 1);
end;
$$ language 'plpgsql';

select * from filme_mais_locado();

create or replace function qtde_dvds_locados(nomeAux varchar(100)) returns table 
(id integer, nome varchar(100), qtde bigint) as
$$
begin
	return query select cliente.codcliente, cliente.nome_cliente, count(*) as qtde_locacao
from cliente natural join locacao 
where upper(cliente.nome_cliente) = upper(nomeAux) group by cliente.codcliente, 
cliente.nome_cliente;
end;
$$ language 'plpgsql';

select * from qtde_dvds_locados('Maria');

create or replace function adiciona_locacao(nomeFilmeAux varchar(100), nomeClienteAux varchar(30))
returns boolean as 
$$
declare 
	codFilmeAux integer;
	codClienteAux integer;
	codDvdAux integer;
begin
	select codcliente from cliente where upper(nome_cliente) = upper(trim(nomeClienteAux)) into codClienteAux;
	select codFilme from filme where upper(nome_filme) = upper(trim(nomeFilmeAux)) into codFilmeAux;
	select codDvd from dvd where codfilme = codFilmeAux and codstatus = 2 into codDvdAux;
	if (codDvdAux != 0 and codClienteAux != 0) then	
		insert into locacao (coddvd, codcliente) values (codDvdAux, codClienteAux);
		return true;
	else
		return false;
	end if;
end;
$$ language 'plpgsql';


select * FROM adiciona_locacao('Entrando numa fria','Maria');
select * from locacao;


create or replace function adiciona_locacao_excecao(nomeFilmeAux varchar(100), nomeClienteAux varchar(30))
returns boolean as 
$$
declare 
	codFilmeAux integer;
	codClienteAux integer;
	codDvdAux integer;
begin
	select codcliente from cliente where upper(nome_cliente) = upper(trim(nomeClienteAux)) into codClienteAux;
	if not found then
		raise exception 'cliente invalido';
--	return false;
	end if;
	select codFilme from filme where upper(nome_filme) = upper(trim(nomeFilmeAux)) into codFilmeAux;
	if not found then
		raise exception 'filme invalido';
--	return false;
	end if;
	select codDvd from dvd where codfilme = codFilmeAux and codstatus = 2 into codDvdAux;
	if not found then
		raise exception 'dvd invalido';
--		return false;
	end if;
	if (codDvdAux != 0 and codClienteAux != 0) then	
		insert into locacao (coddvd, codcliente) values (codDvdAux, codClienteAux);
		return true;
	else
		return false;
	end if;
end;
$$ language 'plpgsql';

select * FROM adiciona_locacao_excecao('Entrando numa fria','Maria');
select * from locacao;

-- 8) 
CREATE OR REPLACE FUNCTION troca_status(bigint) RETURNS boolean as
$$
DECLARE
    registro record;
    data_reservaAux date;
    data_validadeAux date;
begin
    select into registro codreserva, nome_status, data_reserva, data_validade from dvd natural join status natural join reserva where coddvd = $1;
	if not found then
	    raise exception 'dvd inexistente';
	    return false;
	else
	    data_reservaAux := registro.data_reserva;
	    data_validadeAux := registro.data_validade;
	    if data_validadeAux < CURRENT_DATE then
	        UPDATE dvd set codstatus = 2 where coddvd = 1;
	        DELETE FROM reserva where codreserva = registro.codreserva;
	    end if;
	end if;
	return true;

end;
$$ language 'plpgsql';


-- 9) jump

-- 10)  
CREATE OR REPLACE function muda_status_locacao(bigint) returns boolean as 
$$
declare
    registro record;
begin
--     obtendo a ultima locacao deste dvd
     select into registro * from locacao where coddvd = $1 order by data_locacao desc limit 1 ;
     if not found then
	    raise exception 'dvd não foi locado';
        return false;
     else
         if registro.data_devolucao is null or registro.data_devolucao <= CURRENT_DATE then
        --     atualizacao a data da devolucao
             update locacao set data_devolucao = CURRENT_DATE where codlocacao = registro.codlocacao;
        --     e settando novamente o status daquele dvd como disponivel
             update dvd set codstatus = 2 where coddvd = $1;
         else
            raise exception 'dvd com data de devolucao vencida';
            return false;
         end if;
     end if;
     return true;
end;
$$ language 'plpgsql';


--
--create or replace function teste2(x int,y int) RETURNS integer[] as
--$$
--begin
--    return array[x+x, y+y];
--end;
--$$ language 'plpgsql';
--
--
--CREATE OR REPLACE function soma(x anyelement, y anyelement) returns anyelement as
--$$
--begin
--    return x+y;
--end;
--$$ language 'plpgsql';
--
--
--CREATE OR REPLACE function oi() returns cliente.telefone%TYPE  as
--$$
--declare
--    cliente cliente%ROWTYPE;    
--    telefoneAux cliente.telefone%TYPE := '539999999999';
--begin
--    return telefoneAux;
--end;
--$$ language 'plpgsql';



