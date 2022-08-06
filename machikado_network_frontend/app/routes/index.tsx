export default function Index() {
  return (
      <div className={"container mx-auto"}>
          <div className={"sm:my-4 md:my-16"}>
              <div className={"flex justify-center"}>
                  <img
                      src={"/MachikadoNetwork.svg"}
                      width={512}
                      height={512}
                      alt={"logo image"}
                  />
              </div>
              <div className="sm:text-3xl md:text-6xl text-center font-bold">
                  まちカドネットワーク
              </div>
              <div className={"w-full flex my-4"}>
                  <a href={"/user"} className="py-2 px-4 bg-indigo-500 rounded-md text-white mx-auto">
                      ユーザーページ
                  </a>
              </div>
          </div>
      </div>
  );
}
