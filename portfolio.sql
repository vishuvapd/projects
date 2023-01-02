select *
from COVIDDEATH
where continent is not NULL
order by 3,4;


--select *
--from COVIDVACCINATION
--order by 3,4;

SELECT location,dates, total_cases, new_cases, total_deaths, population
from coviddeath
where continent is not NULL
order by 1,2;

SELECT location,dates, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from coviddeath
where continent is not NULL
where location like '%United States%'
order by 1,2;

SELECT location,dates, total_cases, population, (total_cases/population)*100 as PrecentPopulationInfected
from coviddeath
where location like '%India%'
order by 1,2;

SELECT location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PrecentPopulationInfected
from coviddeath
--where location like '%India%'
where continent is not NULL
group by population, location
order by PrecentPopulationInfected desc;

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
--where location like '%India%'
where continent is not NULL
group by location
order by TotalDeathCount desc;

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
--where location like '%India%'
where continent is not NULL
group by continent
order by TotalDeathCount desc;

SELECT  sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as toatl_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from coviddeath
--where location like '%India%'
where continent is not NULL
--group by dates
order by 1,2;


select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
from coviddeath dea
join covidvaccination vac
    on dea.location = vac.location
    and dea.dates = vac.dates
where dea.continent is not NULL
order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, dates, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.dates) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeath dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.dates = vac.dates
where dea.continent is not null 
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 as vaccinationrate
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Dates datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations,int)) OVER (Partition by dea.Location Order by dea.location, dea.Dates) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.dates = vac.dates
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations,int)) OVER (Partition by dea.Location Order by dea.location, dea.Dates) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.dates = vac.dates
where dea.continent is not null 





