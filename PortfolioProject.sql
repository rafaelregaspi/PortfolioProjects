Select *
From CovidDeaths
where continent is not null
order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4'

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null

order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where Location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

-- Highest Infection Rate
Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfecteed
From CovidDeaths
where continent is not null
Group by Location, Population
Order by PercentPopulationInfecteed DESC

-- BY CONTINENT
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Countries with Highest Death Country Per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount DESC

-- Showing continents with the Highest Death Count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount DESC


-- Global Numbers
Select  date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%' and continent is not null
Where continent is not null
Group by date
Order by 1,2


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like '%canada%'
Order by 2,3

-- Using CTE for TotalVaccination
With PopvsVac(continent, location, date, population,new_vaccinations,TotalVaccination)
as (

-- Rolling count for new vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as TotalVaccination --, (TotalVaccination/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%canada%'
--Order by 2,3
)
Select *, (TotalVaccination/Population)*100
From PopvsVac

-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccination numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as TotalVaccination --, (TotalVaccination/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%canada%'
Order by 2,3

Select *, (TotalVaccination/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as TotalVaccination --, (TotalVaccination/population)*100
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%canada%'
--Order by 2,3

Select *
From PercentPopulationVaccinated