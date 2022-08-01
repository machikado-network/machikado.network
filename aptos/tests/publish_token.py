import sys
from typing import Any

from aptos import Account, FaucetClient, RestClient, TESTNET_URL, FAUCET_URL
import requests


class PublishTokenClient(RestClient):
    def get_table_item(self, handle: str, key_type: str, value_type: str, key: Any) -> Any:
        response = requests.post(f"{self.url}/tables/{handle}/item", json={
            "key_type": key_type,
            "value_type": value_type,
            "key": key,
        })
        assert response.status_code == 200, response.text
        return response.json()

    def publish_module(self, account_from: Account, module_hex: str) -> str:
        """Publish a new module to the blockchain within the specified account"""

        payload = {
            "type": "module_bundle_payload",
            "modules": [
                {"bytecode": f"0x{module_hex}"},
            ],
        }
        txn_request = self.generate_transaction(account_from.address(), payload)
        signed_txn = self.sign_transaction(account_from, txn_request)
        res = self.submit_transaction(signed_txn)
        return str(res["hash"])

    def create_token(self, contract_address: str, account_from: Account, name: str, ip: str, public_key: str):
        payload = {
            "type": "script_function_payload",
            "function": f"0x{contract_address}::MachikadoNetwork::create_token",
            "type_arguments": [],
            "arguments": [
                name.encode("utf-8").hex(),
                ip.encode("utf-8").hex(),
                public_key.encode("utf-8").hex(),
            ]
        }
        res = self.execute_transaction_with_payload(account_from, payload)
        return str(res["hash"])

    def publish(self, contract_address: str, account_from: Account, name: str, account_to: Account):
        payload = {
            "type": "script_function_payload",
            "function": f"0x{contract_address}::MachikadoNetwork::publish",
            "type_arguments": [],
            "arguments": [
                name.encode("utf-8").hex(),
                "0x" + account_to.address(),
            ]
        }
        res = self.execute_transaction_with_payload(account_from, payload)
        return str(res["hash"])

    def create_published_token_store(self, contract_address: str, account_from: Account):
        payload = {
            "type": "script_function_payload",
            "function": f"0x{contract_address}::MachikadoNetwork::create_published_token_store",
            "type_arguments": [],
            "arguments": []
        }
        res = self.execute_transaction_with_payload(account_from, payload)
        return str(res["hash"])

    def get_token_store(self, contract_address: str, account_address: str):
        return self.account_resource(account_address, f"0x{contract_address}::MachikadoNetwork::TokenStore")

    def get_published_token_store(self, contract_address: str, account_address: str):
        return self.account_resource(account_address, f"0x{contract_address}::MachikadoNetwork::PublishedTokenStore")


if __name__ == "__main__":
    client = PublishTokenClient(TESTNET_URL)
    faucet_client = FaucetClient(FAUCET_URL, client)

    alice = Account()
    bob = Account()

    print("\n=== Addresses ===")
    print(f"Alice: {alice.address()}")
    print(f"Bob: {bob.address()}")

    faucet_client.fund_account(alice.address(), 10_000_000)
    faucet_client.fund_account(bob.address(), 10_000_000)

    print("\n=== Initial Balances ===")
    print(f"Alice: {client.account_balance(alice.address())}")
    print(f"Bob: {client.account_balance(bob.address())}")

    input("\nUpdate the module with Alice's address, build, copy to the provided path, and press enter.")
    module_path = sys.argv[1]
    with open(module_path, "rb") as f:
        module_hex = f.read().hex()

    print("\n=== Testing Alice ===")
    print("Publishing...")
    tx_hash = client.publish_module(alice, module_hex)
    client.wait_for_transaction(tx_hash)

    print("creating ogura token...")
    tx_hash = client.create_token(alice.address(), alice, "ogura", "10.50.0.5", "+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A")
    client.wait_for_transaction(tx_hash)
    print(f"New value: {client.get_token_store(alice.address(), alice.address())}")

    print("\n=== Testing Bob ===")
    print("create published token store")
    tx_hash = client.create_published_token_store(alice.address(), bob)
    client.wait_for_transaction(tx_hash)

    print("publish ogura")
    tx_hash = client.publish(alice.address(), alice, "ogura", bob)
    client.wait_for_transaction(tx_hash)

    print(f"New value: {client.get_published_token_store(alice.address(), bob.address())}")

    store = client.account_resource(bob.address(), f"0x{alice.address()}::MachikadoNetwork::PublishedTokenStore")["data"]["tokens"]["handle"]
    print(store)
    r = client.get_table_item(store, "0x1::string::String", f"0x{alice.address()}::MachikadoNetwork::PublishedToken", "ogura")
    print(r)

