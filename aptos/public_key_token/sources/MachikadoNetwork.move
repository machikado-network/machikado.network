module MachikadoNetwork::MachikadoNetwork {
    use std::string::String;
    use std::signer;
    use std::error;
    use std::vector;
    use aptos_std::table::Table;
    use aptos_std::table;
    use aptos_std::event::EventHandle;
    use aptos_std::event;
    use std::string;
    use std::option;
    use std::option::Option;

    const ENO_MESSAGE: u64 = 0;

    const ENETWORK_BINDINGS_ALREADY_EXISTS: u64 = 100;
    const ESUBNET_ALREADY_EXISTS: u64 = 101;
    const ECREATOR_ALREADY_EXISTS: u64 = 102;
    const ENAME_ALREADY_EXISTS: u64 = 103;

    const ENETWORK_BINDINGS_NOT_FOUND: u64 = 200;
    const ETOKEN_NOT_FOUND: u64 = 201;

    const ESUBNET_RANGE_INVALID: u64 = 300;
    const EPUBLIC_KEY_INVALID: u64 = 301;
    const ENAME_CHARACTOR_INVALID: u64 = 302;

    const ETOKEN_PERMISSION_DENIED: u64 = 400;

    struct PKToken has store, copy, drop {
        name: String,
        creator: address,
    }

    struct SubnetBinding has store, copy, drop {
        subnet: u8,
        creator: address,
    }

    struct PKTokenStore has key {
        // {[name]: public key}
        public_keys: Table<String, String>,
        tokens: vector<PKToken>,
    }

    struct SubnetStore has key {
        subnets: vector<SubnetBinding>,
        create_subnet_events: EventHandle<SubnetBinding>,
    }

    // Setup SubnetStore and PKTokenStore
    public entry fun setup(creator: &signer) {
        create_subnet_store(creator);
        create_pk_token_store(creator);
    }

    public entry fun create_subnet_store(creator: &signer) {
        assert!(
            !exists<SubnetStore>(signer::address_of(creator)),
            error::already_exists(ENETWORK_BINDINGS_ALREADY_EXISTS),
        );

        move_to(
            creator,
            SubnetStore {
                subnets: vector::empty<SubnetBinding>(),
                create_subnet_events: event::new_event_handle<SubnetBinding>(creator),
            }
        )
    }

    public entry fun create_pk_token_store(creator: &signer) {
        assert!(
            !exists<PKTokenStore>(signer::address_of(creator)),
            error::already_exists(ENETWORK_BINDINGS_ALREADY_EXISTS),
        );

        move_to(
            creator,
            PKTokenStore {
                tokens: vector::empty<PKToken>(),
                public_keys: table::new<String, String>(),
            }
        )
    }

    public entry fun create_subnet_binding(
        creator: &signer,
        target: address,
        subnet: u8,
    ) acquires SubnetStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<SubnetStore>(target), error::not_found(ENETWORK_BINDINGS_NOT_FOUND));

        let bindings = borrow_global_mut<SubnetStore>(target);
        let subnets = &mut bindings.subnets;

        assert!(!has_subnet(subnets, subnet), error::already_exists(ESUBNET_ALREADY_EXISTS));
        assert!(!has_creator(subnets, creator_addr), error::already_exists(ECREATOR_ALREADY_EXISTS));

        // Check subnet
        assert!(0 < subnet && subnet <= 255, error::invalid_argument(ESUBNET_RANGE_INVALID));

        vector::push_back(
            subnets,
            SubnetBinding {
                subnet,
                creator: creator_addr,
            }
        );
    }

    public entry fun delete_subnet_binding(
        creator: &signer,
        target: address,
    ) acquires SubnetStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<SubnetStore>(target), error::not_found(ENETWORK_BINDINGS_NOT_FOUND));

        let bindings = borrow_global_mut<SubnetStore>(target);
        let subnets = &mut bindings.subnets;

        let i = 0;
        let len = vector::length(subnets);
        // remove one subnet binding(because of create limit)
        while (i < len) {
            let subnet = vector::borrow(subnets, i);
            if (subnet.creator == creator_addr) {
                vector::remove(subnets, i);
                return
            };
            i = i + 1;
        }
    }

    public entry fun create_token(
        creator: &signer,
        target: address,
        name: vector<u8>,
        public_key: vector<u8>,
    ) acquires PKTokenStore {
        direct_create_token(creator, target, string::utf8(name), string::utf8(public_key));
    }

    public entry fun delete_token(creator: &signer, target: address, name: vector<u8>) acquires PKTokenStore {
        direct_delete_token(creator, target, string::utf8(name))
    }

    fun direct_create_token(
        creator: &signer,
        target: address,
        name: String,
        public_key: String,
    ) acquires PKTokenStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<PKTokenStore>(target), error::not_found(ENETWORK_BINDINGS_NOT_FOUND));
        let bindings = borrow_global_mut<PKTokenStore>(target);
        let tokens = &mut bindings.tokens;
        let public_keys = &mut bindings.public_keys;

        // Check duplicate
        assert!(!has_name(tokens, name), error::already_exists(ENAME_ALREADY_EXISTS));

        // Validate
        // Validate public key
        // NOTE: maybe todo
        // assert!(ed25519_validate_pubkey(public_key), error::invalid_argument(EPUBLIC_KEY_INVALID));

        // Validate name
        validate_name_charactors(name);

        // Add data
        vector::push_back(
            tokens,
            PKToken {
                name,
                creator: creator_addr,
            }
        );
        table::add(
            public_keys,
            name,
            public_key
        );
    }

    fun direct_delete_token(creator: &signer, target: address, name: String) acquires PKTokenStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<PKTokenStore>(target), error::not_found(ENETWORK_BINDINGS_NOT_FOUND));
        let bindings = borrow_global_mut<PKTokenStore>(target);
        let tokens = &mut bindings.tokens;
        let public_keys = &mut bindings.public_keys;

        let token_optional = get_token(tokens, name);

        // Check having
        assert!(option::is_some(&token_optional), error::already_exists(ETOKEN_NOT_FOUND));

        let token = option::borrow(&token_optional);

        assert!(creator_addr == target || token.creator == creator_addr, error::permission_denied(ETOKEN_PERMISSION_DENIED));

        let (ok, nth) = vector::index_of(tokens, token);
        assert!(ok, ENO_MESSAGE);

        vector::remove(tokens, nth);
        table::remove(public_keys, name);
    }

    fun validate_name_charactors(name: String) {
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

    fun has_subnet(subnets: &vector<SubnetBinding>, subnet: u8): bool {
        let i = 0;
        while (i < vector::length(subnets)) {
            let binding = vector::borrow(subnets, i).subnet;
            if (binding == subnet) {
                return true
            };
            i = i + 1;
        };
        return false
    }

    fun has_creator(subnets: &vector<SubnetBinding>, addr: address): bool {
        let i = 0;
        while (i < vector::length(subnets)) {
            let binding = vector::borrow(subnets, i).creator;
            if (binding == addr) {
                return true
            };
            i = i + 1;
        };
        return false
    }

    fun get_token(tokens: &vector<PKToken>, name: String): Option<PKToken> {
        let i = 0;
        while (i < vector::length(tokens)) {
            let token = vector::borrow(tokens, i);
            if (token.name == name) {
                return option::some(*token)
            };
            i = i + 1;
        };
        option::none<PKToken>()
    }

    fun has_name(tokens: &vector<PKToken>, name: String): bool {
        let i = 0;
        while (i < vector::length(tokens)) {
            if (vector::borrow(tokens, i).name == name) {
                return true
            };
            i = i + 1;
        };
        false
    }

    #[test(account = @0x1)]
    public entry fun test_create_bindings(account: signer) {
        create_subnet_store(&account);

        assert!(exists<SubnetStore>(signer::address_of(&account)), ENO_MESSAGE);
    }

    #[test(account = @0x1)]
    public entry fun test_create_subnet_binding(account: signer) acquires SubnetStore {
        let account_addr = signer::address_of(&account);
        create_subnet_store(&account);

        create_subnet_binding(
            &account,
            account_addr,
            2
        );

        let bindings = borrow_global<SubnetStore>(account_addr);

        assert!(vector::length(&bindings.subnets) == 1, ENO_MESSAGE);

        let subnet = vector::borrow(&bindings.subnets, 0);

        assert!(subnet.creator == account_addr, ENO_MESSAGE);
        assert!(subnet.subnet == 2, ENO_MESSAGE);
    }

    #[test(account = @0x1)]
    public entry fun test_delete_subnet_binding(account: signer) acquires SubnetStore {
        let account_addr = signer::address_of(&account);
        create_subnet_store(&account);

        create_subnet_binding(
            &account,
            account_addr,
            2
        );

        delete_subnet_binding(
            &account,
            account_addr,
        );

        let bindings = borrow_global<SubnetStore>(account_addr);

        assert!(vector::length(&bindings.subnets) == 0, ENO_MESSAGE);
    }

    #[test(account = @0x1)]
    public entry fun test_create_token(account: signer) acquires PKTokenStore {
        let account_addr = signer::address_of(&account);
        create_pk_token_store(&account);

        direct_create_token(
            &account,
            account_addr,
            string::utf8(b"syamimomo"),
            string::utf8(b"+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A"),
        )
    }

    #[test(account = @0x1, target = @0x42)]
    public entry fun test_delete_token(account: signer, target: signer) acquires PKTokenStore {
        let target_addr = signer::address_of(&target);
        create_pk_token_store(&target);

        direct_create_token(
            &account,
            target_addr,
            string::utf8(b"syamimomo"),
            string::utf8(b"+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A"),
        );

        direct_delete_token(
            &account,
            target_addr,
            string::utf8(b"syamimomo"),
        );

        let bindings = borrow_global<PKTokenStore>(target_addr);
        assert!(vector::length(&bindings.tokens) == 0, ENO_MESSAGE);
        assert!(table::length(&bindings.public_keys) == 0, ENO_MESSAGE);
    }

    #[test(account = @0x1, target = @0x42)]
    public entry fun test_delete_aother_token(account: signer, target: signer) acquires PKTokenStore {
        let target_addr = signer::address_of(&target);
        create_pk_token_store(&target);

        direct_create_token(
            &account,
            target_addr,
            string::utf8(b"syamimomo"),
            string::utf8(b"+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A"),
        );

        direct_delete_token(
            &target,
            target_addr,
            string::utf8(b"syamimomo"),
        );

        let bindings = borrow_global<PKTokenStore>(target_addr);
        assert!(vector::length(&bindings.tokens) == 0, ENO_MESSAGE);
        assert!(table::length(&bindings.public_keys) == 0, ENO_MESSAGE);
    }
}
