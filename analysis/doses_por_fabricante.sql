SELECT
    descricao_dose,
    fabricante_laboratorio,
    COUNT(id) AS total_doses_aplicadas
FROM
    vacinados_etl_final
GROUP BY
    descricao_dose,
    fabricante_laboratorio
ORDER BY
    descricao_dose ASC,
    total_doses_aplicadas DESC;