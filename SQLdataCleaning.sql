# ANÁLISE DE RISCO - DATASET EXPLORATION

ALTER TABLE `analise_risco`.`ids` 
RENAME TO  `analise_risco`.`id`;


# 1) Dados dos mutuários

SELECT *
FROM analise_risco.dados_mutuarios
LIMIT 10 ;


# podemos notar 5 colunas distintas: 
# 			1. person_id: identificação da pessoa que contraiu o empréstimo
# 			2. person_age: idade da pessoa
# 			3. person_income: qual é a renda anual da pessoa
# 			4. person_home_ownership: qual é a condição da casa que a pessoa mora
# 			5. person_emp_length: tempo que a pessoa trabalhou em anos

# 2) Empréstimos

SELECT *
FROM analise_risco.emprestimos
LIMIT 10 ;

# podemos notar 7 colunas distintas: 
# 			1. loan_id: ID da solicitação de empréstimo de cada solicitante (único)
# 			2. loan_intent: Motivação do empréstimo, podendo ser: Pessoal (Personal), Educativo (Education), Médico (Medical), Empreendimento (Venture), Melhora do lar (Homeimprovement), Pagamento de débitos (Debtconsolidation)
# 			3. loan_grade: Pontuação de empréstimos, por nível variando de A a G
# 			4. loan_amnt: Valor total do empréstimo solicitado
# 			5. loan_int_rate: Taxa de juros
# 			6. loan_status: Possibilidade de inadimplência
# 			7. loan_percent_income: Renda percentual entre o valor total do empréstimo e o salário anual


# 3) Histórico do Banco

SELECT *
FROM analise_risco.historicos_banco
LIMIT 10 ;

# podemos notar 3 colunas distintas: 
# 			1. cb_id: ID do histórico de cada solicitante
# 			2. cb_person_default_on_file: Indica se a pessoa já foi inadimplente: sim (Y,YES) e não (N,NO)
# 			3. cb_person_cred_hist_length: Tempo - em anos - desde a primeira solicitação de crédito ou aquisição de um cartão de crédito

# 4) Identificação Clientes, Empréstimos e Históricos

SELECT *
FROM analise_risco.id
LIMIT 10 ;

# podemos notar 3 colunas distintas: 
# 			1. person_id: ID da pessoa solicitante
# 			2. person_age: ID da solicitação de empréstico de cada solicitante
# 			3. person_income: ID do histórico de cada solicitante


# SEARCHING FOR INCONSISTENCIES
# Podemos começar investigando as dimensões de cada tabela.

SELECT
	(SELECT COUNT(*) FROM analise_risco.dados_mutuarios) as Dados_MutuariosCount,
    (SELECT COUNT(*) FROM analise_risco.emprestimos) as EmprestimosCount,
    (SELECT COUNT(*) FROM analise_risco.historicos_banco) as Historico_BancoCount,
    (SELECT COUNT(*) FROM analise_risco.id) as IDCount;


# # Dados_MutuariosCount, EmprestimosCount, Historico_BancoCount, IDCount
# 	'34489', '34489', '34489', '34489'

# Podemos ir além e investigar se há valores nulos em certas colunas mais importantes

SELECT COUNT(*), COUNT(person_id), COUNT(person_age), COUNT(person_income), COUNT(person_home_ownership), COUNT(person_emp_length) 
FROM analise_risco.dados_mutuarios;

# Procurar por duplicatas nas colunas id

SELECT person_id, COUNT(*)
FROM analise_risco.dados_mutuarios
GROUP BY person_id
HAVING COUNT(*) > 1; # 4 valores em branco

SELECT *
FROM analise_risco.dados_mutuarios
WHERE person_id = "" OR person_id IS NULL; 

#################################### 

SELECT loan_id, COUNT(*)
FROM analise_risco.emprestimos
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT *
FROM analise_risco.emprestimos
WHERE loan_id = "" OR loan_id IS NULL; 

SELECT cb_id, COUNT(*)
FROM analise_risco.historicos_banco
GROUP BY cb_id
HAVING COUNT(*) > 1;

SELECT *
FROM analise_risco.historicos_banco
WHERE cb_id = "" OR cb_id IS NULL; 

SELECT person_id, COUNT(*)
FROM analise_risco.id
GROUP BY person_id
HAVING COUNT(*) > 1;

SELECT loan_id, COUNT(*)
FROM analise_risco.id
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT cb_id, COUNT(*)
FROM analise_risco.id
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT *
FROM analise_risco.id
WHERE person_id = "" OR person_id IS NULL OR loan_id = "" OR loan_id IS NULL OR cb_id = "" OR cb_id IS NULL; 

####################################

# Podemos observar que temos 4 rows na Table dados_mutuarios e 4 rows na Table id que estão em branco, sendo impossível afirmar com clareza a quem pertencem
# Nesse caso, podemos descartar essas rows, de ambas as tabelas

DELETE 
FROM dados_mutuarios
WHERE person_id = "" OR person_id IS NULL;

DELETE 
FROM id
WHERE person_id = "" OR person_id IS NULL;

DELETE
FROM dados_mutuarios
WHERE person_age = "" OR person_age IS NULL OR person_age = 0;

####################################


SELECT DISTINCT COUNT(person_id)
FROM analise_risco.dados_mutuarios;

SELECT DISTINCT COUNT(person_id)
FROM analise_risco.id;


# Já observamos que já uma série de inconsistências nessa table
# Aggregate functions como COUNT(column) ignoram NULL values, sendo uma exceção COUNT(*)
# # COUNT(*), COUNT(person_id), COUNT(person_age), COUNT(person_income), COUNT(person_home_ownership), COUNT(person_emp_length)
# '34489', '34489', '34168', '34153', '34489', '33235'
# Mais de 1000 registros somente na coluna person_emp_length
# Outras colunas problemáticas são: person_age e person_income

SELECT * 
FROM analise_risco.dados_mutuarios
WHERE person_emp_length IS NULL;


# Podemos obter um tabela sem valores NULL usando a seguinte query:
# COUNT(*), COUNT(person_id), COUNT(person_age), COUNT(person_income), COUNT(person_home_ownership), COUNT(person_emp_length)
# '28437', '28437', '28437', '28437', '28437', '28437'

SELECT COUNT(*), COUNT(person_id), COUNT(person_age), COUNT(person_income), COUNT(person_home_ownership), COUNT(person_emp_length)
FROM analise_risco.dados_mutuarios
WHERE person_emp_length AND person_age AND person_income IS NOT NULL;

SELECT *
FROM analise_risco.dados_mutuarios
WHERE person_emp_length AND person_age AND person_income IS NOT NULL;


-- Podemos exportar a table parcialmente tratada como csv para melhor análise usando outra linguagem de programação:

CREATE TABLE joined_analise_risco as

SELECT 
	dm.person_age,
    dm.person_income,
    dm.person_home_ownership,
    dm.person_emp_length,
	emp.loan_intent,
	emp.loan_grade,
	emp.loan_amnt,
	emp.loan_int_rate,
	emp.loan_status,
	emp.loan_percent_income,
	hb.cb_person_default_on_file,
	hb.cb_person_cred_hist_length
FROM id
INNER JOIN dados_mutuarios as dm 
	ON dm.person_id = id.person_id 
INNER JOIN emprestimos as emp 
	ON emp.loan_id = id.loan_id 
INNER JOIN historicos_banco as hb 
	ON hb.cb_id = id.cb_id
#WHERE person_emp_length AND person_age AND person_income IS NOT NULL;