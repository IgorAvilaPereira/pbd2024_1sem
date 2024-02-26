Fisioterapeuta
- id (pk)
- nome 
- cpf unique
- crefito
- valor_por_hora default 50

atendimento
- id (pk)
- fisio_id integer  (fk)
- paciente_id integer  (fk)
-- ex: 2024-02-19 20:00:00 - 2024-02-19 22:00:00 
- data_hora_inicio timestamp default current_timestamp
- data_hora_fim timestamp 
- observacao text
- nota integer default not null (nota >= 0 and nota <= 5)
- valor_consulta money default 100
- valor_por_hora_fisioterapeuta_atual money  


paciente
- id (pk)
- nome
- cpf
- telefone
- bairro
- rua
- complemento
- numero
- cep



