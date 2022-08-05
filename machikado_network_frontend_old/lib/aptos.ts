import assert from "assert";
import {toast} from "react-toastify";

declare global {
    var aptos: Aptos | undefined
}


export interface Aptos {
    connect(): Promise<void>
    isConnected(): Promise<boolean>
    account(): Promise<Account>
    signAndSubmitTransaction(transaction: Transaction): Promise<TransactionResponse>
    signTransaction(transaction: Transaction): Promise<any>
    disconnect(): Promise<void>
}


export interface Account {
    address: string
    publicKey: string
}


export interface Transaction {
    type: string
    function?: string
    type_arguments?: string[]
    arguments?: (string | number)[]
    modules?: {
        bytecode: string
    }[]
}


export interface TransactionResponse {
    expiration_timestamp_secs: string
    gas_unit_price: string
    hash: string
    max_gas_amount: string
    payload: any
    sender: string
    sequence_number: string
    type: string
}


const TESTNET_URL = "https://fullnode.devnet.aptoslabs.com"


const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))


async function is_transaction_pending(hash: string): Promise<boolean> {
    const response = await fetch(`${TESTNET_URL}/transactions/${hash}`)
    if (response.status === 404) return true
    return (await response.json()).type === "pending_transaction"
}

async function wait_for_transaction(tx: any) {
    const hash = tx.hash;
    while (await is_transaction_pending(hash)) {
        await sleep(1000)
    }
    const response = await fetch(`${TESTNET_URL}/transactions/${hash}`)
    const json = await response.json()
    assert(response.status === 200 && typeof json.success !== "undefined")
    return json
}


export class MachikadoNetwork {
    account?: Account

    async setup(aptos?: Aptos) {
        this.account = await aptos?.account()
    }

    async create_token_store() {
        const account = await window.aptos?.account()
        const tx = await window.aptos?.signAndSubmitTransaction({
            "type": "script_function_payload",
            "function": `${account?.address}::MachikadoNetwork::create_token_store`,
            "type_arguments": [],
            "arguments": []
        })
        console.log(tx)
        const a = await wait_for_transaction(tx)
        console.log(a)
        toast("token store created!")
    }

    async upload_module(hex: string) {
        const tx = await window.aptos?.signAndSubmitTransaction({
            "type": "module_bundle_payload",
            "modules": [
                {"bytecode": `0x${hex}`},
            ],
        })
        await wait_for_transaction(tx)
        toast("module uploaded!")
    }

    async accountResource(address: string, resourceType: string): Promise<any> {
        const response = await fetch(
            `${TESTNET_URL}/accounts/${address}/resource/${resourceType}`
        )
        if (response.status > 399) {
            return null
        }
        return await response.json()
    }

    async tableItems(handle: string, keyType: string, valueType: string, key: any) {
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
        return await response.json()
    }
}
