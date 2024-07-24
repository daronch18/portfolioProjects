select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;



--select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4;


--select the data we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;


-- looking at total cases vs totl deaths
-- show the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at the total cases vs the population

select Location, date, total_cases, population,(total_cases/population)*100 as CasesxPopulation
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--what country has the highest infection rate/population

select Location, max(total_cases) highest_infection_rate,
	population,(max(total_cases)/population)*100 as PercentofPopulationInfect
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentofPopulationInfect desc


--highest death per population

select Location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc


-- by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



--total pop vs vacc

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac



-- temp table

drop table if exists #percentPopVacc
create table #percentPopVacc
(
continent nvarchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #percentPopVacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentPopVacc



-- creating view to store data for later visualization
create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3









