select * 
from coviddaproject..coviddeaths 
order by 3,4

--select * from 
--coviddaproject..covidvaccinations 
--order by 3,4
select location,date,population,total_cases,new_cases,total_deaths 
from coviddaproject..coviddeaths
order by 1,2

--looking total cases vs total dearths

select location,date,total_cases,total_deaths ,total_deaths/total_cases*100 as dearth_pesrsentage--we can even write it in() as (total_deaths/total_cases)
from coviddaproject..coviddeaths
order by 1,2

--specific location

select location,date,total_cases,total_deaths ,total_deaths/total_cases*100 as dearth_pesrsentage--we can even write it in() as (total_deaths/total_cases)
from coviddaproject..coviddeaths
where  location like '%states'--location='India'
order by 1,2

--total cases vs population


select location,date,total_cases,population,total_cases/population*100 as percentage_of_population_infected--we can even write it in() as (total_deaths/total_cases)
from coviddaproject..coviddeaths
where  location like 'india'--location='India'
order by 1,2


--contries with highest infection rate

select location,population,max(total_cases) as highest_infected_count,max(total_cases/population*100) as highest_percentage_of_population_infected
from coviddaproject..coviddeaths
group by location,population
order by highest_percentage_of_population_infected Desc

--total death count by contry
select location,max(cast(total_deaths as int)) as totaldeath_count
from coviddaproject..coviddeaths
where continent is not null
group by location
order by  totaldeath_count Desc

--by continent
select location,max(cast(total_deaths as int)) as totaldeath_count
from coviddaproject..coviddeaths
where continent is  null
group by location
order by  totaldeath_count Desc

--contries with highest  deaths per population

select location,population,max(total_cases) as highest_infected_count,max(total_deaths) as highest_death_rate,max(total_deaths/population*100) as highest_percentage_of_population_died
from coviddaproject..coviddeaths
group by location,population
order by highest_percentage_of_population_died Desc

--contries with highest death to infected ratio 

select location,population,max(total_cases) as highest_infected_count,max(total_deaths) as highest_death_rate,max(total_deaths)/max(total_cases)*100 as highest_percentage_of_infected_died
from coviddaproject..coviddeaths
group by location,population
order by highest_percentage_of_infected_died Desc

--excluding continents

select location,population,max(total_cases) as highest_infected_count,max(total_deaths) as highest_death_rate,max(total_deaths)/max(total_cases)*100 as highest_percentage_of_infected_died
from coviddaproject..coviddeaths
where continent is not null
group by location,population
order by highest_percentage_of_infected_died Desc


--global data 
--total new cases each day
select date,sum(new_cases ) as total_new_cases,sum(cast(total_deaths as int)) as total_new_deaths ,sum(cast(total_deaths as int))/sum(new_cases )*100 as percent_of_deaths_wrt_new_cases
from coviddaproject..coviddeaths
where continent is not null
group by date
order by date

--total data
select sum(new_cases) as total_new_cases,sum(cast(total_deaths as numeric(20))) as total_new_deaths ,sum(cast(total_deaths as int))/sum(new_cases )*100 as percent_of_deaths_wrt_new_cases
from coviddaproject..coviddeaths
where continent is not null
--group by date
--order by 1,2

--geeting vaccination data and respective population and total cases on that days
select dea.date, dea.continent,dea.location,dea.population,dea.total_cases,vac.total_tests,new_vaccinations
from coviddaproject..coviddeaths  dea --alice
join coviddaproject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3,1

--getting rollling count of vaccinations in each country

select dea.date, dea.continent,dea.location,dea.population,dea.total_cases,vac.total_tests,new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rolling_pepole_vaccinated
from coviddaproject..coviddeaths  dea --alice
join coviddaproject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 3,2

--percentage of people vacicinated

--using cte
with popuvsvaci(date,continent,location,population,new_vaccinations,rolling_pepole_vaccinated)
as
(
select dea.date, dea.continent,dea.location,dea.population,new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rolling_pepole_vaccinated
from coviddaproject..coviddeaths  dea --alice
join coviddaproject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 3,2
)--it kind of creats temp table we cant use order by in creating cte

select *,rolling_pepole_vaccinated/population*100 as percent_of_people_vaccinated
from popuvsvaci




--Temp table
drop table if exists percentofpeoplevaccinated --for exicuting temp table againa and again
create table percentofpeoplevaccinated(
date datetime,
continent varchar(225),
location varchar(225),
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric,

)

insert into percentofpeoplevaccinated

select dea.date, dea.continent,dea.location,dea.population,new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rolling_pepole_vaccinated
from coviddaproject..coviddeaths  dea --alice
join coviddaproject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null

select *,rolling_people_vaccinated/population*100 as percent_of_people_vaccinated
from percentofpeoplevaccinated



--creating view for storing data for later use
--by continent
create view continental_covid_death as
select location,max(cast(total_deaths as int)) as totaldeath_count
from coviddaproject..coviddeaths
where continent is  null
group by location
--order by  totaldeath_count Desc

select * from continental_covid_death