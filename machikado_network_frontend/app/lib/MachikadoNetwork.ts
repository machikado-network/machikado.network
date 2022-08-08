import type {AptosPayload} from "~/lib/aptos/TransactionBuilder";
import type {Address} from "~/lib/aptos";
import {accountResource, tableItems, waitForTransaction} from "~/lib/aptos";
import {PUBLISHER} from "~/lib/preferences";


export type AptosOption<T> = {
    vec: [T] | []
}

export interface TincNode {
    name: string
    public_key: string
    inet_hostname: AptosOption<string>
    inet_port: AptosOption<number>
}

export interface Subnet {
    id: number
}

export interface MachikadoAccount {
    name: string
    nodes: TincNode[]
    subnets: Subnet[]
}


export async function createAccountStore(publisher: Address) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::create_account_store`,
        arguments: [],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}

const toHex = (s: string) => Array.from(new TextEncoder().encode(s)).map(x => x.toString(16)).join("")

export async function createMachikadoAccount(publisher: Address, target: Address, name: string) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::create_account`,
        arguments: [target, toHex(name)],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}


export async function updateMachikadoAccountName(publisher: Address, target: Address, name: string) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::update_account_name`,
        arguments: [target, toHex(name)],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}

export async function createTincNode(publisher: Address, target: Address, name: string, publicKey: string) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::create_node`,
        arguments: [target, toHex(name), toHex(publicKey)],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}

export async function updateInetHost(publisher: Address, target: Address, name: string, hostname: string, port: number) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::update_node_inet_host`,
        arguments: [target, toHex(name), toHex(hostname), port.toString()],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}

export async function createSubnet(publisher: Address, target: Address, id: number) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::create_subnet`,
        arguments: [target, id],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    return await waitForTransaction(tx)
}

export async function getMachikadoAccount(publisher: Address, target: Address, myAddress: Address) {
    const resource = await accountResource(target, `${publisher}::MachikadoAccount::AccountStore`)
    const store = resource.data.accounts.handle;
    const id = {
        owner: myAddress,
    }
    return await tableItems<MachikadoAccount>(store, `${PUBLISHER}::MachikadoAccount::AccountKey`, `${PUBLISHER}::MachikadoAccount::Account`, id);
}
