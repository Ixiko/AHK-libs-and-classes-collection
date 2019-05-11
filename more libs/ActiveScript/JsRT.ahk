/*
 *  JsRT for AutoHotkey v1.1
 *
 *  Utilizes the JavaScript engine that comes with IE11.
 *
 *  License: Use, modify and redistribute without limitation, but at your own risk.
 */
class JsRT extends ActiveScript._base
{
    __New()
    {
        throw Exception("This class is abstract. Use JsRT.IE or JSRT.Edge instead.", -1)
    }
    
    class IE extends JsRT
    {
        __New()
        {
            if !this._hmod := DllCall("LoadLibrary", "str", "jscript9", "ptr")
                throw Exception("Failed to load jscript9.dll", -1)
            if DllCall("jscript9\JsCreateRuntime", "int", 0, "int", -1
                , "ptr", 0, "ptr*", runtime) != 0
                throw Exception("Failed to initialize JsRT", -1)
            DllCall("jscript9\JsCreateContext", "ptr", runtime, "ptr", 0, "ptr*", context)
            this._Initialize("jscript9", runtime, context)
        }
    }
    
    class Edge extends JsRT
    {
        __New()
        {
            if !this._hmod := DllCall("LoadLibrary", "str", "chakra", "ptr")
                throw Exception("Failed to load chakra.dll", -1)
            if DllCall("chakra\JsCreateRuntime", "int", 0
                , "ptr", 0, "ptr*", runtime) != 0
                throw Exception("Failed to initialize JsRT", -1)
            DllCall("chakra\JsCreateContext", "ptr", runtime, "ptr*", context)
            this._Initialize("chakra", runtime, context)
        }
        
        ProjectWinRTNamespace(namespace)
        {
            return DllCall("chakra\JsProjectWinRTNamespace", "wstr", namespace)
        }
    }
    
    _Initialize(dll, runtime, context)
    {
        this._dll := dll
        this._runtime := runtime
        this._context := context
        DllCall(dll "\JsSetCurrentContext", "ptr", context)
        DllCall(dll "\JsGetGlobalObject", "ptr*", globalObject)
        this._dsp := this._JsToVt(globalObject)
    }
    
    __Delete()
    {
        this._dsp := ""
        if dll := this._dll
        {
            DllCall(dll "\JsSetCurrentContext", "ptr", 0)
            DllCall(dll "\JsDisposeRuntime", "ptr", this._runtime)
        }
        DllCall("FreeLibrary", "ptr", this._hmod)
    }
    
    _JsToVt(valref)
    {
        VarSetCapacity(variant, 24, 0)
        DllCall(this._dll "\JsValueToVariant", "ptr", valref, "ptr", &variant)
        ref := ComObject(0x400C, &variant), val := ref[], ref[] := 0
        return val
    }
    
    _ToJs(val)
    {
        VarSetCapacity(variant, 24, 0)
        ref := ComObject(0x400C, &variant) ; VT_BYREF|VT_VARIANT
        ref[] := val
        DllCall(this._dll "\JsVariantToValue", "ptr", &variant, "ptr*", valref)
        ref[] := 0
        return valref
    }
    
    _JsEval(code)
    {
        e := DllCall(this._dll "\JsRunScript", "wstr", code, "uptr", 0, "wstr", "source.js"
            , "ptr*", result)
        if e
        {
            if DllCall(this._dll "\JsGetAndClearException", "ptr*", excp) = 0
                throw this._JsToVt(excp)
            throw Exception("JsRT error", -2, format("0x{:X}", e))
        }
        return result
    }
    
    Exec(code)
    {
        this._JsEval(code)
    }
    
    Eval(code)
    {
        return this._JsToVt(this._JsEval(code))
    }
    
    AddObject(name, obj, addMembers := false)
    {
        if addMembers
            throw Exception("AddMembers=true is not supported", -1)
        this._dsp[name] := obj
    }
}