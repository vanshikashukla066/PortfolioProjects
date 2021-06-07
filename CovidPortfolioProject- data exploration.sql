 /*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
 
 
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, Population, total_cases,  (total_cases/Population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/Population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
Order by  InfectedPopulationPercentage desc

-- Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by  TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by  TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,   SUM(cast(new_deaths as int))/SUM(new_cases)*100   as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,   SUM(cast(new_deaths as int))/SUM(new_cases)*100   as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
From POPvsVAC 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null


Select *
From PercentPopulationVaccinated
