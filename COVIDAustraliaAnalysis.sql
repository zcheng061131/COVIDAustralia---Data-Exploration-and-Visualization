SELECT *
FROM PortfolioProject.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4;

SELECT *
FROM PortfolioProject.CovidVaccinations
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths
ORDER BY 1, 2;




-- looking at total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
ORDER BY 1, 2;

UPDATE CovidDeaths
SET date = STR_TO_DATE(date, '%d/%m/%y');




-- show likelihood of dying if you contact covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE location LIKE '%Australia%'
ORDER BY 1, 2;



-- loking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject.CovidDeaths
WHERE location LIKE '%Australia%'
ORDER BY 1, 2;

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
ORDER BY 1, 2;




-- looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;





-- showing the countries with the highest death count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- showing the continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
-- WHERE location like '%Australia%'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
-- WHERE location like '%Australia%'
WHERE continent is NOT NULL
ORDER BY 1,2;





-- Looking at total population vs vaccinations

UPDATE CovidVaccinations
SET date = STR_TO_DATE(date, '%d/%m/%y');

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED )) OVER (PARTITION BY dea.location)
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- CAST 和 CONVERT 一样

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location)
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3;

CREATE INDEX locationid ON PortfolioProject.CovidDeaths(location);
CREATE INDEX dateid ON PortfolioProject.CovidDeaths(date);
CREATE INDEX vaclocationid ON PortfolioProject.CovidVaccinations(location);
CREATE INDEX vacdateid ON PortfolioProject.CovidVaccinations(date);

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3;



--  USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
    AS ( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
                SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL)
-- ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;




-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(Continent NVARCHAR(225),
    Location NVARCHAR(225),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
                SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL;

-- ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;






-- CREATING VIEW to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
                SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL;
-- ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated;






-- AUSTRALIA NUMBER
SELECT location, date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE location like '%Australia%'
AND continent is NOT NULL
GROUP BY location, date
ORDER BY 1,2;

WITH AUPopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
    AS ( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
                SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent is NOT NULL
        AND dea.location LIKE '%Australia%')
-- ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100 AS AUVaccinationPercentage
FROM AUPopvsVac;