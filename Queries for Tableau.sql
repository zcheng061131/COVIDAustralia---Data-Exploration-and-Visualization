SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
-- WHERE location like '%Australia%'
WHERE continent is NOT NULL
ORDER BY 1,2;


SELECT Location, SUM(new_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
WHERE continent is NULL
AND location not in ('World','European Union', 'International')
GROUP BY Location
ORDER BY TotalDeathCount DESC;

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;



SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC;




SELECT Location, population, DATE_FORMAT(date, '%d/%m/%Y'), IF(MAX(total_cases) IS NULL, 0, MAX(total_cases)) as HighestInfectionCount, IF(MAX(total_cases/population)*100 IS NULL, 0.0000, MAX(total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
-- WHERE location LIKE '%Australia%'
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC;



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