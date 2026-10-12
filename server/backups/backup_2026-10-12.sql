--
-- PostgreSQL database dump
--

\restrict dU7Jz9oBV0NqZkJqlbcgDj8H5m8Nd479ZcDyW19kHrcecxXVhmiakJdbhargdV4

-- Dumped from database version 17.11 (7d7ea2a)
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: neon_auth; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

CREATE SCHEMA neon_auth;


ALTER SCHEMA neon_auth OWNER TO neondb_owner;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: registration_approvals_status_enum; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.registration_approvals_status_enum AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE public.registration_approvals_status_enum OWNER TO neondb_owner;

--
-- Name: time_entries_type_enum; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.time_entries_type_enum AS ENUM (
    'WORK',
    'SICK',
    'VAB',
    'VACATION',
    'MEETING',
    'DAY_OFF',
    'RED_DAY'
);


ALTER TYPE public.time_entries_type_enum OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users_sync; Type: TABLE; Schema: neon_auth; Owner: neondb_owner
--

CREATE TABLE neon_auth.users_sync (
    raw_json jsonb NOT NULL,
    id text GENERATED ALWAYS AS ((raw_json ->> 'id'::text)) STORED NOT NULL,
    name text GENERATED ALWAYS AS ((raw_json ->> 'display_name'::text)) STORED,
    email text GENERATED ALWAYS AS ((raw_json ->> 'primary_email'::text)) STORED,
    created_at timestamp with time zone GENERATED ALWAYS AS (to_timestamp((trunc((((raw_json ->> 'signed_up_at_millis'::text))::bigint)::double precision) / (1000)::double precision))) STORED,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE neon_auth.users_sync OWNER TO neondb_owner;

--
-- Name: User; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    email character varying(20) NOT NULL,
    "passwordHash" character varying(255) NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public."User" OWNER TO neondb_owner;

--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_id_seq" OWNER TO neondb_owner;

--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO neondb_owner;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO neondb_owner;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: news_post; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.news_post (
    id integer NOT NULL,
    header character varying NOT NULL,
    text character varying NOT NULL,
    genre character varying DEFAULT 'Other'::character varying NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    "isPrivate" boolean DEFAULT false NOT NULL,
    "createDate" timestamp without time zone DEFAULT now() NOT NULL,
    "authorId" integer
);


ALTER TABLE public.news_post OWNER TO neondb_owner;

--
-- Name: news_post_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.news_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.news_post_id_seq OWNER TO neondb_owner;

--
-- Name: news_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.news_post_id_seq OWNED BY public.news_post.id;


--
-- Name: project_assignments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    comment text,
    "projectId" uuid,
    "userId" uuid,
    hours numeric(5,2) NOT NULL,
    "breakMinutes" integer DEFAULT 0 NOT NULL,
    "startTime" time without time zone,
    "endTime" time without time zone,
    date date NOT NULL
);


ALTER TABLE public.project_assignments OWNER TO neondb_owner;

--
-- Name: project_images; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_images (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    url character varying NOT NULL,
    "publicId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "projectId" uuid NOT NULL
);


ALTER TABLE public.project_images OWNER TO neondb_owner;

--
-- Name: project_material_items; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_material_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "materialId" uuid NOT NULL,
    quantity numeric(10,2),
    price numeric(10,2),
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "materialKey" character varying(100) NOT NULL,
    note text
);


ALTER TABLE public.project_material_items OWNER TO neondb_owner;

--
-- Name: project_materials; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_materials (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "projectId" uuid NOT NULL,
    title text,
    other text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_materials OWNER TO neondb_owner;

--
-- Name: project_receipts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_receipts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    url character varying NOT NULL,
    "publicId" character varying NOT NULL,
    "projectId" uuid NOT NULL,
    description character varying,
    amount numeric(10,2),
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_receipts OWNER TO neondb_owner;

--
-- Name: project_task; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.project_task (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    done boolean DEFAULT false NOT NULL,
    "completedByName" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "completedAt" timestamp without time zone,
    comment text,
    "projectId" uuid,
    "completedById" uuid,
    "photoUrls" text[],
    note text,
    "attentionNote" text
);


ALTER TABLE public.project_task OWNER TO neondb_owner;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.projects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    city text,
    address text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "pricePerM2" numeric,
    "areaM2" numeric,
    "pricePerExtraH" numeric
);


ALTER TABLE public.projects OWNER TO neondb_owner;

--
-- Name: registration_approvals; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.registration_approvals (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userId" uuid,
    "tokenHash" character varying(64) NOT NULL,
    status public.registration_approvals_status_enum DEFAULT 'pending'::public.registration_approvals_status_enum NOT NULL,
    "expiresAt" timestamp with time zone NOT NULL,
    "usedAt" timestamp with time zone,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    email character varying(320) NOT NULL,
    name character varying(255) NOT NULL,
    "passwordHash" character varying(255) NOT NULL
);


ALTER TABLE public.registration_approvals OWNER TO neondb_owner;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.sessions (
    token character varying NOT NULL,
    refresh_token character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    "lastActivityAt" timestamp without time zone,
    expires_at timestamp without time zone DEFAULT now() NOT NULL,
    "userId" uuid,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    access_token_expires_at timestamp without time zone,
    refresh_token_expires_at timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO neondb_owner;

--
-- Name: time_entries; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.time_entries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date date NOT NULL,
    hours numeric(5,2) NOT NULL,
    type public.time_entries_type_enum NOT NULL,
    comment text,
    "userId" uuid NOT NULL,
    "projectId" uuid,
    "breakMinutes" integer DEFAULT 0 NOT NULL,
    "startTime" time without time zone,
    "endTime" time without time zone
);


ALTER TABLE public.time_entries OWNER TO neondb_owner;

--
-- Name: user_salary_history; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.user_salary_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "fromDate" timestamp without time zone DEFAULT now() NOT NULL,
    "userId" uuid,
    salary double precision,
    "salaryNetto" double precision
);


ALTER TABLE public.user_salary_history OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "isAdmin" boolean DEFAULT false NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserId" uuid,
    "CanCreateProjects" boolean DEFAULT false NOT NULL,
    "SpecialCan" boolean DEFAULT false NOT NULL,
    "currentSalary" integer
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: news_post id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.news_post ALTER COLUMN id SET DEFAULT nextval('public.news_post_id_seq'::regclass);


--
-- Data for Name: users_sync; Type: TABLE DATA; Schema: neon_auth; Owner: neondb_owner
--

COPY neon_auth.users_sync (raw_json, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public."User" (id, email, "passwordHash", deleted) FROM stdin;
1	test@gmail.com	$2b$10$KrfetxcxRfvquhMdG6.23Ogt.M3nhQ/t9H1hj1Mvi8hWM.Rla.Rk.	f
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1766934844592	AutoMigrationAddUser1766934844592
2	1766940012880	AutoMigrationAddProjectAndRelations1766940012880
3	1767265559051	AutoMigrationAddSessionTimeEntries1767265559051
4	1767292926915	AutoMigrationAddSessionFix1767292926915
5	1767655569989	AutoMigrationAddProjectImages1767655569989
6	1768078230198	AutoMigrationAddStartEndTime1768078230198
7	1768542505191	AutoMigrationChangeProgectAssignmentComment1768542505191
8	1768598250854	AutoMigrationChangeProjectAssignment1768598250854
9	1768633695833	AutoMigrationAddProjectAssignmentDate1768633695833
10	1769321195198	AutoMigrationAddProjectImagesProjectId1769321195198
11	1771268490865	AutoMigrationAddSoftDeleteUser1771268490865
12	1774765456495	AutoMigrationAddIndexToSessions1774765456495
13	1774767841179	AutoMigrationAddIndexToSessions21774767841179
14	1777136116400	AutoMigrationAddUserFieldsAddDayOffAddRedDay1777136116400
15	1778664758976	AutoMigrationAddUserFieldsAddSallaryHistoryAddProjectM21778664758976
16	1778687831849	AutoMigrationAddUserFieldsAddСurrentSallary1778687831849
17	1778692529724	AutoMigrationAddUserFieldsSallaryHistoryCreateDateColumn1778692529724
18	1779125314520	AutoMigrationAddProjectPriceExtraH1779125314520
19	1780170450436	AutoMigrationAddProjectTask1780170450436
20	1780173249114	AutoMigrationProjectTaskPhotoUrls1780173249114
21	1780798485037	AutoMigrationProjectTaskAddAttentionNote1780798485037
22	1785074278559	AutoMigrationProjectTaskAddReceipt1785074278559
23	1785688600378	AutoMigrationProjectMaterialList1785688600378
24	1787392957453	AutoMigrationAddSessionEntity1787392957453
25	1787507952332	AutoMigrationChangeProjectMaterial1787507952332
26	1791142186801	AutoMigrationAddRegistrationApproval1791142186801
27	1791231903181	AutoMigrationAddRegistrationApprovalNameEmail1791231903181
\.


--
-- Data for Name: news_post; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.news_post (id, header, text, genre, deleted, "isPrivate", "createDate", "authorId") FROM stdin;
1	Something	some text	Politic	f	f	2026-04-06 05:39:27.475683	1
\.


--
-- Data for Name: project_assignments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_assignments (id, comment, "projectId", "userId", hours, "breakMinutes", "startTime", "endTime", date) FROM stdin;
aa95025d-2adb-4220-9cad-0b7a59a038ad	Scaffolding 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.50	30	08:00:00	15:00:00	2026-05-15
dfe3f6d9-29c1-419e-9210-6328b2f75d7f	Cupor	54629585-9337-4f55-8977-036ff89a2e2b	90ce269a-9472-4447-86cc-6f1a1519d31f	3.50	30	12:00:00	16:00:00	2026-01-16
2376e4c6-8bba-47bf-822f-00ac8185879a	Cuppor z-panel	54629585-9337-4f55-8977-036ff89a2e2b	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	15:00:00	17:00:00	2026-01-17
f925c94d-eda8-489c-bf5d-7177ddf0c868	Takkupor z-pannels 	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7.00	30	09:30:00	17:00:00	2026-01-17
bec6e4a5-acce-41c5-ade4-7dc9cbd3462b	snow cleaning, cutting roof	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8.00	30	08:30:00	17:00:00	2026-01-05
d70db961-6c8d-4646-a320-9a46ed2ca7ca	snow cleaning, cutting roof, painting	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7.00	60	08:30:00	16:30:00	2026-01-08
fe3a1b14-3076-4a9b-9bc6-026c22d6421b	ripped z-panells takkupor	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	16:00:00	17:00:00	2026-01-09
7195f78b-1fd9-487e-9995-f4f23a1dc1c4	Takkupor z-pannels 	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7.00	30	09:00:00	16:30:00	2026-01-18
1151b862-bc60-4d4f-b939-fd1618724373	Cuppor z-panel, ventilation 	54629585-9337-4f55-8977-036ff89a2e2b	90ce269a-9472-4447-86cc-6f1a1519d31f	8.50	30	08:00:00	17:00:00	2026-01-19
dabf6b82-080d-46b5-aa12-6ee41f7673c0	Takkupor z-pannels, ventilation 	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8.50	30	08:00:00	17:00:00	2026-01-19
0fdfa289-43e6-4747-a49f-2581950b30aa	Ställning	4813a930-e772-4adf-85d8-0448d373f829	90ce269a-9472-4447-86cc-6f1a1519d31f	6.50	30	08:00:00	15:00:00	2026-05-15
a50317b4-d60c-4436-ada3-be7c9e4d9b40	Ställning	1518522b-892b-47ef-afe6-b56caa69af4c	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	0	09:00:00	12:00:00	2026-03-20
3ec081c6-871e-422b-91d7-9455b3b3ac29	Montera fonster plåt, drill hole for wire. 	54629585-9337-4f55-8977-036ff89a2e2b	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	0	08:00:00	11:00:00	2026-01-23
b3409193-d8cb-4bae-a724-662705b41e0d	takkupor - frame leghts, z-pannels	54629585-9337-4f55-8977-036ff89a2e2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.50	0	12:30:00	16:00:00	2026-01-16
f4892fa2-59cd-4db0-9326-f209c8e1cb02	Taking down ställning	f36437da-0d4c-4db0-9e26-1bbc83e02c10	90ce269a-9472-4447-86cc-6f1a1519d31f	5.00	0	12:30:00	17:30:00	2026-02-05
030eadd8-a1ee-40db-9bc9-c0dc1a8bccd1	Scaffolding 	f36437da-0d4c-4db0-9e26-1bbc83e02c10	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.00	0	12:30:00	17:30:00	2026-02-05
b743a164-078f-4634-a5e0-55f58d7afd77	Ställning	ac4896b2-f0c4-4da1-a604-5213681e663e	90ce269a-9472-4447-86cc-6f1a1519d31f	2.50	0	12:30:00	15:00:00	2026-02-09
890d44ec-fef0-44a8-998f-c13e2d5ce6c9	Scaffolding 	ac4896b2-f0c4-4da1-a604-5213681e663e	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.50	30	08:00:00	15:00:00	2026-02-09
f8341cf0-bffb-4c1c-a3b2-fbcc705feed8	Ställning 	ac4896b2-f0c4-4da1-a604-5213681e663e	7f7fff21-8568-4d80-bec5-77001d7bbf7d	6.50	30	08:00:00	15:00:00	2026-02-09
e54d4009-9c9c-4820-96e1-9ace9da44437	Ställning	f40904f2-dc04-4c56-8c6b-259d63237a2b	90ce269a-9472-4447-86cc-6f1a1519d31f	1.50	30	12:00:00	14:00:00	2026-03-20
ab339bc6-773a-4119-8c0a-7c8384af5d71	Scaffolding 	f40904f2-dc04-4c56-8c6b-259d63237a2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	30	12:00:00	14:00:00	2026-03-20
fa6c3e08-43a9-4d3a-8d37-f505ce3c5192	Rivit ställning 	f40904f2-dc04-4c56-8c6b-259d63237a2b	db131598-bdda-42c3-936d-27229529abfb	2.00	30	12:00:00	14:30:00	2026-03-20
616afd76-1f4c-4738-9769-f8725b698cad	Ställning	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	90ce269a-9472-4447-86cc-6f1a1519d31f	6.00	60	09:00:00	16:00:00	2026-02-23
e6adf798-7567-43c5-a765-24a6f5b66b96		284d06c0-f938-40ae-8ef1-aa1d3e354eb9	db131598-bdda-42c3-936d-27229529abfb	6.00	60	09:00:00	16:00:00	2026-02-23
8850ad76-e17a-4e9a-9652-34fa936f950d	Scaffolding 	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	60	09:00:00	16:00:00	2026-02-23
6c5d79e3-01fb-4cf9-8186-74a1810bdf7a		284d06c0-f938-40ae-8ef1-aa1d3e354eb9	7f7fff21-8568-4d80-bec5-77001d7bbf7d	6.00	60	09:00:00	16:00:00	2026-02-23
678546af-d5b0-4cc9-a17c-cc1ba5815d26	Changing råspond, all hours (my and Ryslan)	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	90ce269a-9472-4447-86cc-6f1a1519d31f	6.00	30	10:00:00	16:30:00	2026-02-27
c5bc4237-10df-42db-b0b6-3e158008bfa8	Demolition and changing respond on takkupor 	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	08:00:00	09:00:00	2026-03-04
1ce69c14-423f-4ce7-8d9e-6ebb720e7a3b		f40904f2-dc04-4c56-8c6b-259d63237a2b	db131598-bdda-42c3-936d-27229529abfb	8.00	0	08:00:00	16:00:00	2026-03-02
f5090bf0-e58f-4090-bd80-d5bed4537caa	Tagit spik	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	db131598-bdda-42c3-936d-27229529abfb	7.50	60	07:30:00	16:00:00	2026-03-05
ff5466ba-b298-4738-bf34-a3015ba16bd3	Tagit spik 	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	db131598-bdda-42c3-936d-27229529abfb	5.50	30	08:00:00	14:00:00	2026-03-06
c5784775-5ce1-496c-acdd-28af78c0348d	Changing råspond	f40904f2-dc04-4c56-8c6b-259d63237a2b	90ce269a-9472-4447-86cc-6f1a1519d31f	0.50	0	15:30:00	16:00:00	2026-03-10
8f7b69ec-eac7-4134-8d7f-392aa538302f		284d06c0-f938-40ae-8ef1-aa1d3e354eb9	db131598-bdda-42c3-936d-27229529abfb	1.00	0	07:00:00	08:00:00	2026-03-10
c1f1eb65-8e63-441f-839e-4f42f6b7fb87	Demolition plastic roof	f40904f2-dc04-4c56-8c6b-259d63237a2b	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	07:00:00	08:00:00	2026-03-13
e919c88d-d824-4517-9de9-2ea191afa35d	Demolition plastic roof 	f40904f2-dc04-4c56-8c6b-259d63237a2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:00:00	08:00:00	2026-03-13
bb9de7a8-c6f0-4d3f-abcf-2b6aaed4b9b7	Byggt ställning 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	db131598-bdda-42c3-936d-27229529abfb	5.50	30	07:00:00	13:00:00	2026-03-23
b5b0575f-70b3-42fe-a564-d10a00bd0118	Scaffolding 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.50	30	07:00:00	13:00:00	2026-03-23
fbad92d2-c656-4112-b1b2-0da15ea83441	Demolition cuppor, futplot cuppors	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	16:00:00	17:00:00	2026-04-09
205e68b1-9c72-43cc-b7dd-3f00a2cb718f	Ställning	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	5.50	30	07:00:00	13:00:00	2026-03-23
3398b2c1-e98a-48e0-b0e9-98dbdac782eb	Front panel, road, buying and montera insekts net	f40904f2-dc04-4c56-8c6b-259d63237a2b	90ce269a-9472-4447-86cc-6f1a1519d31f	1.50	0	11:30:00	13:00:00	2026-03-25
3b26c40c-22be-4d26-96ce-2b4cdf384f67	Frontpana	f40904f2-dc04-4c56-8c6b-259d63237a2b	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	12:00:00	13:00:00	2026-03-25
bdfd4834-6e53-47bf-8fed-41ac58ba2121	Painting windhuivas 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	16:00:00	19:00:00	2026-03-30
18d74cc8-0091-4149-80e0-260a2c2ef135	Painting windhuivas 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	16:30:00	19:30:00	2026-03-31
14c8ea8b-5ce8-4d7c-b3af-9df2fd079e5a	Cuppor ränna, hooks, frezer 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	17:00:00	19:00:00	2026-03-31
dacf8d49-fe9f-40b3-b1b9-7e3012e02d06	Painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	14:00:00	17:00:00	2026-04-01
7747fcdd-8695-41c0-a9fd-3dd4898f4420	Painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	30	07:00:00	13:30:00	2026-04-02
3caeb2a1-a3e5-485a-8828-2db509273401	Painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4.00	0	13:00:00	17:00:00	2026-04-03
84409ad6-dad2-46e6-bdfe-4b756c955ae1	Painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	16:00:00	19:00:00	2026-04-07
087e46aa-4d22-4e4d-b633-41ef3d52e00b	Ränna cuppor	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	15:30:00	16:30:00	2026-04-08
a56fc380-3f27-447d-8bbc-a69bbd1cef89	Demolition takkupors old lockpannels, painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:00:00	08:00:00	2026-04-09
4ea943fe-d684-4c7f-bf08-14e74dd4f414	Gavel plåt, vindpapp	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	1.50	0	17:00:00	18:30:00	2026-04-10
a9d8d478-74db-48c4-826a-4f042ba90696	Dubeln leghts frame govel, windpapp govel, windpapp takkupors, cleaning 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	12.00	30	07:30:00	20:00:00	2026-04-10
d502973a-526a-4a08-b168-d77b1a7c7f3b	Dubeln leghts frame govel, windpapp govel, cleaning	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8.00	30	08:00:00	16:30:00	2026-04-11
522f2179-cb8c-41b4-ae62-1c416eb75a57	Trikant- bottom parts, demolition gåvel lockpannels, preceiling gåvel, collect old pannels, cleaning 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.50	0	13:30:00	19:00:00	2026-04-02
25292d0b-5a0d-4f10-a66f-8c47d205a335	Demolition old gåvel wood, collect	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4.50	0	07:00:00	11:30:00	2026-04-07
8ab58496-1069-4a1c-ac2f-dc4df510090b	Govel plåt, fönster plåt, hjälpa Ruslan med govel, vindskrivor cuppor	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	4.00	0	07:30:00	11:30:00	2026-04-13
3bb971dc-605d-4c06-b713-1fa3f8a9b1ca	Painting takkupors bottom parts, govel desks 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	10.50	30	09:00:00	20:00:00	2026-04-13
b2d95607-cc7c-4514-987f-1476e7fa3320	Vindskrivor cuppor	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	06:30:00	07:30:00	2026-04-14
baf8170b-4426-4a67-92c8-275c57f3f0e3	Govel lockpannels, painting 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	10.00	60	09:00:00	20:00:00	2026-04-14
32e310cf-7059-4c1c-8d31-4185acb60802	Painting, hjälp med gavel	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	30	12:00:00	15:30:00	2026-04-15
6d2cfc5b-c210-41c9-bce0-b9df9dd0c5a4	Govel lockpannels 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	12.50	30	07:00:00	20:00:00	2026-04-15
31785d93-56a3-4748-aacc-e2691950a3f4	Govel lockpannels 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	11.50	30	08:00:00	20:00:00	2026-04-16
81255361-a6b2-4904-93a9-b525838b3da9	Picking up plåt govel, govel, paint	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	8.00	30	07:30:00	16:00:00	2026-04-17
c8a6bea8-3480-430d-bc61-1731e7d8ca15	Gavel	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	90ce269a-9472-4447-86cc-6f1a1519d31f	7.50	30	07:30:00	15:30:00	2026-04-16
f48e3db8-9f2b-4c6e-b7e2-9d3660860bf8	Govel lockpannels, painting govel	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8.50	30	07:00:00	16:00:00	2026-04-17
89122e77-857d-407a-b5ce-cd2f2dc084a6	Govel lockpannels, painting, metal around windows, windhuiva metal garage	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	9.50	30	07:00:00	17:00:00	2026-04-27
b569c0f2-2e83-4ffa-96d0-0af73b377be7	Vindskrivor plåt på cuppor new, because old didn't worked.	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	18:00:00	19:00:00	2026-05-14
9171b317-82cf-4285-b258-d36a4c015ee8	Murat 	f36437da-0d4c-4db0-9e26-1bbc83e02c10	db131598-bdda-42c3-936d-27229529abfb	7.50	30	07:00:00	15:00:00	2026-04-27
26a09840-5b9f-4a86-a492-ca733f7cea46	Murat	f36437da-0d4c-4db0-9e26-1bbc83e02c10	db131598-bdda-42c3-936d-27229529abfb	8.00	30	07:30:00	16:00:00	2026-04-20
2a9edecf-fc9f-4510-b11c-20809a68da78	Murat 	f36437da-0d4c-4db0-9e26-1bbc83e02c10	db131598-bdda-42c3-936d-27229529abfb	4.50	30	07:00:00	12:00:00	2026-04-21
a7c75d3d-0c6b-4892-be17-20e2460a5b98	Murat 	f36437da-0d4c-4db0-9e26-1bbc83e02c10	db131598-bdda-42c3-936d-27229529abfb	8.50	30	07:00:00	16:00:00	2026-04-22
22a594c5-7d26-401d-8c59-af8f23b350ce	Rivit ställning 	f36437da-0d4c-4db0-9e26-1bbc83e02c10	db131598-bdda-42c3-936d-27229529abfb	1.00	0	15:00:00	16:00:00	2026-04-27
635f9394-c3a7-4792-aefc-9e4f0013e70c	Paint and tape doors 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	7f7fff21-8568-4d80-bec5-77001d7bbf7d	7.50	30	08:00:00	16:00:00	2026-04-23
8062556b-c739-4ed0-8913-93b4cbe5c374	Tape doors	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	7f7fff21-8568-4d80-bec5-77001d7bbf7d	2.50	30	08:00:00	11:00:00	2026-04-22
1851c02a-6968-4974-a593-00682d066214	Paind 2 3 layer doors garage 	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	7f7fff21-8568-4d80-bec5-77001d7bbf7d	7.00	60	08:00:00	16:00:00	2026-04-24
7e31b244-8890-48af-9151-e1ae5dadc611	Ställning	4813a930-e772-4adf-85d8-0448d373f829	90ce269a-9472-4447-86cc-6f1a1519d31f	9.00	30	08:00:00	17:30:00	2026-05-18
66a3f8c9-4899-460a-a2c5-8a662316c97d	Scaffolding 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	10.00	30	07:00:00	17:30:00	2026-05-18
09fdf72b-d5b1-4206-ac41-a9ff6eff195f	Stege	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	90ce269a-9472-4447-86cc-6f1a1519d31f	5.00	0	14:00:00	19:00:00	2026-05-21
b3047606-d8e6-4034-839f-6526b92eabaf	Stege, last peace 	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	07:00:00	09:00:00	2026-05-22
fd893ebb-8c7f-4464-9a0b-46fb4eda0091	Taking down metal from window and montera plåt på fånster	4813a930-e772-4adf-85d8-0448d373f829	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	17:30:00	19:30:00	2026-05-25
5232ea90-5102-43e5-81f5-07cb70846c8f	Målat zpanel 	d949002a-7479-4680-b874-f55ea62f594f	db131598-bdda-42c3-936d-27229529abfb	2.00	0	07:00:00	09:00:00	2026-06-25
d1eab250-d166-4dee-8094-4d2a99c08391	Rabygatan 13B- Papp, tape connections takkupors 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	20:00:00	21:00:00	2026-05-28
1f06dac2-c1d0-457f-85c1-4ff9923ef1c1	Rabygatan 13B- demolition metal, papp, pappspiks on takkupors, old silicone around windows takkupors, papped, taped, cleaning 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	11.50	30	09:00:00	21:00:00	2026-05-26
41a1affa-b640-408a-9739-67d2e256a216	Rabygatan 13B- Demolition metal and papp, put new papp on takkupors,  windhuiva on takkupor 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	07:00:00	09:00:00	2026-05-25
146632ac-6db1-467b-b670-84707ec9a2b9	Rabygatan 13B-mogelstops - total 36 at for both sides top and bottom 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	07:00:00	10:00:00	2026-06-01
cfce88e3-dafe-4585-a1ff-5e87545bb9e8	Rabygatan 13A- takkupors - demolition metal, old papp and do new papp, cleaning 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8.50	30	07:00:00	16:00:00	2026-06-02
0f6d3f32-57c3-43bf-be62-1b9b31f5d9cd	Rabygatan 13A- Demolition metal, old papp and put new papp on takkupors, cleaning 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	30	07:30:00	14:00:00	2026-06-03
20656f0d-76e0-4d3c-a3e5-249688388c25	Taping two front windows	4813a930-e772-4adf-85d8-0448d373f829	90ce269a-9472-4447-86cc-6f1a1519d31f	0.50	0	14:30:00	15:00:00	2026-06-03
8c53e3a3-87bd-4e52-8ff1-7c3454d0107b	Rabygatan 13A-taped around takkupors 	4813a930-e772-4adf-85d8-0448d373f829	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:00:00	08:00:00	2026-06-04
5663e88f-aad0-4ce9-be54-011f16b69693	Scratch old paint on chimney, painting 3 times- grund, base and black color	6cfb6350-300e-4727-82c2-96cd431e9425	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.00	30	11:00:00	16:30:00	2026-06-12
6877aec3-34e4-411f-81e3-ce06512cf3f6	2 stuprör on kuppa	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	08:00:00	09:00:00	2026-06-19
a6c96ab1-d5ee-46dc-8e8b-002eaf615d84	Frez ränna krukor, montera ränna krukor, montera ränna, montera futplåt alla på kuppor	d949002a-7479-4680-b874-f55ea62f594f	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	08:30:00	10:30:00	2026-06-22
5eb78c2f-ddce-4139-8c82-226e7a25ded3	Painting gavel and z-panel	d949002a-7479-4680-b874-f55ea62f594f	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	07:30:00	08:30:00	2026-06-26
b2332c27-a952-415e-ac8a-1b8127df6b1b	Målat 	d949002a-7479-4680-b874-f55ea62f594f	db131598-bdda-42c3-936d-27229529abfb	0.50	0	07:30:00	08:00:00	2026-06-26
82c0e0f4-e504-42e2-82a1-875318f012b9	Z-pannels takkupor 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	9.00	30	07:00:00	16:30:00	2026-06-29
51838655-64b5-41f1-9650-99e176fdffa8	Painting takkupor 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	07:00:00	09:00:00	2026-06-30
1bd14e60-0e4e-4cd0-a14b-a2b8d86e14c6	Mogelstop 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	16:00:00	19:00:00	2026-06-22
255fc8da-c647-4400-9443-fa5b7c1c8a09	Montera luftspalt	d949002a-7479-4680-b874-f55ea62f594f	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	07:00:00	08:00:00	2026-06-16
682973fb-9f79-4ce5-a85c-49eab9d5b562	Montera stuprör på kuppor	d949002a-7479-4680-b874-f55ea62f594f	90ce269a-9472-4447-86cc-6f1a1519d31f	0.50	0	11:30:00	12:00:00	2026-06-30
94f0c472-b717-4ad5-82cb-09ed7d1d4c35	Ställning down and collect in one place	d949002a-7479-4680-b874-f55ea62f594f	90ce269a-9472-4447-86cc-6f1a1519d31f	4.00	0	12:00:00	16:00:00	2026-06-30
b7419df8-0e1b-4e5f-8346-1279492d27b4	Scaffolding 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.50	0	12:30:00	16:00:00	2026-06-30
372129b1-eec7-4d15-a4e3-428b80f312a5	Scaffolding 	1238abd9-6257-47ca-bfff-fba910c6c953	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.50	0	09:00:00	11:30:00	2026-07-01
a5b2f623-8460-48bc-8187-c0f9c13e3cd1	Painting rospond 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4.50	0	13:00:00	17:30:00	2026-06-24
2cb1fe29-e165-4143-9fcd-4ef6295b44ab	Painting rospond	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.00	30	07:00:00	12:30:00	2026-06-25
ff85a3c3-39eb-4905-ab0b-762cc99240fc	Byggt ställning 	1238abd9-6257-47ca-bfff-fba910c6c953	db131598-bdda-42c3-936d-27229529abfb	2.50	0	09:00:00	11:30:00	2026-07-01
61db4f28-19cf-4736-bbf5-cca036397bae	Ställning	1238abd9-6257-47ca-bfff-fba910c6c953	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	60	09:00:00	13:00:00	2026-07-01
e92aaf7a-2c7d-4dd6-8b51-22a87ee806d8	demolition z-pannels, frame, metal around takkupor, cleaning	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	0	17:30:00	19:00:00	2026-06-24
216af7a9-66e0-4528-9e55-5e182b7dfc3b	windpapp takkupor, frame for z-pannels 	d949002a-7479-4680-b874-f55ea62f594f	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.50	0	12:30:00	16:00:00	2026-06-25
10e724ac-a3be-4963-a920-54d33aa02ad7	Takkupor - demolition and change rospond 14 m², cleaning 	1238abd9-6257-47ca-bfff-fba910c6c953	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	9.00	30	07:30:00	17:00:00	2026-07-08
cd5e27b2-0c0d-4b0e-89b2-e751d659ab28	Painting rospond - takkupor 	1238abd9-6257-47ca-bfff-fba910c6c953	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:30:00	08:30:00	2026-07-10
3a3167c2-5ae7-454a-ad80-4a5eab738c26	Change råspond total - 3.5 sq.m, 2 edges of roof near 2 sq.m and under chimney 1.5 sq.m	1238abd9-6257-47ca-bfff-fba910c6c953	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	0	14:00:00	17:00:00	2026-07-08
d757a750-c11b-4ae6-9b5f-29125971f2cb	Painting takstool and rospond 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	07:00:00	09:00:00	2026-07-21
f6f82c5c-5faa-4239-9b7a-2717251e3d26	Painting and montera front pannel on house and kuppor	1238abd9-6257-47ca-bfff-fba910c6c953	90ce269a-9472-4447-86cc-6f1a1519d31f	3.00	0	11:00:00	14:00:00	2026-07-11
475c4f4e-9972-41c8-88e9-738226fb8808		cef60249-2727-476e-bd94-4d3e9dd03916	7dafa412-ec37-4c54-b149-1bd406b66a3a	0.00	30	08:00:00	08:01:00	2026-07-21
537de5a4-e48d-4680-a8e1-a0398b1fc540	Painting rospond 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	0	07:00:00	08:30:00	2026-07-23
b3f2edbc-0c2e-4872-b5c0-b5e4ff9accb4	Painting rospond 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	30	10:30:00	14:00:00	2026-07-31
77d3442c-2a14-431a-8b12-208438a27526	Slipa all gavels 	bbffade8-2151-4c8d-bb24-df1b0d515203	90ce269a-9472-4447-86cc-6f1a1519d31f	3.50	0	15:00:00	18:30:00	2026-07-31
1bf62b4e-7f47-46cc-bf42-70382e0afc7b	Painting govel	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.00	0	12:30:00	17:30:00	2026-08-03
76ed7869-0146-440d-97df-66c8bba2a0d9	Painting gåvel	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.50	30	09:00:00	15:00:00	2026-08-04
a04d1df9-3c9b-44d1-a232-51639df686e8	Painting and install gåvel desks	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:00:00	08:00:00	2026-08-05
d1689198-e3e4-48d4-b1e4-d0aeb2efbe24	Painting and install gåvel desks	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	07:00:00	09:00:00	2026-08-06
8812109e-2dab-4ba0-a13f-74801c28c45e	Ställningar	7ff6c67c-a436-402a-aa4e-a080d8dc21df	90ce269a-9472-4447-86cc-6f1a1519d31f	6.50	30	07:00:00	14:00:00	2026-08-06
1d26f2b8-ff86-44ac-b617-bc963b09dfae	Scaffolding 	7ff6c67c-a436-402a-aa4e-a080d8dc21df	7dafa412-ec37-4c54-b149-1bd406b66a3a	4.50	30	09:00:00	14:00:00	2026-08-06
9a1ea737-f38a-4c3a-a750-0b5c45ad9c76	Painting gavel	bbffade8-2151-4c8d-bb24-df1b0d515203	7dafa412-ec37-4c54-b149-1bd406b66a3a	3.50	30	10:00:00	14:00:00	2026-07-31
8d4c4c88-c870-437d-9390-708c57d6f023	Changing broken tile, adding new tile. All that on side of the house where was ställning	bbffade8-2151-4c8d-bb24-df1b0d515203	90ce269a-9472-4447-86cc-6f1a1519d31f	0.50	0	15:00:00	15:30:00	2026-08-21
5a2c57e4-c918-4e62-9dc0-0b9e99732a0d	Taking down ställningar	bbffade8-2151-4c8d-bb24-df1b0d515203	90ce269a-9472-4447-86cc-6f1a1519d31f	3.50	30	11:00:00	15:00:00	2026-08-21
43c9969f-8b93-4259-aa96-bad8c8048be8	Painting change gavel panels	bbffade8-2151-4c8d-bb24-df1b0d515203	90ce269a-9472-4447-86cc-6f1a1519d31f	7.00	60	08:30:00	16:30:00	2026-08-24
56e43213-5ef5-4372-a284-733b4a166782	Demolition old rospond 	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	13:00:00	16:00:00	2026-08-25
c6e9ba07-6318-4d5d-ac1c-7f4e66e31b9f	Demolition ventilation box, close with rospond and papp	678c86c5-32e7-4026-95b4-8e6bc404beb3	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.50	0	07:30:00	10:00:00	2026-09-18
b27c55d9-6378-4db1-8572-b3eaed5ca1be	Lift and install rospond 	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.50	30	11:00:00	15:00:00	2026-08-27
e0bfa61f-af00-401e-986c-ef183ec238e3	Shlifen and shpateln desks 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4.00	30	09:00:00	13:30:00	2026-09-01
e53dd414-ea08-46ab-9e86-2f8d49ffd255	Install attic cover and stairs	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	0	13:30:00	19:30:00	2026-09-01
c522bce3-55d1-420b-9e4e-4c93715b1de6	Shlifen and painting gåvel pannels	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	30	11:30:00	14:00:00	2026-09-02
1e6a5b1c-606d-445e-8e27-f42909f42195	Taking down stallning	bbffade8-2151-4c8d-bb24-df1b0d515203	90ce269a-9472-4447-86cc-6f1a1519d31f	1.00	0	11:00:00	12:00:00	2026-09-03
360cb324-d55d-42d2-ac36-25503ec8c1af	Unloading scaffolding 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	10:00:00	11:00:00	2026-09-03
7f175658-71fe-4235-9d55-e139f28beb34	 fixing takstools	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	30	07:30:00	14:00:00	2026-08-26
41ab45ad-330e-4855-ba98-8ca4dbf8bcde	Install rospond,	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	14:00:00	16:00:00	2026-08-26
2bbbc5e9-3faf-42ba-9daa-90caab82d4cc	Mogelstops	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	17:30:00	18:30:00	2026-08-31
3a63b088-74e8-4fed-b84c-346ae9396164	Mogelstops 	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	0	16:30:00	18:00:00	2026-09-02
4c1221df-36e3-4082-9c4a-bd382f5b7886	mogelstops	7ff6c67c-a436-402a-aa4e-a080d8dc21df	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	0	19:00:00	20:30:00	2026-09-03
83fda297-9b50-4af1-8992-c6e23234b128	Montera stege	7ff6c67c-a436-402a-aa4e-a080d8dc21df	90ce269a-9472-4447-86cc-6f1a1519d31f	2.00	0	14:00:00	16:00:00	2026-09-04
230987af-4367-4098-bb1d-9dbb7f751125	Install frames around attic cover 	bbffade8-2151-4c8d-bb24-df1b0d515203	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	30	08:00:00	14:30:00	2026-09-09
b290b68d-34b3-4088-8ff8-e52197df1ecf	Painting gåvel pannels	ac5d737c-2421-48f2-8e01-e3c4ee638738	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	16:30:00	17:30:00	2026-09-11
ce923740-e8d3-41ff-ace3-86f38ba5398a	Painting rospond -gåvel side	ac5d737c-2421-48f2-8e01-e3c4ee638738	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.50	0	08:00:00	09:30:00	2026-09-12
d9cd6538-318d-4988-8b05-64eccf92c645	Install gåvel pannels under rospond 	ac5d737c-2421-48f2-8e01-e3c4ee638738	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	18:00:00	19:00:00	2026-09-12
14579939-0de4-45f3-8139-45acad625064	Scaffolding 	678c86c5-32e7-4026-95b4-8e6bc404beb3	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.50	0	07:30:00	10:00:00	2026-09-15
ab634e54-0e2c-42e0-9c9a-f0414254e025	Change rospond and painting twise	678c86c5-32e7-4026-95b4-8e6bc404beb3	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.00	0	07:30:00	09:30:00	2026-09-16
67967c4d-e7ef-4cd4-85bd-9ed403813159	Painting rospond and regel twise	d83c0440-0d14-41ac-965a-7155f13d6713	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	5.50	30	08:00:00	14:00:00	2026-09-26
9bad1891-48db-4304-8fb9-db83b6fc1060	Painting twice connecting leghts between gåvel and rospond 	d83c0440-0d14-41ac-965a-7155f13d6713	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	07:30:00	08:30:00	2026-10-02
fb2f6eed-4788-4d2f-9c2c-ede058798b58	Demolition z-pannels and metal, doing papp, windpapp on takkupor. Painting rospond - gåvel side	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	3.00	0	07:30:00	10:30:00	2026-10-05
f60c38c1-938b-4838-a34f-07ce46249e76	Paint front panel all, 2 times 1.5h\nPaint råspond front side under hooks 2 times 2.5h\n	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	90ce269a-9472-4447-86cc-6f1a1519d31f	4.00	30	07:30:00	12:00:00	2026-10-06
cafbb7e7-7c33-4f73-8131-7078d91808b4	Cutting, connecting and doing isolation 2 ventilation pipes 	d83c0440-0d14-41ac-965a-7155f13d6713	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1.00	0	14:00:00	15:00:00	2026-10-08
9287075c-f382-4125-a83b-efc95aa2202e	Close hole between rospond and pannels under rendal, painting twice rospond and regel, install pannels between gåvel and rospond 	d83c0440-0d14-41ac-965a-7155f13d6713	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6.00	0	13:00:00	19:00:00	2026-10-07
b6f3d54a-8c0b-4059-a7b8-481893bc934b	Painting råspond under hooks 2 times from me qnd Anders	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	90ce269a-9472-4447-86cc-6f1a1519d31f	3.50	30	07:30:00	11:30:00	2026-10-08
3743bcfc-06b0-4554-8627-adb35f23723b	Install pannels between gåvel and rospond, painting rospond 	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	2.50	0	17:00:00	19:30:00	2026-10-10
\.


--
-- Data for Name: project_images; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_images (id, url, "publicId", "createdAt", "projectId") FROM stdin;
41f1926c-2ebf-42a1-9d61-8cdb127e53fb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769345879/projects/54629585-9337-4f55-8977-036ff89a2e2b/jasdqljo6ndzgpdevt2h.jpg	projects/54629585-9337-4f55-8977-036ff89a2e2b/jasdqljo6ndzgpdevt2h	2026-01-25 12:58:00.98129	54629585-9337-4f55-8977-036ff89a2e2b
c709f024-491d-4bec-97f9-64bbbc954147	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769345881/projects/54629585-9337-4f55-8977-036ff89a2e2b/rplkxr6x4tcw0evszswa.jpg	projects/54629585-9337-4f55-8977-036ff89a2e2b/rplkxr6x4tcw0evszswa	2026-01-25 12:58:02.979529	54629585-9337-4f55-8977-036ff89a2e2b
bd71ee2d-867d-4bae-9bcb-9213c681edba	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769622387/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vuyo7sjngv5zkglkcxau.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vuyo7sjngv5zkglkcxau	2026-01-28 17:46:30.069134	f36437da-0d4c-4db0-9e26-1bbc83e02c10
9b7c0c31-818b-4e85-ad44-7ba0ad477a13	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769622391/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/tr79x9izenghfsfzcwrm.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/tr79x9izenghfsfzcwrm	2026-01-28 17:46:32.738625	f36437da-0d4c-4db0-9e26-1bbc83e02c10
c6780de5-99e7-4c61-82fe-e6afb5c2985e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699641/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vwjn6x8h5tnkxpbbiwfz.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vwjn6x8h5tnkxpbbiwfz	2026-01-29 15:14:02.215268	f36437da-0d4c-4db0-9e26-1bbc83e02c10
74bab094-c9b9-4efb-b212-973b139e09b6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699643/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/yyms0cu4ccsdsdhtgk17.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/yyms0cu4ccsdsdhtgk17	2026-01-29 15:14:04.102358	f36437da-0d4c-4db0-9e26-1bbc83e02c10
645d449a-f857-4365-8127-0d0d7e4adc54	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699644/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vhqtxe1eegopx85humxb.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/vhqtxe1eegopx85humxb	2026-01-29 15:14:05.79193	f36437da-0d4c-4db0-9e26-1bbc83e02c10
0374e8d8-8229-40fe-b081-14b7106312db	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699664/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/gkdghz2l0xnigxo1lcng.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/gkdghz2l0xnigxo1lcng	2026-01-29 15:14:25.366312	f36437da-0d4c-4db0-9e26-1bbc83e02c10
4a653842-9036-48d2-b7c0-2f1080519b47	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699665/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/clh4inenywrxvdskotoh.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/clh4inenywrxvdskotoh	2026-01-29 15:14:27.035866	f36437da-0d4c-4db0-9e26-1bbc83e02c10
966b6223-9f23-447d-b76f-2ebebcbf3307	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699667/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/t1tzkyhjpz73nydz1shf.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/t1tzkyhjpz73nydz1shf	2026-01-29 15:14:28.608686	f36437da-0d4c-4db0-9e26-1bbc83e02c10
6edd74aa-e420-42a0-afd8-a0ad48ba4fa3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769699669/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/znz3dovtena8xiblnx5z.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/znz3dovtena8xiblnx5z	2026-01-29 15:14:30.482283	f36437da-0d4c-4db0-9e26-1bbc83e02c10
10992327-185f-447e-bca0-3e7413697529	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769788146/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/m1ri8gct8x7w0t9t1ush.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/m1ri8gct8x7w0t9t1ush	2026-01-30 15:49:07.778417	f36437da-0d4c-4db0-9e26-1bbc83e02c10
f78e8a79-acfe-48d3-8d85-9c305728f518	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769788148/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/n2gl09n0mnxonj59tbzq.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/n2gl09n0mnxonj59tbzq	2026-01-30 15:49:09.617824	f36437da-0d4c-4db0-9e26-1bbc83e02c10
6bf2a342-ea42-4f2f-8a7a-382478c2f25d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769788150/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/v2deziuwxwps2crzdmjh.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/v2deziuwxwps2crzdmjh	2026-01-30 15:49:12.163866	f36437da-0d4c-4db0-9e26-1bbc83e02c10
14a00039-de78-4f6a-88d7-a705a40ccfbb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769788153/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/mpawsj543ie77bmrdshv.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/mpawsj543ie77bmrdshv	2026-01-30 15:49:14.282068	f36437da-0d4c-4db0-9e26-1bbc83e02c10
a461efa2-e27d-45f6-ac74-b1c3b1feaeaa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769865566/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/wd2y2sonjhn4krmodebj.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/wd2y2sonjhn4krmodebj	2026-01-31 13:19:27.31157	f36437da-0d4c-4db0-9e26-1bbc83e02c10
c6dd43f9-f4ed-48bf-99aa-2563e1421163	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876246/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/yhp4nvulblhlukrtlbew.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/yhp4nvulblhlukrtlbew	2026-01-31 16:17:27.342428	ac4896b2-f0c4-4da1-a604-5213681e663e
370518c6-b61a-4ac1-8137-02c01ee01b85	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876247/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/fopc0zyvupt5lwu5jt8m.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/fopc0zyvupt5lwu5jt8m	2026-01-31 16:17:28.917103	ac4896b2-f0c4-4da1-a604-5213681e663e
8708095d-1453-42a7-b03d-4aac7cd27d6e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876249/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/z9lcqhjj3403m5b5xwrr.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/z9lcqhjj3403m5b5xwrr	2026-01-31 16:17:31.057659	ac4896b2-f0c4-4da1-a604-5213681e663e
b9028b7e-2ec7-4479-820b-2951ddc61870	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876252/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/m5fcaqsn8pffapaqkkbu.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/m5fcaqsn8pffapaqkkbu	2026-01-31 16:17:34.201423	ac4896b2-f0c4-4da1-a604-5213681e663e
b4a103c2-e233-418a-a912-1179813e3a4b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876255/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/z8a1wttorebjowny0por.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/z8a1wttorebjowny0por	2026-01-31 16:17:36.428111	ac4896b2-f0c4-4da1-a604-5213681e663e
c0d87ba2-e843-4aaa-86c3-802850b38d31	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876257/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/zihzbdnxc3nlfmiqdbrm.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/zihzbdnxc3nlfmiqdbrm	2026-01-31 16:17:38.130396	ac4896b2-f0c4-4da1-a604-5213681e663e
1f5c76cf-e352-421e-a728-f3b55195b922	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1769876260/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/iwzlhue6hqdnwzxtmsbw.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/iwzlhue6hqdnwzxtmsbw	2026-01-31 16:17:42.055953	ac4896b2-f0c4-4da1-a604-5213681e663e
6da64908-8cf2-47ea-b0e9-dcbd5fbd7006	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140623/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/u4us6qmkh0stfrw3lglr.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/u4us6qmkh0stfrw3lglr	2026-02-03 17:43:45.202927	f36437da-0d4c-4db0-9e26-1bbc83e02c10
e576c107-f6f2-4e4b-a517-7b5766b0a161	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140626/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/qoc5vtc8uthumsnaqdwf.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/qoc5vtc8uthumsnaqdwf	2026-02-03 17:43:47.602429	f36437da-0d4c-4db0-9e26-1bbc83e02c10
bde1569f-43e4-4c33-9e4e-148808e3c98a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140628/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/ncnblmwnouvmmjyj6khd.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/ncnblmwnouvmmjyj6khd	2026-02-03 17:43:49.441662	f36437da-0d4c-4db0-9e26-1bbc83e02c10
d6962dce-837f-4ec6-ae15-25581737db1d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140629/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/a4vsw7p2lumnwaegywai.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/a4vsw7p2lumnwaegywai	2026-02-03 17:43:51.434971	f36437da-0d4c-4db0-9e26-1bbc83e02c10
30e9210c-b124-4b55-b032-78e0b1dac446	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140632/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/gv9qbz9yxazdw9uy9pmw.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/gv9qbz9yxazdw9uy9pmw	2026-02-03 17:43:53.481387	f36437da-0d4c-4db0-9e26-1bbc83e02c10
af54b122-5cd2-436d-b033-8aace6b21267	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770140634/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/enlzagsdewkkwa47uw17.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/enlzagsdewkkwa47uw17	2026-02-03 17:43:55.436218	f36437da-0d4c-4db0-9e26-1bbc83e02c10
f95a10ac-fa57-4046-b224-ea26c307e584	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770311853/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/iwzfvscmqvxucnfuopdi.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/iwzfvscmqvxucnfuopdi	2026-02-05 17:17:35.029209	f36437da-0d4c-4db0-9e26-1bbc83e02c10
0b6ee4f1-cbf5-40d1-9a35-6e0cd53117fd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770311855/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/jueu1d981is5efhggl8s.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/jueu1d981is5efhggl8s	2026-02-05 17:17:36.522401	f36437da-0d4c-4db0-9e26-1bbc83e02c10
c932a229-a9f6-40dc-a777-58f49e6e3006	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770533865/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/pwk0gpprpcngmkc7kite.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/pwk0gpprpcngmkc7kite	2026-02-08 06:57:46.441828	f36437da-0d4c-4db0-9e26-1bbc83e02c10
3914fbe8-9f05-49d6-8f9a-a683bc3b618a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770580385/projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/eltfpesfpn9sahlpljkv.jpg	projects/f36437da-0d4c-4db0-9e26-1bbc83e02c10/eltfpesfpn9sahlpljkv	2026-02-08 19:53:07.305484	f36437da-0d4c-4db0-9e26-1bbc83e02c10
eb00e490-1f32-4352-b208-00b2818df6e6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644870/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/vdn1ghmufroz0u8wgkfs.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/vdn1ghmufroz0u8wgkfs	2026-02-09 13:47:51.721067	ac4896b2-f0c4-4da1-a604-5213681e663e
1f3c83ca-3d0f-4429-a68d-37bad312a7e4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644872/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/syejniwfhyl3iwkekhqo.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/syejniwfhyl3iwkekhqo	2026-02-09 13:47:53.875575	ac4896b2-f0c4-4da1-a604-5213681e663e
869b1078-d0b8-45ef-af8a-d63f3e3d0fe7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644874/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/anvgmgztvluwakafmpz4.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/anvgmgztvluwakafmpz4	2026-02-09 13:47:55.741676	ac4896b2-f0c4-4da1-a604-5213681e663e
1aea67af-33ed-448e-a4a0-b973793ea3ed	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644876/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/eo9qdeoxbr8uvayw5rmw.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/eo9qdeoxbr8uvayw5rmw	2026-02-09 13:47:57.158448	ac4896b2-f0c4-4da1-a604-5213681e663e
b5659852-db38-43b9-a104-2ce40bfcfc61	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644877/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/hz3p4v1ya1lwppti4npt.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/hz3p4v1ya1lwppti4npt	2026-02-09 13:47:59.017387	ac4896b2-f0c4-4da1-a604-5213681e663e
63d37fb0-2b17-4a35-8b66-a23d7bf7639a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644879/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/v2bpq1otnxfftjftvdy7.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/v2bpq1otnxfftjftvdy7	2026-02-09 13:48:00.547608	ac4896b2-f0c4-4da1-a604-5213681e663e
4c442dec-37df-4711-a50e-fc6d34841d30	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644881/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/biejw3b9zkf90xmkvuap.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/biejw3b9zkf90xmkvuap	2026-02-09 13:48:02.243994	ac4896b2-f0c4-4da1-a604-5213681e663e
50702bf4-b261-433d-bd81-77d93b6291a9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1770644882/projects/ac4896b2-f0c4-4da1-a604-5213681e663e/cbxmo6uuwa5w33dgzxrl.jpg	projects/ac4896b2-f0c4-4da1-a604-5213681e663e/cbxmo6uuwa5w33dgzxrl	2026-02-09 13:48:03.927805	ac4896b2-f0c4-4da1-a604-5213681e663e
b4cff7d6-a849-4216-a4b4-f31b29bd2364	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771141553/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/og6iejbospkpioasd6zk.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/og6iejbospkpioasd6zk	2026-02-15 07:45:54.488756	5c5918d7-0a51-4733-932b-55b35ea538d3
7a3bdf9d-2491-4e42-bfe3-af00e042e17c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771339586/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hnntmgmd1qpjoq5rbg7f.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hnntmgmd1qpjoq5rbg7f	2026-02-17 14:46:28.114361	5c5918d7-0a51-4733-932b-55b35ea538d3
48c8d21d-d0c9-4d53-8bef-4bb9d05b738c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771339589/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/w3xqhdbzjuxjzlphkbcr.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/w3xqhdbzjuxjzlphkbcr	2026-02-17 14:46:31.006786	5c5918d7-0a51-4733-932b-55b35ea538d3
49d61dbc-28e0-4554-97c8-083c1877fc5a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771495763/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hmq0xoqiloqamidfk4vb.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hmq0xoqiloqamidfk4vb	2026-02-19 10:09:24.982573	5c5918d7-0a51-4733-932b-55b35ea538d3
8c2e9724-d3fd-472a-b57e-94f4bd74edae	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771950654/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iejrfg0jx47wpm6oyvyw.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iejrfg0jx47wpm6oyvyw	2026-02-24 16:30:55.623675	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6da37103-7806-4971-95ba-69213a383198	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1771950656/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/rfwzwwucdxcjpsxbrz6c.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/rfwzwwucdxcjpsxbrz6c	2026-02-24 16:30:57.320064	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
366dafa1-40be-4602-92da-550237386bc1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772279633/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/undfs17xgzjtsnjynmva.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/undfs17xgzjtsnjynmva	2026-02-28 11:53:54.962897	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
83ecd44e-d524-44b7-b833-e0b56b4b8be5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772279635/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ifocnhw1eoeirilelazb.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ifocnhw1eoeirilelazb	2026-02-28 11:53:56.34283	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
636a95ab-84c1-4d6d-b28d-981983b9d87b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772279636/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bmt5szarleeajmhqtevt.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bmt5szarleeajmhqtevt	2026-02-28 11:53:57.586023	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
ed51cabd-cad0-46be-a7e5-f0162f5f7212	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772283225/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/nvydmwz6eri4flmtw2gf.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/nvydmwz6eri4flmtw2gf	2026-02-28 12:53:46.752331	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6dcc509a-f6a0-4433-8f50-bbef7f81f50c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772283227/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/slsusyxf2hudtzl0r6da.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/slsusyxf2hudtzl0r6da	2026-02-28 12:53:48.387474	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5090bace-517e-4dcf-a5b1-3047d0ced4b4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772283228/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jyikdhlvkdlyl96w9hp6.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jyikdhlvkdlyl96w9hp6	2026-02-28 12:53:49.846587	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
a1fa21c2-6476-4a37-8986-0858038098c3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468817/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xtnwv91ls27d9enjolog.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xtnwv91ls27d9enjolog	2026-03-02 16:26:58.54306	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
53dba902-9f97-4fde-a758-15a1cfe9300f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468818/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/kgnj390b6m0vykape43i.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/kgnj390b6m0vykape43i	2026-03-02 16:27:00.283831	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
fe711a85-92b0-4b84-93d2-01524150322b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468820/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vjcjtj0v2y4ixyh31iqm.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vjcjtj0v2y4ixyh31iqm	2026-03-02 16:27:01.579043	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
631fb63e-441e-42fc-8cd0-33a5fe78577a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468821/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xdfe1gzytbutvnzkidl0.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xdfe1gzytbutvnzkidl0	2026-03-02 16:27:03.156855	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
3e73ac69-e128-42f5-ba44-c55f4e5cd0a5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468823/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/gev9yq3ezdtkge4kqhdz.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/gev9yq3ezdtkge4kqhdz	2026-03-02 16:27:04.743668	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6d06f57c-f6bb-4792-bd68-5b3025f49623	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468860/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/edwktlgkryglyn2dbo7w.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/edwktlgkryglyn2dbo7w	2026-03-02 16:27:41.572928	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
2106de5d-eb65-4186-875a-d0afe3cb8000	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468862/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/drchxdktyjkje8gilzox.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/drchxdktyjkje8gilzox	2026-03-02 16:27:43.434284	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5e1a1d16-b400-4b20-80de-fafc5b9e179f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772468863/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/kds2hdn9dull7yu1wqsj.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/kds2hdn9dull7yu1wqsj	2026-03-02 16:27:44.956424	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f7b47b7b-b9a5-41e1-b964-36a9f3591f78	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772554999/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jayeqw659xhe4doidby4.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jayeqw659xhe4doidby4	2026-03-03 16:23:20.681255	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
1e451c73-f2c3-43aa-928b-dafbdd8b744a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772555000/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/whotzctensdrwcfpz87e.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/whotzctensdrwcfpz87e	2026-03-03 16:23:22.135676	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
b7093350-a213-47e6-9e08-ce1d3512566a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772555006/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/f5tuxa89byqevztwctj5.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/f5tuxa89byqevztwctj5	2026-03-03 16:23:28.313668	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5b6482cb-7b41-44f8-bf9c-aa726505d36f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772555008/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lhjqc1nctkxhjwog85ez.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lhjqc1nctkxhjwog85ez	2026-03-03 16:23:29.88027	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
b878079e-2c7b-4a74-82a2-17a9d427ec64	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772555010/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/l0kg7rhdpcwdo63aimpu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/l0kg7rhdpcwdo63aimpu	2026-03-03 16:23:31.21446	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
31c73ead-c0de-4b45-892f-208e44f5f1a9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772555011/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lqlqai9v5pl1otn5ipvq.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lqlqai9v5pl1otn5ipvq	2026-03-03 16:23:33.186509	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f35ce73e-4f43-4825-8a16-79829b78871c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772622147/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a9ructnhrj2hpu8qq2kf.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a9ructnhrj2hpu8qq2kf	2026-03-04 11:02:29.468254	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
4e66f996-7fe7-4cd9-8259-3227ede55c00	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772622149/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/uc5tpy5oevbgjjnbkvwb.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/uc5tpy5oevbgjjnbkvwb	2026-03-04 11:02:31.150208	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
92b329d1-49c7-4292-bdb1-214793e9d245	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645685/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jeazn7z7cuqf7l5evm3l.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jeazn7z7cuqf7l5evm3l	2026-03-04 17:34:46.799735	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
56cb4904-0754-4c62-b71b-daf5eb32b417	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645687/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jxbswcr3aszffkpykobl.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jxbswcr3aszffkpykobl	2026-03-04 17:34:48.358604	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6482ea49-c289-496a-8172-069911a4c172	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645688/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lipkxzigwwdulamnossz.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lipkxzigwwdulamnossz	2026-03-04 17:34:49.895549	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
af1cca7b-6349-4f5a-8bbd-414969aa90c5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645690/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hockby7nxoqwblwtmelb.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hockby7nxoqwblwtmelb	2026-03-04 17:34:51.624606	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f0a4d51f-4dd9-40c2-b2d1-256bd140dd5c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645692/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a0gbhb13gr6sp4atmfzw.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a0gbhb13gr6sp4atmfzw	2026-03-04 17:34:53.296673	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c8d8e99f-fb23-49c2-8d06-c03cd343ea48	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772645693/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ouxgxllurzy1wqydhtyo.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ouxgxllurzy1wqydhtyo	2026-03-04 17:34:54.840542	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
9e08d54d-8613-4a0b-912f-f2a4506cf42c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731032/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jneqt0d5mey99tp5jpgc.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jneqt0d5mey99tp5jpgc	2026-03-05 17:17:14.29968	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
ef3fad44-1e76-41d0-8bae-a79b6fde9873	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731034/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mpckfr4ud3rdxiqrdtt3.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mpckfr4ud3rdxiqrdtt3	2026-03-05 17:17:16.158276	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f0d5581a-3ba3-4ccb-93e6-066abe028210	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731036/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/gszjpzsw4xmvgjwjslla.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/gszjpzsw4xmvgjwjslla	2026-03-05 17:17:17.945004	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
9d194f97-f7c4-40e8-9fac-720333d86244	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731038/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mgfhndxy55wyudjrgkwr.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mgfhndxy55wyudjrgkwr	2026-03-05 17:17:19.547798	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
899bb499-d047-4ca9-85b4-82f67abf6007	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731049/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yt81tibz0t5rdu8zmhgi.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yt81tibz0t5rdu8zmhgi	2026-03-05 17:17:30.588527	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
4cfd0983-d0e4-423a-981f-47ac7bc3608e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731051/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a8dajbkn1v1oibnmqkm9.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/a8dajbkn1v1oibnmqkm9	2026-03-05 17:17:32.971314	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
68db6e68-2300-441e-ace1-f3bc0fc1b346	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731053/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/giwsiqizvkxeurcecuvr.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/giwsiqizvkxeurcecuvr	2026-03-05 17:17:35.546754	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
3346cd17-3e2f-4746-96ed-0884b0130910	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772731056/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/i8keipqrfjoy4elngfgr.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/i8keipqrfjoy4elngfgr	2026-03-05 17:17:37.289575	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
ff0351e8-5829-4d65-98df-3fd2a1c8567e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772819273/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ip8amwedbnb0dif8tgff.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ip8amwedbnb0dif8tgff	2026-03-06 17:47:54.471655	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
1237f742-93ad-48d1-8606-ad29e1b5502c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772819274/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/t2meodeg6gglzplutg7q.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/t2meodeg6gglzplutg7q	2026-03-06 17:47:56.015559	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
e530cf4d-cd94-4424-b1ef-238fd998b448	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772819276/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qgo5dzpm9zbxpzwbfcgp.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qgo5dzpm9zbxpzwbfcgp	2026-03-06 17:47:57.521155	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
3d151846-8bc4-4927-9b6b-ee0b67684322	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772860861/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vly2jjntz0wj5ggnyih9.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vly2jjntz0wj5ggnyih9	2026-03-07 05:21:02.926189	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c57a7c80-7642-4c1f-8bf7-7c2342534af3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772860863/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cqq3yzhdrgdvxun8oghv.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cqq3yzhdrgdvxun8oghv	2026-03-07 05:21:04.371493	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c4b0e42e-fb40-4489-8591-bd5753cec259	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772860864/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tsh02yxoigceuko9iksk.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tsh02yxoigceuko9iksk	2026-03-07 05:21:05.856699	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
7ac8f858-8f8d-4484-9bfa-621f143ef912	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772897213/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jvekyanjvnarqtyvaje1.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jvekyanjvnarqtyvaje1	2026-03-07 15:26:55.874731	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c7e2836a-f3a1-45ba-8f99-c2935118de55	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772897216/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/rv6oj98edg1redlwbtzc.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/rv6oj98edg1redlwbtzc	2026-03-07 15:26:57.276331	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
355e3f96-34bc-4372-b005-da4ddd224f02	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1772897217/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/o01r4qut3lt17sfeised.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/o01r4qut3lt17sfeised	2026-03-07 15:26:58.899283	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5ef01b4b-78e6-4214-9168-a557fe91e07e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773078301/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hhxshrsgs9vbpgelz3nx.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hhxshrsgs9vbpgelz3nx	2026-03-09 17:45:02.422289	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5fe02e40-3b4a-4f07-804e-b3a038167d74	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773078302/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/sgkfoejsat3lxz6hkdmu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/sgkfoejsat3lxz6hkdmu	2026-03-09 17:45:03.853199	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
75e795fc-765e-453e-b08e-3d5b92a852bb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773078304/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/j1rlnpvoraaoqxlzjkzu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/j1rlnpvoraaoqxlzjkzu	2026-03-09 17:45:05.415779	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
7389809b-ae96-4ff0-8698-285bbc2cd34b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773394564/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/z47fwlnaqt0ml33fqmtw.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/z47fwlnaqt0ml33fqmtw	2026-03-13 09:36:05.516776	f40904f2-dc04-4c56-8c6b-259d63237a2b
1a8c1aa5-df72-4506-b485-8912a0b80359	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773394566/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hnfclwygsb6b04vbxisn.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hnfclwygsb6b04vbxisn	2026-03-13 09:36:07.017567	f40904f2-dc04-4c56-8c6b-259d63237a2b
42d55639-414a-48b1-9288-6c6498cd51e3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773394567/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/tlwijf8vdkxcybyj2l8n.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/tlwijf8vdkxcybyj2l8n	2026-03-13 09:36:08.350832	f40904f2-dc04-4c56-8c6b-259d63237a2b
4d6958fe-46b8-453c-b0c1-2e9ef25e3d7d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773415487/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xouvvkkd4vaqps8uppbv.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xouvvkkd4vaqps8uppbv	2026-03-13 15:24:49.074726	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6e9a79bd-0564-4310-877e-59c5cd370239	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773415489/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/nj23cd85kig57hk3t1il.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/nj23cd85kig57hk3t1il	2026-03-13 15:24:50.701265	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
416af0bd-28eb-4f2d-93d9-af49a4125cee	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773415495/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yz9akcpaawzjecgcpypj.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yz9akcpaawzjecgcpypj	2026-03-13 15:24:56.558336	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
2a68f11a-e6bb-472d-bccb-ebf7e96b8bee	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511246/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hmdc8kjju819nau412nw.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hmdc8kjju819nau412nw	2026-03-14 18:00:48.168041	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
38c77359-009e-44e7-b650-e7125c829634	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511248/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jx5cpxpi0kmthszxx7rl.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jx5cpxpi0kmthszxx7rl	2026-03-14 18:00:50.167652	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
b30b42b6-f0cb-40f4-a8a4-bbf04583cb26	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511250/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ypa2klktuuggsb69n8an.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ypa2klktuuggsb69n8an	2026-03-14 18:00:52.932074	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
1d9d7115-8de0-4555-a211-ddc21b0c73e5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511253/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/aoesk2w61ndbecwl12yp.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/aoesk2w61ndbecwl12yp	2026-03-14 18:00:54.495631	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
0fe57e10-b0b9-4c93-b310-cdbfbfcba90d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511254/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mlqdrhyuezs5boncetbj.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/mlqdrhyuezs5boncetbj	2026-03-14 18:00:56.070403	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
7ee32323-ef5b-4bc4-8225-1c3c082e08b3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773511256/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wxvksgk3jwwzrgn23fbo.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wxvksgk3jwwzrgn23fbo	2026-03-14 18:00:57.49438	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
616c35ec-ef1e-4df7-8035-ab718fe37145	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678372/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/w0jkdkhbzcvxcqkrbnr8.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/w0jkdkhbzcvxcqkrbnr8	2026-03-16 16:26:13.756386	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c0151a78-b7cf-4b9a-83d9-b9196f87a702	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678377/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/dv80b5qubhfxowcldhrc.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/dv80b5qubhfxowcldhrc	2026-03-16 16:26:20.089389	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
79f55cc8-da61-4292-94fd-10574d1d78ef	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678380/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cttwb5lfgagbaarz9ye2.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cttwb5lfgagbaarz9ye2	2026-03-16 16:26:21.733679	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
acefe747-3374-49a8-9444-2ff8c551a72f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678382/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/muzpprb42zpuasakbaul.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/muzpprb42zpuasakbaul	2026-03-16 16:26:23.404437	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
fb15bfda-7d98-460d-8812-0a3ea7dc4206	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678383/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/htrp50p6extdsk4xtuvx.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/htrp50p6extdsk4xtuvx	2026-03-16 16:26:25.691643	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
e810a364-5f8f-4aa2-9446-999b391d3585	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678385/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wj9y8q3q514dc4cq4ad2.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wj9y8q3q514dc4cq4ad2	2026-03-16 16:26:27.312116	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
01bd2746-e799-48e3-bf68-5d2fd630fd39	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678387/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xjukcdig95lcqfrpjfum.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xjukcdig95lcqfrpjfum	2026-03-16 16:26:28.634933	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
39625eb9-8454-4dcb-820f-8b394bcad2c5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678466/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/r0ebwkfjt8johwvj3nft.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/r0ebwkfjt8johwvj3nft	2026-03-16 16:27:48.256307	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5da1b63e-6d57-4464-9380-61eccd7279df	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678468/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hykm2cmkww1lpewlfqrz.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hykm2cmkww1lpewlfqrz	2026-03-16 16:27:49.758251	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
75f1854f-c514-4017-ba8c-7e1b6bc59acc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678470/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/izt0rc24pxswfqp52vtr.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/izt0rc24pxswfqp52vtr	2026-03-16 16:27:51.276201	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
149ce557-79d1-4685-ad7e-e53aa194018c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773678471/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xofrovjmfgaxe1jjzyno.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xofrovjmfgaxe1jjzyno	2026-03-16 16:27:52.505433	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
d08990c1-c9be-4001-9eb6-b666a7c24020	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773770264/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qc4cysxd8sdskq1r9mgp.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qc4cysxd8sdskq1r9mgp	2026-03-17 17:57:45.494384	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
b6ea2d83-6836-4efd-9c0b-f5cfd2b1bdb8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773770265/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/odsqbkldserz8wbropfx.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/odsqbkldserz8wbropfx	2026-03-17 17:57:47.261755	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5e309162-b1a6-4456-8d4e-08798a88c066	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773770267/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/acglqpdalwc4s6d1roz4.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/acglqpdalwc4s6d1roz4	2026-03-17 17:57:48.588827	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
af2da6aa-c588-43f0-82a6-877f8816ac9d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773847206/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/obsvjhpjg2jdyhmbdiuy.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/obsvjhpjg2jdyhmbdiuy	2026-03-18 15:20:07.753749	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
fdce6f4c-2cb7-4ca8-a704-70906fff648a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773847208/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/zmrj57qqjqg3crcgxyoq.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/zmrj57qqjqg3crcgxyoq	2026-03-18 15:20:09.513349	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
3239c792-7537-4996-9837-6773661228f7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773847210/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/z5zjmvywkwez4zssbtbg.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/z5zjmvywkwez4zssbtbg	2026-03-18 15:20:11.423247	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
3bd9382a-0c64-4661-8654-8d3e21b237b9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773847211/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cxjdphl3jkwdduvhvcki.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cxjdphl3jkwdduvhvcki	2026-03-18 15:20:13.020466	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
392b41ca-1a80-43e3-8b15-5773db785752	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773855640/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ktaouxyitcg2ju3ggqp5.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ktaouxyitcg2ju3ggqp5	2026-03-18 17:40:43.480999	f40904f2-dc04-4c56-8c6b-259d63237a2b
c6e90b6f-5f04-4f98-85f0-e699c8626a19	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773855644/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/qfgypawfmmynal25g9z2.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/qfgypawfmmynal25g9z2	2026-03-18 17:40:45.586044	f40904f2-dc04-4c56-8c6b-259d63237a2b
0740871d-18dc-4d62-af0f-c81402636c7a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773855645/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ngkyr4pe995uc4cge4vp.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ngkyr4pe995uc4cge4vp	2026-03-18 17:40:47.026874	f40904f2-dc04-4c56-8c6b-259d63237a2b
97dcee9f-54d6-4a10-806d-cf976e53e633	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773855647/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/sg2kxfkh088jeovjbjpi.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/sg2kxfkh088jeovjbjpi	2026-03-18 17:40:48.482999	f40904f2-dc04-4c56-8c6b-259d63237a2b
4e40a587-8715-4348-873b-9e826e72b2e2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773855648/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ic2ygjbyzkxthigsj6j7.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ic2ygjbyzkxthigsj6j7	2026-03-18 17:40:50.18728	f40904f2-dc04-4c56-8c6b-259d63237a2b
a2207d28-9beb-46a7-bfdd-0fa5433a49c3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994146/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/dzm4q9eq6lpcltbhdnnw.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/dzm4q9eq6lpcltbhdnnw	2026-03-20 08:09:07.471388	f40904f2-dc04-4c56-8c6b-259d63237a2b
0534678a-1808-49ec-9216-494b31456c94	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994147/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/f5gr6sxppks6aueqtgpq.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/f5gr6sxppks6aueqtgpq	2026-03-20 08:09:08.734001	f40904f2-dc04-4c56-8c6b-259d63237a2b
e09f4de2-55f1-4792-b698-e6ef901906ee	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994149/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hynczxrij37jjvcmbaab.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hynczxrij37jjvcmbaab	2026-03-20 08:09:10.126318	f40904f2-dc04-4c56-8c6b-259d63237a2b
e127eeb0-5c2b-476d-9b1f-61d42a615ebd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994150/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/er6chbikobfvbfw7q9hx.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/er6chbikobfvbfw7q9hx	2026-03-20 08:09:11.533701	f40904f2-dc04-4c56-8c6b-259d63237a2b
d39ab430-a25d-4eb0-8f11-f6371894d839	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994151/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/jpfvrerbdf6bbqyrrxsp.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/jpfvrerbdf6bbqyrrxsp	2026-03-20 08:09:14.092979	f40904f2-dc04-4c56-8c6b-259d63237a2b
c7c75876-6bca-4554-9a35-08d5e19daa00	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994154/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/uafhj344vdrjdcovaptp.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/uafhj344vdrjdcovaptp	2026-03-20 08:09:15.673741	f40904f2-dc04-4c56-8c6b-259d63237a2b
d883271e-a1f3-4679-ba1f-cca4e731138d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994156/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/vcvao6y4a8oiclmeeaen.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/vcvao6y4a8oiclmeeaen	2026-03-20 08:09:17.19575	f40904f2-dc04-4c56-8c6b-259d63237a2b
709b9378-e7ff-4f88-9ce8-1482d10ff3b1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994157/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/zrmewsv8vjotthnasmg0.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/zrmewsv8vjotthnasmg0	2026-03-20 08:09:19.961832	f40904f2-dc04-4c56-8c6b-259d63237a2b
95839b85-6143-4606-b68c-f4309a8daf6b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994477/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/vwyrfsklifjegcjkmto3.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/vwyrfsklifjegcjkmto3	2026-03-20 08:14:39.637339	f40904f2-dc04-4c56-8c6b-259d63237a2b
b4a6d2e4-a449-4e70-bebd-56fca8a1117f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994479/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/gdlrwtjjde3nwilxub5p.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/gdlrwtjjde3nwilxub5p	2026-03-20 08:14:41.154071	f40904f2-dc04-4c56-8c6b-259d63237a2b
11292036-bf85-4099-81a3-7815b5571d17	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994481/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/tb03dsfpfgfmjndyojca.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/tb03dsfpfgfmjndyojca	2026-03-20 08:14:42.589817	f40904f2-dc04-4c56-8c6b-259d63237a2b
04f65d68-66a6-4cff-8ec2-516814fef792	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994482/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/edv2a4r6ttm7ymrqq4wt.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/edv2a4r6ttm7ymrqq4wt	2026-03-20 08:14:44.621028	f40904f2-dc04-4c56-8c6b-259d63237a2b
1dc8d6e0-1c4b-43c8-a365-8f9ef6116074	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994484/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ieej4pv36o8yxwx9lx7m.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ieej4pv36o8yxwx9lx7m	2026-03-20 08:14:46.033293	f40904f2-dc04-4c56-8c6b-259d63237a2b
b4b9e16a-9358-4b23-a929-010988a6e885	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994486/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/p1b4wupkb5k24lofhxgf.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/p1b4wupkb5k24lofhxgf	2026-03-20 08:14:47.195509	f40904f2-dc04-4c56-8c6b-259d63237a2b
92925c60-1bbc-4bb2-be0b-b667ef9df72b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994487/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ymmr3ojnqlfco3lbnqnu.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ymmr3ojnqlfco3lbnqnu	2026-03-20 08:14:48.679222	f40904f2-dc04-4c56-8c6b-259d63237a2b
fbd6d83a-c6e4-49de-b0ee-9d5a6ed96e9d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994488/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ygiaficgzcgmh0fgjhek.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ygiaficgzcgmh0fgjhek	2026-03-20 08:14:50.011835	f40904f2-dc04-4c56-8c6b-259d63237a2b
1c0ba54b-913f-42e5-91a9-c130bbc15829	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994569/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/byvduijehks1imu5wliz.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/byvduijehks1imu5wliz	2026-03-20 08:16:10.531362	f40904f2-dc04-4c56-8c6b-259d63237a2b
2e1a58a4-9c11-4d25-b74c-8aee4ef4949d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994570/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hiw6cyomwf7fbkupuj2n.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/hiw6cyomwf7fbkupuj2n	2026-03-20 08:16:12.076337	f40904f2-dc04-4c56-8c6b-259d63237a2b
434f1302-5ef4-4c45-8eb9-822ffd7171a6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994572/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/yw28u0ntm29k6fgrxooa.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/yw28u0ntm29k6fgrxooa	2026-03-20 08:16:13.993617	f40904f2-dc04-4c56-8c6b-259d63237a2b
43fa6252-dfd1-4189-863b-da6cd1cf6c57	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994574/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/kv5oocmt5wrvbufxjaua.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/kv5oocmt5wrvbufxjaua	2026-03-20 08:16:15.347359	f40904f2-dc04-4c56-8c6b-259d63237a2b
cc344d00-55f6-4bcc-bac9-e29e694e0857	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994575/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/lfztgojjigpox8cjailj.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/lfztgojjigpox8cjailj	2026-03-20 08:16:17.073466	f40904f2-dc04-4c56-8c6b-259d63237a2b
8ca9a48e-9fe8-4b3c-92ee-cdbe15384e9b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994577/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/bkmkgffdgtyauv73ugbu.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/bkmkgffdgtyauv73ugbu	2026-03-20 08:16:19.353055	f40904f2-dc04-4c56-8c6b-259d63237a2b
d387155c-4d0a-4e0e-b98b-bfe811c6a1d0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994579/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/wpg9nafgfaltg59zg2iv.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/wpg9nafgfaltg59zg2iv	2026-03-20 08:16:20.570871	f40904f2-dc04-4c56-8c6b-259d63237a2b
8ea15374-cb42-43a1-a9dc-2a47c53d4301	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1773994580/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/oekwt5fryzpcdpajmafd.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/oekwt5fryzpcdpajmafd	2026-03-20 08:16:21.988939	f40904f2-dc04-4c56-8c6b-259d63237a2b
984b777a-94af-4f25-9dae-fee7ce331430	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774011251/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/lwcz6rhkxvxz18gslv47.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/lwcz6rhkxvxz18gslv47	2026-03-20 12:54:12.042648	f40904f2-dc04-4c56-8c6b-259d63237a2b
f353823a-9fc8-46c4-9d5d-49e73edb2020	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774011252/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/kz25db9x3n83iysopz98.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/kz25db9x3n83iysopz98	2026-03-20 12:54:13.325066	f40904f2-dc04-4c56-8c6b-259d63237a2b
7d673328-dcd2-4684-b826-8e5242e9d623	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774011253/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/qkwsgieezak0toukpuma.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/qkwsgieezak0toukpuma	2026-03-20 12:54:14.568518	f40904f2-dc04-4c56-8c6b-259d63237a2b
0e360e4e-49be-47a5-aa82-d76dc42da02f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774280663/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/accfrhw6xmhvsioiyr6w.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/accfrhw6xmhvsioiyr6w	2026-03-23 15:44:24.587213	9c5b8aea-784b-4166-80f9-f26b8c6799f0
300005ec-b1c6-4503-94c2-08e1833b0ffa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774280664/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/ww4pbq3jfz2qead0qdwo.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/ww4pbq3jfz2qead0qdwo	2026-03-23 15:44:25.989204	9c5b8aea-784b-4166-80f9-f26b8c6799f0
be0b3f3e-d1ad-49f9-a53c-251499385c60	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774280666/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/oqhrqmh0sfmqbowmgbxu.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/oqhrqmh0sfmqbowmgbxu	2026-03-23 15:44:27.282213	9c5b8aea-784b-4166-80f9-f26b8c6799f0
dc5b7786-2809-4af0-9c3a-d9604d09044e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774280667/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/nq8euk8kzxj7hah2kjjp.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/nq8euk8kzxj7hah2kjjp	2026-03-23 15:44:28.659737	9c5b8aea-784b-4166-80f9-f26b8c6799f0
e06904c6-6c0c-43c5-baa9-1c1ef879425a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774443293/projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ykooxybuw9anhhfvqffk.jpg	projects/f40904f2-dc04-4c56-8c6b-259d63237a2b/ykooxybuw9anhhfvqffk	2026-03-25 12:54:54.435923	f40904f2-dc04-4c56-8c6b-259d63237a2b
48b45b75-b325-4ceb-b70a-81da899eb9e0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774563137/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y6bpqapl27apbuqotvbr.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y6bpqapl27apbuqotvbr	2026-03-26 22:12:18.83514	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
48134f1e-9672-4858-85f9-b6b989034129	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774563139/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/evu9emzpmehgqi6qdwhz.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/evu9emzpmehgqi6qdwhz	2026-03-26 22:12:20.054868	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d8769df0-91de-4dc0-9024-4a8be0d2b37c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774563140/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/k0mq3fqdgwyzkvygwuq6.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/k0mq3fqdgwyzkvygwuq6	2026-03-26 22:12:21.581802	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5fba0e7f-79a2-46ed-88cb-d351da50d8c7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774563141/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/j5xjfriwfgehoqnoun85.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/j5xjfriwfgehoqnoun85	2026-03-26 22:12:23.450181	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
7d3cc4a5-58db-45df-aacc-36ef9a8680b4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774563143/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mfpnzemej5if6qtqpqf3.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mfpnzemej5if6qtqpqf3	2026-03-26 22:12:24.814324	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
72acefab-2e9f-4cfb-9bd5-2bb356a2e2d6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625242/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/lx6ygeuoqvep46vwbmlh.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/lx6ygeuoqvep46vwbmlh	2026-03-27 15:27:23.316584	9c5b8aea-784b-4166-80f9-f26b8c6799f0
ab99c1b4-78e5-448f-b2a0-bc65b59b6ddc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625243/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/nizefdvnocpt6omeu0zy.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/nizefdvnocpt6omeu0zy	2026-03-27 15:27:24.431214	9c5b8aea-784b-4166-80f9-f26b8c6799f0
8f29b3ab-d843-4cf7-a7b4-44960c7ad711	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625244/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/b7e3ipradxs437d3jips.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/b7e3ipradxs437d3jips	2026-03-27 15:27:25.828112	9c5b8aea-784b-4166-80f9-f26b8c6799f0
435607fc-7343-4247-8c15-93f8b028a743	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625303/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/zyx5gdyds7glc1dy0vyq.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/zyx5gdyds7glc1dy0vyq	2026-03-27 15:28:24.821323	9c5b8aea-784b-4166-80f9-f26b8c6799f0
56e2f54a-b624-45aa-bfff-59ceb468c647	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625305/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/uuflsrozeib0mmcukiko.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/uuflsrozeib0mmcukiko	2026-03-27 15:28:27.568254	9c5b8aea-784b-4166-80f9-f26b8c6799f0
34561644-8a15-444c-99a8-b3d66f3bac89	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625307/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/dlukdftj9kl44ns3gemh.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/dlukdftj9kl44ns3gemh	2026-03-27 15:28:28.887656	9c5b8aea-784b-4166-80f9-f26b8c6799f0
44d202ec-7324-4fcd-a069-9470c5c5ead9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625309/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/cnhm7sf5z09f3wfu4jpd.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/cnhm7sf5z09f3wfu4jpd	2026-03-27 15:28:30.429972	9c5b8aea-784b-4166-80f9-f26b8c6799f0
c2a01c0d-8579-4c3e-9866-17fb37b27f8f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625310/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/pw6bjpmkxzxshhey7zid.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/pw6bjpmkxzxshhey7zid	2026-03-27 15:28:32.608613	9c5b8aea-784b-4166-80f9-f26b8c6799f0
471cf9fa-a46b-47d5-99e0-f73166c82415	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774625314/projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/sogwdrpuznlfe4xhkfcn.jpg	projects/9c5b8aea-784b-4166-80f9-f26b8c6799f0/sogwdrpuznlfe4xhkfcn	2026-03-27 15:28:35.845573	9c5b8aea-784b-4166-80f9-f26b8c6799f0
8a81e462-3c11-452e-82e3-2213b008e6e7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774627613/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kp4v50clstjtz5mssabw.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kp4v50clstjtz5mssabw	2026-03-27 16:06:54.533747	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6e6bf8fb-83e2-40b3-bdc7-df6eb08882dd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774627614/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cy3292biygfm8ihvrvq1.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cy3292biygfm8ihvrvq1	2026-03-27 16:06:56.114987	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
b1ad5e0c-1026-4976-854b-a1f6e7f3b6b3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774627616/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/nv2lysi9pmu8k7tbrks2.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/nv2lysi9pmu8k7tbrks2	2026-03-27 16:06:57.522183	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
1f97660b-d002-40e4-8937-46eb0ac9a34a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774627617/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zvmst2lu7fhrir3slwsd.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zvmst2lu7fhrir3slwsd	2026-03-27 16:06:58.761709	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
20c64102-d42f-4262-b238-948ef30fd673	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634420/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/oqwralnojtayltooxznl.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/oqwralnojtayltooxznl	2026-03-27 18:00:22.670112	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
b5d0eafa-e739-4830-bad1-d960d3952bb6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634423/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mrcfqio2hxhdmbrgyatx.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mrcfqio2hxhdmbrgyatx	2026-03-27 18:00:26.306208	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
2299dcdc-737c-46ff-aabf-53a5365dc214	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634426/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hhdunkryckkgt1recp2y.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hhdunkryckkgt1recp2y	2026-03-27 18:00:27.929276	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
ccf8e6ba-8036-48af-8e45-ee483cfd02d0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634428/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/v0hy6bcnm0r5wvs6gir6.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/v0hy6bcnm0r5wvs6gir6	2026-03-27 18:00:30.024464	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
bbdc8550-b7ae-4712-9f81-c3c2cb78938f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634430/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/obeyebunkzqd6wp7y6oa.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/obeyebunkzqd6wp7y6oa	2026-03-27 18:00:32.345583	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
8130984e-e855-45b0-99f3-ecec0e6248f8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774634432/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mk40izpfbegygtau4o7z.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mk40izpfbegygtau4o7z	2026-03-27 18:00:33.959165	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d6990005-3e81-4705-af35-73e76170df1d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721107/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jkycuqxr2dc5wjtbw5co.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jkycuqxr2dc5wjtbw5co	2026-03-28 18:05:09.324024	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
19e64387-8d0c-4248-bb9c-798ef9c72022	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721113/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hzlwi4gafmys6neorvl5.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hzlwi4gafmys6neorvl5	2026-03-28 18:05:17.326901	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5509e1e5-d25d-4423-9d9d-39b19ac27a00	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721117/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/owmbmpbiuywizdxyudpb.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/owmbmpbiuywizdxyudpb	2026-03-28 18:05:18.903685	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
690d443b-17f2-48c4-af11-d3ce1f925559	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721119/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yvpcae9k4bek5hlmuyr1.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yvpcae9k4bek5hlmuyr1	2026-03-28 18:05:20.560652	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
b730cd72-5380-4b78-882a-5bf90f9c9c64	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721125/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/bb67izvdwmsexnbyxyyp.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/bb67izvdwmsexnbyxyyp	2026-03-28 18:05:31.982089	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
21d10635-c0bc-4929-a5b3-eba7ac14f7fb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721132/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lenb0j00tmyfidmbenmd.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lenb0j00tmyfidmbenmd	2026-03-28 18:05:33.482296	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6ba62ab4-91b6-419e-bba4-3c520ef98e36	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721134/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vbwosvuoccqrmjen7mdv.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vbwosvuoccqrmjen7mdv	2026-03-28 18:05:37.180154	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
696224cf-9dc7-455f-9ed2-867b726f6b03	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774721137/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/sdjy5dpzrzakfajrl46h.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/sdjy5dpzrzakfajrl46h	2026-03-28 18:05:39.18411	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
c531595e-9cdb-4f07-9819-107f79287342	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774889094/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/pewtnfqloaoshjuapcqa.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/pewtnfqloaoshjuapcqa	2026-03-30 16:44:55.849183	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
00ecb10e-bfc9-473c-8ee5-9f642786ebab	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774889096/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/drdosw6bkp8kui1gxcku.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/drdosw6bkp8kui1gxcku	2026-03-30 16:44:57.313687	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
4c3cb4c5-958c-4fc4-a8d3-cfe405324e0e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774902870/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hauqt7benabbewxep2in.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hauqt7benabbewxep2in	2026-03-30 20:34:31.394588	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6e9c9976-113d-4076-a276-5ecbed9e1f8f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774902871/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/xnelx4ubycfjaxfeyoma.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/xnelx4ubycfjaxfeyoma	2026-03-30 20:34:34.384102	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d960045f-cf8f-4b2b-a1c6-de435d435dbc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774902874/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zz5zyuqt6djehrusavzc.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zz5zyuqt6djehrusavzc	2026-03-30 20:34:35.892103	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
87ab915d-225c-49f1-afa8-8a64f1ee4957	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774978206/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fxaieiqnndynf2x2mddo.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fxaieiqnndynf2x2mddo	2026-03-31 17:30:07.193586	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5b887d03-86bb-4ee2-bf7c-a0b88f515058	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1774978207/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojpl3kcppkqngnyxweqi.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojpl3kcppkqngnyxweqi	2026-03-31 17:30:09.071529	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
337d5cb0-40a0-40f7-bceb-dcf48ad8a0fa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775147991/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vprivf0j9kxnwp1iydtt.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vprivf0j9kxnwp1iydtt	2026-04-02 16:39:53.199988	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
bb74e01d-3757-4920-bdd7-0382c89ac069	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148292/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lpv37mviq74h6som6ba5.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lpv37mviq74h6som6ba5	2026-04-02 16:44:53.614933	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6ffbc8b3-c53d-4fb6-92ed-bf615dd3243b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148293/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/aqajwvunpgtym3lbllud.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/aqajwvunpgtym3lbllud	2026-04-02 16:44:55.066741	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
9e645ea8-c04b-4af8-9085-d274cefb4344	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148295/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hvetrwbtp5hiwe7ik4gx.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hvetrwbtp5hiwe7ik4gx	2026-04-02 16:44:56.596209	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
1ed94742-8586-4cf3-9af1-203fb67c53eb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148296/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/amjfzal7fczs65cg80ra.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/amjfzal7fczs65cg80ra	2026-04-02 16:44:57.891877	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
2fd5189f-c348-40bc-ab4f-d70f1167ebfd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148298/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y7dubdta3qgih6lolpo4.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y7dubdta3qgih6lolpo4	2026-04-02 16:44:59.143953	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
cf77d271-2a2c-4f29-a2b5-0cfd3d08758f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148299/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/dgaj0taevdztd0zgttsa.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/dgaj0taevdztd0zgttsa	2026-04-02 16:45:00.443296	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
2d605ad0-6311-40b1-bc2a-fb22b5a2342d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775148300/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/bc15ge30aim31yuz3qtk.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/bc15ge30aim31yuz3qtk	2026-04-02 16:45:02.071656	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
426967cf-0b69-4152-b1d3-a32fa4b41e87	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775234843/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/rdut4nfghwddweevtkui.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/rdut4nfghwddweevtkui	2026-04-03 16:47:24.546925	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
fa5e086b-9961-4371-8c8d-e145b9ac5212	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775234844/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zlhiw49ldouaskjfxdcu.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zlhiw49ldouaskjfxdcu	2026-04-03 16:47:26.062804	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
27e9194e-78bc-45db-a36e-97e2bdcff952	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235094/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fuooppi94puof9xtruoc.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fuooppi94puof9xtruoc	2026-04-03 16:51:35.361368	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d883c3f7-58b8-496c-8669-b0c8af01f086	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235095/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lkzhad5zehscwekmh40h.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lkzhad5zehscwekmh40h	2026-04-03 16:51:36.97325	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
21aeae73-cfc3-442f-a4ec-cd08d5622fe3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235097/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/nq0vn60jm8xedfizrzav.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/nq0vn60jm8xedfizrzav	2026-04-03 16:51:39.330323	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
21446a51-a1c8-4e47-8f79-01b8de5a0ba3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235099/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kifgy3cvygepphjuftfu.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kifgy3cvygepphjuftfu	2026-04-03 16:51:40.833728	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
31ff052f-cbd0-4a65-94da-dce8a1578f77	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235101/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/wz6oizwmdxqddqhiowoc.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/wz6oizwmdxqddqhiowoc	2026-04-03 16:51:42.341329	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6089bc6a-9abb-4c60-8512-249590d8213a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775235102/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/obbg6yqmzs1dn8mmccde.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/obbg6yqmzs1dn8mmccde	2026-04-03 16:51:44.087674	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
f992aab6-3544-4639-9ab8-baf586b8d32d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775484386/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vn9garnmbsbnjzxmutja.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vn9garnmbsbnjzxmutja	2026-04-06 14:06:27.399189	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d89aadcb-b74b-42de-b11a-a8d5dd101346	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775484387/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/l6r2om1dwyfakzfo9pj6.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/l6r2om1dwyfakzfo9pj6	2026-04-06 14:06:29.728102	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
0a352cf6-9c8e-4b97-93f9-60151d909700	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775484390/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fii2qch5nq7s89fjcime.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fii2qch5nq7s89fjcime	2026-04-06 14:06:31.249166	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
30713d5f-5215-406f-b269-21f1421d09ca	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775668935/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y9fncstwdiibrqpgg3uj.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/y9fncstwdiibrqpgg3uj	2026-04-08 17:22:17.053827	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
26ff54b3-49e6-4194-8ad2-e800bfbdfd1c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775668937/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/e4vksv8sjwqzskmi8b8o.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/e4vksv8sjwqzskmi8b8o	2026-04-08 17:22:18.632952	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
fd4923b2-fdaf-4a62-9261-0b2fbd710895	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775668938/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/doieisf7vbfixpxunvqj.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/doieisf7vbfixpxunvqj	2026-04-08 17:22:20.340132	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
fe37d59b-804d-477b-9de8-ba9fda940f7a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775668940/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojqvpozccg10bizfstle.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojqvpozccg10bizfstle	2026-04-08 17:22:21.869374	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
7b6b9af3-e159-49b0-8e53-fa9d4fe9029f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775668942/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jxrxend4khufouhdfhwm.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jxrxend4khufouhdfhwm	2026-04-08 17:22:24.031742	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
ac30baf6-8e1c-4222-b0d1-77fea6fbe783	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775669005/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hevup4syv1tqtxssvjmo.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hevup4syv1tqtxssvjmo	2026-04-08 17:23:26.717454	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
0b3c083e-7e51-4323-9dee-547ef25df286	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775669007/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ufpua9glixal7vibv9ne.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ufpua9glixal7vibv9ne	2026-04-08 17:23:28.263279	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
dc426d5a-ca80-4388-a244-a52f94cac8bf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775757264/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/re5f76fug3sm6fhvp7ku.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/re5f76fug3sm6fhvp7ku	2026-04-09 17:54:25.299489	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6a99edb6-de4c-4d25-8ef1-4cb00ed8eb54	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775757265/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/viocpek39ftczdfvs13v.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/viocpek39ftczdfvs13v	2026-04-09 17:54:27.032535	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
da610b98-8656-4de8-8b21-cf99ec8ce864	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775757267/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/pdkabjazpylil76yuunz.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/pdkabjazpylil76yuunz	2026-04-09 17:54:28.595543	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
a75ff1cd-fa31-4e54-bc17-32a4274c000f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775888006/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yrh2hpg33vye6gwayedj.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yrh2hpg33vye6gwayedj	2026-04-11 06:13:27.635998	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
06c08d6a-a85a-4f66-8fee-35b0a6fbb5e1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775888007/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cskanfg2hxlqbucclhkv.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cskanfg2hxlqbucclhkv	2026-04-11 06:13:28.910936	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d0b30ee7-07bf-4419-b039-7ec10119b978	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775888009/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/thztylk49fapqtzqkm7u.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/thztylk49fapqtzqkm7u	2026-04-11 06:13:30.265591	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
67422797-d940-4bf1-9bcd-1bb6d7a54938	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775888010/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/eutv6byntylhv2ce0stv.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/eutv6byntylhv2ce0stv	2026-04-11 06:13:31.850175	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
40e1268f-5168-40ed-b268-150af443aed4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775888012/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zz1zx3fpauaaujhgxvof.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/zz1zx3fpauaaujhgxvof	2026-04-11 06:13:32.934234	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
fbc03b01-2905-4174-851c-3a19b92f9e4b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775918500/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/i1dirmfvcaqbmwmk1s1q.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/i1dirmfvcaqbmwmk1s1q	2026-04-11 14:41:41.349538	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
719316c5-d2a2-4a15-b54d-c10a43958d4c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775918501/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jgrmxk2kgnrjilsqukpc.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jgrmxk2kgnrjilsqukpc	2026-04-11 14:41:42.758164	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5bab49fe-e734-449a-be4c-fcc4b9cc2151	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775918503/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mrttizdeb3nmlywsuolu.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mrttizdeb3nmlywsuolu	2026-04-11 14:41:44.031283	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5e7c6ddc-805b-4b1f-9355-3df75e61dd75	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775918504/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/rfvmsiovapjqrhrdvoq1.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/rfvmsiovapjqrhrdvoq1	2026-04-11 14:41:45.533548	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
be89f80a-3f87-45bd-a080-04ef25432959	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1775918505/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/p4rbl96l4pnledrrhpo2.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/p4rbl96l4pnledrrhpo2	2026-04-11 14:41:46.839108	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
13f8b1ca-471a-4ace-b7e0-9d993cfc1a6b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776138244/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vqktipgp9gzmcaevu4ix.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vqktipgp9gzmcaevu4ix	2026-04-14 03:44:05.00908	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
3b406618-076a-4a6e-b220-85fcb4344494	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776138245/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jkrwd74cyj5zgzkqbtd5.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jkrwd74cyj5zgzkqbtd5	2026-04-14 03:44:06.646429	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d3f869a2-7cd8-4a1e-873a-33e4c41687c9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776138247/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/deldzg7zg2nhek6gm0gw.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/deldzg7zg2nhek6gm0gw	2026-04-14 03:44:07.956163	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
12332d06-3041-4c2d-9913-2c8fa5c0ad91	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776339394/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yzawtxeikqrjpnp2qxul.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/yzawtxeikqrjpnp2qxul	2026-04-16 11:36:35.802897	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
a6fd94ed-9499-4109-afaa-792ae571519a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776339396/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gx2mv2nyoepdrsmf3hrp.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gx2mv2nyoepdrsmf3hrp	2026-04-16 11:36:37.102654	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
b6dda345-193e-46a7-9939-733c4451181b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776339397/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/r4psyz6dtdrzoxiqhso0.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/r4psyz6dtdrzoxiqhso0	2026-04-16 11:36:38.376902	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
0e168859-9733-4ee5-aa1e-12fcdf81eb56	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776339398/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lxldqxqynngnpaevjy7t.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/lxldqxqynngnpaevjy7t	2026-04-16 11:36:39.864954	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
163f1b5f-83e4-4acd-be58-3de88b3f0d6e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776363009/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/i8joex0ncfxnsjupnvxm.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/i8joex0ncfxnsjupnvxm	2026-04-16 18:10:11.188595	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
1907db0c-c155-4cfa-a066-b1fec361de4d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776363011/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/asyujfr1th42kporhnb1.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/asyujfr1th42kporhnb1	2026-04-16 18:10:13.395782	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
7bf9232b-c03b-42a3-bb98-45f071769a8c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776439257/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ti22chc25xpbjgnq6eld.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ti22chc25xpbjgnq6eld	2026-04-17 15:20:58.813919	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
3a92e674-c305-4168-8aaf-5b8cba980f00	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776439259/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jg3o3j5sxsow7jkqngec.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/jg3o3j5sxsow7jkqngec	2026-04-17 15:21:00.523366	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
dcb76935-2942-45e9-8dfc-ad4a0258eec3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776439260/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/qkk4qhhnqpcox8gjsyws.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/qkk4qhhnqpcox8gjsyws	2026-04-17 15:21:02.050643	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
8470eb4d-ccb7-4745-9e1a-a1ce943b16b8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776439262/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/q6zb6cqyzc9dsrpw1kpe.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/q6zb6cqyzc9dsrpw1kpe	2026-04-17 15:21:03.362088	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
99a0848f-56de-4f3d-9dac-e64ae639ce47	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1776439263/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fign1hg26hpl5dyfeuix.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fign1hg26hpl5dyfeuix	2026-04-17 15:21:04.983868	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
362f63b3-b320-4291-a71e-5505cc918b7d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303532/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/s1ypdqcakbsvu0i0z89s.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/s1ypdqcakbsvu0i0z89s	2026-04-27 15:25:34.067787	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
938b1434-023d-4be5-8a05-97b6de08b6cf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303534/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/piyrhp2cvncjid8ovgzg.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/piyrhp2cvncjid8ovgzg	2026-04-27 15:25:35.480244	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
b4d04304-a4d0-4767-acf9-f365eb302d44	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303535/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/tnplwbzicdeknp9ugaww.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/tnplwbzicdeknp9ugaww	2026-04-27 15:25:37.030525	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
d03c8f4e-15ed-4a2c-9cd1-171a5d9bf5a8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303537/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ipxbswbeqtz2cfpqqcg8.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ipxbswbeqtz2cfpqqcg8	2026-04-27 15:25:38.458073	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
3f1e8299-022e-4358-96b8-ec260d6f42f2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303538/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/xwn2g30rmi6qkd4ifaez.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/xwn2g30rmi6qkd4ifaez	2026-04-27 15:25:39.872331	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
c293d87b-83c7-4c56-aab7-1bd4722711ce	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303540/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gbpjnlxuoejar92qqs4t.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gbpjnlxuoejar92qqs4t	2026-04-27 15:25:41.192073	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5a1194ef-8e5d-447e-9e9a-62260b69ab9f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303541/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/dl5huatd6ngixbd0cpwk.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/dl5huatd6ngixbd0cpwk	2026-04-27 15:25:42.614617	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
c6a4632d-cfa2-40dd-924d-c8905d701b00	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303542/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojqnezxf4sukxtyzdjqy.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ojqnezxf4sukxtyzdjqy	2026-04-27 15:25:44.068336	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
5f7b53cf-c047-4b7c-aedc-10dc44494a47	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303544/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/z3amsajed8vq4o3v8rty.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/z3amsajed8vq4o3v8rty	2026-04-27 15:25:45.448569	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
2e33de5f-84ca-4610-acc7-43961bc95f1e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777303545/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kzrxdcgbhpvgme8qu3p9.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/kzrxdcgbhpvgme8qu3p9	2026-04-27 15:25:46.824162	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
7f1343f7-a5c8-442a-9d47-7dfc13c991c5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401076/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qwapsys9hgvjc9cp80jx.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qwapsys9hgvjc9cp80jx	2026-04-28 18:31:18.130473	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
c861a6a4-e0f7-453d-bea3-7261d24f63d9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401078/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/kr7b2xtsthart3oc10or.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/kr7b2xtsthart3oc10or	2026-04-28 18:31:19.745275	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
8bdf632a-ea2d-4ba0-a832-04356499624f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401080/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/l3utywcy3o9jjfft9l0l.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/l3utywcy3o9jjfft9l0l	2026-04-28 18:31:21.586004	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
87dce234-9ffa-4005-8651-b0c0e4d3561e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401081/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nmavo0v7izsf8o0kcvjc.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nmavo0v7izsf8o0kcvjc	2026-04-28 18:31:23.094175	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
fe0b91ca-f6a2-4334-a298-d35dfbf24591	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401083/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/v9rgmuvcjsakspqy9gcl.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/v9rgmuvcjsakspqy9gcl	2026-04-28 18:31:24.567052	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
8cf8401f-41ec-434d-b959-2aadd7421399	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401085/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lualf2ivsh1cl0rmcnwd.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lualf2ivsh1cl0rmcnwd	2026-04-28 18:31:26.340348	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f2f4dc3e-4c0b-4cbc-a41c-b9b3980c0fef	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777401086/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qn7g5m9qmbkkuu0dxerv.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qn7g5m9qmbkkuu0dxerv	2026-04-28 18:31:28.057664	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
2578f937-7a6b-41bb-9994-112654155646	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777435270/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/madkacsrzkn4nggsq8pz.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/madkacsrzkn4nggsq8pz	2026-04-29 04:01:11.553713	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f62e9480-3d70-40f8-a556-09ab4c523fb4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777473589/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ynoxmv6yspp4767hzmm2.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ynoxmv6yspp4767hzmm2	2026-04-29 14:39:50.910832	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
397161fb-a4fe-41a8-a2b4-63e251bae134	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777524290/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/daeote7ybxxrjwau2po7.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/daeote7ybxxrjwau2po7	2026-04-30 04:44:51.906947	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
06dd2be2-6800-4311-90f8-d95a4ef9a187	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777524292/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/bgod5fpk2g7fjil9llmv.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/bgod5fpk2g7fjil9llmv	2026-04-30 04:44:53.264341	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
e697593d-2287-4589-a0ee-c799f6177061	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777524293/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/xhyefmo408vcvagsnjwv.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/xhyefmo408vcvagsnjwv	2026-04-30 04:44:54.516866	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
a7232c7f-9309-4cf6-ae0a-6f4d14c97c72	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777574540/projects/1518522b-892b-47ef-afe6-b56caa69af4c/nt7akzroxxxsw91oomrm.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/nt7akzroxxxsw91oomrm	2026-04-30 18:42:21.164669	1518522b-892b-47ef-afe6-b56caa69af4c
9f5dbf1f-c212-4a26-9330-47cbf25113ca	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777574541/projects/1518522b-892b-47ef-afe6-b56caa69af4c/lwv2q14gabvpfnsjj217.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/lwv2q14gabvpfnsjj217	2026-04-30 18:42:22.485235	1518522b-892b-47ef-afe6-b56caa69af4c
1fd6c96c-7821-40c8-b64d-7ec0449e27cf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650344/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/wowlb17kd9ntxz4vmz38.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/wowlb17kd9ntxz4vmz38	2026-05-01 15:45:45.447526	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f2a18361-2d3e-4c22-8653-7a8f9940f7b6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650345/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/oklhtpaqqkedwsbnwyc6.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/oklhtpaqqkedwsbnwyc6	2026-05-01 15:45:47.293014	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
a40a9a7f-d9f4-4452-a349-2987e01a928f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650347/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/yczmisigzeinrdmmmdtd.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/yczmisigzeinrdmmmdtd	2026-05-01 15:45:48.643085	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
c7c1ae0e-726b-4552-aac2-6681aef2690d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650349/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nftlwgnexv3kwrpd7qqv.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nftlwgnexv3kwrpd7qqv	2026-05-01 15:45:50.473201	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
10c2cd5e-b5eb-4297-9be0-1e8239e12d64	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650350/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/p47sysldzvxli80ksvgs.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/p47sysldzvxli80ksvgs	2026-05-01 15:45:52.338322	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
4718ce51-3781-49fc-9c60-b76c841b3018	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650534/projects/1518522b-892b-47ef-afe6-b56caa69af4c/ll8mzirf2ay3mkgnugpk.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/ll8mzirf2ay3mkgnugpk	2026-05-01 15:48:55.654402	1518522b-892b-47ef-afe6-b56caa69af4c
a6c70395-1df1-46c4-9a96-3255731c63c7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650535/projects/1518522b-892b-47ef-afe6-b56caa69af4c/fyf32zervcbigqytviyd.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/fyf32zervcbigqytviyd	2026-05-01 15:48:56.921963	1518522b-892b-47ef-afe6-b56caa69af4c
0092c218-fee1-4a27-8b21-de84828e140e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650537/projects/1518522b-892b-47ef-afe6-b56caa69af4c/olvmpkzrqvxrqww3pcht.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/olvmpkzrqvxrqww3pcht	2026-05-01 15:48:58.199999	1518522b-892b-47ef-afe6-b56caa69af4c
73498f4c-639a-4bea-8d88-ebd09395d9f1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650538/projects/1518522b-892b-47ef-afe6-b56caa69af4c/eub6woolkhphfk1nppqx.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/eub6woolkhphfk1nppqx	2026-05-01 15:49:00.012098	1518522b-892b-47ef-afe6-b56caa69af4c
a6be6560-9f18-4819-b3dd-943320b3cad9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650540/projects/1518522b-892b-47ef-afe6-b56caa69af4c/rbwtyrusxtpt1smxq8hs.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/rbwtyrusxtpt1smxq8hs	2026-05-01 15:49:01.296086	1518522b-892b-47ef-afe6-b56caa69af4c
294a2c3b-6ff3-42b0-a70f-3ff92f682585	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777650541/projects/1518522b-892b-47ef-afe6-b56caa69af4c/obnhrtzdb9iuuy9l7ktv.jpg	projects/1518522b-892b-47ef-afe6-b56caa69af4c/obnhrtzdb9iuuy9l7ktv	2026-05-01 15:49:02.669372	1518522b-892b-47ef-afe6-b56caa69af4c
cf25309b-19c0-4dc0-90c1-d334201bc1cd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745574/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ul6aqajy62ksrzprxhxu.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ul6aqajy62ksrzprxhxu	2026-05-02 18:12:56.33533	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
9e27f606-ae46-43a3-88c9-740b85c03753	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745576/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mfazjt37zmexe00xux11.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/mfazjt37zmexe00xux11	2026-05-02 18:12:57.737453	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
003e34e7-bc32-4970-98f8-4db90d1bb1dd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745578/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/thufby9rm6svrblgnd9v.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/thufby9rm6svrblgnd9v	2026-05-02 18:12:58.952662	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
3e551413-505c-4c38-a5fb-37c05c64c196	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745579/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hufyokfnzkyhziwsqubp.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/hufyokfnzkyhziwsqubp	2026-05-02 18:13:00.234773	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
898f035e-3ccf-484c-b776-92e97e2674c4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745580/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ogb5ljosclta3eotyxgt.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/ogb5ljosclta3eotyxgt	2026-05-02 18:13:01.53627	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
f2b07ca0-f7b5-4fd3-9f83-f40f52251bd0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777745581/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fxazfgh0rjdugvfea1sq.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fxazfgh0rjdugvfea1sq	2026-05-02 18:13:02.771047	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
6a28a6a3-ad3b-4400-b4b9-cb6dbfb2b806	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927107/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fhmw03djijah3ik9mlap.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/fhmw03djijah3ik9mlap	2026-05-04 20:38:28.476476	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
83d4b225-afc3-4575-918c-491bfafff099	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927108/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gceuhk9niugnh35t1yfx.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/gceuhk9niugnh35t1yfx	2026-05-04 20:38:29.697064	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
8c3a5451-ce55-45b4-8b4a-d2ced50ce4aa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927109/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/spyoylpemq5d18wko4t9.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/spyoylpemq5d18wko4t9	2026-05-04 20:38:31.045832	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
ed46cdf5-93eb-468e-a38f-ce44844f8a34	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927111/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/p1ogbfbn6hkdqzriwzqk.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/p1ogbfbn6hkdqzriwzqk	2026-05-04 20:38:32.440003	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
19d031e0-b28e-4f69-a9bb-7e95e7ae83f4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927112/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vou295rxw3ocb5xevli9.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/vou295rxw3ocb5xevli9	2026-05-04 20:38:33.861133	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
1ea34d1c-e0cc-4f2d-8c2c-a7a87f0cfc6d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927114/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cznx2rnvxho9nteicwrx.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/cznx2rnvxho9nteicwrx	2026-05-04 20:38:35.330595	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
a8b8a621-2406-429b-80da-37117afba349	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1777927115/projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/k0xvx2jqe6msxpktmdet.jpg	projects/8ba316b3-e1e3-4673-b340-be2f65bf9ce2/k0xvx2jqe6msxpktmdet	2026-05-04 20:38:37.103844	8ba316b3-e1e3-4673-b340-be2f65bf9ce2
a5f10163-d17e-4106-9aca-52df741ae6c6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001436/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ji6sehsbchh8pb9crgks.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ji6sehsbchh8pb9crgks	2026-05-05 17:17:17.780611	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
b54c2db3-9dad-4030-aec4-10b3f12920ca	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001438/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/glkpcfudexgegrjd6paz.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/glkpcfudexgegrjd6paz	2026-05-05 17:17:19.66862	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
fe8a0851-59ef-4e66-b465-d455a4c1dcf4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001439/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/hzeemda4yxxutk0fhcfz.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/hzeemda4yxxutk0fhcfz	2026-05-05 17:17:21.114451	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
e04b94ab-b984-48a9-b5fb-0f44afb4d661	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001442/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/iroryv4yxf9cse2cqkvh.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/iroryv4yxf9cse2cqkvh	2026-05-05 17:17:24.162565	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
977ca900-4e80-4c25-99d6-91eca38182ec	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001444/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/exmsax93kfsnfx7itb1a.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/exmsax93kfsnfx7itb1a	2026-05-05 17:17:25.531209	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
cd30ffa6-0cfa-408f-9a0d-16bb000df121	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778001445/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ypl5sszjaeymncobsffx.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ypl5sszjaeymncobsffx	2026-05-05 17:17:27.003397	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
8f7cd22a-58f8-4ba7-bb9c-f8aea9effacc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075339/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/uqcr9s4z1m4brqdlw7yr.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/uqcr9s4z1m4brqdlw7yr	2026-05-06 13:49:00.451811	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5999c351-17c9-4f3b-bbf2-809048a6b693	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075340/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iq0buzuulqw7epmtwkih.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iq0buzuulqw7epmtwkih	2026-05-06 13:49:01.853466	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
dab730c3-a0fb-4033-8dcb-a86d5d2b4ac4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075342/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wg3mj26dncikwmloz94o.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wg3mj26dncikwmloz94o	2026-05-06 13:49:03.223782	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6d435ef7-ef3f-48ea-942f-7502db75af24	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075343/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lv8eyhl45n0fyjqofrjj.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lv8eyhl45n0fyjqofrjj	2026-05-06 13:49:04.781653	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
e8d2adf3-a9da-4a32-8413-6acfd64d4c64	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075345/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pzdotcbx6lb1ophfb7uu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pzdotcbx6lb1ophfb7uu	2026-05-06 13:49:06.398617	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
7861d6d7-02c9-4a83-8999-fb7591b96a82	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778075346/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lsbvsgj3nyukgdms3jus.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lsbvsgj3nyukgdms3jus	2026-05-06 13:49:07.76206	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c773000d-02be-42ba-8f24-3c39a14bb1b8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176835/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nurdygkfwb2qtxixkows.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/nurdygkfwb2qtxixkows	2026-05-07 18:00:36.727991	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
49b63393-66c3-4fb6-a76a-7029ea064796	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176837/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lqnrjbdrlpooeitk6vd8.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lqnrjbdrlpooeitk6vd8	2026-05-07 18:00:38.359845	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
59b85faf-414a-4054-87fe-33553c26bbfa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176838/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ziush8d6wfhd9atxpor0.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/ziush8d6wfhd9atxpor0	2026-05-07 18:00:40.22441	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
b9db73e1-c5bc-4137-975b-c68d28517c7c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176840/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/s2giex1iu7vxtcqu2ybl.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/s2giex1iu7vxtcqu2ybl	2026-05-07 18:00:41.785402	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
31c32f48-000f-4a99-b348-0ddf36825a44	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176842/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/sno7cusddxyhlhayc5rk.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/sno7cusddxyhlhayc5rk	2026-05-07 18:00:43.113304	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
54c22ce3-aad6-45bb-9473-2a43539c84ef	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778176843/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/clfketuzlznr1n75olqs.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/clfketuzlznr1n75olqs	2026-05-07 18:00:45.101627	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f449317f-f804-4097-b91e-cfbfde454117	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778253391/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/op97fhl3ixxoc5zgcyuy.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/op97fhl3ixxoc5zgcyuy	2026-05-08 15:16:32.816695	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
6eff8d9e-7237-4da4-b099-55fd77c4e008	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778253393/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/rsqf7sclu8kusals4hpq.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/rsqf7sclu8kusals4hpq	2026-05-08 15:16:34.617291	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
0d614e59-7949-4f5a-b7e9-9c18f49d5baf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327974/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vnocp6hhijsn2nzdotpd.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vnocp6hhijsn2nzdotpd	2026-05-09 11:59:36.113529	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
d1839545-3660-4abc-8315-ee760cedd329	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327976/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jybvxkktc3bwk45jf5eh.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jybvxkktc3bwk45jf5eh	2026-05-09 11:59:37.533064	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
26a9b996-172b-40f6-b378-208c99c8077d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327977/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/euocpvkzbyf848d8fnvp.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/euocpvkzbyf848d8fnvp	2026-05-09 11:59:38.808958	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f5668982-6f48-4f08-986b-109710a4ab7a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327979/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/arobi9sq3h2hwgorjksx.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/arobi9sq3h2hwgorjksx	2026-05-09 11:59:40.124539	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f22b6510-b594-4b61-a0ed-40a4a03d43b0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327980/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hlcbk3tevhd0uo21xshz.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/hlcbk3tevhd0uo21xshz	2026-05-09 11:59:41.370847	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5727d81d-7579-4c95-a9eb-9d39fc643f76	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327981/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/p5dtnqaeywu5nwt9ja81.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/p5dtnqaeywu5nwt9ja81	2026-05-09 11:59:42.798746	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
671936e9-83e5-4d22-b006-ff2ef79ad87f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327983/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pks17ogyvpqvo716nnbw.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pks17ogyvpqvo716nnbw	2026-05-09 11:59:44.037535	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6a6703c8-ae16-4ace-b010-82d01f8aedb0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778327984/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ruzsbfqagxsmcldctsn5.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ruzsbfqagxsmcldctsn5	2026-05-09 11:59:45.442387	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
4517cf85-bd35-4d32-a186-5fe349acfecd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778344979/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jlj6t5fmxxfkkiz1fvcd.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/jlj6t5fmxxfkkiz1fvcd	2026-05-09 16:43:00.463656	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6e17bf0e-d6c2-42cf-921b-7b7dc9ec1a38	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778344980/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xf9llpshlwwjpcbdsp3t.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xf9llpshlwwjpcbdsp3t	2026-05-09 16:43:01.813361	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
37fa0362-a5c6-46eb-b909-352b0484e979	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778344982/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vcjcfsrg9cujlexfih98.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vcjcfsrg9cujlexfih98	2026-05-09 16:43:03.214616	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f722e47d-c3e1-4c70-a0e5-d87eebf09a83	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768264/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/geoae9s34aqluyvjqreu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/geoae9s34aqluyvjqreu	2026-05-14 14:17:46.060396	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
0e08072b-ad40-4ee1-8f76-83f64cb05e5c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768266/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bbtxrpovy1itseiuceum.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bbtxrpovy1itseiuceum	2026-05-14 14:17:47.847434	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
a54e6016-2487-4829-a391-b90b7ff3db23	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768268/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/u1is83u2vlzpalbwefxl.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/u1is83u2vlzpalbwefxl	2026-05-14 14:17:49.759381	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6cd217e6-dea7-431e-a25e-60d0c9d43c30	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768270/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/zjc4fgujkiytdpmi0i9n.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/zjc4fgujkiytdpmi0i9n	2026-05-14 14:17:51.60584	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
831ffeb3-2ede-4af5-8948-ac0ec6924ba2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768271/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/dm1ovsiaupqswmiqxhlb.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/dm1ovsiaupqswmiqxhlb	2026-05-14 14:17:53.101115	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
15ac7f19-6817-4ca2-b640-45159ddf3893	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768273/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cpbortn28pkucn7rkyox.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/cpbortn28pkucn7rkyox	2026-05-14 14:17:55.847893	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
0e0a6e6a-996f-4309-a427-2e0409e2d070	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768276/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wsxkknfvbucubpac1ohg.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wsxkknfvbucubpac1ohg	2026-05-14 14:17:57.191552	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
4053abe8-2a99-49be-a31b-24b62e3148a7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768277/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ehbgzq9rqc7sinuaimvw.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ehbgzq9rqc7sinuaimvw	2026-05-14 14:17:58.58045	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
a5db788e-f596-49d9-919d-71028b9ff3a6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768278/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lwn71exdw6opyc1emwsf.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/lwn71exdw6opyc1emwsf	2026-05-14 14:18:00.249411	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
67e34ed5-50a3-4710-a3fc-67aaddda0623	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778768280/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iccj0vwlf2indkctnovx.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/iccj0vwlf2indkctnovx	2026-05-14 14:18:01.791	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
c8af2eec-1d56-4525-b989-c4d1a3701abc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778850342/projects/4813a930-e772-4adf-85d8-0448d373f829/piv7h4g3kjmvy2cmv5f1.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/piv7h4g3kjmvy2cmv5f1	2026-05-15 13:05:43.747001	4813a930-e772-4adf-85d8-0448d373f829
51d59ed0-07d7-4309-bc7b-4c547b6ba2a6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778850344/projects/4813a930-e772-4adf-85d8-0448d373f829/viitxxqzbjidcs129v5f.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/viitxxqzbjidcs129v5f	2026-05-15 13:05:45.388812	4813a930-e772-4adf-85d8-0448d373f829
a4750f41-6ce7-4451-9b01-61ee9c5dcf98	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778850345/projects/4813a930-e772-4adf-85d8-0448d373f829/ll4wctiq39qkz1qu0fwu.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ll4wctiq39qkz1qu0fwu	2026-05-15 13:05:46.985846	4813a930-e772-4adf-85d8-0448d373f829
7da080ba-fcb8-4b86-8ec3-cdd2d8b50d98	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778850347/projects/4813a930-e772-4adf-85d8-0448d373f829/nmi321l7kmlakdikzoit.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/nmi321l7kmlakdikzoit	2026-05-15 13:05:48.817332	4813a930-e772-4adf-85d8-0448d373f829
26f0a0bb-61ab-46ab-a592-6f17057d457e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869785/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fdzptogpag0aeg14ddju.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fdzptogpag0aeg14ddju	2026-05-15 18:29:47.894046	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
dd858c95-b1c0-412c-bb34-c1a5ae094349	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869788/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qcfck8qe4dmrd2k9thbr.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/qcfck8qe4dmrd2k9thbr	2026-05-15 18:29:49.587442	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
3d0a9e6f-c259-483e-932a-c3d42adbeb9d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869789/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fwu3xj4hwzlfrooswnrm.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fwu3xj4hwzlfrooswnrm	2026-05-15 18:29:51.078182	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
1fcacce7-2dcf-4409-85a3-d7ec45b508b2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869791/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/im01f8wotwuk78djwjax.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/im01f8wotwuk78djwjax	2026-05-15 18:29:53.086069	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
2dfee73c-5011-43d8-bac7-252efc608691	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869793/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fzktdfgv7vcry7hl74nz.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fzktdfgv7vcry7hl74nz	2026-05-15 18:29:54.598468	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
31f11c35-90d9-40ce-8b0c-2b3dabcce3d3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869795/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/jt16jmmen631vmgzkh8d.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/jt16jmmen631vmgzkh8d	2026-05-15 18:29:56.699009	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f798f1da-e510-4dc9-840a-fca93728e058	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869797/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/zhs8faj0wms8pcpuz9dw.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/zhs8faj0wms8pcpuz9dw	2026-05-15 18:29:58.174557	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
54d98fd0-4cbf-487c-a613-24e5971388be	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869798/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fhuczragwjnfwvrhpu2k.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/fhuczragwjnfwvrhpu2k	2026-05-15 18:29:59.80561	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
06be32bc-782b-43da-8fe9-2da719112564	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869800/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/txia83c9hv7czkajazf2.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/txia83c9hv7czkajazf2	2026-05-15 18:30:01.072162	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
f0552e68-f174-41f0-85b5-a877710b3760	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778869801/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/gbuzcezyaeo3g5xhy6sd.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/gbuzcezyaeo3g5xhy6sd	2026-05-15 18:30:02.39252	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
d082ffa1-b85d-4c44-a5ac-d812fcb50139	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940223/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/z4ok4wtnwoyu1u5cqz1b.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/z4ok4wtnwoyu1u5cqz1b	2026-05-16 14:03:44.46336	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
bd361750-1e90-43c6-a1fd-d38d15474d8d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940224/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tgbpxu96iywmywshbaq6.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tgbpxu96iywmywshbaq6	2026-05-16 14:03:45.997934	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
e4bf260a-e124-48e7-9d0f-dfc01ff9abc7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940226/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pfjth5u3ta7cnhgrzcje.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/pfjth5u3ta7cnhgrzcje	2026-05-16 14:03:47.560454	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
b8dc6867-0019-4458-99da-e50ebde881e3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940227/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ve4qbvadgt7tef9tkpii.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ve4qbvadgt7tef9tkpii	2026-05-16 14:03:49.02575	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
6a5d36a2-2c73-4bb2-8f8b-72865e95fba0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940229/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xhydya1m6bl4zbtji1n4.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/xhydya1m6bl4zbtji1n4	2026-05-16 14:03:50.378942	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
0734309c-cd67-4943-a4d9-cca36c168396	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940230/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ozcrqxjlchqscvejp22m.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ozcrqxjlchqscvejp22m	2026-05-16 14:03:51.939337	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
71588609-9f8b-49d3-bc38-be779f75ed9d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940232/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ouiwxoqpothlsirjnqkk.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ouiwxoqpothlsirjnqkk	2026-05-16 14:03:53.408069	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
22131bc5-3acd-4413-be6c-3b5732e9a54e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940233/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/i5jjhi8xerlsh49hdtfi.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/i5jjhi8xerlsh49hdtfi	2026-05-16 14:03:55.067764	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f3e8194c-b75f-43b9-bff7-a09f1f9b354f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940235/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wmscdh3e3bz5ccocxtrs.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/wmscdh3e3bz5ccocxtrs	2026-05-16 14:03:56.34915	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
632a61ca-cc73-4c4c-ba82-7923d1f699a5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1778940236/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/x3pnslr3asqph7mjndp4.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/x3pnslr3asqph7mjndp4	2026-05-16 14:03:58.059219	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
f5169154-96ea-4844-ada4-185c5f6eb130	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779131700/projects/4813a930-e772-4adf-85d8-0448d373f829/rt6tzpphkd8kuonuhost.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/rt6tzpphkd8kuonuhost	2026-05-18 19:15:01.704028	4813a930-e772-4adf-85d8-0448d373f829
ef33661f-64c1-43c6-b494-0365a9172d1c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779131702/projects/4813a930-e772-4adf-85d8-0448d373f829/ldvc2ryi3zbetj77q36l.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ldvc2ryi3zbetj77q36l	2026-05-18 19:15:03.07764	4813a930-e772-4adf-85d8-0448d373f829
be110152-4faa-45e3-9792-0a2dee4de16e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779131703/projects/4813a930-e772-4adf-85d8-0448d373f829/pqnarzuutoepoytjz0a3.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/pqnarzuutoepoytjz0a3	2026-05-18 19:15:04.227642	4813a930-e772-4adf-85d8-0448d373f829
63381e2b-fc31-4345-ae4b-b674fd6cff62	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779131704/projects/4813a930-e772-4adf-85d8-0448d373f829/w0blsq19qqr9tm6i1mgt.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/w0blsq19qqr9tm6i1mgt	2026-05-18 19:15:05.670436	4813a930-e772-4adf-85d8-0448d373f829
d1945638-bc94-4792-bc4b-4a2dd86ca405	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779131705/projects/4813a930-e772-4adf-85d8-0448d373f829/subi1y1hwtuimsqh21h5.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/subi1y1hwtuimsqh21h5	2026-05-18 19:15:07.065731	4813a930-e772-4adf-85d8-0448d373f829
911d26aa-465c-476c-881c-f67dafc5ba6d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779479554/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/wjzv6edyrjbihiigkcxm.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/wjzv6edyrjbihiigkcxm	2026-05-22 19:52:35.111879	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
9ee3eab1-ef64-4343-bc04-655a0affce41	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779525461/projects/4813a930-e772-4adf-85d8-0448d373f829/ywp8lsgsdcbv8cgmo3qg.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ywp8lsgsdcbv8cgmo3qg	2026-05-23 08:37:42.976153	4813a930-e772-4adf-85d8-0448d373f829
cb5660a4-7191-46c5-bda7-c2113ad97848	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779525463/projects/4813a930-e772-4adf-85d8-0448d373f829/pzkwpudqd0wxf8qpbgij.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/pzkwpudqd0wxf8qpbgij	2026-05-23 08:37:44.500983	4813a930-e772-4adf-85d8-0448d373f829
5155c879-11ee-4ef6-bdb8-3b01a756c760	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779525464/projects/4813a930-e772-4adf-85d8-0448d373f829/bptbxcwxxem8jq7tw2ni.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/bptbxcwxxem8jq7tw2ni	2026-05-23 08:37:45.906755	4813a930-e772-4adf-85d8-0448d373f829
66ea104f-3641-463b-946c-a12f5389cfa0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779525466/projects/4813a930-e772-4adf-85d8-0448d373f829/agkjdjqwewcbwtf6rwf6.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/agkjdjqwewcbwtf6rwf6	2026-05-23 08:37:47.183604	4813a930-e772-4adf-85d8-0448d373f829
09dcb9f3-ebc6-46dc-8ead-09aa2b0e5986	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779525467/projects/4813a930-e772-4adf-85d8-0448d373f829/asbhybrvikh1m7r9uuul.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/asbhybrvikh1m7r9uuul	2026-05-23 08:37:48.647618	4813a930-e772-4adf-85d8-0448d373f829
3b7e6d1f-15de-444f-a95e-c3fd24acb7d5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549510/projects/4813a930-e772-4adf-85d8-0448d373f829/wsa1pkqym5r4relg5atz.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/wsa1pkqym5r4relg5atz	2026-05-23 15:18:31.886635	4813a930-e772-4adf-85d8-0448d373f829
3737815b-ab71-463a-b35b-65fa197730a7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549512/projects/4813a930-e772-4adf-85d8-0448d373f829/fc8wsue4hwz43d7jsccw.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/fc8wsue4hwz43d7jsccw	2026-05-23 15:18:33.231075	4813a930-e772-4adf-85d8-0448d373f829
3968ed4f-53d4-4d6f-9e05-5697dad752ed	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549513/projects/4813a930-e772-4adf-85d8-0448d373f829/udtgjdxavxvmkceacn4u.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/udtgjdxavxvmkceacn4u	2026-05-23 15:18:34.329089	4813a930-e772-4adf-85d8-0448d373f829
661a147c-d30c-42f3-9996-a77d7bbdf740	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549514/projects/4813a930-e772-4adf-85d8-0448d373f829/irz1dledtz0nmf5jrwt3.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/irz1dledtz0nmf5jrwt3	2026-05-23 15:18:35.720189	4813a930-e772-4adf-85d8-0448d373f829
c8e50f7e-ebd7-4ecb-9e45-afc948c0d7d3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549516/projects/4813a930-e772-4adf-85d8-0448d373f829/z6c7c16svzk0gdc7utfx.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/z6c7c16svzk0gdc7utfx	2026-05-23 15:18:37.168048	4813a930-e772-4adf-85d8-0448d373f829
8342ef8d-0ad5-4974-aaa8-c4691593b11b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779549517/projects/4813a930-e772-4adf-85d8-0448d373f829/aq86oz7lkrbklxuobzxn.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/aq86oz7lkrbklxuobzxn	2026-05-23 15:18:38.542342	4813a930-e772-4adf-85d8-0448d373f829
218adc02-8846-49fd-afd5-fbbe4571cd6f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734522/projects/4813a930-e772-4adf-85d8-0448d373f829/t7rx7hy0qqx3lm5klfwt.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/t7rx7hy0qqx3lm5klfwt	2026-05-25 18:42:03.692893	4813a930-e772-4adf-85d8-0448d373f829
55b15c02-ab95-48b4-bebd-128acdbe88af	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734524/projects/4813a930-e772-4adf-85d8-0448d373f829/s7vwcgvpjtrlf83td40y.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/s7vwcgvpjtrlf83td40y	2026-05-25 18:42:04.999667	4813a930-e772-4adf-85d8-0448d373f829
f2a6f76a-946d-4158-a98c-e609feafb897	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734525/projects/4813a930-e772-4adf-85d8-0448d373f829/adzvza6tuz33g7pcfizq.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/adzvza6tuz33g7pcfizq	2026-05-25 18:42:06.650371	4813a930-e772-4adf-85d8-0448d373f829
09efedb7-d58b-4dcf-bd95-833531b17c63	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734527/projects/4813a930-e772-4adf-85d8-0448d373f829/oevdle4b1qp0sut7c0oc.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/oevdle4b1qp0sut7c0oc	2026-05-25 18:42:08.123487	4813a930-e772-4adf-85d8-0448d373f829
88ea5424-8375-4b24-9733-5b38ca24e98a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734528/projects/4813a930-e772-4adf-85d8-0448d373f829/l0spztlwv7lkhxmj20p1.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/l0spztlwv7lkhxmj20p1	2026-05-25 18:42:09.617556	4813a930-e772-4adf-85d8-0448d373f829
900dec1e-b0c6-4644-831e-72b8fbfed72a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779734530/projects/4813a930-e772-4adf-85d8-0448d373f829/s5uljhnromhkeealis7a.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/s5uljhnromhkeealis7a	2026-05-25 18:42:11.644765	4813a930-e772-4adf-85d8-0448d373f829
acc53ed9-6298-4968-b88e-9526b3c1ab73	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779994498/projects/4813a930-e772-4adf-85d8-0448d373f829/onl6tfcyopyl5pr4zles.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/onl6tfcyopyl5pr4zles	2026-05-28 18:54:59.645994	4813a930-e772-4adf-85d8-0448d373f829
c4ebb1a2-03f8-46ee-971e-0aac8615ac3c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779994499/projects/4813a930-e772-4adf-85d8-0448d373f829/ngwx0ikclbcrnyz5yc1s.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ngwx0ikclbcrnyz5yc1s	2026-05-28 18:55:01.068886	4813a930-e772-4adf-85d8-0448d373f829
1c0c4f9f-0d9b-4dd0-8f9c-2a3b29c1514e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779995163/projects/4813a930-e772-4adf-85d8-0448d373f829/pnqmpi5pmdporan18vf2.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/pnqmpi5pmdporan18vf2	2026-05-28 19:06:04.808548	4813a930-e772-4adf-85d8-0448d373f829
1d61fc75-1272-4e5a-beed-a205f10f9064	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779995165/projects/4813a930-e772-4adf-85d8-0448d373f829/v3souuqz1z53nyqbybq2.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/v3souuqz1z53nyqbybq2	2026-05-28 19:06:06.35598	4813a930-e772-4adf-85d8-0448d373f829
b35af30b-5fd0-4840-80c9-ca0dafc95fc0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779995277/projects/4813a930-e772-4adf-85d8-0448d373f829/ndoc7uarbg30qo9yqydi.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ndoc7uarbg30qo9yqydi	2026-05-28 19:07:58.989823	4813a930-e772-4adf-85d8-0448d373f829
3d2c5503-51de-46d2-ab03-57c6dc26378c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1779995279/projects/4813a930-e772-4adf-85d8-0448d373f829/jdze7hxuhx1tb4zyiok7.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/jdze7hxuhx1tb4zyiok7	2026-05-28 19:08:00.54424	4813a930-e772-4adf-85d8-0448d373f829
857bd309-4393-4125-a13f-d73a947ba1ac	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780077158/projects/4813a930-e772-4adf-85d8-0448d373f829/ggailxq7rprxoog8rdab.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ggailxq7rprxoog8rdab	2026-05-29 17:52:39.565753	4813a930-e772-4adf-85d8-0448d373f829
9b696e40-f718-40c4-aafb-c09d0ee9d4f6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780077159/projects/4813a930-e772-4adf-85d8-0448d373f829/zhr5hjul3b6z6zz5uw7m.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/zhr5hjul3b6z6zz5uw7m	2026-05-29 17:52:41.759158	4813a930-e772-4adf-85d8-0448d373f829
d3896ef2-6b9b-4547-9544-bb49dc2723de	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780083522/projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lx7bxlp8zlveokf1375t.jpg	projects/f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79/lx7bxlp8zlveokf1375t	2026-05-29 19:38:45.569741	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79
ec98f154-bab5-48a6-9b78-0d6a444e1bf8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780212239/projects/4813a930-e772-4adf-85d8-0448d373f829/ygijuhixjukt1q8wdvnr.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ygijuhixjukt1q8wdvnr	2026-05-31 07:24:00.748346	4813a930-e772-4adf-85d8-0448d373f829
9b75a444-a624-42c4-96d0-763a5e1ed41b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780212304/projects/4813a930-e772-4adf-85d8-0448d373f829/t21krb0bw3jcxdxzvrfq.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/t21krb0bw3jcxdxzvrfq	2026-05-31 07:25:05.157856	4813a930-e772-4adf-85d8-0448d373f829
34ee9b7f-6673-48db-b945-23c40c433ba1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780324619/projects/4813a930-e772-4adf-85d8-0448d373f829/hlfqyodwvontlmgcxdi3.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/hlfqyodwvontlmgcxdi3	2026-06-01 14:37:00.969477	4813a930-e772-4adf-85d8-0448d373f829
03ab8e32-33e1-4e1b-94c3-f555153f28c3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780324621/projects/4813a930-e772-4adf-85d8-0448d373f829/kdbhvlgeqlqrgqjencl0.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/kdbhvlgeqlqrgqjencl0	2026-06-01 14:37:02.465678	4813a930-e772-4adf-85d8-0448d373f829
e4feb141-152b-47f0-b1d1-55e5642ac639	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780324622/projects/4813a930-e772-4adf-85d8-0448d373f829/t3b5j4vrznetipzmhseo.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/t3b5j4vrznetipzmhseo	2026-06-01 14:37:04.543421	4813a930-e772-4adf-85d8-0448d373f829
afe1841d-9f66-4158-a97f-e2f793526b76	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780324625/projects/4813a930-e772-4adf-85d8-0448d373f829/l8m8tndvnjewfdpksbjf.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/l8m8tndvnjewfdpksbjf	2026-06-01 14:37:06.626242	4813a930-e772-4adf-85d8-0448d373f829
f89dbad2-6988-4c33-aeb0-c97cb5be1baf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780324627/projects/4813a930-e772-4adf-85d8-0448d373f829/fzgqo4jrsj3ab9lef28y.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/fzgqo4jrsj3ab9lef28y	2026-06-01 14:37:08.554609	4813a930-e772-4adf-85d8-0448d373f829
a73a44dc-1187-4628-9e02-069701fa7290	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337387/projects/4813a930-e772-4adf-85d8-0448d373f829/al5snudtieej3bardsmh.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/al5snudtieej3bardsmh	2026-06-01 18:09:49.198552	4813a930-e772-4adf-85d8-0448d373f829
7c991796-2f1f-4752-af87-7f5995b8c498	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337389/projects/4813a930-e772-4adf-85d8-0448d373f829/hp8lmfamxqot6k8xvse2.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/hp8lmfamxqot6k8xvse2	2026-06-01 18:09:50.602027	4813a930-e772-4adf-85d8-0448d373f829
c8b68fac-a4ef-4808-9286-826973860c85	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337390/projects/4813a930-e772-4adf-85d8-0448d373f829/iqcmg13uk2hsxen4az04.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/iqcmg13uk2hsxen4az04	2026-06-01 18:09:52.219147	4813a930-e772-4adf-85d8-0448d373f829
1663fdba-e462-42d3-baec-58b32c3424ca	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337464/projects/4813a930-e772-4adf-85d8-0448d373f829/vnlu5dr2afmzkbm56ouh.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/vnlu5dr2afmzkbm56ouh	2026-06-01 18:11:05.446973	4813a930-e772-4adf-85d8-0448d373f829
7a6ffe65-eb21-493e-ab72-e3d7a4e3c5d6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337465/projects/4813a930-e772-4adf-85d8-0448d373f829/tekaogpxovuwndlwfevb.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/tekaogpxovuwndlwfevb	2026-06-01 18:11:07.172611	4813a930-e772-4adf-85d8-0448d373f829
155fb775-74c2-49d2-9459-cdb334bb6b1c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780337467/projects/4813a930-e772-4adf-85d8-0448d373f829/wdgbhsyuk0psictzvyrm.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/wdgbhsyuk0psictzvyrm	2026-06-01 18:11:08.716201	4813a930-e772-4adf-85d8-0448d373f829
7b7ca68e-f904-447b-ae5e-6b9960b74ee4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780424799/projects/4813a930-e772-4adf-85d8-0448d373f829/fewhraslm2ci1msbp4rw.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/fewhraslm2ci1msbp4rw	2026-06-02 18:26:40.517162	4813a930-e772-4adf-85d8-0448d373f829
dc06f62f-2771-447b-b59e-52327494d7db	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780424800/projects/4813a930-e772-4adf-85d8-0448d373f829/i1q4y0flbz4nk5ig1zcw.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/i1q4y0flbz4nk5ig1zcw	2026-06-02 18:26:41.981278	4813a930-e772-4adf-85d8-0448d373f829
8955a6b2-0a45-4ad8-aab4-33f38774097a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780424802/projects/4813a930-e772-4adf-85d8-0448d373f829/mldymfhdhf8gjjnpi7ls.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/mldymfhdhf8gjjnpi7ls	2026-06-02 18:26:43.595746	4813a930-e772-4adf-85d8-0448d373f829
0146f17a-61ac-478e-84da-384946cb310d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780510719/projects/4813a930-e772-4adf-85d8-0448d373f829/iw61ve4jq6e2pscwpiyo.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/iw61ve4jq6e2pscwpiyo	2026-06-03 18:18:40.457188	4813a930-e772-4adf-85d8-0448d373f829
65c7d36e-8117-4ade-86f1-1af4ec1c1ca3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780510720/projects/4813a930-e772-4adf-85d8-0448d373f829/cqzzryo8psjn3ctqbut7.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/cqzzryo8psjn3ctqbut7	2026-06-03 18:18:42.287246	4813a930-e772-4adf-85d8-0448d373f829
f8cdcbf5-5340-4896-a0a8-637b127b5d26	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780510789/projects/4813a930-e772-4adf-85d8-0448d373f829/q7pulnb3539worki0ht0.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/q7pulnb3539worki0ht0	2026-06-03 18:19:51.890594	4813a930-e772-4adf-85d8-0448d373f829
867071fb-b431-4e6b-9c78-b7ec2fc94ab7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780510792/projects/4813a930-e772-4adf-85d8-0448d373f829/s9qooarv21vxzn2ap5sx.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/s9qooarv21vxzn2ap5sx	2026-06-03 18:19:54.316783	4813a930-e772-4adf-85d8-0448d373f829
e172552e-1dd5-4d36-82c2-e032f3c81e12	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780636497/projects/4813a930-e772-4adf-85d8-0448d373f829/zmwacstdh94o5fhjn7gx.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/zmwacstdh94o5fhjn7gx	2026-06-05 05:14:58.577359	4813a930-e772-4adf-85d8-0448d373f829
08a09b92-e065-45e3-bcdd-9b5989b9aa16	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780636498/projects/4813a930-e772-4adf-85d8-0448d373f829/ys8pb7f7ftqbsnizqzc4.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ys8pb7f7ftqbsnizqzc4	2026-06-05 05:14:59.966356	4813a930-e772-4adf-85d8-0448d373f829
a6c71a59-67c5-41cd-be29-da02d3aa0de8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780636500/projects/4813a930-e772-4adf-85d8-0448d373f829/x3ioevyivxwllshcejnm.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/x3ioevyivxwllshcejnm	2026-06-05 05:15:01.553885	4813a930-e772-4adf-85d8-0448d373f829
914bed40-360f-460a-a3aa-ea3e630f4e78	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780636501/projects/4813a930-e772-4adf-85d8-0448d373f829/dqxmiraoyknd9ijyqgle.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/dqxmiraoyknd9ijyqgle	2026-06-05 05:15:03.100639	4813a930-e772-4adf-85d8-0448d373f829
8e7ac1cb-5082-4765-828e-42bc96aaa023	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780682669/projects/4813a930-e772-4adf-85d8-0448d373f829/tdmppsqooim8mpciwqcy.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/tdmppsqooim8mpciwqcy	2026-06-05 18:04:30.27122	4813a930-e772-4adf-85d8-0448d373f829
c49f7466-e83c-4b58-bf1f-4c2f1a0787f2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780682670/projects/4813a930-e772-4adf-85d8-0448d373f829/pp32ndumxpn7brnilxef.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/pp32ndumxpn7brnilxef	2026-06-05 18:04:31.916457	4813a930-e772-4adf-85d8-0448d373f829
ac3dc03d-6427-41bc-bab6-47fe199ad23f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780682672/projects/4813a930-e772-4adf-85d8-0448d373f829/wdjj6u2ceo81808gdqw0.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/wdjj6u2ceo81808gdqw0	2026-06-05 18:04:33.315183	4813a930-e772-4adf-85d8-0448d373f829
86cf0013-5f1d-47cc-a6e0-047728c01f07	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780682674/projects/4813a930-e772-4adf-85d8-0448d373f829/mqnsnmkpp4qxwgw1tliy.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/mqnsnmkpp4qxwgw1tliy	2026-06-05 18:04:36.096053	4813a930-e772-4adf-85d8-0448d373f829
328c8428-f3da-435a-af3a-085a935fda92	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772038/projects/4813a930-e772-4adf-85d8-0448d373f829/qlsfipn8nv0t67orsthh.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/qlsfipn8nv0t67orsthh	2026-06-06 18:53:59.268655	4813a930-e772-4adf-85d8-0448d373f829
37ced256-d64c-4bc2-8db3-00912d368af2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772039/projects/4813a930-e772-4adf-85d8-0448d373f829/aw4ynajxdyab5olipe40.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/aw4ynajxdyab5olipe40	2026-06-06 18:54:00.701839	4813a930-e772-4adf-85d8-0448d373f829
aa214fce-2e7e-411b-a541-dc595085746e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772041/projects/4813a930-e772-4adf-85d8-0448d373f829/o6axpffkhtdmcpe764ed.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/o6axpffkhtdmcpe764ed	2026-06-06 18:54:02.47845	4813a930-e772-4adf-85d8-0448d373f829
eda4b745-ed18-452b-8e27-1396dced68a2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772043/projects/4813a930-e772-4adf-85d8-0448d373f829/siwoygs3ruwwlryoluuh.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/siwoygs3ruwwlryoluuh	2026-06-06 18:54:04.893235	4813a930-e772-4adf-85d8-0448d373f829
5504bb05-25b2-4aa7-b084-bd3d6504c1f3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772046/projects/4813a930-e772-4adf-85d8-0448d373f829/kq5zxq7mm8gm6dac1vdg.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/kq5zxq7mm8gm6dac1vdg	2026-06-06 18:54:07.638718	4813a930-e772-4adf-85d8-0448d373f829
18e9ce3c-961e-4bb6-b7e7-9ece18245916	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772048/projects/4813a930-e772-4adf-85d8-0448d373f829/cbcab5nszxsbjitmq5iz.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/cbcab5nszxsbjitmq5iz	2026-06-06 18:54:09.949766	4813a930-e772-4adf-85d8-0448d373f829
bda32367-54a8-4a8b-af2a-0864fb72ae31	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780772050/projects/4813a930-e772-4adf-85d8-0448d373f829/imvhkgagsbkv7ubpyhwp.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/imvhkgagsbkv7ubpyhwp	2026-06-06 18:54:12.076538	4813a930-e772-4adf-85d8-0448d373f829
9858d1e7-aa4f-4025-94fe-1bfa0fc76ec7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780944033/projects/6cfb6350-300e-4727-82c2-96cd431e9425/f3yu8pmjo033benpog7i.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/f3yu8pmjo033benpog7i	2026-06-08 18:40:34.930453	6cfb6350-300e-4727-82c2-96cd431e9425
813db7ff-24f6-486a-9cd1-2f55f5700169	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780944035/projects/6cfb6350-300e-4727-82c2-96cd431e9425/ggxyxdd3hrbndlkrhgmf.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/ggxyxdd3hrbndlkrhgmf	2026-06-08 18:40:37.247693	6cfb6350-300e-4727-82c2-96cd431e9425
87f1f134-7fbe-4967-b393-086fcfb5c407	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780944037/projects/6cfb6350-300e-4727-82c2-96cd431e9425/eyhl99q72adqyukhu0zr.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/eyhl99q72adqyukhu0zr	2026-06-08 18:40:39.155035	6cfb6350-300e-4727-82c2-96cd431e9425
1e61831a-a85a-45a9-8363-d4d2914fc83d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1780944039/projects/6cfb6350-300e-4727-82c2-96cd431e9425/julrcsbwxvwoklwn5ecg.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/julrcsbwxvwoklwn5ecg	2026-06-08 18:40:40.790374	6cfb6350-300e-4727-82c2-96cd431e9425
2ab0c607-254f-4caa-a1e1-ab2d9d9749f4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781117708/projects/4813a930-e772-4adf-85d8-0448d373f829/ahk1dibzuvkh2tpb55mz.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/ahk1dibzuvkh2tpb55mz	2026-06-10 18:55:09.74824	4813a930-e772-4adf-85d8-0448d373f829
f0d7ab9f-4b1a-4eb2-bf8b-052576c7a56f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781196116/projects/4813a930-e772-4adf-85d8-0448d373f829/kn4ha1qoca2whnnn2grp.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/kn4ha1qoca2whnnn2grp	2026-06-11 16:41:57.696784	4813a930-e772-4adf-85d8-0448d373f829
21a7daed-15b0-4f55-a5a9-75673d22bf04	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781196118/projects/4813a930-e772-4adf-85d8-0448d373f829/b4a6egc7ixfk75p9mmj3.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/b4a6egc7ixfk75p9mmj3	2026-06-11 16:41:59.570929	4813a930-e772-4adf-85d8-0448d373f829
6e0f960c-765b-4413-85af-4510b244549e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781196119/projects/4813a930-e772-4adf-85d8-0448d373f829/eq4e8dhdlzu4dnuj77nx.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/eq4e8dhdlzu4dnuj77nx	2026-06-11 16:42:00.936635	4813a930-e772-4adf-85d8-0448d373f829
4cd45afa-72af-44c4-b08f-c32536d1c012	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781196121/projects/4813a930-e772-4adf-85d8-0448d373f829/mcvebalfs9mmwefvgyz4.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/mcvebalfs9mmwefvgyz4	2026-06-11 16:42:02.580768	4813a930-e772-4adf-85d8-0448d373f829
5577a853-8a24-4796-95b6-0b07cb8ce9f3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781298451/projects/6cfb6350-300e-4727-82c2-96cd431e9425/qi0cnfcg3jbpvul9jfxq.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/qi0cnfcg3jbpvul9jfxq	2026-06-12 21:07:32.341973	6cfb6350-300e-4727-82c2-96cd431e9425
6d3e4ad4-e370-40b3-9a28-a8359a1d1715	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781298452/projects/6cfb6350-300e-4727-82c2-96cd431e9425/pjjm5x8orjmgyj1onevx.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/pjjm5x8orjmgyj1onevx	2026-06-12 21:07:34.199063	6cfb6350-300e-4727-82c2-96cd431e9425
d0e683e0-4ca8-4fcf-bd4b-0969c15bfcbc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781298454/projects/6cfb6350-300e-4727-82c2-96cd431e9425/sfhy5vxfvddu0jqyxibz.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/sfhy5vxfvddu0jqyxibz	2026-06-12 21:07:36.009264	6cfb6350-300e-4727-82c2-96cd431e9425
2093913d-d699-41b3-af6e-655b51302924	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781298456/projects/6cfb6350-300e-4727-82c2-96cd431e9425/aysuhu3lq8nzf6bwhutz.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/aysuhu3lq8nzf6bwhutz	2026-06-12 21:07:37.381446	6cfb6350-300e-4727-82c2-96cd431e9425
bad0e545-6e5b-4acb-bc8d-6f69ceb7c6da	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363161/projects/6cfb6350-300e-4727-82c2-96cd431e9425/xqdz4uvlhzdlbmctqfj8.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/xqdz4uvlhzdlbmctqfj8	2026-06-13 15:06:02.860523	6cfb6350-300e-4727-82c2-96cd431e9425
f4a71440-c505-4794-a8cc-af376b755804	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363163/projects/6cfb6350-300e-4727-82c2-96cd431e9425/samcuebpto32orvqsiy3.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/samcuebpto32orvqsiy3	2026-06-13 15:06:04.360073	6cfb6350-300e-4727-82c2-96cd431e9425
acb6d5b1-7aa8-477b-980d-3f8761a7285b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363164/projects/6cfb6350-300e-4727-82c2-96cd431e9425/hrjhh9y7ximxuyjivwca.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/hrjhh9y7ximxuyjivwca	2026-06-13 15:06:05.720576	6cfb6350-300e-4727-82c2-96cd431e9425
ee9caabf-1c0a-4c0c-9571-07c6e175a683	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363166/projects/6cfb6350-300e-4727-82c2-96cd431e9425/uadgfypyk0pnmqqv7wh9.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/uadgfypyk0pnmqqv7wh9	2026-06-13 15:06:07.282416	6cfb6350-300e-4727-82c2-96cd431e9425
0e8e261e-1900-42d5-91bd-0d7911fe973e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363280/projects/6cfb6350-300e-4727-82c2-96cd431e9425/fijd6jlreqrly76r5ydc.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/fijd6jlreqrly76r5ydc	2026-06-13 15:08:01.957603	6cfb6350-300e-4727-82c2-96cd431e9425
e38ec1ae-0955-4620-b1a4-09ac1a3f7e54	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363282/projects/6cfb6350-300e-4727-82c2-96cd431e9425/we2m7t2ocwhuo3x4fhml.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/we2m7t2ocwhuo3x4fhml	2026-06-13 15:08:03.411518	6cfb6350-300e-4727-82c2-96cd431e9425
a039dbbe-aeed-4c2d-b509-9526a26ac91e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363283/projects/6cfb6350-300e-4727-82c2-96cd431e9425/zkbo4idirticxkpvvjs8.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/zkbo4idirticxkpvvjs8	2026-06-13 15:08:04.869166	6cfb6350-300e-4727-82c2-96cd431e9425
f797ea52-1bcb-4dac-8e35-e7a6ddb02ede	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781363285/projects/6cfb6350-300e-4727-82c2-96cd431e9425/hifj7csbw8mbdhoutpbl.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/hifj7csbw8mbdhoutpbl	2026-06-13 15:08:06.538133	6cfb6350-300e-4727-82c2-96cd431e9425
11399f7c-2185-416e-95ee-a8897f7e3de3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781545861/projects/6cfb6350-300e-4727-82c2-96cd431e9425/vy6kajh6n3udnsm4mydw.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/vy6kajh6n3udnsm4mydw	2026-06-15 17:51:02.512235	6cfb6350-300e-4727-82c2-96cd431e9425
7b097c66-8c91-49b0-a2aa-209d5567ad5d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781545862/projects/6cfb6350-300e-4727-82c2-96cd431e9425/kcewkvwpsueziu9sg8kq.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/kcewkvwpsueziu9sg8kq	2026-06-15 17:51:03.995548	6cfb6350-300e-4727-82c2-96cd431e9425
20a5efd9-e6e3-4129-9538-bf2b3fe36c68	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781558940/projects/6cfb6350-300e-4727-82c2-96cd431e9425/uxy061ijee2z5okwt98i.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/uxy061ijee2z5okwt98i	2026-06-15 21:29:02.204277	6cfb6350-300e-4727-82c2-96cd431e9425
6e24e244-7937-4cfb-8aa8-e4cf12432b5d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781558942/projects/6cfb6350-300e-4727-82c2-96cd431e9425/oabvhyunxhgso0tga1qd.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/oabvhyunxhgso0tga1qd	2026-06-15 21:29:03.980219	6cfb6350-300e-4727-82c2-96cd431e9425
455a88b6-a728-4ec9-8d73-f3604e12c517	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781558944/projects/6cfb6350-300e-4727-82c2-96cd431e9425/y1koeqzeeyjv7jxkikaj.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/y1koeqzeeyjv7jxkikaj	2026-06-15 21:29:05.563963	6cfb6350-300e-4727-82c2-96cd431e9425
255f8524-0088-4f1d-a957-e6f1f2d82fd6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781558945/projects/6cfb6350-300e-4727-82c2-96cd431e9425/u8uhixcuipumbcabozwr.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/u8uhixcuipumbcabozwr	2026-06-15 21:29:07.328588	6cfb6350-300e-4727-82c2-96cd431e9425
20a68820-ff09-4e8b-9030-7c9a4cbeff30	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781559095/projects/6cfb6350-300e-4727-82c2-96cd431e9425/n9p2hkqrrqke7m1kek6n.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/n9p2hkqrrqke7m1kek6n	2026-06-15 21:31:36.571534	6cfb6350-300e-4727-82c2-96cd431e9425
ee298d9a-c69f-4716-9cfe-4385f01cd589	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781559096/projects/6cfb6350-300e-4727-82c2-96cd431e9425/azwtvevtnky9o3162hgo.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/azwtvevtnky9o3162hgo	2026-06-15 21:31:38.054072	6cfb6350-300e-4727-82c2-96cd431e9425
0cd991f0-4035-4346-a7a5-45314f221a5c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781559098/projects/6cfb6350-300e-4727-82c2-96cd431e9425/fgnkqxnu0e6wiu7g74yh.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/fgnkqxnu0e6wiu7g74yh	2026-06-15 21:31:39.677842	6cfb6350-300e-4727-82c2-96cd431e9425
e2b2e915-2d29-4eb3-8558-811b4cd2fdaa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781559100/projects/6cfb6350-300e-4727-82c2-96cd431e9425/dkgzdh7ox8w0jvm6d08a.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/dkgzdh7ox8w0jvm6d08a	2026-06-15 21:31:41.021759	6cfb6350-300e-4727-82c2-96cd431e9425
75c5e50f-0e95-417c-b9cd-409d2cd05074	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781559101/projects/6cfb6350-300e-4727-82c2-96cd431e9425/b1tfxrekbbs8d9akixrg.jpg	projects/6cfb6350-300e-4727-82c2-96cd431e9425/b1tfxrekbbs8d9akixrg	2026-06-15 21:31:42.377355	6cfb6350-300e-4727-82c2-96cd431e9425
f69327d8-ecc3-447e-866a-2c9508daf5d0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781798531/projects/d949002a-7479-4680-b874-f55ea62f594f/k9zf6qhrnlwzm41fylcn.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/k9zf6qhrnlwzm41fylcn	2026-06-18 16:02:12.591265	d949002a-7479-4680-b874-f55ea62f594f
e0a553af-392a-4fa6-b101-ec2ecb8046b6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781798533/projects/d949002a-7479-4680-b874-f55ea62f594f/ml29l3pamp2cxfgmmlhu.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/ml29l3pamp2cxfgmmlhu	2026-06-18 16:02:14.721649	d949002a-7479-4680-b874-f55ea62f594f
e7e46722-295b-41bb-8c7e-0998e4cb49b8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781799926/projects/d949002a-7479-4680-b874-f55ea62f594f/hbgjd61bhlcsd3i2qlrx.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/hbgjd61bhlcsd3i2qlrx	2026-06-18 16:25:27.571656	d949002a-7479-4680-b874-f55ea62f594f
152cf7e6-60e2-4d63-9162-2b874014f465	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781799927/projects/d949002a-7479-4680-b874-f55ea62f594f/itm0rjpfdu7wziqjytsk.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/itm0rjpfdu7wziqjytsk	2026-06-18 16:25:29.172163	d949002a-7479-4680-b874-f55ea62f594f
9bde588e-4c02-411b-9ae6-0107db3bba64	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887723/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vwibrp09hionq9zxeheu.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vwibrp09hionq9zxeheu	2026-06-19 16:48:45.066024	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
d678655f-4368-4bbe-b859-8e1e4381e331	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887725/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tvlahcayswtqm2d1akvo.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/tvlahcayswtqm2d1akvo	2026-06-19 16:48:46.527437	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
5125d59f-810b-4aa7-950e-326cf46ac65b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887726/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/drcvbw8zd4lctwxufjyg.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/drcvbw8zd4lctwxufjyg	2026-06-19 16:48:47.892002	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
fb5c879d-47af-4d82-abbc-03931181f72c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887728/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yfd3t2vt22bn0iaxspnf.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/yfd3t2vt22bn0iaxspnf	2026-06-19 16:48:49.264239	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
255828b1-33b5-4263-b88e-ecc521d2b62a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887729/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ivwcnhwtvrcw7qujufta.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/ivwcnhwtvrcw7qujufta	2026-06-19 16:48:50.981774	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
8e5b08f0-80be-4b07-8fc1-671ab980c5e9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887891/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/or9snbzoqgeuvdhzsjvj.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/or9snbzoqgeuvdhzsjvj	2026-06-19 16:51:32.205523	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
95b42ebb-8761-4ded-b962-8aec411c6d26	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887892/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vzry2h58zyyc08ovg8wd.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/vzry2h58zyyc08ovg8wd	2026-06-19 16:51:33.682195	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
93c209eb-b7b5-4ed6-b8e8-1b5d90ff9a70	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887893/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qf1d4cdbwkvahrxs90pk.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/qf1d4cdbwkvahrxs90pk	2026-06-19 16:51:35.108456	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
9b7bb262-bd74-4d12-8045-ee7215f624aa	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781887895/projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bwsg4fs2nzy6cwppvxtl.jpg	projects/284d06c0-f938-40ae-8ef1-aa1d3e354eb9/bwsg4fs2nzy6cwppvxtl	2026-06-19 16:51:36.505427	284d06c0-f938-40ae-8ef1-aa1d3e354eb9
df989147-d398-493b-bfa5-618f11c04273	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973174/projects/d949002a-7479-4680-b874-f55ea62f594f/nm7d8pxjgpfhyhztvfyc.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/nm7d8pxjgpfhyhztvfyc	2026-06-20 16:32:55.545932	d949002a-7479-4680-b874-f55ea62f594f
216b3564-8ba4-4dd7-8851-144ee5e05c92	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973175/projects/d949002a-7479-4680-b874-f55ea62f594f/sbkgqg7pc6dofwbwynrp.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/sbkgqg7pc6dofwbwynrp	2026-06-20 16:32:57.264973	d949002a-7479-4680-b874-f55ea62f594f
cfb7bca9-cb0a-424c-a495-4c48317b3075	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973177/projects/d949002a-7479-4680-b874-f55ea62f594f/ziwdl3dwsjctpx3cqosq.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/ziwdl3dwsjctpx3cqosq	2026-06-20 16:32:59.053452	d949002a-7479-4680-b874-f55ea62f594f
ece37fba-3d27-4773-a7e7-68c306ffc231	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973179/projects/d949002a-7479-4680-b874-f55ea62f594f/c8mpzpbwcpfgq0lj9jz4.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/c8mpzpbwcpfgq0lj9jz4	2026-06-20 16:33:00.697475	d949002a-7479-4680-b874-f55ea62f594f
10535f27-0987-4573-b745-51d6f0b18b6e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973181/projects/d949002a-7479-4680-b874-f55ea62f594f/nch19mkpsluh4o6n8nrx.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/nch19mkpsluh4o6n8nrx	2026-06-20 16:33:02.018299	d949002a-7479-4680-b874-f55ea62f594f
adb0cc68-2fbe-419e-8645-ce56244b2228	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1781973182/projects/d949002a-7479-4680-b874-f55ea62f594f/upoclp2hzcbhrdofir29.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/upoclp2hzcbhrdofir29	2026-06-20 16:33:03.46683	d949002a-7479-4680-b874-f55ea62f594f
eaccac83-4369-4da1-a526-48e980002702	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782147471/projects/d949002a-7479-4680-b874-f55ea62f594f/iis1cwublynuryxtdpbd.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/iis1cwublynuryxtdpbd	2026-06-22 16:57:53.013	d949002a-7479-4680-b874-f55ea62f594f
cfe35df2-9818-45f1-b1b2-a775982e4b3d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782147473/projects/d949002a-7479-4680-b874-f55ea62f594f/yduk0ubfeufeekq1zrdc.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/yduk0ubfeufeekq1zrdc	2026-06-22 16:57:54.627182	d949002a-7479-4680-b874-f55ea62f594f
96c910cd-3fab-40a8-ad3c-d48ff54f8402	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782147475/projects/d949002a-7479-4680-b874-f55ea62f594f/fwaavr4i2wkcxoirg7jn.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/fwaavr4i2wkcxoirg7jn	2026-06-22 16:57:56.881072	d949002a-7479-4680-b874-f55ea62f594f
07417168-28f5-461b-be8d-700c425d1d06	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321284/projects/d949002a-7479-4680-b874-f55ea62f594f/jhjuz6zs8slcq8odpivk.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/jhjuz6zs8slcq8odpivk	2026-06-24 17:14:46.124005	d949002a-7479-4680-b874-f55ea62f594f
1e86a103-2e93-4709-a038-efa4ed6ec649	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321286/projects/d949002a-7479-4680-b874-f55ea62f594f/kkaebrz8gvxkoevusmuz.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/kkaebrz8gvxkoevusmuz	2026-06-24 17:14:48.267758	d949002a-7479-4680-b874-f55ea62f594f
43fcec8c-d3bb-4423-899f-b944f58cf9ff	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321288/projects/d949002a-7479-4680-b874-f55ea62f594f/pniv67zkaxqlxbb7qr40.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/pniv67zkaxqlxbb7qr40	2026-06-24 17:14:49.934709	d949002a-7479-4680-b874-f55ea62f594f
eccf8414-4aff-49c5-bf5d-fa2539da35e7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321454/projects/d949002a-7479-4680-b874-f55ea62f594f/yszxv7eoepygioncd3qh.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/yszxv7eoepygioncd3qh	2026-06-24 17:17:35.377671	d949002a-7479-4680-b874-f55ea62f594f
af27716a-5920-436e-969f-52836e4a7a3a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321455/projects/d949002a-7479-4680-b874-f55ea62f594f/dylwslcrgous82gahcyj.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/dylwslcrgous82gahcyj	2026-06-24 17:17:36.957589	d949002a-7479-4680-b874-f55ea62f594f
8a996675-8d23-46be-a332-8eb82e4e475b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782321457/projects/d949002a-7479-4680-b874-f55ea62f594f/e4ydhbki7evngl2np0ka.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/e4ydhbki7evngl2np0ka	2026-06-24 17:17:38.653172	d949002a-7479-4680-b874-f55ea62f594f
92faa6f3-a7c3-452c-8559-ff5a0a8dccae	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393872/projects/d949002a-7479-4680-b874-f55ea62f594f/cqtsszk25ydui2wguzr7.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/cqtsszk25ydui2wguzr7	2026-06-25 13:24:33.894614	d949002a-7479-4680-b874-f55ea62f594f
99a83b76-583e-4985-88ff-a9d976d25738	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393874/projects/d949002a-7479-4680-b874-f55ea62f594f/nthmoxwxsz8tzylv16g3.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/nthmoxwxsz8tzylv16g3	2026-06-25 13:24:35.613139	d949002a-7479-4680-b874-f55ea62f594f
4ab11951-6cf7-4ba8-b656-75c45aa3a6bb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393913/projects/d949002a-7479-4680-b874-f55ea62f594f/zxf2ajkmriref9joq10y.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/zxf2ajkmriref9joq10y	2026-06-25 13:25:15.808113	d949002a-7479-4680-b874-f55ea62f594f
2681a555-767b-490a-9e15-3f5a6baf4f79	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393916/projects/d949002a-7479-4680-b874-f55ea62f594f/bv0mnqyvtv4bmwhtcxob.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/bv0mnqyvtv4bmwhtcxob	2026-06-25 13:25:17.325815	d949002a-7479-4680-b874-f55ea62f594f
51dfdb9b-a520-4438-81ea-435cb4a4478c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393918/projects/d949002a-7479-4680-b874-f55ea62f594f/w9htt6q6axavrgvjjxav.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/w9htt6q6axavrgvjjxav	2026-06-25 13:25:19.580192	d949002a-7479-4680-b874-f55ea62f594f
552e67ff-c42a-4de1-ac87-f3ebeff425a9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782393919/projects/d949002a-7479-4680-b874-f55ea62f594f/c87tz7xnb7ydwkxrcljk.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/c87tz7xnb7ydwkxrcljk	2026-06-25 13:25:21.21673	d949002a-7479-4680-b874-f55ea62f594f
e66746a8-4b13-4254-b5b1-297da5d0538d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782471452/projects/d949002a-7479-4680-b874-f55ea62f594f/mnwq7oc9n6ephhts4d6l.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/mnwq7oc9n6ephhts4d6l	2026-06-26 10:57:33.457736	d949002a-7479-4680-b874-f55ea62f594f
8c90b49d-9739-46e4-a964-6ab8a5e6271a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782471453/projects/d949002a-7479-4680-b874-f55ea62f594f/tgd3jlf6bda5murodmjo.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/tgd3jlf6bda5murodmjo	2026-06-26 10:57:34.87809	d949002a-7479-4680-b874-f55ea62f594f
b5227a2c-c570-4180-82ea-b5abb196f187	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782750362/projects/d949002a-7479-4680-b874-f55ea62f594f/e3anlszifocm5glkjobt.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/e3anlszifocm5glkjobt	2026-06-29 16:26:04.227904	d949002a-7479-4680-b874-f55ea62f594f
0fed2ca0-98de-4aaf-9b58-49d8e27e0e50	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782750364/projects/d949002a-7479-4680-b874-f55ea62f594f/gys9zmbc5dmuof5aulus.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/gys9zmbc5dmuof5aulus	2026-06-29 16:26:06.126334	d949002a-7479-4680-b874-f55ea62f594f
50df4e0d-a32e-4d57-9319-716dbc85bb6b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782799727/projects/d949002a-7479-4680-b874-f55ea62f594f/t7i4hdkguhwlqeebqks6.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/t7i4hdkguhwlqeebqks6	2026-06-30 06:08:48.38821	d949002a-7479-4680-b874-f55ea62f594f
a490c371-ddda-46b4-bacc-877a8fd41b8a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782799728/projects/d949002a-7479-4680-b874-f55ea62f594f/wlpzhiabakgbtcvc6bu5.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/wlpzhiabakgbtcvc6bu5	2026-06-30 06:08:49.672725	d949002a-7479-4680-b874-f55ea62f594f
e9345f63-53f9-453d-970c-a3ce7e226daf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782804662/projects/d949002a-7479-4680-b874-f55ea62f594f/ps75esisxzenw68gkkaf.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/ps75esisxzenw68gkkaf	2026-06-30 07:31:03.760843	d949002a-7479-4680-b874-f55ea62f594f
cc1d081d-2c67-4801-8ce4-f74229a8aa4b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782821546/projects/d949002a-7479-4680-b874-f55ea62f594f/pc4cfp7g7aozu8fdneve.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/pc4cfp7g7aozu8fdneve	2026-06-30 12:12:28.114665	d949002a-7479-4680-b874-f55ea62f594f
b2b329e5-6614-4267-9c3f-f08df67261ab	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782821645/projects/d949002a-7479-4680-b874-f55ea62f594f/uut3uinc1ofbciqi84zc.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/uut3uinc1ofbciqi84zc	2026-06-30 12:14:06.412102	d949002a-7479-4680-b874-f55ea62f594f
b05b1fbe-83b3-4d8e-8f6e-2b7693057ff8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782826756/projects/d949002a-7479-4680-b874-f55ea62f594f/tu5ytl6hq4npsqcjzaxe.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/tu5ytl6hq4npsqcjzaxe	2026-06-30 13:39:18.606166	d949002a-7479-4680-b874-f55ea62f594f
3b9fcf4e-61ff-4c9a-b8a9-f99fb093fab1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782826759/projects/d949002a-7479-4680-b874-f55ea62f594f/kj9zoduig6col9q0eqnh.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/kj9zoduig6col9q0eqnh	2026-06-30 13:39:20.626687	d949002a-7479-4680-b874-f55ea62f594f
0aca4096-4117-4c30-82df-d203e2fc0119	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782826761/projects/d949002a-7479-4680-b874-f55ea62f594f/iyqjwfxj7qpzvj5kejha.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/iyqjwfxj7qpzvj5kejha	2026-06-30 13:39:22.464767	d949002a-7479-4680-b874-f55ea62f594f
ef958fc8-3d5b-495d-b6d9-d2686836b2de	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782827981/projects/d949002a-7479-4680-b874-f55ea62f594f/jcyf2oeloxq6knofjavz.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/jcyf2oeloxq6knofjavz	2026-06-30 13:59:42.905257	d949002a-7479-4680-b874-f55ea62f594f
7386f75d-9d7a-4912-b29c-8b5ac35c6a0e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782827983/projects/d949002a-7479-4680-b874-f55ea62f594f/bxvdrtese1rfdnpadm2q.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/bxvdrtese1rfdnpadm2q	2026-06-30 13:59:44.899522	d949002a-7479-4680-b874-f55ea62f594f
6674a958-59f7-4aa9-8108-5d04bdefdf1c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1782827985/projects/d949002a-7479-4680-b874-f55ea62f594f/twuqck4f85juqcwugrs8.jpg	projects/d949002a-7479-4680-b874-f55ea62f594f/twuqck4f85juqcwugrs8	2026-06-30 13:59:46.407563	d949002a-7479-4680-b874-f55ea62f594f
32574c80-0e4f-465d-8383-a421d24dbcb6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783013688/projects/1238abd9-6257-47ca-bfff-fba910c6c953/slbzvkftxizzxh15ttbl.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/slbzvkftxizzxh15ttbl	2026-07-02 17:34:50.062286	1238abd9-6257-47ca-bfff-fba910c6c953
e0a2f135-655d-4d43-8414-8d68765de531	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783013690/projects/1238abd9-6257-47ca-bfff-fba910c6c953/sh7tvaf5qlyyibfimjgf.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/sh7tvaf5qlyyibfimjgf	2026-07-02 17:34:51.497758	1238abd9-6257-47ca-bfff-fba910c6c953
87729eb6-1ea2-4903-a1bc-087bc84311e2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783013691/projects/1238abd9-6257-47ca-bfff-fba910c6c953/kjli51dhkyamsutfuadx.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/kjli51dhkyamsutfuadx	2026-07-02 17:34:52.876177	1238abd9-6257-47ca-bfff-fba910c6c953
10015e1a-4fe0-488c-ba54-8d20893a26d3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783013693/projects/1238abd9-6257-47ca-bfff-fba910c6c953/sa1ybezsfykhcb8rmimy.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/sa1ybezsfykhcb8rmimy	2026-07-02 17:34:54.376821	1238abd9-6257-47ca-bfff-fba910c6c953
6808047f-4e2a-46ed-9371-f2b94a2224e5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783310943/projects/1238abd9-6257-47ca-bfff-fba910c6c953/utojnikfirbckewbrdf6.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/utojnikfirbckewbrdf6	2026-07-06 04:09:04.645756	1238abd9-6257-47ca-bfff-fba910c6c953
0a0ed98e-afd6-4386-bf20-f1c22c472d5b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783341645/projects/1238abd9-6257-47ca-bfff-fba910c6c953/jneyb6ult3tpny6pugxj.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/jneyb6ult3tpny6pugxj	2026-07-06 12:40:47.108234	1238abd9-6257-47ca-bfff-fba910c6c953
712b9589-6947-4896-94b7-2d3e92d2f077	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783522181/projects/1238abd9-6257-47ca-bfff-fba910c6c953/quve6yzx1mpsysg62tkk.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/quve6yzx1mpsysg62tkk	2026-07-08 14:49:42.466838	1238abd9-6257-47ca-bfff-fba910c6c953
39ceffeb-8f13-428e-a470-b1bfbb0e23be	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783522182/projects/1238abd9-6257-47ca-bfff-fba910c6c953/f7sfonte3nzrs18cdvtv.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/f7sfonte3nzrs18cdvtv	2026-07-08 14:49:44.116991	1238abd9-6257-47ca-bfff-fba910c6c953
03e073b5-d3f5-4174-b903-d5f3c1e5af8a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783606497/projects/1238abd9-6257-47ca-bfff-fba910c6c953/dkgyyw0bmbo9zu4hralz.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/dkgyyw0bmbo9zu4hralz	2026-07-09 14:14:58.971809	1238abd9-6257-47ca-bfff-fba910c6c953
8ba04452-2519-4241-8d90-814cdb677ab1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783606499/projects/1238abd9-6257-47ca-bfff-fba910c6c953/rls0go0llyewchr1jnur.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/rls0go0llyewchr1jnur	2026-07-09 14:15:00.805707	1238abd9-6257-47ca-bfff-fba910c6c953
e85a28e1-d39c-40c8-9f2f-f267cc8af00a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783883339/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/glle5kejsvdai1ontoww.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/glle5kejsvdai1ontoww	2026-07-12 19:09:01.2023	5c5918d7-0a51-4733-932b-55b35ea538d3
32f2ad53-0f78-4cea-8c57-f74608d87d47	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783883339/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/qghbkrcyxwewqh55plpn.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/qghbkrcyxwewqh55plpn	2026-07-12 19:09:02.163533	5c5918d7-0a51-4733-932b-55b35ea538d3
5c1311d6-8e35-4803-92f3-76984ab8bcc7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783886238/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/tpyfczxo9swmwglwjhur.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/tpyfczxo9swmwglwjhur	2026-07-12 19:57:19.044082	5c5918d7-0a51-4733-932b-55b35ea538d3
d0c0e181-814b-4f0d-abd7-9823e939f7a0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783886238/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/wsmfr08kgpl6kbon33vs.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/wsmfr08kgpl6kbon33vs	2026-07-12 19:57:19.825372	5c5918d7-0a51-4733-932b-55b35ea538d3
08e79f1d-2329-438c-b34f-bc7d9138e3d1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1783959938/projects/1238abd9-6257-47ca-bfff-fba910c6c953/gz5xg77twiov5dlgl33h.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/gz5xg77twiov5dlgl33h	2026-07-13 16:25:39.229836	1238abd9-6257-47ca-bfff-fba910c6c953
1e7d86c8-244b-446b-8399-7da90ae8a9ec	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784050041/projects/cef60249-2727-476e-bd94-4d3e9dd03916/kwsjljbf5mveurcabtoh.jpg	projects/cef60249-2727-476e-bd94-4d3e9dd03916/kwsjljbf5mveurcabtoh	2026-07-14 17:27:22.472122	cef60249-2727-476e-bd94-4d3e9dd03916
59d0b518-edcb-4d92-bd8a-6db5f4273a88	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784096899/projects/1238abd9-6257-47ca-bfff-fba910c6c953/ekvkgjyrksdvf8dhs8er.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/ekvkgjyrksdvf8dhs8er	2026-07-15 06:28:20.950673	1238abd9-6257-47ca-bfff-fba910c6c953
359fd714-4392-4e0d-b13c-f88529ab305b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784096899/projects/1238abd9-6257-47ca-bfff-fba910c6c953/ubho5vdhcfqsdaa0wtka.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/ubho5vdhcfqsdaa0wtka	2026-07-15 06:28:21.106024	1238abd9-6257-47ca-bfff-fba910c6c953
4fb8cd90-eb08-4064-a0bc-3d3d89355e9d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784096900/projects/1238abd9-6257-47ca-bfff-fba910c6c953/bxskn2fjb63hxpezjhkt.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/bxskn2fjb63hxpezjhkt	2026-07-15 06:28:21.129552	1238abd9-6257-47ca-bfff-fba910c6c953
c31e0dfc-241f-4a21-b959-c468e92d6864	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784569086/projects/1238abd9-6257-47ca-bfff-fba910c6c953/jfeexmhvnelwjambre5t.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/jfeexmhvnelwjambre5t	2026-07-20 17:38:07.305487	1238abd9-6257-47ca-bfff-fba910c6c953
044e5a0f-7d3f-48d4-be39-c27bab7ebb96	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784569086/projects/1238abd9-6257-47ca-bfff-fba910c6c953/fbqgo4fgjmkbnqizdb2i.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/fbqgo4fgjmkbnqizdb2i	2026-07-20 17:38:07.415432	1238abd9-6257-47ca-bfff-fba910c6c953
e4edf558-87d9-47d3-a5dd-629b0122de24	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784569086/projects/1238abd9-6257-47ca-bfff-fba910c6c953/oebaeeldcxusvarqj7mc.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/oebaeeldcxusvarqj7mc	2026-07-20 17:38:07.610757	1238abd9-6257-47ca-bfff-fba910c6c953
c36c8fe5-3212-4a03-81ab-d6ec803ca926	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784569087/projects/1238abd9-6257-47ca-bfff-fba910c6c953/klgltaufru2xi1fn9uvu.jpg	projects/1238abd9-6257-47ca-bfff-fba910c6c953/klgltaufru2xi1fn9uvu	2026-07-20 17:38:08.668311	1238abd9-6257-47ca-bfff-fba910c6c953
f5bfb49b-5f0b-4e13-b20d-64e7d77784f3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784621862/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/lhkpdfwyg1ehinoqv28n.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/lhkpdfwyg1ehinoqv28n	2026-07-21 08:17:43.435094	bbffade8-2151-4c8d-bb24-df1b0d515203
7470b610-e304-4e52-aa42-63265b4b481c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784621862/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/cdxxwuiroxllsh5cfezn.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/cdxxwuiroxllsh5cfezn	2026-07-21 08:17:43.7214	bbffade8-2151-4c8d-bb24-df1b0d515203
bfac45d9-d3fa-47dc-8a12-8f640e7436d9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784647232/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/yvesxnu682kodmeuv6ac.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/yvesxnu682kodmeuv6ac	2026-07-21 15:20:33.782797	bbffade8-2151-4c8d-bb24-df1b0d515203
6f42c63f-03fa-4247-b935-7926713feb66	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784666571/projects/cef60249-2727-476e-bd94-4d3e9dd03916/rzuyuzhzccnafctvtlec.jpg	projects/cef60249-2727-476e-bd94-4d3e9dd03916/rzuyuzhzccnafctvtlec	2026-07-21 20:42:53.324236	cef60249-2727-476e-bd94-4d3e9dd03916
7300f841-6c7f-4c4c-8d7d-c4f685282677	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784726891/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ludichg5pz9fdg9v5cjy.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ludichg5pz9fdg9v5cjy	2026-07-22 13:28:13.576848	bbffade8-2151-4c8d-bb24-df1b0d515203
ead5aa3a-ff8b-493f-be15-942b342aaacb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784726891/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/bnnsp13gkvapihk20o9g.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/bnnsp13gkvapihk20o9g	2026-07-22 13:28:13.715589	bbffade8-2151-4c8d-bb24-df1b0d515203
027c9d00-96bf-4f46-ac26-5209442569e2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784726892/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/kyinx9pgsizrb7zfblms.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/kyinx9pgsizrb7zfblms	2026-07-22 13:28:13.771028	bbffade8-2151-4c8d-bb24-df1b0d515203
91e47efd-270a-4445-8679-35f541f4e5cf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784726893/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/d7vsqreegcixzrinukol.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/d7vsqreegcixzrinukol	2026-07-22 13:28:15.064999	bbffade8-2151-4c8d-bb24-df1b0d515203
10b4b96e-2447-416d-b785-f8832721cece	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1784806826/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/vuejjliohespkb5bzz0b.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/vuejjliohespkb5bzz0b	2026-07-23 11:40:28.190946	bbffade8-2151-4c8d-bb24-df1b0d515203
c7715df8-7267-49c1-8f7f-5ade26cb5dc5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785083511/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hwdpey5qtv6x7yvkmmjp.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/hwdpey5qtv6x7yvkmmjp	2026-07-26 16:31:52.69064	5c5918d7-0a51-4733-932b-55b35ea538d3
8decd171-735f-4736-8d13-e31af42aad0b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785486465/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/o0zrl0w1nwptkbytjoyc.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/o0zrl0w1nwptkbytjoyc	2026-07-31 08:27:46.735102	bbffade8-2151-4c8d-bb24-df1b0d515203
adf747bf-6db8-448b-be36-ca4360b4b6e5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785486465/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/bq7mchghikii5cu2mo4c.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/bq7mchghikii5cu2mo4c	2026-07-31 08:27:46.834101	bbffade8-2151-4c8d-bb24-df1b0d515203
80cb2fa0-7ceb-4d4b-8936-833e71123374	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785498474/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/pmnqqolhy0100ftzimjz.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/pmnqqolhy0100ftzimjz	2026-07-31 11:47:55.752476	bbffade8-2151-4c8d-bb24-df1b0d515203
3584f3c9-bced-4e50-8d42-113bd3df74d0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785498475/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/vczg8hchox15mjom4oau.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/vczg8hchox15mjom4oau	2026-07-31 11:47:56.306186	bbffade8-2151-4c8d-bb24-df1b0d515203
54871679-11bb-46b6-95df-643cbb39a15f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785518520/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/im40qklpkj1pwxvqhjpp.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/im40qklpkj1pwxvqhjpp	2026-07-31 17:22:01.163493	bbffade8-2151-4c8d-bb24-df1b0d515203
748c1360-e019-41f6-9e01-744baa83ba2c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785518520/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/mixfcg2izulnjmvwuabs.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/mixfcg2izulnjmvwuabs	2026-07-31 17:22:01.51869	bbffade8-2151-4c8d-bb24-df1b0d515203
30200f50-f0f1-4115-bb45-5a56f3610150	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785945488/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/tsmqzqcfng8sk84njfi3.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/tsmqzqcfng8sk84njfi3	2026-08-05 15:58:09.232111	bbffade8-2151-4c8d-bb24-df1b0d515203
692ce2c4-805a-4509-a9dd-60893ccf7558	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785945488/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/qchp5jcz5gowsobtiro8.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/qchp5jcz5gowsobtiro8	2026-08-05 15:58:09.418061	bbffade8-2151-4c8d-bb24-df1b0d515203
57a1b50d-6af2-4540-ba88-6bdfe48cd41e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785945488/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/mazarldjzzhuskbs6jed.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/mazarldjzzhuskbs6jed	2026-08-05 15:58:09.535211	bbffade8-2151-4c8d-bb24-df1b0d515203
3a4b3111-2909-4b26-b9f1-934f06fedda0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1786646040/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/wjcmndjt5q6vknisysef.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/wjcmndjt5q6vknisysef	2026-08-13 18:34:01.604219	bbffade8-2151-4c8d-bb24-df1b0d515203
b33e233d-a209-4387-afb7-be46502753b0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1786646040/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/onr4arjinfwloh2gczhq.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/onr4arjinfwloh2gczhq	2026-08-13 18:34:02.564046	bbffade8-2151-4c8d-bb24-df1b0d515203
81316305-be91-4659-bca8-9fea9340688a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1786646040/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ifcvbkelcly1m5n0t6jk.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ifcvbkelcly1m5n0t6jk	2026-08-13 18:34:02.769017	bbffade8-2151-4c8d-bb24-df1b0d515203
7bf500d2-0d38-4388-b3a9-a74d442a6833	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787756027/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/v2wyarkxgig2cncfmfis.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/v2wyarkxgig2cncfmfis	2026-08-26 14:53:48.790818	7ff6c67c-a436-402a-aa4e-a080d8dc21df
3e17b992-9e4e-47ea-b48e-86b4b8e0b1e0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787756027/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/qlagsgyijh5gkpjzwwry.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/qlagsgyijh5gkpjzwwry	2026-08-26 14:53:48.865156	7ff6c67c-a436-402a-aa4e-a080d8dc21df
8bdf8f1f-1e4d-4ee9-bef0-71ded2547b72	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787756027/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/oi0tcnlpygd5v7hvsv9u.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/oi0tcnlpygd5v7hvsv9u	2026-08-26 14:53:49.111095	7ff6c67c-a436-402a-aa4e-a080d8dc21df
04875cfd-72b8-4710-9711-427f4369579b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787820538/projects/4813a930-e772-4adf-85d8-0448d373f829/oemdfiewkbfoxqavvcyq.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/oemdfiewkbfoxqavvcyq	2026-08-27 08:48:59.554035	4813a930-e772-4adf-85d8-0448d373f829
b0c23c62-9239-4c3a-aeba-eeb4b090ca14	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787820538/projects/4813a930-e772-4adf-85d8-0448d373f829/qzhkjfpbkmeacgru3k9p.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/qzhkjfpbkmeacgru3k9p	2026-08-27 08:48:59.703792	4813a930-e772-4adf-85d8-0448d373f829
7ef28168-6c56-4b94-8a6a-035a5c33cf21	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787820538/projects/4813a930-e772-4adf-85d8-0448d373f829/xarx3lf6hfycqfdkdqja.jpg	projects/4813a930-e772-4adf-85d8-0448d373f829/xarx3lf6hfycqfdkdqja	2026-08-27 08:48:59.769666	4813a930-e772-4adf-85d8-0448d373f829
2c0e0a1a-7869-42b5-982c-337da8a03943	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787861712/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/m7bqafvq8wkrt1juk4u5.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/m7bqafvq8wkrt1juk4u5	2026-08-27 20:15:13.746467	7ff6c67c-a436-402a-aa4e-a080d8dc21df
5b0f47e1-3032-4bef-b61d-9d07a1dd1eb8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1787861712/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/zoneyoqwywyycyaylhbr.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/zoneyoqwywyycyaylhbr	2026-08-27 20:15:13.999139	7ff6c67c-a436-402a-aa4e-a080d8dc21df
d67b83e1-8b55-4b26-aa8d-8504047e78be	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022097/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/oosuqxzazbbwxlu6clwt.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/oosuqxzazbbwxlu6clwt	2026-08-29 16:48:18.4684	7ff6c67c-a436-402a-aa4e-a080d8dc21df
110de2c0-fee6-48b5-bb0c-788ec454b492	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022097/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/a2nysav7sprbi6tne9hk.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/a2nysav7sprbi6tne9hk	2026-08-29 16:48:18.639069	7ff6c67c-a436-402a-aa4e-a080d8dc21df
0d1bb0ef-a6b4-4100-ae66-3da36fc64e22	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022097/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ihldz7dnhyrd2woi8mx9.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ihldz7dnhyrd2woi8mx9	2026-08-29 16:48:18.678307	7ff6c67c-a436-402a-aa4e-a080d8dc21df
55c56259-288d-4023-ab38-5a559ef5c1cc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022098/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/grx1qgzmndcjho1nlvfe.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/grx1qgzmndcjho1nlvfe	2026-08-29 16:48:19.806758	7ff6c67c-a436-402a-aa4e-a080d8dc21df
ff4a1266-ad2c-4aa4-b2ad-35ac2a731052	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022098/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/skqxcifentzcmcv5vlfe.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/skqxcifentzcmcv5vlfe	2026-08-29 16:48:19.9819	7ff6c67c-a436-402a-aa4e-a080d8dc21df
4302b1f2-cdb8-49ab-af10-1d191358f369	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788022182/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/iqdiokdeu93o6f8laufv.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/iqdiokdeu93o6f8laufv	2026-08-29 16:49:42.84688	7ff6c67c-a436-402a-aa4e-a080d8dc21df
e1adf53e-01cb-4626-b65c-651f33af75b0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788358810/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/wuak0xaimppj67dxxmqd.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/wuak0xaimppj67dxxmqd	2026-09-02 14:20:11.14617	bbffade8-2151-4c8d-bb24-df1b0d515203
c06319d3-5b98-4749-bff6-d2a4d620e018	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788358810/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/gl0jjhp0yinkl4ymgorv.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/gl0jjhp0yinkl4ymgorv	2026-09-02 14:20:11.254269	bbffade8-2151-4c8d-bb24-df1b0d515203
a378072c-ddfa-4945-bfd6-85f500e747e0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788358810/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/qlgnixmsd4dhlzrgd9ie.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/qlgnixmsd4dhlzrgd9ie	2026-09-02 14:20:11.462176	bbffade8-2151-4c8d-bb24-df1b0d515203
f4d24ba9-6c3f-42c5-82a8-7aad9d4efd98	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788358811/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ztzq2ix1q3opabialbyx.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ztzq2ix1q3opabialbyx	2026-09-02 14:20:12.74316	bbffade8-2151-4c8d-bb24-df1b0d515203
c682f167-d561-4a39-88d1-18d6caf4c98b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788358811/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ogqc3zpy7a2yyjatxnwj.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/ogqc3zpy7a2yyjatxnwj	2026-09-02 14:20:12.844397	bbffade8-2151-4c8d-bb24-df1b0d515203
844d699b-35c8-4117-89e6-ffbdf6bafd35	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788633863/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/xoibzwn0ls20ho2ii2bb.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/xoibzwn0ls20ho2ii2bb	2026-09-05 18:44:24.288807	7ff6c67c-a436-402a-aa4e-a080d8dc21df
c29dec04-0d2e-4edb-ab89-598d66745810	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788633862/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/clqgvecpqoxoqbdjklln.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/clqgvecpqoxoqbdjklln	2026-09-05 18:44:24.388141	7ff6c67c-a436-402a-aa4e-a080d8dc21df
ab1d97c8-3a93-47dd-827f-84b897a4e6df	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788633863/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/uvopv2kc9boitnih5ly7.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/uvopv2kc9boitnih5ly7	2026-09-05 18:44:24.432117	7ff6c67c-a436-402a-aa4e-a080d8dc21df
7c229582-565b-47ea-a182-ede43e6eeac8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788633864/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/syxhsmcnunkgbiq1sk82.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/syxhsmcnunkgbiq1sk82	2026-09-05 18:44:25.527504	7ff6c67c-a436-402a-aa4e-a080d8dc21df
77ad946d-f41e-48df-a79b-c4ce45504db4	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788892638/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/uto3llkuclafjetmgpmn.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/uto3llkuclafjetmgpmn	2026-09-08 18:37:19.848079	7ff6c67c-a436-402a-aa4e-a080d8dc21df
af2d50b0-7585-4f5e-8dbd-3e45a6b87241	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788892638/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/evij34jtuxux3lmgsuzo.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/evij34jtuxux3lmgsuzo	2026-09-08 18:37:20.072349	7ff6c67c-a436-402a-aa4e-a080d8dc21df
ae14d274-7c21-4e10-9381-e31e68b791c5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976322/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/tddog1svauyfd6ehuap7.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/tddog1svauyfd6ehuap7	2026-09-09 17:52:03.326604	7ff6c67c-a436-402a-aa4e-a080d8dc21df
8fae62aa-00cf-44b0-94c2-95f3fb7a37d8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976321/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ewxikp8coqoigxb8x9um.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ewxikp8coqoigxb8x9um	2026-09-09 17:52:03.450167	7ff6c67c-a436-402a-aa4e-a080d8dc21df
6cd39ad5-1756-4abd-bf3e-03bc16f1666b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976322/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/v9vyh1kfo308zmenp9vb.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/v9vyh1kfo308zmenp9vb	2026-09-09 17:52:03.547028	7ff6c67c-a436-402a-aa4e-a080d8dc21df
f6726d02-a055-4988-85be-99b5c49ea875	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976323/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/sctkq7vhiswkr5hxg8he.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/sctkq7vhiswkr5hxg8he	2026-09-09 17:52:04.724441	7ff6c67c-a436-402a-aa4e-a080d8dc21df
c7ae502f-4295-49fc-be09-8a9c98e80fec	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976323/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ltaspd79wlv4k5rot0tm.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/ltaspd79wlv4k5rot0tm	2026-09-09 17:52:05.379112	7ff6c67c-a436-402a-aa4e-a080d8dc21df
8897c261-9186-45a1-bf7c-a7aadae33195	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788976323/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/nwlx92u5rlkza3kmslcv.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/nwlx92u5rlkza3kmslcv	2026-09-09 17:52:06.047644	7ff6c67c-a436-402a-aa4e-a080d8dc21df
4cffb12f-e442-40c3-afc2-fb4970592009	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789149867/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/droptetfzbxrjooxwcfu.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/droptetfzbxrjooxwcfu	2026-09-11 18:04:29.116388	ac5d737c-2421-48f2-8e01-e3c4ee638738
19eadc5c-f214-459a-84d1-e3e21d4643ba	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233672/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jtpwhz5hkbqh6vyt4cx9.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jtpwhz5hkbqh6vyt4cx9	2026-09-12 17:21:13.851495	ac5d737c-2421-48f2-8e01-e3c4ee638738
736fe6bd-dc83-46d8-aac7-e75078d8a7fd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233841/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/ukolayrcyi0tuy5tnrnq.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/ukolayrcyi0tuy5tnrnq	2026-09-12 17:24:02.267244	ac5d737c-2421-48f2-8e01-e3c4ee638738
b079dbd8-0b88-426d-b3d4-ad50af6782a0	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233841/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/dbqks0c2n93j1dwing6m.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/dbqks0c2n93j1dwing6m	2026-09-12 17:24:02.397475	ac5d737c-2421-48f2-8e01-e3c4ee638738
ce4a7f2f-321b-4b77-bb17-d14143999e94	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233841/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/j92ldwoeashk7zshgmtv.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/j92ldwoeashk7zshgmtv	2026-09-12 17:24:02.64433	ac5d737c-2421-48f2-8e01-e3c4ee638738
cc1779fb-715b-40cf-beeb-4d4aae6f1e6f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233842/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/q5dci9qxlxy4cwopsl76.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/q5dci9qxlxy4cwopsl76	2026-09-12 17:24:03.639041	ac5d737c-2421-48f2-8e01-e3c4ee638738
853798d7-65bf-4ab8-aa64-0b58d19c8d14	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233842/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/tisp5qucasvrrzgnc7z0.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/tisp5qucasvrrzgnc7z0	2026-09-12 17:24:03.910258	ac5d737c-2421-48f2-8e01-e3c4ee638738
67e5fad8-ed29-4360-89cd-54982b67c87e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789233952/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jpy0wdszua0zpdvd7jge.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jpy0wdszua0zpdvd7jge	2026-09-12 17:25:53.807473	ac5d737c-2421-48f2-8e01-e3c4ee638738
f0e2f315-42a2-4594-bc33-9283bb7c20e6	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789409785/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/ben75fhqp6qajei5ll8f.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/ben75fhqp6qajei5ll8f	2026-09-14 18:16:26.620075	ac5d737c-2421-48f2-8e01-e3c4ee638738
821fa379-68b1-4f75-a841-1fdfbc1de83b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789409785/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jdxhfearemdajhzgxuvy.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/jdxhfearemdajhzgxuvy	2026-09-14 18:16:26.797157	ac5d737c-2421-48f2-8e01-e3c4ee638738
3ce2c7cc-ce8b-47a7-beef-1cbfd80d54b7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789409785/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/vtxjiltqdbaltrywmhi8.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/vtxjiltqdbaltrywmhi8	2026-09-14 18:16:26.939743	ac5d737c-2421-48f2-8e01-e3c4ee638738
2c090a26-6c18-4ef0-92a9-b0b67ca9094b	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789533653/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uqupwhq6l8kpplb5o6m2.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uqupwhq6l8kpplb5o6m2	2026-09-16 04:40:54.697278	678c86c5-32e7-4026-95b4-8e6bc404beb3
79470ce8-bfc4-4187-a39e-5431da3c952e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789580170/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/suhoioqijutv0vqmlnmk.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/suhoioqijutv0vqmlnmk	2026-09-16 17:36:11.25794	678c86c5-32e7-4026-95b4-8e6bc404beb3
a746efe3-2506-4171-86bd-d75692e70f2c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789580170/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uxg7loldde4ojqtb32vr.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uxg7loldde4ojqtb32vr	2026-09-16 17:36:11.423165	678c86c5-32e7-4026-95b4-8e6bc404beb3
49695ac3-423c-4fbd-821f-84e5d2c1fbc3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789580231/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/gxrcm5nayppgtuh8ekzv.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/gxrcm5nayppgtuh8ekzv	2026-09-16 17:37:12.489896	678c86c5-32e7-4026-95b4-8e6bc404beb3
c8dacac1-92f4-4a74-8113-002a3a5c6bbd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789580231/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/i7nc2l9llvomfu6ygf40.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/i7nc2l9llvomfu6ygf40	2026-09-16 17:37:12.642741	678c86c5-32e7-4026-95b4-8e6bc404beb3
01e97624-3f9f-402e-a761-b52db2ad69cc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789580231/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/ji8eega8z7zkrmyxxbdn.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/ji8eega8z7zkrmyxxbdn	2026-09-16 17:37:12.73935	678c86c5-32e7-4026-95b4-8e6bc404beb3
a9666d02-1162-4624-9593-b79f5d41a218	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789726812/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/dotna5smyfl6ye7am4oz.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/dotna5smyfl6ye7am4oz	2026-09-18 10:20:14.030772	678c86c5-32e7-4026-95b4-8e6bc404beb3
0bc714d1-709c-441b-b811-b0ac35a5b7ba	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789726812/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/zk5z0zhrcvuvn5nunzgb.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/zk5z0zhrcvuvn5nunzgb	2026-09-18 10:20:14.221937	678c86c5-32e7-4026-95b4-8e6bc404beb3
39c9c8b8-b1d3-4542-aaef-fd99917b91d1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789726812/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/dhdcvv7arqmgkddcl4jt.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/dhdcvv7arqmgkddcl4jt	2026-09-18 10:20:14.258651	678c86c5-32e7-4026-95b4-8e6bc404beb3
ec8afa76-dadd-41fc-b0bb-15417c38eefc	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789754841/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/k9pffxikhdviqgu09rks.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/k9pffxikhdviqgu09rks	2026-09-18 18:07:22.734016	678c86c5-32e7-4026-95b4-8e6bc404beb3
829082b4-b2b0-48f3-b58d-97d1e7dc28f2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789754841/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/niuwwzgarabdth9ttepc.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/niuwwzgarabdth9ttepc	2026-09-18 18:07:22.921812	678c86c5-32e7-4026-95b4-8e6bc404beb3
c58cead9-fe6a-40a2-9e97-b301620a8844	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789754841/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/ya6pi5uaobbasvsuefnv.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/ya6pi5uaobbasvsuefnv	2026-09-18 18:07:22.988863	678c86c5-32e7-4026-95b4-8e6bc404beb3
7cfd0a55-1822-4902-9073-17568238a213	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789754843/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/awoorkigwvchryqexwae.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/awoorkigwvchryqexwae	2026-09-18 18:07:24.090529	678c86c5-32e7-4026-95b4-8e6bc404beb3
09a100bb-797c-4027-bb36-79343c761ce1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790015397/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/qrf6upfzwz6c29chjczl.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/qrf6upfzwz6c29chjczl	2026-09-21 18:29:58.654228	678c86c5-32e7-4026-95b4-8e6bc404beb3
a94242fa-3b96-44cf-a4b2-4daf6014fbfd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790015397/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uokqb3a1lrmedyzsovy0.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/uokqb3a1lrmedyzsovy0	2026-09-21 18:29:58.860953	678c86c5-32e7-4026-95b4-8e6bc404beb3
1c0114ab-01e3-465f-9f97-9a0b4e1f7222	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790174026/projects/d83c0440-0d14-41ac-965a-7155f13d6713/nthetftpxoxb8qygurzw.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/nthetftpxoxb8qygurzw	2026-09-23 14:33:47.391458	d83c0440-0d14-41ac-965a-7155f13d6713
5554a749-03e2-4991-b5bb-3ea28f361a24	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790174026/projects/d83c0440-0d14-41ac-965a-7155f13d6713/aneq0orrrpybmjlqkumb.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/aneq0orrrpybmjlqkumb	2026-09-23 14:33:47.540749	d83c0440-0d14-41ac-965a-7155f13d6713
196ccfd8-8e7e-40f6-954c-cdb50b09286d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790174026/projects/d83c0440-0d14-41ac-965a-7155f13d6713/oz8dblqi9bxi6aaa5jeu.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/oz8dblqi9bxi6aaa5jeu	2026-09-23 14:33:47.613966	d83c0440-0d14-41ac-965a-7155f13d6713
436d0b9f-5805-41e9-a01b-2f4a38634d42	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790261395/projects/d83c0440-0d14-41ac-965a-7155f13d6713/fqrxfbnz9oxuonba6cf4.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/fqrxfbnz9oxuonba6cf4	2026-09-24 14:49:56.991343	d83c0440-0d14-41ac-965a-7155f13d6713
3bc08b00-1705-4516-b29c-7fd2acb867c1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790261395/projects/d83c0440-0d14-41ac-965a-7155f13d6713/m4qfeyhtf3md1kvkavqg.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/m4qfeyhtf3md1kvkavqg	2026-09-24 14:49:57.077739	d83c0440-0d14-41ac-965a-7155f13d6713
c39047f5-58bc-44c1-a7ae-659cc0e44c44	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790261395/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ekralou9ne2miv7uqsa0.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ekralou9ne2miv7uqsa0	2026-09-24 14:49:57.744617	d83c0440-0d14-41ac-965a-7155f13d6713
4eab84c3-9341-4fd3-b315-047aff37d3a9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337790/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/t4fo35vc33zda3uqkvas.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/t4fo35vc33zda3uqkvas	2026-09-25 12:03:11.380358	678c86c5-32e7-4026-95b4-8e6bc404beb3
7c247762-be63-427b-aa26-997b9d557b4a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337790/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/m8h9sjyjocuttox6lodv.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/m8h9sjyjocuttox6lodv	2026-09-25 12:03:11.851313	678c86c5-32e7-4026-95b4-8e6bc404beb3
0636b2ee-06d6-47ef-a08f-1da8835df1c3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337790/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/xbecv69lotf7kgzxf0lg.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/xbecv69lotf7kgzxf0lg	2026-09-25 12:03:11.966228	678c86c5-32e7-4026-95b4-8e6bc404beb3
41bdfafc-a6ee-42cc-aab1-ae0a3d21c496	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337791/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/o5uq2taz8t6aldozobt4.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/o5uq2taz8t6aldozobt4	2026-09-25 12:03:12.836722	678c86c5-32e7-4026-95b4-8e6bc404beb3
1ec91e1d-b67c-4de5-a5fc-dd17b31226ce	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337792/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/lgzksze5iykahp00vkso.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/lgzksze5iykahp00vkso	2026-09-25 12:03:13.12895	678c86c5-32e7-4026-95b4-8e6bc404beb3
2f57bdea-3eb8-4eda-a2ee-a8f934fef886	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337792/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/brvbxzp1ampsgpwrji0w.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/brvbxzp1ampsgpwrji0w	2026-09-25 12:03:13.362556	678c86c5-32e7-4026-95b4-8e6bc404beb3
3647840c-670d-493d-b522-6bdd96f4500a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337793/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/tchlmxkhfjrrb2pxx8kf.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/tchlmxkhfjrrb2pxx8kf	2026-09-25 12:03:14.710018	678c86c5-32e7-4026-95b4-8e6bc404beb3
19d11db8-2b1c-402f-915b-19d7a73df90e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790337793/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/r6caudvsgcxlhjl7drry.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/r6caudvsgcxlhjl7drry	2026-09-25 12:03:14.857774	678c86c5-32e7-4026-95b4-8e6bc404beb3
d60413a4-54a1-4f25-8df7-064b3d863f4e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790354343/projects/d83c0440-0d14-41ac-965a-7155f13d6713/whh6fjfzl3ipuwx8lznu.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/whh6fjfzl3ipuwx8lznu	2026-09-25 16:39:04.044287	d83c0440-0d14-41ac-965a-7155f13d6713
b1e38c9d-b74f-44e1-87b9-dbe185b45c2c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790354343/projects/d83c0440-0d14-41ac-965a-7155f13d6713/s2reammcrvj3qk8uh0fv.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/s2reammcrvj3qk8uh0fv	2026-09-25 16:39:04.139936	d83c0440-0d14-41ac-965a-7155f13d6713
87344a6b-e196-4296-ad4e-8e2de06134ad	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790354343/projects/d83c0440-0d14-41ac-965a-7155f13d6713/pztdgetypmzvagrov8yv.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/pztdgetypmzvagrov8yv	2026-09-25 16:39:04.795688	d83c0440-0d14-41ac-965a-7155f13d6713
794e2a83-673f-4f65-806c-52040568ac26	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790354344/projects/d83c0440-0d14-41ac-965a-7155f13d6713/i9oio9qqyzdgs4varsvk.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/i9oio9qqyzdgs4varsvk	2026-09-25 16:39:05.95699	d83c0440-0d14-41ac-965a-7155f13d6713
d0b73e49-c946-45a9-9b3d-acc7bfd37c67	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790426693/projects/d83c0440-0d14-41ac-965a-7155f13d6713/si7xtlkjkjtghzx0ys8b.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/si7xtlkjkjtghzx0ys8b	2026-09-26 12:44:54.725644	d83c0440-0d14-41ac-965a-7155f13d6713
98743ab4-133b-4214-aad4-991440bf5f88	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790426693/projects/d83c0440-0d14-41ac-965a-7155f13d6713/azr7lgxasplu7sktd54s.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/azr7lgxasplu7sktd54s	2026-09-26 12:44:54.901178	d83c0440-0d14-41ac-965a-7155f13d6713
836039e4-a51d-4578-8d22-137fb9e69b62	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790426693/projects/d83c0440-0d14-41ac-965a-7155f13d6713/bb1w2p0ticcbmd0rhwhi.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/bb1w2p0ticcbmd0rhwhi	2026-09-26 12:44:54.934555	d83c0440-0d14-41ac-965a-7155f13d6713
eab8a8e2-5e53-46de-b754-a18561341996	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790442248/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ywuona07xlqsnuel0dbf.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ywuona07xlqsnuel0dbf	2026-09-26 17:04:09.10847	d83c0440-0d14-41ac-965a-7155f13d6713
56ceb520-ebb4-4137-b221-4c89656e80f7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790442248/projects/d83c0440-0d14-41ac-965a-7155f13d6713/z5iwot2cvmclaydnbjpu.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/z5iwot2cvmclaydnbjpu	2026-09-26 17:04:09.30558	d83c0440-0d14-41ac-965a-7155f13d6713
b6d99aca-09ec-44bf-ac1d-89429e7bd143	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790442248/projects/d83c0440-0d14-41ac-965a-7155f13d6713/d6yk43arwnlhqtnpjszt.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/d6yk43arwnlhqtnpjszt	2026-09-26 17:04:09.527633	d83c0440-0d14-41ac-965a-7155f13d6713
3277326e-9b38-4ea6-9904-983a50e4711f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790442249/projects/d83c0440-0d14-41ac-965a-7155f13d6713/kpnv045zykpmhtf4aoos.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/kpnv045zykpmhtf4aoos	2026-09-26 17:04:10.770354	d83c0440-0d14-41ac-965a-7155f13d6713
da3ae295-50bb-4905-a8f4-836d2d843a23	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790442249/projects/d83c0440-0d14-41ac-965a-7155f13d6713/teg6qxfex2qj31kfir9s.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/teg6qxfex2qj31kfir9s	2026-09-26 17:04:10.87072	d83c0440-0d14-41ac-965a-7155f13d6713
d5e7ccb4-5ad5-4547-8ef3-7ada99fe3ded	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791050155/projects/d83c0440-0d14-41ac-965a-7155f13d6713/pq4doh2idqahdkbdijr4.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/pq4doh2idqahdkbdijr4	2026-10-03 17:55:56.748293	d83c0440-0d14-41ac-965a-7155f13d6713
b8d1d8c4-be78-463c-9bd8-00773b39da5d	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791050155/projects/d83c0440-0d14-41ac-965a-7155f13d6713/cppuxffez0wnmvg0wmkd.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/cppuxffez0wnmvg0wmkd	2026-10-03 17:55:56.880342	d83c0440-0d14-41ac-965a-7155f13d6713
8a92656f-8622-4189-84e7-d2c6cddcaae7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791050155/projects/d83c0440-0d14-41ac-965a-7155f13d6713/h1mjvu3mylahxvz0dk61.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/h1mjvu3mylahxvz0dk61	2026-10-03 17:55:57.01304	d83c0440-0d14-41ac-965a-7155f13d6713
235d43b7-ffe2-4e3f-ad6c-c0e7aa5979c5	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791050157/projects/d83c0440-0d14-41ac-965a-7155f13d6713/nyqjd9g53qmfiatifoih.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/nyqjd9g53qmfiatifoih	2026-10-03 17:55:57.986816	d83c0440-0d14-41ac-965a-7155f13d6713
3f3be8f0-0893-4045-81c5-b60a67815b2f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791050157/projects/d83c0440-0d14-41ac-965a-7155f13d6713/v5sae1ivty9wygsmc2gb.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/v5sae1ivty9wygsmc2gb	2026-10-03 17:55:58.261733	d83c0440-0d14-41ac-965a-7155f13d6713
bf0a25de-3be3-4917-bd5f-a0a646a8ae69	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791220533/projects/d83c0440-0d14-41ac-965a-7155f13d6713/b5lqffhtt1ddhqrjetdn.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/b5lqffhtt1ddhqrjetdn	2026-10-05 17:15:34.913522	d83c0440-0d14-41ac-965a-7155f13d6713
33ef78a6-76c9-4bfc-9b9f-14a51d77ce71	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791220533/projects/d83c0440-0d14-41ac-965a-7155f13d6713/eietxu4aqkakxk9zcs4o.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/eietxu4aqkakxk9zcs4o	2026-10-05 17:15:35.092665	d83c0440-0d14-41ac-965a-7155f13d6713
9805111c-f53b-4e08-a713-607bff64332c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791220533/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ailghvax8u0jjjafg1sn.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ailghvax8u0jjjafg1sn	2026-10-05 17:15:35.133127	d83c0440-0d14-41ac-965a-7155f13d6713
b65a0f00-29a8-4820-b099-c683c5cc2a3c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791392979/projects/d83c0440-0d14-41ac-965a-7155f13d6713/lnxfmoipjtkqio1rh5vf.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/lnxfmoipjtkqio1rh5vf	2026-10-07 17:09:40.389458	d83c0440-0d14-41ac-965a-7155f13d6713
05aa43e5-4244-447d-90f5-2865fc812a34	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791392979/projects/d83c0440-0d14-41ac-965a-7155f13d6713/mkzz2adxqtttcebn7uoc.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/mkzz2adxqtttcebn7uoc	2026-10-07 17:09:40.589464	d83c0440-0d14-41ac-965a-7155f13d6713
821b6815-b650-44bd-8d13-e31aedeaa9dd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791393199/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ghzswxa0op3hwkveqmzp.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ghzswxa0op3hwkveqmzp	2026-10-07 17:13:20.620234	d83c0440-0d14-41ac-965a-7155f13d6713
4a43dc48-b2fd-4e94-b423-efecb86940b3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791393199/projects/d83c0440-0d14-41ac-965a-7155f13d6713/w7wjywlnibwrqervvlmu.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/w7wjywlnibwrqervvlmu	2026-10-07 17:13:20.875191	d83c0440-0d14-41ac-965a-7155f13d6713
b0af2e16-e479-4ac2-bf4d-dcc96f9fcefe	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791393200/projects/d83c0440-0d14-41ac-965a-7155f13d6713/r70gpavvjzn2ptwcavlw.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/r70gpavvjzn2ptwcavlw	2026-10-07 17:13:21.144312	d83c0440-0d14-41ac-965a-7155f13d6713
7a8e595f-0f47-40ec-a6a7-e50c98ade75f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791393200/projects/d83c0440-0d14-41ac-965a-7155f13d6713/dlpxssrrjb0cxwiu9jzw.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/dlpxssrrjb0cxwiu9jzw	2026-10-07 17:13:21.778707	d83c0440-0d14-41ac-965a-7155f13d6713
b11e6c28-97a0-4293-81e0-2e25278fd325	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791393201/projects/d83c0440-0d14-41ac-965a-7155f13d6713/douyfp4cfeuddz016lwo.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/douyfp4cfeuddz016lwo	2026-10-07 17:13:22.218271	d83c0440-0d14-41ac-965a-7155f13d6713
13727d2a-42ef-4773-9bfb-0f76779163b2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475909/projects/d83c0440-0d14-41ac-965a-7155f13d6713/kxizrtqxe5tndfots5j0.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/kxizrtqxe5tndfots5j0	2026-10-08 16:11:50.515075	d83c0440-0d14-41ac-965a-7155f13d6713
591fb4c1-54fa-40f4-a71c-c0aeb468aaf3	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475909/projects/d83c0440-0d14-41ac-965a-7155f13d6713/snsrgpnw490yhdumihzv.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/snsrgpnw490yhdumihzv	2026-10-08 16:11:50.675577	d83c0440-0d14-41ac-965a-7155f13d6713
21606f0a-2a4d-4a44-9a0b-7b0fa670965e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475909/projects/d83c0440-0d14-41ac-965a-7155f13d6713/n4c5cxfyrj3jrz7epryf.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/n4c5cxfyrj3jrz7epryf	2026-10-08 16:11:50.90202	d83c0440-0d14-41ac-965a-7155f13d6713
8490b686-88b3-48f6-b4bb-70643c3525fd	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475910/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ufy70xlercrtkjykvhut.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ufy70xlercrtkjykvhut	2026-10-08 16:11:51.624983	d83c0440-0d14-41ac-965a-7155f13d6713
6a2bf8e1-17ce-461b-9ac8-4a2331500c37	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475910/projects/d83c0440-0d14-41ac-965a-7155f13d6713/oaim6bc8omrevhuvl5kw.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/oaim6bc8omrevhuvl5kw	2026-10-08 16:11:51.855301	d83c0440-0d14-41ac-965a-7155f13d6713
4dfc5c49-90fd-4dad-a7a7-847fbb70458e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475911/projects/d83c0440-0d14-41ac-965a-7155f13d6713/fqbfi2f09yoturuaoamq.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/fqbfi2f09yoturuaoamq	2026-10-08 16:11:52.212444	d83c0440-0d14-41ac-965a-7155f13d6713
9b54e971-3027-498d-9ac3-6d9325340062	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475911/projects/d83c0440-0d14-41ac-965a-7155f13d6713/pe1a06imru8no3nkean8.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/pe1a06imru8no3nkean8	2026-10-08 16:11:53.140304	d83c0440-0d14-41ac-965a-7155f13d6713
18373884-46cd-40d6-b311-90d29d42835c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475999/projects/d83c0440-0d14-41ac-965a-7155f13d6713/k9yzhjtxwm84iutydq4p.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/k9yzhjtxwm84iutydq4p	2026-10-08 16:13:19.928951	d83c0440-0d14-41ac-965a-7155f13d6713
61039269-cb3f-410d-8495-9fa13363b0ae	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791475999/projects/d83c0440-0d14-41ac-965a-7155f13d6713/h8pwi3zimpj7ka1gnwp6.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/h8pwi3zimpj7ka1gnwp6	2026-10-08 16:13:20.104508	d83c0440-0d14-41ac-965a-7155f13d6713
556116f3-d039-4a45-bbc9-5e4d681dd08f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791476102/projects/d83c0440-0d14-41ac-965a-7155f13d6713/rtqrrjmfgzu1t8f4botc.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/rtqrrjmfgzu1t8f4botc	2026-10-08 16:15:03.486185	d83c0440-0d14-41ac-965a-7155f13d6713
581fb2aa-fb9d-4491-82d3-a4385a554fd1	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791476102/projects/d83c0440-0d14-41ac-965a-7155f13d6713/g1wbmggz85pw1i5vclgc.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/g1wbmggz85pw1i5vclgc	2026-10-08 16:15:03.633233	d83c0440-0d14-41ac-965a-7155f13d6713
55a88183-5168-4ed6-8e4f-2c9c3a0fd56e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791476102/projects/d83c0440-0d14-41ac-965a-7155f13d6713/uw4ebltvuvwsmoylr608.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/uw4ebltvuvwsmoylr608	2026-10-08 16:15:03.867783	d83c0440-0d14-41ac-965a-7155f13d6713
ecd77240-cfa2-44d6-873f-2ca4c9ab1ea9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791477439/projects/d83c0440-0d14-41ac-965a-7155f13d6713/ayksmk9vjlj5x2cocmi5.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/ayksmk9vjlj5x2cocmi5	2026-10-08 16:37:20.40053	d83c0440-0d14-41ac-965a-7155f13d6713
51be4a14-dce4-4604-8fc8-7174e261c71a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791567231/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/jkslowmbvegnvfkuyjee.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/jkslowmbvegnvfkuyjee	2026-10-09 17:33:52.165785	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
831def70-37b1-4d8f-b575-f9cbf8007629	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791567231/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/vdtvx5mbj2kxrrtvj8ht.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/vdtvx5mbj2kxrrtvj8ht	2026-10-09 17:33:52.24747	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
38d9671a-665b-4870-b778-af5ae639229c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759374/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/sw2sna7n0q26gnoyyeik.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/sw2sna7n0q26gnoyyeik	2026-10-11 22:56:15.544684	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
45d2f2d0-3910-45ca-a15a-76d604edc2a8	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759374/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/eeeagajzn259bimnnjpc.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/eeeagajzn259bimnnjpc	2026-10-11 22:56:15.692882	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
f72c01b2-b30f-4d48-b95a-59a3cbedc6b9	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759374/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/ddblc6ooarsixnezuuxy.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/ddblc6ooarsixnezuuxy	2026-10-11 22:56:15.831624	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
bb66f54b-d39c-42b9-8e0b-29e759780991	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759375/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/zd4wolbesgm0dfc6laix.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/zd4wolbesgm0dfc6laix	2026-10-11 22:56:16.76879	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
b0235578-45fa-4dcf-bbb4-86e011d90b73	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759501/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/occxmwigjl4jlgaxzsvw.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/occxmwigjl4jlgaxzsvw	2026-10-11 22:58:22.505959	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
4e970aec-a75e-4478-823b-d59aa7c3113e	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759501/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/swnts8goxl1nfa28csbx.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/swnts8goxl1nfa28csbx	2026-10-11 22:58:22.748206	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
fb9a58db-0906-4fc5-be2c-320ab1db04ac	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791759501/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/nui1msrlblfkrbtrbdwf.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/nui1msrlblfkrbtrbdwf	2026-10-11 22:58:22.796747	8fd932a5-3dc1-4bf3-802f-e5285789d8d6
\.


--
-- Data for Name: project_material_items; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_material_items (id, "materialId", quantity, price, "sortOrder", "materialKey", note) FROM stdin;
672b8ffa-4b97-4607-9010-9a1959b327d6	bdc80476-516a-4ab6-805a-18be83b7695a	1.00	\N	0	gutter_4m	vit
90e2be25-335a-4225-9fd8-f3c017fc0aef	bdc80476-516a-4ab6-805a-18be83b7695a	1.00	\N	1	outlet	\N
ed688178-c91a-4c2c-8c08-f4ce2ae2532e	2700df6c-a28f-427d-aa31-29fa4c2dff23	4.00	\N	0	windboard_22x170_3_6m	\N
c7f6a311-6125-4adb-9290-bf187dfd74f4	2700df6c-a28f-427d-aa31-29fa4c2dff23	1.00	\N	1	snow_guard	Tegelröd
7fa77d5a-0994-4101-a038-ddb98322a230	2700df6c-a28f-427d-aa31-29fa4c2dff23	3.00	\N	2	silicone	Transprent
b8557419-1447-4df8-987a-ea7761f5834d	2700df6c-a28f-427d-aa31-29fa4c2dff23	2.00	\N	3	screws_55mm	\N
c4e62bd6-e897-46ce-9ad9-62c4872ae890	2700df6c-a28f-427d-aa31-29fa4c2dff23	1.00	\N	4	metal_screws_33mm	\N
ce091f55-a636-4ff7-9290-59f87cb7c5b5	2700df6c-a28f-427d-aa31-29fa4c2dff23	2.00	\N	5	wood_screws_30mm	\N
bd1d4c96-6dd6-4acf-bb58-bf5acbf63681	2700df6c-a28f-427d-aa31-29fa4c2dff23	1.00	\N	6	screw_75_80mm	\N
55620a4c-9739-46aa-b80d-1ab036d1157e	2700df6c-a28f-427d-aa31-29fa4c2dff23	10.00	\N	7	ridge_band	\N
61c866fb-cd38-4c6e-83f8-f86bf093cc06	2700df6c-a28f-427d-aa31-29fa4c2dff23	5.00	\N	8	bird_band	\N
bc85924a-d12d-4a31-b870-aa93a72534f8	2700df6c-a28f-427d-aa31-29fa4c2dff23	5.00	\N	9	triangle_batten	\N
c0770fce-89ba-4593-a64b-4280f87de7ac	2700df6c-a28f-427d-aa31-29fa4c2dff23	3.00	\N	10	trash_bags	\N
601859dc-6cc2-46b7-8189-de701f09644f	2700df6c-a28f-427d-aa31-29fa4c2dff23	3.00	\N	11	tape	\N
60b15453-969f-48f0-9b74-97fa829bc09b	57e22227-28ec-4ded-af11-ca318ea53423	20.00	\N	0	roof_sheathing_20x540_4_2m	\N
8288c509-db69-45d0-8bb8-2554b63b77b7	57e22227-28ec-4ded-af11-ca318ea53423	3.00	\N	1	wood_screws_30mm	\N
15531d0e-6732-49c9-8d02-63b7a7430220	57e22227-28ec-4ded-af11-ca318ea53423	1.00	\N	2	screw_75_80mm	\N
712c8635-e4cb-4172-a9c3-85243a342d57	57e22227-28ec-4ded-af11-ca318ea53423	1.00	\N	3	clips	\N
0cf38385-bfa8-493a-93ec-1c9c0e6ab323	57e22227-28ec-4ded-af11-ca318ea53423	13.00	\N	4	ridge_band	\N
950bf714-bfb2-43cc-9ee7-e2245c7ad2d9	57e22227-28ec-4ded-af11-ca318ea53423	26.00	\N	5	bird_band	\N
b159e2f0-f021-4131-b034-4465b5f0b5f9	57e22227-28ec-4ded-af11-ca318ea53423	8.00	\N	6	eave_flashing_2m	Svart
e25a0e76-a0d4-4f9e-a350-82cc5887cb10	57e22227-28ec-4ded-af11-ca318ea53423	10.00	\N	7	batten_12x50	\N
47c4539b-d404-4f0d-981a-e6c93d68b038	57e22227-28ec-4ded-af11-ca318ea53423	4.00	\N	8	rafter_45x45_3_6m	\N
910896d0-e02a-4ea3-9309-35a909bec20e	57e22227-28ec-4ded-af11-ca318ea53423	3.00	\N	9	trash_bags	\N
bf384d4b-38d3-485d-b316-e14d3ea31379	57e22227-28ec-4ded-af11-ca318ea53423	1.00	\N	10	paint	Vit
fd429fd1-bef8-46d0-bae1-700857837554	57e22227-28ec-4ded-af11-ca318ea53423	2.00	\N	11	tape	\N
cdb25b9e-7710-4f44-8649-43c8f3c7f535	f672bd09-adb8-4097-9e2b-e45253c5281b	5.00	\N	0	gutter_6m	Svart
36d4b8f9-22c3-4652-8575-7becad88703b	f672bd09-adb8-4097-9e2b-e45253c5281b	2.00	\N	1	gutter_4m	Svart
afdaef84-1f73-4113-8c52-746c115cf672	f672bd09-adb8-4097-9e2b-e45253c5281b	65.00	\N	2	gutter_hook	Svart
826efe17-e51c-4744-9612-23b2842eac84	f672bd09-adb8-4097-9e2b-e45253c5281b	6.00	\N	3	gutter_end	Svart
60dc7f07-9db1-4401-8424-c691129ed0d3	f672bd09-adb8-4097-9e2b-e45253c5281b	5.00	\N	4	gutter_joint	Svart
70a573ee-537f-4cef-b256-e3406d2b6df2	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	5	inner_gutter_angle	Svart
ff436a98-11fb-4b91-9e1b-4598f76c332c	f672bd09-adb8-4097-9e2b-e45253c5281b	3.00	\N	6	omvik	Svart
23ebf05d-e593-4747-84cc-b08c0526a643	f672bd09-adb8-4097-9e2b-e45253c5281b	3.00	\N	7	downpipe_2_5m	Svart
b9c8f150-b7c6-45ca-b7b1-769fef3517d2	f672bd09-adb8-4097-9e2b-e45253c5281b	3.00	\N	8	middle_section	Svart
bf49db15-9a9d-4382-9552-4629c0fef234	f672bd09-adb8-4097-9e2b-e45253c5281b	6.00	\N	9	downpipe_clamp	Svart
98d281eb-27e2-4990-a9b0-1225b8f308e9	f672bd09-adb8-4097-9e2b-e45253c5281b	3.00	\N	10	leaf_strainer	Svart
9c8fcf7e-ba51-4b1b-aca9-813f62ec97aa	f672bd09-adb8-4097-9e2b-e45253c5281b	6.00	\N	11	pipe_angle	Svart
36007171-34d8-4505-8c18-bc1b725dbc4d	f672bd09-adb8-4097-9e2b-e45253c5281b	8.00	\N	12	windboard_22x170_4_8m	\N
5002a34e-ca8e-4e42-a020-c20765569266	f672bd09-adb8-4097-9e2b-e45253c5281b	4.00	\N	13	windboard_22x170_4_2m	\N
d0dbfe65-9eb3-4a68-a7c7-271f2be7755b	f672bd09-adb8-4097-9e2b-e45253c5281b	18.00	\N	14	windboard_metal	Svart
7c388647-164d-44b4-92a5-8c136bcf2914	f672bd09-adb8-4097-9e2b-e45253c5281b	9.00	\N	15	roof_ladder_step	Svart
e3433a15-368d-4120-b8c2-a1c4fa552dc2	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	16	snow_guard	Svart
f2c8be24-c734-48ea-9061-9b6d34125d7b	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	17	screws_55mm	\N
4326f481-725f-4bba-8e55-e5461c391d0a	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	18	metal_screws_33mm	\N
29c4730d-7207-4632-a589-20d26fa27a72	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	19	screws_42mm	\N
830350a3-3cd8-40ef-bd96-3ef630761f23	f672bd09-adb8-4097-9e2b-e45253c5281b	2.00	\N	20	wood_screws_30mm	\N
54fd0ba9-d11b-493e-b512-609d5d9f0130	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	21	screw_75_80mm	\N
7f92da0f-de43-45cf-9f06-6529c37e4534	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	22	farmers_screw	Svart
e2a016d1-877f-43df-8ffa-0a4b4dd970c0	f6853e26-bd43-45a7-8679-2d47a54b4aef	7.00	\N	0	gutter_6m	Svart
83e724fa-8ed8-456d-86d6-0350ff0512d0	f6853e26-bd43-45a7-8679-2d47a54b4aef	80.00	\N	1	gutter_hook	Svart
f7c55621-3e1a-4ddc-8f3b-c2aea0b87b7d	f6853e26-bd43-45a7-8679-2d47a54b4aef	6.00	\N	2	gutter_end	Svart
c2fb488a-8e4a-4efd-960a-8098e5c36a60	f6853e26-bd43-45a7-8679-2d47a54b4aef	8.00	\N	3	gutter_joint	Svart
862ddc6c-1a15-4bfe-aafc-53395a61557d	f6853e26-bd43-45a7-8679-2d47a54b4aef	1.00	\N	4	inner_gutter_angle	Svart
9fcd7990-2a00-44b5-bc11-1160c1a3ae3a	f6853e26-bd43-45a7-8679-2d47a54b4aef	5.00	\N	5	omvik	Svart
a3bd0f10-1f50-4fcf-a33d-3b7afaf1cbed	f6853e26-bd43-45a7-8679-2d47a54b4aef	5.00	\N	6	downpipe_2_5m	Svart
4993ed99-7c29-4f5e-8d28-f5e77ca5ec6a	f6853e26-bd43-45a7-8679-2d47a54b4aef	5.00	\N	7	middle_section	\N
4d24357f-2479-4fc3-9d12-88c7636437e7	f6853e26-bd43-45a7-8679-2d47a54b4aef	10.00	\N	8	downpipe_clamp	Svart
dcac2cdb-c398-4f27-addc-7d6f0b112834	f6853e26-bd43-45a7-8679-2d47a54b4aef	5.00	\N	9	leaf_strainer	Svart
7a0d8abc-3a16-4d43-852f-54faa3a78859	f6853e26-bd43-45a7-8679-2d47a54b4aef	10.00	\N	10	pipe_angle	Svart
e6e8644e-5e97-4e4e-9cb1-1db3efb0da3a	f6853e26-bd43-45a7-8679-2d47a54b4aef	12.00	\N	11	windboard_22x170_4_8m	\N
df38cbaf-95cc-480e-86e6-ba2454386595	f6853e26-bd43-45a7-8679-2d47a54b4aef	4.00	\N	12	windboard_22x170_4_2m	\N
b3bee36c-5cfe-439a-96a0-1a662185ef57	f6853e26-bd43-45a7-8679-2d47a54b4aef	22.00	\N	13	windboard_metal	Svart
e3025299-f2fa-4dc4-a538-9acff735632c	f6853e26-bd43-45a7-8679-2d47a54b4aef	11.00	\N	14	roof_ladder_step	Svart
994fd2ad-5427-4286-8987-efd9d05e05b2	f6853e26-bd43-45a7-8679-2d47a54b4aef	1.00	\N	15	snow_guard	Svart
a9e52f88-eabf-4dab-9a3a-f54c3cf05d6e	f6853e26-bd43-45a7-8679-2d47a54b4aef	2.00	\N	16	pistol_nails	\N
c7c9aae3-30e1-4fb7-a442-7dc919c2c890	f6853e26-bd43-45a7-8679-2d47a54b4aef	2.00	\N	17	screws_55mm	\N
a7931b19-8ee8-4c1b-94af-c75f884a9ab2	f672bd09-adb8-4097-9e2b-e45253c5281b	2.00	\N	23	clips	\N
03ce6eb6-4cf2-4cf1-b92f-dad8f9720c53	f6853e26-bd43-45a7-8679-2d47a54b4aef	2.00	\N	18	metal_screws_33mm	\N
f0a411a9-a4bb-4352-a171-b6524fb46cff	f6853e26-bd43-45a7-8679-2d47a54b4aef	4.00	\N	19	wood_screws_30mm	\N
d4030554-1d5f-48d0-bd5b-13de5f31a7e1	f6853e26-bd43-45a7-8679-2d47a54b4aef	28.00	\N	20	ridge_band	Monier svart Dryroll
8fa815b4-8ca0-4141-8f02-f933d8a2560d	f6853e26-bd43-45a7-8679-2d47a54b4aef	40.00	\N	21	bird_band	\N
2e6d975f-7772-4339-b714-f93c15705e78	f6853e26-bd43-45a7-8679-2d47a54b4aef	25.00	\N	22	eave_flashing_2m	Svart
283c60ef-f71b-4c09-8b4f-3f3583118ce3	f6853e26-bd43-45a7-8679-2d47a54b4aef	8.00	\N	23	batten_12x50	\N
c1ce7537-6142-4b3f-a6fc-90080347e4aa	f6853e26-bd43-45a7-8679-2d47a54b4aef	10.00	\N	24	triangle_batten	\N
58417d23-fc18-4984-90a0-82ca3d9160d7	f6853e26-bd43-45a7-8679-2d47a54b4aef	8.00	\N	25	rafter_45x45_3_6m	\N
4a215f6b-8a0f-4d3d-a9b1-13a54060a123	f6853e26-bd43-45a7-8679-2d47a54b4aef	3.00	\N	26	trash_bags	\N
638f1b4c-6f2f-4c99-b1e7-aa0698cd7abb	f672bd09-adb8-4097-9e2b-e45253c5281b	25.00	\N	24	ridge_band	Monier mörkgrå
c4a1a15a-6404-4a87-a415-8273eaa0eb34	f672bd09-adb8-4097-9e2b-e45253c5281b	30.00	\N	25	bird_band	\N
2170e281-54d7-43a3-8516-26e39301efbd	f672bd09-adb8-4097-9e2b-e45253c5281b	21.00	\N	26	eave_flashing_2m	Svart
117180d7-dbee-4ea1-bb1c-3c6681ecf508	f672bd09-adb8-4097-9e2b-e45253c5281b	10.00	\N	27	batten_12x50	\N
9fc69e51-f993-4df6-bfc5-0711d137ede9	f672bd09-adb8-4097-9e2b-e45253c5281b	3.00	\N	28	trash_bags	\N
079fe6ba-d8fa-4a89-b22b-1818866b1516	f672bd09-adb8-4097-9e2b-e45253c5281b	1.00	\N	29	paint	Vit 5l
3dbf27d4-316d-47c5-9e30-b33bdffd0fd6	f672bd09-adb8-4097-9e2b-e45253c5281b	2.00	\N	30	tape	\N
4d346de6-a357-49c5-a776-02589230aadf	b99ca394-39ba-444a-a6da-3bfeabe29b52	6.00	\N	0	gutter_6m	Vit
51c62dd0-9ab3-4e51-8734-d5f44b35ec4e	b99ca394-39ba-444a-a6da-3bfeabe29b52	60.00	\N	1	gutter_hook	Vit
6173dae1-fcbf-4b9d-81dc-91f192fe684a	b99ca394-39ba-444a-a6da-3bfeabe29b52	4.00	\N	2	gutter_end	Vit
5a4f30dd-58de-4966-9fa9-c284496ad8d3	b99ca394-39ba-444a-a6da-3bfeabe29b52	4.00	\N	3	gutter_joint	Vit
2ffd51d6-b817-429d-b717-7c8d2db95ec8	b99ca394-39ba-444a-a6da-3bfeabe29b52	2.00	\N	4	omvik	Vit
7fa748b7-7619-467c-b80b-47e3288276f2	b99ca394-39ba-444a-a6da-3bfeabe29b52	2.00	\N	5	downpipe_3m	Vit
4b96786f-c0e0-4258-b8d6-5a83d03b8a2a	b99ca394-39ba-444a-a6da-3bfeabe29b52	4.00	\N	6	downpipe_clamp	Vit
9270c3c8-0bb1-4194-9942-41b03a89d41b	b99ca394-39ba-444a-a6da-3bfeabe29b52	2.00	\N	7	leaf_strainer	Vit
7001d04f-6032-4928-ba2c-2f73de686055	b99ca394-39ba-444a-a6da-3bfeabe29b52	4.00	\N	8	pipe_angle	Vit
610708da-3f10-4381-baa0-a24911e48390	b99ca394-39ba-444a-a6da-3bfeabe29b52	8.00	\N	9	windboard_22x170_3_6m	22x170  3.6m
dd9ababa-5c59-456d-bb60-e24739f07ef3	b99ca394-39ba-444a-a6da-3bfeabe29b52	8.00	\N	10	windboard_22x170_4_2m	22x170 4.8m
c28f342b-c218-44f1-b6f4-5172984581c5	b99ca394-39ba-444a-a6da-3bfeabe29b52	13.00	\N	11	windboard_metal	Vit
7ae7e2dd-911f-4c8e-bd23-8f7c7a6e1816	b99ca394-39ba-444a-a6da-3bfeabe29b52	18.00	\N	12	roof_ladder_step	Svart
aebc495e-e2c3-44f8-9fde-85d02ac1ce7b	b99ca394-39ba-444a-a6da-3bfeabe29b52	1.00	\N	13	snow_guard	Svart
69de8238-7ccb-4b31-91d2-177ea23d8e77	b99ca394-39ba-444a-a6da-3bfeabe29b52	2.00	\N	14	silicone	\N
317ef443-611e-490a-a8df-862e223ee910	b99ca394-39ba-444a-a6da-3bfeabe29b52	1.00	\N	15	screws_55mm	\N
0ebc1d36-f4c0-4a84-8048-a70c382e7b6f	b99ca394-39ba-444a-a6da-3bfeabe29b52	1.00	\N	16	metal_screws_33mm	\N
4c2fb9bd-c113-4ef9-823e-d5fa18392829	b99ca394-39ba-444a-a6da-3bfeabe29b52	17.00	\N	17	ridge_band	Randers Gul
595ca8fe-cb03-4131-bd83-aec02893e8b9	b99ca394-39ba-444a-a6da-3bfeabe29b52	35.00	\N	18	bird_band	\N
1057f92b-9d5f-4137-bcbc-a6b589f35150	b99ca394-39ba-444a-a6da-3bfeabe29b52	18.00	\N	19	eave_flashing_2m	Vit
dd376d5d-d0e0-4241-b5c6-1f0e19c16ead	b99ca394-39ba-444a-a6da-3bfeabe29b52	6.00	\N	20	batten_12x50	\N
2f67aadf-5898-436a-ac33-0317618a58cd	b99ca394-39ba-444a-a6da-3bfeabe29b52	5.00	\N	21	rafter_45x45_3_6m	\N
77732a1d-66a2-4a7c-bd69-f7ee4827ed64	b99ca394-39ba-444a-a6da-3bfeabe29b52	2.00	\N	22	trash_bags	\N
f1505847-18bf-4054-8c1a-a3b78d58b262	b99ca394-39ba-444a-a6da-3bfeabe29b52	1.00	\N	23	tape	\N
13053e1d-e542-4bf1-bc91-d3c1b436cc6a	66ecbe97-04f7-46e5-b2fc-0606da8e6434	5.00	\N	0	gutter_6m	Svart
cfa3a728-422d-44c2-a7dd-20e05f9bcd8b	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	1	gutter_3m	Svart
f6a1a3b5-1966-4487-93c6-b8d4dc92a7a9	66ecbe97-04f7-46e5-b2fc-0606da8e6434	56.00	\N	2	gutter_hook	Svart
1c6cffcf-1d97-4bc7-b4d9-8d06a2a00be1	66ecbe97-04f7-46e5-b2fc-0606da8e6434	6.00	\N	3	gutter_end	Svart
7f9de2e3-1061-48e2-b9e4-0e8857963334	66ecbe97-04f7-46e5-b2fc-0606da8e6434	4.00	\N	4	gutter_joint	Svart
3e939809-c32b-4478-9086-8bed738814fe	66ecbe97-04f7-46e5-b2fc-0606da8e6434	3.00	\N	5	omvik	Svart
2858604e-167e-4291-b5d1-768a49e85139	66ecbe97-04f7-46e5-b2fc-0606da8e6434	3.00	\N	6	downpipe_2_5m	Vit
7ed140d3-e8ae-4a0c-9c68-7a9738cedb40	66ecbe97-04f7-46e5-b2fc-0606da8e6434	6.00	\N	7	downpipe_clamp	4 Vit 2 svart
b4119b45-167b-4f76-afa6-e3669e8db607	66ecbe97-04f7-46e5-b2fc-0606da8e6434	2.00	\N	8	leaf_strainer	Vit
b598ca43-da7a-4944-8b17-c7ee3e1a093c	66ecbe97-04f7-46e5-b2fc-0606da8e6434	6.00	\N	9	pipe_angle	4 vit 2 svart
74de32ea-9959-473e-95ae-2470c10aff03	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	10	outlet	Svart
9543d595-3157-4124-ba38-b3c67316db79	66ecbe97-04f7-46e5-b2fc-0606da8e6434	18.00	\N	11	windboard_metal	Svart
7a87cb2a-efde-4dc2-a555-58aad74acbac	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	12	metal_screws_33mm	\N
5cfeba56-f40e-49b3-95af-b27ed8152bd0	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	13	wood_screws_30mm	\N
1d4325ce-d8c5-4cb3-8db9-8ce9cf2b397a	66ecbe97-04f7-46e5-b2fc-0606da8e6434	2.00	\N	14	clips	\N
1ffc091e-7028-4121-b180-21075d9b3a1c	66ecbe97-04f7-46e5-b2fc-0606da8e6434	13.00	\N	15	ridge_band	Dryroll svart Monier
cceff8f4-0d5f-4d04-a4d0-191d1667bca9	66ecbe97-04f7-46e5-b2fc-0606da8e6434	30.00	\N	16	bird_band	\N
c10b5c2f-783a-4c71-83f7-c5c96d2ae1e6	66ecbe97-04f7-46e5-b2fc-0606da8e6434	16.00	\N	17	eave_flashing_2m	Svart
00e5036a-4a40-4c2f-9da6-fe1d54ffa090	66ecbe97-04f7-46e5-b2fc-0606da8e6434	2.00	\N	18	trash_bags	\N
c2a24f77-cc2a-4647-93d2-87f9a48f6aaf	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	19	paint	Vit
8e5c8253-eb61-4837-a773-e5c51f3f14ad	66ecbe97-04f7-46e5-b2fc-0606da8e6434	1.00	\N	20	tape	\N
\.


--
-- Data for Name: project_materials; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_materials (id, "projectId", title, other, "createdAt", "updatedAt") FROM stdin;
2700df6c-a28f-427d-aa31-29fa4c2dff23	7ff6c67c-a436-402a-aa4e-a080d8dc21df	\N	Trappstege 4.7m x 2.5m tegelröd	2026-09-03 05:53:47.650336	2026-09-03 05:53:47.650336
57e22227-28ec-4ded-af11-ca318ea53423	ac5d737c-2421-48f2-8e01-e3c4ee638738	\N		2026-09-08 05:59:58.63009	2026-09-08 05:59:58.63009
b99ca394-39ba-444a-a6da-3bfeabe29b52	678c86c5-32e7-4026-95b4-8e6bc404beb3	\N	Takfönster 78x120 5st, 78x180 1st antracitgrå	2026-09-15 05:49:58.884761	2026-09-15 06:34:20.421342
bdc80476-516a-4ab6-805a-18be83b7695a	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	2026-08-23 19:55:57.759155	2026-09-18 17:57:27.507535
f6853e26-bd43-45a7-8679-2d47a54b4aef	d83c0440-0d14-41ac-965a-7155f13d6713	\N	Rendalbeslag 7 st svart	2026-09-23 05:18:12.602228	2026-09-23 05:47:17.919079
66ecbe97-04f7-46e5-b2fc-0606da8e6434	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	\N	\N	2026-10-05 05:45:39.330482	2026-10-05 06:30:23.689421
f672bd09-adb8-4097-9e2b-e45253c5281b	d5ba2856-4921-4854-948d-0482c8d79d2a	\N	\N	2026-10-12 05:39:52.150391	2026-10-12 05:51:41.421217
\.


--
-- Data for Name: project_receipts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_receipts (id, url, "publicId", "projectId", description, amount, "createdAt") FROM stdin;
57840b64-5586-459a-bb76-95316f70eda2	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785074791/projects/5c5918d7-0a51-4733-932b-55b35ea538d3/receipts/ei6ccrtokzs1wks5xf3n.jpg	projects/5c5918d7-0a51-4733-932b-55b35ea538d3/receipts/ei6ccrtokzs1wks5xf3n	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	2026-07-26 14:06:33.380224
7bfdf4a8-e792-4174-b25b-4bc23b2ed3fb	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1785859349/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/iigbgmmdasjprwnicymy.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/iigbgmmdasjprwnicymy	bbffade8-2151-4c8d-bb24-df1b0d515203	\N	\N	2026-08-04 16:02:30.378532
a3180d75-774a-4e32-b331-72739f35ce1c	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788544676/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/receipts/mofhgewf1ubfhsxnie2b.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/receipts/mofhgewf1ubfhsxnie2b	7ff6c67c-a436-402a-aa4e-a080d8dc21df	\N	\N	2026-09-04 17:57:58.23705
3283cdd9-cdaa-4c8a-b23b-915ddcd2ac4f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788544677/projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/receipts/awgesrbq431lw8erlffw.jpg	projects/7ff6c67c-a436-402a-aa4e-a080d8dc21df/receipts/awgesrbq431lw8erlffw	7ff6c67c-a436-402a-aa4e-a080d8dc21df	\N	\N	2026-09-04 17:57:58.422776
5d073e81-60b2-4627-bb7a-aa3d04581f9a	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788958358/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/r1bmgjyyvwm0evkirpfk.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/r1bmgjyyvwm0evkirpfk	bbffade8-2151-4c8d-bb24-df1b0d515203	\N	\N	2026-09-09 12:52:39.881535
149244f1-3a4c-45b2-bd04-2a4ed6ab9e01	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788958358/projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/xjkdgfeqjip2tzeczrw5.jpg	projects/bbffade8-2151-4c8d-bb24-df1b0d515203/receipts/xjkdgfeqjip2tzeczrw5	bbffade8-2151-4c8d-bb24-df1b0d515203	\N	\N	2026-09-09 12:52:40.041283
216ec69e-9e62-42d0-ac3b-b1d6d59f4be7	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1788958378/projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/receipts/dwrihuzyod031bg5n7el.jpg	projects/ac5d737c-2421-48f2-8e01-e3c4ee638738/receipts/dwrihuzyod031bg5n7el	ac5d737c-2421-48f2-8e01-e3c4ee638738	\N	\N	2026-09-09 12:52:59.125225
5dd7bdcd-75f9-4a1c-b2a1-205510597f33	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1789585273/projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/receipts/dpb65k11pv6fl0hxoeof.jpg	projects/678c86c5-32e7-4026-95b4-8e6bc404beb3/receipts/dpb65k11pv6fl0hxoeof	678c86c5-32e7-4026-95b4-8e6bc404beb3	\N	\N	2026-09-16 19:01:15.570502
664d62d7-0c3c-43a5-8fc3-b64695b7632f	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1790359010/projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/wfh1xls9fo7jogfnmgk0.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/wfh1xls9fo7jogfnmgk0	d83c0440-0d14-41ac-965a-7155f13d6713	\N	\N	2026-09-25 17:56:51.143359
a0100afa-4b31-444e-9d23-d3c309fe8abf	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791197443/projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/receipts/d5repsd3d4zpgw5j97kq.jpg	projects/8fd932a5-3dc1-4bf3-802f-e5285789d8d6/receipts/d5repsd3d4zpgw5j97kq	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	\N	\N	2026-10-05 10:50:44.996632
9c5b94d6-ee6b-404a-8b32-a2f699d62dfe	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791197469/projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/dql8oycrjiedzxrdwwmg.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/dql8oycrjiedzxrdwwmg	d83c0440-0d14-41ac-965a-7155f13d6713	\N	\N	2026-10-05 10:51:11.045837
b2371c2a-21e4-457b-a611-031ccc16c700	https://res.cloudinary.com/ddbvtwaf6/image/upload/v1791221361/projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/rvanwrtgaxe84avyu8v3.jpg	projects/d83c0440-0d14-41ac-965a-7155f13d6713/receipts/rvanwrtgaxe84avyu8v3	d83c0440-0d14-41ac-965a-7155f13d6713	\N	\N	2026-10-05 17:29:22.81124
\.


--
-- Data for Name: project_task; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.project_task (id, title, done, "completedByName", "createdAt", "completedAt", comment, "projectId", "completedById", "photoUrls", note, "attentionNote") FROM stdin;
7f990fab-2722-400f-9167-6630fbd4c6f1	Montering av vindskivebeslag	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	Mörkröd, fabrikstillverkade plåtdetaljer från Plannja, Lindab, Icopal eller andra tillverkare med motsvarande kvalitet	\N
b6ab28c9-29f8-48f4-b15e-3cdb7378d274	Leverans av takpannor med kranbil	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	\N	\N
5db743bf-d918-4215-af0b-bedaf7482085	Montering av tak- samt nockpannor	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	Randers RT823, Naturröd	Infästning av tak- samt nockpannor
8f577d38-f936-4850-a2ab-494f0049d995	Montering av nockband	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	Randers, Tegelröd	\N
37c3af4c-17f9-4066-8f58-4bf7edb5efe8	Montering av avloppsluftare	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	1 styck, Randers, Tegelröd	\N
647daf9d-34aa-45ca-a8e3-2127c1838d0b	Montering av bärläktsteg samt glidskydd	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	1 uppsättning, Mörkröd	\N
49b03e3c-e29d-4aa7-aea8-d45b89931938	Tillverkning och montering av plåtbeslag för ventilationsaggregat	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	Mörkröd, nedre plåtdetalj	\N
54c2e68b-7775-45a9-9891-50a6651f3f35	Målning av vindskivor	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	Vit	\N
892c2ab3-fa6b-4ea3-b803-4c0fbcac1eb2	Diverse övriga förbrukningsmaterial för infästning och tätning	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	\N	Avseende arbetet
94bc30f8-d41b-4473-b6fb-2e81b8f24e1d	Avetablering	f	\N	2026-06-07 20:07:10.610624	\N	\N	5c5918d7-0a51-4733-932b-55b35ea538d3	\N	\N	\N	Demontering av byggställning, bortforsling av byggställning samt eventuellt material etc, slutstädning
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.projects (id, city, address, "createdAt", "pricePerM2", "areaM2", "pricePerExtraH") FROM stdin;
f7e03ed8-6869-4d86-8ced-004a62355f04	Övrigt	Home	2026-01-06 13:43:08.644657	\N	\N	\N
54629585-9337-4f55-8977-036ff89a2e2b	Falsterbro	Päronträdsvägen 1B	2026-01-10 14:57:06.228436	\N	\N	\N
ac4896b2-f0c4-4da1-a604-5213681e663e	Kågeröd	Knutstorpsvägen 23	2026-01-15 07:33:22.25464	\N	\N	\N
f36437da-0d4c-4db0-9e26-1bbc83e02c10	Höllviken	Norra skogsvägen 12	2026-01-26 06:24:54.859047	\N	\N	\N
019b62fd-0697-454b-baed-ded26eba74a9	Höllviken	Västra Lärkvägen 5	2026-02-02 13:04:40.194417	\N	\N	\N
284d06c0-f938-40ae-8ef1-aa1d3e354eb9	Bunkeflostrand	Ängsdalsvägen 51	2026-02-23 15:03:44.053213	\N	\N	\N
f40904f2-dc04-4c56-8c6b-259d63237a2b	Limhamn	Slamstensgatan 53	2026-03-03 10:27:12.106732	\N	\N	\N
1518522b-892b-47ef-afe6-b56caa69af4c	Oxie	Anders Orkans Väg 37	2026-03-20 11:01:54.425872	\N	\N	\N
9c5b8aea-784b-4166-80f9-f26b8c6799f0	Staffanstorp	Vallby Byväg 38-11	2026-03-23 15:43:36.429634	\N	\N	\N
cef60249-2727-476e-bd94-4d3e9dd03916	Saxtorp	Någorlundavägen 16	2026-04-13 11:32:15.249509	\N	\N	\N
5c5918d7-0a51-4733-932b-55b35ea538d3	test	test	2026-01-06 14:59:32.801525	350	10	\N
f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	Malmö	Sagoliden 3	2026-04-28 18:30:03.080731	500	140	350
4813a930-e772-4adf-85d8-0448d373f829	Limhamn	Rabygatan 13A-B	2026-05-15 12:18:11.918847	400	290	350
6cfb6350-300e-4727-82c2-96cd431e9425	Dalby	Kommendervägen 2	2026-06-08 04:25:15.331343	400	180.5	\N
d949002a-7479-4680-b874-f55ea62f594f	Staffanstorp	Merkuriusvägen 3	2026-06-15 13:17:50.844153	500	170.5	350
1238abd9-6257-47ca-bfff-fba910c6c953	Vellinge	Möllegårdsvägen 10-0	2026-07-01 09:25:30.336784	450	130	350
bbffade8-2151-4c8d-bb24-df1b0d515203	Höör	Havrevägen 9	2026-07-16 14:20:13.403032	600	160	350
8ba316b3-e1e3-4673-b340-be2f65bf9ce2	Falsterbo 	Norra tvärgatan 2	2026-03-23 11:48:46.787205	400	200	350
ac5d737c-2421-48f2-8e01-e3c4ee638738	Löddeköpinge	Odlarevägen 68	2026-09-07 05:33:55.900896	500	200	350
678c86c5-32e7-4026-95b4-8e6bc404beb3	Anderslöv	Landsvägen 2177	2026-09-14 18:44:36.194873	400	195	350
d83c0440-0d14-41ac-965a-7155f13d6713	Veberöd	Spireavägen 20	2026-09-19 19:17:22.094105	500	258	350
e0a08b6f-1955-4fc6-8047-018b57651357	Leon	Leon	2026-09-29 14:41:20.342424	\N	\N	500
8fd932a5-3dc1-4bf3-802f-e5285789d8d6	Skanör	Sven Målares gränd 7	2026-10-04 19:12:10.599879	\N	\N	350
7ff6c67c-a436-402a-aa4e-a080d8dc21df	Malmö 	Krageholmsgatan 12, 216 19	2026-08-06 14:19:51.568678	550	170	350
d5ba2856-4921-4854-948d-0482c8d79d2a	Bara	Duvgatan 1	2026-10-12 05:35:40.417065	400	180	350
\.


--
-- Data for Name: registration_approvals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.registration_approvals (id, "userId", "tokenHash", status, "expiresAt", "usedAt", "createdAt", "updatedAt", email, name, "passwordHash") FROM stdin;
b14d6864-e002-4563-a689-2c072700599e	\N	b2df8074737fb7f454aa44f1896b3f5d8ea39daa6633336a3d641a9056ab5801	rejected	2026-10-08 17:54:06.153+00	2026-10-09 19:32:38.948+00	2026-10-07 17:54:06.233152+00	2026-10-09 19:32:39.026892+00	test4@gmail.com	test	$2b$10$GG3n4fOL188IYbqOO39JaOzUnEw4coVwRzSGkYRj2iawZU9ueMvKG
6944d386-dc67-44ff-b2dd-cbd94918b143	\N	a9ddadee617b12b87135e6d14e153e363f7849bc2c2ffc8fbc4802ba4a8e56a8	rejected	2026-10-10 19:32:39.115+00	2026-10-09 20:12:49.766+00	2026-10-09 19:32:39.194265+00	2026-10-09 20:12:49.83938+00	test4@gmail.com	test	$2b$10$bZlb3UDZhc.QHPbYWtmK.uTwUA92eG3viqIMIEnZ7KVhNbwZioryi
4c277265-0983-4db5-b7cf-4cb624ebd41e	\N	53d574bc940dd7f646843173422f726534cc4a4356a7e4161505316ef3a49e4c	rejected	2026-10-10 20:12:49.924+00	2026-10-10 14:49:07.852+00	2026-10-09 20:12:49.996796+00	2026-10-10 14:49:07.924509+00	test4@gmail.com	test	$2b$10$dNQ26rpOCQyO8UA8xUBKhuOHWHtPub2wC0oTl4BxGybKIMVLfmgIW
3a209ed1-2175-451c-8a88-e3f257ae1a6f	\N	20055869430ee42555bb9408d40d4fd19c7cbfff752c9563b046c177545c26e6	rejected	2026-10-11 14:49:08.006+00	2026-10-10 15:16:28.246+00	2026-10-10 14:49:08.078862+00	2026-10-10 15:16:28.32519+00	test4@gmail.com	test	$2b$10$4yXFeqxN56j20ctx5HtfdOZXWoh1I1GYAC83aPelMJlQ/GWuv01tm
8de4cf3d-9181-4678-b99d-d9e1898a80a9	\N	4839138c876dbd126bb0451691a402ae4c4a7071b6ed9e448ffd8d9c4028e7af	rejected	2026-10-11 15:16:28.459+00	2026-10-10 15:21:04.877+00	2026-10-10 15:16:28.538572+00	2026-10-10 15:21:04.95615+00	test4@gmail.com	test	$2b$10$VMmHJQZ4g.K/0CMJlNh1feCBVdoPShcoB8YAz7HmWPHwXgtzqGfL.
6136522c-95ad-4df9-a2dc-414db991473f	\N	985c821dd29b885834ef9d945300ef2ca928b9f5de2f0b9c741c0249e2c1a2c1	rejected	2026-10-11 15:21:05.035+00	2026-10-10 15:42:01.219+00	2026-10-10 15:21:05.113561+00	2026-10-10 15:42:01.296365+00	test4@gmail.com	test	$2b$10$VG2cB5RT7YcUnrGLocRe9.bDD8P03JvDPUuK4LEsB14EDxTfDbUra
c6fd44ac-08f2-40e6-b967-5b8b1cc57088	\N	d54808a3f690e02cf3dda141289567ac25363a8926870fd57bb026e467ccc8d3	rejected	2026-10-11 15:42:01.38+00	2026-10-10 15:50:22.338+00	2026-10-10 15:42:01.456714+00	2026-10-10 15:50:22.408946+00	test4@gmail.com	test	$2b$10$wZFVf5ESTqjsmlabzyW/Ze/3uJ4LzB8Ri5OVgomB6ZTWxLkPcGGA2
90cc0255-d22f-4a5e-afc3-7151c53cead9	2aa46110-2419-4565-a490-a0c409e2c196	083099798718ffa1258fd6e05c740d0c222efa542b9427146f6abaa907319044	approved	2026-10-11 15:50:22.492+00	2026-10-10 15:50:49.319+00	2026-10-10 15:50:22.565249+00	2026-10-10 15:50:48.808527+00	test4@gmail.com	test	$2b$10$zSCE5Qv0C0MPebbt.asmAe9JNWM9IH1WS8mEFddA/vkMspa/l6JvO
afb2e5e2-56fa-4016-b06d-967b5743a991	3c9a9690-0e31-46bb-a12f-ee4a182f1986	7d87a457f96c90c26a69417a6fbbba77cb3334918def1283bd8bb53d05006836	approved	2026-10-12 16:48:27.73+00	2026-10-11 16:49:23.441+00	2026-10-11 16:48:27.741313+00	2026-10-11 16:49:22.884564+00	test5@gmail.com	Test	$2b$10$dQXdcHRPGf4cl9o1nldaFuPzdGja2uKlooUAu05XFbQgyZrxjRkya
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.sessions (token, refresh_token, created_at, "lastActivityAt", expires_at, "userId", id, access_token_expires_at, refresh_token_expires_at) FROM stdin;
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMzAwYzRiYi1mMWNmLTQyODAtOGM5MC0xMjI0YzI5OTUyYjIiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwiaWF0IjoxNzkxNTc0ODMxLCJleHAiOjE3OTE1NzY2MzF9.OQiLTOqLujmFp-7-V29j50nPV-i0pQFtqL-wgeDJ-Jo	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMzAwYzRiYi1mMWNmLTQyODAtOGM5MC0xMjI0YzI5OTUyYjIiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwiaWF0IjoxNzkxMzk1NzU2LCJleHAiOjE3OTM5ODc3NTZ9.pCvWysHcQCKZFCUG2amwMqw_LxMskxzxpY1fTa0jpYU	2026-10-07 17:55:56.312707	2026-10-09 19:40:31.461	2026-10-07 17:55:56.312707	1300c4bb-f1cf-4280-8c90-1224c29952b2	68d7e6bd-5436-41e9-a842-eff9bc256e3b	2026-10-09 20:10:31	2026-11-06 17:55:56
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MDg0NDMwMCwiZXhwIjoxNzkxMDE3MTAwfQ.UJhk9nCPWX2v_903vOaVQMfKaa-612HMtMz8oCXB-4Q	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MDc5NzcwNywiZXhwIjoxNzkzMzg5NzA3fQ.XA9Qhdzc6yf3Hh6_PjPqGBDkVC9FDxglaKHHG0e7nJo	2026-09-30 19:48:27.013809	2026-10-01 08:45:00.634	2026-10-03 08:45:00	7dafa412-ec37-4c54-b149-1bd406b66a3a	01a0ba25-86cc-484e-95dc-3c6314fbde25	\N	\N
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyY2FlNjI1Yy1kMGE5LTQ5NTktOTA4OS0yY2RiM2JkZmQ3Y2MiLCJlbWFpbCI6ImRvYnJ5eXJ1c2xhbkB1a3IubmV0IiwiaWF0IjoxNzkxNzU5MTY3LCJleHAiOjE3OTE3NjA5Njd9.Sved6hf5jiSUGrIwKqutNgP6SYMGNQdulHjaDL3fv54	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyY2FlNjI1Yy1kMGE5LTQ5NTktOTA4OS0yY2RiM2JkZmQ3Y2MiLCJlbWFpbCI6ImRvYnJ5eXJ1c2xhbkB1a3IubmV0IiwiaWF0IjoxNzkwMzM3NTg4LCJleHAiOjE3OTI5Mjk1ODh9.HeNBpWoogYBgJzWp-4EHlfCh2Wq7QF8WOF6KrG4otRk	2026-09-25 11:59:48.827653	2026-10-11 22:58:15.059	2026-09-25 11:59:48.827653	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	865e980a-90ad-401d-b076-84a71dfec4ab	2026-10-11 23:22:47	2026-10-25 11:59:48
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3M2UxMjM0Ny04NGNlLTQ1OTQtODA3OS02YWQyNjU3ZWVkNzYiLCJlbWFpbCI6Imt1bmdlbkBnbWFpbC5jb20iLCJpYXQiOjE3OTA4NTQyMzgsImV4cCI6MTc5MDg1NjAzOH0.7-o2o1xq_9AnM8Kvj9RHamIQ8cBXuZGvC6nV0x8gDKw	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3M2UxMjM0Ny04NGNlLTQ1OTQtODA3OS02YWQyNjU3ZWVkNzYiLCJlbWFpbCI6Imt1bmdlbkBnbWFpbC5jb20iLCJpYXQiOjE3OTA4NTQyMzgsImV4cCI6MTc5MzQ0NjIzOH0.6F-RBjMsoYPyaA9NJCHTfdPvgpNAZnBYFHxt5ywTzKg	2026-10-01 11:30:38.04133	2026-10-01 11:30:38.027	2026-10-01 11:30:38.04133	73e12347-84ce-4594-8079-6ad2657eed76	44dae8c2-2c54-4442-a916-bdbdbe9c8bdb	2026-10-01 12:00:38	2026-10-31 11:30:38
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MTgwMzg2NSwiZXhwIjoxNzkxODA1NjY1fQ.HFOKS6A02W8fwp0py5PxmfxrdUeiTj1HsPSlSSDUzXo	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MDU3MzkwMywiZXhwIjoxNzkzMTY1OTAzfQ.7ksD0ZROtNnqW3_3_znz8NnJdhXJPau0wJvBmjCipVc	2026-09-28 05:38:23.52038	2026-10-12 11:17:45.373	2026-09-28 05:38:23.52038	7dafa412-ec37-4c54-b149-1bd406b66a3a	8fcf36b5-340d-46d7-99cf-c8fa0180d092	2026-10-12 11:47:45	2026-10-28 05:38:23
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3M2UxMjM0Ny04NGNlLTQ1OTQtODA3OS02YWQyNjU3ZWVkNzYiLCJlbWFpbCI6Imt1bmdlbkBnbWFpbC5jb20iLCJpYXQiOjE3OTA4OTI2MzQsImV4cCI6MTc5MDg5NDQzNH0.thk0N7_g2B3ol6YE7A1ZxxvCzfY1NAIyUDcJMcxy3qM	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3M2UxMjM0Ny04NGNlLTQ1OTQtODA3OS02YWQyNjU3ZWVkNzYiLCJlbWFpbCI6Imt1bmdlbkBnbWFpbC5jb20iLCJpYXQiOjE3OTA4NTQyNTAsImV4cCI6MTc5MzQ0NjI1MH0.KMOkm5r_PIIYZwkvpZl4Dzl-oFMH2hzeDIYElkahOJw	2026-10-01 11:30:50.206286	2026-10-01 22:10:34.815	2026-10-01 11:30:50.206286	73e12347-84ce-4594-8079-6ad2657eed76	2df7b6fd-992f-4e31-aaeb-d47aa517f53f	2026-10-01 22:40:34	2026-10-31 11:30:50
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MDY4Njg4NCwiZXhwIjoxNzkwODU5Njg0fQ.CYHtf1tYDmvCZEHuOXhGnQCTFemNnUFD2YLOC2VB5WU	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MDU4Njc5MiwiZXhwIjoxNzkzMTc4NzkyfQ.caSEqywxIqHBNhAzhwXI6QSW6xx6lW_NuzPFnuvw_cA	2026-09-28 09:13:12.105918	2026-09-29 13:01:24.072	2026-10-01 13:01:24	7dafa412-ec37-4c54-b149-1bd406b66a3a	d640f3d9-2094-4d74-bc91-9acc3d6d9995	\N	\N
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MTUzNDIxNywiZXhwIjoxNzkxNzA3MDE3fQ.RO_euhJxsaIsXtTVK8sGwxmdSPPIPYt-1bwTmpD1Qwo	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MTUzMjY2MCwiZXhwIjoxNzk0MTI0NjYwfQ.iPHs9MI59GQ-GdVLPAhCIcWYkxal4WdCn9n1WMZ07kw	2026-10-09 07:57:40.334655	2026-10-09 08:23:37.813	2026-10-11 08:23:37	7dafa412-ec37-4c54-b149-1bd406b66a3a	17398e5c-f4ee-4a24-abcc-d996ff364ba6	\N	\N
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMzAwYzRiYi1mMWNmLTQyODAtOGM5MC0xMjI0YzI5OTUyYjIiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwiaWF0IjoxNzkxODAzNzMyLCJleHAiOjE3OTE4MDU1MzJ9.uITknECpvT9XRjAatBzoTmqK7Lg_9F_AgIFvpvZgH4Q	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMzAwYzRiYi1mMWNmLTQyODAtOGM5MC0xMjI0YzI5OTUyYjIiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwiaWF0IjoxNzkxNzgzMzA2LCJleHAiOjE3OTQzNzUzMDZ9.wZauV_uBqARYWnY0wtyWv8-hx_FeCLLkVVMawsfxhmg	2026-10-12 05:35:06.200491	2026-10-12 11:15:32.874	2026-10-12 05:35:06.200491	1300c4bb-f1cf-4280-8c90-1224c29952b2	0b5fb794-d123-49d3-ab50-b87a41e6da12	2026-10-12 11:45:32	2026-11-11 05:35:06
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MTgwNjM1OCwiZXhwIjoxNzkxOTc5MTU4fQ.dIC9aYBD9vg3LQfnUHSzysrUP2fhnDDirE5QoRRJDos	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3ZGFmYTQxMi1lYzM3LTRjNTQtYjE0OS0xYmQ0MDZiNjZhM2EiLCJlbWFpbCI6ImdyemVnb3J6QGdtYWlsLmNvbSIsImlhdCI6MTc5MTgwNTE2MiwiZXhwIjoxNzk0Mzk3MTYyfQ.gQ3BicqKZ7-LXsuyDrkTesR3_QiWlLIYUuA6gbVcp0I	2026-10-12 11:39:22.420354	2026-10-12 11:59:18.327	2026-10-14 11:59:18	7dafa412-ec37-4c54-b149-1bd406b66a3a	df36fa76-4b91-43c8-b55c-73d70a2ebf6e	\N	\N
\.


--
-- Data for Name: time_entries; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.time_entries (id, date, hours, type, comment, "userId", "projectId", "breakMinutes", "startTime", "endTime") FROM stdin;
6f6e3acf-73e5-468f-b3a2-248f23eff16d	2026-01-09	8.00	WORK	Ränna	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
fec0f2c9-98b1-44da-b5f4-cfcd36c56091	2026-01-08	7.00	WORK	z-panel, paint?, prepare for ränna hooks	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	60	08:30:00	16:30:00
f2525cb3-233e-44ea-988a-a5e344e254d0	2026-01-12	7.50	WORK	futplot, ränna, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	30	08:30:00	16:30:00
2bde548c-867b-45ee-a438-abeca184aa1a	2026-01-07	8.00	WORK	test	3dd3a93a-b2d1-4233-8c09-4ed27f121040	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
1e470673-5b3d-4c89-b884-3053c5ad104b	2026-01-13	5.00	WORK	Fotplåt, prepare work for Marek	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	08:00:00	13:00:00
10132bac-51ab-46e5-95b9-19c0a1dc96f4	2026-03-10	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	16:00:00
2b47b4be-9ccf-4e17-8d47-7a6b0f50d0d4	2025-12-21	8.00	WORK		90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	60	08:00:00	17:00:00
2ba4e427-5bc9-411b-be70-425088621def	2025-12-20	7.50	WORK		90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	60	08:00:00	16:30:00
005763e0-2536-4109-95fe-f62f31fa250e	2026-01-13	6.00	WORK	cleaning a lot of snow, fogelband, tiles	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	09:30:00	16:00:00
6d82407d-924e-4883-87bc-768728b414dd	2026-01-06	8.00	MEETING	Red day	90ce269a-9472-4447-86cc-6f1a1519d31f	\N	60	08:00:00	17:00:00
b1315535-1198-4770-a631-21213043daf4	2026-01-15	8.00	WORK	Ränna, fix vindskrivor,  cut tile, fix small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	30	09:00:00	17:30:00
2444cabe-7aec-4b5b-b4bb-726bf3a03e3e	2026-01-26	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f36437da-0d4c-4db0-9e26-1bbc83e02c10	60	08:00:00	17:00:00
6ae25fb7-4ffd-44d7-abb2-048bb601f553	2026-01-16	4.00	WORK	stupror, fix small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	08:00:00	12:00:00
18c9894c-2446-41b8-986a-a754332a1b5a	2026-01-27	4.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	08:00:00	12:00:00
2f2ad161-ed70-497a-9856-09549f3e5cba	2026-01-17	1.00	WORK	Fix under window, fix stairs to ovlop	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	14:00:00	15:00:00
956dcca4-f92a-4f1a-964a-6815168c6d84	2026-01-17	1.00	WORK	 Fixing tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	0	08:30:00	09:30:00
35d7d071-116d-4073-a83b-77bd54e654ad	2026-01-01	8.00	WORK	red day 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	16:00:00
3cd2203f-3d85-4f7d-953a-91bcadd138e7	2026-01-06	8.00	WORK	red day	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	16:00:00
968a47ec-625c-420a-a577-df3eb839330a	2026-01-09	7.00	WORK	hooks both sides,cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	30	08:30:00	16:00:00
49f34549-44eb-416f-a4d9-a9fdd5cd78f6	2026-01-15	8.00	WORK	fogelband, painting, cutting tiles, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	30	09:00:00	17:30:00
316ac4cb-0213-4157-abd3-60d98936a049	2026-01-16	4.00	WORK	tiles, taped around ventilation, painting, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	30	08:00:00	12:30:00
a6538018-9fac-4f5f-a8f1-1878cc9435ae	2026-01-22	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
c394e884-54a3-4c8a-8c39-e9a51777e0ad	2026-01-23	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
737753a8-94ec-4f50-93b6-79f6e220a124	2026-01-12	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	17:00:00
417c4cd1-139c-480f-b311-f528ca9782d0	2026-01-13	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	17:00:00
9f12fc68-557e-475f-959e-ff98bb2a3e64	2026-01-27	4.50	WORK	Cleaning snow, montera presenning, stroläkts small peaces.	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	08:00:00	12:30:00
e07d7f81-bea1-4859-bb9d-47cf323ace78	2026-01-19	2.00	WORK	Pannor, cleaning, loading tools	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	17:00:00	19:00:00
f994f281-d8ad-4e22-9ee4-66add0b5655a	2026-01-27	4.50	WORK	Cleaning snow, leghts, preceiling	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	08:00:00	12:30:00
1b8dc0c6-1763-4101-bfd0-886baa019f22	2026-01-19	2.00	WORK	Tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	0	17:00:00	19:00:00
e0a005c2-6312-400a-b118-3eb5dc34552f	2026-01-20	8.50	WORK	Vindskivor,  ränna, small fix	90ce269a-9472-4447-86cc-6f1a1519d31f	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	17:00:00
9f883bf1-8513-4b5d-a8be-690403034f1e	2026-01-20	8.00	WORK	Fotplåt fågelband måla 	7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	17:00:00
5e65a22a-1951-42d9-9715-02a7881e68ba	2026-01-20	8.50	WORK	fogelband, tiles, cutting tiles - prepare for rendal, nok-regel, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	17:00:00
ac7a71d8-5458-493f-a663-a1771ec6a9d3	2025-12-23	7.50	WORK	tiles, painting, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	16:30:00
ad8da42f-00a5-4765-ad73-01958bdf5297	2025-12-24	6.50	WORK	top line leghts, tiles, cutting tiles around chimney, takkupor, windhuiva takkupor, painting, nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	09:00:00	16:00:00
566a5306-971b-479a-afd3-73c32e5576b5	2026-01-05	8.00	WORK		90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	30	08:30:00	17:00:00
8e27020d-06df-4bdc-b63a-81629cd755b4	2025-12-24	6.50	WORK		90ce269a-9472-4447-86cc-6f1a1519d31f	ac4896b2-f0c4-4da1-a604-5213681e663e	30	09:00:00	16:00:00
c7422040-d2e4-41e8-a809-7e2c1380f110	2026-01-28	8.50	WORK	Ränna, megure, läkts	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	17:00:00
8d356119-a01a-48c6-946f-08c857512a36	2025-12-30	1.50	WORK	cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	0	15:00:00	16:30:00
45a1b66b-745b-4f41-8975-3c1c4292d296	2026-01-21	8.00	WORK	Vindskrivor metal, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	16:30:00
ec9ed360-1346-48df-8f5a-dad582168b66	2026-01-21	8.00	WORK	tiles, gluing and cutting tiles - prepare for rendal and opposite side, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	16:30:00
35c97887-b2fd-49cf-a059-f18e4e8c15fb	2026-01-28	8.50	WORK	leghts, removing preceiling, demolition windhuiva, rennas, metal, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	17:00:00
7e0a22ae-e6b6-490e-ae2c-8b8906f69ab1	2026-01-27	4.50	WORK		db131598-bdda-42c3-936d-27229529abfb	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	08:00:00	12:30:00
58c5c1b2-ce23-4615-acb1-707796408b09	2026-01-13	5.00	WORK		db131598-bdda-42c3-936d-27229529abfb	54629585-9337-4f55-8977-036ff89a2e2b	0	08:00:00	13:00:00
c2494c8d-6f43-4a00-ae27-bd7e8d429c9d	2026-01-16	7.50	WORK	4 timmar fixat med kupan 	db131598-bdda-42c3-936d-27229529abfb	54629585-9337-4f55-8977-036ff89a2e2b	30	08:00:00	16:00:00
2abc5459-76de-4ae9-bd4f-64e7709e17fd	2026-01-12	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	54629585-9337-4f55-8977-036ff89a2e2b	60	08:30:00	16:30:00
78a431bc-55e6-409a-8984-c22990364565	2026-01-29	7.50	WORK	Satt vindskivor 	db131598-bdda-42c3-936d-27229529abfb	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:00:00
e0527954-8f63-47d1-81b4-635700c706f9	2026-01-21	7.50	WORK	Fågelband stuprör måla	7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	16:30:00
8933c50c-df65-4b59-8e7d-bdeda6df439c	2026-01-29	7.50	WORK	Windhuiva, trikant, nok regel, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:00:00
954df01e-01ee-4f43-bce9-523f10b31cd6	2026-01-22	8.00	WORK	takkupor tiles, gluing and cutting tiles - rendal, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
22f9e2e4-fbfd-4775-a810-f95cf5c8c4e9	2026-01-23	3.50	WORK	Cleaning, taking down ställning, montera pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	30	11:00:00	15:00:00
34ab257e-f640-4c1d-a9d8-7741959e4548	2026-01-23	6.50	WORK	takkupor tiles, gluing and cutting tiles - rendal, removing scaffolding, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	30	08:00:00	15:00:00
d2b0c522-7bc4-401a-981c-4c7799ace0db	2026-01-24	8.50	WORK	Demolition couppor, papp cuppor, montera råspond on copper, paint, vindskivor plåt	90ce269a-9472-4447-86cc-6f1a1519d31f	ac4896b2-f0c4-4da1-a604-5213681e663e	30	09:00:00	18:00:00
b33b953c-abc8-45b0-8183-d549489dfa7f	2026-01-24	8.50	WORK	tiles, heating, gluing and cutting tiles - prepare for rendal and opposite side, nok and (heating), nok, cleaning	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	09:00:00	18:00:00
2bc58d55-60ce-49f9-919f-d8886cf0b0a9	2026-01-26	8.50	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	17:00:00
c773e508-9c2b-45ed-87ae-82c81f442d1a	2026-01-26	8.50	WORK	Ripoff tiles, papped, leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	17:00:00
477d7ab8-2fc4-4cbb-bfe3-f2e59ef65c58	2026-01-29	7.50	WORK	Megure roof, ränna	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:00:00
c8b1fba2-fa29-424b-9033-a42e2dc31336	2026-03-11	5.00	WORK	Ränna, tile	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	12:30:00
af4cfac2-80f6-4198-bc1f-df19579d91b0	2026-01-30	8.00	WORK	Fogelband, unloading tiles, put tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:30:00
a542798d-7007-4f7d-9b6e-fec94fdde0d0	2026-01-30	8.00	WORK	Tile, vindskrivor plåt, ränna	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:30:00
13edec1e-3fdb-44bb-a5c0-a30a99785e16	2026-02-10	6.50	WORK	Regels, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	019b62fd-0697-454b-baed-ded26eba74a9	30	08:00:00	15:00:00
ae111f0a-80b5-4165-bbdc-82ac4cdda031	2026-01-31	8.50	WORK	Nok regel, heating and gluing nok and, nok-connection, cutting windhuiva metal, removing scaffolding, stupor, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	17:00:00
c53bee16-8773-4035-ac11-62c602720268	2026-02-02	5.50	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	019b62fd-0697-454b-baed-ded26eba74a9	30	08:00:00	14:00:00
7fc3402a-d57a-4485-8cfa-e1458a407602	2026-02-02	3.00	WORK	Loading tile to truck	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	14:00:00	17:00:00
37ed2bbd-e3e8-4b5a-853b-74fa7de17095	2026-02-02	8.50	WORK	Demolition tiles, leghts, old papp, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	019b62fd-0697-454b-baed-ded26eba74a9	30	08:00:00	17:00:00
6d997f62-a619-4474-8550-843d314a868a	2026-02-03	4.50	WORK	Vindscrivor metal, cleaning, glydskid.	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	13:00:00
d2125227-1ed5-4376-a65d-41edfe90dfdf	2026-02-03	3.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	019b62fd-0697-454b-baed-ded26eba74a9	0	13:00:00	16:00:00
e181d1d4-d855-4033-a6b1-7a15dffdf194	2026-02-03	4.50	WORK	Stuprors, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	13:00:00
a0493eea-1906-4654-9564-7d11d9e90eec	2026-02-03	3.00	WORK	Papp demolition, preceiling, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	019b62fd-0697-454b-baed-ded26eba74a9	0	13:00:00	16:00:00
d7794dc7-6422-42bc-aaea-9e1127ecaaff	2026-02-04	6.50	WORK	Cleaning car	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	07:30:00	14:00:00
9581efc4-ad14-420e-8a34-9302994172ae	2026-02-04	4.00	WORK	Tile delivery and montera	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	14:00:00	18:00:00
d981f7f7-bbb2-46cd-9afa-af4f5fe09ee5	2026-02-04	6.50	WORK	Washing and cleaning car, separate and bring tools to basement 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	07:30:00	14:00:00
67bd7b3d-967c-4b47-bfcd-98b5a54f372c	2026-02-04	4.00	WORK	Unloading tiles, install tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	0	14:00:00	18:00:00
899b2be6-f942-4f24-99e3-413998978d00	2026-02-05	3.00	WORK	Buying nok pannor, bringing car to Lutsian, picking scrues and other stuff to car	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	07:00:00	10:00:00
c1d000b8-cff5-4f75-9b7e-5a8e572bc451	2026-02-05	3.00	WORK	Derome, tools, delivery car	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	07:00:00	10:00:00
e263c150-b441-4216-823d-f0034e2aa967	2026-02-05	2.00	WORK	Heating nok and, nok, painting 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	10:00:00	12:30:00
43ec1bb0-3df9-4524-a7b4-30bbcd4014bd	2026-02-05	2.00	WORK	Cut tile, paint	90ce269a-9472-4447-86cc-6f1a1519d31f	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	10:00:00	12:30:00
36a4200a-a5ed-4464-932d-f459a5ca6f1e	2026-02-04	8.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	019b62fd-0697-454b-baed-ded26eba74a9	60	08:00:00	17:30:00
b6bf0377-baf2-4bc4-a477-15d205f62624	2026-02-25	4.50	WORK	.	7f7fff21-8568-4d80-bec5-77001d7bbf7d	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	13:00:00
18d79769-ef1f-4659-9acc-94e9917f211c	2026-02-02	8.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	17:00:00
b0b09fcd-fcdd-433b-821b-4361f086deb0	2026-02-03	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f36437da-0d4c-4db0-9e26-1bbc83e02c10	60	08:00:00	17:00:00
abb0ece1-3fe7-4980-b93a-4c2fa71aba3d	2026-02-09	4.00	WORK	Cutting nok, stupror, paint, fixing small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	ac4896b2-f0c4-4da1-a604-5213681e663e	30	08:00:00	12:30:00
934bb9e3-d1a5-4baa-9c21-9f1ecc912bd9	2026-01-08	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
c01356cc-dbf4-426d-88d2-9be68551461f	2026-01-30	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f36437da-0d4c-4db0-9e26-1bbc83e02c10	30	08:00:00	16:30:00
3d037ca1-2449-4066-b76c-892f9f5ea10d	2026-02-02	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
8145808b-ab30-4ed3-8c9f-05331b68ccf7	2026-02-03	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
f28b08d5-922a-4730-bf7b-30982bbcc815	2026-02-04	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
3ff72917-c7d2-4f0c-ba65-40c2cf139e3b	2026-02-05	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
f65b71bf-084c-4b48-8ec4-ba8397335433	2026-02-06	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
8b930e87-74ff-4904-a9cb-19d718cd6e94	2026-02-09	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
af6128e5-2e8e-48a0-b033-422f7a5365df	2026-02-10	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	60	08:00:00	17:00:00
51f66c3a-17f6-47ba-b6a4-be3053946a31	2026-01-09	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
8c72459f-0f38-4ced-bc57-27292a720bd6	2026-01-14	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	17:00:00
9da13baa-a7d1-423a-aeb0-46f94e1cd437	2026-01-28	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	54629585-9337-4f55-8977-036ff89a2e2b	60	08:00:00	17:00:00
f0ccb488-bed2-4cc8-8e20-b2b73700a612	2026-01-29	6.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	10:00:00	17:00:00
b81d50ea-7a94-4a44-aa61-8163f0166eb7	2026-01-30	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f36437da-0d4c-4db0-9e26-1bbc83e02c10	60	08:00:00	17:00:00
ef1c3769-3526-48d4-96ef-52c79631b707	2026-01-15	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	ac4896b2-f0c4-4da1-a604-5213681e663e	60	08:00:00	17:00:00
ece62e18-3964-4bd6-ac13-d943575ea1d2	2026-02-10	3.00	WORK	Fixing car shelf 	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	12:30:00	15:30:00
58ac86c3-8e2c-4cc5-ae57-932251af79f7	2026-02-24	9.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
979231fb-24a1-4c2c-8380-e538b3a161d0	2026-02-24	9.00	WORK		db131598-bdda-42c3-936d-27229529abfb	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
016f98a1-571d-4478-81ce-e4d7e067f8d6	2026-02-24	9.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
f84141f8-e950-4779-8ac6-b29f60a7bf88	2026-02-25	8.50	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:00:00
8257b8ce-29d2-4892-a2fd-025aa9e7f6eb	2026-02-25	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:00:00
085eaa07-ee49-488a-adad-2bf465e1b7da	2026-02-24	9.00	WORK	Demolition, papp, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
dad85e16-8811-4f1c-a4d8-b3c6cb183c92	2026-02-25	8.50	WORK	Demolition, papp, leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:00:00
3a4d23b0-272d-4da1-aa48-56746ada2dc4	2026-02-26	8.00	WORK	Läkt 	7f7fff21-8568-4d80-bec5-77001d7bbf7d	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	08:30:00	17:30:00
36d18c82-ba4e-4113-a65b-a72a4c2e78b0	2026-02-26	8.00	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	08:30:00	17:30:00
ab2c94bd-5916-49d4-8bea-bd380a0cf6f6	2026-02-26	8.00	WORK	Papp, megure for bärläkts	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	08:30:00	17:30:00
296cd6c7-3b6e-4359-9629-0aba314feec6	2026-02-28	5.00	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	08:00:00	13:00:00
cfb53dce-2642-4551-903f-9412d167ab60	2026-02-28	4.50	WORK	Läkts, demolition ränna, start with ränna	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	13:00:00
a7f6f028-4658-4118-ac23-ce4b2997f2e9	2026-02-27	1.00	WORK	Demolition, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	09:00:00	10:00:00
f15b94a4-2109-46e2-8b6c-a51853b99b22	2026-03-02	9.00	WORK	Ränna, läkts, papp	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
6efb0bc7-264b-405f-ab5b-e9e5a85bb570	2026-02-11	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
2baa40fd-2ce7-4533-a147-dceca4b82220	2026-03-02	9.00	WORK	Papp, Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	17:30:00
5467ff3b-f8fa-4a8f-b7d1-851dcf5d98db	2026-02-12	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
5b5d0bf7-14e6-45c0-9c68-26508034cadd	2026-02-13	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
1cec984c-0a78-465c-a898-b67fb2c005f2	2026-02-16	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
95aaeeaf-f378-46bc-851a-dd6ba437cc91	2026-02-17	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
4e11aaca-74ed-4358-81b7-35dc21c43736	2026-02-18	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
33b39da9-e9a0-45bf-8183-613510b40fea	2026-02-19	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
5e93ae9f-1708-4932-b3ff-5e38f143ba26	2026-02-20	4.00	WORK		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	12:00:00
2a914967-f338-4274-adee-eee34b3ba25c	2026-03-03	2.50	WORK	Demolition tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	08:00:00	10:30:00
a3783aad-4db7-403a-a672-a5ef14505c77	2026-03-11	5.00	WORK	Leghts, tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	12:30:00
88c95c9a-30d6-4bf4-b81a-5b3da58b36f4	2026-03-03	0.02	DAY_OFF	test	90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	08:00:00	08:01:00
8da12851-7cd5-43f5-8bb1-6e76855671cb	2026-03-03	6.50	WORK	Ripp off panels and metal both takkupors, papped bottom parts, windpapp and taped connections, leghts, regel, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	10:30:00	17:30:00
8a7995f2-73b7-4ca4-a9c0-226dfc0feec2	2026-02-27	7.50	WORK	Leghts, demolition, change respond, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:30:00	16:30:00
c8fed158-a101-4454-a3fd-59e52e4bb49e	2026-02-27	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:30:00	16:30:00
f9e0986a-473b-4753-9b39-56ad225c7775	2026-03-04	9.00	WORK	Leghts, trikant takkupors, ends of roof, papped and taped connections around chimney, govel, windhuivas, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	09:00:00	18:30:00
b3484b27-37e2-4699-a208-0f2d19096cb5	2026-03-04	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	08:00:00	16:00:00
f4969265-4f11-4d78-a905-7daece17867f	2026-03-05	10.50	WORK	Derome, ränna, megure roof for tile 	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:30:00	18:30:00
366101ee-c96c-4161-b808-2a18fe7ccfce	2026-03-05	10.50	WORK	Nokregel, footplot, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:30:00	18:30:00
5ae41d59-0a0a-42fa-93ac-b39ae30e8d7e	2026-03-11	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	07:00:00	16:30:00
1cde017b-2efc-4ff6-a24e-65bdf3a0fb7f	2026-03-06	8.50	WORK	Ränna, pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	08:00:00	17:30:00
f94cbb49-69d4-4eaf-85f2-337577ea43a3	2026-03-06	10.00	WORK	Fixing stroyleghts, fogelband, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	18:30:00
b9f54a07-b5a4-4293-8989-750628f70245	2026-03-07	9.00	WORK	Ränna, fotplåt, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:00:00	16:30:00
437b1842-6b45-47c8-88e0-ed73f86c56c4	2026-03-07	9.00	WORK	Tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:00:00	16:30:00
16767cdd-ac5d-4c10-89be-662df1c80cac	2026-03-11	4.00	WORK	Vindskrivor cuppor träd, paint	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	12:30:00	16:30:00
b7743561-9d0e-442a-a889-b7721b2972d3	2026-03-12	2.00	WORK	Lifting pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	07:00:00	09:00:00
8e8a07e7-9ebb-4ac5-bcd0-ad361e3c0abf	2026-03-09	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	15:30:00
155ba6c2-9c07-4f1e-94ad-b80fc5b6a0d9	2026-03-09	10.50	WORK	Stoprör, finish ränna, finish futplåt, lite sakers	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:30:00	18:30:00
46331a7f-8ccc-4745-a822-27a33de497db	2026-03-09	10.50	WORK	Tiles, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:30:00	18:30:00
05fdc0a0-2c2e-427c-b34b-33e7a6522939	2026-03-10	1.50	WORK	Lifting up tile	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	07:00:00	08:30:00
f45783f8-cc10-4183-a6e7-f7852a5e7425	2026-03-12	2.00	WORK	Lift tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	07:00:00	09:00:00
f4394535-7060-4f60-bc79-c2ec0eaa68a9	2026-03-12	8.00	WORK	Megure, tile	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	09:00:00	17:30:00
2037468c-3050-4b88-ae8e-0b904d8d9037	2026-03-10	6.50	WORK	Ränna, megure, demolition, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	08:30:00	15:30:00
88cb2a8c-fea9-4e72-ace3-0538327b9473	2026-03-10	1.50	WORK	Tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	07:00:00	08:30:00
1a931b88-cddc-460a-a29d-c6749afed4e5	2026-03-10	7.00	WORK	Leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	08:30:00	16:00:00
4b64fac3-ece4-47e8-bb10-c8110dc7259c	2026-03-12	8.00	WORK	Windhuivas, tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	09:00:00	17:30:00
69eaf444-3292-4200-9540-9650e37602a6	2026-03-13	3.00	WORK	Tile, tape papp around chimney	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	08:00:00	11:00:00
e14b9b9e-8bba-46d4-bb36-52d3fe7f936b	2026-03-13	3.00	WORK	Chimney, windhuiva 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	08:00:00	11:00:00
97e3dce0-758c-4042-83dd-58b257ad5557	2026-03-13	5.00	WORK	Vindskrivor vite, painting, montera pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	11:00:00	16:30:00
5b03a66e-5de3-4d54-861a-00e37e1bc70c	2026-03-13	5.00	WORK	Tiles, steps	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	11:00:00	16:30:00
55357f61-5a46-4fe0-a001-218b725af2f3	2026-03-14	6.00	WORK	Leghts, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	13:00:00	19:00:00
41343a04-ef75-4f2a-bfdf-2bc772d51098	2026-03-12	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	14:30:00
9370c1da-5ffb-4f10-9010-5633f5a8a33d	2026-03-16	6.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	13:30:00
1bf17c6c-de67-4c21-bd6c-9b359ca48965	2026-03-16	6.00	WORK	Fotplåt, panna, lekts	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	13:30:00
5464533e-5efa-4050-b1df-8ce3e72f97b5	2026-03-16	10.00	WORK	Extra nokregel, cleaning tiles for nokband, tiles, cleaning around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	07:00:00	17:30:00
34ddc5ec-f356-4cb5-a49e-940c082fffbe	2026-03-17	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	16:00:00
fade00e9-c546-48c9-830f-ea733139c6d2	2026-03-17	8.50	WORK	Stuprors, painting, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	16:00:00
357d904e-24cd-416b-b83f-38853318c8f3	2026-03-17	3.00	WORK	Nokband, leghts, painting 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	16:00:00	19:00:00
0b0c136d-9fe1-48c7-b2b7-198649d4d25d	2026-03-17	8.50	WORK	Finish ränna, futplåt, panna	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	16:00:00
39257ddc-2386-4b25-8b9d-cb5e342f76b2	2026-03-18	7.00	WORK	Lift and install nok, fixing leghts, cleaning rennas and scaffolding 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	09:00:00	16:30:00
3b7f8ccc-2db9-4b4d-92e7-5509aae12c0a	2026-03-18	8.00	WORK	Bending metal, small fixes, borja med vindskrivor plåt.	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	15:30:00
2c9529bf-fb18-4f88-bd86-c58c3c612775	2026-03-18	2.00	WORK	Stupror, demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	07:00:00	09:00:00
81d99441-1e42-4506-b377-54f29b465126	2026-03-18	2.00	WORK	Windhuiva metal 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	16:30:00	18:30:00
6f79401a-9508-4c56-b307-73bfebc1fd14	2026-03-18	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	15:30:00
52c54fb9-7e4f-4a71-8e26-7db6e407b6bc	2026-03-19	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	15:30:00
9dae5db4-3f60-4170-9ecc-085cae7ea276	2026-03-19	11.50	WORK	Windhuiva, windhuiva side metal, windhuiva top metal 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	07:00:00	19:00:00
a7931180-d332-484d-89a0-edddb5d42486	2026-03-19	8.50	WORK	Bending metal, vindskrivor, vacaflex	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	30	06:30:00	15:30:00
080813cc-871f-4b70-931c-45b76f785ee5	2026-03-20	2.00	WORK	Cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	07:00:00	09:00:00
0098dbf1-dfa1-4e3a-9a84-0a10843f2a52	2026-03-20	2.50	WORK	Finishing metal, cleaning	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	06:30:00	09:00:00
8a1f9480-3968-4f7a-86b8-f969344247fc	2026-03-20	3.00	WORK	Scaffolding 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1518522b-892b-47ef-afe6-b56caa69af4c	0	09:00:00	12:00:00
0114651d-fe81-49f8-8b9d-818aec63dcc2	2026-03-20	3.00	WORK	Byggt ställning 	db131598-bdda-42c3-936d-27229529abfb	1518522b-892b-47ef-afe6-b56caa69af4c	0	09:00:00	12:00:00
01eb524c-e4b9-44a0-97b9-5b05aa1937c2	2026-03-20	2.00	WORK	Städat	db131598-bdda-42c3-936d-27229529abfb	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	07:00:00	09:00:00
dd48bd3b-3b44-41d6-8ffe-dd1a2f1df1e5	2026-03-21	5.00	WORK	Painting, fixing small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	08:00:00	13:00:00
24b82556-13e5-4b7d-8b6e-f1b1e304a9a5	2026-03-21	5.00	WORK	Fixing mistakes	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	54629585-9337-4f55-8977-036ff89a2e2b	0	08:00:00	13:00:00
93e67ecf-a817-4448-a64b-1ba182212ec2	2026-03-04	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
637427de-00ea-47a2-ad97-61ca0dc6485f	2026-03-23	4.00	WORK	Papp	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	9c5b8aea-784b-4166-80f9-f26b8c6799f0	0	13:00:00	17:00:00
7a628d98-3b8b-4062-8b6b-e08a3d3d93d8	2026-03-23	4.00	WORK		db131598-bdda-42c3-936d-27229529abfb	9c5b8aea-784b-4166-80f9-f26b8c6799f0	0	13:00:00	17:00:00
5d53239c-f51c-4129-9f2b-9fc248e10ae2	2026-03-23	4.00	WORK	Papp	90ce269a-9472-4447-86cc-6f1a1519d31f	9c5b8aea-784b-4166-80f9-f26b8c6799f0	0	13:00:00	17:00:00
c2dd093f-45e4-4678-8a67-06bd7df19a60	2026-03-24	10.50	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	18:00:00
5279c1e6-d7c1-4dec-b9e5-57393749886b	2026-03-24	7.50	WORK	Unload tile, demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	06:30:00	14:30:00
1be5a659-e7eb-45cf-bc8c-d877f41e2498	2026-03-24	1.50	WORK	Road + Painting	90ce269a-9472-4447-86cc-6f1a1519d31f	f40904f2-dc04-4c56-8c6b-259d63237a2b	0	14:30:00	16:00:00
ccc99ab3-ebb4-4112-bccf-5ba0a9c95127	2026-04-08	7.50	WORK	Unloading tile, megure, futplot	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:30:00	15:30:00
96a4758f-3218-4b75-acf4-61c0d937be97	2026-03-24	10.50	WORK	Demolition, papp, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	18:00:00
f698e2f4-1fbc-4466-b2e5-9198cf26a462	2026-03-26	10.00	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	17:30:00
5f58c02e-f10b-43aa-a299-4ce674700249	2026-03-26	10.00	WORK	Demolition, lekts	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	17:30:00
cf40bba3-0974-4b37-81ea-99f522a6cebc	2026-03-26	11.50	WORK	Demolition, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	19:00:00
ee445181-0495-4df7-a1b3-e1827519a48e	2026-03-27	6.00	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	13:30:00
137177a4-ec55-477e-b032-dbac6685efce	2026-03-26	6.50	WORK	Underlagpapp 	7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	15:00:00
26837a5c-b913-46a9-944c-6363f617d03b	2026-03-27	5.00	WORK	Undrrlagspapp rändal	7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	13:30:00
52abdbe4-2cad-4bb7-981b-6688b064448d	2026-03-27	6.00	WORK	Ränna hook, papp	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	13:30:00
68b0b7b1-558f-4358-aba3-60e4faece5ec	2026-03-27	11.50	WORK	Papp, leghts, painting windhuivas, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	19:00:00
2538b906-88f1-4858-b228-9932012686f6	2026-03-28	9.00	WORK	Rennahooks, leghts, trikant, collect and placed old leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	09:30:00	19:00:00
df36a86b-b259-4a29-8209-47f34369060a	2026-03-30	6.50	WORK	Ränna, lines, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	11:00:00	17:30:00
155f405d-2b69-4f60-a4cf-d601432c8938	2026-03-30	5.00	WORK	Hooks, renna	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	11:00:00	16:00:00
dcdb00d9-2442-46fc-92e2-4c372dff543c	2026-03-31	9.00	WORK	Leghts, trikant takkupors 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	16:30:00
e11dbec7-8913-42ef-8853-7e53cb8894fd	2026-03-31	7.50	WORK	Ränna, fotplåt, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	09:00:00	17:00:00
01415255-4ad3-4773-9123-165882eb5cbc	2026-04-01	2.00	WORK	Demolition garage, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	09:00:00	11:00:00
2a869753-2992-4f3e-8275-d86b8bf0a912	2026-04-01	6.50	WORK	Delivery tools Staffanstorp-Oxie-Falsterbo-Oxie, demolition leghts, papp	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	14:00:00
8bcbdd52-319d-4ecc-aa3e-3bf400a1da97	2026-04-02	2.50	WORK	Cleaning, papp, lekts	90ce269a-9472-4447-86cc-6f1a1519d31f	1518522b-892b-47ef-afe6-b56caa69af4c	0	13:30:00	16:00:00
78fb4b35-3cc3-4f67-98bb-719814ddda24	2026-04-02	4.00	WORK	Buying stuff, waiting,  delivery	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	10:00:00	14:00:00
f5bc1cc3-3b79-44d6-b7b4-d0d917482795	2026-04-03	4.50	WORK	Mogelstop, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	17:00:00	21:30:00
321c93fd-a2f1-497c-aa6c-6eb8c90d37aa	2026-04-03	8.00	RED_DAY		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
a46ef080-1bae-4781-bab5-e4b26b48e694	2026-04-04	7.00	WORK	Distances, rospond, govel 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	08:30:00	15:30:00
6078c4c2-b027-4184-a7f7-0d4a435472f7	2026-04-06	8.00	RED_DAY		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
794281fc-80c2-482c-82d8-5e7abcc5e14c	2026-04-06	7.00	WORK	Mogelstop, trikant, leghts, painting, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	14:00:00	21:00:00
23b9885c-07ee-48a9-9ee5-0d87a6130bbe	2026-04-07	9.00	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	16:30:00
e98c0c12-c692-4ac5-b268-0cc83d84973c	2026-04-02	8.00	RED_DAY		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
be67810f-d112-47c6-b8ef-b8e3a67cbd17	2026-04-06	8.00	RED_DAY		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
f412830f-7a94-4e3b-a82c-61c043ae7e44	2026-04-07	8.00	WORK	Ränna, futplåt, meguring 	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	08:00:00	16:30:00
078e2a97-55d6-422e-933c-9ea607b24917	2026-04-08	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	08:00:00	17:00:00
75cbdaf7-de6a-4b9c-9c09-edba7c59a3bb	2026-04-08	11.50	WORK	Unloading tiles, mogelstop garage, renna, footplot, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	19:00:00
c18fdaae-92e7-4a41-a3d5-55a125b58701	2026-04-08	1.00	WORK	Changing tiers	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	16:30:00	17:30:00
847cffb2-4aa6-4c49-82fc-072ac1a29a6f	2026-04-09	8.00	WORK	Vindskivor,  panna, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:30:00	16:00:00
328908e1-6b60-4716-94fd-ddc13c5d1a88	2026-04-09	11.50	WORK	Windhuivas, leghts, fogelband, tiles, nokregel garage, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	08:00:00	20:00:00
8ec81507-d120-4ac5-8b1b-e2ea968b370a	2026-04-10	9.00	WORK	Vindskivor plåt, panna	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:30:00	17:00:00
38d9f3fc-1c8d-49e5-b601-9280b6dec16d	2026-03-24	7.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	15:30:00
b5c5210d-b144-4d61-b024-ca11c9d5625a	2026-04-07	4.00	WORK	windhuivas, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	11:30:00	16:00:00
08beff73-3be6-4636-99c2-07ef3173df30	2026-03-25	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	07:30:00	16:00:00
fa188e55-11b5-4260-9a0c-d0d06e701b68	2026-03-03	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
67c9ca39-12bd-4672-8aa8-84b572bf6459	2026-03-06	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
4c248b67-4753-4e14-9b43-d0d6f15b36b6	2026-03-05	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
9f7f2b8e-42f3-443d-b9a2-779b9b4d1f3e	2026-03-09	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
5562f080-da31-42ad-8089-bc9bc6b5b7ba	2026-03-10	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	f40904f2-dc04-4c56-8c6b-259d63237a2b	60	08:00:00	17:00:00
7bf5895d-917f-489c-8ecc-a0b3093a6a9a	2026-03-11	6.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	08:00:00	15:30:00
00acd74b-4566-4ded-846b-0dd55fa96e71	2026-03-12	6.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	07:30:00	15:00:00
690f90f6-ee18-43ce-bd8c-6e8ad5e50531	2026-03-13	7.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	30	08:00:00	15:30:00
aa3e7030-40ff-4cc2-adad-2bb9f7c96435	2026-03-16	7.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	30	08:00:00	15:30:00
5488de1b-56d9-46c7-82cc-3d12da7b1eb1	2026-03-17	6.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	08:00:00	15:00:00
2093581d-1e3d-4c34-a9c3-59afdb87a1f8	2026-03-18	6.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	08:00:00	15:00:00
56124402-14e2-4d35-8844-f6bcc27eed78	2026-03-19	6.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	08:00:00	15:30:00
050d5350-9f5f-43a1-9475-2ce07bb17bdf	2026-03-20	6.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	cef60249-2727-476e-bd94-4d3e9dd03916	60	08:00:00	15:00:00
f1027316-e91e-46df-a52d-3ab56a9a7d3d	2026-04-13	6.00	WORK	Panna, stairs	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	11:30:00	18:00:00
e02f6654-3158-4879-be82-b8f146643d05	2026-04-13	2.00	WORK	Windhuiva, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	07:00:00	09:00:00
e46b1df3-d606-415b-9e89-f2df905b78e9	2026-04-09	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
c2b2f96a-1e74-4003-8fea-74d815099060	2026-04-10	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
1db26ad1-107d-44a2-807f-cf37f014c946	2026-04-13	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
31006571-13bd-490e-a34b-b20a7e5a8e29	2026-04-14	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
313dd5aa-0b16-4981-9d94-843ecd92137e	2026-04-14	8.50	WORK	Panna, nok, regel	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	60	07:30:00	17:00:00
27bae16f-5ed5-4ad3-9f2b-496596c8683f	2026-04-14	2.00	WORK	Windhuiva takkupor, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	07:00:00	09:00:00
1806a0d5-b79f-4e98-a72d-a63cb816e3ef	2026-04-03	8.00	RED_DAY		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
385c7a21-2f6e-4b6f-9acd-2967ed5bbc76	2026-04-06	8.00	RED_DAY		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
117465b3-6f89-4359-b4e7-492312322a0c	2026-04-15	5.00	WORK	Stuprörs, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	07:00:00	12:00:00
dded07a8-fe1a-442a-8603-ee582ea8715b	2026-04-15	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
ddc3ef53-3190-4bea-840e-dc902a68449c	2026-04-16	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
b5fe11fe-5662-4165-9761-fe4c21c47b1a	2026-04-20	4.50	WORK	Cuppor: lekts, vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	07:30:00	12:00:00
3dbef521-d4cb-42d5-8624-d262b795ad9f	2026-04-21	4.50	WORK	Cuppor, tile, vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	12:00:00
6f3a2808-876d-49e5-a08d-fe19faff87c1	2026-04-20	7.50	WORK	Pap garage 	7f7fff21-8568-4d80-bec5-77001d7bbf7d	1518522b-892b-47ef-afe6-b56caa69af4c	30	08:00:00	16:00:00
5318bbf4-a489-48a7-a14e-ef4ce0546ff5	2026-04-21	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	07:30:00	16:00:00
6c6dcc8b-eaac-4253-90af-7284a657cd5a	2026-04-22	8.00	SICK	Back problems 	90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
9b6d1312-4c4e-4ca0-9c3d-007503fd974f	2026-04-23	8.00	SICK		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
ba88ba8d-dabc-443a-8e45-926910961403	2026-04-24	8.00	SICK		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
c3202a0d-89a3-421b-b1cf-f8d136ba3b7d	2026-04-20	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
8d567169-a225-4515-957a-c690ee1399c7	2026-04-21	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
09387b83-c439-4cc9-8db7-e319417f90ab	2026-04-22	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
5fd5158c-31bc-4960-9bbb-3ce6e3af1e92	2026-04-23	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
d29c6073-cc2a-4406-a357-0970a07e2581	2026-04-24	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
2faafa74-5792-4747-bf33-c17678b30b4c	2026-04-17	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
c351df6f-adf4-4264-a693-816a93a87e35	2026-04-16	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
243fd9b0-0f7f-4e5b-b9ed-0093e48b8cfe	2026-04-15	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
68635a24-cc93-45d8-ab79-07cfd1a57162	2026-04-14	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
43dfc12d-48e2-44a6-a132-2a7726e1a4a8	2026-04-13	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
fd6c5b34-0d7a-4918-b635-085722327921	2026-04-10	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
506f3d14-2bce-4d09-84b5-4108ad2998f5	2026-04-09	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
474100c7-1fc2-4e6f-ae26-9ac0b1f953d3	2026-04-08	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
b0a99965-96af-44a0-b137-a8363641ffee	2026-04-07	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
887de2cc-cfe9-4534-bb44-68275534f22e	2026-04-06	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
a7c33c54-ff29-40fd-bb17-b0e1723a6cbb	2026-04-01	0.02	DAY_OFF		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	08:00:00	08:01:00
fad20a21-5230-4e65-bb18-cdc09b7fb53c	2026-04-02	0.02	DAY_OFF		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	08:00:00	08:01:00
d065a30a-1847-475f-b36e-18655c7dd1bf	2026-04-03	0.02	DAY_OFF		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	08:00:00	08:01:00
35f0e802-17e4-4ef7-b7e4-b1f2a495f3ec	2026-04-27	2.50	WORK	Windhuiva 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1518522b-892b-47ef-afe6-b56caa69af4c	0	17:00:00	19:30:00
66f08024-e090-4c69-a96d-a0876642602f	2026-04-27	8.00	SICK		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
5e3aab4c-d4bc-4bb9-8563-2030c6d222a2	2026-04-17	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	16:00:00
72dd4413-b859-40b0-95e3-0b6b813006a4	2026-04-23	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	60	07:00:00	16:30:00
36af4c04-4ad2-4f3e-b2d7-19998c201fc0	2026-04-24	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	07:00:00	16:00:00
19b1cb5b-25e8-4b41-93f2-66e9db763fc8	2026-04-28	10.00	WORK	Demolition tiles, leghts, papp	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	17:30:00
311caf51-0222-43a4-90c2-6a9b07ceeef3	2026-04-28	10.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	17:30:00
630c1790-34a9-42f3-8b7c-dcb4f92c9539	2026-04-28	10.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	17:30:00
0e1b8666-f8ed-463e-90b2-3c22ff1c14d4	2026-04-29	8.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:30:00
91d58610-1f08-4622-a277-aca4e2c89d23	2026-04-29	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:30:00
10bd832c-393b-420c-868e-6ede197dd949	2026-04-29	12.50	WORK	Demolition leghts and papp, papp, trikant, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	20:00:00
6218c6b6-d8ad-4f04-8a68-f231df854c5c	2026-04-30	7.50	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:00:00
ba42a347-abde-47fb-aeeb-626a3da67d76	2026-04-30	7.50	WORK	Ränna, futplot, delivery, start meguring	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:00:00
9c2dcbbe-c0b2-4d82-8972-02b9a56e660a	2026-04-30	6.00	WORK	Ränna, fotplåt, tile, vindskrivor, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	1518522b-892b-47ef-afe6-b56caa69af4c	0	15:00:00	21:00:00
d6b7efb4-078e-45ff-9dac-fa7022e5425e	2026-04-30	6.00	WORK	Leghts, windhuivas, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1518522b-892b-47ef-afe6-b56caa69af4c	0	15:00:00	21:00:00
a3f65fae-e46b-41dc-8055-b26aa12e553e	2026-05-01	8.00	RED_DAY		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
ea714833-5a5c-4c2a-b363-b5ca9661077b	2026-05-01	8.00	RED_DAY		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
c0302bee-62d9-46cd-bbb9-afeb8ba6b0dc	2026-05-01	9.50	WORK	Tile, vindskrivor, garage plåt, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	08:00:00	18:00:00
6cae8c83-84a5-4f7d-81e5-c32cf2409af4	2026-05-01	9.50	WORK	Painting, nok, windhuivas, stupror, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1518522b-892b-47ef-afe6-b56caa69af4c	30	08:00:00	18:00:00
1eec5c20-5452-4178-b734-a4601bc2fa2b	2026-05-02	11.50	WORK	Fixed wrong things according to the list. Painting windhuivas,lifting and placed tiles, glued tiles for rendal, redoing nok on flat roof, cleaning scaffolding, put down all broken tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	30	08:00:00	20:00:00
5aaf4831-a057-442f-b11b-3e49a6f1d572	2026-04-30	5.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	07:00:00	12:00:00
e100e50b-d104-490e-a471-ff09184a3af2	2026-04-22	5.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	07:00:00	13:00:00
c74b3686-a128-40a1-ba15-abe60f9eded0	2026-05-01	8.00	RED_DAY		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
e1cc01b5-4f2e-44ef-b93f-5c39017b6064	2026-05-04	6.50	WORK	Leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	14:00:00
16433d47-5e3b-4c37-a69f-e7f384fd1dd9	2026-05-04	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	16:00:00
5297aa22-6c54-452a-971c-6012f3bc0949	2026-05-04	6.00	WORK	Megure bärläkts, ränna, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	09:30:00	16:00:00
c51d8b8c-ecef-4e60-8db6-6471ad024d4d	2026-05-04	2.00	WORK	Tile, fix stuprör	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	16:00:00	18:00:00
bba012c6-45aa-463e-ab40-ae57509969ab	2026-05-04	7.50	WORK	Unloading tiles, lifting tiles on scaffolding, reddal, stuprors takkupors, do fug every tile on flat roof, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	14:00:00	21:30:00
696d5337-0bb7-4fae-9b4c-d6cc9d378d79	2026-05-05	8.00	WORK	Megure, läkts, vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:30:00	16:00:00
840c0b65-7094-44ed-bc40-8cb89f736f85	2026-05-05	12.00	WORK	Measurements, leghts, windhuiva, fogelband, taped around chimney, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	19:30:00
f0f80737-10c8-41f6-a962-da6499e08982	2026-05-06	6.50	WORK	Leghts, windhuivas 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	08:00:00	15:00:00
cb0f881a-7d88-49c9-abbc-4789eaf0fcf7	2026-05-06	7.50	WORK	Läkts, vindskrovor, borja rekna	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:00:00
77c41755-251a-4091-afed-7e4018334956	2026-05-06	1.00	WORK	Buying stuprör, stuff for it, prata med owner 	90ce269a-9472-4447-86cc-6f1a1519d31f	1518522b-892b-47ef-afe6-b56caa69af4c	0	15:00:00	16:00:00
5c06d09c-8ecf-42b7-9541-51eaea23de88	2026-05-06	4.50	WORK	Rendal	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	15:00:00	19:30:00
c338a017-d3fd-4d5f-acbd-c7af60f5f3b1	2026-05-01	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
de304624-e50c-4fb8-9347-6e0a77965125	2026-04-30	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
75ba0b11-10d7-43fe-92c3-ed966f4e9b19	2026-04-29	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
0b65df08-bd40-4407-9362-21f344379d5f	2026-04-28	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
88dde5c2-557b-47d3-a0fe-ef8df86fcde4	2026-04-27	3.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	12:00:00
80bb0b63-bd49-4165-9df6-927e7865d9cb	2026-05-04	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
e3b1ee46-e5ca-4e8e-92ad-4dd58af3efb3	2026-05-05	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
e5f526e1-23cf-4737-8f72-c3d075819546	2026-05-06	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
626c9912-2879-46e2-871f-735ca20b02ef	2026-05-07	9.50	WORK	Leghts, windhuivas, painting windhuivas, nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	10:00:00	20:00:00
cfb4e9bc-735c-46d1-b02f-66d75fcf8777	2026-05-07	3.50	WORK	Stuprör, add few vindskrivor, paint, buy stuff in Derome, collect trash from project.	90ce269a-9472-4447-86cc-6f1a1519d31f	1518522b-892b-47ef-afe6-b56caa69af4c	30	10:00:00	14:00:00
3a5d091b-9bc3-4542-898f-ddc5d8d06dc7	2026-05-07	5.50	WORK	Megure roof for tile, vindskrivor wood, additional cutting for stuprör what asked owner.	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	14:00:00	19:30:00
6b5f2e23-188f-4b9f-b815-226acb21bb6f	2026-05-08	7.00	WORK	Receiving pannor, montera pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	08:00:00	15:30:00
0353fb3f-61c6-49ad-a300-133bc78e752c	2026-05-08	10.00	WORK	Unloading tiles, placed tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	17:30:00
8e1c8c16-32fe-4d58-80ec-77d48e2c3143	2026-05-08	3.50	WORK	Rendal 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	17:30:00	21:00:00
b1e2d036-a084-41e7-8d99-df9784fb8c81	2026-05-15	5.50	WORK	Rendal, tiles, total cleaning all scaffolding and around house, putting down all broken and cutting tiles.	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	15:00:00	20:30:00
3fd645e3-3888-43a6-818d-c26f0571ef50	2026-05-09	9.00	WORK	Cutting rendal, cutting tiles under steps and redoing it, cutting nok tiles on connections, glued and cutting rendal on another side, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	09:00:00	18:30:00
11db7f4e-0021-4c7b-90ca-2caed1ca74ea	2026-05-11	3.50	WORK	Pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	08:30:00	12:00:00
5c377ab0-7111-44fe-a684-e9b1eaf92095	2026-05-12	11.00	WORK	Vindskivor plåt,  pannor, fix small things	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	18:30:00
fad9b278-7234-494a-94b9-fb9825d049ce	2026-05-11	3.50	WORK	Fix mansard tile connection 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	08:30:00	12:00:00
c4ffbcbb-c9ad-4208-b016-e2b1d64c7691	2026-05-12	12.00	WORK	Tiles, rendals, mansard tile connection, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:30:00	20:00:00
42a23e65-43d3-4c73-8fb8-0b93fc6968c7	2026-05-13	2.50	WORK	Lagt pannor 	db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	10:00:00
ded8caa7-56a9-45d7-b226-cd885222d0ae	2026-05-05	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	16:00:00
6c905eeb-6682-44dc-a4ce-a4670bd9b3fd	2026-05-08	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:00:00	15:30:00
782bf9a2-e9a0-4653-9f55-eff7b1b5c008	2026-05-13	8.50	WORK	Tiles, cutting rendal, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	60	07:00:00	16:30:00
e9f6395a-b968-481a-836c-686fe64fd4d7	2026-05-13	3.00	WORK	Lifting tiles, placed, repeated for rendal 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	16:30:00	19:30:00
9169efd0-ae61-4366-833b-62273780de05	2026-05-14	8.00	RED_DAY		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
e79f986b-d196-4b7f-a051-7032d5f4536a	2026-05-14	7.50	WORK	Lifting tiles, placed, prepared tiles for rendal, cutting rendal. Hanging leghts on kuppas, tiles, cleaning. Placed tiles beside avlop and chimney 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:00:00	16:00:00
0639d7cb-0076-4182-a19c-e139e5a46d67	2026-05-14	2.00	WORK	Rendal 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	16:00:00	18:00:00
76940db7-1963-4f8a-b701-481bfd59fe07	2026-05-14	8.00	RED_DAY		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
91be23dd-6560-4a81-a664-9ee8cb3d57fa	2026-05-14	1.50	WORK	Fix z panel plus road	90ce269a-9472-4447-86cc-6f1a1519d31f	54629585-9337-4f55-8977-036ff89a2e2b	0	13:30:00	15:00:00
5b7dd7ce-e5ff-4230-a057-b9c093fef461	2026-05-14	3.00	WORK	Painting, fixing small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	8ba316b3-e1e3-4673-b340-be2f65bf9ce2	0	15:00:00	18:00:00
0c5fe809-a983-420f-8afb-ea70a405d4df	2026-05-15	4.50	WORK	Pannor, nok	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	15:00:00	19:30:00
147adc9f-3239-4044-8696-921551e3cf1c	2026-05-15	0.50	WORK	Vakaflex near ränna old roof and new roof	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	19:30:00	20:00:00
28d2ff93-9ef9-4384-872f-5375269773c0	2026-05-14	5.50	WORK	Vindskivor plåt, pannor, cutting panna	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	07:30:00	13:30:00
866817fd-ee79-43b3-8d7c-afa3351068a4	2026-05-16	5.00	WORK	Cleaning tiles from dust, glue nokband, do nok on main roof, on triangle part, fill empty spots with tiles, lifting tiles from pallets on ground, putting down tiles with defekts and cutting or broken one. Total cleaning all scaffolding and around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	60	10:00:00	16:00:00
4abd45f0-8c0c-4e7e-8705-ca11c8b5b18a	2026-05-18	8.00	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	16:30:00
0a460c44-d273-464e-b3e0-0754d655c550	2026-05-19	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
769a74d9-8b56-4531-bb61-4efdb222103e	2026-05-15	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
118c78de-21bf-4c52-ac36-a90f79547d40	2026-05-14	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
6e8e847e-7d56-48a7-bce8-aac20354d355	2026-05-13	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
b3c1b267-bfbd-41b0-8b48-b0022d99cc3d	2026-05-07	8.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	17:00:00
50b410a9-cddb-48f0-b067-a80db0afb673	2026-05-12	7.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	16:00:00
0d80b9e1-7b7f-472b-a7f3-7c79e5ba78e6	2026-05-11	7.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	16:00:00
353efbfc-5fd4-41b4-8ec9-49baba2684ed	2026-05-08	7.50	WORK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	16:00:00
81447965-50b8-4aeb-bd76-095c45c82ec7	2026-05-19	11.00	WORK	Demolition tiles and leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	08:00:00	19:30:00
f1f96e25-3ac2-4d53-8ca8-e48356549177	2026-05-19	7.00	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	60	08:00:00	16:00:00
727d7b84-556a-44aa-a77e-a667f2207a15	2026-05-20	8.00	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	15:30:00
eb967b90-6064-48b8-ae7d-61915fdd8abb	2026-05-20	8.00	WORK	Demolition, papp, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	15:30:00
f760c3a1-9521-4f00-8891-ded2b62e8777	2026-05-18	8.00	VAB		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
10e6a084-3178-4754-8775-eac8e073b407	2026-05-19	8.00	VAB		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
27b57601-96b8-4167-a1b9-97ff5345ef6a	2026-05-20	8.00	VAB		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
1f2c62a8-4b0e-4bef-a833-95bae132e137	2026-05-21	6.50	WORK	Rivit 	db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	14:00:00
e431aac0-95e8-4c0e-a077-c01745624452	2026-05-21	6.50	WORK	Demolition papp and leghts, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	14:00:00
06454c99-0164-46c0-8b0c-38c35294752d	2026-05-21	5.00	WORK	Tiles, ladder 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	14:00:00	19:00:00
6fa538a9-7ebe-40fa-a49a-f971144ff382	2026-05-21	6.00	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	14:00:00
5f0ad3b2-965b-41c1-bbbd-475f1d478be8	2026-05-22	6.00	WORK	Demolition, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	13:00:00
641702a3-8ab7-4b80-869d-046ce17deeca	2026-05-22	1.50	WORK	Ledder, nok connection, tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	30	13:00:00	15:00:00
f1d9c700-c585-4e1e-aef5-3a9f8b798d9d	2026-05-22	2.50	WORK	Papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	15:00:00	17:30:00
a07b5989-f879-4799-ba5a-12dc348cc019	2026-05-22	8.00	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	09:00:00	17:30:00
06c9e3ae-736c-4dc4-bd7f-63bdbf861812	2026-05-23	5.50	WORK	Papp, tape on connections, pappspiks on the  top pappconnection, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	11:00:00	17:00:00
dbdfc14e-8bcb-4eb5-865a-c920c29c80b6	2026-05-25	9.50	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	17:30:00
67d083ad-f6ee-4f9c-b228-b6640ea37437	2026-05-26	7.50	WORK	Läkts, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	15:30:00
f2b2af89-b642-499f-9ccf-c8aeec1791f8	2026-05-25	8.50	WORK	Rivit 	db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	16:00:00
ce61ca85-2f8b-4d4b-ab9a-c9b2cc7a7b3e	2026-05-26	8.00	WORK	Läktat	db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	15:30:00
b9c351d4-13e8-4412-a318-becca32d5267	2026-05-27	7.00	WORK	Läkts, ränna hooks, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	08:00:00	15:30:00
fe5fb700-3298-45dd-8152-0b1117d2f251	2026-05-27	12.50	WORK	Unloading materials, papp, tape, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	08:00:00	21:00:00
7a81055c-21da-44c3-905c-05048baea082	2026-05-27	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	9c5b8aea-784b-4166-80f9-f26b8c6799f0	30	08:00:00	16:00:00
faa06845-8ac4-4511-aeb7-ec98d507d410	2026-05-28	6.50	WORK	Papp demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	cef60249-2727-476e-bd94-4d3e9dd03916	30	07:00:00	14:00:00
545d917b-018c-4a4b-b71c-dbc30136bbbe	2026-05-28	5.50	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	cef60249-2727-476e-bd94-4d3e9dd03916	60	07:00:00	13:30:00
c4e1ec4e-68c3-4468-90ea-9455114e1635	2026-05-28	6.50	WORK	Läkts, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	0	14:00:00	20:30:00
a3258a85-8b78-4dea-b468-4a6ba7b89611	2026-05-28	6.00	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	14:00:00	20:00:00
e1e0e2e7-d349-4f44-828c-45f193d6fcda	2026-05-26	2.00	WORK	Cutting avlop, change rospond	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	09:00:00
41357b04-de0d-4125-b3f4-12a24537c15e	2026-05-25	11.00	WORK	Change few spots rospond on roof, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	09:00:00	20:30:00
8186de20-2641-4b96-b985-b3c43f8b1baf	2026-05-23	0.50	WORK	Rabygatan 13A- demolition and change rospond 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	10:30:00	11:00:00
7fc79b7d-9aaf-490a-9d7f-83c97512397a	2026-05-23	2.50	WORK	Rabygatan 13B- demolition and change rospond on few spots	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	08:00:00	10:30:00
b85dae72-5798-431d-ba3e-f6169638dbc2	2026-05-29	2.50	WORK	Cutting tile for Marek, montera pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	07:00:00	09:30:00
085a8393-0c9d-4b17-a1ab-cceaf2a100d2	2026-05-29	10.00	WORK	Ränna. Läkts	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	09:30:00	20:00:00
beb7260e-7e06-423c-81ec-00dcb69ecc23	2026-05-29	2.50	WORK	Cutting, drill and install tiles around front takkupor 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	f39a9a5a-1b8e-48e1-bb05-cfa9d9857b79	0	07:00:00	09:30:00
c15f2ff9-9b86-4323-8e5d-85dd49a88d92	2026-05-29	10.00	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	09:30:00	20:00:00
a7438d81-69c9-4c5f-a1c1-741c60d48971	2026-05-30	4.50	WORK	Megure, läkts, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	0	13:30:00	18:00:00
2ea021ae-746c-40df-9a93-f1ca801bd758	2026-05-30	7.00	WORK	Leghts, papp edges regel, nok	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	09:00:00	16:30:00
20ef924d-a925-43e1-9591-636f1aaf43eb	2026-05-30	1.00	WORK	Rabygatan 13B- mogelstop 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	16:30:00	17:30:00
b598051e-0af1-4116-8744-48988e2664e5	2026-06-01	6.50	WORK	Unloading tiles, windhuivas, fogelband, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	10:00:00	17:00:00
de6f01de-9681-44ad-8a1a-49e5dd8526fd	2026-06-01	3.00	WORK	Rabygatan 13A-mogelstops	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	17:00:00	20:00:00
bd75834f-fc5f-4552-b146-3df49c09bf94	2026-05-28	6.50	WORK	Rivit 	db131598-bdda-42c3-936d-27229529abfb	cef60249-2727-476e-bd94-4d3e9dd03916	30	07:00:00	14:00:00
a9d5bb2d-1cbe-4863-98a9-9d2363053643	2026-05-29	5.00	WORK		db131598-bdda-42c3-936d-27229529abfb	9c5b8aea-784b-4166-80f9-f26b8c6799f0	0	07:00:00	12:00:00
d5a92b05-8c5b-423a-80e1-a00205dc1424	2026-05-29	3.50	WORK		db131598-bdda-42c3-936d-27229529abfb	cef60249-2727-476e-bd94-4d3e9dd03916	30	12:00:00	16:00:00
63be4123-bcf6-4ba5-a7d4-e5f414c27504	2026-06-01	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	cef60249-2727-476e-bd94-4d3e9dd03916	30	07:00:00	14:30:00
2c0aa18e-9867-41ba-9a91-a7819b182c1d	2026-06-02	4.50	WORK	Install windhuivas, painting, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	16:00:00	20:30:00
299972bd-932d-4636-be82-d88107f05f74	2026-06-02	13.00	WORK	Ränna hooks, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	20:30:00
3d4cedb6-1c78-404a-9c71-bdf227bdcdce	2026-06-01	6.50	WORK	Receiving tile, ränna	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	0	07:30:00	14:00:00
f4e45a4f-46da-4b45-88b5-f1d1a3c2ae1e	2026-06-02	6.00	WORK		db131598-bdda-42c3-936d-27229529abfb	cef60249-2727-476e-bd94-4d3e9dd03916	0	08:00:00	14:00:00
64b07041-f808-48cf-97e8-942544def921	2026-06-03	6.50	WORK	Montera ränna, futplåt, fix small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	14:30:00
443e01bd-966e-4dc8-ae49-8798b68176e9	2026-06-03	6.00	WORK	Leghts, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	14:00:00	20:00:00
8d13f586-9f8a-435d-b85b-ad1c6c755556	2026-06-04	7.00	WORK	Ränna finish, futplåt, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	14:00:00
41a775b5-cbdb-4633-af8b-a217d40ac5b2	2026-06-03	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	15:00:00
4f735541-f110-4596-8b3f-d247047f058b	2026-06-04	11.50	WORK	Leghts, fogelband, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	08:00:00	20:00:00
cea052f5-9d77-4e3a-b770-3bd4b75df8c4	2026-05-20	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
e82443a1-3aeb-4d4f-95b4-0ac64cf8a2b2	2026-05-21	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
31894800-d810-40b8-a6c3-24956bf0afb3	2026-05-22	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
5068529d-9224-4499-9eea-d5057df52b5c	2026-05-25	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
0257e6b3-2073-4877-8792-01ac94ff32e8	2026-05-26	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
7112601d-0319-42a4-b169-a3893ce70d73	2026-05-27	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
a32b36d6-86ae-45df-a5b8-28e98b0dcf6d	2026-05-28	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
9eac08df-602c-4986-9a24-77caf506b03a	2026-06-01	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
6e850597-2754-468f-a23b-ca5621694f39	2026-06-02	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
45ba8b1b-5cc7-4af6-a92b-8356ea9b4808	2026-06-03	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
a4a244c3-c8b6-4085-992e-45da32ce9f80	2026-06-04	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
c88107e9-22d5-4a37-813c-683c9dc820cc	2026-06-05	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
97ffd2a7-9e02-438e-b289-d9d2126ec0ba	2026-05-29	8.00	SICK		7f7fff21-8568-4d80-bec5-77001d7bbf7d	\N	0	09:00:00	17:00:00
8100946e-68d5-4389-9e36-32a900899447	2026-06-05	6.50	WORK	Futplåt finish, vindskrivor plåt, stoprör	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	30	10:30:00	17:30:00
b817eee0-db7c-4682-8b34-276ed20a7a9e	2026-06-05	12.50	WORK	Ovlops, nokregel, nok, fogelband, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	20:00:00
9e3367ae-972c-4fe2-bff2-b4912cb2b49b	2026-06-06	10.50	WORK	Hanging leghts on top takkupors front and back sides, fogelband, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	08:30:00	19:30:00
7160ffa3-368b-46a5-8867-e9d9d248dc1c	2026-06-05	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	15:00:00
2c6b668b-06b5-43dc-b8f2-404ab9f46e8e	2026-06-08	13.00	WORK	Demolition, läkt, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	6cfb6350-300e-4727-82c2-96cd431e9425	30	07:00:00	20:30:00
74189ec4-a5c4-46a5-a856-b4413c7bd524	2026-06-08	12.50	WORK	Demolition, papp, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	30	07:30:00	20:30:00
08f61325-0408-4e2a-92cd-48f667cb108c	2026-06-08	8.00	WORK	Rivit 	db131598-bdda-42c3-936d-27229529abfb	6cfb6350-300e-4727-82c2-96cd431e9425	30	07:30:00	16:00:00
03427692-28d0-42be-9b36-91f4fa69d370	2026-06-09	2.00	WORK		db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	09:00:00
8682afb5-e83f-4eb0-9790-c0ad05569d21	2026-06-09	2.00	WORK	Tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	09:00:00
b4e5a482-b947-4e8f-8448-f624ca4044e1	2026-06-10	12.00	WORK	Cutting, drill and install tiles under 8 takkupors, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	07:30:00	20:00:00
d73b1eef-63d2-4ef8-9d9e-fbaac9dbe61d	2026-06-10	12.00	WORK	Vindskrivor, stuprör, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	60	07:30:00	20:30:00
d17237c1-aa98-40b9-9f23-d53f2422f588	2026-06-11	9.50	WORK	Ränna, bärläkt, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	6cfb6350-300e-4727-82c2-96cd431e9425	30	07:00:00	17:00:00
392db0c6-eb60-4e35-8094-247be8a37c09	2026-06-11	10.50	WORK	Cutting and drill tiles around windows and ventilation, install tiles, cleaning scaffolding and around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	18:00:00
64b77a97-c18d-49d9-ac60-f004d31b8fd4	2026-06-10	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	4813a930-e772-4adf-85d8-0448d373f829	30	07:00:00	16:00:00
b8e6aec8-553a-4998-9783-180b7c7ab365	2026-06-12	12.50	WORK	Ränna, futplöt, vindskrovor träd, plåt, painting	90ce269a-9472-4447-86cc-6f1a1519d31f	6cfb6350-300e-4727-82c2-96cd431e9425	30	07:00:00	20:00:00
67972342-9aba-4d83-b016-5249643fa140	2026-06-12	4.00	WORK	Windhuivas, unloading tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	0	07:00:00	11:00:00
871089c2-b936-4787-b2b4-a433eecb79b4	2026-06-12	3.50	WORK	Windhuivas, painting, mogelstops, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	0	16:30:00	20:00:00
3f469653-52a8-492f-b323-08e9929fdf2c	2026-06-13	8.50	WORK	Painting windhuivas second time, install windhuiva, tiles, steps, ledder hooks, cutting tiles around chimney and ovlop, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	30	08:00:00	17:00:00
ecb070ba-2c58-4129-ad93-33c51c5a73ed	2026-06-15	2.00	WORK	Demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	10:30:00	13:00:00
c3a18548-3afa-4537-9c9a-1f2815157ad2	2026-06-15	2.00	WORK	Remove tile, start presening	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	10:30:00	13:00:00
5910b460-fa4d-418f-9c3f-b3632c023d30	2026-06-15	7.00	WORK	Finish vindskrivor, stuprör, chimney 	90ce269a-9472-4447-86cc-6f1a1519d31f	6cfb6350-300e-4727-82c2-96cd431e9425	0	13:00:00	20:00:00
b7929ca7-1fd0-4a67-bb65-278a4c8c45b9	2026-06-15	3.50	WORK	Ovlop, painting 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	0	07:00:00	10:30:00
63a4e9d6-e5e1-49ef-8b29-b0007178ddc8	2026-06-15	7.00	WORK	Cutting tiles around chimney, unloading and install chimney, nokregel, nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	6cfb6350-300e-4727-82c2-96cd431e9425	0	13:00:00	20:00:00
194f19cc-3be9-4ccb-882f-3f73119daf35	2026-06-15	7.50	WORK	Rivit	db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	08:00:00	16:00:00
4e7bfe2e-6ab2-4722-bd12-0d705f167634	2026-06-16	14.50	WORK	Demolition, karton, rospond, papp, cleaning around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	22:00:00
97b42d1a-0987-417b-9b2a-dda6306b1434	2026-06-16	9.00	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:30:00
17b9acec-c5fa-4a2c-b2d5-234716ca6b4c	2026-06-17	13.50	WORK	Demolition, finish montera råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	21:00:00
40ec9fdf-a7fe-4b65-a134-a98d62abcd72	2026-06-17	13.50	WORK	Rospond	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	21:00:00
c234ddbb-bab7-4b68-8350-43be4cd97e32	2026-06-18	10.50	WORK	Papp, evrething, fönster plåt	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	18:00:00
7a4de4ba-4633-4551-816a-63d1aaf959a5	2026-06-18	10.50	WORK	Rospond, papp, leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	18:00:00
dc302466-3b09-4fc1-92ca-a9d94ead8752	2026-06-19	1.00	WORK	Megure roof for bärläkt	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	15:00:00	16:00:00
163ff3c1-8a98-4fd7-abbc-23c5b00c2519	2026-06-19	5.50	WORK	Montera pannor, cutting	90ce269a-9472-4447-86cc-6f1a1519d31f	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	09:00:00	15:00:00
825177b1-7eb9-46f2-ab71-48bc520bcb51	2026-06-19	5.50	WORK	Lifting tiles, install tiles, gluing tiles and preparing for cutting around window 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	30	08:30:00	14:30:00
09e72d1b-2ebd-4de2-8e54-f827605d213e	2026-06-19	2.00	WORK	Shooting lines, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	0	14:30:00	16:30:00
58aa0827-9406-4086-9716-3bcb73df6fc0	2026-06-19	2.00	WORK	Cutting tiles around window, fill tiles around window, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	284d06c0-f938-40ae-8ef1-aa1d3e354eb9	0	16:30:00	18:30:00
168b5206-b698-4933-a5d2-7ebcbd37b1f3	2026-06-20	8.00	WORK	Leghts, stempling and cutting papp both sides on trekants, cleaning scaffolding and around the house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	10:00:00	18:30:00
ef0883c0-0149-4019-bac5-7578f493334c	2026-06-17	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:00:00
236b7bc9-4326-4f53-9854-47db650d782d	2026-06-18	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	15:00:00
f35c8480-b6c0-48bf-8811-995d95190ce9	2026-06-22	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:00:00
18630924-ea54-40e3-8159-cacb9a553911	2026-06-22	1.50	WORK	Fix taping windows	90ce269a-9472-4447-86cc-6f1a1519d31f	4813a930-e772-4adf-85d8-0448d373f829	0	07:00:00	08:30:00
e143c569-702b-484d-b82d-0c4bc07f8b9d	2026-06-22	4.50	WORK	Megure roof for bärläkts, vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	10:30:00	15:30:00
45ffcf75-683c-4483-ac53-76bc3b178089	2026-06-23	8.50	WORK	Ränna, futplåt, vindskrivor träd	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:00:00
46a4d439-447f-4e43-a3e4-e8d7e2efbd05	2026-06-24	8.50	WORK	Vindskivor träd, ränna, megure roof for tile, stuprör	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:00:00
497be085-5c1e-46eb-86be-d970cbeb91e8	2026-06-16	13.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	08:00:00	21:30:00
f412cd83-6a5f-4550-a6de-63bb15daa710	2026-06-24	5.00	WORK	Windhuivas, painting windhuivas, fogelband, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	07:30:00	13:00:00
d1b27b7f-9add-41a9-95e3-6242022ab9d3	2026-06-23	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	16:00:00
e479916a-1f6e-47dd-87b9-e2861711ed0c	2026-06-22	4.00	WORK	Painting windhuivas, fogelband leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	120	10:00:00	16:00:00
f3b8e49d-f318-41e3-8f35-c9cc89c28898	2026-06-23	12.00	WORK	Windhuivas, fogelband, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	19:30:00
1b4dc6de-395b-4fde-abe5-e3f6209898cf	2026-06-25	8.00	WORK	Vindskrivor plåt, vindskrivor plåt och träd på kuppor, stuprör, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	15:30:00
6b0a440e-786a-4e5f-84e1-43a3124ab2be	2026-06-26	4.00	WORK	Delivery tile, monteta tile	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	08:30:00	13:00:00
b4d0297b-843d-4fdb-9d43-7a6d7dd34066	2026-06-26	4.50	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	30	08:00:00	13:00:00
86b3bbcc-ab20-4d24-b311-2b4576eeee03	2026-06-29	10.50	WORK	Cutting tike, montera tile, fix window, clean	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	60	07:00:00	18:30:00
f2356bcb-1033-4a24-a164-6a7afc8aa752	2026-06-26	0.02	DAY_OFF		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	08:00:00	08:01:00
6ed85626-c03c-4b8b-90a3-b0131108e1a9	2026-06-30	4.00	WORK	Cleaning, finish small stuff on roof	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:00:00	11:30:00
2bc019bf-ede2-43df-b145-902218d08eb8	2026-06-30	3.00	WORK	Cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d949002a-7479-4680-b874-f55ea62f594f	30	09:00:00	12:30:00
d81f9f53-e86a-4237-8d61-bf6837af20df	2026-07-01	2.00	WORK	Tools, demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:00:00	09:00:00
4d248f90-79aa-4a7a-aed4-1bb73b50d646	2026-07-01	1.50	WORK	List, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:30:00	09:00:00
4f82e5a8-f6b5-4712-83d2-425bcf09d3a7	2026-07-01	2.00	WORK	Fixat verktyg o rivit	db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:00:00	09:00:00
911da036-ae20-4945-9de7-6cb92c89e778	2026-07-01	4.50	WORK	Demolition, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	11:30:00	16:30:00
51550daa-1bf3-4d79-b82d-9c8c507e4f51	2026-07-01	4.50	WORK	Rivit 	db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	11:30:00	16:30:00
4907cce6-94b3-4b5b-bdb5-aa69d6dcd5bc	2026-06-30	5.00	WORK		db131598-bdda-42c3-936d-27229529abfb	d949002a-7479-4680-b874-f55ea62f594f	0	07:00:00	12:00:00
6ad6e351-1f5e-4225-a465-79111a17f273	2026-06-29	8.00	SICK		db131598-bdda-42c3-936d-27229529abfb	\N	0	09:00:00	17:00:00
33a1ec30-4e13-43eb-abe7-82fcbc5625e7	2026-07-01	2.50	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	13:00:00	16:00:00
c17c5960-3c38-407a-aff6-f40ead6e261b	2026-07-02	6.50	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:00:00	13:30:00
06aee46d-6da5-49bf-9568-1c8660c92d8c	2026-07-02	6.00	WORK	Demolition, papp, rospond, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:30:00	13:30:00
d8fc39ca-5cb8-4629-a7fa-9499b536e7d3	2026-07-02	6.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:30:00	13:30:00
bdeff1ab-0e4d-4ccc-8e6f-e05c701e4676	2026-07-04	9.50	WORK	Demolition, montera window, precening	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	17:30:00
beb4d543-62e1-42bb-a057-16ddd7b75aaa	2026-07-03	0.02	DAY_OFF		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	08:00:00	08:01:00
9b909f83-d902-426c-a641-3b6ed7699b24	2026-07-04	9.50	WORK	Install window, demolition, papp, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	17:30:00
19a83ba3-f55d-48b1-87d2-a0bd2100e447	2026-07-06	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:00:00	15:00:00
003abfaa-9635-4683-aa90-b48adc2ce598	2026-07-06	6.50	WORK	Läkts, megure, demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	14:30:00
9a6426e2-6044-4604-bcd1-ba812a111563	2026-07-06	7.00	WORK	Demolition, papp, leghts, preceiling, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:00:00	14:30:00
a3956ad1-481f-45e5-8b88-d865ab7e829e	2026-07-07	0.02	DAY_OFF		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	08:00:00	08:01:00
ed7dc8ef-0cd2-4909-bb6d-406410ebfecf	2026-07-08	9.00	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	17:00:00
4efd2978-70aa-4c37-a75f-5277c9834975	2026-07-09	4.00	WORK	Changing råspond, buying it	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	30	07:30:00	12:00:00
523bebf5-1190-4300-8a0c-52334f121cc9	2026-07-09	4.50	WORK	Rospond 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	cef60249-2727-476e-bd94-4d3e9dd03916	0	07:30:00	12:00:00
a973e9f5-b085-4ed2-92d4-d38117d2ad6e	2026-07-09	3.50	WORK	Demolition metal bottom part takkupor, cutting and taping papp rendal takkupor and around chimney, leghts, front pannel, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	12:00:00	16:00:00
28fd024d-c8ea-4d20-b3bc-4bc3b6db79cc	2026-07-09	3.50	WORK	Ränna hooks	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	12:00:00	16:00:00
7ddb1788-b755-40da-b487-d10a889b02fe	2026-07-10	2.50	WORK	Ränna, megure bärläkts	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	0	07:00:00	09:30:00
c5dfd7bc-1fcf-4414-a6e2-7aa44e8a9d3f	2026-07-09	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	cef60249-2727-476e-bd94-4d3e9dd03916	30	07:30:00	16:00:00
904fa268-300d-410d-8f53-24536f4d3c57	2026-07-10	7.00	WORK	Windhuivas, painting, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	08:30:00	16:00:00
b0bf504b-6336-4dc9-befd-13b4a101abf2	2026-07-10	3.00	WORK	Futplåt, ränna hooks	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	0	13:00:00	16:00:00
b2256a32-19ff-47f6-b4c8-5ed1cebda542	2026-07-10	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	16:00:00
7b06ebee-da14-43fc-8adb-241a9f32bb2f	2026-07-13	9.00	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:00:00	16:30:00
52f072d4-c231-4bba-8a45-eac80aea8ce0	2026-07-13	2.50	WORK	Delivery car and råspond with ränna to project	90ce269a-9472-4447-86cc-6f1a1519d31f	cef60249-2727-476e-bd94-4d3e9dd03916	0	07:30:00	10:00:00
c74f395f-f51e-4f16-bf05-b974a581ef10	2026-07-13	4.50	WORK	Ränna hooks all	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	13:00:00	18:00:00
6b82874d-ae5f-4a12-87be-ac54e0f876d9	2026-07-13	9.00	WORK	Tiles, leghts, fogelband, footplate 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:00:00	16:30:00
c849bbe9-b9c7-484d-b995-8c420f277ff5	2026-07-14	7.50	WORK	Papp, ränna, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	cef60249-2727-476e-bd94-4d3e9dd03916	30	07:30:00	15:30:00
73528fbd-101e-4986-9cd9-90d47574f7c8	2026-07-14	8.00	WORK	Tiles, renna, footplate, fogelband 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	16:00:00
0915f0a8-4f23-4adb-8db0-77a3b31b1f19	2026-07-15	0.02	DAY_OFF		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	08:00:00	08:01:00
d1e2fb2b-a0bc-4c08-a728-c436b63172ca	2026-07-14	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	16:00:00
aa796b6b-88ea-4495-8e47-11fb80e5879a	2026-07-15	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:00:00	16:00:00
3d7a361e-b703-4e98-a1eb-0e9365c333b4	2026-07-15	8.00	WORK	Stuprör, vindskrivor plåt, tile	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	16:00:00
2226b3d8-cef0-4d67-bd1b-ad307856ff5e	2026-07-16	8.00	WORK	Demolition, tile, precening	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	16:00:00
ee8d4e46-457f-47c9-9cc4-5d7ddd578b0e	2026-07-16	7.50	WORK	Demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	16:00:00
756ede1f-0b39-42d4-8de4-f7b03b016beb	2026-07-16	7.50	WORK		db131598-bdda-42c3-936d-27229529abfb	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	16:00:00
30ade964-dd23-4f2f-9cb5-c2a45ddfc452	2026-07-17	8.00	WORK		db131598-bdda-42c3-936d-27229529abfb	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	16:00:00
7c52170c-7206-4a54-ab76-159dc944d487	2026-07-17	7.50	WORK	Demolition, montera råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	16:00:00
9e937236-50b2-4409-a475-b8316ef760bb	2026-07-17	8.50	WORK	Demolition, install rospond, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	16:30:00
ac317394-e37b-42c9-a062-8fa9a2dec2d9	2026-07-20	11.00	WORK	Tile, rendal, fix bottom tike, cleaning	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	19:00:00
ab5a2451-f430-4973-a68e-04dfa4b55694	2026-07-08	5.50	WORK	Demolition, läkts, tape	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	60	07:30:00	14:00:00
9ba0ff9e-38a1-4c56-a2cb-3baf4b483fab	2026-07-20	11.00	WORK	Rendals takkupor, tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	19:00:00
ac9ed4bc-afe5-4dff-a5b7-c393931fe615	2026-07-21	10.00	WORK	Papp, paint, lekts	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	17:30:00
9ee5a414-f29e-45ae-bed9-879572d156c8	2026-07-21	8.00	WORK	Rospond bottom part, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	09:00:00	17:30:00
d9cc8215-290e-4c4a-a88a-ba38eec212de	2026-07-11	1.00	WORK	Ränna, läkts on kuppor	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	0	10:00:00	11:00:00
a90314df-de54-42b8-896e-31d4d3b8f5db	2026-07-22	7.00	WORK	Leghts, cutting papp - sides, painting, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	60	07:00:00	15:00:00
50cc18ef-b8db-4dad-9708-2c91a3188f30	2026-07-23	9.00	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	17:30:00
47662cd7-5ef7-4164-a973-d22d4cf42472	2026-07-23	8.50	WORK	Demolition, rospond, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:30:00	17:30:00
fbe655e2-2230-4321-85f7-8ead8466086c	2026-07-24	14.50	WORK	Demolition,  papp	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	22:00:00
9e635d05-5cef-49b7-afc3-654ea2a05eff	2026-07-24	14.50	WORK	Demolition, rospond, papp	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	22:00:00
dd954abf-0889-43b3-a2b2-2faf0cac98db	2026-07-27	5.50	WORK	Lekts, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	14:00:00
ada72ee6-2882-41c8-a567-bd8400bc6f5d	2026-07-27	5.50	WORK	Leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	14:00:00
fb55b951-ef20-4cba-870a-4ed2a3f1b5f3	2026-07-28	0.02	DAY_OFF		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	08:00:00	08:01:00
c31851df-70d9-4cec-8e21-01902a83f9ab	2026-07-28	10.00	WORK	Leghts, windhuivas, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	17:30:00
162385ce-9352-4485-a563-61dfb509590d	2026-07-29	8.50	WORK	Ränna hooks, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	60	07:30:00	17:00:00
19ba04b0-cf20-45c4-858b-58b7f1278a68	2026-07-30	4.00	WORK	Ränna, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	0	08:00:00	12:00:00
48ec2028-2a97-4811-8b37-1964a5b81933	2026-07-29	10.00	WORK	Leghts, taping, painting windhuivas 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	17:30:00
f6c08ce0-88de-4478-9263-942e49487c58	2026-07-30	0.02	DAY_OFF		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	08:00:00	08:01:00
9cc5324b-d8fe-4da6-8d32-083a528d6418	2026-07-31	3.50	WORK	Mogelstop, fogelband 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	07:00:00	10:30:00
8cfab54e-cfb1-46e6-a72a-b71fb095d077	2026-07-31	4.00	WORK	Fogelband, footplate, painting 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	14:00:00	18:00:00
1a5b7e91-79cc-478b-a966-225d1a89c243	2026-07-31	7.00	WORK	Ränna finish, futplåt, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	15:00:00
d9d5354b-3181-4f1d-ae0b-0d27ad9564fd	2026-08-03	9.50	WORK	Vindskrivor plåt, futplåt, megure, tile, talk to owner 	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	17:30:00
f28fd083-a272-4fea-a66b-252fef571da9	2026-08-04	2.00	WORK	Unloading tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	07:00:00	09:00:00
c373d87b-85ce-4ac0-b4e9-aeb5ad9348c1	2026-08-03	5.00	WORK	Leghts, cutting windhuivas 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:00:00	12:30:00
ba8ffb72-7704-4d3a-b550-be3e56833297	2026-08-04	9.50	WORK	Tile, unloading tile, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	17:30:00
b284def6-7305-4271-b279-3d7ec9caf5bc	2026-08-05	6.00	WORK	Loading and cutting tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	11:00:00	17:00:00
64f672d8-46ed-4098-8694-af2ae51314bb	2026-08-05	4.00	WORK	Nock, tile, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	0	12:00:00	16:00:00
b4622285-4768-4c93-b2cd-d4d81abb0075	2026-08-06	1.00	WORK	Nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	09:00:00	10:00:00
f88c5338-0a98-4b57-95f2-db91e568e451	2026-08-06	6.00	WORK	Demolition 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	10:00:00	16:30:00
6cd70910-99c5-47e6-8059-f35ec1e9cea9	2026-08-06	2.00	WORK	Taking down tile, precening	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	14:00:00	16:00:00
11d1546a-c994-48db-a60b-6af5df00e828	2026-08-07	9.00	WORK	Demolition, leghts, preceiling, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	17:00:00
4bb7b9c8-51f9-4f29-8da2-49a3b279e551	2026-08-11	8.50	WORK		db131598-bdda-42c3-936d-27229529abfb	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:00:00	16:00:00
4da096d3-ccf4-4850-b316-412b210e6466	2026-08-12	6.00	WORK	Rändal	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	09:00:00	15:30:00
6d8170f0-dde6-40a5-b7e4-d2b38ed2ebcd	2026-08-11	8.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	16:00:00
cc529c1e-9bdd-4071-98ae-3ab8d7f77242	2026-08-10	2.00	WORK	Rändal	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	0	12:00:00	14:00:00
f8e796de-8b4c-47fd-a261-22607982be8a	2026-08-07	8.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	16:00:00
6ec0a896-d5dc-4ea2-9faf-3c7842f57b56	2026-08-13	7.00	WORK	Rändal, steps	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	07:30:00	15:00:00
49c731a0-edac-437b-a9fb-dea92c5288ae	2026-08-14	6.50	WORK	Läkts	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	60	08:30:00	16:00:00
ff646bbe-d6ec-4a4b-8d78-7a50a7584595	2026-08-15	2.50	WORK	Paint, fix small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	d949002a-7479-4680-b874-f55ea62f594f	0	13:30:00	16:00:00
55560a63-ebe0-495e-9188-82fc0f4934d2	2026-08-15	4.50	WORK	Nok, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	0	09:00:00	13:30:00
907746f8-cf5e-484c-bb36-37d6060c61dc	2026-08-12	7.00	WORK		db131598-bdda-42c3-936d-27229529abfb	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	08:00:00	15:00:00
78304273-e834-48d9-8004-876fffaccf33	2026-08-17	7.50	WORK	Bärläkts, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	15:30:00
d2059810-f016-4fcd-90d8-e7c8f18891f6	2026-08-18	8.00	WORK	Demolition	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	60	07:30:00	16:30:00
7f394534-7147-40e5-a422-cbeb5bbddece	2026-08-20	7.00	WORK	Ränna, fix some råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	60	07:30:00	15:30:00
290e44de-798e-49d5-be0d-5714c5160892	2026-08-10	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
ad749c6c-6bcf-46f0-b32c-84feec8ae71b	2026-08-11	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
d824e279-b8be-4554-9d03-f089b9bad4c1	2026-08-12	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
6e551073-d1ff-4827-86db-922589160d1b	2026-08-13	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
e097fb11-0fdb-425a-b0d8-a5da3b77cf2b	2026-08-14	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
dab58934-ede4-4f84-81d8-22cccf6d3bae	2026-08-17	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
04f15cb8-872b-4b19-9e23-7426077c3673	2026-08-18	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
06d875e7-23f3-40e1-be18-c0634100ef3d	2026-08-19	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
b3e80f71-887e-486f-8172-af5cdbeee61c	2026-08-20	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
93ac3c84-a9bc-434f-82a1-f2fa91a481e5	2026-08-21	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
209bba93-1137-41be-ba10-d19718dff663	2026-08-21	3.50	WORK	Taking window from derome to Vellinge, stuprör hamare hollare buy in Bevego. Paint bottom vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	07:30:00	11:00:00
2927d0ae-b5e1-4df4-ab0f-7d3938c10a88	2026-08-24	8.00	VACATION		2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	\N	0	09:00:00	17:00:00
a93eb73c-ff9e-4f39-a184-e1d74b17cf0a	2026-08-25	5.00	WORK	Demolition leghts and papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	13:00:00
a3720762-a6e4-476a-918b-35bb527078b4	2026-08-26	8.00	SICK		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
f977ca31-fe2b-46bc-aff6-e3436ce2a359	2026-08-27	3.50	WORK	Åvlop, injection net, silicone holes, delivery connectors for åvlop	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	4813a930-e772-4adf-85d8-0448d373f829	0	07:30:00	11:00:00
ea5db1a3-6199-4476-8ce9-f1e5fc5b268b	2026-08-25	8.00	SICK		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
f311aa68-09d8-41f8-a355-79623a1080ef	2026-08-27	7.50	WORK	Fixing tile, stuprör, montera bottom vindskrivor part, delivery window	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	08:00:00	16:00:00
182c4eac-aafe-457e-9af5-7bfa31ed1771	2026-08-27	7.00	WORK	Papp, safety leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	15:00:00	22:00:00
2f43feed-ef6e-4fb9-bf36-162c1e47f407	2026-08-28	6.00	WORK	Demolition, papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	14:00:00
542937b7-8c47-4388-b228-cc1e437830c3	2026-08-28	2.50	WORK	Frame around window, tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	1238abd9-6257-47ca-bfff-fba910c6c953	0	14:00:00	16:30:00
21f67767-7d3d-4d67-9916-02e6fe66717e	2026-08-28	7.50	WORK	Fix window, fix stuprör	90ce269a-9472-4447-86cc-6f1a1519d31f	1238abd9-6257-47ca-bfff-fba910c6c953	30	07:30:00	15:30:00
fa98b245-138e-40aa-bd24-a4bb957829c1	2026-08-29	9.50	WORK	Demolition, papp, rospond,leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	09:00:00	19:00:00
c2d03923-3d5c-48a9-a769-8c138fe9694c	2026-08-31	7.50	WORK	Ränna, futplåt	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	15:30:00
e7e3ad03-fc5d-4eb8-bd5e-78c3f7df14b2	2026-09-01	1.50	WORK	Delivery tools 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	07:30:00	09:00:00
8084a208-c28d-4689-b271-6e5f43001deb	2026-09-02	4.00	WORK	Footplate, leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	07:30:00	11:30:00
3b5dc15c-5694-4b3a-9d95-53ab1118edb7	2026-09-02	2.50	WORK	Change broken tiles, fix bridge, cleaning scaffolding and around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	bbffade8-2151-4c8d-bb24-df1b0d515203	0	14:00:00	16:30:00
6905b565-280a-4b14-9311-dc62af70b2eb	2026-09-02	7.50	WORK	Tile, futplot,  läkts	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	15:30:00
49c09bbb-cf2b-45cc-ae6c-507f3646fbfc	2026-09-01	8.00	WORK	Finish ränna, montera pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	16:00:00
16566d54-fc5c-425a-8ecb-8f16ac990a0e	2026-09-03	3.50	WORK	Montera tile	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	07:30:00	11:00:00
cf3ed653-b520-4dbb-9279-7a74e120e45b	2026-09-15	7.50	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	07:30:00	15:30:00
a7210fe0-752f-483f-bb5b-21cdcbed7929	2026-09-15	12.50	WORK	Demolition tiles, leghts, do papp, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	10:00:00	23:00:00
d100e654-b6d4-45df-a015-b51b68f955d4	2026-08-31	9.50	WORK	 fogelband, papp takkupor, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	17:30:00
167606bf-bbcf-48de-a77c-9f8222879732	2026-09-03	6.00	WORK	Delivery materials,footplate,fogelband trekant, leghts,nokregel, cleaning around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	12:30:00	19:00:00
aefd0412-76cc-4cb0-aeeb-e3dcd536e2ae	2026-09-04	6.00	WORK	Tile	90ce269a-9472-4447-86cc-6f1a1519d31f	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	14:00:00
8462c432-2253-4520-816f-263b67d3b705	2026-09-04	11.50	WORK	Lifting and installing tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	07:30:00	19:30:00
c0ca2aa0-908b-484e-b35a-ecf152d3ebfc	2026-09-05	11.50	WORK	Lifting, cutting and installing tiles, nok, windhuivas, cleaning, collecting tools and materials with 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	30	08:00:00	20:00:00
f6dacc2e-7469-403e-b5a6-df2a12fb0f40	2026-09-07	7.50	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	15:30:00
1889af50-333e-412d-8ce1-393d7c4a6709	2026-09-07	15.50	WORK	Demolition, rospond, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	23:30:00
007f2b66-82fe-4345-85d6-47959e1d5b5e	2026-09-08	7.50	WORK	Papp, rospond, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	15:30:00
19ad6028-0620-4140-9abf-65107fc77421	2026-09-08	6.50	WORK	Papp, råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	14:30:00
bf3f87cf-85e9-4bd3-b7a5-685834b85f6c	2026-09-08	1.50	WORK	Buy listva, road, cutting listva	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	0	14:30:00	16:00:00
facc1614-eae0-4a14-9e04-55baa866d15f	2026-09-08	5.00	WORK	1,5 hours - way between projects, picked up ladder and holders in Bevego, 0,5 hours - Lift tiles, 3 hours - install tiles, install ladder 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	15:30:00	20:30:00
3a02445c-965b-40d4-8d42-373a68031138	2026-09-09	6.00	WORK	Buy material for listwa till luka, montera listva	90ce269a-9472-4447-86cc-6f1a1519d31f	bbffade8-2151-4c8d-bb24-df1b0d515203	30	08:00:00	14:30:00
741b6db5-666d-45c2-bc61-28f755e69f62	2026-09-09	5.50	WORK	Bevego, cutting and install tiles (takkupor, åvlop) windhuivas takkupor, painting, windhuiva metal takkupor, total cleaning scaffolding and around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	7ff6c67c-a436-402a-aa4e-a080d8dc21df	0	14:30:00	20:00:00
e24a97de-4c5f-4dbb-8b54-f44fe0a3a02d	2026-09-10	8.00	WORK	Papp, råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	16:00:00
832b932d-1a00-4614-ac3c-c3a041d1b2c2	2026-09-10	12.00	WORK	Rospond, papp, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	20:00:00
87a632c0-2b06-41b7-8829-3900f4f89908	2026-09-16	9.50	WORK	Windhuivas, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	09:30:00	19:30:00
ab3adaba-9a7e-455f-9b72-f37196d880d3	2026-09-11	8.50	WORK	Leghts, painting fogelband leghts and windhuivas 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	16:30:00
98c71b6e-3142-4853-8c91-c66135b1b931	2026-09-11	8.00	WORK	Ränna, megure roof, läkts	90ce269a-9472-4447-86cc-6f1a1519d31f	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:00:00	15:30:00
320dd391-abee-4360-b8c0-dafe81944be8	2026-09-11	2.50	WORK	Windhuivas, renna, footplåt, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	0	17:30:00	20:00:00
7eed610c-4664-4773-9b31-0d63233d5c00	2026-09-12	8.00	WORK	Windhuivas+extra leghts, nok regel and correct top leghts, fogelband, stupror, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	09:30:00	18:00:00
a2aa33a1-bbe1-4292-8185-b78e05d4e462	2026-09-14	12.00	WORK	Unloading tiles, windhuivas metal -sides and top, total cleaning around 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	20:00:00
87b2d7a5-dda8-4037-a9e4-d4e79cb37b85	2026-09-14	7.50	WORK	Vindskrivor plåt, ränna, unload tile	90ce269a-9472-4447-86cc-6f1a1519d31f	ac5d737c-2421-48f2-8e01-e3c4ee638738	30	07:30:00	15:30:00
e9b54312-18c5-47ed-94d9-af0631758705	2026-09-16	7.50	WORK	Ränna, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	07:30:00	15:30:00
f46faf02-30d0-4aa4-b3fc-39a6f30182a2	2026-09-17	8.50	WORK	Ränna, megure bärläkts, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	06:30:00	15:30:00
47bfd73a-b616-4d95-9fbe-2b8662fb9281	2026-09-17	8.00	WORK	Leghts, footplåt 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	07:30:00	16:00:00
97f9ccc9-bbe3-43f9-befd-3decd9e0bc4e	2026-09-18	8.50	WORK	Ränna, futplåt, megure for pannor	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	06:30:00	15:30:00
4191ddd5-1a55-48ff-81a7-dbca49ae5f01	2026-09-18	9.00	WORK	Leghts, painting windhuivas inside and outside parts, painting screws under rospond, nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	60	10:00:00	20:00:00
d3e26e2c-d397-4bd5-8828-816e8031ed4c	2026-09-21	7.50	WORK	Receiving tile, montera pannor 	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	08:00:00	16:00:00
568f4bc1-86a7-4f84-a67a-3d02f35f9333	2026-09-21	12.00	WORK	Unloading tiles, cutting around windows, install, cleaning, collecting all tools with 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	08:00:00	20:30:00
b7cc01a9-f333-4e4c-91b7-c5e9d2437dd3	2026-09-22	6.50	WORK	Montera tile, montera vindskivor, papp ventilation. 	90ce269a-9472-4447-86cc-6f1a1519d31f	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	09:00:00	16:00:00
0ed4db7e-0bb7-4bec-bd37-750d7274a8d2	2026-09-22	1.00	WORK	Buy stuff in shop	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	0	08:00:00	09:00:00
db09005b-01f9-4cc8-bde1-156ad4c9159d	2026-09-22	8.00	WORK	Cutting and install tiles, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	30	07:30:00	16:00:00
59611f30-8844-4c23-a88f-ff18145b8d26	2026-09-23	7.50	WORK	Demolition 	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	15:00:00
e394e03c-4956-48c5-a84c-94e6bf42612c	2026-09-24	8.00	WORK	Demolition,  papp, råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:30:00	16:00:00
8fafc64d-e1c8-4fa1-b4db-dd75277cf4a1	2026-09-24	8.50	WORK	Demolition, rospond, papp, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:30:00	16:30:00
0fe284a3-3e03-4d55-8fc0-7909a5afffbe	2026-09-23	14.50	WORK	Demolition, rospond, papp, cleaning, preceiling 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	22:00:00
285ca5cf-dac4-42b4-a695-f10ec50528f5	2026-09-25	8.00	VAB		90ce269a-9472-4447-86cc-6f1a1519d31f	\N	0	09:00:00	17:00:00
b786d4f1-1f86-4bc6-b0d0-9069713f1423	2026-09-25	6.50	WORK	Do and install steps and tiles, nok regel, nok, windhuivas metal cutting and connecting, cleaning around 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	678c86c5-32e7-4026-95b4-8e6bc404beb3	0	07:30:00	14:00:00
8a7a5949-e77d-448d-bf36-12fb32a580f4	2026-09-25	4.00	WORK	Leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	14:00:00	18:30:00
f006180c-89f1-4fc5-a1d4-f44e021d2430	2026-09-26	4.00	WORK	Painting windhuivas, demolition old windhuivas, fix roof edges, trekants, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	0	14:00:00	18:00:00
b0f144fd-152b-46e2-a77f-ea0fb19acdf0	2026-09-28	8.00	WORK	Demolition,  råspond	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:30:00	16:00:00
e1c16025-3680-4065-a834-d9ba0f3e7c84	2026-09-28	13.00	WORK	Demolition, rospond, papp, preceiling, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	20:30:00
13cfb09b-8401-4a1b-b061-85f9595aaabd	2026-09-29	8.00	WORK	Papp, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:30:00	16:00:00
277171fb-8e2f-45e6-9ec2-8ead399eb4ac	2026-09-29	8.50	WORK	Papp, läkts, megure	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	16:00:00
82a9ab2e-7542-4da8-b9f5-75b516e2d117	2026-09-30	8.50	WORK	Demolition Leons project Norra fäladsvägen 29, Dalby	90ce269a-9472-4447-86cc-6f1a1519d31f	f7e03ed8-6869-4d86-8ced-004a62355f04	30	07:00:00	16:00:00
6fe9b9d3-6776-4de0-97a3-fdff0423d7df	2026-09-30	10.00	WORK	Norra fäladsvägen 29, Dalby- Demolition, papp, leghts, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	e0a08b6f-1955-4fc6-8047-018b57651357	30	07:00:00	17:30:00
ca14bad0-bac2-4b6e-8e85-760b4b565e21	2026-10-01	5.00	WORK	Unloading tile, megure roof for tile	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	0	07:00:00	12:00:00
ac9aa662-b430-4e02-88d0-08222a5f9722	2026-10-01	7.00	WORK	Unloading tiles, painting leghts 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	90	07:30:00	16:00:00
4a641319-5179-4d27-8d77-fa7137b06d24	2026-10-02	6.00	WORK	Ränna, small fixes	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	60	07:00:00	14:00:00
b722d181-2333-4d4d-96d5-8ed700aa3acb	2026-10-02	9.50	WORK	Painting windhuivas, footplåt, delivery, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	60	08:30:00	19:00:00
2b7e4de4-9db0-42d9-bad3-aa0b3242fb16	2026-10-03	12.00	WORK	Fogelband, tiles, nokregel, nok, cleaning, collecting all tools with 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	0	08:00:00	20:00:00
d7bfd9cc-808a-448d-8bfd-21df914c14cd	2026-10-03	5.00	WORK	Ränna, futplåt, vindskrivor plåt	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	0	14:00:00	19:00:00
cadf8382-dc86-4cb8-a2a8-956ee1cec5d4	2026-10-05	7.50	WORK	Paint front panel 2 times, montera front panel, megure roof for tile,	90ce269a-9472-4447-86cc-6f1a1519d31f	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	30	07:30:00	15:30:00
48762805-90ee-4857-8a12-72e80d51bbd8	2026-10-05	6.50	WORK	Windhuivas - install and painting 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	30	10:30:00	17:30:00
4bded0b1-6a40-41ec-927b-5c0490ff5616	2026-10-05	1.50	WORK	Fogelband, installing tiles, glue tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	0	17:30:00	19:00:00
cbd23717-51c1-4a08-a0f5-f07420fb15bc	2026-10-06	3.50	WORK	Unload tile, montera ränna hooks, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	0	12:00:00	15:30:00
589e87eb-a652-429d-927d-5d64b6556909	2026-10-06	8.50	WORK	Fogelband, tiles, rendal, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:30:00	16:30:00
83bca8f4-f241-4259-b765-946ae240226d	2026-10-07	3.50	WORK	Ränna, futplåt, small stuff	90ce269a-9472-4447-86cc-6f1a1519d31f	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	0	07:30:00	11:00:00
0ef5a424-26de-4a0f-9699-18d79d2d793a	2026-10-07	4.00	WORK	Stuprör, vindskrivor	90ce269a-9472-4447-86cc-6f1a1519d31f	d83c0440-0d14-41ac-965a-7155f13d6713	30	11:00:00	15:30:00
76e5740c-2edd-404f-bac3-28ab2f5a03cf	2026-10-07	5.50	WORK	Rendal, tiles, nok	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	13:00:00
194d24a2-7d2e-48e3-9b8d-8ba6b9742cbe	2026-10-08	1.00	WORK	Connecting åvlop pipes, final cleaning around house 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	0	15:00:00	16:00:00
31b9b0a0-101d-471a-a282-d1e933735d02	2026-10-08	6.50	WORK	Install pannels between gåvel and rospond, do windhuivas metal, cleaning on garage and scaffolding 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	d83c0440-0d14-41ac-965a-7155f13d6713	30	07:00:00	14:00:00
320c6ebe-1f0f-4cf7-b3d4-8be3ea7699f9	2026-10-09	7.50	WORK	Ränna, painting shill, montera shill	90ce269a-9472-4447-86cc-6f1a1519d31f	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	30	07:30:00	15:30:00
a5aa8103-1849-424b-9f55-0761f416f6c0	2026-10-09	10.50	WORK	Fogelband, cutting tiles around windows and ventilations, installing tiles 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	30	08:00:00	19:00:00
bfce4958-7553-4f40-8db4-77eee395698e	2026-10-10	5.00	WORK	Futplåt, vindskrivor, stuprör	90ce269a-9472-4447-86cc-6f1a1519d31f	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	0	07:30:00	12:30:00
349a943b-a657-4019-a7d6-1af3420e2dca	2026-10-10	8.50	WORK	Painting windhuivas, fogelband, tiles, nok, cleaning 	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	8fd932a5-3dc1-4bf3-802f-e5285789d8d6	30	08:00:00	17:00:00
\.


--
-- Data for Name: user_salary_history; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.user_salary_history (id, "fromDate", "userId", salary, "salaryNetto") FROM stdin;
3dbe28d4-d1e4-4e9f-b938-def0e8846d74	2026-05-13 17:24:04.755805	2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	200	140
b5fafc58-d1d0-4e3f-b91f-40da0db8b662	2026-05-14 19:47:40.882724	90ce269a-9472-4447-86cc-6f1a1519d31f	230	161
5e979d5e-bbaa-49ea-9820-e06dbb501d04	2026-05-18 17:03:43.602811	db131598-bdda-42c3-936d-27229529abfb	175	122.49999999999999
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, email, password, name, "createdAt", "isAdmin", "updatedAt", "deletedAt", "deletedByUserId", "CanCreateProjects", "SpecialCan", "currentSalary") FROM stdin;
73e12347-84ce-4594-8079-6ad2657eed76	kungen@gmail.com	$2b$10$TG.pcOl.LwkkFO9VS/neauCmQ7vlwY9AxT9hBZyWXApncK/Jw9.ia	King Kuba	2026-10-01 11:30:37.944369	f	2026-10-01 11:30:37.944369	\N	\N	f	f	\N
3dd3a93a-b2d1-4233-8c09-4ed27f121040	quest@gmail.com	$2b$10$RWV2xSdTGAs6OtaK1Va9oexzuDGlKd0tKZ3EW.D.rYSUYc5j7TZ3C	Quest	2026-01-13 10:58:55.931077	f	2026-02-16 19:11:38.524795	\N	\N	f	f	\N
f04e87b0-e010-47aa-ae5d-bfc9aadbe702	volodymyr1988dev@gmail.com	$2b$10$3hX6JMllJiZ51roQ8DXC1OR5JLI6Obinn0ETK.1EdBVaB9hcajFIC	Volodymyr	2026-10-05 16:03:52.531977	f	2026-10-05 16:03:52.531977	\N	\N	f	f	\N
32e07862-815f-46be-9aac-e950a16054b6	test3@gmail.com	$2b$10$YL6RCVTg8Rg95L0Rd/BaY.6.u3vnPZFafuzwew1S8YnBO9gEb5.VO	test	2026-10-05 17:42:57.896562	f	2026-10-05 17:42:57.896562	\N	\N	f	f	\N
7dafa412-ec37-4c54-b149-1bd406b66a3a	grzegorz@gmail.com	$2b$10$9jpnpObHimZEARPeZtCFq.O7wWPc44DlNkWAHUTrsfZfgO/CcCQmq	Grzegorz	2026-02-12 08:26:45.821434	t	2026-02-16 19:11:38.524795	\N	\N	f	f	\N
7f7fff21-8568-4d80-bec5-77001d7bbf7d	jarfjordj@gmail.com	$2b$10$.iQPITRq36Ed3g0P/qvsjOJbajQiQ53nzEOKJI3Detqgc41TuekQi	Josef Jarfjord	2026-01-13 14:13:15.085011	f	2026-10-09 04:48:59.481361	2026-10-09 04:48:59.481361	90ce269a-9472-4447-86cc-6f1a1519d31f	t	f	\N
2aa46110-2419-4565-a490-a0c409e2c196	test4@gmail.com	$2b$10$zSCE5Qv0C0MPebbt.asmAe9JNWM9IH1WS8mEFddA/vkMspa/l6JvO	test	2026-10-10 15:50:48.808527	f	2026-10-10 15:50:48.808527	\N	\N	f	f	\N
3c9a9690-0e31-46bb-a12f-ee4a182f1986	test5@gmail.com	$2b$10$dQXdcHRPGf4cl9o1nldaFuPzdGja2uKlooUAu05XFbQgyZrxjRkya	Test	2026-10-11 16:49:22.884564	f	2026-10-11 16:49:22.884564	\N	\N	f	f	\N
1300c4bb-f1cf-4280-8c90-1224c29952b2	test@gmail.com	$2b$10$gQkvmISpY6Hg/0OWBDj/Zuw5PuSQiUL/C.b5zxHTx2.OHzN/YHMGy	test	2026-02-17 13:22:02.032127	t	2026-02-20 20:18:16.387114	\N	90ce269a-9472-4447-86cc-6f1a1519d31f	f	f	\N
2de92ef3-b2ca-4711-9a28-56cf524edc30	test2@gmail.com	$2b$10$P55Tzes0GR8d43xI6QjB9.zX97WyQeQ1uMdX8AQWbrCmOlwYUkcvu	test2	2026-04-23 06:14:26.225687	f	2026-04-23 06:14:26.225687	\N	\N	t	f	\N
1aa4ec77-a68d-40b4-a01e-c9320f9c0b54	Figo@gmail.com	$2b$10$GLLX4GjL5j3vvGnX1CjVcebqAUtRKS9FjVANlHORZSwzneX0cffyC	Figo	2026-05-07 10:52:21.284376	f	2026-05-07 10:52:21.284376	\N	\N	f	f	\N
2cae625c-d0a9-4959-9089-2cdb3bdfd7cc	dobryyruslan@ukr.net	$2b$10$dFzzRIGqxoJ4FUoc8HeMC.tbCviZCDJSzBYNQjQrSRh62E0dBCtEq	Ruslan	2026-01-12 22:52:18.801808	f	2026-05-13 17:24:05.348766	\N	\N	t	f	200
90ce269a-9472-4447-86cc-6f1a1519d31f	PropertyChernivtsy@gmail.com	$2b$10$zunPoyJuDEIvKTslwVM.O.VXpI8xRt2N.JG.4sSQSGPrf4XHwX0eS	Volodymyr	2025-12-28 15:34:14.757265	t	2026-05-14 19:47:41.509586	\N	\N	f	f	230
db131598-bdda-42c3-936d-27229529abfb	malmoff200508@gmail.com	$2b$10$Zxo5n7f7wGSq0VVT65HEo.PZyaJUf9Z3ezpLknISxrttRUo576pKW	anders 	2026-01-29 07:16:34.334371	f	2026-05-18 17:03:43.710741	\N	\N	f	f	175
\.


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public."User_id_seq"', 1, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.migrations_id_seq', 27, true);


--
-- Name: news_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.news_post_id_seq', 1, true);


--
-- Name: users_sync users_sync_pkey; Type: CONSTRAINT; Schema: neon_auth; Owner: neondb_owner
--

ALTER TABLE ONLY neon_auth.users_sync
    ADD CONSTRAINT users_sync_pkey PRIMARY KEY (id);


--
-- Name: project_assignments PK_045df8f32ae1d54810b39b9c7bd; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT "PK_045df8f32ae1d54810b39b9c7bd" PRIMARY KEY (id);


--
-- Name: sessions PK_3238ef96f18b355b671619111bc; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "PK_3238ef96f18b355b671619111bc" PRIMARY KEY (id);


--
-- Name: project_materials PK_4be35cdf6905d3effc565a82a64; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_materials
    ADD CONSTRAINT "PK_4be35cdf6905d3effc565a82a64" PRIMARY KEY (id);


--
-- Name: projects PK_6271df0a7aed1d6c0691ce6ac50; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "PK_6271df0a7aed1d6c0691ce6ac50" PRIMARY KEY (id);


--
-- Name: project_receipts PK_64cf70a8f0857f21724d9803dca; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_receipts
    ADD CONSTRAINT "PK_64cf70a8f0857f21724d9803dca" PRIMARY KEY (id);


--
-- Name: registration_approvals PK_684da43f336bb8a858a0df6a620; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.registration_approvals
    ADD CONSTRAINT "PK_684da43f336bb8a858a0df6a620" PRIMARY KEY (id);


--
-- Name: project_images PK_7683abb57ed0c0fa8379f54692b; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_images
    ADD CONSTRAINT "PK_7683abb57ed0c0fa8379f54692b" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: User PK_9862f679340fb2388436a5ab3e4; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "PK_9862f679340fb2388436a5ab3e4" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: time_entries PK_b8bc5f10269ba2fe88708904aa0; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT "PK_b8bc5f10269ba2fe88708904aa0" PRIMARY KEY (id);


--
-- Name: project_material_items PK_d2ae9b8b31b3145ddb542c52864; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_material_items
    ADD CONSTRAINT "PK_d2ae9b8b31b3145ddb542c52864" PRIMARY KEY (id);


--
-- Name: user_salary_history PK_dfb4b9c0a9b2ad332a77b9f1ceb; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_salary_history
    ADD CONSTRAINT "PK_dfb4b9c0a9b2ad332a77b9f1ceb" PRIMARY KEY (id);


--
-- Name: news_post PK_f3da2059a86af58f909bded384c; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.news_post
    ADD CONSTRAINT "PK_f3da2059a86af58f909bded384c" PRIMARY KEY (id);


--
-- Name: project_task PK_f8275249858f42bc01e47cb979d; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_task
    ADD CONSTRAINT "PK_f8275249858f42bc01e47cb979d" PRIMARY KEY (id);


--
-- Name: project_materials REL_5400e7b44258b1b9781a0873c2; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_materials
    ADD CONSTRAINT "REL_5400e7b44258b1b9781a0873c2" UNIQUE ("projectId");


--
-- Name: User UQ_4a257d2c9837248d70640b3e36e; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "UQ_4a257d2c9837248d70640b3e36e" UNIQUE (email);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: users_sync_deleted_at_idx; Type: INDEX; Schema: neon_auth; Owner: neondb_owner
--

CREATE INDEX users_sync_deleted_at_idx ON neon_auth.users_sync USING btree (deleted_at);


--
-- Name: IDX_2a32f641edba1d0f973c19cc94; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_2a32f641edba1d0f973c19cc94" ON public.users USING btree ("deletedAt");


--
-- Name: IDX_42d4f2abf614c536382f8d419e; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_42d4f2abf614c536382f8d419e" ON public.project_material_items USING btree ("materialId");


--
-- Name: IDX_4b6d28f4cdc75f1de55b2fa619; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_4b6d28f4cdc75f1de55b2fa619" ON public.sessions USING btree ("lastActivityAt");


--
-- Name: IDX_5400e7b44258b1b9781a0873c2; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "IDX_5400e7b44258b1b9781a0873c2" ON public.project_materials USING btree ("projectId");


--
-- Name: IDX_694170ebc0718ad5420f4192a1; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_694170ebc0718ad5420f4192a1" ON public.news_post USING btree ("createDate");


--
-- Name: IDX_7000e05107037eb10111e87388; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_7000e05107037eb10111e87388" ON public.project_material_items USING btree ("materialKey");


--
-- Name: IDX_97672ac88f789774dd47f7c8be; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "IDX_97672ac88f789774dd47f7c8be" ON public.users USING btree (email);


--
-- Name: IDX_9cfe37d28c3b229a350e086d94; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_9cfe37d28c3b229a350e086d94" ON public.sessions USING btree (expires_at);


--
-- Name: IDX_a4ce7d0df5bb475b9b0c1bc34c; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_a4ce7d0df5bb475b9b0c1bc34c" ON public.news_post USING btree (header);


--
-- Name: IDX_d0b91fcf539def7b9ad50741f0; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_d0b91fcf539def7b9ad50741f0" ON public.registration_approvals USING btree ("userId");


--
-- Name: IDX_df3979bad92d26bcf72e480ad7; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_df3979bad92d26bcf72e480ad7" ON public.news_post USING btree (genre);


--
-- Name: IDX_e59af021a32c359c2d9dcf14cc; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX "IDX_e59af021a32c359c2d9dcf14cc" ON public.sessions USING btree (refresh_token_expires_at);


--
-- Name: project_assignments FK_2de237ae3bf6566e76fa428199b; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT "FK_2de237ae3bf6566e76fa428199b" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: project_material_items FK_42d4f2abf614c536382f8d419ec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_material_items
    ADD CONSTRAINT "FK_42d4f2abf614c536382f8d419ec" FOREIGN KEY ("materialId") REFERENCES public.project_materials(id) ON DELETE CASCADE;


--
-- Name: users FK_4ffb8c41fed6d32b356ae4709cb; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_4ffb8c41fed6d32b356ae4709cb" FOREIGN KEY ("deletedByUserId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: project_materials FK_5400e7b44258b1b9781a0873c2e; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_materials
    ADD CONSTRAINT "FK_5400e7b44258b1b9781a0873c2e" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: sessions FK_57de40bc620f456c7311aa3a1e6; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "FK_57de40bc620f456c7311aa3a1e6" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: project_task FK_5fea8867d69a5edacf7f11b0fce; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_task
    ADD CONSTRAINT "FK_5fea8867d69a5edacf7f11b0fce" FOREIGN KEY ("completedById") REFERENCES public.users(id);


--
-- Name: user_salary_history FK_915b58ee89ccdde417b541709d5; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_salary_history
    ADD CONSTRAINT "FK_915b58ee89ccdde417b541709d5" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: project_receipts FK_92d0bda0a82dcc0abf0b733fadc; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_receipts
    ADD CONSTRAINT "FK_92d0bda0a82dcc0abf0b733fadc" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_assignments FK_9c5f0cbd89c4d1e858a4b4a4e4f; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT "FK_9c5f0cbd89c4d1e858a4b4a4e4f" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: news_post FK_a3677e07ecbe41e4297ae33cb0a; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.news_post
    ADD CONSTRAINT "FK_a3677e07ecbe41e4297ae33cb0a" FOREIGN KEY ("authorId") REFERENCES public."User"(id);


--
-- Name: project_images FK_a6efe5710e20ed5469e7719f074; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_images
    ADD CONSTRAINT "FK_a6efe5710e20ed5469e7719f074" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_task FK_a81f1f3ca71d469236a55e2bcaa; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.project_task
    ADD CONSTRAINT "FK_a81f1f3ca71d469236a55e2bcaa" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: registration_approvals FK_d0b91fcf539def7b9ad50741f0b; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.registration_approvals
    ADD CONSTRAINT "FK_d0b91fcf539def7b9ad50741f0b" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: time_entries FK_d1b452d7f0d45863303b7d30000; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT "FK_d1b452d7f0d45863303b7d30000" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: time_entries FK_f051d95ecf3cd671445ef0c9be8; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT "FK_f051d95ecf3cd671445ef0c9be8" FOREIGN KEY ("projectId") REFERENCES public.projects(id);


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict dU7Jz9oBV0NqZkJqlbcgDj8H5m8Nd479ZcDyW19kHrcecxXVhmiakJdbhargdV4

