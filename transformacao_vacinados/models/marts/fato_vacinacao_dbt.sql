{{ config(materialized='table') }}

WITH vacinados AS (
    SELECT 
        *
    FROM {{ ref('int_vacinados_preparados') }}
),

paciente AS (SELECT * FROM {{ ref('dim_paciente_dbt') }}),
vacina AS (SELECT * FROM {{ ref('dim_vacina_dbt') }}),
unidade AS (SELECT * FROM {{ ref('dim_unidade_dbt') }}),
localidade AS (SELECT * FROM {{ ref('dim_localidade_dbt') }}),
tempo AS (SELECT * FROM {{ ref('dim_tempo_dbt') }})

SELECT

    p.id_paciente_sk,
    l.id_localidade_sk,
    v.id_vacina_sk,
    u.id_unidade_sk,
    t.id_tempo_sk,
    base.descricao_dose,
    base.ano_origem

FROM vacinados AS base

-- JOIN PACIENTE
LEFT JOIN paciente p 
    ON base.sexo = p.sexo 
    AND base.grupo = p.grupo 
    AND base.raca_cor = p.raca_cor 
    AND base.categoria = p.categoria

-- JOIN LOCALIDADE
LEFT JOIN localidade l 
    ON base.municipio = l.municipio

-- JOIN VACINA
LEFT JOIN vacina v 
    ON base.nome_vacina = v.nome_vacina 
    AND base.fabricante_laboratorio = v.fabricante_laboratorio

-- JOIN UNIDADE
LEFT JOIN unidade u 
    ON base.nome_unidade = u.nome_unidade

-- JOIN TEMPO
LEFT JOIN tempo t 
    ON base.data_vacinacao = t.data_vacinacao