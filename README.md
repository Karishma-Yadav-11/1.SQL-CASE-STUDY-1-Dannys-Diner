# 1. SQL CASE STUDY - Danny's Diner

![Dannys Diner](https://github.com/Karishma-Yadav-11/1.SQL-CASE-STUDY-1-Dannys-Diner/blob/main/1.png)

## Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.
Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.
Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!
Danny has shared with you 3 key datasets for this case study:
•	sales
•	menu
•	members
You can inspect the entity relationship diagram and example data below.

**NOTE** : Refer [case-study-1](https://8weeksqlchallenge.com/case-study-1/) for complete description and tables. 

## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:
1.	What is the total amount each customer spent at the restaurant?
2.	How many days has each customer visited the restaurant?
3.	What was the first item from the menu purchased by each customer?
4.	What is the most purchased item on the menu and how many times was it purchased by all customers?
5.	Which item was the most popular for each customer?
6.	Which item was purchased first by the customer after they became a member?
7.	Which item was purchased just before the customer became a member?
8.	What is the total items and amount spent for each member before they became a member?
9.	If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10.	In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    
## Bonus Questions
11. Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
(Determine the name and price of the product ordered by each customer on all order dates and find out whether the customer was a member on the order date or not.)

'''sql
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
'''

12. Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
(Rank the previous output from Q.11 based on the order_date for each customer. display NULL if customer was not a member when dish was ordered.)

'''sql
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
'''
