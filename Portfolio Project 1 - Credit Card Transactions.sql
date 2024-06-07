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

with max_amount as (
select 
card_type,
month(transaction_date) as mnth,
year(transaction_date) as yr,
max(amount) as Max_amt
from credit_card 
GROUP BY card_type,mnth,yr
)
SELECT Card_type,Mnth,Yr,Max_amt
FROM max_amount
WHERE max_amt IN (SELECT MAX(max_amt) FROM max_amount GROUP BY card_type);


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
row_number() over(partition by card_type order by transaction_date, transaction_id) as rn
from cte
where tot >=1000000)
select *
from cte2
where rn<=4;


-- 4- write a query to find city which had lowest percentage spend for gold card type


with cte1 as (
select 
card_type,
city,
sum(amount),
sum(amount)/(select sum(amount) from credit_card) * 100 as per
from credit_card
group by card_type,city
having card_type='gold'),
cte2 as(
select *,
dense_rank() over (order by per) as rn
from cte1)
select * 
from cte2
where rn =1;
 




-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)


SELECT
    city,
  MAX(CASE WHEN amount = max_amount THEN exp_type END) AS highest_expense_type,
    MIN(CASE WHEN amount = min_amount THEN exp_type END) AS lowest_expense_type
FROM (
    SELECT
        city,
        exp_type,
        amount,
        MAX(amount) OVER (PARTITION BY city) AS max_amount,
        MIN(amount) OVER (PARTITION BY city) AS min_amount
    FROM credit_card
) sub
GROUP BY city, max_amount, min_amount;


/*select 
city,
max(case when (select max(amount) over (partition by city) from  credit_card) then exp_type end) as max_expence ,
min(case when (select min(amount) over (partition by city) from credit_card) then exp_type end) as min_expence
from credit_card
group by city;*/-- wrong answer

-- 6- write a query to find percentage contribution of spends by females for each expense type


select 
gender,
exp_type,
sum(amount)/(select sum(amount) from credit_card) * 100 as per
from credit_card
group by gender,exp_type
having gender='f';

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
exp_type,mn,yr
order by card_type,exp_type,mn,yr),
cte2 as (
select *,
lag(total) over(partition by card_type,exp_type order by card_type,exp_type,mn,yr) as dif
from cte)
select *,
(total-dif)/dif as growth
from cte2
where mn=1 and yr=2014
order by growth desc;









-- 8- during weekends which city has highest total spend to total no of transcations ratio 




with cte as (
select city,
sum(amount) as tot,
dayname(transaction_date) as dn
from credit_card
where dayname(transaction_date) in ('saturday','sunday')
group by city,dayname(transaction_date)),
cte2 as (
select city,
tot/(select count(transaction_id) from credit_card) as ratio
from cte)
select city,
max(ratio)
from cte2
group by city
limit 1;


-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city

select * from credit_card;

with cte as (
select city,
transaction_date,
transaction_id,
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








-- once you are done with this create a github repo to put that link in your resume. Some example github links:
-- https://github.com/ptyadana/SQL-Data-Analysis-and-Visualization-Projects/tree/master/Advanced%20SQL%20for%20Application%20Development
-- https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/COVID%20Portfolio%20Project%20-%20Data%20Exploration.sql