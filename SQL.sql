-- ===========================
-- SCRIPT DE OTIMIZAÇÃO SQL - PARTE 1
-- ===========================

-- CRIAÇÃO DE TABELAS (modelo simplificado)
CREATE TABLE departamento (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100)
);

CREATE TABLE empregado (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamento(id)
);

-- =========================================
-- ÍNDICES CRIADOS COM BASE NAS CONSULTAS
-- =========================================

-- Índice para JOIN e GROUP BY por departamento
CREATE INDEX idx_empregado_departamento ON empregado(departamento_id);
-- Motivo: melhora o desempenho em JOINs e contagens agrupadas por departamento

-- Índice para busca de departamentos por cidade
CREATE INDEX idx_departamento_cidade ON departamento(cidade);
-- Motivo: melhora filtragem e ordenação por cidade

-- =========================================
-- CONSULTAS OTIMIZADAS
-- =========================================

-- 1. Qual o departamento com maior número de pessoas?
SELECT d.nome, COUNT(e.id) AS total_empregados
FROM departamento d
JOIN empregado e ON d.id = e.departamento_id
GROUP BY d.nome
ORDER BY total_empregados DESC
LIMIT 1;

-- 2. Quais são os departamentos por cidade?
SELECT cidade, nome AS departamento
FROM departamento
ORDER BY cidade;

-- 3. Relação de empregados por departamento
SELECT d.nome AS departamento, e.nome AS empregado
FROM empregado e
JOIN departamento d ON e.departamento_id = d.id
ORDER BY d.nome;

-- ===========================
-- SCRIPT DE PROCEDURE - PARTE 2
-- ===========================

-- Exemplo com E-COMMERCE
CREATE TABLE produto (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    preco DECIMAL(10,2)
);

DELIMITER //

CREATE PROCEDURE sp_gerenciar_produto (
    IN p_opcao INT,
    IN p_id INT,
    IN p_nome VARCHAR(100),
    IN p_preco DECIMAL(10,2)
)
BEGIN
    CASE 
        WHEN p_opcao = 1 THEN
            INSERT INTO produto (id, nome, preco) VALUES (p_id, p_nome, p_preco);
        WHEN p_opcao = 2 THEN
            UPDATE produto SET nome = p_nome, preco = p_preco WHERE id = p_id;
        WHEN p_opcao = 3 THEN
            DELETE FROM produto WHERE id = p_id;
        ELSE
            SELECT 'Opção inválida' AS mensagem;
    END CASE;
END //

DELIMITER ;

-- ===========================
-- CHAMADAS DA PROCEDURE
-- ===========================
-- CALL sp_gerenciar_produto(1, 101, 'Teclado Gamer', 199.99); -- Inserção
-- CALL sp_gerenciar_produto(2, 101, 'Teclado RGB', 179.99);    -- Atualização
-- CALL sp_gerenciar_produto(3, 101, '', 0.00);                 -- Remoção

-- ===========================
-- PARTE 3: VIEWS E PERMISSÕES - COMPANY
-- ===========================

-- Número de empregados por departamento e localidade
CREATE VIEW vw_empregados_por_departamento_cidade AS
SELECT d.nome AS departamento, d.cidade, COUNT(e.id) AS total_empregados
FROM departamento d
JOIN empregado e ON d.id = e.departamento_id
GROUP BY d.nome, d.cidade;

-- Lista de departamentos e seus gerentes
-- Supondo que tabela gerente: (id INT, nome VARCHAR, departamento_id INT)
CREATE TABLE gerente (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamento(id)
);

CREATE VIEW vw_departamento_gerentes AS
SELECT d.nome AS departamento, g.nome AS gerente
FROM departamento d
JOIN gerente g ON d.id = g.departamento_id;

-- Projetos com maior número de empregados
CREATE TABLE projeto (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    departamento_id INT
);

CREATE TABLE empregado_projeto (
    empregado_id INT,
    projeto_id INT,
    FOREIGN KEY (empregado_id) REFERENCES empregado(id),
    FOREIGN KEY (projeto_id) REFERENCES projeto(id)
);

CREATE VIEW vw_projetos_mais_empregados AS
SELECT p.nome AS projeto, COUNT(ep.empregado_id) AS total_empregados
FROM projeto p
JOIN empregado_projeto ep ON p.id = ep.projeto_id
GROUP BY p.nome
ORDER BY total_empregados DESC;

-- Lista de projetos, departamentos e gerentes
CREATE VIEW vw_projetos_departamento_gerente AS
SELECT p.nome AS projeto, d.nome AS departamento, g.nome AS gerente
FROM projeto p
JOIN departamento d ON p.departamento_id = d.id
JOIN gerente g ON d.id = g.departamento_id;

-- Quais empregados possuem dependentes e se são gerentes
CREATE TABLE dependente (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    empregado_id INT,
    FOREIGN KEY (empregado_id) REFERENCES empregado(id)
);

CREATE VIEW vw_empregados_dependentes_gerente AS
SELECT e.nome AS empregado, 
       CASE WHEN d.id IS NOT NULL THEN 'Sim' ELSE 'Não' END AS possui_dependente,
       CASE WHEN g.id IS NOT NULL THEN 'Sim' ELSE 'Não' END AS e_gerente
FROM empregado e
LEFT JOIN dependente d ON e.id = d.empregado_id
LEFT JOIN gerente g ON e.id = g.id;

-- ===========================
-- CRIAÇÃO DE USUÁRIOS E PERMISSÕES
-- ===========================

-- Criando usuário gerente
CREATE USER 'gerente_user'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON vw_empregados_por_departamento_cidade TO 'gerente_user'@'localhost';
GRANT SELECT ON vw_departamento_gerentes TO 'gerente_user'@'localhost';

-- Criando usuário empregado
CREATE USER 'empregado_user'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON vw_empregados_dependentes_gerente TO 'empregado_user'@'localhost';

-- ===========================
-- PARTE 4: TRIGGERS PARA E-COMMERCE
-- ===========================

-- Antes de deletar conta, mover para tabela de backup
CREATE TABLE usuario (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE usuario_backup (
    id INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_remocao DATETIME
);

DELIMITER //
CREATE TRIGGER trg_before_delete_usuario
BEFORE DELETE ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO usuario_backup (id, nome, email, data_remocao)
    VALUES (OLD.id, OLD.nome, OLD.email, NOW());
END;//
DELIMITER ;

-- Atualização de salário ao cadastrar novo colaborador
CREATE TABLE colaborador (
    id INT PRIMARY KEY,
    nome VARCHAR(100),
    salario DECIMAL(10,2)
);

DELIMITER //
CREATE TRIGGER trg_before_update_salario
BEFORE UPDATE ON colaborador
FOR EACH ROW
BEGIN
    IF NEW.salario < OLD.salario THEN
        SET NEW.salario = OLD.salario; -- Impede redução de salário
    END IF;
END;//
DELIMITER ;
