import type {AptosPayload} from "~/lib/aptos/TransactionBuilder";
import type {Address} from "~/lib/aptos";
import {waitForTransaction} from "~/lib/aptos";

export async function createAccountStore(publisher: Address) {
    const payload: AptosPayload = {
        type: "script_function_payload",
        function: `${publisher}::MachikadoNetwork::create_account_store`,
        arguments: [],
        type_arguments: [],
    }
    const tx = await window.aptos!.signAndSubmitTransaction(payload)
    await waitForTransaction(tx)
}
