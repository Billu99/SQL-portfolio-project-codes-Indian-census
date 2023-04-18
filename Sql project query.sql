select * from [SQL portfolio project].dbo.data1;
select * from [SQL portfolio project].dbo.data2;

--number of rows into our dataset
select COUNT(*) as Total_row_1 from [SQL portfolio project].dbo.data1;
select COUNT(*) as Total_raw_2 from [SQL portfolio project].dbo.data2;

--dataset for jharkhand and bihar
select * from [SQL portfolio project]..data1 where State in ('Jharkhand' , 'Bihar');

--population of India
select sum(population) as Population from [SQL portfolio project]..data2;

--average growth
select state, AVG(growth) as avg_growth 
from [SQL portfolio project]..data1
group by state;

--avg sex ratio
select state, round(avg(sex_ratio),0) as avg_sex_ratio 
from [SQL portfolio project]..data1 
group by state 
order by avg_sex_ratio desc;

--avg literacy rate
select state, round(avg(literacy), 0) as avg_literacy_rate
from [SQL portfolio project]..data1
group by state
having round(avg(literacy), 0) > 90
order by avg_literacy_rate desc;

--top 3 states showing hishest growth rate
select top 3 state, avg(growth) * 100 as avg_growth 
from [SQL portfolio project]..data1 
group by state 
order by avg_growth desc;

--bottom 3 state showing lowest sex ratio
select top 3 state, round(avg(sex_ratio), 0) as avg_sex_ratio 
from [SQL portfolio project]..data1 
group by State 
order by avg_sex_ratio asc;

--top and bottom 3 states in literacy rate
drop table if exists #topstates;

create table #topstates
(
state nvarchar(255),
topstate float
)

insert into #topstates
select state, round(avg(literacy), 0) as avg_literacy_ratio from [SQL portfolio project]..Data1
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;

create table #bottomstates
(
state nvarchar(255),
bottomstate float
)

insert into #bottomstates
select state, round(avg(literacy), 0) as avg_literacy_ratio from [SQL portfolio project]..Data1
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by  #bottomstates.bottomstate asc;

--union operator

select c.state, c.topstate from
(select * from (
select top 3 * from #topstates order by #topstates.topstate desc
) as a

union

select * from (
select top 3 * from #bottomstates order by  #bottomstates.bottomstate asc
) as b) as c

order by c.topstate desc;



--states staring with letter a
select distinct state from [SQL portfolio project]..Data1 where lower(state) like 'a%' or lower(state) like 'b%';
select distinct state from [SQL portfolio project]..Data1 where lower(state) like 'a%' and lower(state) like '%m';

--joining both table

--total males and females
select d.state, sum(d.males) as total_males, sum(d.females) as total_females from
(select c.district, c.state, round(c.population / (c.sex_ratio + 1), 0) as males, 
round((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) as females from 
(select a.District, a.State, a.Sex_Ratio / 1000 as sex_ratio, b.Population from 
[SQL portfolio project]..Data1 as a inner join [SQL portfolio project]..Data2 as b on a.District = b.district) as c) as d
group by d.State;

--total literacy rate
select d.state, sum(d.literate_people) as total_literate_people, sum(d.illiterate_people) as total_illiterate_people from
(select c.district, c.state, round((c.literacy_ratio * c.population), 0) as literate_people, 
round(((1-c.literacy_ratio) * c.population), 0) as illiterate_people from
(select a.District, a.State, a.Literacy / 100 as literacy_ratio, b.Population from 
[SQL portfolio project]..Data1 as a inner join [SQL portfolio project]..Data2 as b on a.District = b.district) as c) as d
group by d.state;


--population in previous year
select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from
(select e.state, sum(e.previous_census_population) as previous_census_population, sum(current_census_population) as current_census_population from
(select d.district, d.state, round(d.population / (1 + d.growth), 0) as previous_census_population, d.population as current_census_population from
(select a.District, a.State, a.Growth, b.Population from 
[SQL portfolio project]..Data1 as a inner join [SQL portfolio project]..Data2 as b on a.District = b.district) as d) as e
group by e.State) as m

-- window
--output top 3 districts from each state with highest literacy rate

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) as rnk from [SQL portfolio project]..Data1) as a
where a.rnk in (1,2,3) order by state

