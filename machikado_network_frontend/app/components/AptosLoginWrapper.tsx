import type {ReactNode} from "react";
import {useAptos} from "~/hooks/aptos";

interface WrapperProps {
    children: ReactNode
}

const AptosLoginWrapper = ({children}: WrapperProps) => {
    const aptos = useAptos()

    return <>
        {aptos.isConnected
            ? <>
                <div className="w-full py-2 flex">
                    <button
                        className="px-4 py-2 bg-red-500 text-white rounded-md my-auto ml-auto mr-4"
                        onClick={aptos.disconnect}
                    >
                        接続解除
                    </button>
                </div>
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
