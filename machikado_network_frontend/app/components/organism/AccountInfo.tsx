import type { MachikadoAccount,AptosOption} from "~/lib/MachikadoNetwork";
import {useEffect, useState} from "react";
import { getMachikadoAccount} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {useAptos} from "~/hooks/aptos";

const getOption = (o: AptosOption<any>) => o.vec.length === 1 ? o.vec[0] : null

const CreateSubnet = () => {
    const aptos = useAptos()

    return <div className="w-full p-3 bg-gray-200 border-2 border-momo rounded-md my-4">
        <h2 className="font-bold text-lg">あなたのアカウント詳細</h2>
        <h3 className={"font-bold"}>ユーザー名: {aptos.machikadoAccount?.name}</h3>
        <p>Address: {aptos.account?.address}</p>
        <div className="my-2">
            <h3 className="font-bold">Tinc Node一覧</h3>
            <table className={"table-auto"}>
                <thead>
                <tr>
                    <th className="px-4 py-2">ノード名</th>
                    <th className="px-4 py-2">Public Key</th>
                    <th className="px-4 py-2">Inet Hostname</th>
                    <th className="px-4 py-2">Inet Port</th>
                </tr>
                </thead>
                <tbody>
                {aptos.machikadoAccount?.nodes.map(
                    (node, i2) => <tr key={i2}>
                        <td className="border px-4 py-2">{node.name}</td>
                        <td className="border px-4 py-2">{node.public_key.substring(0, 30)}...</td>
                        <td className="border px-4 py-2">{getOption(node.inet_hostname) ?? "なし"}</td>
                        <td className="border px-4 py-2">{getOption(node.inet_port) ?? "なし"}</td>
                    </tr>)}
                </tbody>
            </table>
        </div>
        <div className="my-2">
            <h3 className="font-bold">Subnet一覧</h3>
            <table className={"table-auto"}>
                <thead>
                <tr>
                    <th className="px-4 py-2">Subnet</th>
                </tr>
                </thead>
                <tbody>
                {aptos.machikadoAccount?.subnets.map(
                    (subnet, i2) => <tr key={i2}>
                        <td className="border px-4 py-2">10.50.{subnet.id}.0/24</td>
                    </tr>)}
                </tbody>
            </table>
        </div>
    </div>
}

export default CreateSubnet
