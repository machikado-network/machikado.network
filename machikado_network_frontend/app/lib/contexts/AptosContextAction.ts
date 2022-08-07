import type {Account} from "~/lib/aptos";
import type {MachikadoAccount} from "~/lib/MachikadoNetwork";

export enum AptosActionType {
    UpdateIsConnected,
    UpdateAccount,
    UpdateMachikadoAccount,
}


export interface UpdateIsConnected {
    type: AptosActionType.UpdateIsConnected,
    value: boolean,
}

export interface UpdateAccount {
    type: AptosActionType.UpdateAccount,
    account: Account | null,
}

export interface UpdateMachikadoAccount {
    type: AptosActionType.UpdateMachikadoAccount,
    account: MachikadoAccount | null
}

export type AptosAction
    = UpdateIsConnected
    | UpdateAccount
    | UpdateMachikadoAccount
