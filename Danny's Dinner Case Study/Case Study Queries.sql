CREATE DATABASE dannys_diner;
USE dannys_diner;
SHOW TABLES;

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
  
-- What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_amount 
FROM sales s JOIN menu m 
ON s.product_id = m.product_id 
GROUP BY s.customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS no_of_visits 
FROM sales 
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
WITH ranktable AS 
(SELECT s.customer_id, m.product_name,
row_number() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS ranknumber
FROM sales s JOIN menu m 
ON s.product_id = m.product_id)

SELECT * FROM ranktable WHERE ranknumber = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(order_date) AS no_of_times
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(order_date) DESC 
LIMIT 1;

-- Which item was the most popular for each customer?

WITH CTE AS(
SELECT customer_id,m.product_name, count(order_date) AS nooftimes,
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) AS rankval
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, m.product_name)

SELECT * FROM CTE where rankval = 1;


-- Which item was purchased first by the customer after they became a member?
with CTE1 AS(SELECT S.customer_id,order_date,join_date,M.product_name,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM sales S
JOIN menu M ON S.product_id = M.product_id
Join members P ON S.customer_id = P.customer_id
WHERE order_date >= join_date
)
SELECT customer_id,product_name
FROM CTE1 
WHERE rnk = 1;

-- Which item was purchased just before the customer became a member?
WITH CTE1 AS(
SELECT s.customer_id,order_date,join_date,M.product_name,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
FROM Sales S
JOIN Menu M ON S.product_id = M.product_id
Join members P ON S.customer_id = P.customer_id
WHERE order_date < join_date
)
SELECT customer_id,product_name
FROM CTE1 
WHERE rnk = 1;


-- What is the total items and amount spent for each member before they became a member?
SELECT S.customer_id
,count(S.product_id) AS Products
,Sum(M.price) as Price
FROM Sales S
JOIN Menu M ON S.product_id = M.product_id
JOIN members P on S.customer_id = P.customer_id
WHERE order_date < join_date
GROUP BY customer_id
ORDER BY customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT S.customer_id,
SUM(CASE WHEN product_name = "sushi" THEN price * 10 * 2
ELSE price * 10 END) AS points
FROM Sales S
JOIN Menu M ON S.product_id = M.product_id
GROUP BY customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?   
WITH CTE1 AS (
    SELECT
        S.customer_id,
        S.order_date,
        M.product_name,
        M.price,
        CASE
            WHEN product_name = 'sushi' THEN 2 * M.price 
            WHEN order_date BETWEEN P.join_date AND DATE_ADD(P.join_date, INTERVAL 6 DAY) THEN 2 * M.price
            ELSE M.price
        END AS points
    FROM
        Sales S
        JOIN Menu M ON S.product_id = M.product_id
        JOIN Members P ON S.customer_id = P.customer_id
    WHERE
        DATE_FORMAT(order_date, '%Y-%m-01') = '2021-01-01'
)
SELECT
    customer_id,
    SUM(points) * 10 AS total_points
FROM
    CTE1
GROUP BY
    customer_id
ORDER BY customer_id;