-- O nosso primeiro passo, será salvar esse modelo como uma 'tabela'
{{

    config(
        materialized='table'
    )
}}

with stg_vacinados AS(

    SELECT * FROM {{ ref('stg_vacinados_unificados') }} --Pegando o nosso modelo de staging
 ),

 tratamento_nulos_e_tipos AS (
    SELECT
        _id,
        faixa_etaria,
        idade,
        municipio,
        grupo,
        lote,
        vacina_fabricante,
        descricao_dose,
        cnes,
        sistema_origem,
        data_vacinacao,
        ano_origem,
        COALESCE(sexo, 'OUTROS') AS sexo,
        COALESCE(raca_cor, 'NÃO INFORMADO') AS raca_cor,
        COALESCE(REPLACE(categoria, 'OUTRAS', 'OUTROS'), 'OUTROS') AS categoria
    FROM
        stg_vacinados

 ),

 simplificar_grupos AS (

    SELECT
        _id, faixa_etaria, idade, municipio, lote,
        vacina_fabricante, descricao_dose, cnes, sistema_origem,
        data_vacinacao, ano_origem,
        sexo,
        raca_cor,
        categoria,

        CASE
            WHEN UPPER(grupo) LIKE '%CRIANÇAS%' THEN 'CRIANÇAS'
            WHEN UPPER(grupo) LIKE '%GESTANTES%' OR UPPER(grupo) LIKE '%PUÉRPERAS%' THEN 'GESTANTES E PUÉRPERAS'
            WHEN UPPER(grupo) LIKE '%TRABALHADORES%' OR UPPER(grupo) LIKE '%CAMINHONEIROS%' THEN 'TRABALHADORES (DIVERSOS)'
            WHEN UPPER(grupo) LIKE '%DFICIÊNCIA%' THEN 'PESSOAS COM DEFICIÊNCIA'
            WHEN UPPER(grupo) LIKE '%COMORBIDADES%' THEN 'PESSOAS COM COMORBIDADES'
            WHEN UPPER(grupo) LIKE '%PÚBLICO%' THEN 'PÚBLICO EM GERAL'
            WHEN UPPER(grupo) LIKE '%IDOSOS%' THEN 'IDOSOS'
            WHEN UPPER(grupo) LIKE '%RUA%' THEN 'PESSOAS EM SITUAÇÃO DE RUA'
            WHEN UPPER(grupo) LIKE '%VIAGEM%' THEN 'PESSOAS COM VIAGEM PARA O EXTERIOR'
            ELSE 'OUTRAS PRIORIDADES'
        END AS grupo
    
    FROM
        tratamento_nulos_e_tipos
 ),
 tratar_cnes_limpeza AS (
    SELECT
        _id, faixa_etaria, idade, municipio, lote,
        vacina_fabricante, descricao_dose, sistema_origem,
        data_vacinacao, ano_origem, sexo, raca_cor, categoria, grupo,
        
        TRIM(RTRIM(cnes, '.')) AS cnes_limpo
    FROM
        simplificar_grupos
),

tratar_cnes_split_1 AS (
    SELECT
        _id, faixa_etaria, idade, municipio, lote,
        vacina_fabricante, descricao_dose, sistema_origem,
        data_vacinacao, ano_origem, sexo, raca_cor, categoria, grupo,

        TRIM(SPLIT_PART(cnes_limpo, ' - ', 1)) AS cnes_info,
        TRIM(SPLIT_PART(cnes_limpo, ' - ', 2)) AS nome_unidade
    FROM
        tratar_cnes_limpeza
),

tratar_cnes_final AS (
    SELECT
        _id, faixa_etaria, idade, municipio, lote,
        vacina_fabricante, descricao_dose, sistema_origem,
        data_vacinacao, ano_origem, sexo, raca_cor, categoria, grupo,
        nome_unidade,

        TRIM(SPLIT_PART(cnes_info, ':', 1)) AS distrito_sanitario,
        TRIM(SPLIT_PART(cnes_info, ':', 3)) AS codigo_cnes
    FROM
        tratar_cnes_split_1
),

tratar_vacina AS (
    
    SELECT
        _id, faixa_etaria, idade, municipio, lote, descricao_dose, sistema_origem,
        data_vacinacao, ano_origem, sexo, raca_cor, categoria, grupo,
        nome_unidade, distrito_sanitario, codigo_cnes,

        TRIM(SPLIT_PART(vacina_fabricante, '-', 1)) AS id_vacina,

        (REGEXP_MATCHES(vacina_fabricante, '\((.*?)\)'))[1] AS fabricante_laboratorio,

        CASE
            WHEN UPPER(vacina_fabricante) LIKE '%PEDIÁTRICA%' THEN 'PEDIÁTRICA'
            ELSE 'GERAL'
        END AS publico_alvo,

        TRIM(SPLIT_PART(SPLIT_PART(vacina_fabricante, ' - ', 2), ' (', 1)) AS nome_vacina
    FROM
        tratar_cnes_final

),
limpeza_final AS (
    SELECT
        sexo,
        raca_cor,
        municipio,
        grupo,
        categoria,
        sistema_origem,
        distrito_sanitario,
        codigo_cnes,
        nome_unidade,
        id_vacina,
        fabricante_laboratorio,
        publico_alvo,
        nome_vacina,
        descricao_dose,

        CAST(idade AS INTEGER) AS idade,
        
        CAST(ano_origem AS INTEGER) AS ano_origem,
        
        CAST(SUBSTRING(data_vacinacao, 1, 10) AS DATE) AS data_vacinacao
        
    FROM 
        tratar_vacina
    
    WHERE 
        idade IS NOT NULL 
        AND municipio IS NOT NULL
),


adicionar_id_unico AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY data_vacinacao, id_vacina) AS id,
        *
    FROM
        limpeza_final
)

select * from adicionar_id_unico
