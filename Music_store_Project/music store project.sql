use  music_store_data;

select * from employee;

# Easy Question
#Q1) who is the senior most employee based on job title?
  select * from employee 
  order by levels desc limit 1;
  
#Q2) which countries have the most invoices?
   select * from invoice;
   
   select count(billing_country) as c , billing_country
     from invoice group by billing_country 
     order by c desc;
     
#Q3) what are top 3 values of total invoice?
    select	total from invoice
    order by total desc limit 3;
    
#Q4) Which city have the best customers? we would like to throw a promotional music festival in the city we made the most money. 
#     write a query that returns one  city that has the highest sum of  invoice total. Return both the city name & sum of all 
#      invoice totals.  

  select sum(total) as total_invoice , billing_city from invoice
  group by billing_city order by total_invoice desc ;
  
-- Q5) who is the best customer? The customer who has spend the most money will be declared  the best customer. write a query 
--     that returns the person who has spent most money.
     select * from customer;
     
     select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total) as total 
     from customer 
     join invoice on customer.customer_id = invoice.customer_id
     group by customer.customer_id ,customer.first_name, customer.last_name 
     order by total desc limit 1;
     
  -- Moderate
  -- Q1) write query to return the email, first name, last name, and genre of all Rock Music listeners.
  -- Return you list ordered alphabetically by email starting with A.
   select distinct email, first_name, Last_name 
   from customer 
   join invoice on customer.customer_id = invoice.customer_id
   join invoice_line on invoice.invoice_id = invoice_line.invoice_id
   where track_id in( 
   select track_id from track
   join genre on track.genre_id = genre.genre_id
   where genre.name like 'Rock')
   order by email;
 
 -- Q2) Lets invite the artists who have written the most rock music in our dataset. write a query that return the artist 
 -- name and total track count of the top 10 rock brands.
 
   select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
   from track 
   join album on album.album_id = track.album_id
   join artist on artist.artist_id = album.artist_id
   join genre on genre.genre_id = track.genre_id
   where genre.name like "Rock"
   group by artist.artist_id, artist.name 
   order by number_of_songs desc
   limit 10;
 
 -- Q3) Return all the track names that have a song length longer than the average song length.
 --  Return the Name and Millseconds for each track. Order by the song length with the longest songs 
 --  listed first.
    select name,milliseconds
    from track
    where milliseconds >(select avg(milliseconds) as avg_track_length
    from track)
    order by milliseconds desc ;
    
-- Advance 
-- Q1) Find how much amount spent by each customer on artist? write query to return customer name, artist name and total spend.
        
     with best_selling_artist as(
        select artist.artist_id as artist_id,  artist.name as artist_name,
        sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
        from invoice_line
        join track on track.track_id = invoice_line.track_id
        join album on album.album_id = track.album_id
        join artist on artist.artist_id = album.artist_id
        group by 1,2
        order by 3 Desc
        limit 1
        )
        select customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name,
        sum(invoice_line.unit_price * invoice_line.quantity) as amount_spent
        from invoice 
        join customer on customer.customer_id = invoice.customer_id
        join invoice_line on invoice_line.invoice_id = invoice.invoice_id 
        join track on track.track_id = invoice_line.track_id 
        join album on album.album_id = track.album_id 
        join best_selling_artist on best_selling_artist.artist_id = album.artist_id
        group by 1,2,3,4
        order by 5 desc;
     
	-- Q2) We want to find out the most popular music gener for each country. we determine the most popular genre
    --     as the genre with the highest amount of purchases. write a query that returns each country along with
    --     the top Genre. For countries where the maximum number of purchases is shared return all Genres.
          
          with popular_genre as (
          select count(invoice_line.quantity)  as purchases ,customer.country , genre.name, genre.genre_id,
          row_number() over(partition by customer.country order by count(invoice_line.quantity) desc ) as rowno 
          from invoice_line
          join invoice on invoice.invoice_id = invoice_line.invoice_id
          join customer on customer.customer_id = invoice.customer_id 
          join track on track.track_id = invoice_line.track_id 
          join genre on genre.genre_id = track.genre_id
          group by 2,3,4
          order by 2 ASC , 1 Desc
          )
          select * from popular_genre where rowno <=1;
		
-- Q3) write query that determines the customer that has spent the most on music for each country.
--     write a query that returns the country along with top customer and how much they spent.
--     For countries where the top amount is shared, provide all customers who spent this amount.

	 with customer_with_country as (
		 select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
         row_number() over(partition by billing_country order by sum(total) desc) as rowno
         from invoice 
         join customer on customer.customer_id = invoice.customer_id 
         group by 1,2,3,4 
         order by 4 asc, 5 desc
         )
         
         select * from customer_with_country where rowno <=1;
          
          