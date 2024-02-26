DROP DATABASE IF EXISTS toquebrado;
CREATE DATABASE toquebrado;

\c toquebrado;

CREATE TABLE fisioterapeuta (
    id serial primary key,
    nome character varying(100) not null,
    cpf character(11) unique,
--  cpf character(11) unique check (validaCPF(cpf) is TRUE),
    crefito text not null,
    valor_por_hora money
);

-- select nome, mascaraCPF(cpf) FROM fisioterapeuta;

CREATE TABLE paciente (
    id serial primary key,
    nome character varying(100) not null,
    cpf character(11) unique,
    telefone character(12),
    bairro text,
    rua text,
    complemento text,
    numero text,
    cep character(8)
);

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

