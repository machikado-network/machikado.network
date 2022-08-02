module MachikadoNetwork::MachikadoNetwork {
    use std::string;
    use aptos_std::table::Table;
    use std::signer;
    use aptos_std::table;
    use std::error;
    use std::vector;

    const ETOKEN_STORE_EXISITS: u64 = 0;
    const ETOKEN_STORE_NOT_FOUND: u64 = 1;
    const ENAME_EXISTS: u64 = 2;
    const EPKTOKEN_EXISTS: u64 = 3;
    const ESUBNET_EXISTS: u64 = 4;
    const EINVALID_SUBNET_RANGE: u64 = 5;
    const ENAME_CHARACTOR_INVALID: u64 = 6;
    const ENO_MESSAGE: u64 = 7;
    const ENAME_NOT_FOUND: u64 = 8;
    const ETOKEN_CREATOR_INVALID: u64 = 9;

    // Token for storing Public Key. Used only for reading.
    struct PKToken has store, copy {
        public_key: string::String,
        name: string::String,
        creator: address,
    }

    // How to check for duplicates?
    // First, check for duplicate names using the bindings table.
    // Next, we check for duplicate ip addresses using the tokens table.
    struct PKTokenStore has key {
        tokens: Table<u8, PKToken>,
        // Table to link names to subnets. Used to check for duplicates.
        bindings: Table<string::String, u8>,
        // List of users who created PKToken
        creators: vector<address>,
    }

    // Create a PKToken in target's PKTokenStore.
    public entry fun create_token(
        creator: &signer,
        target: address,
        name_raw: vector<u8>,
        subnet: u8,
        public_key_raw: vector<u8>,
    ) acquires PKTokenStore {
        direct_create_token(creator, target, string::utf8(name_raw), subnet, string::utf8(public_key_raw))
    }

    // Edit a PKToken's public key.
    public entry fun edit_public_key(
        creator: &signer,
        target: address,
        name_raw: vector<u8>,
        public_key_raw: vector<u8>,
    ) acquires PKTokenStore {
        direct_edit_public_key(creator, target, string::utf8(name_raw), string::utf8(public_key_raw));
    }

    // Create a PKTokenStore to creator.
    public entry fun create_token_store(
        creator: &signer,
    ) {
        assert!(
            !exists<PKTokenStore>(signer::address_of(creator)),
            error::already_exists(ETOKEN_STORE_EXISITS),
        );
        move_to(
            creator,
            PKTokenStore {
                tokens: table::new<u8, PKToken>(),
                bindings: table::new<string::String, u8>(),
                creators: vector::empty<address>()
            }
        )
    }

    fun check_name_charactors(name: string::String) {
        let i = 0;
        let name_raw = string::bytes(&name);
        while (i < string::length(&name)) {
            let char = vector::borrow(name_raw, i);
            assert!(
                // name is [0-9a-z]
                (48 <= *char && *char <= 57) || (97 <= *char && *char <= 122),
                ENAME_CHARACTOR_INVALID
            );
            i = i + 1;
        };
    }

    fun direct_create_token(
        creator: &signer,
        target: address,
        name: string::String,
        subnet: u8,
        public_key: string::String,
    ) acquires PKTokenStore {
        let creator_addr = signer::address_of(creator);

        // Check target has PKTokenStore
        assert!(
            exists<PKTokenStore>(target),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let token_store = borrow_global_mut<PKTokenStore>(target);
        let tokens = &mut token_store.tokens;
        let bindings = &mut token_store.bindings;
        let creators = &mut token_store.creators;

        // Check user has PKToken
        assert!(
            !vector::contains(creators, &creator_addr),
            error::already_exists(EPKTOKEN_EXISTS),
        );

        // Check name duplicate
        assert!(
            !table::contains(bindings, name),
            error::already_exists(ENAME_EXISTS),
        );

        // Check name charactors
        check_name_charactors(name);

        // Check subnet duplicate
        assert!(
            !table::contains(tokens, subnet),
            error::already_exists(ESUBNET_EXISTS),
        );

        // Check subnet range(1<=255 is valid)
        assert!(
            subnet != 0,
            EINVALID_SUBNET_RANGE,
        );

        // Add to creators
        vector::push_back(creators, creator_addr);
        // Add to bindings
        table::add(bindings, name, subnet);
        // Add to tokens
        let token = PKToken {
            name,
            public_key,
            creator: creator_addr,
        };
        table::add(tokens, subnet, token);

    }

    fun direct_edit_public_key(
        creator: &signer,
        target: address,
        name: string::String,
        new_public_key: string::String,
    ) acquires PKTokenStore {
        let creator_addr = signer::address_of(creator);

        // Check target has PKTokenStore
        assert!(
            exists<PKTokenStore>(target),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let token_store = borrow_global_mut<PKTokenStore>(target);
        let tokens = &mut token_store.tokens;
        let bindings = &mut token_store.bindings;

        // Check name
        assert!(
            table::contains(bindings, name),
            error::not_found(ENAME_NOT_FOUND),
        );
        let binding = *table::borrow(bindings, name);
        let token = table::borrow_mut(tokens, binding);

        // Check Token Creator
        assert!(token.creator == creator_addr, error::permission_denied(ETOKEN_CREATOR_INVALID));

        let public_key = &mut token.public_key;
        *public_key = new_public_key;
    }

    #[test(account = @0x1, target = @0x42)]
    public entry fun create_token_test(account: signer, target: signer) acquires PKTokenStore {
        create_token_store(&target);

        direct_create_token(
            &account,
            signer::address_of(&target),
            string::utf8(b"sumidora"),
            2,
            string::utf8(b"A12345_+/1")
        );

        let token_store = borrow_global<PKTokenStore>(signer::address_of(&target));

        // Check creators
        let creator = *vector::borrow(&token_store.creators, 0);
        assert!(signer::address_of(&account) == creator, ENO_MESSAGE);

        // Check bindings
        let binding = *table::borrow(&token_store.bindings, string::utf8(b"sumidora"));
        assert!(binding == 2, ENO_MESSAGE);

        // Check tokens
        let token = table::borrow(&token_store.tokens, 2);
        assert!(token.creator == signer::address_of(&account), ENO_MESSAGE);
        assert!(token.public_key == string::utf8(b"A12345_+/1"), ENO_MESSAGE);
        assert!(token.name == string::utf8(b"sumidora"), ENO_MESSAGE);
    }

    #[test(account = @0x1, target = @0x42)]
    public entry fun change_public_key_test(account: signer, target: signer) acquires PKTokenStore {
        create_token_store(&target);

        direct_create_token(
            &account,
            signer::address_of(&target),
            string::utf8(b"sumidora"),
            2,
            string::utf8(b"A12345_+/1")
        );

        direct_edit_public_key(
            &account,
            signer::address_of(&target),
            string::utf8(b"sumidora"),
            string::utf8(b"A12345_+/2")
        );

        let token_store = borrow_global<PKTokenStore>(signer::address_of(&target));

        // Check Token
        let token = table::borrow(&token_store.tokens, 2);
        assert!(token.creator == signer::address_of(&account), ENO_MESSAGE);
        assert!(token.public_key == string::utf8(b"A12345_+/2"), ENO_MESSAGE);
        assert!(token.name == string::utf8(b"sumidora"), ENO_MESSAGE);
    }
}
