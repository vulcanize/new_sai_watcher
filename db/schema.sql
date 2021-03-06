--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: maker; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA maker;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = maker, pg_catalog;

--
-- Name: act; Type: TYPE; Schema: maker; Owner: -
--

CREATE TYPE act AS ENUM (
    'give',
    'open',
    'join',
    'exit',
    'lock',
    'free',
    'draw',
    'wipe',
    'shut',
    'bite'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cup_action; Type: TABLE; Schema: maker; Owner: -
--

CREATE TABLE cup_action (
    log_id integer,
    id integer,
    tx character varying(66) NOT NULL,
    act act NOT NULL,
    arg character varying(66),
    lad character varying(66) NOT NULL,
    ink numeric DEFAULT 0 NOT NULL,
    art numeric DEFAULT 0 NOT NULL,
    ire numeric DEFAULT 0 NOT NULL,
    block integer NOT NULL,
    deleted boolean DEFAULT false,
    guy character varying(66)
);


--
-- Name: gov; Type: TABLE; Schema: maker; Owner: -
--

CREATE TABLE gov (
    log_id integer,
    block integer NOT NULL,
    tx character varying(66) NOT NULL,
    var character varying(15),
    arg numeric,
    guy character varying(42),
    cap numeric,
    mat numeric,
    tax numeric,
    fee numeric,
    axe numeric,
    gap numeric
);


--
-- Name: peps_everyblock; Type: TABLE; Schema: maker; Owner: -
--

CREATE TABLE peps_everyblock (
    id integer NOT NULL,
    block_number bigint NOT NULL,
    block_id integer NOT NULL,
    block_time bigint,
    pep numeric,
    pip numeric,
    per numeric
);


--
-- Name: peps_everyblock_id_seq; Type: SEQUENCE; Schema: maker; Owner: -
--

CREATE SEQUENCE peps_everyblock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: peps_everyblock_id_seq; Type: SEQUENCE OWNED BY; Schema: maker; Owner: -
--

ALTER SEQUENCE peps_everyblock_id_seq OWNED BY peps_everyblock.id;


SET search_path = public, pg_catalog;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE logs (
    id integer NOT NULL,
    block_number bigint,
    address character varying(66),
    tx_hash character varying(66),
    index bigint,
    topic0 character varying(66),
    topic1 character varying(66),
    topic2 character varying(66),
    topic3 character varying(66),
    data text,
    receipt_id integer
);


--
-- Name: block_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW block_stats AS
 SELECT max(logs.block_number) AS max_block,
    min(logs.block_number) AS min_block
   FROM logs;


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE blocks (
    number bigint,
    gaslimit bigint,
    gasused bigint,
    "time" bigint,
    id integer NOT NULL,
    difficulty bigint,
    hash character varying(66),
    nonce character varying(20),
    parenthash character varying(66),
    size character varying,
    uncle_hash character varying(66),
    eth_node_id integer NOT NULL,
    is_final boolean,
    miner character varying(42),
    extra_data character varying,
    reward double precision,
    uncles_reward double precision
);


--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blocks_id_seq OWNED BY blocks.id;


--
-- Name: cup; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cup AS
 SELECT c.act,
    c.art,
    c.block,
    c.deleted,
    c.id,
    c.ink,
    c.ire,
    c.lad,
    c.pip,
    c.per,
    ((((c.pip * c.per) * c.ink) / NULLIF(c.art, (0)::numeric)) * (100)::numeric) AS ratio,
    ((c.pip * c.per) * c.ink) AS tab,
    c."time"
   FROM ( SELECT DISTINCT ON (cup_action.id) cup_action.act,
            cup_action.art,
            cup_action.block,
            blocks."time",
            cup_action.deleted,
            cup_action.id,
            cup_action.ink,
            cup_action.ire,
            cup_action.lad,
            ( SELECT peps_everyblock.pip
                   FROM maker.peps_everyblock
                  ORDER BY peps_everyblock.block_number DESC
                 LIMIT 1) AS pip,
            ( SELECT peps_everyblock.per
                   FROM maker.peps_everyblock
                  ORDER BY peps_everyblock.block_number DESC
                 LIMIT 1) AS per
           FROM (maker.cup_action
             JOIN blocks ON ((cup_action.block = blocks.number)))
          ORDER BY cup_action.id DESC, cup_action.block DESC) c;


--
-- Name: cup_act; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cup_act AS
 SELECT cup_action.act,
    cup_action.arg,
    cup_action.art,
    cup_action.block,
    cup_action.deleted,
    cup_action.id,
    cup_action.ink,
    cup_action.ire,
    cup_action.lad,
    peps_everyblock.pip,
    peps_everyblock.per,
    ((((peps_everyblock.pip * peps_everyblock.per) * cup_action.ink) / NULLIF(cup_action.art, (0)::numeric)) * (100)::numeric) AS ratio,
    ((peps_everyblock.pip * peps_everyblock.per) * cup_action.ink) AS tab,
    cup_action.tx
   FROM (maker.cup_action
     LEFT JOIN maker.peps_everyblock ON ((peps_everyblock.block_number = cup_action.block)))
  ORDER BY cup_action.block DESC;


--
-- Name: eth_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE eth_nodes (
    id integer NOT NULL,
    genesis_block character varying(66),
    network_id numeric,
    eth_node_id character varying(128),
    client_name character varying
);


--
-- Name: log_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_filters (
    id integer NOT NULL,
    name character varying NOT NULL,
    from_block bigint,
    to_block bigint,
    address character varying(66),
    topic0 character varying(66),
    topic1 character varying(66),
    topic2 character varying(66),
    topic3 character varying(66),
    CONSTRAINT log_filters_from_block_check CHECK ((from_block >= 0)),
    CONSTRAINT log_filters_name_check CHECK (((name)::text <> ''::text)),
    CONSTRAINT log_filters_to_block_check CHECK ((to_block >= 0))
);


--
-- Name: log_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_filters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_filters_id_seq OWNED BY log_filters.id;


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logs_id_seq OWNED BY logs.id;


--
-- Name: nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nodes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nodes_id_seq OWNED BY eth_nodes.id;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE receipts (
    id integer NOT NULL,
    transaction_id integer NOT NULL,
    contract_address character varying(42),
    cumulative_gas_used numeric,
    gas_used numeric,
    state_root character varying(66),
    status integer,
    tx_hash character varying(66)
);


--
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE receipts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE receipts_id_seq OWNED BY receipts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE transactions (
    id integer NOT NULL,
    hash character varying(66),
    nonce numeric,
    tx_to character varying(66),
    gaslimit numeric,
    gasprice numeric,
    value numeric,
    block_id integer NOT NULL,
    tx_from character varying(66),
    input_data character varying
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transactions_id_seq OWNED BY transactions.id;


--
-- Name: watched_contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE watched_contracts (
    contract_id integer NOT NULL,
    contract_hash character varying(66),
    contract_abi json
);


--
-- Name: watched_contracts_contract_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE watched_contracts_contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watched_contracts_contract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE watched_contracts_contract_id_seq OWNED BY watched_contracts.contract_id;


--
-- Name: watched_event_logs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW watched_event_logs AS
 SELECT log_filters.name,
    logs.id,
    logs.block_number,
    logs.address,
    logs.tx_hash,
    logs.index,
    logs.topic0,
    logs.topic1,
    logs.topic2,
    logs.topic3,
    logs.data,
    logs.receipt_id
   FROM ((log_filters
     CROSS JOIN block_stats)
     JOIN logs ON ((((logs.address)::text = (log_filters.address)::text) AND (logs.block_number >= COALESCE(log_filters.from_block, block_stats.min_block)) AND (logs.block_number <= COALESCE(log_filters.to_block, block_stats.max_block)))))
  WHERE ((((log_filters.topic0)::text = (logs.topic0)::text) OR (log_filters.topic0 IS NULL)) AND (((log_filters.topic1)::text = (logs.topic1)::text) OR (log_filters.topic1 IS NULL)) AND (((log_filters.topic2)::text = (logs.topic2)::text) OR (log_filters.topic2 IS NULL)) AND (((log_filters.topic3)::text = (logs.topic3)::text) OR (log_filters.topic3 IS NULL)));


SET search_path = maker, pg_catalog;

--
-- Name: peps_everyblock id; Type: DEFAULT; Schema: maker; Owner: -
--

ALTER TABLE ONLY peps_everyblock ALTER COLUMN id SET DEFAULT nextval('peps_everyblock_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocks ALTER COLUMN id SET DEFAULT nextval('blocks_id_seq'::regclass);


--
-- Name: eth_nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eth_nodes ALTER COLUMN id SET DEFAULT nextval('nodes_id_seq'::regclass);


--
-- Name: log_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_filters ALTER COLUMN id SET DEFAULT nextval('log_filters_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq'::regclass);


--
-- Name: receipts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY receipts ALTER COLUMN id SET DEFAULT nextval('receipts_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions ALTER COLUMN id SET DEFAULT nextval('transactions_id_seq'::regclass);


--
-- Name: watched_contracts contract_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY watched_contracts ALTER COLUMN contract_id SET DEFAULT nextval('watched_contracts_contract_id_seq'::regclass);


SET search_path = maker, pg_catalog;

--
-- Name: cup_action tx_act_arg_constraint; Type: CONSTRAINT; Schema: maker; Owner: -
--

ALTER TABLE ONLY cup_action
    ADD CONSTRAINT tx_act_arg_constraint UNIQUE (tx, act, arg);


SET search_path = public, pg_catalog;

--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: watched_contracts contract_hash_uc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY watched_contracts
    ADD CONSTRAINT contract_hash_uc UNIQUE (contract_hash);


--
-- Name: blocks eth_node_id_block_number_uc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocks
    ADD CONSTRAINT eth_node_id_block_number_uc UNIQUE (number, eth_node_id);


--
-- Name: eth_nodes eth_node_uc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eth_nodes
    ADD CONSTRAINT eth_node_uc UNIQUE (genesis_block, network_id, eth_node_id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: log_filters name_uc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_filters
    ADD CONSTRAINT name_uc UNIQUE (name);


--
-- Name: eth_nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eth_nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: watched_contracts watched_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY watched_contracts
    ADD CONSTRAINT watched_contracts_pkey PRIMARY KEY (contract_id);


--
-- Name: block_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_id_index ON transactions USING btree (block_id);


--
-- Name: block_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_number_index ON blocks USING btree (number);


--
-- Name: node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX node_id_index ON blocks USING btree (eth_node_id);


--
-- Name: transaction_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_id_index ON receipts USING btree (transaction_id);


--
-- Name: tx_from_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_from_index ON transactions USING btree (tx_from);


--
-- Name: tx_to_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tx_to_index ON transactions USING btree (tx_to);


SET search_path = maker, pg_catalog;

--
-- Name: peps_everyblock blocks_fk; Type: FK CONSTRAINT; Schema: maker; Owner: -
--

ALTER TABLE ONLY peps_everyblock
    ADD CONSTRAINT blocks_fk FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: cup_action log_index_fk; Type: FK CONSTRAINT; Schema: maker; Owner: -
--

ALTER TABLE ONLY cup_action
    ADD CONSTRAINT log_index_fk FOREIGN KEY (log_id) REFERENCES public.logs(id) ON DELETE CASCADE;


--
-- Name: gov log_index_fk; Type: FK CONSTRAINT; Schema: maker; Owner: -
--

ALTER TABLE ONLY gov
    ADD CONSTRAINT log_index_fk FOREIGN KEY (log_id) REFERENCES public.logs(id) ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- Name: transactions blocks_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT blocks_fk FOREIGN KEY (block_id) REFERENCES blocks(id) ON DELETE CASCADE;


--
-- Name: blocks node_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocks
    ADD CONSTRAINT node_fk FOREIGN KEY (eth_node_id) REFERENCES eth_nodes(id) ON DELETE CASCADE;


--
-- Name: logs receipts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs
    ADD CONSTRAINT receipts_fk FOREIGN KEY (receipt_id) REFERENCES receipts(id) ON DELETE CASCADE;


--
-- Name: receipts transaction_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT transaction_fk FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

