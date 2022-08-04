module MachikadoNetwork::MachikadoNetwork {
    use MachikadoNetwork::MachikadoAccount::{direct_create_account, direct_update_account_name, direct_create_account_store, direct_create_node, direct_update_node_public_key, direct_update_node_inet_host};
    use std::string;

    public entry fun create_account_store(creator: &signer) {
        direct_create_account_store(creator);
    }

    public entry fun create_account(
        creator: &signer,
        target: address,
        name: vector<u8>,
    ) {
        direct_create_account(creator, target, string::utf8(name));
    }

    public entry fun update_account_name(
        creator: &signer,
        target: address,
        new_name: vector<u8>,
    ) {
        direct_update_account_name(creator, target, string::utf8(new_name));
    }

    public entry fun create_node(
        creator: &signer,
        target: address,
        name: vector<u8>,
        public_key: vector<u8>,
    ) {
        direct_create_node(creator, target, string::utf8(name), string::utf8(public_key));
    }

    public entry fun update_node_public_key(
        creator: &signer,
        target: address,
        name: vector<u8>,
        public_key: vector<u8>,
    ) {
        direct_update_node_public_key(creator, target, string::utf8(name), string::utf8(public_key));
    }

    public entry fun update_node_inet_host(
        creator: &signer,
        target: address,
        name: vector<u8>,
        inet_hostname: vector<u8>,
        inet_port: u64,
    ) {
        direct_update_node_inet_host(creator, target, string::utf8(name), string::utf8(inet_hostname), inet_port);
    }
}
