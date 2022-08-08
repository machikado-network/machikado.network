import {useEffect, useState} from "react";
import {accountResource, tableItems} from "~/lib/aptos";
import {PUBLISHER} from "~/lib/preferences";
import type {AptosOption, MachikadoAccount} from "~/lib/MachikadoNetwork";


const getOption = (o: AptosOption<any>) => o.vec.length === 1 ? o.vec[0] : null


const Nodes = () => {
    const [accounts, setAccounts] = useState<MachikadoAccount[]>([])

    async function getAccounts() {
        const resource = await accountResource(PUBLISHER, `${PUBLISHER}::MachikadoAccount::AccountStore`)
        const store = resource.data.accounts.handle;
        for (const addr of resource.data.addresses as string[]) {
            const id = {
                owner: addr
            }
            const data = await tableItems<MachikadoAccount>(store, `${PUBLISHER}::MachikadoAccount::AccountKey`, `${PUBLISHER}::MachikadoAccount::Account`, id);
            setAccounts(prevState => [...prevState, data!])
        }
    }

    useEffect(() => {
        getAccounts()
    }, [])

    return <div className={"mx-auto container py-4 md:py-12"}>
        <h1 className="text-xl md:text-3xl font-bold my-2">まちカドネットワーク Node一覧</h1>
        <table className={"table-auto"}>
            <thead>
            <tr>
                <th className="px-4 py-2">ユーザー</th>
                <th className="px-4 py-2">ノード名</th>
                <th className="px-4 py-2">Public Key</th>
                <th className="px-4 py-2">Inet Hostname</th>
                <th className="px-4 py-2">Inet Port</th>
            </tr>
            </thead>
            <tbody>
            {accounts.map((account, i) =>
                account.nodes.map(
                    (node, i2) => <tr key={`${i}-${i2}`}>
                        <td className="border px-4 py-2">{account.name}</td>
                        <td className="border px-4 py-2">{node.name}</td>
                        <td className="border px-4 py-2">{node.public_key.substring(0, 30)}...</td>
                        <td className="border px-4 py-2">{getOption(node.inet_hostname) ?? "なし"}</td>
                        <td className="border px-4 py-2">{getOption(node.inet_port) ?? "なし"}</td>
                    </tr>)
            )}
            </tbody>
        </table>
    </div>
}

export default Nodes
