			-- COVID-19 ON 2020   (by: Dimas Bagus Setiawan)
            
select * from full_grouped;		-- main table
select * from covid_19_clean;   -- table 1
select * from worldometer_data; -- table 2

-- JOIN 1 (main table with 1 table)
select * from full_grouped as FG inner join covid_19_clean as C19C 
on FG.`Country/Region` = C19C.`Country/Region`order by Date desc;

-- JOIN 2 (main table with 2 table)
select * from full_grouped as FG inner join worldometer_data as WD 
on  FG.`Country/Region` = WD.`Country/Region` order by Date desc;


-- looking total Confirmed, Deaths, and recoveries in each Country/Region for main table

select `Country/Region`, sum(Confirmed) as Total_Confirmed, sum(Deaths) as Total_Deaths, sum(Recovered) as Total_Recovered 
from full_grouped group by `Country/Region`;
	

-- looking total confirmed vs total death Covid-19

select FG.`Country/Region`, max(FG.Confirmed) as Confirmed_covid, max(FG.Deaths) as Deaths, WD.Population, 
(max(FG.Deaths)/max(FG.Confirmed))*100 `percentage_death/case`
from full_grouped as FG inner join worldometer_data as WD on  FG.`Country/Region` = WD.`Country/Region` 
group by  FG.`Country/Region`;


-- looking total case Covid-19 country vs population

select FG.`Country/Region`, max(FG.Confirmed) as Confirmed_covid, WD.Population, 
(max(FG.Confirmed)/WD.Population)*100 `percentage case/population`
from full_grouped as FG inner join worldometer_data as WD on FG.`Country/Region` = WD.`Country/Region` 
group by FG.`Country/Region`;


-- looking at countries with highest infection rate compare to population

select FG.`Country/Region`, max(FG.Confirmed) as Total_Infection, WD.Population, (max(FG.Confirmed)/WD.Population)*100 `Percentage Infection/perpopulation` 
from full_grouped FG inner join worldometer_data WD on  FG.`Country/Region` = WD.`Country/Region` 
group by FG.`Country/Region` order by `Percentage Infection/perpopulation` desc;


-- showing country with heighest death count per-population

select FG.`Country/Region`, max(FG.Deaths) as Death, WD.Population, (max(FG.Deaths)/Population)*100 `Percentage(%)`
from full_grouped FG inner join worldometer_data WD on  FG.`Country/Region` = WD.`Country/Region` 
group by  FG.`Country/Region` order by  `Percentage(%)` desc;


-- showing continent with heighest death count

select WD.Continent, count(FG.Deaths) heighest_death_continent
from full_grouped FG inner join worldometer_data WD on  FG.`Country/Region` = WD.`Country/Region` 
group by WD.Continent order by  heighest_death_continent desc;


-- USE CTE for population vs Recovered order by number of recoveries

with popvrec (Continent, `Country/Region`, Date, Population, Confirmed, Recovered, `Rolling People Recovered`) as
(select WD.Continent, FG.`Country/Region`, FG.Date, WD.Population, FG.Confirmed, FG.Recovered, 
sum(FG.Recovered) over (partition by  FG.`Country/Region` order by FG.`Country/Region`, Date) `Rolling People Recovered`
from full_grouped as FG inner join worldometer_data as WD on FG.`Country/Region` = WD.`Country/Region`)
select *, (`Rolling People Recovered`/Population)*100 as `Percent(%) recov/population` from  popvrec order by Recovered desc;


-- Creating View to Store Data for Visualization

create view popvrec as
select WD.Continent, FG.`Country/Region`, FG.Date, WD.Population, FG.Confirmed, FG.Recovered, 
sum(FG.Recovered) over (partition by  FG.`Country/Region` order by FG.`Country/Region`, Date) `Rolling People Recovered`
from full_grouped as FG inner join worldometer_data as WD on FG.`Country/Region` = WD.`Country/Region`;