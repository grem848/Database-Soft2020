-- Build test data

BEGIN;
INSERT INTO public."Guests"
("name", email, phone)
SELECT 
	left(md5(i::text), 10) AS name ,
	  'user_' || i || '@' || (
	    CASE (RANDOM() * 2)::INT
	      WHEN 0 THEN 'gmail'
	      WHEN 1 THEN 'hotmail'
	      WHEN 2 THEN 'yahoo'
	    END
	  ) || '.com' AS email,
   	floor(random()*(99999999-10000000+1))+10000000 AS phone
FROM generate_series(1, 20) s(i);


INSERT INTO public."Bookings"
(primary_guest_id, guests_amount, booking_created, is_group_event, is_cancelled)
SELECT
	floor(random()*(0-9+1))+9 AS primary_guest_id,
	floor(random()*(0-5+1))+5 AS guests_amount,
	timestamp '2020-01-20 10:00:00' +
       random() * (timestamp '2020-01-20 10:00:00' -
                   timestamp '2020-01-01 20:00:00'),
 	cast(cast(random() AS integer) AS boolean) AS is_group_event,
 	cast(cast(random() AS integer) AS boolean) AS is_cancelled
FROM generate_series(1, 10);


INSERT INTO public."Guest_bookings"
(guest_id, booking_id)
SELECT
	floor(random()*(10-21+1))+21 AS guest_id,
	floor(random()*(0-9+1))+9 AS booking_id
FROM generate_series(1,10);

INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(1, 4000, 2);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(2, 2000, 2);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(3, 500, 2);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(4, 500, 2);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(5, 300, 1);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(6, 400, 1);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(7, 450, 1);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(8, 20000, 50);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(9, 35000, 80);
INSERT INTO public."Rooms"
("number", price, max_guests)
VALUES(10, 60000, 120);

INSERT INTO public."Booked_Rooms"
(booking_id, room_number, starts, ends)
SELECT
	floor(random()*(0-9+1))+9 AS booking_id,
	floor(random()*(0-9+1))+9 AS room_number,
	timestamp '2020-03-20 10:00:00',
	timestamp '2020-03-21 16:00:00'
FROM generate_series(1,10);


END;