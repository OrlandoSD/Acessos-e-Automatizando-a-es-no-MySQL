# Projeto: Banco de Dados com Índices, Procedures, Views e Triggers

Este repositório contém a implementação de um sistema de banco de dados com foco em **otimização de consultas**, **manipulação de dados via procedures**, **segurança com views e permissões**, e **automatização com triggers**.

## 🗂️ Estrutura do Projeto

### ✅ Parte 1 - Criação de Índices e Consultas Otimizadas

**Objetivo:** Melhorar a performance das consultas SQL utilizando índices estratégicos.

**Consultas Otimizadas:**
1. Qual o departamento com maior número de pessoas?
2. Quais são os departamentos por cidade?
3. Relação de empregados por departamento

**Índices Criados:**
- `idx_empregado_departamento`: melhora JOINs entre `empregado` e `departamento`.
- `idx_departamento_cidade`: acelera filtros por cidade na tabela `departamento`.

**Justificativa:** Os índices foram criados com base nas colunas utilizadas nos filtros (`WHERE`) e agrupamentos (`GROUP BY`) das consultas, otimizando o tempo de resposta.

---

### ✅ Parte 2 - Procedures com Estruturas Condicionais

**Objetivo:** Criar uma procedure que manipula dados da tabela `produto` com base em uma variável de controle (`p_opcao`).

**Ações Suportadas:**
- `1`: Inserção
- `2`: Atualização
- `3`: Remoção

**Vantagens:**
- Centralização da lógica de negócio
- Redução de código duplicado
- Facilidade de manutenção

---

### ✅ Parte 3 - Views e Permissões

**Objetivo:** Criar views para facilitar a análise de dados e aplicar controle de acesso por tipo de usuário.

**Views Criadas:**
- `vw_empregados_por_departamento_cidade`
- `vw_departamento_gerentes`
- `vw_projetos_mais_empregados`
- `vw_projetos_departamento_gerente`
- `vw_empregados_dependentes_gerente`

**Permissões:**
- Usuário `gerente_user`: acesso a dados estratégicos (departamentos, empregados, projetos).
- Usuário `empregado_user`: acesso restrito aos dados de dependentes e sua relação com gerentes.

**Justificativa:** As views abstraem a complexidade das queries e permitem aplicar políticas de segurança granular via `GRANT`.

---

### ✅ Parte 4 - Triggers para E-commerce

**Objetivo:** Automatizar tarefas em eventos de remoção e atualização.

**Triggers Criadas:**
- `trg_before_delete_usuario`: backup de usuários antes da exclusão.
- `trg_before_update_salario`: impede redução de salário de colaboradores.

**Vantagens:**
- Garante integridade e rastreabilidade de dados.
- Automatiza regras de negócio diretamente no banco de dados.

---

## 🛠️ Tecnologias Utilizadas
- MySQL 8.x
- SQL DDL & DML
- Procedures, Triggers e Views
- Controle de Acesso com GRANT/REVOKE

---

## 🚀 Como Executar

1. Clone o repositório:
   ```bash
   git clone https://github.com/OrlandoSD/Banco-de-Dados-com-ndices-e-Procedures.git
   ```

2. Importe ou execute o script `Company Db Index Procedure.sql` em seu SGBD MySQL.

3. Teste os exemplos de queries, procedures e triggers.

---

## 🧠 Autor

**Orlando**  
💡 Projeto acadêmico de banco de dados  
🔗 [GitHub](https://github.com/OrlandoSD)

---


