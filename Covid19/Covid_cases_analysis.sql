SELECT *
FROM CovidPeriod..CovidDeaths
WHERE continent is NOT NULL -- to solve the issues where location is provided with the name of continent
ORDER BY 3,4;

SELECT *
FROM CovidPeriod..CovidVaccinations
WHERE continent is NOT NULL
ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPeriod..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2;

-- Checking total_deaths v/s total_cases
-- Shows the likelihood of dying if you are infected with corona in a particular country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS "DeathPercentage"
FROM CovidPeriod..CovidDeaths
WHERE location = 'India' -- to see cases in India specifically
AND continent is NOT NULL
ORDER BY 1,2;


-- Checking total_cases v/s popultion
-- Shows the likelihood of getting infected with covid in a country
SELECT location, date, total_cases, population, (total_cases/population)*100 AS "PopulationInfectedPercentage"
FROM CovidPeriod..CovidDeaths
-- WHERE location = 'India' 
AND continent is NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS "PopulationInfectedPercentage"
FROM CovidPeriod..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC;

-- Shwoing countries with highest death counts
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidPeriod..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Let's check the record of highest deathCount per continent
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidPeriod..CovidDeaths
WHERE continent is NULL --Wile doing continent as Not null and checking continent column, we are getting wrong numbers :(
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Let's check the cases each day across the world
SELECT date, SUM(new_cases) AS TotalCases, 
		SUM(CAST(new_deaths AS int)) AS TotalDeaths, --new_deaths is a varchar
		SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidPeriod..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Population vs Vaccinations
SELECT dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPeriod..CovidDeaths dea
JOIN CovidPeriod..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPeriod..CovidDeaths dea
JOIN CovidPeriod..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3;
)
SELECT *, RollingPeopleVaccinated/population
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPeriod..CovidDeaths dea
Join CovidPeriod..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- Creating View for later visulaizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPeriod..CovidDeaths dea
Join CovidPeriod..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;