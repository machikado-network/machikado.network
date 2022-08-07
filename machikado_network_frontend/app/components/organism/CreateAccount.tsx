import Button from "~/components/atom/button";
import {useState} from "react";
import Input from "~/components/atom/input";
import {createMachikadoAccount} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {toast} from "react-toastify";

const CreateAccount = () => {
    const [name, setName] = useState("")

    const createAccount = async () => {
        try {
            await createMachikadoAccount(PUBLISHER, PUBLISHER, name);
        } catch (e) {
            window.alert(e)
            toast.error("アカウント作成に失敗しました")
            return
        }
        toast.success("アカウント作成しました！")
    }
    return <div className="w-full p-3 bg-gray-200 rounded-md my-4">
        <h2 className="font-bold text-lg">まちカドネットワークアカウント作成</h2>
        <div className={"my-2 text-gray-600 text-sm"}>
            <p>まちカドネットワークに接続するためのTinc Nodeを登録するために、まちカドネットワークアカウントを作成する必要があります。</p>
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">アカウント名</label>
            <Input value={name} setValue={setName} />
        </div>
        <Button title={"アカウント作成"} onClick={createAccount} />
    </div>
}

export default CreateAccount