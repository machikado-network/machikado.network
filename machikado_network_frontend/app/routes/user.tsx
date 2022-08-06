import AptosLoginWrapper from "~/components/AptosLoginWrapper";
import CreateAccount from "~/components/organism/CreateAccount";
import {useAptos} from "~/hooks/aptos";
import {PUBLISHER} from "~/lib/preferences";
import CreateTincNode from "~/components/organism/CreateTincNode";

const User = () => {
    const aptos = useAptos()

    return <AptosLoginWrapper noNav>
        <div className="mx-auto p-3 container min-h-screen">
            <div className="my-3 md:my-6">
                <div className="md:flex">
                    <h1 className="font-bold text-xl md:text-2xl">まちカドネットワーク ユーザーページ</h1>
                    <a
                        href={`https://explorer.devnet.aptos.dev/account/${PUBLISHER}`}
                        className={"px-4 py-2 bg-green-500 text-white rounded-md ml-auto mr-2"}
                        target={"_blank"}
                    >
                        まちカドネットワークAddressを見る
                    </a>
                    <a
                        href={`https://explorer.devnet.aptos.dev/account/${aptos.account?.address}`}
                        className={"px-4 py-2 bg-green-500 text-white rounded-md ml-2 mr-2"}
                        target={"_blank"}
                    >
                        自分のAddressを見る
                    </a>
                    <button
                        className={"px-4 py-2 bg-red-500 text-white rounded-md ml-2 mr-2"}
                        onClick={aptos.disconnect}
                        >
                        接続解除
                    </button>
                </div>
            </div>
            <div className="my-4">
                <CreateAccount />
                <CreateTincNode />
            </div>
        </div>
    </AptosLoginWrapper>
}

export default User
