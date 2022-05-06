-- DATA EXPLORATIONS

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

-- Select data that wer are going to be using


SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%' AND
continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs population

SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population) * 100 AS CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Let's break things down by continent


--SELECT
--	continent,
--	MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths$
--WHERE continent IS NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

-- en este resultado tenemos un problema, no son confiables los datos
-- el resultado para NorthAmerica luce igual que el de US es decir que no esta contando Canada

--ESTE ES EL CORRECTO!!
SELECT
	location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
-- este podria ser el correcto porque los que tienen el continente NULL
-- tienen el nombre del continente en la locacion


-- Showing countries with highest death count per population

SELECT
	location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers


SELECT
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- TABLE COVID VACCINATIONS

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations$

--JOIN THE TWO TABLES

--looking at total population vs vaccinations

--recuerde que population esta en la tabla de la izquierda
-- y las info de vacunas esta en la tabla de la izquierda
-- new vaccinations per day

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
FROM PortfolioProject.dbo.CovidDeaths$ dea
INNER JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- with cte
-- todo esto hay que correrlo junto

WITH PopulationVsVaccinations (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
INNER JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.continent IS NOT NULL
)

-- % de personas vacunadas
SELECT *,(RollingPeopleVaccinated/population)* 100 AS PercentOfPeopleVaccinated
FROM PopulationVsVaccinations
ORDER BY 2,3

---- % de personas vacunadas
--SELECT *,(RollingPeopleVaccinated/population)* 100 AS PercentOfPeopleVaccinated
--FROM PopulationVsVaccinations
--WHERE location LIKE '%COLOMBIA%'
--ORDER BY 2,3



-- TEMP TABLE
DROP TABLE if exists #PercentPeopleVaccinated
-- DROP TABLE #PercentPeopleVaccinated
-- este drop se incluye porque si modificamos esta tabla y la cargamos va a salir un error
-- el error que saldra es que ya hay una tabla con este nombre
-- asi que si colocamos el DROP TABLE al inicio lo que pasara es que se eliminara la existente y creara otra

CREATE TABLE #PercentPeopleVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)




INSERT INTO #PercentPeopleVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
INNER JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)* 100 AS PercentOfPeopleVaccinated
FROM #PercentPeopleVaccinated
ORDER BY 2,3

-- CREATING VIEW

CREATE VIEW PercentPeopleVaccinated as
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
INNER JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.continent IS NOT NULL

SELECT *
FROM PercentPeopleVaccinated

-- Hello world
-- this is awesome
