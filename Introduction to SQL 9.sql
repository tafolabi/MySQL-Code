# 1a. Display the first and last names of all actors from the table actor.

select * from actor;
select first_name,last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. 
#Name the column Actor Name.

alter table actor
add Actor_Name varchar(200);
update actor set Actor_Name = concat(first_name, ' ' ,last_name);

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?

select * from actor where first_name = "Joe";
#2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%GEN%";

#2c. Find all actors whose last names contain the letters LI. This time, 
#order the rows by last name and first name, in that order:

select last_name,first_name from actor where last_name like "%LI%";

#2d. Using IN, display the country_id and country columns of the following countries:
# Afghanistan, Bangladesh, and China:

select  country_id, country from country where country in ("Afghanistan", "Bangladesh", "China");

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
# so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add Description blob(200);
select * from actor;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort.
# Delete the description column.

alter table actor drop column Description;

#4a. List the last names of actors, as well as how many actors have that last name.

select COUNT(last_name),last_name
from actor
group by last_name

#4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors

having COUNT(last_name) >1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
set
  first_name = REPLACE('HARPO', 'first_name','Groucho')
where
  actor_id = 172;
  
  #5a. You cannot locate the schema of the address table.
  #Which query would you use to re-create it?

show create table address;

#6a use join to display the first and last names as well as the address of each

select  staff.first_name, staff.last_name, address.address
from staff
join address 
using( address_id);

#6b  use staff and payment to display total amount rung by each staff member in august 2005

select staff.first_name,staff.last_name, sum(payment.amount) as 'total amount'
from staff
join payment on payment.staff_id = staff.staff_id and payment.payment_date between '2005-08-01' and '2005-08-31'
group by staff.staff_id;

#6c 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
#Use inner join.

select film.title, count(film_actor.actor_id) as 'Number of Actors'
from film
inner join film_actor 
using (film_id)
group by film_actor.actor_id;

# 6d 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
# select * from film.film_id, film.title, inventory.inventory_id;

select film.title, count(film.title) as 'Film Total' 
from film 
inner join inventory 
using (film_id)
where film.title = 'HUNCHBACK IMPOSSIBLE'
group by film_id;

# 6e  Using the tables payment and customer and the JOIN command, list the total paid by each customer.
# List the customers alphabetically by last name:

select customer.first_name,customer.last_name, sum(payment.amount) as 'total amount'
from payment
inner join customer
using(customer_id)
group by customer_id
order by last_name;

#7a Use subqueries to display the titles of movies starting with the letters K and Q 
#whose language is English.
select title,language_id from film
 where language_id in (
select language_id from language
where  language_id = 1) 
and  (title like 'K%')
or (title like 'Q%');

#7b Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name, actor_id from actor
 where actor_id in ( 
 (select actor_id from film_actor
 where film_id in 
 (select film_id from film
where  title = 'ALONE TRIP')));

#7b confirmation
(select actor_id, film_id from film_actor
 where film_id in 
 (select film_id from film
where  title = 'ALONE TRIP'));

#7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.

select customer.first_name, customer.last_name, customer.email, country.country  from customer
 join address
	on customer.address_id= address.address_id
  join city
	on city.city_id = address.city_id
  join country
	on country.country_id =city.country_id
    where country = 'Canada'
    order by first_name;

#7d  Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as family films.

select  film.title, category.category_id, category.name
from category
join film_category
   on category.category_id= film_category.category_id
join film
   on film.film_id = film_category.film_id
  where category.name = "family"
  order by name;
  
#7e  Display the most frequently rented movies in descending order.

select  film_text.title, count(rental.rental_id) as 'Rental Count'
from film_text
join inventory
on film_text.film_id = inventory.film_id
join rental
on rental.inventory_id = inventory.inventory_id
group by title
order by count(rental.rental_id) desc;

 #7f Write a query to display how much business, in dollars, each store brought in.
 
 select  sum(amount) as Sum, store.store_id
from store
join staff
on store.store_id= staff.store_id
join payment
on staff.staff_id = payment.staff_id
group by store_id;

#7g Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country  from store
 join address
	on store.address_id= address.address_id
  join city
	on city.city_id = address.city_id
  join country
	on country.country_id =city.country_id;

#7h List the top five genres in gross revenue in descending order. 

select category.name,sum(payment.amount) as 'Gross Revenue'
 from rental 
 join payment
	on rental.rental_id=payment.rental_id
 join inventory
	on rental.inventory_id = inventory.inventory_id
 join film_category
	on inventory.film_id = film_category.film_id
 join category
	on film_category.category_id = category.category_id
    group by category.name 
    order by  sum(payment.amount) desc
    limit 5;
    
#8a Use the solution from the problem above to create a view.

create view REVENUE as
select category.name,sum(payment.amount) as 'Gross Revenue'
 from rental 
 join payment
	on rental.rental_id=payment.rental_id
 join inventory
	on rental.inventory_id = inventory.inventory_id
 join film_category
	on inventory.film_id = film_category.film_id
 join category
	on film_category.category_id = category.category_id
    group by category.name 
    order by  sum(payment.amount) desc
    limit 5;

 #8b How would you display the view that you created in 8a?
 
 select * from revenue;
 
 #8c You find that you no longer need the view top_five_genres. Write a query to delete it.
 
 drop view revenue;

 
 