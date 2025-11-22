{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('int_vacinados_preparados') }}
),

locais_unicos AS (
    SELECT DISTINCT
        municipio,
        'Pernambuco' AS estado,
        'PE' AS uf,
        'Nordeste' AS regiao,
        'Brasil' AS pais
    FROM base
)

SELECT
    ROW_NUMBER() OVER (ORDER BY municipio) AS id_localidade_sk,
    *
FROM locais_unicos