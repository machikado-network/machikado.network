import type {Dispatch} from "react";
import {createContext} from "react";
import type {AptosAction} from "~/lib/contexts/AptosContextAction";
import {AptosActionType} from "~/lib/contexts/AptosContextAction";
import type {Account, Address} from "~/lib/aptos";

export interface AptosContextData {
    isConnected: boolean
    account: Account | null
}


export const AptosContext = createContext<{state: AptosContextData, dispatch: Dispatch<AptosAction>}>({
    state: {
        isConnected: false,
        account: null,
    },
    dispatch: () => {}
})

export const aptosReducer = (state: AptosContextData, action: AptosAction) => {
    switch (action.type) {
        case AptosActionType.UpdateIsConnected:
            return {
                ...state,
                isConnected: action.value,
            }
        case AptosActionType.UpdateAccount:
            return {
                ...state,
                account: action.account,
            }
    }
    return state
}
