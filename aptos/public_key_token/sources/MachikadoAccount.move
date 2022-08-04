module MachikadoNetwork::MachikadoAccount {
    use std::vector;
    use std::signer;
    use std::error;
    use std::string::{String};
    use std::option::{Option, some, none};
    use aptos_std::table::Table;
    use std::option;
    use aptos_std::table;
    use std::string;
    #[test_only]
    use std::string::{utf8};

    const ENO_MESSAGE: u64 = 0;

    const EACCOUNT_STORE_ALREADY_EXISTS: u64 = 100;
    const EACCOUNT_ALREADY_EXISTS: u64 = 101;
    const ENAME_ALREADY_EXISTS: u64 = 102;
    const ENODE_NAME_ALREADY_EXISTS: u64 = 103;

    const EACCOUNT_STORE_NOT_FOUND: u64 = 200;
    const EACCOUNT_NOT_FOUND: u64 = 201;
    const ENODE_NOT_FOUND: u64 = 202;

    const EINVALID_NAME_CHARACTOR: u64 = 300;
    const EINVALID_ACCOUNT_NAME_LENGTH: u64 = 301;
    const EINVALID_NODE_NAME_LENGTH: u64 = 302;
    const EINVALID_PORT_RANGE: u64 = 303;

    struct TincNode has store, copy, drop {
        // tinc host name e.g. syamimomo
        name: String,
        public_key: String,
        // hostname for network(used when it is root server). e.g. root.mchkd.net or 50.20.0.12
        inet_hostname: Option<String>,
        // port is tinc port (default is 655)
        inet_port: Option<u64>,
    }

    struct Subnet has store, drop {
        id: u8,
    }

    struct AccountKey has key, copy, drop {
        owner: address,
    }

    struct Account has store {
        name: String,
        nodes: vector<TincNode>,
        subnets: vector<Subnet>,

        // e.g. discord account name
        additional_fields: Table<String, String>,
    }

    spec Account {
        invariant string::length(name) <= 32;
    }

    struct AccountStore has key {
        accounts: Table<AccountKey, Account>,
        addresses: vector<address>,
    }

    struct FindResult<T> has store, copy, drop {
        data: T,
        nth: u64,
    }

    public fun direct_create_account_store(creator: &signer) {
        assert!(!exists<AccountStore>(signer::address_of(creator)), error::already_exists(EACCOUNT_STORE_ALREADY_EXISTS));

        move_to(
            creator,
            AccountStore {
                accounts: table::new<AccountKey, Account>(),
                addresses: vector::empty<address>(),
            }
        );
    }

    public fun direct_create_account(
        creator: &signer,
        target: address,
        name: String,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

        // Validate arguments
        // Name length is less than 32.
        assert!(string::length(&name) <= 32, error::invalid_argument(EINVALID_ACCOUNT_NAME_LENGTH));

        assert!(exists<AccountStore>(target), error::not_found(EACCOUNT_STORE_NOT_FOUND));

        let store = borrow_global_mut<AccountStore>(target);
        let accounts = &mut store.accounts;
        let addresses = &mut store.addresses;

        // Check Duplicate
        assert!(option::is_none(&find_account_key_by_name(accounts, addresses, name)), ENAME_ALREADY_EXISTS);
        assert!(!table::contains(accounts, AccountKey {owner: creator_addr}), ENAME_ALREADY_EXISTS);

        table::add(
            accounts,
            AccountKey {owner: creator_addr},
            Account {
                name,
                nodes: vector::empty<TincNode>(),
                subnets: vector::empty<Subnet>(),
                additional_fields: table::new<String, String>(),
            }
        );
        vector::push_back(addresses, creator_addr);
    }

    public fun direct_update_account_name(
        creator: &signer,
        target: address,
        new_name: String,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<AccountStore>(target), error::not_found(EACCOUNT_STORE_NOT_FOUND));

        let store = borrow_global_mut<AccountStore>(target);
        let accounts = &mut store.accounts;
        let addresses = &mut store.addresses;

        // Check user has account
        assert!(table::contains(accounts, AccountKey {owner: creator_addr}), error::not_found(EACCOUNT_NOT_FOUND));

        // Check name duplicate
        assert!(option::is_none(&find_account_key_by_name(accounts, addresses, new_name)), error::already_exists(ENAME_ALREADY_EXISTS));

        // Change name
        let account = table::borrow_mut(accounts, AccountKey {owner: creator_addr});
        account.name = new_name;
    }

    public fun direct_create_node(
        creator: &signer,
        target: address,
        name: String,
        public_key: String,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

        // Validate arguments
        assert!(string::length(&name) <= 32, error::invalid_argument(EINVALID_NODE_NAME_LENGTH));
        assert!(is_valide_name_charactors(name), error::invalid_argument(EINVALID_NAME_CHARACTOR));

        assert!(exists<AccountStore>(target), error::not_found(EACCOUNT_STORE_NOT_FOUND));

        let store = borrow_global_mut<AccountStore>(target);
        let accounts = &mut store.accounts;
        let addresses = &mut store.addresses;

        // Check user has account
        assert!(table::contains(accounts, AccountKey {owner: creator_addr}), error::not_found(EACCOUNT_NOT_FOUND));

        // Check Node name duplicate
        assert!(option::is_none(&find_all_node_by_name(accounts, addresses, name)), error::already_exists(ENODE_NAME_ALREADY_EXISTS));

        let account = table::borrow_mut(accounts, AccountKey {owner: creator_addr});
        let nodes = &mut account.nodes;

        vector::push_back(
            nodes,
            TincNode {
                name,
                public_key,
                inet_hostname: none<String>(),
                inet_port: none<u64>(),
            }
        );
    }

    public fun direct_update_node_public_key(
        creator: &signer,
        target: address,
        name: String,
        public_key: String,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

        assert!(exists<AccountStore>(target), error::not_found(EACCOUNT_STORE_NOT_FOUND));

        let store = borrow_global_mut<AccountStore>(target);
        let accounts = &mut store.accounts;

        // Check user has account
        assert!(table::contains(accounts, AccountKey {owner: creator_addr}), error::not_found(EACCOUNT_NOT_FOUND));

        let account = table::borrow_mut(accounts, AccountKey {owner: creator_addr});
        let nodes = &mut account.nodes;

        let result_optional = find_node_by_name(nodes, name);
        assert!(option::is_some(&result_optional), error::not_found(ENODE_NOT_FOUND));
        let result = option::borrow(&result_optional);

        let node = vector::borrow_mut(nodes, result.nth);
        node.public_key = public_key;
    }

    public fun direct_update_node_inet_host(
        creator: &signer,
        target: address,
        name: String,
        inet_hostname: String,
        inet_port: u64,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

        // Validate arguments
        // inet port is 1 <= 65535
        assert!(1 <= inet_port && inet_port < 65536, error::invalid_argument(EINVALID_PORT_RANGE));

        assert!(exists<AccountStore>(target), error::not_found(EACCOUNT_STORE_NOT_FOUND));

        let store = borrow_global_mut<AccountStore>(target);
        let accounts = &mut store.accounts;

        // Check user has account
        assert!(table::contains(accounts, AccountKey {owner: creator_addr}), error::not_found(EACCOUNT_NOT_FOUND));

        let account = table::borrow_mut(accounts, AccountKey {owner: creator_addr});
        let nodes = &mut account.nodes;

        let result_optional = find_node_by_name(nodes, name);
        assert!(option::is_some(&result_optional), error::not_found(ENODE_NOT_FOUND));
        let result = option::borrow(&result_optional);

        let node = vector::borrow_mut(nodes, result.nth);

        node.inet_hostname = some(inet_hostname);
        node.inet_port = some(inet_port);
    }

    fun find_account_key_by_name(accounts: &Table<AccountKey, Account>, addresses: &vector<address>, name: String): Option<AccountKey> {
        let i = 0u64;
        while (i < vector::length(addresses)) {
            let addr = *vector::borrow(addresses, i);
            let account = table::borrow(accounts, AccountKey {owner: addr});
            if (account.name == name) {
                return some(AccountKey {owner: addr})
            };
            i = i + 1;
        };
        return none<AccountKey>()
    }

    fun find_node_by_name(nodes: &vector<TincNode>, name: String): Option<FindResult<TincNode>> {
        let i = 0;
        while (i < vector::length(nodes)) {
            let node = vector::borrow(nodes, i);
            if (node.name == name) {
                return some(FindResult<TincNode> {
                    data: *node,
                    nth: i,
                })
            };
            i = i + 1;
        };
        none<FindResult<TincNode>>()
    }

    fun find_all_node_by_name(accounts: &Table<AccountKey, Account>, addresses: &vector<address>, name: String): Option<FindResult<TincNode>> {
        let i = 0;
        while (i < vector::length(addresses)) {
            let addr = vector::borrow(addresses, i);
            let account = table::borrow(accounts, AccountKey {owner: *addr});
            let node = find_node_by_name(&account.nodes, name);
            if (option::is_some(&node)) {
                return node
            };
            i = i + 1;
        };
        none<FindResult<TincNode>>()
    }

    fun is_valide_name_charactors(name: String): bool {
        let i = 0;
        let name_raw = string::bytes(&name);
        while (i < string::length(&name)) {
            let char = vector::borrow(name_raw, i);
            if (!((48 <= *char && *char <= 57) || (97 <= *char && *char <= 122))) {
                return false
            };
            i = i + 1;
        };
        true
    }

    #[test_only]
    fun addr(account: &signer): address {
        signer::address_of(account)
    }

    #[test(account = @0x42)]
    public entry fun test_create_account_store(account: signer) {
        direct_create_account_store(&account);

        assert!(exists<AccountStore>(signer::address_of(&account)), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_create_account(account: signer, target: signer) acquires AccountStore {
        direct_create_account_store(&target);

        direct_create_account(
            &account,
            addr(&target),
            utf8(b"syamimomo")
        );

        let store = borrow_global<AccountStore>(addr(&target));
        let accounts = &store.accounts;
        let addresses = &store.addresses;

        assert!(table::contains(accounts, AccountKey {owner: signer::address_of(&account)}), ENO_MESSAGE);
        assert!(vector::contains(addresses, &signer::address_of(&account)), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_update_account_name(account: signer, target: signer) acquires AccountStore {
        direct_create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            utf8(b"syamimomo")
        );

        direct_update_account_name(
            &account,
            signer::address_of(&target),
            utf8(b"mikan")
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let acc = table::borrow(accounts, AccountKey {owner: signer::address_of(&account)});
        assert!(acc.name == utf8(b"mikan"), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_create_node(account: signer, target: signer) acquires AccountStore {
        direct_create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            utf8(b"syamimomo")
        );

        direct_create_node(
            &account,
            addr(&target),
            utf8(b"ogura"),
            utf8(b"12345ABC"),
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let acc = table::borrow(accounts, AccountKey {owner: signer::address_of(&account)});

        assert!(acc.name == utf8(b"syamimomo"), ENO_MESSAGE);

        // Get Node
        assert!(vector::length(&acc.nodes) == 1, ENO_MESSAGE);
        let token = vector::borrow(&acc.nodes, 0);
        assert!(token.name == utf8(b"ogura"), ENO_MESSAGE);
        assert!(token.public_key == utf8(b"12345ABC"), ENO_MESSAGE);
        assert!(option::is_none(&token.inet_hostname), ENO_MESSAGE);
        assert!(option::is_none(&token.inet_port), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_update_node_public_key(account: signer, target: signer) acquires AccountStore {
        direct_create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            utf8(b"syamimomo")
        );

        direct_create_node(
            &account,
            addr(&target),
            utf8(b"ogura"),
            utf8(b"12345ABC"),
        );

        direct_update_node_public_key(
            &account,
            addr(&target),
            utf8(b"ogura"),
            utf8(b"6789XYZ"),
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let acc = table::borrow(accounts, AccountKey {owner: signer::address_of(&account)});

        assert!(acc.name == utf8(b"syamimomo"), ENO_MESSAGE);

        // Get Node
        assert!(vector::length(&acc.nodes) == 1, ENO_MESSAGE);
        let token = vector::borrow(&acc.nodes, 0);
        assert!(token.public_key == utf8(b"6789XYZ"), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_update_node_inet_host(account: signer, target: signer) acquires AccountStore {
        direct_create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            utf8(b"syamimomo")
        );

        direct_create_node(
            &account,
            addr(&target),
            utf8(b"ogura"),
            utf8(b"12345ABC"),
        );

        direct_update_node_inet_host(
            &account,
            addr(&target),
            utf8(b"ogura"),
            utf8(b"host.example.com"),
            655,
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let acc = table::borrow(accounts, AccountKey {owner: signer::address_of(&account)});

        assert!(acc.name == utf8(b"syamimomo"), ENO_MESSAGE);

        // Get Node
        assert!(vector::length(&acc.nodes) == 1, ENO_MESSAGE);
        let token = vector::borrow(&acc.nodes, 0);
        assert!(token.inet_hostname == some(utf8(b"host.example.com")), ENO_MESSAGE);
        assert!(token.inet_port == some(655), ENO_MESSAGE);
    }
}