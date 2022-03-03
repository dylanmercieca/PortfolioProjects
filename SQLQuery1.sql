select * from CovidDeaths 
where continent is not null
order by 3,4

--select * from CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths order by 1,2;

 --Looking at Total Cases vs Total Deaths

--select location,date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as "Ratio (%)"
--from CovidDeaths where location like 'Malta' 
--order by 1, 2 ;


---- Looking at Total Cases vs Population

--select location, date, total_cases, population, (total_cases/population)*100 as PercentageCases
--from CovidDeaths where location = 'Malta'
--order by 1,2;

-- Looking at countries with highest infection rate compared to population
select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)*100) as PercentageCases
from CovidDeaths 
--where location = 'Malta'
group by location, population 
order by 4 desc;

-- Looking at countries with highest death rate ratio
select location, max(cast(total_deaths as int)) as TotalDeathCount, population, Max((total_deaths/population)*100) as DeathPercentage
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc;

-- Let's Break things down by Continent
-- Looking at countries with highest death rate ratio
select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS by DATE
select date, SUM(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by date
order by date

-- GLOBAL NUMBERS 
select  SUM(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null

-- USE CTE
With POPvsVAC (location, date, population, new_vaccinations, CumulativeVaccinations)
as
(
-- Looking at Total Population vs Vaccination
Select CD.location, CD.date, population, cv.new_vaccinations, SUM(cast (new_vaccinations as bigint))
OVER (Partition by cd.location order by cd.location, cd.date) as CumulativeVaccinations
--(CumulativeVaccinations/population)*100 as CumulativePercent
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 1, 2
)
select *,(CumulativeVaccinations/population)*100 from POPvsVAC


-- TEMP TABLE
drop table if exists #PercentPopVac
Create Table #PercentPopVac
(
location nvarchar(255), date datetime, population float, new_vaccinations float, CumulativeVaccinations float
)

Insert into #PercentPopVac
Select CD.location, CD.date, population, cv.new_vaccinations, SUM(cast (new_vaccinations as bigint))
OVER (Partition by cd.location order by cd.location, cd.date) as CumulativeVaccinations
-- (CumulativeVaccinations/population)*100 as CumulativePercent
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 1, 2

Select *, (cast(CumulativeVaccinations as float)/(cast(population as float)))*100
from #PercentPopVac order by 1,2


-- Creating View to store data for later visualizations

Create View PercentPopVac as
Select CD.location, CD.date, population, cv.new_vaccinations, SUM(cast (new_vaccinations as bigint))
OVER (Partition by cd.location order by cd.location, cd.date) as CumulativeVaccinations
-- (CumulativeVaccinations/population)*100 as CumulativePercent
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 1, 2

select * from #PercentPopVac;

drop view PercentPopVac;