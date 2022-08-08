import Button from "~/components/atom/button";
import {useState} from "react";
import {createSubnet} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {toast} from "react-toastify";

const CreateSubnet = () => {
    const [subnet, setSubnet] = useState(12)

    const create = async () => {
        try {
            await createSubnet(PUBLISHER, PUBLISHER, subnet)
        } catch (e) {
            console.error(e)
            toast.error("追加に失敗しました。")
            return
        }
        toast.success("追加しました！")
    }

    return <div className="w-full p-3 bg-gray-200 rounded-md my-4">
        <h2 className="font-bold text-lg">まちカドネットワーク Subnet追加</h2>
        <div className={"my-2 text-gray-600 text-sm"}>
            <p>自分のアカウントのNodeを配置できるサブネットを作成します。</p>
            <p>10.50.12.1にNodeを配置したい場合、12のサブネットを取得する必要があります。</p>
            <p>サブネットは一つまで作成できます。また、そのサブネット以外の場所にNodeを配置していた場合将来的に自動で排斥するシステムを構築します。</p>
            <p>
                <span>
                    <a className="text-blue-600 hover:text-blue-800 hover:cursor-pointer"
                       href={"/subnets"}>Tinc Subnet一覧</a>
                </span>
                で設定を確認できます。
            </p>
        </div>
        <div className="w-32 my-3">
            <label className="text-sm">追加するSubnet</label>
            <input type={"number"} max={255} min={1} className={"p-2 w-full border-2 border-indigo-500 rounded-md"}
                   value={subnet} onChange={event => setSubnet(parseInt(event.target.value))}/>
        </div>
        <Button title={"作成"} onClick={create} />
    </div>
}

export default CreateSubnet
