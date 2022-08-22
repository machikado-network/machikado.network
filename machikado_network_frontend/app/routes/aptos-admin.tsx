import AptosLoginWrapper from "~/components/AptosLoginWrapper";
import {useState} from "react";
import Button from "~/components/atom/button";
import {uploadModules} from "~/lib/aptos";
import {toast} from "react-toastify";
import {createAccountStore} from "~/lib/MachikadoNetwork";
import Input from "~/components/atom/input";
import {PUBLISHER} from "~/lib/preferences";

const AptosAdmin = () => {
    const [module, setModule] = useState("")
    const [publisher, setPublisher] = useState<string>(PUBLISHER)

    const upload = async () => {
        try {
            const response = await uploadModules([module.startsWith("0x") ? module : `0x${module}`])
        } catch (e) {
            toast.error("アップロード失敗😭")
            return
        }
        toast.success("アップロード完了!")
    }

    const createStore = async () => {
        try {
            const response = await createAccountStore(publisher)
        } catch (e) {
            console.log(e)
            toast.error("作成失敗😭")
            return
        }
        toast.success("作成完了!")
    }

    return <AptosLoginWrapper>
        <div className="container mx-auto">
            <div className="my-3 md:my-12">
                <div className="w-full md:w-2/3 bg-gray-100 rounded-md p-3 mb-4">
                    <h2 className="text-xl md:text-2xl font-bold">Aptos Move Module Uploader</h2>
                    <div className="my-3">
                        <p>Aptos Move Moduleを、あなたのアドレスにアップロードします。</p>
                        <textarea
                            value={module}
                            onChange={event => setModule(event.target.value)}
                            className={"p-2 my-2 w-full md:w-2/3 border-2 border-indigo-500 rounded-md"}
                        />
                        <div>
                            <Button title={"送信"} onClick={upload} />
                        </div>
                    </div>
                </div>
                <div className="w-full md:w-2/3 bg-gray-100 rounded-md p-3 mb-4">
                    <h2 className="text-xl md:text-2xl font-bold">Machikado Network AccountStore Setup</h2>
                    <div className="my-3">
                        <p>Account Storeを作成します。</p>
                        <div>
                            <p className="text-sm text-gray-600">関数の作成者</p>
                            <Input value={publisher} setValue={setPublisher} />
                        </div>
                        <div>
                            <Button title={"作成"} onClick={createStore} />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AptosLoginWrapper>
}

export default AptosAdmin
