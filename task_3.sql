
# 1. Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT name AS category_name, COUNT(film_category.film_id) AS films FROM category
JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY films DESC;

# 2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT actor.first_name, actor.last_name, COUNT(rental_date) as rents FROM actor
JOIN film_actor USING(actor_id)
JOIN film USING(film_id)
JOIN inventory USING(film_id)
JOIN rental USING(inventory_id)
GROUP BY actor.actor_id
ORDER BY rents DESC
LIMIT 10;

# 3. Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT category.name, SUM(payment.amount) as money_spent from category
JOIN film_category USING(category_id)
JOIN film USING(film_id)
JOIN inventory USING(film_id)
JOIN rental USING(inventory_id)
JOIN payment USING(rental_id)
GROUP BY category.name
ORDER BY money_spent DESC
LIMIT 1;

# 4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT film.title FROM inventory
RIGHT JOIN film ON inventory.film_id = film.film_id
WHERE inventory.film_id IS NULL;

# 5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”.
#    Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

SELECT actor.first_name, actor.last_name, COUNT(film.film_id) AS children_films
FROM film
JOIN film_category USING(film_id)
JOIN category USING(category_id)
JOIN film_actor USING(film_id)
JOIN actor USING(actor_id)
WHERE category.name='Children'
GROUP BY actor.actor_id
ORDER BY children_films DESC
FETCH FIRST 3 ROWS WITH TIES;

# 6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1).
#    Отсортировать по количеству неактивных клиентов по убыванию.

SELECT city.city, COUNT(customer.active = 1) AS active, COUNT(customer.active = 0) AS non_active FROM city
JOIN address USING(city_id)
JOIN customer USING(address_id)
GROUP BY city.city
ORDER BY count(customer.active = 0) desc;

# 7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах
#    (customer.address_id в этом city),
#    и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”.
#    Написать все в одном запросе.

WITH category_rent_count AS
    (SELECT category.name, SUM(age(rental.return_date,rental.rental_date)) AS rent_time, city.city
    FROM category
    JOIN film_category USING(category_id)
    JOIN film USING(film_id)
    JOIN inventory USING(film_id)
    JOIN rental USING(inventory_id)
    JOIN customer USING(customer_id)
    JOIN address USING(address_id)
    JOIN city USING(city_id)
    GROUP BY category.name, city.city)
SELECT DISTINCT ON(city) name, rent_time, city
FROM category_rent_count
WHERE rent_time IN
    (SELECT MAX(rent_time) FROM category_rent_count GROUP BY city) AND (city LIKE'%-%' OR LOWER(city) LIKE 'a%')
ORDER BY city, name;
