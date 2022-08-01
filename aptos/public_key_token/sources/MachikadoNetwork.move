module MachikadoNetwork::MachikadoNetwork {
    use std::string;
    use aptos_std::table::Table;
    use std::signer;
    use aptos_std::table;
    use std::error;
    use std::vector;
    use aptos_std::event;
    use aptos_std::event::EventHandle;
    use std::option;
    use std::option::{Option, some, none};

    const ETOKEN_NAME_EXISTS: u64 = 0;
    const ETOKEN_IP_ADDRESS_EXISTS: u64 = 1;
    const ETOKEN_PUBLIC_KEY_EXISTS: u64 = 2;
    const EIP_ADDRESS_RANGE_ERROR: u64 = 3;
    const ENAME_LENGTH_MUST_UNDER_32: u64 = 4;
    const ENAME_CHARACTOR_INVALID: u64 = 5;
    const ENO_MESSAGE: u64 = 6;
    const ETOKEN_STORE_NOT_FOUND: u64 = 7;
    const EPUBLISHED_TOKEN_STORE_NOT_FOUND: u64 = 8;
    const ETOKEN_NOT_FOUND: u64 = 9;
    const EUNPUBLISH_PERMISSION_MISSING: u64 = 10;

    struct Token has store, copy, drop {
        ip_address: string::String,
        public_key: string::String,
        name: string::String,
    }

    struct TokenStore has key {
        tokens: vector<Token>,
    }

    struct PublishedToken has store, copy, drop {
        ip_address: string::String,
        public_key: string::String,
        creator: address,
        name: string::String,
    }

    struct PublishedTokenStore has key {
        tokens: vector<PublishedToken>,

        publish_events: EventHandle<PublishEvent>,
        unpublished_events: EventHandle<UnpublishEvent>,
    }

    struct PublishEvent has drop, store {
        id: string::String
    }

    struct UnpublishEvent has drop, store {
        id: string::String
    }

    struct NthToken<T> has store, copy, drop {
        data: T,
        nth: u64,
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
                    tokens: vector::empty<Token>(),
                },
            )
        };

        let store = borrow_global_mut<TokenStore>(account_addr);
        let tokens = &mut store.tokens;
        check_token_items(
            name,
            ip_address,
            public_key,
            tokens
        );

        let token = Token {
            ip_address,
            public_key,
            name,
        };

        vector::push_back(tokens, token)
    }

    public entry fun create_published_token_store(creator: &signer) {
        let target_addr = signer::address_of(creator);
        if (!exists<PublishedTokenStore>(target_addr)) {
            move_to(
                creator,
                PublishedTokenStore {
                    tokens: vector::empty<PublishedToken>(),
                    publish_events: event::new_event_handle<PublishEvent>(creator),
                    unpublished_events: event::new_event_handle<UnpublishEvent>(creator),
                }
            )
        };
    }

    public entry fun unpublish(
        creator: &signer,
        name_bytes: vector<u8>,
        target: address,
    ) acquires PublishedTokenStore {
        let name = string::utf8(name_bytes);
        assert!(exists<PublishedTokenStore>(target), error::not_found(EPUBLISHED_TOKEN_STORE_NOT_FOUND));

        let store = borrow_global_mut<PublishedTokenStore>(target);
        let tokens = &mut store.tokens;

        let token = get_published_token(tokens, name);

        assert!(option::is_some(&token), ETOKEN_NOT_FOUND);

        let token = option::borrow(&token);
        assert!(token.data.creator == signer::address_of(creator) || signer::address_of(creator) == target, EUNPUBLISH_PERMISSION_MISSING);
        vector::remove(tokens, token.nth);

        event::emit_event(&mut store.unpublished_events, UnpublishEvent {
            id: name
        });
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
        let token = get_token(tokens, name);
        assert!(option::is_some(&token), error::not_found(ETOKEN_NOT_FOUND));
        let token = option::borrow(&token);

        assert!(exists<PublishedTokenStore>(target), error::not_found(EPUBLISHED_TOKEN_STORE_NOT_FOUND));

        let published_store = borrow_global_mut<PublishedTokenStore>(target);
        let tokens = &mut published_store.tokens;
        check_published_token_items(
            name,
            token.data.ip_address,
            token.data.public_key,
            tokens
        );

        // add to published store
        vector::push_back(
            tokens,
            PublishedToken {
                ip_address: token.data.ip_address,
                public_key: token.data.public_key,
                creator: signer::address_of(creator),
                name,
            }
        );

        event::emit_event(&mut published_store.publish_events, PublishEvent {
            id: name
        });
    }

    fun get_token(tokens: &vector<Token>, name: string::String): Option<NthToken<Token>> {
        let i = 0;
        while (i < vector::length(tokens)) {
            let token = vector::borrow(tokens, i);
            if (token.name == name) {
                return some(NthToken<Token> {
                    data: *token,
                    nth: i,
                })
            };
            i = i + 1;
        };
        none<NthToken<Token>>()
    }

    fun get_published_token(tokens: &vector<PublishedToken>, name: string::String): Option<NthToken<PublishedToken>> {
        let i = 0;
        while (i < vector::length(tokens)) {
            let token = vector::borrow(tokens, i);
            if (token.name == name) {
                return some(NthToken<PublishedToken> {
                    data: *token,
                    nth: i,
                })
            };
            i = i + 1;
        };
        none<NthToken<PublishedToken>>()
    }

    fun check_published_token(name: string::String, tokens: &mut Table<string::String, PublishedToken>) {
        assert!(
            !table::contains(tokens, name),
            error::already_exists(ETOKEN_NAME_EXISTS),
        );
    }

    fun check_field(
        name: string::String,
        ip_address: string::String,
    ) {
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

    fun check_token_items(
        name: string::String,
        ip_address: string::String,
        public_key: string::String,
        tokens: &vector<Token>
    ) {
        let i = 0;
        while (i < vector::length(tokens)) {
            let token = vector::borrow(tokens, i);
            assert!(
                token.ip_address != ip_address,
                error::already_exists(ETOKEN_IP_ADDRESS_EXISTS),
            );
            assert!(
                token.public_key != public_key,
                error::already_exists(ETOKEN_PUBLIC_KEY_EXISTS),
            );
            assert!(
                token.name != name,
                error::already_exists(ETOKEN_NAME_EXISTS),
            );

            i = i + 1;
        };
        check_field(name, ip_address);
    }

    fun check_published_token_items(
        name: string::String,
        ip_address: string::String,
        public_key: string::String,
        tokens: &vector<PublishedToken>
    ) {
        let i = 0;
        while (i < vector::length(tokens)) {
            let token = vector::borrow(tokens, i);
            assert!(
                token.ip_address != ip_address,
                error::already_exists(ETOKEN_IP_ADDRESS_EXISTS),
            );
            assert!(
                token.public_key != public_key,
                error::already_exists(ETOKEN_PUBLIC_KEY_EXISTS),
            );
            assert!(
                token.name != name,
                error::already_exists(ETOKEN_NAME_EXISTS),
            );

            i = i + 1;
        };
        check_field(name, ip_address);
    }

    #[test_only]
    fun get_user_token(addr: address, name: string::String): Token acquires TokenStore {
        let store = borrow_global_mut<TokenStore>(addr);
        let tokens = &mut store.tokens;
        option::borrow(&get_token(tokens, name)).data
    }

    #[test_only]
    fun get_user_published_token(addr: address, name: string::String): PublishedToken acquires PublishedTokenStore {
        let store = borrow_global_mut<PublishedTokenStore>(addr);
        let tokens = &mut store.tokens;
        option::borrow(&get_published_token(tokens, name)).data
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

        let token = get_user_token(signer::address_of(&account), string::utf8(b"sumidora"));
        assert!(
            token.ip_address == string::utf8(b"10.50.24.5"),
            ENO_MESSAGE
        );
        assert!(
            token.public_key == string::utf8(b"A12345B"),
            ENO_MESSAGE
        );

        let published_token = get_user_published_token(signer::address_of(&account2), string::utf8(b"sumidora"));
        assert!(
            published_token.ip_address == string::utf8(b"10.50.24.5"),
            ENO_MESSAGE
        );
        assert!(
            published_token.public_key == string::utf8(b"A12345B"),
            ENO_MESSAGE
        );

        unpublish(&account, b"sumidora", signer::address_of(&account2));

        let store = borrow_global_mut<PublishedTokenStore>(signer::address_of(&account2));
        assert!(vector::length(&store.tokens) == 0, ENO_MESSAGE);
    }
}
