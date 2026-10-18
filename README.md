# sql-project-michaela-perlikova
SQL project focused on salary, food price and GDP analysis.
SQL Projekt - Michaela Perlíková
Popis projektu
Cílem projektu bylo analyzovat vývoj mezd, cen základních potravin a HDP v České republice.

Primární tabulka
Název tabulky:

t_michaela_perlikova_project_SQL_primary_final

Tabulka obsahuje:

rok
odvětví
průměrnou mzdu
potravinu
průměrnou cenu
Vytvořena byla spojením tabulek:

czechia_payroll
czechia_payroll_value_type
czechia_payroll_industry_branch
czechia_price
czechia_price_category
Sekundární tabulka
Název tabulky:

t_michaela_perlikova_project_SQL_secondary_final

Tabulka obsahuje:

stát
zkratku státu
rok
populaci
HDP
GINI index
Vytvořena byla spojením tabulek:

economies
countries
Do analýzy byly zahrnuty pouze evropské státy.

Informace o výstupních datech
Analýza pracuje s obdobím 2006–2018.
Primární tabulka obsahuje dvě sledované potraviny:
Chléb konzumní kmínový
Mléko polotučné pasterované
Sekundární tabulka obsahuje pouze evropské státy.
Ve zdrojových datech se vyskytují chybějící hodnoty GINI indexu.
Výzkumné otázky a závěry
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Ve všech sledovaných odvětvích byla průměrná mzda v roce 2018 vyšší než v roce 2006.

2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
V roce 2006 bylo možné koupit:
1 437,46 l mléka
1 287,17 kg chleba
   
V roce 2018 bylo možné koupit:
1 641,77 l mléka
1 342,32 kg chleba

3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
Mléko polotučné pasterované s průměrným meziročním růstem 2,98 %.

4. Existuje rok, ve kterém byl meziroční nárůst cen výrazně vyšší než růst mezd?
Ano. Takové situace nastaly v letech 2008 a 2011.

5. Má výška HDP vliv na změny ve mzdách a cenách potravin?
Z dat lze pozorovat výraznější souvislost mezi růstem HDP a růstem mezd než mezi růstem HDP a cenami potravin.
