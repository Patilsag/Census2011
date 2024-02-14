select * from dbo.Data1
select * from dbo.Data2


---No. of rows in to dataset

select count(*) from dbo.Data1
select count(*) from dbo.Data2


--data for jharkhand and bihar

select * from dbo.Data1 where State IN ('Bihar', 'Jharkhand')
order by State

---Total population of india

select sum(Population) as Pop_India from dbo.Data2

---Average growth of India

select AVG(Growth)*100 Avg_Growth from dbo.Data1

---Average growth of State
select AVG(Growth)*100 Avg_Growth, State
from dbo.Data1
group by State
order by 1 desc

---Average sex ratio of india

select AVG(Sex_Ratio) Avg_Sex_Ratio from dbo.Data1


---Average sex ratio of States
select State, ROUND(AVG(Sex_Ratio),0) Avg_Sex_Ratio
from dbo.Data1
group by State
order by 2 desc

---Average literacy rate 

select  State, ROUND (avg(Literacy),0) as avg_literacy
from dbo.Data1
group by State
having ROUND (avg(Literacy),0) > 80
order by 2 desc

---top 3 state showing highest growth rate

select  top 3 state, AVG(Growth)*100 Avg_Growth 
from dbo.Data1 
group by State 
order by 2 desc;


---Bottom 3 state showing lowest sex ration

select top 3 State, ROUND(AVG(Sex_Ratio),0) Avg_Sex_Ratio
from dbo.Data1 
group by State 
order by 2

---top and bottom 3 states in literacy rate

---top 3

drop table if exists #TLS
create table #TLS

( State nvarchar(255), HL float )

insert into #TLS
 select State, ROUND (avg(Literacy),0) as High_literacy_state
from dbo.Data1
group by State
order by High_literacy_state desc ; 

select top 3 * from #TLS order by #TLS.HL desc;

---Now for bottom 3

drop table if exists #BLS
create table #BLS

( State nvarchar(255), LL float )

insert into #BLS
 select State, ROUND (avg(Literacy),0) as High_literacy_state
from dbo.Data1
group by State
order by High_literacy_state ; 

select top 3 * from #BLS order by #BLS.LL ;


---Union Operator 

