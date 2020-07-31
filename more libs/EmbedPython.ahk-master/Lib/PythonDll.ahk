LoadPython() {
    ; Try default search-order. This approach works with virtualenv since
    ; activating one adds "VIRTUAL_ENV\Scripts" to the PATH.
    ; TODO: Add support for venv.
    python_dll := "python3.dll"
    HPYTHON_DLL := LoadLibraryEx(python_dll)
    if (HPYTHON_DLL != NULL) {
        return HPYTHON_DLL
    }
    if (A_LastError != ERROR_MOD_NOT_FOUND) {
        End("Cannot load Python DLL: " A_LastError)
    }

    ; Try py.exe.
    cmd := "py.exe -3 -c ""import os, sys; print(os.path.dirname(sys.executable), end='')"""
    pythonDir := StdoutToVar_CreateProcess(cmd)
    exists := FileExist(pythonDir)
    if (pythonDir != "" and FileExist(pythonDir) == "D") {
        python_dll := pythonDir "\python3.dll"
        HPYTHON_DLL := LoadLibraryEx(python_dll, LOAD_WITH_ALTERED_SEARCH_PATH)
        if (HPYTHON_DLL != NULL) {
            return HPYTHON_DLL
        }
    }
    if (A_LastError != ERROR_MOD_NOT_FOUND) {
        End("Cannot load Python DLL: " A_LastError)
    }

    End("Cannot find Python DLL.")
}

LoadLibraryEx(libFileName, flags:=0) {
    file := NULL
    return DllCall("LoadLibraryEx"
        , "Str", libFileName
        , "Ptr", file
        , "Int", flags
        , "Ptr")
}

PythonDllCall(function, args*) {
    return DllCall(CachedProcAddress(function), args*)
}

CachedProcAddress(symbol, returnType:="Ptr") {
    proc := PYTHON_DLL_PROCS[symbol]
    if (not proc) {
        proc := DllCall("GetProcAddress", "Ptr", HPYTHON_DLL, "AStr", symbol, returnType)
        if (not proc) {
            End("Cannot get the address of " symbol " symbol. Error " A_LastError)
        }
        PYTHON_DLL_PROCS[symbol] := proc
    }
    return proc
}

Py_Initialize() {
    PythonDllCall("Py_Initialize", "Cdecl")
}

Py_BuildValue(format) {
    return PythonDllCall("Py_BuildValue", "AStr", format, "Cdecl Ptr")
}

Py_IncRef(pyObject) {
    PythonDllCall("Py_IncRef", "Ptr", pyObject, "Cdecl")
}

Py_XIncRef(pyObject) {
    if (pyObject != NULL) {
        Py_IncRef(pyObject)
    }
}

Py_DecRef(pyObject) {
    PythonDllCall("Py_DecRef", "Ptr", pyObject, "Cdecl")
}

Py_XDecRef(pyObject) {
    if (pyObject != NULL) {
        Py_DecRef(pyObject)
    }
}

Py_TYPE(ob) {
    ; #define Py_TYPE(ob) (_PyObject_CAST(ob)->ob_type)
    ; #define _PyObject_CAST(op) ((PyObject*)(op))

    ; obRefcnt := NumGet(ob, "Int64")
    return NumGet(ob+8, "UPtr")
}

Py_FinalizeEx() {
    if (HPYTHON_DLL) {
        return PythonDllCall("Py_FinalizeEx", "Cdecl Int")
    }
}

PyFloat_AsDouble(pyfloat) {
    ; double PyFloat_AsDouble(PyObject *pyfloat)
    return PythonDllCall("PyFloat_AsDouble", "Ptr", pyfloat, "Cdecl Double")
}

PyFloat_FromDouble(value) {
    return PythonDllCall("PyFloat_FromDouble", "Double", value, "Cdecl Ptr")
}

PyFloat_Check(o) {
    PyFloat_Type := CachedProcAddress("PyFloat_Type")
    return PyObject_TypeCheck(o, PyFloat_Type)
}

PyImport_AppendInittab(name, initfunc) {
    return PythonDllCall("PyImport_AppendInittab"
        , "Ptr", name
        , "Ptr", RegisterCallback(initfunc, "C", 0)
        , "Cdecl Int")
}

PyImport_ImportModule(name) {
    ; PyObject* PyImport_ImportModule(const char *name)
    return PythonDllCall("PyImport_ImportModule", "AStr", name, "Cdecl Ptr")
}

PyModule_Create2(module, api_version) {
    return PythonDllCall("PyModule_Create2"
        , "Ptr", module
        , "Int", api_version
        , "Cdecl Ptr")
}

PyModule_AddObject(module, name, value) {
    return PythonDllCall("PyModule_AddObject"
        , "Ptr", module
        , "AStr", name
        , "Ptr", value
        , "Cdecl Int")
}

PyArg_ParseTuple(args, format, dest*) {
    dllArgs := ["Ptr", args, "AStr", format]
    for _, arg in dest {
        dllArgs.Push("Ptr")
        dllArgs.Push(arg)
    }
    dllArgs.Push("Cdecl Int")
    return PythonDllCall("PyArg_ParseTuple", dllArgs*)
}

PyCallable_Check(pyObject) {
    return PythonDllCall("PyCallable_Check", "Ptr", pyObject, "Cdecl")
}

