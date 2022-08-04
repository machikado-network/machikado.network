module MachikadoNetwork::MachikadoNetwork {
    use MachikadoNetwork::MachikadoAccount::{direct_create_account, direct_update_account_name, direct_create_account_store};
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
}
