SELECT *
FROM PortfolioProject.CovidDeaths_csv cdc 
ORDER BY 3,4

-- select *
-- FROM CovidVacc
-- ORDER BY 3,4


-- Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths_csv
ORDER BY 1,2


-- Total Cases vs. Total Deaths (Shows likelihood of dying if you contract COVID in Canada)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths_csv
WHERE location like '%canada%'
ORDER BY 1,2 DESC


-- Total Cases vs. Population (Shows percentage of Canada's population that contracted COVID)

SELECT location, date, total_cases, population, (total_cases/population)*100 as CanadaInfectionPercentage
FROM PortfolioProject.CovidDeaths_csv
WHERE location like '%canada%'
ORDER BY 1,2 DESC


-- Countries with highest infection rate by population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject.CovidDeaths_csv
GROUP BY location, population 
ORDER BY InfectionPercentage DESC


-- Countries with highest death count by population

SELECT location, population, MAX(total_deaths) as HighestDeathCount,  MAX((total_deaths/population)*100) as DeathPercentage
FROM PortfolioProject.CovidDeaths_csv
GROUP BY location, population 
ORDER BY DeathPercentage DESC


-- Highest death count in each country by population

SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths_csv
WHERE continent <> ''
GROUP BY location, population
ORDER BY population DESC


-- Highest death count in each continent

SELECT location, MAX(total_deaths) as TotalDeathCount 
FROM PortfolioProject.CovidDeaths_csv
WHERE continent IS NULL OR continent = ''
GROUP BY location, continent
ORDER BY TotalDeathCount DESC


-- Global New Infection Count, New Death Count & Death Rate by date 

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases) as NewDeathPercentage
FROM PortfolioProject.CovidDeaths_csv
WHERE continent <> ''
GROUP BY date
ORDER BY date DESC


-- Global Total Cases, Total Deaths & Total Death Percentage

SELECT SUM(new_cases) as GlobalCases, SUM(new_deaths) as GlobalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as GlobalDeathPercentage
FROM PortfolioProject.CovidDeaths_csv
WHERE continent <> ''


-- Global Population vs. Global Vaccinations

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated)
AS
(
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
SUM(cvc.new_vaccinations) OVER (PARTITION BY cdc.location ORDER BY cdc.location, cdc.date) as RollingPopulationVaccinated
FROM PortfolioProject.CovidDeaths_csv cdc 
JOIN PortfolioProject.CovidVacc_csv cvc
	ON cdc.location = cvc.location 
	AND cdc.date = cvc.date
WHERE cdc.continent <> ''
)
SELECT *, (RollingPopulationVaccinated/population)*100 as PopulationVaccinated
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
SUM(cvc.new_vaccinations) OVER (PARTITION BY cdc.location ORDER BY cdc.location, cdc.date) as RollingPopulationVaccinated
FROM PortfolioProject.CovidDeaths_csv cdc 
JOIN PortfolioProject.CovidVacc_csv cvc
	ON cdc.location = cvc.location 
	AND cdc.date = cvc.date
WHERE cdc.continent <> ''

SELECT *
FROM PercentPopulationVaccinated



-- Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations, 
SUM(cvc.new_vaccinations) OVER (PARTITION BY cdc.location ORDER BY cdc.location, cdc.date) as RollingPopulationVaccinated
FROM PortfolioProject.CovidDeaths_csv cdc 
JOIN PortfolioProject.CovidVacc_csv cvc
	ON cdc.location = cvc.location 
	AND cdc.date = cvc.date
WHERE cdc.continent <> ''


SELECT * 
FROM PercentPopulationVaccinated
