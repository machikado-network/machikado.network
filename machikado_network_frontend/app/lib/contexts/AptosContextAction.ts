import type {Account} from "~/lib/aptos";

export enum AptosActionType {
    UpdateIsConnected,
    UpdateAccount,
}


export interface UpdateIsConnected {
    type: AptosActionType.UpdateIsConnected,
    value: boolean,
}

export interface UpdateAddress {
    type: AptosActionType.UpdateAccount,
    account: Account | null,
}

export type AptosAction
    = UpdateIsConnected
    | UpdateAddress
