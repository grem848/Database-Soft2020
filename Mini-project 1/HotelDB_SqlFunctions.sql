/*  UPDATE ROOM PRICE FROM ROOM NUMBER */

CREATE OR REPLACE FUNCTION updateRoomPriceFromRoomNumber (pricee integer, roomnumberr integer) 
   RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN  
UPDATE public."Rooms"
SET price=pricee
WHERE number=roomnumberr;

RETURN FOUND;
END; $$ 

-- Run -> SELECT * FROM updateRoomPriceFromRoomNumber(6000, 3); */



/* UPDATE ROOM PRICE FROM MAX_GUESTS */

CREATE OR REPLACE FUNCTION updateRoomPriceFromMaxGuests (pricee integer, maxguests integer) 
   RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN  
UPDATE public."Rooms"
SET price=pricee
WHERE max_guests=maxguests;

RETURN FOUND;
END; $$ 

-- Run ->  SELECT * FROM updateRoomPriceFromMaxGuests(1000, 1);



/* GET LOYAL CLIENTS */

CREATE OR REPLACE FUNCTION getLoyalClients () 
   RETURNS TABLE (
      p_guest_id INT,
      n_of_visits BIGINT
) 
AS $$
BEGIN
   RETURN QUERY 
  
SELECT primary_guest_id, count(primary_guest_id) as number_of_visits
FROM public."Bookings"
GROUP BY primary_guest_id
HAVING count(primary_guest_id) > 1 
ORDER BY number_of_visits desc;

END; $$ 
 
LANGUAGE 'plpgsql';

-- Run -> SELECT * FROM getLoyalClients()



/* GET CONFERENCE SCHEDULE */

CREATE OR REPLACE FUNCTION getConferenceSchedule (startsss timestamp without time zone, endsss timestamp without time zone) 
   RETURNS TABLE (
      bookedrooms_id INT,
	  bookings_id INT,
	  roomnumber INT,
	  startss TIMESTAMP WITHOUT TIME ZONE,
	  endss TIMESTAMP WITHOUT TIME ZONE
) 
AS $$
BEGIN
   RETURN QUERY 
  
SELECT *
FROM public."Booked_Rooms"
WHERE room_number = 10 
AND starts >= startsss
AND ends <= endsss;

END; $$ 
 
LANGUAGE 'plpgsql';

-- Run -> SELECT * FROM getConferenceSchedule(timestamp '2020-03-20 01:00:00', timestamp '2020-03-20 23:00:00');



/* ROOM AVAILABILITY */

CREATE OR REPLACE FUNCTION getRoomAvailability (roomnumberr integer, startsss timestamp without time zone, endsss timestamp without time zone) 
   RETURNS TABLE (
      bookedrooms_id INT,
	  bookings_id INT,
	  roomnumber INT,
	  startss TIMESTAMP WITHOUT TIME ZONE,
	  endss TIMESTAMP WITHOUT TIME ZONE
) 
AS $$
BEGIN
   RETURN QUERY 
  
SELECT *
FROM public."Booked_Rooms"
WHERE room_number = roomnumberr
AND starts >= startsss
AND ends <= endsss;

END; $$ 
 
LANGUAGE 'plpgsql';

-- Run -> SELECT * FROM getRoomAvailability(8, timestamp '2020-03-20 01:00:00', timestamp '2020-03-20 23:00:00');



/* GET BUSIEST BOOKING MONTH */

CREATE OR REPLACE FUNCTION getBusyBookingMonths () 
   RETURNS TABLE (
      numberOfBookingsInMonth BIGINT,
      busiestMonth DOUBLE PRECISION
) 
AS $$
BEGIN
   RETURN QUERY 
  
SELECT count(*) as number_of_bookings_in_month, 
		date_part('Month', booking_created) as busiest_month
FROM public."Bookings"
GROUP BY busiest_month
ORDER BY count(*) desc;

END; $$ 
 
LANGUAGE 'plpgsql';

-- Run -> SELECT * FROM getBusyBookingMonths();


/* GET BUSIEST MONTH OF YEAR */
CREATE OR REPLACE FUNCTION getNumberOfBookingsInMonth (startss date, endss date) 
   RETURNS TABLE (
      numberOfBookingsInMonth BIGINT
) 
AS $$
BEGIN
   RETURN QUERY 
  
SELECT count(*) as number_of_bookings_in_month
FROM public."Booked_Rooms"
WHERE (starts, ends) OVERLAPS
      (startss, endss + interval '1 month -1 day');

END; $$ 
 
LANGUAGE 'plpgsql';

-- Run --> SELECT * FROM getNumberOfBookingsInMonth(date '2020-03-01', date '2020-03-01')