/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Coviddataset..CovidDeaths
Where continent is not null 
order by 3,4


-- The code below  selects Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Coviddataset..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country using Nigeria  as a case study 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Coviddataset..CovidDeaths
Where location like '%Nigeria%' 
order by 1,3




-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in Nigeria 

Select Location, date, total_cases,total_deaths, population, (total_deaths/population)*100 as DeathPercentage
From Coviddataset..CovidDeaths
Where location like '%Nigeria%' 
order by 1,3



-- Countries in Africa continent with Highest Infection Rate compared to their Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount
From Coviddataset..CovidDeaths
where continent like '%Africa%'
Group by Location, Population
order by HighestInfectioncount desc



-- Countries with Highest Death Count per Population in Africa

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Coviddataset..CovidDeaths
--Where location like '%states%'
Where continent like '%Africa%'
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Coviddataset..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Number of total cases and total deaths in Africa

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Coviddataset..CovidDeaths
--African continent 
where continent like  '%Africa%'
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coviddataset..CovidDeaths D
Join Coviddataset..CovidVaccinations V
	On D.location = V.location
	and D.date = D.date
where D.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coviddataset..CovidDeaths dea
Join Coviddataset..CovidVaccinations vac
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percent_of_PopulationVaccinated
Create Table #Percent_of_PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_of_PopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coviddataset..CovidDeaths D
Join Coviddataset..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where d.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #Percent_of_PopulationVaccinated




-- Creating View to store data for later visualizations

Create View Percent_of_PopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coviddataset..CovidDeaths d
Join Coviddataset..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
