--
-- PostgreSQL database dump
--

-- Dumped from database version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)

-- Started on 2024-03-25 20:19:53 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE toquebrado;
--
-- TOC entry 3400 (class 1262 OID 57421)
-- Name: toquebrado; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE toquebrado WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


ALTER DATABASE toquebrado OWNER TO postgres;

\connect toquebrado

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 215 (class 1255 OID 57422)
-- Name: atendimentos_anteriores(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atendimentos_anteriores(character) RETURNS TABLE(data_hora_inicio timestamp without time zone, data_hora_fim timestamp without time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    return query select atendimento.data_hora_inicio, atendimento.data_hora_fim from paciente inner join atendimento on (paciente.id = atendimento.paciente_id) where paciente.cpf = $1;

END;
$_$;


ALTER FUNCTION public.atendimentos_anteriores(character) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 57476)
-- Name: faturamento_por_ano(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.faturamento_por_ano(integer) RETURNS money
    LANGUAGE plpgsql
    AS $_$
DECLARE
	somatorio money;
	registro record;
BEGIN
	somatorio := 0;
	for registro in select atendimento.id, valor_consulta+valor_por_hora_fisioterapeuta*transforma_para_horas(data_hora_fim-data_hora_inicio) as vl_consulta from atendimento where extract(year from atendimento.data_hora_inicio) = $1 and data_hora_fim is not null loop
		raise notice '%', registro.vl_consulta;
		somatorio := somatorio + registro.vl_consulta;
	end loop;
	return somatorio;	
END;
$_$;


ALTER FUNCTION public.faturamento_por_ano(integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 57480)
-- Name: faturamento_por_mes(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.faturamento_por_mes(mes integer, ano integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE
	somatorio money;
	registro record;
BEGIN
	somatorio := 0;
	for registro in select atendimento.id, valor_consulta+valor_por_hora_fisioterapeuta*transforma_para_horas(data_hora_fim-data_hora_inicio) as vl_consulta from atendimento where extract(year from atendimento.data_hora_inicio) = ano and extract(month from atendimento.data_hora_inicio) = mes AND data_hora_fim is not null loop
		raise notice '%', registro.vl_consulta;
		somatorio := somatorio + registro.vl_consulta;
	end loop;
	return somatorio;	
END;
$$;


ALTER FUNCTION public.faturamento_por_mes(mes integer, ano integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 57479)
-- Name: faturamento_por_semana(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.faturamento_por_semana(date) RETURNS money
    LANGUAGE plpgsql
    AS $_$
DECLARE
	somatorio money;
	registro record;
BEGIN
	somatorio := 0;
	for registro in select atendimento.id, valor_consulta+valor_por_hora_fisioterapeuta*transforma_para_horas(data_hora_fim-data_hora_inicio) as vl_consulta from atendimento where (cast(atendimento.data_hora_inicio as date) between $1 AND $1 + interval '7 days') and data_hora_fim is not null loop
		raise notice '%', registro.vl_consulta;
		somatorio := somatorio + registro.vl_consulta;
	end loop;
	return somatorio;	
END;
$_$;


ALTER FUNCTION public.faturamento_por_semana(date) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 57501)
-- Name: fisioterapeuta_mais_atendimentos(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fisioterapeuta_mais_atendimentos(data_inicio date, data_fim date) RETURNS TABLE(id integer, nome character varying, qtde bigint)
    LANGUAGE plpgsql
    AS $_$
begin
	return query 
select
	fisioterapeuta.id,
	fisioterapeuta.nome,
	count(*)
from
	fisioterapeuta
inner join atendimento 
on
	(fisioterapeuta.id = atendimento.fisioterapeuta_id)
where
	cast(atendimento.data_hora_inicio as date) between $1 and $2
group by
	fisioterapeuta.id
having
	count(*) = (
	select
		count(*)
	from
		fisioterapeuta
	inner join atendimento 
on
		(fisioterapeuta.id = atendimento.fisioterapeuta_id)
	where
		cast(atendimento.data_hora_inicio as date) between $1 and $2
	group by
		fisioterapeuta.id
	order by
		count(*) desc
	limit 1);
end;

$_$;


ALTER FUNCTION public.fisioterapeuta_mais_atendimentos(data_inicio date, data_fim date) OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 57424)
-- Name: formata_cep(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.formata_cep(character) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    resultado text;
BEGIN
    resultado := substring($1 from 1 for 2) || '.';
    resultado := resultado || substring($1 from 3 for 3) || '-';
    resultado := resultado || substring($1 from 6 for length($1));
    RETURN resultado;   
END;
$_$;


ALTER FUNCTION public.formata_cep(character) OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 57425)
-- Name: formata_telefone(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.formata_telefone(character) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    resultado text;
BEGIN
    resultado := '(' || substring($1 from 1 for 3) || ') ';
    resultado := resultado || substring ($1 from 4 for 7) || ' - ' || substring($1 from 8 for length($1));
    RETURN resultado;   
END;
$_$;


ALTER FUNCTION public.formata_telefone(character) OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 57426)
-- Name: mascara_cpf(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mascara_cpf(character) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
	cpf character(11);
BEGIN
	cpf := $1;
	return SUBSTRING(cpf from 1 for 3)||'.'||SUBSTRING(cpf from 4 for 3)||'.'||SUBSTRING(cpf from 7 for 3)||'-'||SUBSTRING(cpf from 10 for 2);
END;
$_$;


ALTER FUNCTION public.mascara_cpf(character) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 57497)
-- Name: melhor_fisioterapeuta(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.melhor_fisioterapeuta(data_inicio date, data_fim date) RETURNS TABLE(id integer, media double precision)
    LANGUAGE plpgsql
    AS $_$
begin
--	exemplo de chamada
--	select * from melhor_fisioterapeuta(cast('2024-03-01' as date), cast('2024-03-31' as date));

	return query 
select
	fisioterapeuta.id,
	cast(sum(nota) as real)/(
	select
		count(*)
	from
		atendimento as real) as media
from
	fisioterapeuta
inner join atendimento 
on
	(fisioterapeuta.id = atendimento.fisioterapeuta_id)
where
	cast(atendimento.data_hora_inicio as date) between $1 and $2
group by
	fisioterapeuta.id
having
	cast(sum(nota) as real)/(
	select
		count(*)
	from
		atendimento as real) = 
	(
	select
		cast(sum(nota) as real)/(
		select
			count(*)
		from
			atendimento as real) as media
	from
		fisioterapeuta
	inner join atendimento on
		(fisioterapeuta.id = atendimento.fisioterapeuta_id)
	where
		cast(atendimento.data_hora_inicio as date) between $1 and $2
	group by
		fisioterapeuta.id
	order by
		media desc
	limit 1);
end;
$_$;


ALTER FUNCTION public.melhor_fisioterapeuta(data_inicio date, data_fim date) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 57481)
-- Name: mes_mais_rentavel(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mes_mais_rentavel(ano integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	mes_mais_rentavel integer := 0;
	valor money;
	valor_mais_rentavel money := 0;
	i integer := 1;	
BEGIN
	while (i <= 12) LOOP
		valor := faturamento_por_mes(i, ano);
		if (valor >= valor_mais_rentavel) THEN
			mes_mais_rentavel := i;
			valor_mais_rentavel := valor;
		END IF;
		i := i + 1;
	END LOOP;
	return mes_mais_rentavel;
END;
$$;


ALTER FUNCTION public.mes_mais_rentavel(ano integer) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 57427)
-- Name: paciente_nro_atendimentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.paciente_nro_atendimentos() RETURNS TABLE(id integer, nome character varying, qtde bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	return query select paciente.id as id, paciente.nome as nome, count(*) as qtde from paciente inner join atendimento ON atendimento.paciente_id = paciente.id  group by paciente.id, paciente.nome 
	having count(*) = (select count(*) as qtde from paciente inner join atendimento ON atendimento.paciente_id = paciente.id group by paciente.id order by count(*) desc limit 1) order by paciente.id;
END;
$$;


ALTER FUNCTION public.paciente_nro_atendimentos() OWNER TO postgres;

--
-- TOC entry 220 (class 1255 OID 57428)
-- Name: transforma_para_horas(interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transforma_para_horas(interval) RETURNS real
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.transforma_para_horas(interval) OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 57429)
-- Name: valida_cpf(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.valida_cpf(character) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.valida_cpf(character) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 57430)
-- Name: atendimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.atendimento (
    id integer NOT NULL,
    fisioterapeuta_id integer,
    paciente_id integer,
    data_hora_inicio timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    data_hora_fim timestamp with time zone,
    observacao text,
    nota integer,
    valor_consulta money DEFAULT 100,
    valor_por_hora_fisioterapeuta money,
    CONSTRAINT atendimento_nota_check CHECK (((nota >= 0) AND (nota <= 5)))
);


ALTER TABLE public.atendimento OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 57438)
-- Name: atendimento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.atendimento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.atendimento_id_seq OWNER TO postgres;

--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 210
-- Name: atendimento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.atendimento_id_seq OWNED BY public.atendimento.id;


--
-- TOC entry 211 (class 1259 OID 57439)
-- Name: fisioterapeuta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fisioterapeuta (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    cpf character(11),
    crefito text NOT NULL,
    valor_por_hora money,
    CONSTRAINT valida_cpf CHECK ((public.valida_cpf(cpf) IS TRUE))
);


ALTER TABLE public.fisioterapeuta OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 57445)
-- Name: fisioterapeuta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fisioterapeuta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fisioterapeuta_id_seq OWNER TO postgres;

--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 212
-- Name: fisioterapeuta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fisioterapeuta_id_seq OWNED BY public.fisioterapeuta.id;


--
-- TOC entry 213 (class 1259 OID 57446)
-- Name: paciente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paciente (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    cpf character(11),
    telefone character(12),
    bairro text,
    rua text,
    complemento text,
    numero text,
    cep character(8),
    CONSTRAINT valida_cpf CHECK ((public.valida_cpf(cpf) IS TRUE))
);


ALTER TABLE public.paciente OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 57452)
-- Name: paciente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paciente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paciente_id_seq OWNER TO postgres;

--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 214
-- Name: paciente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paciente_id_seq OWNED BY public.paciente.id;


--
-- TOC entry 3231 (class 2604 OID 57453)
-- Name: atendimento id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento ALTER COLUMN id SET DEFAULT nextval('public.atendimento_id_seq'::regclass);


--
-- TOC entry 3234 (class 2604 OID 57454)
-- Name: fisioterapeuta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta ALTER COLUMN id SET DEFAULT nextval('public.fisioterapeuta_id_seq'::regclass);


--
-- TOC entry 3236 (class 2604 OID 57455)
-- Name: paciente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente ALTER COLUMN id SET DEFAULT nextval('public.paciente_id_seq'::regclass);


--
-- TOC entry 3389 (class 0 OID 57430)
-- Dependencies: 209
-- Data for Name: atendimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.atendimento VALUES (2, 1, 3, '2024-03-18 19:19:10.925309-03', '2024-03-18 21:19:10.925309-03', NULL, 2, 'R$ 100,00', 'R$ 100,00');
INSERT INTO public.atendimento VALUES (3, 1, 3, '2024-03-18 19:56:04.05183-03', '2024-03-18 20:25:23.734915-03', NULL, 1, 'R$ 100,00', 'R$ 100,00');
INSERT INTO public.atendimento VALUES (1, 1, 1, '2024-03-04 20:02:59.936992-03', '2024-03-04 22:02:59.936992-03', NULL, 1, 'R$ 100,00', 'R$ 100,00');
INSERT INTO public.atendimento VALUES (4, 4, 1, '2024-03-25 19:28:30.095495-03', '2024-03-25 21:33:14.41186-03', NULL, 4, 'R$ 150,00', 'R$ 150,00');


--
-- TOC entry 3391 (class 0 OID 57439)
-- Dependencies: 211
-- Data for Name: fisioterapeuta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fisioterapeuta VALUES (1, 'FLAVIO SANTOS', '17658586072', 'OIAUFJIOSDUFOISD', 'R$ 100,00');
INSERT INTO public.fisioterapeuta VALUES (4, 'JOHN MCLANE', '99453730050', 'USIFIOSDUFIOS', 'R$ 150,00');


--
-- TOC entry 3393 (class 0 OID 57446)
-- Dependencies: 213
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.paciente VALUES (1, 'IGOR AVILA PEREIRA', '26151303075', '053996688900', NULL, NULL, NULL, NULL, '96202188');
INSERT INTO public.paciente VALUES (3, 'KATIANE
', '17658586072', NULL, NULL, NULL, NULL, NULL, NULL);


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 210
-- Name: atendimento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.atendimento_id_seq', 6, true);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 212
-- Name: fisioterapeuta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fisioterapeuta_id_seq', 4, true);


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 214
-- Name: paciente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paciente_id_seq', 3, true);


--
-- TOC entry 3239 (class 2606 OID 57457)
-- Name: atendimento atendimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_pkey PRIMARY KEY (id);


--
-- TOC entry 3241 (class 2606 OID 57459)
-- Name: fisioterapeuta fisioterapeuta_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta
    ADD CONSTRAINT fisioterapeuta_cpf_key UNIQUE (cpf);


--
-- TOC entry 3243 (class 2606 OID 57461)
-- Name: fisioterapeuta fisioterapeuta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta
    ADD CONSTRAINT fisioterapeuta_pkey PRIMARY KEY (id);


--
-- TOC entry 3245 (class 2606 OID 57463)
-- Name: paciente paciente_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_cpf_key UNIQUE (cpf);


--
-- TOC entry 3247 (class 2606 OID 57465)
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id);


--
-- TOC entry 3248 (class 2606 OID 57466)
-- Name: atendimento atendimento_fisioterapeuta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_fisioterapeuta_id_fkey FOREIGN KEY (fisioterapeuta_id) REFERENCES public.fisioterapeuta(id);


--
-- TOC entry 3249 (class 2606 OID 57471)
-- Name: atendimento atendimento_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id);


-- Completed on 2024-03-25 20:19:53 -03

--
-- PostgreSQL database dump complete
--

