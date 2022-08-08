import {useEffect, useState} from "react";
import {accountResource, tableItems} from "~/lib/aptos";
import {PUBLISHER} from "~/lib/preferences";
import type {MachikadoAccount} from "~/lib/MachikadoNetwork";


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
        <h1 className="text-xl md:text-3xl font-bold my-2">まちカドネットワーク Subnet一覧</h1>
        <table className={"table-auto"}>
            <thead>
            <tr>
                <th className="px-4 py-2">ユーザー</th>
                <th className="px-4 py-2">Subnet</th>
            </tr>
            </thead>
            <tbody>
            {accounts.map((account, i) =>
                <>
                    {account.subnets.map(
                        (subnet, i2) => <tr key={`${i}-${i2}`}>
                            <td className="border px-4 py-2">{account.name}</td>
                            <td className="border px-4 py-2">10.50.{subnet.id}.0/24</td>
                        </tr>)}
                </>
            )}
            </tbody>
        </table>
    </div>
}

export default Nodes
