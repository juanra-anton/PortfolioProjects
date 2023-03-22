-- GENERAL VISUALIZATIONS --

-- Visualizing CovidDeaths table

SELECT *
FROM CovidDeaths

-- Visualizing countries data ordered by location and date

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data that we are going to use ordered by location and date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths by Country
-- Likelihood of dying if you contract Covid

SELECT location, date, total_cases, total_deaths, population, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths
ORDER BY location, date


-- COVID IN SPAIN --

-- Total Cases vs Total Deaths in Spain

SELECT location, date, total_cases, total_deaths, population, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Spain'
ORDER BY location, date

-- Total Cases vs Population in Spain
-- Percentage of population that got infected by Covid

SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Spain'
ORDER BY location, date

-- COUNTRIES with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases) / population)*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- COUNTRIES with the highest Death Count per population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL -- removes continents from the results
GROUP BY location
ORDER BY TotalDeathCount DESC

-- CONTINENTS with the Highest Death Count

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS --

-- New cases and new deaths in the world by day

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases and total deaths in the world

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Visualizing COVID VACCINATIONS table

SELECT *
FROM Project1..CovidVaccinations

-- JOINing both tables

SELECT *
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date

-- Total Population vs Vaccinations in SPAIN
-- Percentage of population that has received at least 1 vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'Spain'
ORDER BY 2,3  

-- Using CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using TEMP TABLE to perform calculation on PARTITION BY in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATE A VIEW to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL