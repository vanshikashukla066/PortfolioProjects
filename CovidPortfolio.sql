Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order by 1,2

--looking at total cases vs population 
--show what percentage of population got covid
Select location, date, Population, total_cases,  (total_cases/Population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order by 1,2

--looking at countries with highest infection rate compared to population 
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/Population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
Order by  InfectedPopulationPercentage desc

--showing countries with Highest Death count per popultaion
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by  TotalDeathCount desc


--Let's break things down by continents
--showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by  TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,   SUM(cast(new_deaths as int))/SUM(new_cases)*100   as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,   SUM(cast(new_deaths as int))/SUM(new_cases)*100   as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--looking at total population vs vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null
Order by 2,3


--USE CTE
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


--Temp table

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


--Creating view to store data for later visualization
Create view PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, 
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths Join PortfolioProject..CovidVaccinations as vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
Where deaths.continent is not null


Select *
From PercentPopulationVaccinated