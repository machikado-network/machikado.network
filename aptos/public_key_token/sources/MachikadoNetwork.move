module MachikadoNetwork::MachikadoNetwork {
    use std::string;
    use aptos_std::table::Table;
    use std::signer;
    use aptos_std::table;
    use std::error;
    use std::vector;
    use aptos_std::event;
    use aptos_std::event::EventHandle;

    const ETOKEN_NAME_EXISTS: u64 = 0;
    const ETOKEN_IP_ADDRESS_EXISTS: u64 = 1;
    const ETOKEN_PUBLIC_KEY_EXISTS: u64 = 2;
    const EIP_ADDRESS_RANGE_ERROR: u64 = 3;
    const ENAME_LENGTH_MUST_UNDER_32: u64 = 4;
    const ENAME_CHARACTOR_INVALID: u64 = 5;
    const ENO_MESSAGE: u64 = 6;
    const ETOKEN_STORE_NOT_FOUND: u64 = 7;
    const ETOKEN_NOT_FOUND: u64 = 8;

    struct Token has store, copy, drop {
        ip_address: string::String,
        public_key: string::String,
    }

    struct TokenStore has key {
        tokens: Table<string::String, Token>,
        ip_addresses: vector<string::String>,
        public_keys: vector<string::String>
    }

    struct PublishedToken has store, copy, drop {
        ip_address: string::String,
        public_key: string::String,
        creator: address,
    }

    struct PublishedTokenStore has key {
        tokens: Table<string::String, PublishedToken>,
        ip_addresses: vector<string::String>,
        public_keys: vector<string::String>,

        publish_events: EventHandle<PublishEvent>,
        unpublished_events: EventHandle<UnpublishEvent>,
    }

    struct PublishEvent has drop, store {
        id: string::String
    }

    struct UnpublishEvent has drop, store {
        id: string::String
    }

    public entry fun create_token(
        creator: &signer,
        name_bytes: vector<u8>,
        ip_address_bytes: vector<u8>,
        public_key_bytes: vector<u8>,
    ) acquires TokenStore {
        let name = string::utf8(name_bytes);
        let ip_address = string::utf8(ip_address_bytes);
        let public_key = string::utf8(public_key_bytes);
        let account_addr = signer::address_of(creator);
        if (!exists<TokenStore>(account_addr)) {
            move_to(
                creator,
                TokenStore {
                    tokens: table::new(),
                    ip_addresses: vector::empty<string::String>(),
                    public_keys: vector::empty<string::String>(),
                },
            )
        };

        let store = borrow_global_mut<TokenStore>(account_addr);
        let tokens = &mut store.tokens;
        let ip_addresses = &mut store.ip_addresses;
        let public_keys = &mut store.public_keys;
        check_token(name, tokens);
        check_token_items(
            name,
            ip_address,
            public_key,
            ip_addresses,
            public_keys
        );

        let token = Token {
            ip_address,
            public_key,
        };

        table::add(tokens, name, token);
        vector::push_back(ip_addresses, ip_address);
        vector::push_back(public_keys, public_key);
    }

    public entry fun create_published_token_store(creator: &signer) {
        let target_addr = signer::address_of(creator);
        if (!exists<PublishedTokenStore>(target_addr)) {
            move_to(
                creator,
                PublishedTokenStore {
                    tokens: table::new(),
                    ip_addresses: vector::empty<string::String>(),
                    public_keys: vector::empty<string::String>(),
                    publish_events: event::new_event_handle<PublishEvent>(creator),
                    unpublished_events: event::new_event_handle<UnpublishEvent>(creator),
                }
            )
        };
    }

    public entry fun publish(
        creator: &signer,
        name_bytes: vector<u8>,
        target: address,
    ) acquires TokenStore, PublishedTokenStore {
        let name = string::utf8(name_bytes);
        let account_addr = signer::address_of(creator);
        assert!(exists<TokenStore>(account_addr), error::not_found(ETOKEN_STORE_NOT_FOUND));

        let store = borrow_global_mut<TokenStore>(account_addr);
        let tokens = &mut store.tokens;
        assert!(table::contains(tokens, name), error::not_found(ETOKEN_NOT_FOUND));

        let token = table::borrow(tokens, name);

        assert!(exists<PublishedTokenStore>(target), error::not_found(ETOKEN_STORE_NOT_FOUND));

        let published_store = borrow_global_mut<PublishedTokenStore>(target);
        let tokens = &mut published_store.tokens;
        let ip_addresses = &mut published_store.ip_addresses;
        let public_keys = &mut published_store.public_keys;
        check_published_token(name, tokens);
        check_token_items(
            name,
            token.ip_address,
            token.public_key,
            ip_addresses,
            public_keys
        );

        // add to published store
        table::add(tokens, name, PublishedToken {
            ip_address: token.ip_address,
            public_key: token.public_key,
            creator: signer::address_of(creator),
        });
        vector::push_back(ip_addresses, token.ip_address);
        vector::push_back(public_keys, token.public_key);

        event::emit_event(&mut published_store.publish_events, PublishEvent {
            id: name
        });
    }

    fun check_token(name: string::String, tokens: &mut Table<string::String, Token>) {
        assert!(
            !table::contains(tokens, name),
            error::already_exists(ETOKEN_NAME_EXISTS),
        );
    }

    fun check_published_token(name: string::String, tokens: &mut Table<string::String, PublishedToken>) {
        assert!(
            !table::contains(tokens, name),
            error::already_exists(ETOKEN_NAME_EXISTS),
        );
    }

    fun check_token_items(
        name: string::String,
        ip_address: string::String,
        public_key: string::String,
        ip_addresses: &mut vector<string::String>,
        public_keys: &mut vector<string::String>,
    ) {
        // check ip address, public key
        assert!(
            !vector::contains(ip_addresses, &ip_address),
            error::already_exists(ETOKEN_IP_ADDRESS_EXISTS)
        );
        assert!(
            !vector::contains(public_keys, &public_key),
            error::already_exists(ETOKEN_PUBLIC_KEY_EXISTS)
        );

        // ip address mush starts 10.50.
        assert!(
            string::sub_string(&ip_address, 0, 6) == string::utf8(b"10.50."),
            EIP_ADDRESS_RANGE_ERROR,
        );

        // name length is under 32
        assert!(
            string::length(&name) <= 32,
            ENAME_LENGTH_MUST_UNDER_32
        );

        // check name charactors
        let i = 0;
        let name_raw = string::bytes(&name);
        while (i < string::length(&name)) {
            let char = vector::borrow(name_raw, i);
            assert!(
                (48 <= *char && *char <= 57) || (*char == 95) || (97 <= *char && *char <= 122),
                ENAME_CHARACTOR_INVALID
            );
            i = i + 1;
        };
    }

    public fun get_token(addr: address, name: string::String): Token acquires TokenStore {
        assert!(exists<TokenStore>(addr), error::not_found(ENO_MESSAGE));
        *table::borrow(&borrow_global<TokenStore>(addr).tokens, name)
    }

    public fun get_published_token(addr: address, name: string::String): PublishedToken acquires PublishedTokenStore {
        assert!(exists<PublishedTokenStore>(addr), error::not_found(ENO_MESSAGE));
        *table::borrow(&borrow_global<PublishedTokenStore>(addr).tokens, name)
    }

    #[test(account = @0x1, account2 = @0x42)]
    public entry fun test_publish(account: signer, account2: signer) acquires TokenStore, PublishedTokenStore {
        create_token(
            &account,
            b"sumidora",
            b"10.50.24.5",
            b"A12345B",
        );

        create_published_token_store(&account2);

        publish(
            &account,
            b"sumidora",
            signer::address_of(&account2),
        );

        let token = get_token(signer::address_of(&account), string::utf8(b"sumidora"));
        assert!(
            token.ip_address == string::utf8(b"10.50.24.5"),
            ENO_MESSAGE
        );
        assert!(
            token.public_key == string::utf8(b"A12345B"),
            ENO_MESSAGE
        );

        let published_token = get_published_token(signer::address_of(&account2), string::utf8(b"sumidora"));
        assert!(
            published_token.ip_address == string::utf8(b"10.50.24.5"),
            ENO_MESSAGE
        );
        assert!(
            published_token.public_key == string::utf8(b"A12345B"),
            ENO_MESSAGE
        );
    }
}
