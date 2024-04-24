-- Retrieve the total number of orders placed.

Select count(order_id) as total_orders from orders;



-- Calculate the total revenue generated from pizza sales.

SELECT 
    round(sum(od.quantity * p.price),2) as total_sale
FROM
    order_details AS od
        LEFT JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id;



-- Identify the highest-priced pizza.

SELECT 
    pt.name AS pizza_name, p.price AS high_priced_pizza
FROM
    pizzas AS p
        LEFT JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;  


-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.order_details_id) AS Order_count
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY Order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS most_ordered
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY most_ordered DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, COUNT(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY total_quantity Desc;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY order_count DESC


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS distribution
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity) AS avg_per_day_pizza
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;



-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
limit 3;
 
 
 -- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sale
                FROM
                    order_details AS od
                        LEFT JOIN
                    pizzas AS p ON od.pizza_id = p.pizza_id) * 100,
            1) AS percentage_distribution
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY percentage_distribution DESC;


-- Analyze the cumulative revenue generated over time


select order_date,
round(sum(revenue) over(order by order_date),2) as cum_revenue
from
(SELECT 
    o.order_date, SUM(od.quantity * p.price) AS revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    orders AS o ON o.order_id = od.order_id
GROUP BY o.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue, rank_ from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rank_
from
(SELECT 
    pt.category,
    pt.name,
    SUM((od.quantity) * p.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category , pt.name) as a) as b
where rank_ <= 3;


