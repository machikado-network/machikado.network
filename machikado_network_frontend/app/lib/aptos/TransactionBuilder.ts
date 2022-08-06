export type Argument = string | number

export interface ScriptFunctionPayload {
    type: "script_function_payload",
    function: string,
    type_arguments: string[],
    arguments: Argument[]
}

export interface ModuleBundlePayload {
    type: "module_bundle_payload",
    modules: {
        bytecode: string
    }[]
}

export type AptosPayload = ScriptFunctionPayload | ModuleBundlePayload
