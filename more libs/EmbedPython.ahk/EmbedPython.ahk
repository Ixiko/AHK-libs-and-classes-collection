#NoEnv
#Warn, All, MsgBox

global NULL := 0
global EMPTY_STRING := ""
global PY_EMPTY_STRING_INTERN := NULL
global PY_NONE := NULL
global LOAD_WITH_ALTERED_SEARCH_PATH := 0x8
global ERROR_MOD_NOT_FOUND := 0x7e
global HPYTHON_DLL := NULL
global PYTHON_DLL_PROCS := {}

; Python constants
global METH_VARARGS := 0x0001
global PYTHON_API_VERSION := 1013
global Py_TPFLAGS_LONG_SUBCLASS := 1 << 24
global Py_TPFLAGS_UNICODE_SUBCLASS := 1 << 28
global Py_TPFLAGS_BASE_EXC_SUBCLASS := 1 << 30

global CALLBACKS := {}
global BOUND_TRIGGERS := {}

global AHKError
global AHKMethods
global AHKModule
global AHKModule_name

OnExit("OnExitFunc")

Main()

; END AUTO-EXECUTE SECTION
return


#Include, <StdoutToVar_CreateProcess>
#Include, <PythonDll>
#Include, <Commands>


Main() {
    EnvGet, venv, VIRTUAL_ENV
    if (venv != "") {
        EnvSet, PYTHONHOME, %venv%
    }

    LoadPython()
    PackBuiltinModule()
    PyImport_AppendInittab(&AHKModule_name, Func("PyInit_ahk"))
    Py_Initialize()

    PY_NONE := Py_BuildValue("")

    argv0 := A_ScriptFullPath
    packArgs := ["Ptr", &argv0]
    for i, arg in A_Args {
        ; TODO: Try Object.GetAddress.
        argv%i% := arg
        packArgs.Push("Ptr")
        packArgs.Push(&argv%i%)
    }
    argc := A_Args.Length() + 1
    Pack(argv, packArgs*)
    PySys_SetArgv(argc, &argv)

    ; Import the higher-level ahk module to bootstrap the excepthook.
    ; TODO: Add test for excepthook.
    hiAhk := PyImport_ImportModule("ahk")
    if (hiAhk == NULL) {
        End("Cannot load ahk module.")
    }

    mainFunc := PyObject_GetAttrString(hiAhk, "_main")
    if (mainFunc == NULL) {
        End("Cannot find the main function.")
    }

    result := PyObject_CallObject(mainFunc, NULL)
    if (result == NULL) {
        PyErr_Print()
        return
    }
}

PackBuiltinModule() {
    PackBuiltinMethods()

    ; typedef struct PyModuleDef{
    ;   PyModuleDef_Base m_base;
    ;   const char* m_name;
    ;   const char* m_doc;
    ;   Py_ssize_t m_size;
    ;   PyMethodDef *m_methods;
    ;   struct PyModuleDef_Slot* m_slots;
    ;   traverseproc m_traverse;
    ;   inquiry m_clear;
    ;   freefunc m_free;
    ; } PyModuleDef;

    ; static PyModuleDef AHKModule = {
    ;     PyModuleDef_HEAD_INIT, "ahk", NULL, -1, AHKMethods,
    ;     NULL, NULL, NULL, NULL
    ; };

    global AHKModule_name := EncodeString("_ahk")
    global AHKModule
    Pack(AHKModule
        , "Int64", 1  ; ob_refcnt
        , "Ptr", NULL ; ob_type
        , "Ptr", NULL ; m_init
        , "Int64", 0  ; m_index
        , "Ptr", NULL ; m_copy
        , "Ptr", &AHKModule_name
        , "Ptr", NULL
        , "Int64", -1
        , "Ptr", &AHKMethods
        , "Ptr", NULL
        , "Ptr", NULL
        , "Ptr", NULL
        , "Ptr", NULL)
}

PackBuiltinMethods() {
    ; struct PyMethodDef {
    ;     const char  *ml_name;
    ;     PyCFunction ml_meth;
    ;     int         ml_flags;
    ;     const char  *ml_doc;
    ; };

    ; static PyMethodDef AHKMethods[] = {
    ;     {"call", AHKCall, METH_VARARGS,
    ;      "docstring blablabla"},
    ;     {NULL, NULL, 0, NULL} // sentinel
    ; };

    global AHKMethod_call_name := EncodeString("call")
    global AHKMethod_call_doc := EncodeString("Execute the given AutoHotkey function.")

    global AHKMethods
    Pack(AHKMethods
        ; -- call
        , "Ptr", &AHKMethod_call_name
        , "Ptr", RegisterCallback("AHKCall", "C")
        , "Int64", METH_VARARGS
        , "Ptr", &AHKMethod_call_doc

        ; -- sentinel
        , "Ptr", NULL
        , "Ptr", NULL
        , "Int64", 0
        , "Ptr", NULL)
}

Pack(ByRef var, args*) {
    static typeSizes := {Char: 1, UChar: 1
        , Short: 2, UShort: 2
        , Int: 4 , UInt: 4, Int64: 8
        , Float: 4, Double: 8
        , Ptr: A_PtrSize, UPtr: A_PtrSize}

    cap := 0
    typedValues := []
    typedValue := {}
    for index, param in args {
        if (Mod(index, 2) == 1) {
            ; Type string.
            size := typeSizes[param]
            if (not size) {
                End("Invalid type " param)
            }
            cap += size
            typedValue.Type := param
            typedValue.Size := size
        } else {
            typedValue.Value := param
            typedValues.Push(typedValue)
            typedValue := {}
        }
    }

    VarSetCapacity(var, cap, 0)
    offset := 0
    for index, tv in typedValues {
        NumPut(tv.Value, var, offset, tv.Type)
        offset += tv.Size
    }
}

