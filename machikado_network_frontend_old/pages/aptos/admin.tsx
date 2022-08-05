import AptosHeader from "../../components/AptosHeader";
import {useEffect, useState} from "react";
import {useAptos, useAptosAccount} from "../../hooks/aptos";
import Link from "next/link";
import {MachikadoNetwork} from "../../lib/aptos";

const Admin = () => {
    const [moduleHex, setModuleHex] = useState("")
    const [aptos, _] = useAptos()
    const account = useAptosAccount()
    const client = new MachikadoNetwork()

    const installModule = async () => {
        await new MachikadoNetwork().upload_module(moduleHex)
    }

    useEffect(() => {
        (async () => {
            await client.setup(aptos)
        })()
    }, [aptos])

    return <>
        <AptosHeader />
        <div className="container mx-auto my-2 md:my-12">
            <div className="my-6">
                <h2 className="text-2xl font-bold">Aptos Move Moduleをインストールする</h2>
                <p className="text-sm text-slate-500">手順を元にAptos Move Moduleをビルドし、それのhexを貼り付けてください。</p>
                <div>
                    <textarea
                        value={moduleHex} onChange={event => setModuleHex(event.target.value)}
                        className={"w-full md:w-1/2 border-indigo-500 border-2 p-2 h-64"}
                        placeholder={"a11ceb0b050000000d01001002103603468b0104d1011e05ef01f40207e304c2040..."}
                    />
                </div>
                <button
                    className="px-4 py-2 bg-indigo-500 text-white rounded-md my-4"
                    onClick={installModule}
                >
                    インストール
                </button>
                <div className="my-6">
                    <Link href={`https://explorer.devnet.aptos.dev/account/${account?.address}`}>
                        <a className={"px-4 py-2 bg-gray-200 rounded-md"}>ここから確認できます</a>
                    </Link>
                </div>
            </div>
        </div>
        <div className="container mx-auto my-2 md:my-12">
            <div className="my-6">
                <h2 className="text-2xl font-bold">PKToken Storeをインストールする</h2>
                <p className="text-sm text-slate-500">受け取り側がこれをインストールしないとトークン作成に失敗します。</p>
                <button
                    className="px-4 py-2 bg-indigo-500 text-white rounded-md my-4"
                    onClick={(new MachikadoNetwork()).create_token_store}
                >
                    インストール
                </button>
                <div className="my-6">
                    <Link href={`https://explorer.devnet.aptos.dev/account/${account?.address}`}>
                        <a className={"px-4 py-2 bg-gray-200 rounded-md"}>ここから確認できます</a>
                    </Link>
                </div>
            </div>
        </div>
    </>
}

export default Admin
