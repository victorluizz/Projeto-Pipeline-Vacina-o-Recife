{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('int_vacinados_preparados') }}
),

perfis_unicos AS (
    SELECT DISTINCT
        sexo,
        raca_cor,
        grupo,
        categoria
    FROM base
)

SELECT
    ROW_NUMBER() OVER (ORDER BY grupo, categoria) AS id_paciente_sk,
    *
FROM perfis_unicos