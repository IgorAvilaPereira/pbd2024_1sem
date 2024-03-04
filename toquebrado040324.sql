DROP DATABASE IF EXISTS toquebrado;
CREATE DATABASE toquebrado;

\c toquebrado;

CREATE TABLE fisioterapeuta (
    id serial primary key,
    nome character varying(100) not null,
--    cpf character(11) unique,
    cpf character(11) unique check (valida_cpf(cpf) is TRUE),
    crefito text not null,
    valor_por_hora money
);
INSERT INTO fisioterapeuta (nome, cpf, crefito, valor_por_hora) VALUES
('FLAVIO SANTOS', '17658586072', 'OIAUFJIOSDUFOISD', 100.0);

-- 11144477735
CREATE OR REPLACE FUNCTION valida_cpf(character (11)) RETURNS boolean AS
$$
DECLARE
    digito1 integer;
    digito1_real integer;
    digito2 integer;
    digito2_real integer;
    i integer;
    qtde integer;
    soma integer;
    multiplicador integer;
    resto integer;
BEGIN
   if (length($1) < 11) THEN
        RETURN FALSE;
   END IF; 
    
   i = 0; 
   while (i <= 9) loop
        if ((cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)||
            cast(i as text)) = $1) THEN
        RETURN FALSE;
        END IF;            
        i := i + 1;
   end loop;
    
    
    i := 1;
    soma := 0;
    multiplicador := 10;    
    while (i <= 9) LOOP
        BEGIN
            soma := soma + cast(substring($1 from i for 1) as integer)*multiplicador;
        EXCEPTION 
            WHEN OTHERS then RETURN FALSE;
        END;
            multiplicador := multiplicador - 1;
        i := i + 1;
    END LOOP;
    RAISE NOTICE 'soma1: %', soma;
    
    resto := soma % 11;
    
    if (resto < 2) then
        digito1 := 0;
    else
        digito1 := 11 - resto;
    end if;
    
    RAISE NOTICE '%', digito1;
    
    i := 1;
    soma := 0;
    multiplicador := 11;    
    while (i <= 10) LOOP
        BEGIN
            soma := soma + cast(substring($1 from i for 1) as integer)*multiplicador;
        EXCEPTION 
            WHEN OTHERS then RETURN FALSE;
        END;
        multiplicador := multiplicador - 1;
        i := i + 1;
    END LOOP;   
    RAISE NOTICE 'soma2: %', soma;
    
    resto := soma % 11; 
      if (resto < 2) then
        digito2 := 0;
    else
        digito2 := 11 - resto;
    end if;
    
    RAISE NOTICE '%', digito2;

    digito1_real := cast(substring($1 from 10 for 1) as integer);
    RAISE NOTICE '%', digito1_real;
    digito2_real := cast(substring($1 from 11 for 1) as integer);
    RAISE NOTICE '%', digito2_real;
    
    if (digito1 = digito1_real AND digito2 = digito2_real) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;    
END;
$$ LANGUAGE 'plpgsql';

-- select nome, mascaraCPF(cpf) FROM fisioterapeuta;
--
--myrow paciente%rowtype;
--
--myrow.id
--myrow.nome

CREATE TABLE paciente (
    id serial primary key,
    nome character varying(100) not null,
    cpf character(11) unique check (valida_cpf(cpf) is TRUE),
    telefone character(12),
    bairro text,
    rua text,
    complemento text,
    numero text,
    cep character(8)
);

INSERT INTO paciente (nome, cpf, telefone) VALUES
('IGOR AVILA PEREIRA', '26151303075', '053996688900');

INSERT INTO paciente (nome, cpf, telefone) VALUES
('joao', '26151303073', '053996682900');

CREATE OR REPLACE FUNCTION formata_telefone(character (12)) RETURNS text AS
$$
DECLARE
    resultado text;
BEGIN
    resultado := '(' || substring($1 from 1 for 3) || ') ';
    resultado := resultado || substring ($1 from 4 for 7) || '-' || substring($1 from 8 for length($1));
    RETURN resultado;   
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION formata_cep(character (8)) RETURNS text AS
$$
DECLARE
    resultado text;
BEGIN
    resultado := substring($1 from 1 for 2) || '.';
    resultado := resultado || substring($1 from 3 for 3) || '-';
    resultado := resultado || substring($1 from 6 for length($1));
    RETURN resultado;   
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION atendimentos_anteriores(character (11)) RETURNS TABLE (data_hora_inicio timestamp, data_hora_fim timestamp) AS
$$
BEGIN
    return query select atendimento.data_hora_inicio, atendimento.data_hora_fim from paciente inner join atendimento on (paciente.id = atendimento.paciente_id) where paciente.cpf = $1;

END;
$$ LANGUAGE 'plpgsql';



CREATE TABLE atendimento (
    id serial primary key,
    fisioterapeuta_id integer references fisioterapeuta (id),
    paciente_id integer references paciente (id),
    data_hora_inicio timestamp default current_timestamp,
    data_hora_fim timestamp,
    observacao text,
    nota integer check (nota >= 0 and nota <= 5),
    valor_consulta money default 100,
    valor_por_hora_fisioterapeuta money
);

INSERT INTO atendimento (fisioterapeuta_id, paciente_id, data_hora_fim, nota, valor_por_hora_fisioterapeuta) VALUES
(1, 1, CURRENT_TIMESTAMP + INTERVAL '2 HOURS', 5, 100);

