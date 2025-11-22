{{ config(materialized='table') }}

WITH base AS (
    SELECT DISTINCT 
        data_vacinacao 
    FROM {{ ref('int_vacinados_preparados') }}
    WHERE data_vacinacao IS NOT NULL
)

SELECT
    ROW_NUMBER() OVER (ORDER BY data_vacinacao) AS id_tempo_sk,
    data_vacinacao,
    EXTRACT(DAY FROM data_vacinacao) AS dia,
    EXTRACT(MONTH FROM data_vacinacao) AS mes,
    EXTRACT(YEAR FROM data_vacinacao) AS ano,
    EXTRACT(QUARTER FROM data_vacinacao) AS trimestre,
    TO_CHAR(data_vacinacao, 'Day') AS dia_semana
FROM base