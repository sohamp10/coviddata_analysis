select * from portfolio1 ..covidDeaths
where continent is not null
order by 3,4

--select * from portfolio1 ..covid_vactinations
--order by 3,4

--select data
select location, date, total_cases,new_cases, total_deaths, population 
from portfolio1 ..covidDeaths
order by 1,2

--total cases vs total deaths
select location, date, total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentge 
from portfolio1 ..covidDeaths
where continent is not null 
order by 1,2

---total cases vs population
select location, date, total_cases,new_cases, total_deaths,population, (total_cases/population)*100 as case_percentage
from portfolio1 ..covidDeaths
where continent is not null
order by 1,2

-- looking to countries highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infected_country,
(Max(total_cases)/population)*100 as Total_infect_per_pop
from portfolio1 ..covidDeaths
where continent is not null
group by location, population
order by Total_infect_per_pop desc

-- countries with highest death rate
select location, population, MAX(cast(total_deaths as int)) as highest_death_country,
(Max(total_deaths)/population)*100 as death_rate
from portfolio1 ..covidDeaths
where continent is not null
group by location, population
order by highest_death_country desc

-- things break down by continent
select continent, MAX(cast(total_deaths as int)) as highest_death
from portfolio1 ..covidDeaths
where continent is not null
group by continent
order by highest_death desc

--global numbers of new case and death by date
select date, sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death from 
portfolio1 ..covidDeaths
where new_cases is not null
group by date
order by date

--total global numbers
select sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage from 
portfolio1 ..covidDeaths
where continent is not null

--join two table
select population  from portfolio1 ..covidDeaths dea
join portfolio1 ..covid_vactinations vac 
on dea.location = vac.location 
and dea.date = vac.date

-- vactination per population
select dea.continent,vac.location, dea.date, dea.population , vac.new_vaccinations  
from portfolio1 ..covidDeaths dea
join portfolio1 ..covid_vactinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- looking at total population vs vactination

select dea.continent,vac.location, dea.date, dea.population , vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingdata
from portfolio1 ..covidDeaths dea
join portfolio1 ..covid_vactinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3		

-- use cte ( common table expression)
with povsvac (continent, location, dATE, POPULATION, new_vac,rolling_data)
as
(
select dea.continent,vac.location, dea.date, dea.population , vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingdata
from portfolio1 ..covidDeaths dea
join portfolio1 ..covid_vactinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
	
)

select *, (rolling_data/POPULATION)*100 as percentage_vac from povsvac


--Temp table

create table PerPopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
rollingdata numeric
)

Insert into PerPopvac
select dea.continent,vac.location, dea.date, dea.population , vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingdata
	from portfolio1..covidDeaths dea
	join portfolio1 ..covid_vactinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (rollingdata/population)*100 as percentage_vac from PerPopvac

