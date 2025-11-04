# Projeto de Pipeline de Dados (ETL vs. ELT) - Vacinados Recife

Este repositório é um projeto de estudo para a monitoria de Banco de Dados, focado em demonstrar, construir e comparar duas abordagens de pipeline de dados: **ETL (Extract, Transform, Load)** e **ELT (Extract, Load, Transform)**.

O projeto utiliza um conjunto de dados públicos do Portal de Dados Abertos da Prefeitura do Recife sobre as **Pessoas Vacinadas contra a Covid-19**. O desafio central é a integração de múltiplos arquivos (um para cada ano: 2022, 2023, 2024) em uma base de dados única, limpa e pronta para análise.

## 🚀 Objetivos do Projeto

  * **Demonstrar um Pipeline ETL Clássico:** Usando **Python (Pandas)** para extrair, unificar, limpar e transformar os dados em memória antes de carregá-los em um banco de dados.
  * **Demonstrar um Pipeline ELT Moderno:** Usando **Python** apenas para a Extração e Carga (EL) dos dados brutos e o **dbt (data build tool)** para realizar todas as transformações (T) diretamente no banco de dados com SQL.
  * **Aplicar Técnicas de Limpeza de Dados:** Lidar com valores nulos, inconsistências de formato e dados redundantes.
  * **Realizar Engenharia de Atributos:** Quebrar colunas complexas em campos utilizáveis.
  * **Gerar um "ID Único":** Criar uma chave primária substituta (surrogate key) para a tabela final, já que o `_id` original não era confiável.

## 🛠️ Tecnologias Utilizadas

  * **Linguagem:** Python 3
  * **Bibliotecas Python:** Pandas, SQLAlchemy, Psycopg2-binary
  * **Banco de Dados:** PostgreSQL
  * **Ferramenta de Transformação (ELT):** dbt (dbt-postgres)
  * **Ambiente:** Jupyter Notebook / VS Code

## 📁 Estrutura do Projeto

```
.
├── data/
│   ├── dados_vacinados_2022.csv  (Arquivo de dados brutos)
│   ├── dados_vacinados_2023.csv
│   └── dados_vacinados_2024.csv
├── notebooks/
│   ├── ETL.ipynb                 (Pipeline ETL completo com Pandas)
│   └── ELT.ipynb            (Etapa "EL" do pipeline ELT - Carga bruta)
├── transformacao_vacinados/      (Projeto dbt para a etapa "T")
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_vacinados_unificados.sql  (Unifica as 3 fontes)
│   │   │   └── schema.yml                    (Define as fontes 'raw')
│   │   └── marts/
│   │       └── vacinados_etl_final.sql       (Modelo final com toda a limpeza)
│   └── dbt_project.yml
└── README.md                     (Este arquivo)
```

## ⚙️ Configuração e Instalação

Siga estes passos para replicar o ambiente do projeto.

### Pré-requisitos

  * Python 3.10+
  * Um servidor PostgreSQL instalado e rodando.
  * Git (para clonar o projeto).

### 1\. Clonar o Repositório

```bash
git clone https://github.com/[SEU_USUARIO]/[NOME_DO_PROJETO].git
cd [NOME_DO_PROJETO]
```

### 2\. Instalar Dependências

```bash
pip install pandas sqlalchemy psycopg2-binary dbt-postgres
```

### 3\. Configurar o Banco de Dados (PostgreSQL)

1.  Crie um novo banco de dados no seu PostgreSQL (ex: `projeto_banco_de_dados`).
2.  **Importante:** Atualize a `DATABASE_URL` nos notebooks `ETL.ipynb` e `ELT_load.ipynb` com seu usuário, senha e nome do banco.
    ```python
    DATABASE_URL = 'postgresql://postgres:SUA_SENHA@localhost:5432/projeto_monitoria'
    ```

### 4\. Configurar o dbt

1.  O `dbt` precisa de um arquivo `profiles.yml` para se conectar ao seu banco. Este arquivo **não** fica no projeto, ele fica na sua pasta de usuário.

2.  Vá até `C:\Users\[SEU_USUARIO]\.dbt\` e crie/edite o arquivo `profiles.yml`.

3.  Cole a configuração abaixo, substituindo os campos `pass` e `dbname` pelos seus:

    ```yaml
    transformacao_vacinados:
      target: dev
      outputs:
        dev:
          type: postgres
          host: localhost
          user: postgres
          pass: SUA_SENHA_AQUI
          port: 5432
          dbname: projeto_monitoria
          schema: public
    ```

## ▶️ Como Executar os Pipelines

### Pipeline 1: ETL (Abordagem com Pandas)

1.  Abra e execute todas as células do notebook:
    `notebooks/ETL.ipynb`
2.  Ao final, o notebook irá carregar o DataFrame final e limpo na tabela `vacinados_etl_final` no seu PostgreSQL.

### Pipeline 2: ELT (Abordagem com dbt)

Este pipeline tem duas etapas:

**Etapa 1: Carga (EL)**

1.  Abra e execute todas as células do notebook:
    `notebooks/ELT.ipynb`
2.  Isso carregará os 3 CSVs **brutos** em 3 tabelas separadas no PostgreSQL: `raw_vacinados_2022`, `raw_vacinados_2023` e `raw_vacinados_2024`.

**Etapa 2: Transformação (T)**

1.  Abra seu terminal e navegue até a pasta do projeto dbt:
    ```bash
    cd transformacao_vacinados
    ```
2.  Teste sua conexão com o banco:
    ```bash
    dbt debug
    ```
3.  Execute o pipeline de transformação. O `dbt` irá ler os dados brutos, unificá-los, limpá-los e criar a tabela final `vacinados_etl_final`:
    ```bash
    dbt run
    ```

## 📊 Análise

Com a tabela `vacinados_etl_final` (criada por qualquer um dos pipelines) pronta no banco, podemos realizar as análises.

*Exemplo de análise que pode ser feita:*

```sql
SELECT 
    grupo,
    ano_origem,
    COUNT(id) AS total_doses
FROM 
    vacinados_etl_final
GROUP BY 
    grupo, ano_origem
ORDER BY 
    ano_origem, total_doses DESC;
```
