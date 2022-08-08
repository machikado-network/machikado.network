import {useContext} from "react";
import {AptosContext} from "~/lib/contexts/AptosContext";
import {AptosActionType} from "~/lib/contexts/AptosContextAction";
import {getMachikadoAccount} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";


export function useAptos() {
    const {state, dispatch} = useContext(AptosContext)

    async function updateMachikadoAccount() {
        const machikadoAccount = await getMachikadoAccount(PUBLISHER, PUBLISHER, (await window.aptos!.account()).address)
        dispatch({
            type: AptosActionType.UpdateMachikadoAccount,
            account: machikadoAccount,
        })
    }

    async function connect() {
        await window.aptos!.connect();
        dispatch({
            type: AptosActionType.UpdateIsConnected,
            value: await window.aptos?.isConnected() ?? false,
        })
        const account = await window.aptos!.account()
        dispatch({
            type: AptosActionType.UpdateAccount,
            account,
        })
    }

    async function disconnect() {
        await window.aptos!.disconnect()
        dispatch({
            type: AptosActionType.UpdateIsConnected,
            value: await window.aptos?.isConnected() ?? false,
        })
        dispatch({
            type: AptosActionType.UpdateAccount,
            account: null,
        })
    }

    async function updateAccount() {
        dispatch({
            type: AptosActionType.UpdateAccount,
            account: await window.aptos?.account() ?? null,
        })
    }

    return {
        isConnected: state.isConnected,
        account: state.account,
        machikadoAccount: state.machikadoAccount,
        connect,
        disconnect,
        updateAccount,
        updateMachikadoAccount,
    }
}
