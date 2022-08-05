import {Account, Aptos} from "../lib/aptos";
import {useEffect, useState} from "react";

export function useAptos(): [Aptos | undefined, () => void] {
    const [aptos, setAptos] = useState<Aptos | undefined>(undefined)

    useEffect(() => {
        setAptos(window.aptos)
    }, [])

    const update = () => {
        setAptos(window.aptos)
    }

    return [aptos, update]
}

export function useAptosAccount(): Account | undefined {
    const [account, setAccount] = useState<Account | undefined>(undefined)

    useEffect(() => {
        (async () => {
            setAccount(await window.aptos?.account())
        })()
    }, [])

    return account
}
