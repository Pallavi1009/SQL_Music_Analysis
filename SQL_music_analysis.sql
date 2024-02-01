--Que1:Who is the senior most employee based on the job title?

select * from employee
order by levels desc
limit 1

--Que2:Which countries have the most invoices? 

select Count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

--Que3:What are the top 3 values of total invoice?

select total from invoice
order by total desc 
limit 3

--Que4:Which city has the best customers? we would like to through a promotional music festival in the city we made the most money.
--Write a query that return one city that has highest sum of invoice total.
--Return both the city name and sum of all invoice total.

select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc

--Que5:Who is the best customer?The customer who has spent most money will be declared as the best customer.
--write a query that returns the person who has spent most money.

select customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1 



--Que6:Write a query to return the email,first name,last name and genre of al  Rock Music listeners.
--Return your list ordered alphabetically by email starting A.

select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

--Que7:Let's invite the artists who have written the most rock music in our dataset.
--Write a query that return the artist name and total track count of the top 10 rock bands.

select artist.artist_id,artist.name, count(artist.artist_id)as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;



--Que8:Return all the track names that have a song length longer than the average song length.
--Return the name and milliseconds for each track.Order by the song length with the longest songs listed first.

select name,milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;




--Que9:Find how much amount spend by each customer on artists? 
--Write a query to return customer Name,artist name and total spent.

##CTE(Common Table Expressions)

with best_selling_artist as(
	select artist.artist_id as artist_id,artist.name as artist_name,
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


--Que10: We want to find out the most popular music genre of each country. 
--(We determine the most popular genre as the genre with the highest amount of purchases.)
--Write a query that returns each country along with the top genre.For countries where the maximum number of purchases is shared written all genres. 


with popular_genre as(
	select count(invoice_line.quantity) as purchases, customer.country,genre.name,genre.genre_id,
	Row_Number() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNo 
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1 

