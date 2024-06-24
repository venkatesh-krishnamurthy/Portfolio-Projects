-- SQL porfolio project.
-- download credit card transactions dataset from below link :
-- https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india
-- import the dataset in sql server with table name : credit_card_transcations
-- change the column names to lower case before importing data to sql server.Also replace space within column names with underscore.
-- (alternatively you can use the dataset present in zip file)
-- while importing make sure to change the data types of columns. by defualt it shows everything as varchar.

-- write 4-6 queries to explore the dataset and put your findings 




-- solve below questions
-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

select 
city,
sum(amount),
sum(amount)/(select sum(amount) from credit_card) * 100 as per
from credit_card
group by
city
order by sum(amount) desc
limit 5;



-- 2- write a query to print highest spend month and amount spent in that month for each card type

select * from credit_card;


with cte as (
select
sum(amount) as total,
card_type,
month(transaction_date) as mn,
year(transaction_date) as yr
from credit_card
group by month(transaction_date),
year(transaction_date),card_type)
select card_type,mn,yr,total
from cte
where total in (select max(total) from cte group by card_type);




-- 3- write a query to print the transaction details(all columns from the table) for each card type when
	-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)


with cte as (
select *,
sum(amount) over (partition by card_type order by transaction_date, transaction_id) as tot
from credit_card),
cte2 as (
select *,
dense_rank() over(partition by card_type order by tot) as rn
from cte
where tot >=1000000)
select *
from cte2
where rn=1;


-- 4- write a query to find city which had lowest percentage spend for gold card type

WITH cte as(
	SELECT city, card_type, SUM(amount) as amount,
    SUM(CASE WHEN card_type='Gold' THEN amount END) as gold_amount
	FROM credit_card
	GROUP BY city, card_type
)
SELECT city, SUM(gold_amount)*1.0/SUM(amount) as gold_ratio
FROM cte
GROUP BY city
HAVING COUNT(gold_amount) > 0 AND SUM(gold_amount)>0
ORDER BY gold_ratio;
 




-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

select * from credit_card;

with cte as(
select 
city,exp_type,sum(amount) as tot_amt
from credit_card
group by city,exp_type),
cte1 as (
select *,
dense_rank() over(partition by city order by tot_amt asc) as rn_asc,
dense_rank() over(partition by city order by tot_amt desc) as rn_dsc
from cte)
select 
city,
max(case when rn_asc=1 then exp_type END) as low_expence,
max(case when rn_dsc=1 then exp_type END) as high_expence
from cte1
group by city;


-- 6- write a query to find percentage contribution of spends by females for each expense type



SELECT exp_type,
SUM(CASE WHEN gender='F' THEN amount ELSE 0 END)*1.0/SUM(amount) as percent_female_contribution
FROM credit_card
GROUP BY exp_type
ORDER BY percent_female_contribution DESC;



-- 7- which card and expense type combination saw highest month over month growth in Jan-2014
select * from credit_card;
with cte as (
select 
card_type,
exp_type,
month(transaction_date) as mn,
year(transaction_date) as yr,
sum(amount) as total
from credit_card
group by card_type,
exp_type,month(transaction_date),year(transaction_date)),
cte2 as (
select *,
lag(total,1) over(partition by card_type,exp_type order by yr,mn) as dif
from cte)
select *,
(total-dif) as growth
from cte2
where mn=1 and yr=2014
order by growth desc
limit 1;

-- 8- during weekends which city has highest total spend to total no of transcations ratio 


select city,sum(amount)*1.0/count(*) as ratio
from credit_card
where dayname(transaction_date) in ('saturday','sunday')
group by city
order by ratio desc
limit 1
;

-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city

select * from credit_card;

with cte as (
select *,
row_number() over (partition by city order by transaction_date) as rn
from credit_card),
cte2 as (
select 
city,
transaction_date
from cte 
where rn=500),
cte3 as (
select 
city,
min(transaction_date) as mini
from credit_card
group by city),
cte4 as (
select 
cte2.city,
datediff(cte2.transaction_date,cte3.mini) as days_500
from cte2
join cte3 
on cte2.city = cte3.city)
select *
from cte4
order by days_500
limit 1;

with cte as(
select *,
row_number() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card)

select city,max(transaction_date),min(transaction_date),
timestampdiff(day,min(transaction_date),max(transaction_date)) as date_diff
from cte
where rn=1 or rn=500
group by city
having count(*)=2
order by date_diff
limit 1;







-- once you are done with this create a github repo to put that link in your resume. Some example github links:
-- https://github.com/ptyadana/SQL-Data-Analysis-and-Visualization-Projects/tree/master/Advanced%20SQL%20for%20Application%20Development
-- https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/COVID%20Portfolio%20Project%20-%20Data%20Exploration.sql