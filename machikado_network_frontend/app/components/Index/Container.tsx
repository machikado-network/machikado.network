import clsx from 'clsx'
import type {ReactNode} from "react";

export function Container({ className, children }: {className?: string, children?: ReactNode}) {
    return (
        <div
            className={clsx('mx-auto max-w-7xl px-4 sm:px-6 lg:px-8', className)}
        >
            {children}
        </div>
    )
}
