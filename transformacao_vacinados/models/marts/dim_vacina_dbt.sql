{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('int_vacinados_preparados') }}
),

vacinas_unicas AS (
    SELECT DISTINCT
        nome_vacina,
        fabricante_laboratorio,
        id_vacina AS codigo_vacina_original,
        publico_alvo
    FROM base
)

SELECT
    ROW_NUMBER() OVER (ORDER BY nome_vacina) AS id_vacina_sk,
    *
FROM vacinas_unicas