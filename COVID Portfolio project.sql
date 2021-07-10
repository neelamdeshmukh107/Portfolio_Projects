SELECT * 
FROM Portfolio_Project..Coviddeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM Portfolio_Project..Covidvaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Coviddeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--Likelihood of a person dying if he gets infected by covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..Coviddeaths
WHERE location='India'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got infected by covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM Portfolio_Project..Coviddeaths
--WHERE location= 'India'
order by 1,2

--Looking at Countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population)*100) as InfectionPercentage
FROM Portfolio_Project..Coviddeaths
Group by location, population
order by InfectionPercentage desc

--Showing the countries with the highest deaths per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..Coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..Coviddeaths
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date )
AS RollingPeopleVaccinated
FROM Portfolio_Project..Coviddeaths dea
JOIN Portfolio_Project..Covidvaccination vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Coviddeaths dea
Join Portfolio_Project..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Coviddeaths dea
Join Portfolio_Project..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Coviddeaths dea
Join Portfolio_Project..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * FROM PercentPopulationVaccinated

