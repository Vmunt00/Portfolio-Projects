Select *
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From UnitedWaySampleProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Likleyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
Where location like '%states%'
order by 1,2

-- Total cases vs Population
-- Percentage of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
order by 1,2


-- Countries with highest infection rate compared to Population

Select location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death count per Population

Select location, MAX (cast(total_deaths as int)) as TotaldDeathCount
From UnitedWaySampleProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by location
order by TotaldDeathCount desc


-- By Continent

Select continent, MAX (cast(total_deaths as int)) as TotaldDeathCount
From UnitedWaySampleProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotaldDeathCount desc


---Continents with the Highest Death Count per Population
Select continent, MAX (cast(total_deaths as int)) as TotaldDeathCount
From UnitedWaySampleProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotaldDeathCount desc

--Global Numbers

Select  SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM( cast(new_deaths as int))/SUM (New_Cases)*100 as DeathPercentage
From UnitedWaySampleProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Total Population VX Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,sum(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From UnitedWaySampleProject..CovidDeaths$ dea
Join UnitedWaySampleProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---CTE

With PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,sum(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From UnitedWaySampleProject..CovidDeaths$ dea
Join UnitedWaySampleProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationVsVaccination

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,sum(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From UnitedWaySampleProject..CovidDeaths$ dea
Join UnitedWaySampleProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View to Store Data

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,sum(Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From UnitedWaySampleProject..CovidDeaths$ dea
Join UnitedWaySampleProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated