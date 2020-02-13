--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: add_event(text, timestamp without time zone, timestamp without time zone, text, character varying, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_event(title text, starts timestamp without time zone, ends timestamp without time zone, venue text, postal character varying, country character) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
did_insert boolean := false;
found_count integer;
the_venue_id integer;
BEGIN
SELECT venue_id INTO the_venue_id
FROM venues v
WHERE v.postal_code=postal AND v.country_code=country AND v.name ILIKE venue
LIMIT 1;
IF the_venue_id IS NULL THEN
INSERT INTO venues (name, postal_code, country_code)
VALUES (venue, postal, country)
RETURNING venue_id INTO the_venue_id;
did_insert := true;
END IF;
-- Note: this is a notice, not an error as in some programming languages
RAISE NOTICE 'Venue found %', the_venue_id;
INSERT INTO events (title, starts, ends, venue_id)
VALUES (title, starts, ends, the_venue_id);
RETURN did_insert;
END;
$$;


ALTER FUNCTION public.add_event(title text, starts timestamp without time zone, ends timestamp without time zone, venue text, postal character varying, country character) OWNER TO postgres;

--
-- Name: log_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
INSERT INTO logs (event_id, old_title, old_starts, old_ends)
VALUES (OLD.event_id, OLD.title, OLD.starts, OLD.ends);
RAISE NOTICE 'Someone just changed event #%', OLD.event_id;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_event() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cities (
    name text NOT NULL,
    postal_code character varying(9) NOT NULL,
    country_code character(2) NOT NULL,
    CONSTRAINT cities_postal_code_check CHECK (((postal_code)::text <> ''::text))
);


ALTER TABLE public.cities OWNER TO postgres;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    country_code character(2) NOT NULL,
    country_name text
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    event_id integer NOT NULL,
    title text,
    starts timestamp without time zone,
    ends timestamp without time zone,
    venue_id integer,
    colors text[]
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_event_id_seq OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_event_id_seq OWNED BY public.events.event_id;


--
-- Name: holidays; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.holidays AS
 SELECT events.event_id AS holiday_id,
    events.title AS name,
    events.starts AS date,
    events.colors
   FROM public.events
  WHERE ((events.title ~~ '%Day%'::text) AND (events.venue_id IS NULL));


ALTER TABLE public.holidays OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    event_id integer,
    old_title character varying(255),
    old_starts timestamp without time zone,
    old_ends timestamp without time zone,
    logged_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: venues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venues (
    venue_id integer NOT NULL,
    name character varying(255),
    street_address text,
    type character(7) DEFAULT 'public'::bpchar,
    postal_code character varying(9),
    country_code character(2),
    CONSTRAINT venues_type_check CHECK ((type = ANY (ARRAY['public'::bpchar, 'private'::bpchar])))
);


ALTER TABLE public.venues OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venues_venue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venues_venue_id_seq OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venues_venue_id_seq OWNED BY public.venues.venue_id;


--
-- Name: events event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN event_id SET DEFAULT nextval('public.events_event_id_seq'::regclass);


--
-- Name: venues venue_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venues ALTER COLUMN venue_id SET DEFAULT nextval('public.venues_venue_id_seq'::regclass);


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cities (name, postal_code, country_code) FROM stdin;
Portland	97206	us
Gentofte	2820	dk
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.countries (country_code, country_name) FROM stdin;
us	United States
mx	Mexico
au	Australia
gb	United Kingdom
de	Germany
dk	Denmark
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (event_id, title, starts, ends, venue_id, colors) FROM stdin;
1	Fight Club	2018-02-15 17:30:00	2018-02-15 19:30:00	2	\N
2	April Fools Day	2018-04-01 00:00:00	2018-04-01 23:59:00	\N	\N
4	Birthday	2020-12-26 00:00:00	2020-12-26 23:59:59	3	\N
5	Soft Intro Day	2020-02-03 08:30:00	2020-02-03 12:00:00	3	\N
6	Moby	2018-02-06 21:00:00	2018-02-06 23:00:00	1	\N
7	Wedding	2012-02-26 21:00:00	2012-02-26 23:00:00	2	\N
8	Dinner with Mom	2012-02-26 18:00:00	2012-02-26 20:30:00	3	\N
9	Valentine's Day	2012-02-14 00:00:00	2012-02-14 23:59:00	\N	\N
10	House Party	2018-05-03 23:00:00	2018-05-04 01:00:00	4	\N
11	House Party	2018-05-03 23:00:00	2018-05-04 01:00:00	5	\N
3	Christmas Day	2018-12-15 19:30:00	2018-12-25 23:59:00	\N	{red,green}
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (event_id, old_title, old_starts, old_ends, logged_at) FROM stdin;
10	House Party	2018-05-03 23:00:00	2018-05-04 02:00:00	2020-02-06 20:16:16.942893
11	House Party	2018-05-03 23:00:00	2018-05-04 02:00:00	2020-02-06 20:16:16.942893
3	Christmas Day	2018-12-15 19:30:00	2018-12-25 23:59:00	2020-02-06 20:19:29.902878
3	Christmas Day	2018-12-15 19:30:00	2018-12-25 23:59:00	2020-02-06 20:20:10.311005
3	Christmas Day	2018-12-15 19:30:00	2018-12-25 23:59:00	2020-02-06 20:21:02.221386
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.venues (venue_id, name, street_address, type, postal_code, country_code) FROM stdin;
1	Crystal Ballroom	\N	public 	97206	us
2	Voodoo Doughnut	\N	public 	97206	us
3	My Place	Soløsevej 19	private	2820	dk
4	Run's House	\N	public 	97206	us
5	Run's House	\N	public 	97206	us
\.


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_event_id_seq', 11, true);


--
-- Name: venues_venue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venues_venue_id_seq', 5, true);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (country_code, postal_code);


--
-- Name: countries countries_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_country_name_key UNIQUE (country_name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_code);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (venue_id);


--
-- Name: events_starts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_starts ON public.events USING btree (starts);


--
-- Name: events_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_title ON public.events USING hash (title);


--
-- Name: holidays update_holidays; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE update_holidays AS
    ON UPDATE TO public.holidays DO INSTEAD  UPDATE public.events SET title = new.name, starts = new.date, colors = new.colors
  WHERE (events.title = old.name);


--
-- Name: events log_events; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_events AFTER UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.log_event();


--
-- Name: cities cities_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_country_code_fkey FOREIGN KEY (country_code) REFERENCES public.countries(country_code);


--
-- Name: events events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(venue_id);


--
-- Name: venues venues_country_code_postal_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_country_code_postal_code_fkey FOREIGN KEY (country_code, postal_code) REFERENCES public.cities(country_code, postal_code) MATCH FULL;


--
-- PostgreSQL database dump complete
--

