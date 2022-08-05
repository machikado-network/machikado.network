import {useContext, useEffect} from "react";
import {AptosContext} from "~/lib/contexts/AptosContext";
import {AptosActionType} from "~/lib/contexts/AptosContextAction";

export function useAptos() {
    const {state, dispatch} = useContext(AptosContext)

    useEffect(() => {
        (async () => {
            dispatch({
                type: AptosActionType.UpdateIsConnected,
                value: await window.aptos?.isConnected() ?? false
            })
        })()
    }, [dispatch])

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

    return {
        isConnected: state.isConnected,
        account: state.account,
        connect,
        disconnect,
    }
}
