--SELECT TOP 10 *
--FROM ['Covid deaths$']

--Selecting the Data relevant for this project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project (COVID)]..['Covid deaths$']
ORDER BY 1,2

-- Exploring Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE location LIKE 'Nigeria'
ORDER BY 1,2 DESC

-- Looking at the Total Cases vs Population
-- Shows percentage of Nigerian population got infected with the COVID virus
SELECT location, date, total_cases, total_deaths, population, (total_cases/population) * 100 AS case_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE location LIKE 'Nigeria'
ORDER BY 1,2 DESC

-- Exploring countries with highest infection rate as compared with population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population)) * 100 AS case_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
--WHERE location LIKE 'Nigeria'
GROUP BY Location, population
ORDER BY case_percentage DESC

-- Exploring countries with highest death count compared with population

SELECT location, population, MAX(total_deaths) AS Highest_death_count, MAX((total_deaths/population)) * 100 AS death_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
GROUP BY Location, population
ORDER BY death_percentage DESC

-- Showing countries with highest death count

SELECT Location, MAX(cast(Total_deaths as int)) AS Total_death_count
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent IS NOT Null
GROUP BY Location
ORDER BY Total_death_count DESC

-- SUMMARIZING BY CONTINENT
-- Showing Continent with the highest death count
SELECT continent, MAX(cast(Total_deaths as int)) AS Total_death_count
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent IS NOT Null
GROUP BY continent
ORDER BY Total_death_count DESC

-- Removing the global summaries, and ust showing the countires, in the result
SELECT location, MAX(cast(Total_deaths as int)) AS Total_death_count
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent IS NOT Null
GROUP BY location
ORDER BY Total_death_count DESC

-- Showing total_death_count summaries per continent
SELECT location, MAX(cast(Total_deaths as int)) AS Total_death_count
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent IS Null
GROUP BY location
ORDER BY Total_death_count DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS Death_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent is NOT NULL
GROUP BY date
ORDER BY Death_percentage DESC

--SHOWING VALES FOR OVERALL TOTAL CASES, DEATHS AND PERCENTAGES
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS Death_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent is NOT NULL
ORDER BY Death_percentage DESC

-- CREATING A NEW TABLE BY JOINING Covid_Death and Covid_Vaccinations Table
SELECT TOP 50 *
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
AND Cov_dea.date = Cov_Vac.date 

--LOOKING AT TOTAL POPULATION vs VACCINATIONS
--Showing the relevant columns needed for the query
SELECT Cov_dea.continent, Cov_dea.location, Cov_dea.date, Cov_dea.population, Cov_Vac.new_vaccinations
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
WHERE Cov_dea.continent is NOT NULL
AND Cov_dea.date = Cov_Vac.date 
ORDER BY 1,2,3

SELECT Cov_dea.continent, Cov_dea.location, Cov_dea.date, Cov_dea.population, Cov_Vac.new_vaccinations,
SUM (Cast (Cov_vac.new_vaccinations as bigint)) OVER (Partition By  Cov_dea.location ORDER BY Cov_dea.location, Cov_dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
AND Cov_dea.date = Cov_Vac.date 
WHERE Cov_dea.continent is NOT NULL
ORDER BY 2,3


--CREATING A CTE TO COMPARE ROLLING PEOPLE VACCINATED NUMBERS VS POPULATION

With PopvsVacc (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT Cov_dea.continent, Cov_dea.location, Cov_dea.date, Cov_dea.population, Cov_Vac.new_vaccinations,
SUM (Cast (Cov_vac.new_vaccinations as bigint)) OVER (Partition By  Cov_dea.location ORDER BY Cov_dea.location, Cov_dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
AND Cov_dea.date = Cov_Vac.date
WHERE Cov_dea.continent is NOT NULL
 )
 SELECT *, (Rolling_People_Vaccinated/Population) * 100 AS Rolling_percentage
 FROM PopvsVacc

 --- CREATING A TEMP TABLE TO COMPARE ROLLING PEOPLE VACCINATED NUMBERS VS POPULATION

Create Table #Percent_Pop_Vac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Pop_Vac
 SELECT Cov_dea.continent, Cov_dea.location, Cov_dea.date, Cov_dea.population, Cov_Vac.new_vaccinations,
SUM (Cast (Cov_vac.new_vaccinations as bigint)) OVER (Partition By  Cov_dea.location ORDER BY Cov_dea.location, Cov_dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
AND Cov_dea.date = Cov_Vac.date
WHERE Cov_dea.continent is NOT NULL

SELECT *, (Rolling_People_Vaccinated/Population) * 100 AS Rolling_percentage
 FROM #Percent_Pop_Vac


 -- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

 CREATE VIEW Percentage_Pop_Vac AS
 SELECT Cov_dea.continent, Cov_dea.location, Cov_dea.date, Cov_dea.population, Cov_Vac.new_vaccinations,
SUM (Cast (Cov_vac.new_vaccinations as bigint)) OVER (Partition By  Cov_dea.location ORDER BY Cov_dea.location, Cov_dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project (COVID)]..['Covid deaths$'] AS Cov_dea
JOIN [Portfolio Project (COVID)]..['Covid Vaccinations$'] AS Cov_Vac
ON Cov_dea.location = Cov_Vac.location
AND Cov_dea.date = Cov_Vac.date
WHERE Cov_dea.continent is NOT NULL


SELECT *
FROM Percentage_Pop_Vac

CREATE VIEW TotalCases_Deaths_Percentages  AS
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS Death_percentage
FROM [Portfolio Project (COVID)]..['Covid deaths$']
WHERE continent is NOT NULL


SELECT *
FROM TotalCases_Deaths_Percentages