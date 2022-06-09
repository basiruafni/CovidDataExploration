SELECT *
FROM project.coviddeaths
ORDER BY 3,4

SELECT *
FROM project.covidvaccination
ORDER BY 3,4

-- Select Data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project.covid_deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood od dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM project.covid_deaths
WHERE location like '%indonesia%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM project.covid_deaths
WHERE location like '%indonesia%'
ORDER BY 1,2

-- Looking at Countries with HIghest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCountry,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM project.covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM project.covid_deaths
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break things down by continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM project.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM project.covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(new_vaccinations, UNSIGNED INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM project.covid_deaths dea
JOIN project.covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- Looking at Total Population vs Vaccinations using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(new_vaccinations, UNSIGNED INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM project.covid_deaths dea
JOIN project.covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

