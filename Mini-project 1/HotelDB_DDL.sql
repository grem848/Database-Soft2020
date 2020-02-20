CREATE TABLE "Guests" (
	"id" serial NOT NULL,
	"name" varchar(255) NOT NULL,
	"email" varchar(255) NOT NULL,
	"phone" varchar(255) NOT NULL,
	CONSTRAINT "Guests_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Guest_bookings" (
	"id" serial NOT NULL,
	"guest_id" integer NOT NULL,
	"booking_id" integer NOT NULL,
	CONSTRAINT "Guest_bookings_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Bookings" (
	"id" serial NOT NULL,
	"primary_guest_id" integer NOT NULL,
	"guests_amount" integer NOT NULL,
	"booking_created" TIMESTAMP NOT NULL,
	"is_group_event" BOOLEAN NOT NULL,
	"is_cancelled" BOOLEAN NOT NULL,
	CONSTRAINT "Bookings_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Rooms" (
	"number" integer NOT NULL,
	"price" integer NOT NULL,
	"max_guests" integer NOT NULL,
	CONSTRAINT "Rooms_pk" PRIMARY KEY ("number")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Booked_Rooms" (
	"id" serial NOT NULL,
	"booking_id" integer NOT NULL,
	"room_number" integer NOT NULL,
	"starts" TIMESTAMP NOT NULL,
	"ends" TIMESTAMP NOT NULL,
	CONSTRAINT "Booked_Rooms_pk" PRIMARY KEY ("id")
) WITH (
  OIDS=FALSE
);




ALTER TABLE "Guest_bookings" ADD CONSTRAINT "Guest_bookings_fk0" FOREIGN KEY ("guest_id") REFERENCES "Guests"("id");
ALTER TABLE "Guest_bookings" ADD CONSTRAINT "Guest_bookings_fk1" FOREIGN KEY ("booking_id") REFERENCES "Bookings"("id");

ALTER TABLE "Bookings" ADD CONSTRAINT "Bookings_fk0" FOREIGN KEY ("primary_guest_id") REFERENCES "Guests"("id");


ALTER TABLE "Booked_Rooms" ADD CONSTRAINT "Booked_Rooms_fk0" FOREIGN KEY ("booking_id") REFERENCES "Bookings"("id");
ALTER TABLE "Booked_Rooms" ADD CONSTRAINT "Booked_Rooms_fk1" FOREIGN KEY ("room_number") REFERENCES "Rooms"("number");

