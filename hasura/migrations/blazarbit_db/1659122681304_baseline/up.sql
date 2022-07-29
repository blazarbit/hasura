SET check_function_bodies = false;
CREATE TABLE public.blockchains (
    network_id character varying NOT NULL,
    name character varying NOT NULL,
    logo_url character varying,
    rpc_node_address character varying,
    lcd_node_address character varying,
    fee_token_denom character varying,
    fee_token_avg_amount bigint,
    protocol_contract_address character varying,
    prefix character varying,
    gas_price character varying
);
CREATE TABLE public.channels (
    channel_id character varying NOT NULL,
    blockchain character varying NOT NULL,
    port_id character varying NOT NULL,
    counterparty_channel character varying,
    counterparty_blockchain character varying,
    counterparty_port character varying,
    client_state character varying
);
CREATE TABLE public.denom_traces (
    hash character varying NOT NULL,
    path character varying NOT NULL,
    denom character varying NOT NULL
);
CREATE TABLE public.donations (
    address character varying NOT NULL,
    denom character varying NOT NULL,
    blockchain character varying NOT NULL,
    name character varying,
    logo_url character varying
);
CREATE TABLE public.nft_contracts (
    contract_address character varying NOT NULL,
    blockchain character varying NOT NULL,
    name character varying,
    token_id character varying,
    price_per_one bigint,
    amount_available bigint,
    logo_url character varying,
    payment_token_denom character varying
);
CREATE TABLE public.pools (
    id integer NOT NULL,
    blockchain character varying NOT NULL,
    base_token_denom character varying NOT NULL,
    quote_token_denom character varying NOT NULL,
    rate numeric,
    fee numeric
);
CREATE TABLE public.protocol_instructions (
    id integer NOT NULL,
    payment_method_denom character varying NOT NULL,
    payment_method_blockchain character varying NOT NULL,
    destination_asset_blockchain character varying NOT NULL,
    destination_asset_denom character varying,
    destination_asset_address character varying,
    destination_asset_contract_address character varying,
    json_encoded_send_args jsonb NOT NULL,
    funds jsonb NOT NULL,
    fee jsonb NOT NULL,
    payment_token_amount bigint,
    destination_asset_amount bigint,
    memo character varying DEFAULT ''::character varying NOT NULL
);
CREATE SEQUENCE public.protocol_instructions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.protocol_instructions_id_seq OWNED BY public.protocol_instructions.id;
CREATE TABLE public.tokens (
    denom character varying NOT NULL,
    blockchain character varying NOT NULL,
    base_denom character varying,
    base_blockchain character varying,
    minted_channel character varying,
    minted_port character varying,
    previous_wrap_denom character varying,
    previous_wrap_blockchain character varying
);
CREATE TABLE public.tokens_data (
    base_denom character varying NOT NULL,
    base_blockchain character varying NOT NULL,
    symbol character varying,
    symbol_point_exponent integer,
    logo_url character varying,
    current_price_in_usd numeric
);
ALTER TABLE ONLY public.protocol_instructions ALTER COLUMN id SET DEFAULT nextval('public.protocol_instructions_id_seq'::regclass);
ALTER TABLE ONLY public.blockchains
    ADD CONSTRAINT blockchains_name_key UNIQUE (name);
ALTER TABLE ONLY public.blockchains
    ADD CONSTRAINT blockchains_pkey PRIMARY KEY (network_id);
ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (channel_id, blockchain, port_id);
ALTER TABLE ONLY public.denom_traces
    ADD CONSTRAINT denom_traces_pkey PRIMARY KEY (hash);
ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (address, denom, blockchain);
ALTER TABLE ONLY public.nft_contracts
    ADD CONSTRAINT nft_contracts_pkey PRIMARY KEY (blockchain, contract_address);
ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id, blockchain, base_token_denom, quote_token_denom);
ALTER TABLE ONLY public.protocol_instructions
    ADD CONSTRAINT protocol_instructions_pkey PRIMARY KEY (id, payment_method_denom, payment_method_blockchain, destination_asset_blockchain);
ALTER TABLE ONLY public.tokens_data
    ADD CONSTRAINT tokens_data_pkey PRIMARY KEY (base_denom, base_blockchain);
ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (denom, blockchain);
ALTER TABLE ONLY public.blockchains
    ADD CONSTRAINT blockchains_fee_token_denom_network_id_fkey FOREIGN KEY (fee_token_denom, network_id) REFERENCES public.tokens(denom, blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_counterparty_port_counterparty_blockchain_counterpa FOREIGN KEY (counterparty_port, counterparty_blockchain, counterparty_channel) REFERENCES public.channels(port_id, blockchain, channel_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_denom_blockchain_fkey FOREIGN KEY (denom, blockchain) REFERENCES public.tokens(denom, blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.nft_contracts
    ADD CONSTRAINT nft_contracts_blockchain_fkey FOREIGN KEY (blockchain) REFERENCES public.blockchains(network_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.nft_contracts
    ADD CONSTRAINT nft_contracts_blockchain_payment_token_denom_fkey FOREIGN KEY (blockchain, payment_token_denom) REFERENCES public.tokens(blockchain, denom) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_blockchain_base_token_denom_fkey FOREIGN KEY (blockchain, base_token_denom) REFERENCES public.tokens(blockchain, denom) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_blockchain_fkey FOREIGN KEY (blockchain) REFERENCES public.blockchains(network_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_blockchain_quote_token_denom_fkey FOREIGN KEY (blockchain, quote_token_denom) REFERENCES public.tokens(blockchain, denom) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.protocol_instructions
    ADD CONSTRAINT protocol_instructions_destination_asset_address_destinatio_fkey FOREIGN KEY (destination_asset_address, destination_asset_blockchain, destination_asset_denom) REFERENCES public.donations(address, blockchain, denom) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.protocol_instructions
    ADD CONSTRAINT protocol_instructions_destination_asset_blockchain_destina_fkey FOREIGN KEY (destination_asset_blockchain, destination_asset_contract_address) REFERENCES public.nft_contracts(blockchain, contract_address) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.protocol_instructions
    ADD CONSTRAINT protocol_instructions_destination_asset_denom_destination__fkey FOREIGN KEY (destination_asset_denom, destination_asset_blockchain) REFERENCES public.tokens(denom, blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.protocol_instructions
    ADD CONSTRAINT protocol_instructions_payment_method_denom_payment_method__fkey FOREIGN KEY (payment_method_denom, payment_method_blockchain) REFERENCES public.tokens(denom, blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_base_blockchain_base_denom_fkey FOREIGN KEY (base_blockchain, base_denom) REFERENCES public.tokens(blockchain, denom) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_base_denom_base_blockchain_fkey FOREIGN KEY (base_denom, base_blockchain) REFERENCES public.tokens_data(base_denom, base_blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_blockchain_fkey FOREIGN KEY (blockchain) REFERENCES public.blockchains(network_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tokens_data
    ADD CONSTRAINT tokens_data_base_blockchain_fkey FOREIGN KEY (base_blockchain) REFERENCES public.blockchains(network_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_minted_channel_minted_port_blockchain_fkey FOREIGN KEY (minted_channel, minted_port, blockchain) REFERENCES public.channels(channel_id, port_id, blockchain) ON UPDATE RESTRICT ON DELETE RESTRICT;
