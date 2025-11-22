{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('int_vacinados_preparados') }}
),

unidades_unicas AS (
    SELECT DISTINCT
        nome_unidade,
        distrito_sanitario,
        codigo_cnes,
        sistema_origem
    FROM base
)

SELECT
    ROW_NUMBER() OVER (ORDER BY nome_unidade) AS id_unidade_sk,
    *
FROM unidades_unicas