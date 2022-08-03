module MachikadoNetwork::MachikadoNetwork {
    use std::string::String;
    use std::vector;
    use std::option::Option;
    use aptos_std::table::Table;
    use std::signer;
    use std::error;

    const ENO_MESSAGE: u64 = 0;

    const EACCOUNT_STORE_ALREADY_EXISTS: u64 = 100;

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

    struct Account has store {
        owner: address,
        name: String,
        nodes: vector<TincNode>,
        subnets: vector<Subnet>,

        additional_fields: Table<String, String>,
    }

    struct AccountStore has key {
        accounts: vector<Account>
    }

    public entry fun create_account_store(creator: &signer) {
        assert!(!exists<AccountStore>(signer::address_of(creator)), error::already_exists(EACCOUNT_STORE_ALREADY_EXISTS));

        move_to(
            creator,
            AccountStore {
                accounts: vector::empty<Account>(),
            }
        );
    }

    #[test(account = @0x42)]
    public entry fun test_create_account_store(account: signer) {
        create_account_store(&account);

        assert!(exists<AccountStore>(signer::address_of(&account)), ENO_MESSAGE);
    }
}
