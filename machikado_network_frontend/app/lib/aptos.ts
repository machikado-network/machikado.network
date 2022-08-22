import assert from "assert";
import type {Transaction} from "aptos/dist/generated";
import type {AptosPayload} from "~/lib/aptos/TransactionBuilder";


/// Aptos Address
export type Address = string


declare global {
    var aptos: Aptos | undefined
}


export interface Aptos {
    connect(): Promise<void>
    isConnected(): Promise<boolean>
    account(): Promise<Account>
    signAndSubmitTransaction(transaction: AptosPayload): Promise<Transaction>
    signTransaction(transaction: AptosPayload): Promise<Transaction>
    disconnect(): Promise<void>
}


export interface Account {
    address: string
    publicKey: string
}


const TESTNET_URL = "https://fullnode.devnet.aptoslabs.com/v1"


const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))


async function isTransactionPending(hash: string): Promise<boolean> {
    const response = await fetch(`${TESTNET_URL}/transactions/by_hash/${hash}`)
    if (response.status === 404) return true
    return (await response.json<Transaction>()).type === "pending_transaction"
}

export async function waitForTransaction(tx: Transaction) {
    const hash = tx.hash;
    let retry = 0;
    while (await isTransactionPending(hash) && retry < 5) {
        retry++
        await sleep(1000 * retry)
    }
    const response = await fetch(`${TESTNET_URL}/transactions/by_hash/${hash}`)
    const json = await response.json<any>()
    assert(response.status === 200 && typeof json.success !== "undefined")
    return json
}


export async function uploadModules(hex: string[]) {
    const tx = await window.aptos!.signAndSubmitTransaction({
        "type": "module_bundle_payload",
        "modules": hex.map(x => ({"bytecode": x})),
    })
    return await waitForTransaction(tx)
}

export async function accountResource(address: string, resourceType: string): Promise<any> {
    const response = await fetch(
        `${TESTNET_URL}/accounts/${address}/resource/${resourceType}`,
    )
    if (response.status > 399) {
        return null
    }
    return await response.json()
}


export async function tableItems<T>(handle: string, keyType: string, valueType: string, key: any) {
    const response = await fetch(
        `${TESTNET_URL}/tables/${handle}/item`,
        {
            body: JSON.stringify({
                key_type: keyType,
                value_type: valueType,
                key,
            }),
            method: "POST",
            headers: [
                ["Content-Type", "application/json"]
            ]
        }
    )
    if (response.status > 399) {
        return null
    }
    return await response.json<T>()
}
