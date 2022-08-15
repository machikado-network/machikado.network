import clsx from 'clsx'
import type {ReactNode} from "react";

interface ButtonProps {
    href?: string
    className?: string
    children: ReactNode
}

export function Button({ href, className, children }: ButtonProps) {
    className = clsx(
        'inline-flex justify-center rounded-2xl bg-primary-600 p-4 text-base font-semibold text-white hover:bg-primary-500 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-500 active:text-white/70',
        className
    )

    return href ? (
        <a href={href} className={className}>{children}</a>
    ) : (
        <button className={className}>{children}</button>
    )
}
