import {useEffect, useState} from "react";
import {useAptos} from "~/hooks/aptos";
import AptosLoginWrapper from "~/components/AptosLoginWrapper";
import {accountResource, tableItems} from "~/lib/aptos";
import {PUBLISHER} from "~/lib/preferences";

type Option<T> = [T] | []

interface TincNode {
    name: string
    public_key: string
    inet_hostname: Option<string>
    inet_port: Option<number>
}

interface Subnet {
    id: number
}

interface MachikadoAccount {
    name: string
    nodes: TincNode[]
    subnets: Subnet[]
}

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
            setAccounts(prevState => [...prevState, data])
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
            </tr>
            </thead>
            <tbody>
            {accounts.map((account, i) =>
                <>
                    {account.nodes.map(
                        (node, i2) => <tr key={`${i}-${i2}`}>
                            <td className="border px-4 py-2">{account.name}</td>
                            <td className="border px-4 py-2">{node.name}</td>
                            <td className="border px-4 py-2">{node.public_key.slice(0, 32)}...</td>
                        </tr>)}
                </>
            )}
            </tbody>
        </table>
    </div>
}

export default Nodes
