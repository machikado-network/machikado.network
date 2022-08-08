interface ButtonProps {
    title: string
    onClick: () => void
}

const Button = ({title, onClick}: ButtonProps) => {
    return <button
        onClick={onClick}
        className={"px-4 py-2 bg-indigo-500 hover:bg-indigo-700 rounded-md text-white mr-2"}
    >
        {title}
    </button>
}

export default Button
