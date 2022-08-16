SELECT *
FROM PortfolioProject..covid_vaccination_

SELECT location, date, total_cases,new_cases, total_deaths, population 
FROM PortfolioProject..covid_deaths_
ORDER BY 1,2

----Looking at the Total Cases VS Total Deaths
----Shows the likelihood of dying if infected by covid in your location

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..covid_deaths_
WHERE location = 'UNITED KINGDOM'
ORDER BY 1,2

----Looking at the Total Cases VS Population
----Shows what percentage of the population got covid
SELECT location, date, total_cases, population,(total_cases/population)*100 AS Infected_Population_Percentage
FROM PortfolioProject..covid_deaths_
WHERE location LIKE '%UNITED KINGDOM%'
ORDER BY 1,2

----Looking at countries with Highest Infection Rate compared to their Population
SELECT location, population,MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Infected_Population_Percentage
FROM PortfolioProject..covid_deaths_
--WHERE location LIKE '%UNITED KINGDOM%'
GROUP BY location, population
ORDER BY Infected_Population_Percentage DESC 



SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..covid_deaths_
--WHERE location LIKE '%UNITED KINGDOM%'
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

----Let's Break Things Down By Continent
--Showing continents with the highest death counts
SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..covid_deaths_
--WHERE location LIKE '%UNITED KINGDOM%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC 


----GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS Death_Percentage
FROM PortfolioProject..covid_deaths_
--WHERE location = 'UNITED KINGDOM'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS Death_Percentage
FROM PortfolioProject..covid_deaths_
--WHERE location = 'UNITED KINGDOM'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


----Looking at Total Population VS Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..covid_deaths_ dea
JOIN PortfolioProject..covid_vaccination_ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




--Using CTE

WITH PopvsVac (continent, location, date , population, new_vaccinations, RollingPeopleVaccinated)
AS
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths_ dea
JOIN PortfolioProject..covid_vaccination_ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac 



--TEMP TABLE 

DROP TABLE IF EXISTS  #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinnations numeric,
RollingPeopleVaccinated numeric,
)


INSERT INTO #PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths_ dea
JOIN PortfolioProject..covid_vaccination_ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentpopulationVaccinated


--Creating view to store data for later visualizations


CREATE VIEW  PercentpopulationVaccinated  AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths_ dea
JOIN PortfolioProject..covid_vaccination_ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentpopulationVaccinated
 