/* I want to find the account that placed the most orders */

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1

  
/* I want to find the account that placed the least orders */

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders 
LIMIT 1


/* Finding the account that placed the earliest order */

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY o.occurred_at 
LIMIT 1


/* Finding the account that placed the Latest order */

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY o.occurred_at DESC 
LIMIT 1


/* Ranking the total amount of paper ordered (from highest to lowest) for each account using a partition */

SELECT id, account_id, total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders


/* What kind of paper was ordered the most */

SELECT SUM(standard_qty) standard_paper, SUM(poster_qty) poster_paper, SUM(gloss_qty) gloss_paper
FROM orders
ORDER BY 1, 2, 3 DESC


/*Find the mean (average) amount spent per order on each paper type, as well  as the mean amount of each paper
type purchased per order. */

SELECT AVG(standard_qty) AS avg_standasr_qty,
	   AVG(gloss_qty) AS avg_gloss_qty,
	   AVG(poster_qty) AS avg_poster_qty,
	   AVG(standard_amt_usd) AS avg_standard_amt,
	   AVG(gloss_amt_usd) AS avg_gloss_amt,
	   AVG(poster_amt_usd) AS avg_poster_amt
FROM orders;


/* The region for each sales rep along with their associated accounts. Sort the accounts alphabetically (A-Z) 
according to the account name.*/
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name
LIMIT 10;


/* Which year did Parch and Posey have the greatest sales in terms of total number of orders */

SELECT DATE_PART('year', occurred_at) ord_year, 
       COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


/* Which month did Parch and Posey have the greatest sales in terms of total number of orders */

SELECT DATE_PART('month', occurred_at) ord_month, 
       COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


/* The name of the sales rep in each region with the largest amount of sales (USD) */

SELECT s.name rep, r.name region, SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY s.name, r.name
ORDER BY total_sales DESC
LIMIT 5;


/* The region with the largest amount of total sales (USD), and how many total orders were placed? */

SELECT r.name region, SUM(o.total_amt_usd) largest_sales_usd,
       COUNT(o.total) total_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC, 3;


/* The region with the smallest amount of total sales (USD), and how many total orders were placed? */

SELECT r.name region, SUM(o.total_amt_usd) smallest_sales_usd,
       COUNT(o.total) total_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 ASC, 3;


/* The customer that spent the most (in total over their lifetime as a customer) in terms of total amount (USD).
How many web events did they have for each channel? */

SELECT a.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (SELECT id
                   FROM(SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
                        FROM orders o
                        JOIN accounts a
                        ON a.id = o.account_id
                        GROUP BY a.id, a.name
                        ORDER BY 3 DESC
                        LIMIT 1) inner_table)
GROUP BY 1,2
ORDER BY 3 DESC;


/* Provide the name of the sales rep in each region with the largest amount of total amount (USD) */

WITH t1 AS(
	 SELECT s.name rep_name, r.name region, SUM(o.total_amt_usd) total_amt
	 FROM sales_reps s
	 JOIN accounts a
	 ON a.sales_rep_id = s.id
	 JOIN orders o
	 ON o.account_id = a.id
	 JOIN region r
	 ON r.id = s.region_id
	 GROUP BY 1,2
	 ORDER BY 3 DESC),
t2 AS(
	 SELECT region, MAX(total_amt) total_amt
	 FROM t1
	 GROUP BY 1)
SELECT t1.rep_name, t1.region, t1.total_amt
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.total_amt = t2.total_amt;


/* The account that purchased the most (in total over their lifetime as a customer) in terms of standard quantity
paper, how many accounts still had more in total */
WITH t1 AS(
        SELECT a.name account_name, SUM(o.standard_qty)total_std, SUM(o.total) total
	    FROM accounts a
	    JOIN orders o
	    ON o.account_id = a.id
	    GROUP BY 1
	    ORDER BY 2 DESC
	    LIMIT 1),
	t2 AS(
		SELECT a.name name
		FROM orders o
		JOIN accounts a
		ON a.id = o.account_id
		GROUP BY 1
 HAVING SUM (o.total) > (SELECT total FROM t1))
 SELECT COUNT(*) accounts_had_more_in_total
 FROM t2;
