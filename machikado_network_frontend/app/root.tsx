import type {MetaFunction} from "@remix-run/cloudflare";
import {
    Links,
    LiveReload,
    Meta,
    Outlet,
    Scripts,
    ScrollRestoration,
} from "@remix-run/react";

import styles from "./styles/app.css"
import toast from 'react-toastify/dist/ReactToastify.css';
import {ToastContainer} from "react-toastify";
import {useReducer} from "react";
import {AptosContext, aptosReducer} from "~/lib/contexts/AptosContext";

export function links() {
    return [
        {rel: "stylesheet", href: styles},
      {rel: "stylesheet", href: toast},
    ]
}

export const meta: MetaFunction = () => ({
    charset: "utf-8",
    title: "Machikado Network Website",
    viewport: "width=device-width,initial-scale=1",
});

export default function App() {
    const [state, dispatch] = useReducer(aptosReducer, {
        isConnected: false,
        account: null,
    })
    return (
        <html lang="en">
        <head>
            <Meta/>
            <Links/>
        </head>
        <body>
        <AptosContext.Provider value={{state, dispatch}}>
            <Outlet/>
            <ScrollRestoration/>
            <Scripts/>
            <LiveReload/>
            <ToastContainer/>
        </AptosContext.Provider>
        </body>
        </html>
    );
}
