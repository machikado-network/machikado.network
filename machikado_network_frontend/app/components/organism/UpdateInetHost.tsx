import Input from "~/components/atom/input";
import Button from "~/components/atom/button";
import {useState} from "react";
import {updateInetHost} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {toast} from "react-toastify";

const UpdateInetHost = () => {
    const [name, setName] = useState("")
    const [hostname, setHostname] = useState("")
    const [port, setPort] = useState(655)

    const update = async () => {
        try {
            await updateInetHost(PUBLISHER, PUBLISHER, name, hostname, port)
        } catch (e) {
            console.error(e)
            toast.error("設定更新に失敗しました。")
            return
        }
        toast.success("設定更新しました！")
    }

    return <div className="w-full p-3 bg-gray-200 rounded-md my-4">
        <h2 className="font-bold text-lg">TincNode Inet Host変更</h2>
        <div className={"my-2 text-gray-600 text-sm"}>
            <p>外部から接続するルートノードになるための設定を変更します。</p>
            <p>初期設定では設定されていません。</p>
            <p>
                <span>
                    <a className="text-blue-600 hover:text-blue-800 hover:cursor-pointer"
                       href={"/nodes"}>Tinc Node一覧</a>
                </span>
                で設定を確認できます。
            </p>
            <p>HostnameはIPアドレスやドメイン、PortはtincのPort(デフォルトは655)を設定してください。</p>
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">変更するNode名</label>
            <Input value={name} setValue={setName} />
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">Hostname</label>
            <Input value={hostname} setValue={setHostname}/>
        </div>
        <div className="w-32 my-3">
            <label className="text-sm">Port</label>
            <input type={"number"} max={65535} min={1} className={"p-2 w-full border-2 border-indigo-500 rounded-md"}
                   value={port} onChange={event => setPort(parseInt(event.target.value))}/>
        </div>
        <Button title={"更新"} onClick={update} />
    </div>
}

export default UpdateInetHost
