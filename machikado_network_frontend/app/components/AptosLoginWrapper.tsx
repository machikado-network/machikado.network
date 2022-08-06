import type {ReactNode} from "react";
import {useAptos} from "~/hooks/aptos";
import {useEffect} from "react";

interface WrapperProps {
    children: ReactNode
    noNav?: boolean
}

const AptosLoginWrapper = ({children, noNav}: WrapperProps) => {
    const aptos = useAptos()

    useEffect(() => {
        aptos.updateAccount().catch(console.error)
    }, [aptos])

    return <>
        {aptos.isConnected
            ? <>
                {noNav
                    ? null
                    : <div className="w-full py-2 flex bg-momo">
                        <div className={"p-2"}>
                            <p className={"hidden md:block my-auto font-medium"}>まちカドネットワークに接続しています。アドレス: {aptos.account?.address}</p>
                        </div>
                        <button
                            className="px-4 py-2 bg-gray-100 hover:bg-gray-300 duration-300 rounded-md my-auto ml-auto mr-4"
                            onClick={aptos.disconnect}
                        >
                            接続解除
                        </button>
                    </div>
                }
                {children}
            </>
            : <div className="w-full min-h-screen mx-auto text-center">
                <div className="my-3 md:my-12">
                    <h1 className="text-3xl md:text-5xl mb-12">Aptos ログイン</h1>
                    <p>この先の機能を利用する際はAptosでログインしてください。</p>
                    <button
                        className={"px-4 py-2 bg-indigo-500 text-white rounded-md"}
                        onClick={aptos.connect}
                    >
                        接続する
                    </button>
                </div>
            </div>
        }
    </>
}

export default AptosLoginWrapper
