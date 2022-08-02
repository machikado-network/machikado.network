import sys
from typing import Any

from aptos import Account, FaucetClient, RestClient, TESTNET_URL, FAUCET_URL
import requests


class PublishTokenClient(RestClient):

    def create_token(self, contract_address: str, account_from: Account, target_address: str, name: str, subnet: int, public_key: str):
        payload = {
            "type": "script_function_payload",
            "function": f"0x{contract_address}::MachikadoNetwork::create_token",
            "type_arguments": [],
            "arguments": [
                "0x" + target_address,
                name.encode("utf-8").hex(),
                subnet,
                public_key.encode("utf-8").hex(),
            ]
        }
        res = self.execute_transaction_with_payload(account_from, payload)
        return str(res["hash"])

    def create_pktoken_store(self, contract_address: str, account_from: Account):
        payload = {
            "type": "script_function_payload",
            "function": f"0x{contract_address}::MachikadoNetwork::create_token_store",
            "type_arguments": [],
            "arguments": []
        }
        res = self.execute_transaction_with_payload(account_from, payload)
        return str(res["hash"])

    def get_token_store(self, contract_address: str, account_address: str):
        return self.account_resource(account_address, f"0x{contract_address}::MachikadoNetwork::PKTokenStore")


if __name__ == "__main__":
    # MachikadoNetworkにアクセスするためのREST Client
    client = PublishTokenClient(TESTNET_URL)
    # 無料でお金をもらうためのFaucet Client
    faucet_client = FaucetClient(FAUCET_URL, client)

    alice = Account()
    bob = Account()

    print("\n=== Addresses ===")
    print(f"Alice: {alice.address()}")
    print(f"Bob: {bob.address()}")

    # テストのため、二つのアドレスにお金を振り込む
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
    # AliceのアカウントにMove Moduleを公開し使えるようにする
    tx_hash = client.publish_module(alice, module_hex)
    client.wait_for_transaction(tx_hash)

    print("Create bob's token store")
    # 先ほど公開したMove Moduleを利用してPKToken Storeを作成する（しないとそのアドレスに対してトークン作成できない）
    tx_hash = client.create_pktoken_store(alice.address(), bob)
    client.wait_for_transaction(tx_hash)

    print("creating ogura token...")
    # bobのアドレスに対してaliceがoguraという名前でトークンを作成している。subnetは2なので10.50.2.0/24がaliceのものになる
    tx_hash = client.create_token(alice.address(), alice, bob.address(), "ogura", 2, "+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A")
    client.wait_for_transaction(tx_hash)
    print(f"New value: {client.get_token_store(alice.address(), bob.address())}")
