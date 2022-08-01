import {Aptos} from "../lib/aptos";
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
