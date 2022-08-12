import {useState} from "react";
import Button from "~/components/atom/button";
import {createInvite} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {toast} from "react-toastify";

const CreateInvite = () => {
    const [address, setAddress] = useState("")

    const create = async () => {
        try {
            await createInvite(PUBLISHER, PUBLISHER, address)
        } catch (e) {
            toast.error("招待作成に失敗しました。")
            return
        }
        toast.success("招待を作成しました！")
    }

    return <div className="w-full p-3 bg-gray-200 rounded-md my-4">
        <h2 className="font-bold text-lg">まちカドネットワークに招待する</h2>
        <div className={"my-2 text-gray-600 text-sm"}>
            <p>まちカドネットワークにAptosアカウントを招待できます</p>
            <p>ユーザーは招待されない限りまちカドネットワークアカウントを作ることができません</p>
            <p>3人まで招待できます。</p>
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">招待するアドレス</label>
            <input type={"text"} className={"p-2 w-full border-2 border-indigo-500 rounded-md"}
                   value={address} onChange={event => setAddress(event.target.value)}/>
        </div>
        <Button title={"作成"} onClick={create} />
    </div>
}

export default CreateInvite
