import {useEffect, useState} from "react";
import {useAptos} from "../hooks/aptos";

const AptosHeader = () => {
    const [isLogin, setIsLogin] = useState(false)
    const [aptos, _] = useAptos()

    const setLoginState = async () => {
        setIsLogin(await aptos?.isConnected() ?? false)
    }

    useEffect(() => {
        setLoginState().catch(console.error)
    }, [])

    const login = async () => {
        await aptos?.connect()
        await setLoginState()
    }

    const logout = async () => {
        await aptos?.disconnect()
        await setLoginState()
    }

    return <div className="w-full h-14 bg-gray-300 p-2 flex">
        {typeof aptos === "undefined"
            ? <p className={"text-2xl font-bold"}>公式のAptos Walletをインストールしてください。</p>
            : <div className={"right-0 mr-4 ml-auto"}>
                {isLogin
                    ? <button
                        className="px-4 py-2 bg-red-500 text-white rounded-md"
                        onClick={logout}
                    >
                        ログアウト
                    </button>
                    : <button
                        className="px-4 py-2 bg-cyan-500 text-white rounded-md"
                        onClick={login}
                    >
                        ログイン
                    </button>
                }
            </div>
        }
    </div>
}

export default AptosHeader
