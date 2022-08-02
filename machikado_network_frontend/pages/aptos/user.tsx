import {useEffect, useState} from "react";
import {useAptos} from "../../hooks/aptos";
import {Account} from "../../lib/aptos";
import AptosHeader from "../../components/AptosHeader";
import Link from "next/link";
import {toast} from "react-toastify";

const User = () => {
    //　もし変更したい場合はここを変更可能にする
    // modulerは関数を所有している人
    const [moduler, setModuler] = useState("0x966802465c8c02b2b7e7c6daabe5b391f09dee134df785224d3f66500ba43cfc")
    const [name, setName] = useState("")
    const [subnet, setSubnet] = useState(2)
    const [publicKey, setPublicKey] = useState("")

    // 宛先
    const [publisher, setPublisher] = useState("0x966802465c8c02b2b7e7c6daabe5b391f09dee134df785224d3f66500ba43cfc")
    const [aptos, _] = useAptos()
    const [account, setAccount] = useState<Account | null>(null)

    useEffect(() => {
        (async () => {
            setAccount(await aptos?.account() ?? null)
        })()
    }, [aptos])

    const createToken = async () => {
        // TODO バリデーション
        if (subnet <= 0 || subnet > 255) {
            toast.error("サブネットは1から255にしてください。")
            return
        }

        const payload = {
            "type": "script_function_payload",
            "function": `${moduler}::MachikadoNetwork::create_token`,
            "type_arguments": [],
            "arguments": [
                moduler,
                Buffer.from(name, "utf-8").toString("hex"),
                subnet,
                Buffer.from(publicKey, "utf-8").toString("hex"),
            ]
        }
        await aptos?.signAndSubmitTransaction(payload)
    }

    return <>
        <AptosHeader />
        <div className="container mx-auto my-2 md:my-12">
            <div className="my-6 mx-2 md:mx-0">
                <h2 className="text-2xl font-bold">PKTokenを作成する</h2>
                <Link href={"https://scrapbox.io/machikado-network/PKToken"}>
                    <a className={"text-indigo-500"}>PKTokenとは</a>
                </Link>
                <p className="text-sm text-slate-500">宛先、IPアドレス、公開鍵、名前をもとにPKTokenを作成してください。</p>
                <div className="my-2">
                    <p>宛先Address</p>
                    <input
                        value={publisher} onChange={event => setPublisher(event.target.value)}
                        className={"w-full md:w-1/2 border-indigo-500 border-2 p-2 h-12"}
                        placeholder={"0x8878e00d2cb67d758b4e57551c790f04b4eda469d17c81c915639c42a1f5bdae"}
                    />
                </div>
                <div className="my-2">
                    <p>名前はa-z0-9の中から、まだ使われていないものを入力してください。</p>
                    <input
                        value={name} onChange={event => setName(event.target.value)}
                        className={"w-full md:w-1/2 border-indigo-500 border-2 p-2 h-12"}
                        placeholder={"syamimomo"}
                    />
                </div>
                <div className="my-2">
                    <p>サブネットは1から255の中から、まだ使われていないものを入力してください。</p>
                    <input
                        type={"number"}
                        max={255}
                        min={1}
                        value={subnet} onChange={event => setSubnet(Number(event.target.value))}
                        className={"w-full md:w-1/2 border-indigo-500 border-2 p-2 h-12"}
                        placeholder={"2"}
                    />
                </div>
                <div className="my-2">
                    <p>PublicKeyは設定の時に表示されたPublic Keyを書いてください。</p>
                    <input
                        value={publicKey} onChange={event => setPublicKey(event.target.value)}
                        className={"w-full md:w-1/2 border-indigo-500 border-2 p-2 h-12"}
                        placeholder={"+gyEjlydmJvVJ4z99wHJVxiTNwiL9/zNA9FZb+26D3A"}
                    />
                </div>
                <button
                    className="px-4 py-2 bg-indigo-500 text-white rounded-md my-4"
                    onClick={createToken}
                >
                    作成
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


export default User
