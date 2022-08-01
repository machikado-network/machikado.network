import type { NextPage } from 'next'
import Image from "next/image";


const Home: NextPage = () => {
  return (
    <div className={"container mx-auto"}>
      <div className={"my-32"}>
          <div className={"flex justify-center"}>
              <Image src={"/MachikadoNetwork.svg"} height={512} width={512} className={"mx-auto"} alt={"logo"} />
          </div>
          <div className="text-6xl text-center font-bold">
              まちカドネットワーク
          </div>
      </div>
    </div>
  )
}

export default Home
