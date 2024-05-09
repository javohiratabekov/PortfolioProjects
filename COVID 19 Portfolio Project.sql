SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total cases vs Total Deaths
--Shows information about Uzbekistan

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathpercentage
FROM coviddeaths
WHERE location LIKE 'Uzbekistan'
AND continent IS NOT NULL
ORDER BY 1,2


--Total cases vs Population
--Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, total_deaths, (total_cases/population)* 100 as percent_population_infected
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Countries with the Highest Infection Rate compared to Population

SELECT location ,population, MAX(total_cases) as highest_infection_count , MAX((total_cases/population))* 100 as percent_population_infected
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC


--Countries with the Highest Death Count per Population

SELECT location, MAX(total_deaths) as total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


--Showing Continents with the Highest Death Count per population

SELECT continent, MAX(total_deaths) as totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using CTE to perform Calculation on Partition by in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (people_vaccinated/population)*100 AS percent_of_people
FROM PopvsVac



--Temp TABLE to perform Calculation on Partition by in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (people_vaccinated/population)*100 AS percentofpeople
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated