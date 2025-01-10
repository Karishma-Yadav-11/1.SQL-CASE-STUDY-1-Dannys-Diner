--CASE Study - 1 (Danny's Diner)

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
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
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;

--Case Study Questions
--Each of the following case study questions can be answered using a single SQL statement:

--1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(price) AS Total_amount_spent
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP  BY s.customer_id
ORDER BY s.customer_id;

--2. How many days has each customer visited the restaurant?

SELECT customer_id, count(DISTINCT(order_date)) AS Num_visit_days
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH cte AS
(
SELECT s.customer_id, m.product_name,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS row_num
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
ORDER BY s.customer_id
)

SELECT customer_id, product_name
FROM cte
WHERE row_num = 1;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name,count(s.product_id) AS order_count
FROM  menu m
JOIN sales s
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY order_count DESC;

--5. Which item was the most popular for each customer?

WITH item_count AS
(
SELECT s.customer_id, m.product_name, count(*) AS order_count,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY count(*) DESC) AS rnk
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name
FROM item_count
WHERE rnk = 1;

--6. Which item was purchased first by the customer after they became a member?

WITH cte AS
(
SELECT s.customer_id, m.product_name AS order_item_after_membership, s.order_date, mm.join_date,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mm
ON s.customer_id = mm.customer_id
WHERE s.order_date > mm.join_date
)

SELECT customer_id, order_item_after_membership
FROM cte
WHERE rnk = 1;

--7. Which item was purchased just before the customer became a member?

WITH cte AS
(
SELECT s.customer_id, m.product_name AS order_item_before_membership, s.order_date, mm.join_date,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mm
ON s.customer_id = mm.customer_id
WHERE s.order_date < mm.join_date
)

SELECT customer_id, order_item_before_membership
FROM cte
WHERE rnk = 1;

--8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mm
ON s.customer_id = mm.customer_id
WHERE s.order_date < mm.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH cte AS
(
SELECT s.customer_id, m.product_name, m.price,
		CASE
			WHEN m.product_name = 'sushi' THEN m.price*10*2
			ELSE m.price*10
		END AS points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
)

SELECT customer_id, SUM(points) AS total_points
FROM cte
GROUP BY customer_id
ORDER BY customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH points_cet AS
(
SELECT s.customer_id, m.product_name, m.price, s.order_date,
		CASE
			WHEN s.order_date BETWEEN mm.join_date AND mm.join_date + INTERVAL '7 DAYS' THEN m.price*10*2
			ELSE m.price*10
		END AS points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mm
ON s.customer_id = mm.customer_id
WHERE s.order_date < '2021-02-01'
)

SELECT customer_id, SUM(points) AS total_points_for_members
FROM points_cet
GROUP BY customer_id
ORDER BY customer_id;

--Bonus Questions--

--11. Determine the name and price of the product ordered by each customer on all order dates and find out whether the customer was a member on the order date or not.

SELECT s.customer_id, s.order_date, m.product_name, m.price,
		CASE
			WHEN mb.join_date <= s.order_date THEN 'Y'
			ELSE 'N'
		END AS member
FROM sales s
LEFT JOIN members mb
ON s.customer_id = mb.customer_id
JOIN menu m
ON s.product_id = m.product_id;

--12. Rank the previous output from Q.11 based on the order_date for each customer. display NULL if customer was not a member when dish was ordered.

WITH cte AS
(
SELECT s.customer_id, s.order_date, m.product_name, m.price,
		CASE
			WHEN mb.join_date <= s.order_date THEN 'Y'
			ELSE 'N'
		END AS member_status
FROM sales s
LEFT JOIN members mb
ON s.customer_id = mb.customer_id
JOIN menu m
ON s.product_id = m.product_id
)

SELECT *,
		CASE
			WHEN member_status= 'Y' THEN RANK() OVER(PARTITION BY customer_id, member_status ORDER BY order_date)
			ELSE NULL
		END AS ranking
FROM cte;