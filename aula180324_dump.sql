--
-- PostgreSQL database dump
--

-- Dumped from database version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)

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
-- Name: faturamento_por_mes(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.faturamento_por_mes(integer) RETURNS money
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.faturamento_por_mes(integer) OWNER TO postgres;

--
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
-- Name: atendimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.atendimento (
    id integer NOT NULL,
    fisioterapeuta_id integer,
    paciente_id integer,
    data_hora_inicio timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    data_hora_fim timestamp without time zone,
    observacao text,
    nota integer,
    valor_consulta money DEFAULT 100,
    valor_por_hora_fisioterapeuta money,
    CONSTRAINT atendimento_nota_check CHECK (((nota >= 0) AND (nota <= 5)))
);


ALTER TABLE public.atendimento OWNER TO postgres;

--
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
-- Name: atendimento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.atendimento_id_seq OWNED BY public.atendimento.id;


--
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
-- Name: fisioterapeuta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fisioterapeuta_id_seq OWNED BY public.fisioterapeuta.id;


--
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
-- Name: paciente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paciente_id_seq OWNED BY public.paciente.id;


--
-- Name: atendimento id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento ALTER COLUMN id SET DEFAULT nextval('public.atendimento_id_seq'::regclass);


--
-- Name: fisioterapeuta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta ALTER COLUMN id SET DEFAULT nextval('public.fisioterapeuta_id_seq'::regclass);


--
-- Name: paciente id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente ALTER COLUMN id SET DEFAULT nextval('public.paciente_id_seq'::regclass);


--
-- Data for Name: atendimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.atendimento VALUES (1, 1, 1, '2024-03-04 20:02:59.936992', '2024-03-04 22:02:59.936992', NULL, 5, 'R$ 100,00', 'R$ 100,00');
INSERT INTO public.atendimento VALUES (2, 1, 3, '2024-03-18 19:19:10.925309', '2024-03-18 21:19:10.925309', NULL, NULL, 'R$ 100,00', 'R$ 100,00');
INSERT INTO public.atendimento VALUES (3, 1, 3, '2024-03-18 19:56:04.05183', '2024-03-18 20:25:23.734915', NULL, NULL, 'R$ 100,00', 'R$ 100,00');


--
-- Data for Name: fisioterapeuta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fisioterapeuta VALUES (1, 'FLAVIO SANTOS', '17658586072', 'OIAUFJIOSDUFOISD', 'R$ 100,00');


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.paciente VALUES (1, 'IGOR AVILA PEREIRA', '26151303075', '053996688900', NULL, NULL, NULL, NULL, '96202188');
INSERT INTO public.paciente VALUES (3, 'KATIANE
', '17658586072', NULL, NULL, NULL, NULL, NULL, NULL);


--
-- Name: atendimento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.atendimento_id_seq', 3, true);


--
-- Name: fisioterapeuta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fisioterapeuta_id_seq', 2, true);


--
-- Name: paciente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paciente_id_seq', 3, true);


--
-- Name: atendimento atendimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_pkey PRIMARY KEY (id);


--
-- Name: fisioterapeuta fisioterapeuta_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta
    ADD CONSTRAINT fisioterapeuta_cpf_key UNIQUE (cpf);


--
-- Name: fisioterapeuta fisioterapeuta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fisioterapeuta
    ADD CONSTRAINT fisioterapeuta_pkey PRIMARY KEY (id);


--
-- Name: paciente paciente_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_cpf_key UNIQUE (cpf);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id);


--
-- Name: atendimento atendimento_fisioterapeuta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_fisioterapeuta_id_fkey FOREIGN KEY (fisioterapeuta_id) REFERENCES public.fisioterapeuta(id);


--
-- Name: atendimento atendimento_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atendimento
    ADD CONSTRAINT atendimento_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id);


--
-- PostgreSQL database dump complete
--

