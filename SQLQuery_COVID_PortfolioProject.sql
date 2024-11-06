--Select * 
--From Portfolio_Projects..covid_vaccination$
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Projects..covid_deaths$
Order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Likelihood of Dying if infected with covid in Nigeria

Select location, date, total_cases, total_deaths, (Convert(Decimal, total_deaths) / total_cases) * 100 as DeathToCasePercentage
From Portfolio_Projects..covid_deaths$
Where location = 'nigeria'
Order by 1,2

-- Looking at the total cases vs population
-- Shows the percentage of population got covid in Nigeria

Select location, date, total_cases, population, (total_cases / population)*100 as CasesToPopulationPercentage
From Portfolio_Projects..covid_deaths$
where continent is not null and location = 'nigeria'
Order by 1,2

-- looking at the Countries with the highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases) / population * 100 as HighestInfectionRate
From Portfolio_Projects..covid_deaths$
Group by location, population
Order by HighestInfectionRate desc

-- Showing Countries with the Highest Death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Projects..covid_deaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continent with the Highest Death Count


Select continent, Max(cast(total_cases as int)) as TotalCasePerContinent, Max(cast(total_deaths as int)) as TotalDeathPerContinent
From Portfolio_Projects..covid_deaths$
Where continent is not null
Group by continent
Order by TotalCasePerContinent desc



-- Global Numbers

Select Sum(new_cases) as Totalcases, Sum(cast(new_deaths as int)) as TotalDeaths, 
		Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Portfolio_Projects..covid_deaths$
Where continent is not null
--Group by date
Order by 1,2


Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	Sum(Convert(Int, vaccine.new_vaccinations)) over (Partition by death.location Order by death.location,death.date) as RollingVaccination
	
From Portfolio_Projects..covid_deaths$ death
Join Portfolio_Projects..covid_vaccination$ vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
Order by 2,3

-- USE A CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccination)
as 
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	Sum(Convert(Int, vaccine.new_vaccinations)) over (Partition by death.location Order by death.location,death.date) as RollingVaccination
	
From Portfolio_Projects..covid_deaths$ death
Join Portfolio_Projects..covid_vaccination$ vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--Order by 2,3
)
Select *, (RollingVaccination/population)*100 as percentVaccinated
From PopvsVac

--  Temp Table

DROP TABLE IF EXISTS #percentVaccinated
Create Table #percentVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingVaccination numeric
)

Insert into #percentVaccinated

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	Sum(Convert(Int, vaccine.new_vaccinations)) over (Partition by death.location Order by death.location,death.date) as RollingVaccination
	
From Portfolio_Projects..covid_deaths$ death
Join Portfolio_Projects..covid_vaccination$ vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
	where death.continent is not null
--Order by 2,3

Select *, (RollingVaccination/population)*100
From #percentVaccinated


-- Creating View to store data

Create View percentPopulationVaccinated as 

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	Sum(Convert(Int, vaccine.new_vaccinations)) over (Partition by death.location Order by death.location,death.date) as RollingVaccination
	
From Portfolio_Projects..covid_deaths$ death
Join Portfolio_Projects..covid_vaccination$ vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
	where death.continent is not null
--Order by 2,3

Select *
From percentPopulationVaccinated