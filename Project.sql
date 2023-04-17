SELECT *
FROM Project..CovidDeaths
ORDER BY 3,4

-- SELECT Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths
Order by 1,2

--Looking total cases vs Total Death
Select Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
From Project..CovidDeaths
Where location like '%States%'
Order by 1,2

-- Show likelihood of dying if you contract covid in your country

--Looking at Total cases vs Population
Select Location, date, total_cases, population, ROUND((total_cases/population)*100,2) as DeathPercentage
From Project..CovidDeaths
Where location like '%States%'
Order by 1,2

--Looking at Countries with Highest Infection rate	compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount,  ROUND(MAX((total_cases/population))*100,2) as PercentPopulationInfected
From Project..CovidDeaths
--Where location like '%States%'
GROUP BY location, population
ORDER By PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per population
Select Location, MAX(Cast(total_deaths as int)) as TotalDeathcount
From Project..CovidDeaths
--Where location like '%States%'
Where continent is not null
GROUP BY location
ORDER By TotalDeathcount Desc

-- LET's Break THINGS DOWN BY CONTINENT
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathcount
From Project..CovidDeaths
--Where location like '%States%'
Where continent is not null
GROUP BY continent
ORDER By TotalDeathcount Desc

-- Showing continent with Highest death count per population
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathcount
From Project..CovidDeaths
--Where location like '%States%'
Where continent is not null
GROUP BY continent
ORDER By TotalDeathcount Desc


--GLOBAL NUMBERS
Select SUM(new_cases)as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum (New_Cases)*100 as DeathPercentage
FROM Project..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea. population, vac. new_vaccinations
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac. location
	and dea.date = vac. date
Where dea.continent is not null
order by 1,2,3

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations, SUM (Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location) 
as RollingPeopleVaccination
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac. location
	and dea.date = vac. date
Where dea.continent is not null
order by 1,2,3

---- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations, SUM (Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location) 
as RollingPeopleVaccination
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac. location
	and dea.date = vac. date
Where dea.continent is not null
--order by 1,2,3
)

Select *, (RollingPeopleVaccination/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations, SUM (Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location) 
as RollingPeopleVaccinated
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac. location
	and dea.date = vac. date
--Where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
USE Project
GO
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations, SUM (Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location) 
as RollingPeopleVaccinated
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac. location
	and dea.date = vac. date
Where dea.continent is not null
--order by 1,2,3

Select *
FROM PercentPopulationVaccinated
