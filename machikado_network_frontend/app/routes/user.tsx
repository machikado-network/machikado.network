import AptosLoginWrapper from "~/components/AptosLoginWrapper";

const User = () => {
    return <AptosLoginWrapper noNav>
        <nav className="bg-momo">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-16">
                    <div className="flex items-center">
                        <div className="flex-shrink-0">
                            <img className="h-14 w-14"
                                 src="/MachikadoNetwork.svg" alt="Logo" />
                        </div>
                        <div className="hidden md:block">
                            <div className="ml-10 flex items-baseline space-x-4">

                                <a href="#"
                                   className="bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium"
                                   aria-current="page">Dashboard</a>

                                <a href="#"
                                   className="hover:bg-gray-300 px-3 py-2 rounded-md text-sm font-medium">Team</a>

                                <a href="#"
                                   className="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Projects</a>

                                <a href="#"
                                   className="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Calendar</a>

                                <a href="#"
                                   className="text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Reports</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
        <div className="bg-gray-50 mx-auto p-3 container min-h-screen">
            <div className="my-3 md:my-6">
                <h1 className="font-bold text-2xl md:text-4xl">まちカドネットワーク ユーザーページ</h1>
            </div>
        </div>
    </AptosLoginWrapper>
}

export default User
