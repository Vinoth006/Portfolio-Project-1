create database PortfolioProject

use PortfolioProject
select * 
from PortfolioProject ..Covid_Death
where continent is not null
order by 3,4;


select * 
from PortfolioProject ..Covid_Vaccination
order by 3,4;




--Looking total case vs total deaths
select [location],[date],[total_cases],[total_deaths], ([total_deaths]/[total_cases])*100 as deathprescentage
from PortfolioProject..Covid_death
where location like '%ind%'
and continent is not null
order by 1,2;

-- Total_Deaths by location --
--max give the sum funtion --
-- to convert the data type use CAST --
select [location],max(cast(total_deaths as int)) as Total_Deaths
from PortfolioProject ..Covid_death
where continent is null
group by location
order by Total_Deaths desc


--Total Deaths by Continent--
select [location], MAX(cast(total_deaths as int)) as Total_deathsbycontinent
from PortfolioProject ..Covid_death
where continent is null
group by location
order by Total_deathsbycontinent desc

--Day daily cases--
select [date], SUM(new_cases) as Total_case from PortfolioProject..Covid_death
where continent is not null
group by date
order by 1  desc

-- Over all cases --
select [date] , SUM([new_cases]) as total_cases,
SUM(cast([new_deaths] as int)) as total_death,
SUM(cast([new_deaths] as int)) / SUM([new_cases])*100 as deathpercentage
from PortfolioProject..Covid_death
where [continent] is not null
group by date
order by 1,2 desc;

-- Rolling_people_vaccinated --
select dea.date,dea.continent,dea.location,vac.population,vac.new_vaccinations,
sum (convert (int , vac.new_vaccinations)) over (partition by dea.[location] order by dea.location,dea.date) as Rolling_people_vaccinated
from PortfolioProject ..Covid_death dea
join PortfolioProject ..Covid_Vaccination vac
  on dea.date = vac.date
  and dea.location = vac.location
where dea.continent is not null
order by 3,2 


-- use CTE
with popvsVac (Date,continent,Location,population, New_Vaccinations,RollingPeoplevacctionated)
as
(

select dea.date,dea.continent,dea.location,vac.population,vac.new_vaccinations,
sum (convert (int , vac.new_vaccinations)) over (partition by dea.[location] order by dea.location,dea.date) as Rolling_people_vaccinated
from PortfolioProject ..Covid_death dea
join PortfolioProject ..Covid_Vaccination vac
  on dea.date = vac.date
  and dea.location = vac.location
where dea.continent is not null
--order by 3,2 (we can't use order by)
)
select *,(RollingPeoplevacctionated/population)*100 as 
from popvsVac




--create Table --
Drop Table if exists #percentpopulationVaccinated
create Table #percentpopulationVaccinated
(
date       datetime,
continent  nvarchar(255),
Location   nvarchar(255),
Population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)


insert into #percentpopulationVaccinated
select dea.date,dea.continent,dea.location,vac.population,vac.new_vaccinations,
sum (convert (int , vac.new_vaccinations)) over (partition by dea.[location] order by dea.location,dea.date) as Rolling_people_vaccinated
from PortfolioProject ..Covid_death dea
join PortfolioProject ..Covid_Vaccination vac
  on dea.date = vac.date
  and dea.location = vac.location
 where dea.continent is not null

select *,(Rollingpeoplevaccinated/population)*100  
from #percentpopulationVaccinated


-- Creating View--
create view PercentPopulationVaccinated as
select dea.date,dea.continent,dea.location,vac.population,vac.new_vaccinations,
sum (convert (int , vac.new_vaccinations)) over (partition by dea.[location] order by dea.location,dea.date) as Rolling_people_vaccinated
from PortfolioProject ..Covid_death dea
join PortfolioProject ..Covid_Vaccination vac
  on dea.date = vac.date
  and dea.location = vac.location
 where dea.continent is not null
