select *
From COVID19ANALYSIS..CovidDeaths
order by 3,4

select *
From COVID19ANALYSIS..CovidDeaths
Where continent is null
order by 3,4

select *
From COVID19ANALYSIS..CovidDeaths
Where continent is not null
order by 3,4


--select *
--From COVID19ANALYSIS..CovidVaccinations  
--order by 3,4

--First step: Selection of data for analysis and ordering by location and date

Select location, date, total_cases, new_cases, total_deaths,population
From COVID19ANALYSIS..CovidDeaths
Where continent is not null
order by 1,2

---- Exploring the Total Cases vs. the Total Deaths(a percentage)
----We need to convert the data type of our total_cases and total_deaths column from nvarchar to int in order to order a percentage

--EXEC  sp_help 'dbo.covidDeaths';

--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN total_Deaths int

--ALTER TABLE dbo.CovidDeaths
--ALTER COLUMN total_Deaths int
--Ended up using a exact downloaded data set from ATA from Github as the data appears to have changed greatly
--Another method to achieve this is to  use (cast("column name" as int))

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From COVID19ANALYSIS..CovidDeaths
Where continent is not null 
order by 1,2

-- Exploring the Total Cases vs. the Total Deaths(a percentage)
---- This shows the likelihood of dying if you are in Germany

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From COVID19ANALYSIS..CovidDeaths
Where location like '%Germany%' and continent is not null
order by 1,2


---Looking at the Total Cases Vs the Population(Percentage)
Select location, date, population, total_cases,(total_cases/population)*100 As PercentagePopulationInfected
From COVID19ANALYSIS..CovidDeaths
Where location like '%Germany%' and continent is not null 
order by 1,2

-- Looking at countries with the highest infection rate compared to the population

Select location, population, Max(total_cases) As HighestInfectionCount, Max(total_cases/population)*100 As PercentPopulationInfected
From COVID19ANALYSIS..CovidDeaths
-- Where location like '%Germany%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected DESC

-- Showing the countries with the Highest Death Count per Population
Select location, Max(Population) as Population, Max(Cast(Total_Deaths as int)) As TotalDeathCount
From COVID19ANALYSIS..CovidDeaths
--Where location like '%Germany%'
Where continent is not null
Group by location
Order by TotalDeathCount DESC

Select location, Max(Population) as Population, Max(Cast(Total_Deaths as int)) As TotalDeathCount
From COVID19ANALYSIS..CovidDeaths
--Where location like '%Germany%'
Where continent is null
Group by location
Order by TotalDeathCount DESC


--LET'S BREAK THINGS UP BY CONTINENTS
 -- Showing the continents with the Highest Death Count per Population

Select continent, Max(Cast(Total_Deaths as int)) As TotalDeathCount
From COVID19ANALYSIS..CovidDeaths
--Where location like '%Germany%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC
 

 -- GLOBAL DAILY NUMBERS


 Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_Cases))*100 As DeathPercentage
From COVID19ANALYSIS..CovidDeaths
--Where location like '%Germany%' 
Where continent is not null
Group by date
order by 1,2

-- Global Total Numbers for the period under Review

 Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_Cases))*100 As DeathPercentage
From COVID19ANALYSIS..CovidDeaths
--Where location like '%Germany%' 
Where continent is not null
--Group by date
order by 1,2



--Looking at total Population vs Vaccination


Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.Location, cd.date) As RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)/cd.population * 100
From COVID19ANALYSIS..CovidDeaths as cd
Join COVID19ANALYSIS..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Order by 2, 3


-- USING CTE

With PopvsVac (Continent, location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.Location, cd.date) As RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)/cd.population * 100
From COVID19ANALYSIS..CovidDeaths as cd
Join COVID19ANALYSIS..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
--Order by 2, 3
)
Select * , (RollingPeopleVaccinated/population) * 100 as PercentageVaccinated
From PopvsVac

--TEMP TABLES

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.Location, cd.date) As RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)/cd.population * 100
From COVID19ANALYSIS..CovidDeaths as cd
Join COVID19ANALYSIS..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
--Where cd.continent is not null
--Order by 2, 3

Select * , (RollingPeopleVaccinated/population) * 100 as PercentageVaccinated
From #PercentagePopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW

PercentagePopulationVaccinatedNEW as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.Location, cd.date) As RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)/cd.population * 100
From COVID19ANALYSIS..CovidDeaths as cd
Join COVID19ANALYSIS..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
--Order by 2, 3




--Selecting From Views

CREATE VIEW GlobalTotalNumbers as

 Select 
 SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_Cases))*100 As DeathPercentage
From COVID19ANALYSIS..CovidDeaths
Where continent is not null
--Group by date
--order by 1,2

