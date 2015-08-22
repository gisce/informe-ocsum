/*
	All the request cancelled during the given period.
*/
SELECT
	COUNT(*) AS nreq,
	dist.id AS distriid,
	dist.ref AS refdistribuidora,
	tar.name as tarname,
	provincia.code AS codiprovincia,
	provincia.name AS nomprovincia,
	dist.name AS distriname,
	STRING_AGG(sw.id::text, ',' ORDER BY sw.id) AS casos
FROM
	(
	SELECT
		id AS pass_id,
		header_id,
		1 AS process
	FROM giscedata_switching_c1_09
	WHERE
		create_date >= %(periodStart)s AND
		create_date < %(periodEnd)s AND
		rebuig = FALSE AND
		TRUE
	UNION
	SELECT
		id AS pass_id,
		header_id,
		2 AS process
	FROM giscedata_switching_c2_09
	WHERE
		create_date >= %(periodStart)s AND
		create_date < %(periodEnd)s AND
		rebuig = FALSE AND
		TRUE
	) AS step
LEFT JOIN
	giscedata_switching_step_header AS sth ON step.header_id = sth.id
LEFT JOIN
	giscedata_switching AS sw ON sw.id = sth.sw_id
LEFT JOIN
	giscedata_cups_ps AS cups ON cups.id = sw.cups_id
LEFT JOIN
	giscedata_polissa AS pol ON pol.id = sw.cups_polissa_id
LEFT JOIN
	res_partner AS dist ON dist.id = pol.distribuidora
LEFT JOIN
	giscedata_polissa_tarifa AS tar ON tar.id = pol.tarifa
LEFT JOIN
	res_municipi ON res_municipi.id = cups.id_municipi
LEFT JOIN
	res_country_state AS provincia ON provincia.id = res_municipi.state
GROUP BY
	tar.name,
	dist.name,
	provincia.code,
	dist.id,
	dist.ref,
	provincia.name,
	dist.name,
	TRUE
ORDER BY
	tar.name,
	dist.name,
	provincia.code,
	TRUE
;
