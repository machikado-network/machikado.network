import {useEffect, useState} from "react";
import {MachikadoNetwork} from "../../lib/aptos";
import Link from "next/link";


function hex2hexs(hex: string) {
    const hexs = [];
    for (let i = 0; i < hex.length; i += 2) {
        hexs.push(parseInt(hex.substring(i, i + 2), 16));
    }
    return hexs;
}


interface PKToken {
    name: string
    creator: string
    public_key: string
}


const Hosts = () => {
    const [subnets, setSubnets] = useState<{subnet: number, token: PKToken}[]>([])
    const [moduler, setModuler] = useState("0x966802465c8c02b2b7e7c6daabe5b391f09dee134df785224d3f66500ba43cfc")

    async function getToken(handle: string, subnet: number): Promise<PKToken> {
        const aptos = new MachikadoNetwork()
        return await aptos.tableItems(handle, "u8", `${moduler}::MachikadoNetwork::PKToken`, subnet)
    }

    async function getHosts() {
        const aptos = new MachikadoNetwork()
        const resource = await aptos.accountResource(moduler, `${moduler}::MachikadoNetwork::PKTokenStore`)
        const subs = hex2hexs((resource.data.subnets as string).replace("0x", ""))
        for (const sub of subs) {
            const token = await getToken(resource.data.tokens.handle as string, sub)
            setSubnets(before => [...before, {
                subnet: sub,
                token,
            }])
        }
    }

    useEffect(() => {
        getHosts().catch(console.log)
    }, [])

    return <div className="my-2 md:my-12">
        <h1 className="text-3xl font-bold text-center">登録されたホスト一覧</h1>
        <div className="w-full md:w-2/3 mx-auto mt-12">
            <div className={"border-2 border-indigo-500 p-2 rounded-md"}>
                <table className="table-auto">
                    <thead>
                    <tr>
                        <th className="px-4 py-2">IPアドレス範囲</th>
                        <th className="px-4 py-2">名前</th>
                        <th className="px-4 py-2">持ち主</th>
                        <th className="px-4 py-2">公開鍵</th>
                    </tr>
                    </thead>
                    <tbody>
                    {subnets.map((x, i) =>
                        <tr key={i}>
                            <td className={"border px-4 py-2"}>10.50.{x.subnet}.0/24</td>
                            <td className={"border px-4 py-2"}>{x.token.name}</td>
                            <td className={"border px-4 py-2"}>
                                <Link href={`https://explorer.devnet.aptos.dev/account/${x.token.creator}`}>
                                    <a className="text-indigo-300 hover:text-indigo-500">{x.token.creator.substring(0, 10)}...</a>
                                </Link>
                            </td>
                            <td className={"border px-4 py-2"}>{x.token.public_key}</td>
                        </tr>
                    )}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
}

export default Hosts
