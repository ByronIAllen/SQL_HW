USE sakila;

-- 1a. Display the first and last names of all actors
SELECT first_name, last_name FROM actor;

/* 1b. Display the first and last name of each actor in a single column
		in all caps. Name the column 'Actor Name'.*/
SELECT concat(first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an 
		actor, of whom you know only the first name, "Joe." 
        What is one query would you use to obtain this information?*/
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = 'JOE';

/* 2b. Find all actors whose last name contain the letters 'GEN'.*/
SELECT actor_id, first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

/* 2c. Find all the actors whose last names contain the letters 'LI'.
		This time display last name then first name.*/
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

/* 2d. Using IN, display the country_id and country columns of the 
		following countries: Afghanistan, Bangladesh, and China*/
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/* 3a. You want to keep a description of each actor. Create a column in 
		the actor table named description using the type BLOB.*/
ALTER TABLE actor
ADD description BLOB;

/* 3b. Entering descriptions of each actor is too much effort! Delete the
		description column and forget you ever had that idea.*/
ALTER TABLE actor
DROP COLUMN description;

/* 4a. List the last names of actors along with a count of actors with 
		that last name.*/
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name;

/* 4b. List last names of actors who have the same last name, but only 
		where the last name is shared by at least two actors.*/
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

/* 4c. The actor 'HARPO WILLIAMS' was accidentally entered in the actor 
		table as 'GROUCHO WILLIAMS'. Write a query to fix the record.*/
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns
		out that GROUCHO was the correct name after all! In a seperate 
        query, if the first name of the actor is currently HARPO change
        it to GROUCHO*/
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

/* 5a. You cannot locate the schema of the 'address' table. Which query 
		would you use to re-create it?*/
SHOW CREATE TABLE address;

/* 6a. Use JOIN to display the first and last names, plus the address,
		of each staff member. Use the staff and address tables.*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address 
ON staff.address_id = address.address_id
GROUP BY staff.last_name;

/* 6b. Use JOIN to display the total amount rung up by each staff member in 
		August of 2005. Use tables staff and payment*/
SELECT staff.staff_id, SUM(payment.amount)
FROM staff
JOIN payment 
ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

/* 6c. List each film and the number of actors who are listed for that
		film. Use tables film and film_actors with an INNER JOIN.*/
SELECT film.title, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor 
ON film.film_id = film_actor.film_id
GROUP BY film.title;

/* 6d. How many copies of the film 'Hunchback Impossible' exist in the 
		inventory system?*/
SELECT film.title, COUNT(inventory.film_id)
FROM film
JOIN inventory 
ON film.film_id = inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE';

/* 6e. Using the tables payment and customer with the JOIN command, list 
		the total paid by each customer. List the customers alphabetically
		by last name.*/
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY customer.last_name
ORDER BY customer.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely
		resurgence. As an unintended consequence, films starting with the
        letters K and Q have also soared in popularity. Use subqueries to 
        display the titles of movies starting with the letters K and Q 
        whose language is English.*/
SELECT film.title
FROM film
JOIN language 
ON film.language_id = language.language_id
WHERE film.title LIKE 'K%' OR film.title LIKE 'Q%'
AND language.name = 'ENGLISH';

/* 7b. Use subqueries to display all actors who appear in the film 'Alone
		Trip'.*/
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);

/* 7c. You want to run an email marketing campaign in Canada, for which 
		you will need the names and email addresses of all Canadian 
        customers. Use joins to retrieve this information.*/
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(
 SELECT address_id
 FROM address
 WHERE city_id IN
 (
  SELECT city_id
  FROM city
  WHERE country_id IN
  (
   SELECT country_id
   FROM country
   WHERE country = 'CANADA'
  )
 )
);

/* 7d. Sales have been lagging among young families, and you wish to 
		target all family movies for a promotion. Identify all movies
        categorized as 'family' films.*/
SELECT title
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
   SELECT category_id
   FROM category
   WHERE name = 'FAMILY'
  )
);

/* 7e. Display the most frequently rented movies in decending order.*/
SELECT f.title, COUNT(r.inventory_id)
FROM inventory i
JOIN rental r 
ON i.inventory_id = r.inventory_id
JOIN film f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

/* 7f. Write a query to display how much business, in dollars, each store
		brought in.*/
SELECT store.store_id, SUM(payment.amount)
FROM store
INNER JOIN staff 
ON store.store_id = staff.store_id
INNER JOIN payment
ON payment.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(payment.amount);

/* 7g. Write a query to display for each store its store ID, city, and 
		country.*/
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN customer
ON store.store_id = customer.store_id
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id;

/* 7h. List the top fie genres in gross revenue in descending order.
		Hint: use the category, film_category, inventory, payment, and 
        rental tables.*/
-- Note: This block always threw a 2013 error when ran. Tried to fix but never worked --
SELECT category.name, SUM(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON inventory.film_id = film_category.film_id
INNER JOIN rental
ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment
GROUP BY category.name
LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy 
		way to view the Top Five Grossing Genres. Use the solution to the 
        problem above to create a view.*/
CREATE VIEW top_five_genre_gross AS

SELECT category.name, SUM(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON inventory.film_id = film_category.film_id
INNER JOIN rental
ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment
GROUP BY category.name
LIMIT 5;

/* 8b. How would you display the view that you created above?*/
SELECT * FROM top_five_genre_gross;

/* 8c. You find that you no longer need the view that you created. 
		Write a query to delete it.*/
DROP VIEW top_five_genre_gross;