PyErr_Clear() {
    PythonDllCall("PyErr_Clear", "Cdecl")
}

PyErr_ExceptionMatches(exc) {
    ; int PyErr_ExceptionMatches(PyObject *exc)
    return PythonDllCall("PyErr_ExceptionMatches", "Ptr", exc, "Cdecl Int")
}

PyErr_Fetch(ByRef ptype, ByRef pvalue, ByRef ptraceback) {
    ; PyErr_Fetch(PyObject **ptype, PyObject **pvalue, PyObject **ptraceback)
    PythonDllCall("PyErr_Fetch", "Ptr", &ptype, "Ptr", &pvalue, "Ptr", &ptraceback, "Cdecl")
    ptype := NumGet(ptype)
    pvalue := NumGet(pvalue)
    ptraceback := NumGet(ptraceback)
    x := 0
}

PyErr_NewException(name, base, dict) {
    return PythonDllCall("PyErr_NewException"
        , "AStr", name
        , "Ptr", base
        , "Ptr", dict
        , "Cdecl Ptr")
}

PyErr_Occurred() {
    ; PyObject* PyErr_Occurred()
    return PythonDllCall("PyErr_Occurred", "Cdecl Ptr")
}

PyErr_Print() {
    PythonDllCall("PyErr_Print", "Cdecl")
}

PyErr_Restore(ptype, pvalue, ptraceback) {
    PythonDllCall("PyErr_Restore", "Ptr", ptype, "Ptr", pvalue, "Ptr", ptraceback, "Cdecl")
}

PyErr_SetString(exception, message) {
    encoded := EncodeString(message)
    PythonDllCall("PyErr_SetString", "Ptr", exception, "Ptr", &encoded, "Cdecl")
}

PyExceptionInstance_Check(o) {
    return PyType_FastSubclass(Py_TYPE(o), Py_TPFLAGS_BASE_EXC_SUBCLASS)
}

PyLong_AsLongLong(obj) {
    ; long long PyLong_AsLongLong(PyObject *obj)
    return PythonDllCall("PyLong_AsLongLong", "Ptr", obj, "Cdecl Int64")
}

PyLong_Check(o) {
    return PyType_FastSubclass(Py_TYPE(o), Py_TPFLAGS_LONG_SUBCLASS)
}

PyLong_FromLongLong(value) {
    return PythonDllCall("PyLong_FromLongLong", "Int64", value, "Cdecl Ptr")
}

PyObject_GetAttrString(obj, attr) {
    return PythonDllCall("PyObject_GetAttrString", "Ptr", obj, "AStr", attr, "Cdecl Ptr")
}

PyObject_CallObject(pyObject, args) {
    return PythonDllCall("PyObject_CallObject", "Ptr", pyObject, "Ptr", args, "Cdecl Ptr")
}

PyObject_Repr(o) {
    ; PyObject* PyObject_Repr(PyObject *o)
    return PythonDllCall("PyObject_Repr", "Ptr", o, "Cdecl Ptr")
}

PyObject_TypeCheck(ob, tp) {
    obType := Py_TYPE(ob)
    return obType == tp or PyType_IsSubtype(obType, tp)
}

PyTuple_GetItem(p, pos) {
    ; PyObject* PyTuple_GetItem(PyObject *p, Py_ssize_t pos)
    return PythonDllCall("PyTuple_GetItem", "Ptr", p, "Int", pos, "Cdecl Ptr")
}

PySys_SetArgv(argc, argv) {
    PythonDllCall("PySys_SetArgv", "Int", argc, "Ptr", argv, "Cdecl")
}

PyTuple_Size(p) {
    ; Py_ssize_t PyTuple_Size(PyObject *p)
    return PythonDllCall("PyTuple_Size", "Ptr", p, "Cdecl Int")
}

PyType_FastSubclass(t, f) {
    ; #define PyType_FastSubclass(t,f)  PyType_HasFeature(t,f)
    ; #define PyType_HasFeature(t,f)  ((PyType_GetFlags(t) & (f)) != 0)

    flags := PythonDllCall("PyType_GetFlags", "Ptr", t, "Cdecl UInt")
    return flags & f != 0
}

PyType_IsSubtype(a, b) {
    return PythonDllCall("PyType_IsSubtype", "Ptr", a, "Ptr", b, "Cdecl Int")
}

PyUnicode_AsWideCharString(unicode) {
    ; wchar_t* PyUnicode_AsWideCharString(PyObject *unicode, Py_ssize_t *size)
    size := 0
    wchars := PythonDllCall("PyUnicode_AsWideCharString", "Ptr", unicode, "Ptr", &size, "Cdecl Ptr")
    if (wchars == NULL) {
        throw Exception("cannot convert Python unicode to AHK string.")
    }
    size := NumGet(size)
    return StrGet(wchars, size)
}

PyUnicode_Check(o) {
    return PyType_FastSubclass(Py_TYPE(o), Py_TPFLAGS_UNICODE_SUBCLASS)
}

PyUnicode_InternFromString(string) {
    return PythonDllCall("PyUnicode_InternFromString", "Ptr", string, "Cdecl Ptr")
}

PyUnicode_FromString(string) {
    encoded := EncodeString(string)
    return PythonDllCall("PyUnicode_FromString", "Ptr", &encoded, "Cdecl Ptr")
}
