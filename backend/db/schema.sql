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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: check_user_login(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_user_login(email text, password text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (
        SELECT
            u.user_id
        FROM
            users u
        WHERE
            u.email = check_user_login.email
            AND u.password = CRYPT(check_user_login.PASSWORD, u.password)
        LIMIT 1);
END
$$;


--
-- Name: create_place_activity(text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_place_activity(place_activity_id text, trip_place_id text, name text, information_url text, start_time text, end_time text, entry_fee text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO place_activities (place_activity_id, trip_place_id, name, information_url, start_time, end_time, entry_fee)
    SELECT
        create_place_activity.place_activity_id::uuid,
        create_place_activity.trip_place_id::uuid,
        create_place_activity.name,
        create_place_activity.information_url,
        create_place_activity.start_time::time,
        create_place_activity.end_time::time,
        create_place_activity.entry_fee::numeric;
    --
    RETURN create_place_activity.place_activity_id;
END
$$;


--
-- Name: create_trip(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_trip(user_id text, trip_id text, destination text, start_date text, end_date text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO trips (trip_id, destination, start_date, end_date)
        VALUES (create_trip.trip_id::uuid, create_trip.destination, create_trip.start_date::date, create_trip.end_date::date);
    --
    INSERT INTO user_trips (user_id, trip_id)
        VALUES (create_trip.user_id::uuid, create_trip.trip_id::uuid);
    --
    RETURN create_trip.trip_id;
END
$$;


--
-- Name: create_user(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_user(user_id text, email text, password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO users (user_id, email, PASSWORD)
        VALUES (create_user.user_id::uuid, create_user.email, create_user.password);
END
$$;


--
-- Name: delete_trip_companions(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_trip_companions(trip_id text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM trip_companions tc
    WHERE tc.trip_id = delete_trip_companions.trip_id::uuid;
    --
    RETURN 'OK';
END
$$;


--
-- Name: place_activities_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.place_activities_view() RETURNS TABLE(trip_id uuid, trip_place_id uuid, place_name text, place_activities json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY WITH activities_ordered_by_end_time AS (
        SELECT
            *
        FROM
            place_activities
        ORDER BY
            end_time
),
activities AS (
    SELECT
        pa.trip_place_id,
        json_agg(json_build_object('place_activity_id', pa.place_activity_id, 'name', pa.name, 'information_url', pa.information_url, 'start_time', TO_CHAR(pa.start_time, 'HH24:MI'), 'end_time', TO_CHAR(pa.end_time, 'HH24:MI'), 'entry_fee', pa.entry_fee)) AS activities
FROM
    activities_ordered_by_end_time pa
GROUP BY
    pa.trip_place_id
)
SELECT
    tp.trip_id,
    tp.trip_place_id,
    tp.name AS place_name,
    coalesce(a.activities, '[]'::json) AS place_activities
FROM
    trip_places tp
    LEFT JOIN activities a ON a.trip_place_id = tp.trip_place_id;
END;
$$;


--
-- Name: trips_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trips_view() RETURNS TABLE(user_id uuid, trip_id uuid, destination text, start_date date, end_date date, places json, companions json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY WITH companions AS (
        SELECT
            tc.trip_id,
            json_agg(json_build_object('trip_companion_id', tc.trip_companion_id, 'name', name, 'email', tc.email)) AS companions
        FROM
            trip_companions tc
        GROUP BY
            tc.trip_id
),
places AS (
    SELECT
        tp.trip_id,
        json_agg(json_build_object('trip_place_id', tp.trip_place_id, 'name', tp.name, 'date', to_char(tp.date, 'YYYY-MM-DD'), 'google_maps_link', tp.google_maps_link)) AS places
    FROM
        trip_places tp
    GROUP BY
        tp.trip_id
),
trips AS (
    SELECT
        ut.user_id AS user_id,
        t.trip_id AS trip_id,
        t.destination AS destination,
        t.start_date AS start_date,
        t.end_date AS end_date
    FROM
        user_trips ut
        LEFT JOIN trips t ON ut.trip_id = t.trip_id
    ORDER BY
        t.start_date ASC
)
SELECT
    tp.user_id,
    tp.trip_id,
    tp.destination,
    tp.start_date,
    tp.end_date,
    coalesce(p.places, '[]'::json) AS places,
    coalesce(c.companions, '[]'::json) AS companions
FROM
    trips tp
    LEFT JOIN companions c ON tp.trip_id = c.trip_id
    LEFT JOIN places p ON tp.trip_id = p.trip_id;
END;
$$;


--
-- Name: update_trip(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_trip(trip_id text, destination text, start_date text, end_date text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        trips
    SET
        destination = update_trip.destination,
        start_date = update_trip.start_date::date,
        end_date = update_trip.end_date::date
    WHERE
        trips.trip_id = update_trip.trip_id::uuid;
    --
    RETURN update_trip.trip_id;
END
$$;


--
-- Name: upsert_trip_companion(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.upsert_trip_companion(trip_companion_id text, trip_id text, name text, email text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            trip_companions tc
        WHERE
            tc.trip_companion_id = upsert_trip_companion.trip_companion_id::uuid) THEN
    INSERT INTO trip_companions (trip_companion_id, trip_id, name, email)
    SELECT
        upsert_trip_companion.trip_companion_id::uuid,
        upsert_trip_companion.trip_id::uuid,
        upsert_trip_companion.name,
        upsert_trip_companion.email;
ELSE
    UPDATE
        trip_companions tc
    SET
        name = upsert_trip_companion.name,
        email = upsert_trip_companion.email
    WHERE
        tc.trip_companion_id = upsert_trip_companion.trip_companion_id::uuid;
END IF;
    --
    RETURN upsert_trip_companion.trip_companion_id;
END
$$;


--
-- Name: upsert_trip_place(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.upsert_trip_place(trip_place_id text, trip_id text, name text, date text, google_maps_link text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            trip_places tp
        WHERE
            tp.trip_place_id = upsert_trip_place.trip_place_id::uuid) THEN
    INSERT INTO trip_places (trip_place_id, trip_id, name, date, google_maps_link)
    SELECT
        upsert_trip_place.trip_place_id::uuid,
        upsert_trip_place.trip_id::uuid,
        upsert_trip_place.name,
        upsert_trip_place.date::date,
        upsert_trip_place.google_maps_link;
ELSE
    UPDATE
        trip_places tp
    SET
        name = upsert_trip_place.name,
        date = upsert_trip_place.date::date,
        google_maps_link = upsert_trip_place.google_maps_link
    WHERE
        tp.trip_place_id = upsert_trip_place.trip_place_id::uuid;
END IF;
    --
    RETURN upsert_trip_place.trip_place_id;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: place_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.place_activities (
    place_activity_id uuid NOT NULL,
    trip_place_id uuid NOT NULL,
    name text NOT NULL,
    information_url text,
    start_time time(0) without time zone,
    end_time time(0) without time zone,
    entry_fee numeric(18,2)
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: trip_companions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trip_companions (
    trip_companion_id uuid NOT NULL,
    trip_id uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL
);


--
-- Name: trip_places; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trip_places (
    trip_place_id uuid NOT NULL,
    trip_id uuid NOT NULL,
    name text NOT NULL,
    date date NOT NULL,
    google_maps_link text
);


--
-- Name: trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trips (
    trip_id uuid NOT NULL,
    destination text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


--
-- Name: user_trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_trips (
    user_id uuid NOT NULL,
    trip_id uuid NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id uuid NOT NULL,
    created_utc timestamp without time zone DEFAULT timezone('utc'::text, now()),
    email text NOT NULL,
    password text NOT NULL
);


--
-- Name: place_activities place_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.place_activities
    ADD CONSTRAINT place_activities_pkey PRIMARY KEY (place_activity_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: trip_companions trip_companions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_companions
    ADD CONSTRAINT trip_companions_pkey PRIMARY KEY (trip_companion_id);


--
-- Name: trip_places trip_places_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_places
    ADD CONSTRAINT trip_places_pkey PRIMARY KEY (trip_place_id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- Name: user_trips user_trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_trips
    ADD CONSTRAINT user_trips_pkey PRIMARY KEY (user_id, trip_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: place_activities place_activities_trip_place_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.place_activities
    ADD CONSTRAINT place_activities_trip_place_id_fkey FOREIGN KEY (trip_place_id) REFERENCES public.trip_places(trip_place_id);


--
-- Name: trip_companions trip_companions_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_companions
    ADD CONSTRAINT trip_companions_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(trip_id);


--
-- Name: trip_places trip_places_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_places
    ADD CONSTRAINT trip_places_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(trip_id);


--
-- Name: user_trips user_trips_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_trips
    ADD CONSTRAINT user_trips_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(trip_id);


--
-- Name: user_trips user_trips_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_trips
    ADD CONSTRAINT user_trips_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20240815005645'),
    ('20240824214726');
