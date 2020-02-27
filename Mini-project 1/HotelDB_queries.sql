/* UPDATE THE ACCOMMODATION PRICES */

UPDATE public."Rooms"
SET price=450
WHERE number=3;


/* UPDATE ALL DOUBLE ROOMS */

UPDATE public."Rooms"
SET price=2500
WHERE max_guests=2;

/* LIST OF LOYAL CLIENTS */

SELECT primary_guest_id, count(primary_guest_id) as number_of_visits
FROM public."Bookings"
GROUP BY primary_guest_id
HAVING count(primary_guest_id) > 1 
ORDER BY number_of_visits desc


/* SCHEDULE OF USING THE CONFERENCE HALL DURING A SPECIFIC PERIOD OF TIME */

SELECT *
FROM public."Booked_Rooms"
WHERE room_number = 10 
AND starts >= timestamp '2020-03-20 01:00:00'
AND ends <= timestamp '2020-03-20 23:00:00';


/* CURRENT ROOM AVAILABILITY */
-- if something returns room is booked
SELECT *
FROM public."Booked_Rooms"
WHERE room_number = 8
AND starts >= timestamp '2020-03-21 17:00:00'
AND ends <= timestamp '2020-03-22 23:00:00';


/* GET MONTHS OF THE YEAR WHERE PEOPLE BOOK THE MOST */
SELECT count(*) as number_of_bookings_in_month, 
		date_part('Month', booking_created) as busiest_month
FROM public."Bookings"
GROUP BY busiest_month
ORDER BY count(*) desc

/* GET BUSIEST MONTHS OF THE YEAR */
SELECT count(*) as number_of_bookings_in_month, 
		date_part('Month', starts) as busiest_month
FROM public."Booked_Rooms"
GROUP BY busiest_month
ORDER BY count(*) desc


/* GET BUSIEST MONTH OF THE YEAR */
SELECT count(*) as number_of_bookings_in_month
FROM public."Booked_Rooms"
WHERE (starts, ends) OVERLAPS
      (DATE '2020-03-01', DATE '2020-03-01' + interval '1 month -1 day')