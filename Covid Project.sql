select * 
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
order by 3,4

--select * 
--from PortfolioProjects..CovidvaccinationsDataset$
--where continent is not null
--order by 3,4

--select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
order by 1,2

--total cases vs total deaths
--shows likelihood of dying

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeathsDataset$
where location like '%canada%' and continent is not null
order by 1,2

--total cases vs population
--shows percentage affected by covid
select location, date, total_cases, population, (total_cases/population)*100 as AffectedPercentage
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
--where location like '%canada%'
order by 1,2

--highest infection rates compared to population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
--where location like '%canada%'
group by location, population
order by PercentOfPopulationInfected desc

--countries with highest death count per population
select location, max(total_deaths) as HighestDeathCount, population, max((total_deaths/population))*100 as PercentOfPopulationDied
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
--where location like '%canada%'
group by location, population
order by PercentOfPopulationDied desc

--countries with highest death count 
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
--where location like '%canada%'
group by location
order by HighestDeathCount desc

--data by continent

--continents with highest death count 
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
--where location like '%canada%'
group by continent
order by HighestDeathCount desc

--global numbers
select date, SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
group by date
order by 1,2

--total global numbers
select SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProjects..CovidDeathsDataset$
where continent is not null
order by 1,2

--join tables

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProjects..CovidDeathsDataset$ dea
join PortfolioProjects..CovidvaccinationsDataset$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeCount
from PortfolioProjects..CovidDeathsDataset$ dea
join PortfolioProjects..CovidvaccinationsDataset$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopVsVac (Continent, Location, Date, population, new_vaccinations, CumulativeCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeCount
from PortfolioProjects..CovidDeathsDataset$ dea
join PortfolioProjects..CovidvaccinationsDataset$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (CumulativeCount/population)*100
from PopVsVac

--create temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
CumulativeVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccinated
from PortfolioProjects..CovidDeathsDataset$ dea
join PortfolioProjects..CovidvaccinationsDataset$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (CumulativeVaccinated/population)*100
from #PercentPopulationVaccinated


use PortfolioProjects
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccinated
from PortfolioProjects..CovidDeathsDataset$ dea
join PortfolioProjects..CovidvaccinationsDataset$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

