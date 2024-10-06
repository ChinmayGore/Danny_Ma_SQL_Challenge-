CREATE SCHEMA dannys_diner;

SET search_path = dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
   order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 select * from sales;

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  select * from menu;
 ## Query1 . What is the total amount each customer spent at the restaurant?
 
 
  select  sum(menu.price) as Total_price , 
         sales.customer_id from menu
  join sales on sales.product_id = menu.product_id
         group by sales.customer_id;
  
  
  
  ## Query 2. How many days has each customer visited the restaurant?
  
select customer_id,count(distinct order_date) 
       as Total_customer_visit
from sales 
	   group by customer_id;


## Query 3. What was the first item from the menu pudrchased by each customer?

with final as (
       select sales.* , menu.product_name,
rank() over(partition by Customer_id order by order_date) as ranks
       from sales
join menu  on sales.product_id = menu.product_id)
	   select * from final where 
ranks = 1;


## Query 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


select menu.product_name,count(*) 
      as Total
from  menu join sales on 
      menu.product_id = sales.product_id
group by menu.product_name;

  
## Query 5. Which item was the most popular for each customer?


with final as (
        select  menu.product_name,sales.customer_id,count(*) as Total
from menu join sales on
        sales.product_id =  menu.product_id 
group by menu.product_name, sales.customer_id)

select customer_id,Product_name,total,
         rank() over(partition by customer_id order by total desc) 
as finalrank
         from final;




## Query 6. Which item was purchased first by the customer after they became a member?

with finale as (
select sales.* , members.customer_id as cusid ,members.join_date ,
          menu.product_name as productname, 
rank() over (partition by sales.customer_id order by sales.order_date) as ranking
          from sales 
left join members on
		  sales.customer_id = members.customer_id
join menu
           on menu.product_id = sales.product_id
where sales.order_date >= members.join_date)

select customer_id,ranking,productname 
         from finale 
where ranking = 1;


  
  ## Query 7 Which item was purchased just before the customer became a member?
  
  
  with final as (
select sales.* , members.customer_id as cus_id ,members.join_date , 
         menu.product_name as productname, 
rank() over (partition by sales.customer_id order by sales.order_date) as ranking
         from sales 
left join members on
		 sales.customer_id = members.customer_id
join menu
		 on menu.product_id = sales.product_id
where sales.order_date  < members.join_date  
  )
  select cus_id,order_date,join_date, 
         productname from final
  where  ranking = 1;
  
  
  ## Query 8 What is the total items and amount spent for each member before they became a member?
  

 with cte as (
        select sa.customer_id,sa.order_date,
mem.join_date,me.price,me.product_name
     from sales  sa
left join members mem on sa.customer_id = mem.customer_id
      join menu me on sa.product_id = me.product_id
where sa.order_date < mem.join_date)

select customer_id,sum(price),
    count(distinct product_name)
from cte 
    group by customer_id;


## Query 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select * from menu;

 with cte as 
 (select sa.customer_id,men.product_name,men.price,
       case 
 when men.product_name ="sushi" then Men.price*10*2
       else men.price*10
 end as point
       from sales sa
 join menu men on
	   sa.product_id = men.product_id )
 select customer_id,sum(point) as final_points
	   from cte
 group by customer_id;
 
 
##  Query 10 . In the first week after a customer joins the program (including their join date) they
##                earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 with cte as 
(SELECT sa.customer_id, men.product_name, men.price, sa.order_date, mem.join_date,
CASE 
    WHEN sa.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN men.price * 10 * 2
    WHEN men.product_name = 'sushi' THEN men.price * 10 * 2
    ELSE men.price * 10
END AS total_price
FROM menu men
JOIN sales sa 
    ON sa.product_id = men.product_id
JOIN members mem 
    ON sa.customer_id = mem.customer_id
WHERE sa.order_date < '2021-02-01')
select customer_id,sum(total_price) as final_price 
     from cte 
group by customer_id;






 
 
 
  
  
  