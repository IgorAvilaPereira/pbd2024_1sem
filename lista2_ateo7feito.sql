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

