SELECT *
FROM Portfolioproject..CovidDeaths
order by 3,4

--SELECT *
--FROM Portfolioproject..CovidVaccinations
--order by 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolioproject..CovidDeaths
--order by 1,2


--Total Cases VS Total Deaths

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM Portfolioproject..CovidDeaths
--WHERE location like '%brunei%'
--order by 1,2


--Total Cases VS Population

--SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
--FROM Portfolioproject..CovidDeaths
--Where location like '%brunei%'
--order by 1,2


--Countries with highest infection rate compared to population

--SELECT location, population, MAX(total_cases) HighestInfectionRate, MAX((total_cases/population))*100 as 
--PercentagePopulationInfected
--FROM Portfolioproject..CovidDeaths
--Group by location, population
--order by 4 desc


--Countries with Highest total death

--SELECT location, population, MAX(cast(total_deaths as int)) TotalDeathCount
--FROM Portfolioproject..CovidDeaths
--WHERE continent is not null
--group by location, population
--order by 3 desc


--Continents with highes total death

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent is not null 
group by continent
order by 2 desc


--Global numbers

SELECT SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths
, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent is not null


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3,4

--USE CTE

WITH VacPerPop (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3,4
)
select *, (RollingPeopleVaccinated/Population)*100 As percentageVaccinated
from VacPerPop


--Temp Table

Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3,4

select *, (RollingPeopleVaccinated/Population)*100 As percentageVaccinated
from #percentpopulationvaccinated


--creating views for later visualization

Create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3,4