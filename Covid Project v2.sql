Select *
From ProjectPortfolio..CovidDeaths$
Order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations$
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths from Covid in Australia
-- Shows the mortality rate of Covid 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where location like 'Australia'
Order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as PositiveCasesPercentage
From ProjectPortfolio..CovidDeaths$
Where location like 'Australia'
Order by 1,2

-- Looking at Country Infection Rates compared to Population
Select Location, population, MAX(total_cases) as MaxPositiveCases, MAX((total_cases/population))*100 as PositiveCasesPercentage
From ProjectPortfolio..CovidDeaths$
Group by Location, Population
Order by PositiveCasesPercentage desc

-- Looking at Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths -- cast as int to avoid error
From ProjectPortfolio..CovidDeaths$
Where continent is not null -- Some entries list continents as locations
Group by Location
Order by TotalDeaths desc
-- Showing Continents with Highest Death Count
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From ProjectPortfolio..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeaths desc

-- Global Numbers
Select date, SUM(new_cases) as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2
-- Total Numbers
Select SUM(new_cases) as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where continent is not null
Order by 1,2

-- Joining Tables
Select *
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
-- Need to order by location and date otherwise it will just add up the total by location
, (RollingVaccinationCount/population)*100
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
-- Does not work because we cannot use a column we just created, therefore we need to either use CTE or Create a Temp Table


-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinationCount/Population)*100 as RollingVacPercentage
From PopvsVac



-- Temp Table
Drop Table if exists #PercentPopulationVaccinated -- Incase if you want to alter the table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVaccinationCount/Population)*100 as RollingVacPercentage
From #PercentPopulationVaccinated


-- Creating Views to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From ProjectPortfolio..CovidDeaths$ dea
Join ProjectPortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Create View AustraliaMortality as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where location like 'Australia'

Create View AustraliaCases as
Select Location, date, total_cases, population, (total_cases/population)*100 as PositiveCasesPercentage
From ProjectPortfolio..CovidDeaths$
Where location like 'Australia'

Create View GlobalCases as
Select Location, population, MAX(total_cases) as MaxPositiveCases, MAX((total_cases/population))*100 as PositiveCasesPercentage
From ProjectPortfolio..CovidDeaths$
Group by Location, Population

Create View ContinentDeaths as
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From ProjectPortfolio..CovidDeaths$
Where continent is not null
Group by continent

Create View GlobalDeaths as
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths -- cast as int to avoid error
From ProjectPortfolio..CovidDeaths$
Where continent is not null -- Some entries list continents as locations
Group by Location






