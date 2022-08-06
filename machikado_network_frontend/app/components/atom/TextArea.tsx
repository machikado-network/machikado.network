interface TextAreaProps {
    value: string
    setValue: (value: string) => void,
    placeholder?: string
}


const TextArea = ({value, setValue, placeholder}: TextAreaProps) => {
    return <textarea
        style={{fontFamily: "Menlo"}}
        value={value} onChange={event => setValue(event.target.value)}
        className="p-2 border-2 border-indigo-500 rounded-md my-2 w-full h-32 md:h-64"
        placeholder={placeholder}
    />
}

export default TextArea
