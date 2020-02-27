/*  UPDATE ROOM PRICE FROM ROOM NUMBER */

CREATE OR REPLACE PROCEDURE updateroompricefromroomnumber(
	pricee integer,
	roomnumberr integer)
LANGUAGE 'plpgsql'

AS $$
BEGIN  
UPDATE public."Rooms"
SET price=pricee
WHERE number=roomnumberr;

RETURN;
END; $$;

-- CALL updateroompricefromroomnumber(7000, 1);


/* UPDATE ROOM PRICE FROM MAX_GUESTS */

CREATE OR REPLACE PROCEDURE updateroompricefrommaxguests(
	pricee integer,
	maxguests integer)
    LANGUAGE 'plpgsql'
    
AS $$
BEGIN  
UPDATE public."Rooms"
SET price=pricee
WHERE max_guests=maxguests;

RETURN;
END; $$;

-- CALL updateroompricefrommaxguests(2000, 2);


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




/* TRIGGER FUNCTION TO AVOID CANCELLATION WITHIN 24 HOURS OF BOOKING START */
CREATE OR REPLACE FUNCTION cancellationCheck24H() 
	RETURNS TRIGGER AS 
$BODY$ 
DECLARE
start_date TIMESTAMP;
compare_date TIMESTAMP;
BEGIN  
	IF new.is_cancelled IS TRUE THEN
		start_date := (select starts from public."Booked_Rooms" where booking_id = old.id);
		RAISE NOTICE 'start_date: %', start_date;
		compare_date := (now() + interval '24 hours');
		RAISE NOTICE 'compare_date: %', compare_date;
		
		IF start_date < compare_date THEN
			RAISE EXCEPTION 'CANNOT CANCEL WITHIN 24 HOURS OF BOOKING START!';
		ELSE
			RETURN NEW;
		END IF;
	END IF;
	RETURN NEW;
END;  
$BODY$ 
LANGUAGE plpgsql;  

/* TRIGGER FOR TABLE BOOKINGS */
DROP TRIGGER cancellationcheck24h ON public."Bookings";
CREATE TRIGGER cancellationcheck24h
    BEFORE UPDATE OF is_cancelled
    ON public."Bookings"
    FOR EACH ROW
    EXECUTE PROCEDURE public.cancellationcheck24h();
	
	
/* CREATE FULL BOOKING */
DO $$
	DECLARE
   		bookings integer := (SELECT count(*) 
					 FROM public."Booked_Rooms" 
					 WHERE room_number = 8  
					 AND starts >= timestamp '2020-03-22 10:00:00'  
					 AND ends <= timestamp '2020-03-23 10:00:00');
		timeNow TIMESTAMP := now();
		booking_id integer;
BEGIN
	IF bookings > 0 THEN
		RAISE EXCEPTION 'ALREADY BOOKED';
	ELSE 
		INSERT INTO "Bookings" (primary_guest_id, guests_amount, booking_created, is_group_event, is_cancelled)  VALUES ( 1, 20, timeNow, TRUE , FALSE);
		booking_id := (SELECT id FROM "Bookings" WHERE primary_guest_id = 1 AND guests_amount = 20 AND booking_created = timeNow AND is_group_event = TRUE AND is_cancelled =  FALSE);
		RAISE WARNING 'booking_id is %', booking_id;
	END IF;
	INSERT INTO "Guest_bookings" ( guest_id, booking_id) VALUES ( 1, booking_id );
	INSERT INTO "Booked_Rooms" ( booking_id, room_number, starts, ends ) VALUES (booking_id, 8 , '2020-03-22 10:00:00', '2020-03-23 10:00:00' );
	EXCEPTION 
		WHEN OTHERS THEN 
		RAISE WARNING 'EXCEPTION CALLED ';
		ROLLBACK;
	RAISE NOTICE 'BOOKING SUCCESSFUL';
	COMMIT;
END $$;
