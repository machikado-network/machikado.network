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
    arguments?: string[]
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
