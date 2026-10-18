--Vytvoření primární tabulky
CREATE TABLE t_michaela_perlikova_project_SQL_primary_final AS
SELECT 
    cp.payroll_year AS rok,
    ib.name AS odvetvi,
    cp.value AS prumerna_mzda,
    pc.name AS potravina,
    prc.prumerna_cena
FROM czechia_payroll cp
JOIN czechia_payroll_value_type vt 
    ON cp.value_type_code = vt.code
JOIN czechia_payroll_industry_branch ib
    ON cp.industry_branch_code = ib.code
JOIN (
    SELECT 
        EXTRACT(YEAR FROM pr.date_from) AS rok,
        pr.category_code,
        AVG(pr.value) AS prumerna_cena
    FROM czechia_price pr
    WHERE pr.category_code IN (111301, 114201)
    GROUP BY rok, pr.category_code
) prc
    ON prc.rok = cp.payroll_year
JOIN czechia_price_category pc
    ON prc.category_code = pc.code
WHERE vt.code = 5958
  AND cp.payroll_year BETWEEN 2006 AND 2018;

-- Vytvoření sekundární tabulky
CREATE TABLE t_michaela_perlikova_project_SQL_secondary_final AS
SELECT 
    e.country AS stat,
    c.abbreviation AS stat_zkratka,
    e.year AS rok,
    e.population AS populace,
    e.gdp AS "HDP",
    e.gini AS "GINI_index"
FROM economies e
JOIN countries c
    ON e.country = c.country
WHERE e.year BETWEEN 2006 AND 2018
  AND c.continent = 'Europe';


--Výzkumné otázky--
--1)Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT 
	odvetvi, rok, AVG(tmpp.prumerna_mzda) AS prumerna_mzda,
	CASE WHEN rok=2018 AND AVG(prumerna_mzda) > 
	(SELECT AVG(prumerna_mzda)FROM t_michaela_perlikova_project_sql_primary_final t2 WHERE t2.odvetvi=tmpp.odvetvi AND rok=2006)
	THEN 'ROSTE'
	WHEN rok=2018 AND AVG(prumerna_mzda) < 
	(SELECT AVG(prumerna_mzda)FROM t_michaela_perlikova_project_sql_primary_final t2 WHERE t2.odvetvi=tmpp.odvetvi AND rok=2006)
	THEN 'KLESA'
	ELSE NULL END AS trend
	FROM t_michaela_perlikova_project_sql_primary_final AS tmpp WHERE rok=2006 OR rok= 2018
	GROUP BY odvetvi, rok ORDER BY odvetvi, rok;
--2 Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT 
    rok,
    AVG (prumerna_mzda) AS prumerna_mzda,
    AVG(CASE WHEN potravina = 'Mléko polotučné pasterované' THEN prumerna_cena END) AS cena_mleka,
    AVG(CASE WHEN potravina = 'Chléb konzumní kmínový' THEN prumerna_cena END) AS cena_chleba,
    AVG(prumerna_mzda) / AVG(CASE WHEN potravina = 'Mléko polotučné pasterované' THEN prumerna_cena END) AS litry_mleka,
    AVG(prumerna_mzda) / AVG(CASE WHEN potravina = 'Chléb konzumní kmínový' THEN prumerna_cena END) AS kg_chleba
FROM t_michaela_perlikova_project_sql_primary_final
WHERE rok = 2006 OR rok = 2018
GROUP BY rok
ORDER BY rok;

--3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
SELECT 
    t1.potravina,
    AVG( (t1.prumerna_cena - t2.prumerna_cena) / t2.prumerna_cena * 100 ) AS mezirocni_narust_procent
FROM t_michaela_perlikova_project_sql_primary_final t1
JOIN t_michaela_perlikova_project_sql_primary_final t2
    ON t1.potravina = t2.potravina
    AND t1.rok = t2.rok + 1
GROUP BY t1.potravina
ORDER BY mezirocni_narust_procent ASC;

--4 Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT 
    t1.rok AS aktualni_rok,
    ((t1.avg_cena - t2.avg_cena) / t2.avg_cena * 100) AS narust_cen_procent,
    ((t1.avg_mzda - t2.avg_mzda) / t2.avg_mzda * 100) AS narust_mezd_procent,
    CASE 
        WHEN ((t1.avg_cena - t2.avg_cena) / t2.avg_cena * 100)
             > ((t1.avg_mzda - t2.avg_mzda) / t2.avg_mzda * 100) + 10
        THEN 'ANO'
        ELSE 'NE'
    END AS ceny_vyssi_o_10_procent
FROM (
    SELECT rok,
           AVG(prumerna_cena) AS avg_cena,
           AVG(prumerna_mzda) AS avg_mzda
    FROM t_michaela_perlikova_project_sql_primary_final
    GROUP BY rok
) t1
JOIN (
    SELECT rok,
           AVG(prumerna_cena) AS avg_cena,
           AVG(prumerna_mzda) AS avg_mzda
    FROM t_michaela_perlikova_project_sql_primary_final
    GROUP BY rok
) t2
ON t1.rok = t2.rok + 1
ORDER BY t1.rok;

--5 Má výška HDP vliv na změny ve mzdách a cenách potravin?Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na
-- cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
CREATE VIEW vyvoj_cr AS
SELECT
    p.rok,
    AVG(p.prumerna_mzda) AS prumerna_mzda,
    AVG(p.prumerna_cena) AS prumerna_cena,
    AVG(s."HDP") AS hdp
FROM t_michaela_perlikova_project_sql_primary_final p
JOIN t_michaela_perlikova_project_sql_secondary_final s
    ON p.rok = s.rok
WHERE s.stat_zkratka = 'CZ'
GROUP BY p.rok
ORDER BY p.rok;


SELECT 
	t1.rok,
	((t1.HDP-t2.HDP)/t2.HDP) * 100 AS narust_HDP,
	((t1.prumerna_mzda - t2.prumerna_mzda) / t2.prumerna_mzda) * 100 AS narust_mezd,
	((t1.prumerna_cena - t2.prumerna_cena) / t2.prumerna_cena) * 100 AS narust_cen
FROM vyvoj_cr t1
JOIN vyvoj_cr t2
	ON t1.rok = t2.rok + 1
ORDER BY t1.rok;
	