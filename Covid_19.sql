/*
    For the visualization on Tableau, I only use the first 4 datasets using the queries below.
*/

--1. Look up percentage of covid cases vs the population

SELECT location, population, sum(new_cases) as cases_count, round(((sum(new_cases)/population)*100),2) AS Covid_Percentage
FROM `Covid_Death.Covid_Death`
WHERE continent is not null
GROUP BY 1,2
ORDER BY 1,2


--2. Look up infection count from countries around the world

SELECT location, population, date, MAX(total_cases) AS Infection_Count,  Round((((MAX(total_cases)/population)*100)),2) AS Percentage_Infection_Count
FROM `Covid_Death.Covid_Death`
--WHERE continent is not null
GROUP BY location, population, date
ORDER BY Percentage_Infection_Count DESC


--3. Look up the death percentage around the world

SELECT sum(new_deaths) as death_count, sum(new_cases) as cases_count, round(((sum(new_deaths)/sum(new_cases))*100),2) AS Death_Percentage
FROM `Covid_Death.Covid_Death`
WHERE continent is not null
ORDER BY 1,2


--4. Look up the death count around the world

Select location, population, SUM(new_deaths) as Total_Death_Count
From `Covid_Death.Covid_Death`
Where continent is null and location not in ('World', 'European Union', 'International')
Group by location, population
order by Total_Death_Count desc


/*
  Other queries
*/

-- 1. Look up the death percentage around the world (Break down into countries)

SELECT location, population, MAX(total_deaths) AS Death_Count,  Round((((MAX(total_deaths)/population)*100)),2) AS Percentage_Death_Count
FROM `Covid_Death.Covid_Death`
WHERE continent is not NULL
GROUP BY location, population
ORDER BY Death_Count DESC

-- 2. Look up continents with the highest death count

SELECT MAX(total_deaths) AS Death_Count, SUM(population) AS Total_Population, (((MAX(total_deaths)/SUM(population))*100)) AS Death_Percentage
FROM `Covid_Death.Covid_Death`
WHERE continent is not NULL
ORDER BY Death_Count,Total_Population DESC

-- 3. Look up continents with the highest death count (Break down into continent)

SELECT location, MAX(total_deaths) AS Death_Count,  Round((MAX((total_deaths/population)*100)),2) AS Percentage_Death_Count
FROM `Covid_Death.Covid_Death`
WHERE continent is NULL 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Death_Count DESC


--4. Look up total population vs vaccinations AND vaccination count per day (Use CTE)

WITH PopVsVac as
(
  SELECT 
  Dea.continent,
  Dea.location,
  Dea.date,
  Dea.population,
  Vac.new_vaccinations,
  SUM(Vac.new_vaccinations) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) as People_Vaccinated
    FROM `Covid_Death.Covid_Death` as Dea
    JOIN `Covid_Death.Covid_Vaccinations` as Vac
  ON Dea.location = Vac.location
  AND Dea.date = Vac.date
  WHERE Dea.continent is not null
)
SELECT location, date, population, new_vaccinations, (People_Vaccinated/population)*100 as Vaccinated_Percentage
FROM PopVsVac