select * from (select top 3 * from #TLS order by #TLS.HL desc) a
union 
select * from (select top 3 * from #BLS order by #BLS.LL ) b


----Sates starting with a
select distinct state from dbo.Data1 where State like 'a%' or State like 'b%'

----State ending with d
select distinct state from dbo.Data1 where State like '%d' or State like 'a%'


---Joining the table 

select D1.District, D1.State, D1.Sex_Ratio, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district
order by 1;

---- find male and female population in all districts

--female / male = Sex Ratio............Eq.1
--Female+Male = Population......Eq.2
--females = population - males.....Eq.3

----Eq. 3 put in Eq.1

--(population - males)/Males= SR 
--population - males = SR * Males
--population = Males (SR + 1)
--##Males = Population / (SR + 1)............(male)

--## Female = population - (population /(SR+1))
--             = population (1-1/(SR+1))
--             = population ((SR+1-1)/(SR+1))
--             = population ((SR/(SR+1))
--             = Population * SR / (SR+1)..........................(female)


select district, state, ROUND (population/(Sex_ratio +1),0) as Male_Pop, ROUND ((Population*Sex_ratio)/(Sex_ratio +1),0) as Female_pop from 
(select D1.District, D1.State, D1.Sex_Ratio/1000 Sex_ratio, D2.Population from Data1 as D1 join Data2 as D2 on D1.district = D2.district) C)



---- find male and female population in all States

select A.State, sum(A.Male_pop) as total_males, sum(A.Female_pop) as total_females from 
(select district, state, ROUND (population/(Sex_ratio +1),0) as Male_Pop, ROUND ((Population*Sex_ratio)/(Sex_ratio +1),0) as Female_pop from 
(select D1.District, D1.State, D1.Sex_Ratio/1000 Sex_ratio, D2.Population from Data1 as D1 join Data2 as D2 on D1.district = D2.district) C) A
group by A.state
order by 1




---- find Population of literate and illiterate people on the basis of districts
--literacy rate = literate people / population
--so if we want to find out how many literate people in the specific state we have multiply the literacy rate with population
--Total literate People = Literacy Rate * Population


select district, state, round ((literacy/100 * population),0) as Literate_Pop, (Population - round ((literacy/100 * population),0)) as Illiterate_Pop, Population as Total_Pop from  
(select D1.District, D1.State, D1.Sex_Ratio, D1.Literacy, D2.Population from Data1 as D1 join Data2 as D2 on D1.district = D2.district) a




---- find Population of literate and illiterate people on the basis of states

select State, sum(Literate_Pop) Lit_Pop, sum(Illiterate_Pop) Illit_Pop, sum(Total_Pop) Pop from 
(select district, state, round ((literacy/100 * population),0) as Literate_Pop, (Population - round ((literacy/100 * population),0)) as Illiterate_Pop, Population as Total_Pop from  
(select D1.District, D1.State, D1.Sex_Ratio, D1.Literacy, D2.Population from Data1 as D1 join Data2 as D2 on D1.district = D2.district) a) b
group by State


----Population in previous census

--For Previous Census population 
--previous pop + growth * previous pop = latest pop
--previous pop = latest pop / (1+ growth)

---based on districts
Select district, state, population, round ((population / (1 + growth)), 0) as Previous_Pop from
(select D1.District, D1.State, D1.Growth, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district ) 

---based on states

select state, sum(Previous_Pop) as Total_Prev_Pop, sum(population) Total_Curr_Pop from 
(Select district, state, population, round ((population / (1 + growth)), 0) as Previous_Pop from
(select D1.District, D1.State, D1.Growth, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district ) a) b
group by State

-- Previous and current census population
select sum(c.Total_Prev_Pop) Prev_Census_Pop, sum(c.Total_Curr_Pop) Curr_Census_Pop from (
select state, sum(Previous_Pop) as Total_Prev_Pop, sum(population) Total_Curr_Pop from 
(Select district, state, population, round ((population / (1 + growth)), 0) as Previous_Pop from
(select D1.District, D1.State, D1.Growth, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district ) a) b
group by State) c



---Population vs Area

select p.*, q.* from

(select '1' as ID, y.* from (
select sum(Area_km2) as Area from Data2 ) y) p

join

(select '1' as ID, z.* from (
select sum(c.Total_Prev_Pop) Prev_Census_Pop, sum(c.Total_Curr_Pop) Curr_Census_Pop from (
select state, sum(Previous_Pop) as Total_Prev_Pop, sum(population) Total_Curr_Pop from 
(Select district, state, population, round ((population / (1 + growth)), 0) as Previous_Pop from
(select D1.District, D1.State, D1.Growth, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district ) a) b
group by State) c)z) q

on p.ID = q.ID


-- to get to know how much area has been decreased with population


select s.Area/s.Prev_Census_Pop as PPA, s.Area/s.Curr_Census_Pop as CPA from
(select p.Area, q.* from

(select '1' as ID, y.* from (
select sum(Area_km2) as Area from Data2 ) y) p

join

(select '1' as ID, z.* from (
select sum(c.Total_Prev_Pop) Prev_Census_Pop, sum(c.Total_Curr_Pop) Curr_Census_Pop from (
select state, sum(Previous_Pop) as Total_Prev_Pop, sum(population) Total_Curr_Pop from 
(Select district, state, population, round ((population / (1 + growth)), 0) as Previous_Pop from
(select D1.District, D1.State, D1.Growth, D2.Population
from Data1 as D1 join Data2 as D2 on D1.district = D2.district ) a) b
group by State) c)z) q

on p.ID = q.ID) s


---WINDOW FUNCTION
---top 3 districts from each state with highest literacy rate

select * from
(select district, state, literacy, ROW_NUMBER () over (partition by state order by literacy desc) rownum from Data1) a
where rownum in ('1', '2','3')