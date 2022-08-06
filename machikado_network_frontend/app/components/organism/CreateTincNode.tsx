import Input from "~/components/atom/input";
import Button from "~/components/atom/button";
import {useState} from "react";
import TextArea from "~/components/atom/TextArea";
import {createTincNode} from "~/lib/MachikadoNetwork";
import {PUBLISHER} from "~/lib/preferences";
import {toast} from "react-toastify";

const PLACEHOLDER = `-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEArAlqLBAronTRJQPUqtnLo/yZqxwJZiel5XEEdZPZYWtpxZvsm7p9
ku82P0I3QtwCkNAAuf28c6QEYQ2PGChnTLrC+PsWNF8Jwgc6jTteA3N5rpOP7ISJ
NqTATh9g21Hxoz/P0nfBv+aqv1l/ghsSZA18zhzpOYtd7Oemc8TUhrafuYPUET+J
s47SqYZQZ77tKrOKXNn0nStIL7beJPbBWTLS/+57mzZTilDDS8DXFeyDZIfiQg0Z
Y3UesikxX0fn23VemFsTyJg/Rm8jkcdAy53Qpzh2re1ugmZRRWRyXzt0QvWkp4ld
jYjoxbU0fN6/2bP0nL/+VwGdI2elaSKITwIDAQAB
-----END RSA PUBLIC KEY-----`

const CreateTincNode = () => {
    const [name, setName] = useState("")
    const [publicKey, setPublicKey] = useState("")

    const createNode = async () => {
        try {
            await createTincNode(
                PUBLISHER,
                PUBLISHER,
                name,
                publicKey
                    .replace("-----BEGIN RSA PUBLIC KEY-----", "")
                    .replace("-----END RSA PUBLIC KEY-----", "")
                    .replaceAll("\n", "")
                    .replaceAll(" ", "")
                    .replaceAll("\t", "")
            )
        } catch (e) {
            toast.error(`${e}`)
            toast.error("作成に失敗しました.")
            return
        }
        toast.success("作成に成功しました！")
    }

    return <div className="w-full p-3 bg-gray-200 rounded-md my-4">
        <h2 className="font-bold text-lg">TincNode作成</h2>
        <div className={"my-2 text-gray-600 text-sm"}>
            <p>まちカドネットワークに接続するためのTinc Nodeを登録します。</p>
            <p>
                <span>
                    <a className="text-blue-600 hover:text-blue-800 hover:cursor-pointer" href={"/nodes"}>Tinc Node一覧</a>
                </span>
                に存在しない名前([0-9a-z])と、その名前を用いてセットアップを行った時に表示された公開鍵の本文を送信してください。
            </p>
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">Node名</label>
            <Input value={name} setValue={setName} />
        </div>
        <div className="w-full md:w-2/3 my-3">
            <label className="text-sm">公開鍵</label>
            <TextArea value={publicKey} setValue={setPublicKey} placeholder={PLACEHOLDER} />
        </div>
        <Button title={"Node作成"} onClick={createNode} />
    </div>
}

export default CreateTincNode
