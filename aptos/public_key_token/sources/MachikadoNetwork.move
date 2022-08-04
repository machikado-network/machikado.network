module MachikadoNetwork::MachikadoNetwork {
    use std::vector;
    use std::signer;
    use std::error;
    use std::string::String;
    use std::option::{Option, some, none};
    use aptos_std::table::Table;
    use std::string;
    use std::option;
    use aptos_std::table;

    const ENO_MESSAGE: u64 = 0;

    const EACCOUNT_STORE_ALREADY_EXISTS: u64 = 100;
    const EACCOUNT_ALREADY_EXISTS: u64 = 101;
    const ENAME_ALREADY_EXISTS: u64 = 102;

    const EACCOUNT_STORE_NOT_FOUND: u64 = 200;
    const EACCOUNT_NOT_FOUND: u64 = 201;

    struct TincNode has store, copy, drop {
        // tinc host name e.g. syamimomo
        name: String,
        public_key: String,
        // hostname for network(used when it is root server). e.g. root.mchkd.net or 50.20.0.12
        inet_hostname: Option<String>,
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

    struct AccountStore has key {
        accounts: Table<AccountKey, Account>,
        addresses: vector<address>,
    }

    public entry fun create_account_store(creator: &signer) {
        assert!(!exists<AccountStore>(signer::address_of(creator)), error::already_exists(EACCOUNT_STORE_ALREADY_EXISTS));

        move_to(
            creator,
            AccountStore {
                accounts: table::new<AccountKey, Account>(),
                addresses: vector::empty<address>(),
            }
        );
    }

    public entry fun create_account(
        creator: &signer,
        target: address,
        name: vector<u8>,
    ) acquires AccountStore {
        direct_create_account(creator, target, string::utf8(name));
    }

    public entry fun update_account_name(
        creator: &signer,
        target: address,
        new_name: vector<u8>,
    ) acquires AccountStore {
        direct_update_account_name(creator, target, string::utf8(new_name));
    }

    fun direct_create_account(
        creator: &signer,
        target: address,
        name: String,
    ) acquires AccountStore {
        let creator_addr = signer::address_of(creator);

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

    fun direct_update_account_name(
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

    #[test(account = @0x42)]
    public entry fun test_create_account_store(account: signer) {
        create_account_store(&account);

        assert!(exists<AccountStore>(signer::address_of(&account)), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_create_account(account: signer, target: signer) acquires AccountStore {
        create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            string::utf8(b"syamimomo")
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let addresses = &store.addresses;

        assert!(table::contains(accounts, AccountKey {owner: signer::address_of(&account)}), ENO_MESSAGE);
        assert!(vector::contains(addresses, &signer::address_of(&account)), ENO_MESSAGE);
    }

    #[test(account = @0x42, target = @0x1)]
    public entry fun test_update_account_name(account: signer, target: signer) acquires AccountStore {
        create_account_store(&target);

        direct_create_account(
            &account,
            signer::address_of(&target),
            string::utf8(b"syamimomo")
        );

        direct_update_account_name(
            &account,
            signer::address_of(&target),
            string::utf8(b"mikan")
        );

        let store = borrow_global<AccountStore>(signer::address_of(&target));
        let accounts = &store.accounts;
        let acc = table::borrow(accounts, AccountKey {owner: signer::address_of(&account)});
        assert!(acc.name == string::utf8(b"mikan"), ENO_MESSAGE);
    }
}
