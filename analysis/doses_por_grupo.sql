-- Consultado qual grupo prioritário tiveram mais doses aplicadas
SELECT
	grupo,
	COUNT(id) as total_doses
FROM
	vacinados_etl_final
WHERE
	grupo != 'PÚBLICO EM GERAL'
GROUP BY
	grupo
ORDER BY
	total_doseS DESC
LIMIT 10;