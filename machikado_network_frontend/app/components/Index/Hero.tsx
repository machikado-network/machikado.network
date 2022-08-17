import { Container } from "./Container";
import {Button} from "~/components/Index/Button";

export function Hero() {
    return (
        <div className="relative pt-10 pb-20 sm:py-24">
            <div className="absolute inset-x-0 -top-48 -bottom-14 overflow-hidden bg-primary-50">
                <div className="absolute inset-x-0 top-0 h-40 bg-gradient-to-b from-white" />
                <div className="absolute inset-x-0 bottom-0 h-40 bg-gradient-to-t from-white" />
            </div>
            <Container className="relative">
                <div className="mx-auto max-w-2xl lg:max-w-4xl lg:px-12">
                    <h1 className="font-display text-5xl font-bold tracking-tighter text-primary-600 sm:text-7xl">
                        <span className="sr-only">まちカドネットワーク - </span>
                        50人くらいでやってる<br className={"hidden md:block"} />インターネットを作ろう。
                    </h1>
                    <div className="mt-6 space-y-6 font-display text-2xl tracking-tight text-primary-900">
                        <p>
                            インターネットから完全に分離した、まちかどだけでやってるネットワークを作るプロジェクトです。
                            ブロックチェーンの自動処理システムを利用し、認証のための公開鍵を登録・交換し互いに認証し合うことで
                            インターネットの片隅にインターネットから完全に分離・独立したLANを作っています。
                        </p>
                        <p>
                            まちカドネットワーク内では全てのユーザーが信頼されていることになっているため、インターネットには公開できないようなプロトコルを使ったサービスを公開できます。
                            例えば、「つぶやいたー」というE2E暗号化SNSを運用しています。
                        </p>
                    </div>
                    <dl className="mt-10 grid grid-cols-2 gap-y-6 gap-x-10 sm:mt-16 sm:gap-y-10 sm:gap-x-16 sm:text-center lg:auto-cols-auto lg:grid-flow-col lg:grid-cols-none lg:justify-start lg:text-left">
                        {[
                            ['Nodes', '5'],
                            ['People', '12'],
                            ['Location', 'World edge'],
                        ].map(([name, value]) => (
                            <div key={name}>
                                <dt className="font-mono text-sm text-primary-600">{name}</dt>
                                <dd className="mt-0.5 text-2xl font-semibold tracking-tight text-primary-900">
                                    {value}
                                </dd>
                            </div>
                        ))}
                    </dl>
                    <Button href="https://docs.machikado.network" className="mt-10 w-full sm:hidden">
                        詳しく知る
                    </Button>
                </div>
            </Container>
        </div>
    )
}