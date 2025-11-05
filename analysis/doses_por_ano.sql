-- Consultado a comparação de doses por ano
SELECT
	ano_origem,
	COUNT(id) AS numero_doses
FROM
	vacinados_etl_final
GROUP BY
	ano_origem
ORDER BY
	ano_origem ASC;