interface InputProps {
    value: string
    setValue: (value: string) => void,
}


const Input = ({value, setValue}: InputProps) => {
    return <input
        value={value} onChange={event => setValue(event.target.value)}
        className="p-2 border-2 border-indigo-500 rounded-md my-2 w-full"
    />
}

export default Input