; static PyObject*
PyInit_ahk() {
    module := PyModule_Create2(&AHKModule, PYTHON_API_VERSION)
    if (module == NULL) {
        return NULL
    }

    base := NULL
    dict := NULL
    AHKError := PyErr_NewException("ahk.Error", base, dict)
    Py_XIncRef(AHKError)

    result := PyModule_AddObject(module, "Error", AHKError)
    if (result < 0) {
        ; Adding failed.
        Py_XDecRef(AHKError)
        ; Py_CLEAR(AHKError);
        Py_DecRef(module)
        return NULL
    }

    return module
}

AHKCall(self, args) {
    ; AHK debugger doesn't see local variables in a C callback function. Call a
    ; regular AHK function.
    return _AHKCall(self, args)
}

_AHKCall(self, args) {
    pyFunc := PyTuple_GetItem(args, 0)
    if (pyFunc == NULL) {
        ; TODO: The error should be a TypeError.
        PyErr_SetString(AHKError, "_ahk.call() missing 1 required positional argument: 'func'")
        return NULL
    }

    func := PythonToAHK(pyFunc)

    funcRef := Func(func)
    if (not funcRef) {
        ; Try custom command wrapper.
        funcRef := Func("_" func)
    }
    if (not funcRef) {
        PyErr_SetString(AHKError, "unknown function " func)
        return NULL
    }

    ; Parse the arguments.
    ahkArgs := []
    i := 1
    size := PyTuple_Size(args)
    while (i < size) {
        arg := PyTuple_GetItem(args, i)
        if (arg == PY_NONE) {
            ; Ignore all arguments after None.
            break
        }
        try {
            ahkArg := PythonToAHK(arg)
        } catch e {
            PyErr_SetString(AHKError, e.Message)
            return NULL
        }
        if (PyErr_Occurred()) {
            ; Python couldn't convert the value, e.g. OverflowError.
            return NULL
        }
        ahkArgs.Push(ahkArg)
        i += 1
    }

    try {
        result := %funcRef%(ahkArgs*)
    } catch e {
        PyErr_SetString(AHKError, e.Message)
        return NULL
    }

    return AHKToPython(result)
}

AHKToPython(value) {
    if (IsObject(value)) {
        ; TODO: Convert AHK object to Python dict.
        End("Not implemented")
    } else if (IsFunc(value)) {
        ; TODO: Wrap AHK function to be called from Python?
        End("Not implemented")
    } else if (value == "") {
        if (PY_EMPTY_STRING_INTERN == NULL) {
            PY_EMPTY_STRING_INTERN := PyUnicode_InternFromString(&EMPTY_STRING)
        }
        return PY_EMPTY_STRING_INTERN
    } else if value is integer
        return PyLong_FromLongLong(value)
    else if value is float
        return PyFloat_FromDouble(value)
    else {
        ; The value is a string.
        return PyUnicode_FromString(value)
    }
}

PythonToAHK(pyObject) {
    ; TODO: Convert dicts to objects and lists to arrays.
    if (PyUnicode_Check(pyObject)) {
        return PyUnicode_AsWideCharString(pyObject)
    } else if (PyLong_Check(pyObject)) {
        return PyLong_AsLongLong(pyObject)
    } else if (PyFloat_Check(pyObject)) {
        return PyFloat_AsDouble(pyObject)
    } else if (PyCallable_Check(pyObject)) {
        Py_IncRef(pyObject)
        CALLBACKS[pyObject] := pyObject
        boundFunc := BOUND_TRIGGERS[pyObject]
        if (not boundFunc) {
            boundFunc := Func("Trigger").Bind(pyObject)
            BOUND_TRIGGERS[pyObject] := boundFunc
        }
        return boundFunc
    } else {
        pyRepr := PyObject_Repr(pyObject)
        if (PyUnicode_Check(pyRepr)) {
            repr := PyUnicode_AsWideCharString(pyRepr)
            throw Exception("cannot convert '" repr "' to an AHK value")
        } else {
            throw Exception("cannot convert Python object to an AHK value")
        }
    }
}

EncodeString(string) {
    ; Convert a UTF-16 string to a UTF-8 one.
    len := StrPut(string, "utf-8")
    VarSetCapacity(var, len)
    StrPut(string, &var, "utf-8")
    return var
}

Trigger(key, args*) {
    funcObjPtr := CALLBACKS[key]
    if (not funcObjPtr) {
        return
    }
    argsPtr := NULL
    result := PyObject_CallObject(funcObjPtr, argsPtr)
    ; TODO: Exit gracefully on sys.exit()
    if (result == "") {
        End("Call to '" key "' callback failed: " ErrorLevel)
    } else if (result == NULL) {
        PyErr_Print()
    }
}

End(message) {
    ; TODO: Consider replacing some of End invocations with raising Python
    ; exceptions.
    message .= "`nThe application will now exit."
    MsgBox, % message
    ExitApp
}

GuiContextMenu:
GuiDropFiles:
GuiEscape:
GuiSize:
OnClipboardChange:
    Trigger(A_ThisLabel)
    return

GuiClose:
    OnExitFunc("Close", 0, A_ThisLabel)
    return

OnExitFunc(reason, code, label:="OnExit") {
    if (Trigger(label) == 0) {
        return
    }
    if (Py_FinalizeEx() < 0) {
        code := 120
    }
    ExitApp, %code%
}

OnMessageClosure(wParam, lParam, msg, hwnd) {
    Trigger("OnMessage " . msg, wParam, lParam, msg, hwnd)
}
