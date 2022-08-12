path = "build/MachikadoNetwork/bytecode_modules/"

modules = [
    "Invite.mv",
    "MachikadoAccount.mv",
    "MachikadoNetwork.mv"
]

for module in modules:
    with open(path + module, "rb") as f:
        print("show " + module)
        print()
        print(f.read().hex())
        print()
