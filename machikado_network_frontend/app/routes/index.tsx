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
                  まちかどネットワーク
              </div>
          </div>
      </div>
  );
}
