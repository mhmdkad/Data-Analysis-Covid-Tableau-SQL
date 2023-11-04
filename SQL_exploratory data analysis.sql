--select *
--from CovidProject..CovidDeaths$
--order by 3, 4

--select *
--from CovidProject..CovidVaccinations$
--order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
order by 1, 2

-- Tableau report 1
-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
where continent is not null 
order by 1,2

-- Tableau report 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Tableau report 3
-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- Tableau report 4
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc

-- or

Select Location, Population, date, (total_cases) as HighestInfectionCount,  ((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
order by PercentPopulationInfected desc


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac