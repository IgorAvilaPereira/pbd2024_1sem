
 CREATE OR REPLACE FUNCTION mascara_cpf (character(11)) RETURNS CHARACTER(14) AS
 $$
 DECLARE
 	cpf character(11);
 BEGIN
 	cpf := $1;
 	return SUBSTRING(cpf from 1 for 3)||'.'||SUBSTRING(cpf from 4 for 3)||'.'||SUBSTRING(cpf from 7 for 3)||'-'||SUBSTRING(cpf from 10 for 2);
 END;
 $$ LANGUAGE 'plpgsql';
 
 
DROP FUNCTION paciente_nro_atendimentos();

CREATE OR REPLACE FUNCTION paciente_nro_atendimentos() RETURNS TABLE(id integer, nome character varying(100), qtde bigint) AS
$$
BEGIN
	return query select paciente.id as id, paciente.nome as nome, count(*) as qtde from paciente inner join atendimento ON atendimento.paciente_id = paciente.id  group by paciente.id, paciente.nome 
	having count(*) = (select count(*) as qtde from paciente inner join atendimento ON atendimento.paciente_id = paciente.id group by paciente.id order by count(*) desc limit 1) order by paciente.id;
END;
$$ LANGUAGE 'plpgsql';

select * from paciente_nro_atendimentos();

-- select * from atendimento;

DROP FUNCTION transforma_para_horas;

CREATE OR REPLACE function transforma_para_horas(interval) returns real as
$$
DECLARE
	horas integer;
	minutos REAL;
BEGIN
-- 	raise notice '%', $1;
	horas := EXTRACT(HOUR FROM $1);
	minutos := CASt(EXTRACT(MINUTE from $1) AS REAL);
	minutos := minutos/60.0;
	return horas + minutos;
-- 	return 0.0;
END;
$$ LANGUAGE 'plpgsql';



CREATE OR REPLACE function faturamento_por_mes(integer) returns money as
$$
DECLARE
	somatorio money;
	registro record;
BEGIN
	somatorio := 0;
	for registro in select atendimento.id, valor_consulta+valor_por_hora_fisioterapeuta*transforma_para_horas(data_hora_fim-data_hora_inicio) as vl_consulta from atendimento where extract(month from atendimento.data_hora_inicio) = $1 AND data_hora_fim is not null loop
		raise notice '%', registro.vl_consulta;
		somatorio := somatorio + registro.vl_consulta;
	end loop;
	return somatorio;	
END;
$$ LANGUAGE 'plpgsql';

select faturamento_por_mes(3);
