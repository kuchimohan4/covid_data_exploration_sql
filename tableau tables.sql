--1st total death percentage 
select sum(new_cases) as total_cases,sum(cast(new_deaths as int )) as tpotal_deaths, sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercentage
from coviddaproject..coviddeaths
where continent is not null

--2nd total death count per continent
--by continent
select location,max(cast(total_deaths as int)) as totaldeath_count
from coviddaproject..coviddeaths
where continent is  null
and location  in ('Europe','North america','Asia','South america','africa','Oceania')
group by location
order by  totaldeath_count Desc


-- 3ed contries  with highest in fection rate
select location,population,max(total_cases) as highest_infected_count,max(total_cases/population*100) as percentage_of_population_infected
from coviddaproject..coviddeaths
where continent is not null 
group by location,population
order by percentage_of_population_infected Desc






--global data 
--4th  total pecentage of population infected 
select date,location,population,max(total_cases) as highest_infected_count,max(total_cases/population*100) as percentage_of_population_infected
from coviddaproject..coviddeaths
group by location,population,date
order by location,percentage_of_population_infected  Desc