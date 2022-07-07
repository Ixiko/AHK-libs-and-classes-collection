from ctypes import *
from _ctypes import COMError, CopyComPointer, _SimpleCData
from ctypes.wintypes import VARIANT_BOOL
from sys import exc_info


_IncRef = pythonapi.Py_IncRef
_DecRef = pythonapi.Py_DecRef
_IncRef.argtypes = [c_void_p]
_DecRef.argtypes = [c_void_p]
_IncRef.restype = _DecRef.restype = None
_CLSIDFromString = oledll.ole32.CLSIDFromString

class GUID(Structure):
    _fields_ = (("Data1", c_ulong), ("Data2", c_ushort), ("Data3", c_ushort), ("Data4", c_byte * 8))

    def __init__(self, name=None):
        if name is not None:
            _CLSIDFromString(name, byref(self))

    def __eq__(self, other):
        return isinstance(other, GUID) and bytes(self) == bytes(other)

    def __hash__(self):
        return hash(bytes(self))

IID_IUnknown  = GUID("{00000000-0000-0000-C000-000000000046}")
IID_IDispatch = GUID("{00020400-0000-0000-C000-000000000046}")
IID_PYOBJECT  = GUID("{0E814CA7-00C1-479B-B0EF-D2CEA22BFC34}")
riid_null     = byref(GUID())

PTR_SIZE = sizeof(c_void_p())
VT_EMPTY = 0
VT_NULL = 1
VT_I2 = 2
VT_I4 = 3
VT_R4 = 4
VT_R8 = 5
VT_BSTR = 8
VT_DISPATCH = 9
VT_ERROR = 10
VT_BOOL = 11
VT_VARIANT = 12
VT_UNKNOWN = 13
VT_I8 = 20
VT_HRESULT = 25
VT_SAFEARRAY = 27
VT_BYREF = 16384
VT_TYPEMASK = 4095

class BSTR(_SimpleCData):
    "The windows BSTR data type"
    _type_ = "X"
    _needsfree = False
    def __repr__(self):
        return "%s(%r)" % (self.__class__.__name__, self.value)

    def __ctypes_from_outparam__(self):
        self._needsfree = True
        return self.value

    def __del__(self):
        # Free the string if self owns the memory
        # or if instructed by __ctypes_from_outparam__.
        if self._b_base_ is None or self._needsfree:
            windll.oleaut32.SysFreeString(self)

    @classmethod
    def from_param(cls, value):
        """Convert into a foreign function call parameter."""
        if isinstance(value, cls):
            return value
        return cls(value)

class SAFEARRAYBOUND(Structure):
    _fields_ = (('cElements', c_uint), ('lLbound', c_long))

class SAFEARRAY(Structure):
    _fields_ = (('cDims', c_ushort),
                ('fFeatures', c_ushort),
                ('cbElements', c_uint),
                ('cLocks', c_uint),
                ('pvData', c_void_p),
                ('rgsabound', SAFEARRAYBOUND * 1))

class DECIMAL(Structure):
    _fields_ = (("wReserved", c_ushort), ("scale", c_ubyte), ("sign", c_ubyte), ("Hi32", c_ulong), ("Lo64", c_ulonglong))

class ComProxy(Structure):
    _dyna_names_ = []

    def __init__(self, obj):
        self.pvtbl = pointer(self._vtbl_)
        self.obj = obj
        self.pself = id(self)
        self.pdisp = cast(byref(self), c_void_p)

    def as_IDispatch(self):
        IDispatch.AddRef(c_void_p(self.pdisp))
        return IDispatch(self.pdisp)

    @classmethod
    def _make_vtbl(cls):
        def QueryInterface(this, riid, ppvObj):
            if riid[0] in (IID_IUnknown, IID_IDispatch, IID_PYOBJECT):
                CopyComPointer(c_void_p(this), ppvObj)
                return 0
            ppvObj[0] = None
            return -2147467262  # E_NOINTERFACE

        def AddRef(this):
            _IncRef(p := c_void_p.from_address(this + PTR_SIZE * 2))
            return c_ssize_t.from_address(p.value).value

        def Release(this):
            p = c_void_p.from_address(this + PTR_SIZE * 2)
            t = c_ssize_t.from_address(p.value).value
            _DecRef(p)
            return t - 1

        def GetTypeInfoCount(this, pctinfo):
            pctinfo[0] = 0
            return 0

        def GetTypeInfo(this, itinfo, lcid, ptinfo):
            ptinfo[0] = None
            return -2147467263

        def GetIDsOfNames(this, riid, rgszNames, cNames, lcid, rgDispId):
            obj = py_object.from_address(this + PTR_SIZE).value
            names = py_object.from_address(this + PTR_SIZE * 2).value._dyna_names_
            name = rgszNames[0]
            if hasattr(obj, name):
                try:
                    rgDispId[0] = names.index(name) + 1
                except:
                    names.append(name)
                    rgDispId[0] = len(names)
            else:
                return -2147352570
            i = 1
            while i < cNames:
                rgDispId[i] = -1
                i += 1
            return 0 if i == 1 else -2147352570

        def Invoke(this, dispIdMember, riid, lcid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr):
            obj = py_object.from_address(this + PTR_SIZE).value
            params = pDispParams[0]
            args = tuple(params.rgvarg[i].value for i in range(params.cArgs)[::-1])
            excep = pExcepInfo[0]
            try:
                if dispIdMember == 0:
                    if (wFlags & 1) and callable(obj):
                        pVarResult[0].value = obj(*args)
                    elif wFlags & 2:
                        pVarResult[0].value = obj[args[0] if len(args) == 1 else args]
                    elif wFlags & (4|8):
                        obj[args[0]] = args[1]
                    else: return -2147352573
                elif dispIdMember > 0 :
                    try:
                        name = py_object.from_address(this + PTR_SIZE * 2).value._dyna_names_[dispIdMember - 1]
                    except:
                        return -2147352573  # DISP_E_MEMBERNOTFOUND
                    if wFlags & (4 | 8):
                        setattr(obj, name, args[0])
                    else:
                        try:
                            obj = getattr(obj, name)
                        except:
                            return -2147352573
                        if callable(obj):
                            if wFlags & 1:
                                pVarResult[0].value = obj(*args)
                            else: return -2147352573
                        else:
                            if wFlags & 2:
                                if args:
                                    pVarResult[0].value = obj[args[0] if len(args) == 1 else args]
                                else: pVarResult[0].value = obj
                            else: return -2147352573
                elif dispIdMember == -4:
                    if hasattr(obj, '__iter__'):
                        class _Enum:
                            __slots__ = ('obj',)
                            def __init__(self, obj):
                                self.obj = iter(obj)
                            def __call__(self, *args):
                                try:
                                    v = self.obj.__next__()
                                    l = len(args)
                                    if l == 1:
                                        args[0][0] = v
                                    else:
                                        for i in range(l):
                                            args[i][0] = v[i]
                                    return 1
                                except:
                                    return 0
                        pVarResult[0].value = ComProxy(_Enum(obj)).as_IDispatch()
                    else:
                        excep.scode = -2147352573
                        return -2147352573
                else: return -2147352573
            except:
                typ, value, tb = exc_info()
                excep.scode = -2147352567
                if value.args:
                    excep.bstrDescription = f'{typ.__name__}: {value.args[0]}'
                excep.bstrSource = obj.__name__ if callable(obj) else str(obj)
                excep.bstrHelpFile = tb.tb_frame.f_code.co_filename
                excep.dwHelpContext = tb.tb_lineno
                return -2147352567
            return 0

        local = locals()
        methods = []
        for field in VTbl_IDispatch._fields_:
            name, functype = field
            methods.append(functype(local[name]))
        cls._vtbl_ = VTbl_IDispatch(*methods)

class VARIANT(Structure):
    class U_VARIANT1(Union):
        class __tagVARIANT(Structure):
            class U_VARIANT2(Union):
                _fields_ = (("VT_BOOL", VARIANT_BOOL),
                            ("VT_I1", c_byte),
                            ("VT_I2", c_short),
                            ("VT_I4", c_long),
                            ("VT_I8", c_longlong),
                            ("VT_INT", c_int),
                            ("VT_UI1", c_ubyte),
                            ("VT_UI2", c_ushort),
                            ("VT_UI4", c_ulong),
                            ("VT_UI8", c_ulonglong),
                            ("VT_UINT", c_uint),
                            ("VT_R4", c_float),
                            ("VT_R8", c_double),
                            ("c_wchar_p", c_wchar_p),
                            ("c_void_p", c_void_p),
                            ("pparray", POINTER(POINTER(SAFEARRAY))),
                            ("bstrVal", BSTR),
                            ("_tagBRECORD", c_void_p * 2))
            _fields_ = (("vt", c_ushort),
                        ("wReserved1", c_ushort),
                        ("wReserved2", c_ushort),
                        ("wReserved3", c_ushort),
                        ("_", U_VARIANT2))
            _anonymous_ = ["_"]
        _fields_ = (("__VARIANT_NAME_2", __tagVARIANT), ("decVal", DECIMAL))
        _anonymous_ = ["__VARIANT_NAME_2"]
    _fields_ = (("__VARIANT_NAME_1", U_VARIANT1),)
    _anonymous_ = ["__VARIANT_NAME_1"]

    def __init__(self, *args):
        if args:
            self.value = args[0]

    def __del__(self):
        if self._b_needsfree_:
            # XXX This does not work.  _b_needsfree_ is never
            # set because the buffer is internal to the object.
            _VariantClear(self)

    def __repr__(self):
        if self.vt & VT_BYREF:
            return "VARIANT(vt=0x%x, byref(%r))" % (self.vt, self[0])
        return "VARIANT(vt=0x%x, %r)" % (self.vt, self.value)

    @classmethod
    def from_param(cls, value):
        if isinstance(value, cls):
            return value
        return cls(value)

    def __setitem__(self, index, value):
        # This method allows to change the value of a
        # (VT_BYREF|VT_xxx) variant in place.
        if index != 0:
            raise IndexError(index)
        if not self.vt & VT_BYREF:
            raise TypeError("set_byref requires a VT_BYREF VARIANT instance")
        typ = _vartype_to_ctype[self.vt & ~VT_BYREF]
        cast(self.c_void_p, POINTER(typ))[0].value = value

    @property
    def value(self):
        vt = self.vt
        if vt == VT_BSTR:
            return self.bstrVal
        elif vt == VT_I4:
            return self.VT_I4
        elif vt == VT_R8:
            return self.VT_R8
        elif vt == VT_DISPATCH:
            val = self.c_void_p
            if not val:
                return None
            idisp = IDispatch(val)
            try:
                idisp.QueryInterface(IID_PYOBJECT)
                return py_object.from_address(val + PTR_SIZE).value
            except:
                idisp.AddRef()
                return Dispatch(idisp)
        elif vt == VT_I8:
            return self.VT_I8
        elif vt == VT_BOOL:
            return self.VT_BOOL
        elif vt == VT_UNKNOWN:
            return self.c_void_p
        elif vt in (VT_EMPTY, VT_NULL):
            return None
        elif self.vt & VT_BYREF:
            return self
        else:
            raise NotImplementedError("typecode %d = 0x%x)" % (vt, vt))

    @value.setter
    def value(self, value):
        _VariantClear(self)
        if isinstance(value, int):
            self.vt = VT_I8
            self.VT_I8 = value
        elif isinstance(value, float):
            self.vt = VT_R8
            self.VT_R8 = value
        elif isinstance(value, str):
            self.vt = VT_BSTR
            self.c_void_p = _SysAllocStringLen(value, len(value))
        elif isinstance(value, bool):
            self.vt = VT_BOOL
            self.VT_BOOL = value
        elif value is None:
            self.vt = VT_NULL
        elif isinstance(value, VARIANT):
            _VariantCopy(self, value)
        else:
            if isinstance(value, Dispatch):
                self.c_void_p = p = value._comobj_
            elif isinstance(value, IDispatch):
                self.c_void_p = p = value
            else:
                if not isinstance(value, ComProxy):
                    value = ComProxy(value)
                self.c_void_p = p = c_void_p(value.pdisp)
            self.vt = VT_DISPATCH
            IDispatch.AddRef(p)

    def __getitem__(self, index):
        if index != 0:
            raise IndexError(index)
        if self.vt == VT_BYREF|VT_VARIANT:
            v = VARIANT()
            # apparently VariantCopyInd doesn't work always with
            # VT_BYREF|VT_VARIANT, so do it manually.
            v = cast(self.c_void_p, POINTER(VARIANT))[0]
            return v.value
        else:
            v = VARIANT()
            _VariantCopyInd(v, self)
            return v.value

    def __ctypes_from_outparam__(self):
        # XXX Manual resource management, because of the VARIANT bug:
        result = self.value
        self.value = None
        return result


class DISPPARAMS(Structure):
    _fields_ = (('rgvarg', POINTER(VARIANT)),
                ('rgdispidNamedArgs', POINTER(c_long)),
                ('cArgs', c_uint),
                ('cNamedArgs', c_uint))
    def __del__(self):
        if self._b_needsfree_:
            for i in range(self.cArgs):
                self.rgvarg[i].value = None

class EXCEPINFO(Structure):
    _fields_ = (('wCode', c_ushort),
                ('wReserved', c_ushort),
                ('bstrSource', BSTR),
                ('bstrDescription', BSTR),
                ('bstrHelpFile', BSTR),
                ('dwHelpContext', c_ulong),
                ('pvReserved', c_void_p),
                ('pfnDeferredFillIn', c_void_p),
                ('scode', c_long))
    def __repr__(self):
        return "<EXCEPINFO %s>" % ((self.wCode, self.bstrSource, self.bstrDescription, self.bstrHelpFile, self.dwHelpContext, self.pfnDeferredFillIn, self.scode),)

_vartype_to_ctype = {
    VT_I4: c_long,
    VT_I8: c_longlong,
    VT_R4: c_float,
    VT_R8: c_double,
    VT_BOOL: VARIANT_BOOL,
    VT_BSTR: BSTR,
    VT_VARIANT: VARIANT,
    VT_BYREF|VT_VARIANT: POINTER(VARIANT),
    VT_BYREF|VT_BSTR: POINTER(BSTR)
}

_oleaut32 = oledll.oleaut32
_VariantChangeType = _oleaut32.VariantChangeType
_VariantChangeType.argtypes = (POINTER(VARIANT), POINTER(VARIANT), c_ushort, c_ushort)

_VariantClear = _oleaut32.VariantClear
_VariantClear.argtypes = (POINTER(VARIANT),)

_SysAllocStringLen = windll.oleaut32.SysAllocStringLen
_SysAllocStringLen.argtypes = (c_wchar_p, c_uint)
_SysAllocStringLen.restype = c_void_p

_VariantCopy = _oleaut32.VariantCopy
_VariantCopy.argtypes = (POINTER(VARIANT), POINTER(VARIANT))

_VariantCopyInd = _oleaut32.VariantCopyInd
_VariantCopyInd.argtypes = (POINTER(VARIANT), POINTER(VARIANT))

# some commonly used VARIANT instances
VARIANT.null = VARIANT(None)
VARIANT.empty = VARIANT()
VARIANT.missing = v = VARIANT()
v.vt = VT_ERROR
v.VT_I4 = 0x80020004
del v

instancemethod = PYFUNCTYPE(py_object, py_object)(('PyInstanceMethod_New', pythonapi))
class IDispatch(c_void_p):
    QueryInterface = instancemethod(WINFUNCTYPE(
        HRESULT, POINTER(GUID), POINTER(c_void_p))(
            0, 'QueryInterface', ((1,),(2,)), IID_IDispatch))
    AddRef = instancemethod(WINFUNCTYPE(c_ulong)(1, 'AddRef', iid=IID_IDispatch))
    Release = instancemethod(WINFUNCTYPE(c_ulong)(2, 'Release', iid=IID_IDispatch))
    __GetIDsOfNames = instancemethod(WINFUNCTYPE(
        HRESULT, POINTER(GUID), POINTER(c_wchar_p), c_uint, c_uint, POINTER(c_long))(
            5, 'GetIDsOfNames', iid=IID_IDispatch))
    __Invoke = instancemethod(WINFUNCTYPE(HRESULT, c_long, POINTER(GUID), c_uint,
        c_ushort, POINTER(DISPPARAMS), POINTER(VARIANT), POINTER(EXCEPINFO), POINTER(c_uint))(
            6, 'Invoke', iid=IID_IDispatch))

    def GetIDsOfNames(self, name):
        dispid = c_long()
        self.__GetIDsOfNames(riid_null, byref(c_wchar_p(name)), 1, 0x400, byref(dispid))
        return dispid.value

    def Invoke(self, dispid, invkind, *args):
        result = VARIANT()
        excepinfo = EXCEPINFO()
        argerr = c_uint()
        array = (VARIANT * len(args))()
        dp = DISPPARAMS()
        for i, a in enumerate(args[::-1]):
            array[i].value = a
        if args:
            dp.cArgs = len(args)
            dp.rgvarg = array

        if invkind in (4, 8):
            dp.cNamedArgs = 1
            dp.rgdispidNamedArgs = pointer(c_long(-3))
            rresult = None
        else:
            dp.cNamedArgs = 0
            rresult = byref(result)

        try:
            self.__Invoke(dispid, riid_null, 0x400, invkind, byref(dp), rresult, byref(excepinfo), byref(argerr))
        except Exception as err:
            (errno, text, details, hresult, n) = err.args
            if hresult == -2147352567:  # DISP_E_EXCEPTION
                details = (excepinfo.bstrDescription, excepinfo.bstrSource, excepinfo.bstrHelpFile, excepinfo.dwHelpContext, excepinfo.scode)
                raise COMError(hresult, text, details)
            elif hresult == -2147352572:    # DISP_E_PARAMNOTFOUND
                raise COMError(hresult, text, argerr.value)
            elif hresult == -2147352571:    # DISP_E_TYPEMISMATCH
                raise COMError(hresult, text,
                    ("TypeError: Parameter %s" % (argerr.value + 1), args))
            raise COMError(hresult, text, None)
        return result.value

    _free = False

    def __init__(self, *args):
        if l := len(args):
            val = args[0]
            self.value = val if isinstance(val, int) else val.value
            self._free = args[1] if l > 1 else True

    def __del__(self):
        if self._free and self.value:
            self.Release()

class VTbl_IDispatch(Structure):
    _fields_ = (
        ('QueryInterface', WINFUNCTYPE(HRESULT, c_void_p, POINTER(GUID), POINTER(c_void_p))),
        ('AddRef', WINFUNCTYPE(c_ulong, c_void_p)),
        ('Release', WINFUNCTYPE(c_ulong, c_void_p)),
        ('GetTypeInfoCount', WINFUNCTYPE(HRESULT, c_void_p, POINTER(c_uint))),
        ('GetTypeInfo', WINFUNCTYPE(HRESULT, c_void_p, c_uint, c_uint, POINTER(c_void_p))),
        ('GetIDsOfNames', WINFUNCTYPE(HRESULT, c_void_p, POINTER(GUID), POINTER(c_wchar_p), c_uint, c_uint, POINTER(c_long))),
        ('Invoke', WINFUNCTYPE(HRESULT, c_void_p, c_long, POINTER(GUID), c_uint, c_ushort, POINTER(DISPPARAMS), POINTER(VARIANT), POINTER(EXCEPINFO), POINTER(c_uint)))
    )

ComProxy._fields_ = (('pvtbl', POINTER(VTbl_IDispatch)), ('obj', py_object), ('pself', c_void_p), ('pdisp', c_void_p))
ComProxy._make_vtbl()

class Dispatch:
    __slots__ = ('_comobj_', '_this_', '_dispids_')
    _comobj_: IDispatch
    _dispids_: dict

    def __init__(self, comobj, dispids = None, bindthis = True):
        object.__setattr__(self, '_comobj_', comobj)
        object.__setattr__(self, '_this_', None if bindthis else False)
        object.__setattr__(self, '_dispids_', dispids or {})

    def __dir__(self):
        return self.__slots__

    def __call__(self, *args):
        if self._this_:
            v = self._comobj_.Invoke(0, 1, self._this_, *args)
        else: v = self._comobj_.Invoke(0, 1, *args)
        if isinstance(v, Dispatch):
            object.__setattr__(v, '_dispids_', self._dispids_)
        return v

    def __getitem__(self, index, dispid = 0):
        if isinstance(index, tuple):
            v = self._comobj_.Invoke(dispid, 2, *index)
        else: v = self._comobj_.Invoke(dispid, 2, index)
        if isinstance(v, Dispatch):
            object.__setattr__(v, '_dispids_', self._dispids_)
        return v

    def __setitem__(self, index, value, dispid = 0):
        if isinstance(index, tuple):
            self._comobj_.Invoke(dispid, 4, *index, value)
        else: self._comobj_.Invoke(dispid, 4, index, value)

    def __getattr__(self, attr):
        if not (dispid := self._dispids_.get(attr, None)):
            self._dispids_[attr] = dispid = self._comobj_.GetIDsOfNames(attr)
        try:
            v = self._comobj_.Invoke(dispid, 2)
            if isinstance(v, Dispatch):
                object.__setattr__(v, '_dispids_', self._dispids_)
                if v._this_ is None:
                    object.__setattr__(v, '_this_', self)
            return v
        except Exception as err:
            if err.hresult in [-2147352567]:
                class MethodCaller:
                    __slots__ = ('dispid', 'obj')
                    def __init__(self, obj, dispid):
                        self.obj = obj
                        self.dispid = dispid

                    def __call__(self, *args):
                        return self.obj._comobj_.Invoke(self.dispid, 1, *args)

                    def __getitem__(self, index):
                        return self.obj.__getitem__(index, self.dispid)

                    def __setitem__(self, index, value):
                        self.obj.__setitem__(index, value, self.dispid)

                return MethodCaller(self, dispid)
            else:
                raise

    def __setattr__(self, attr, value):
        if not (dispid := self._dispids_.get(attr, None)):
            self._dispids_[attr] = dispid = self._comobj_.GetIDsOfNames(attr)
        self._comobj_.Invoke(dispid, 4, value)

__all__ = ['ComProxy', 'Dispatch', 'VARIANT', 'GUID', 'IDispatch', 'instancemethod', 'IID_PYOBJECT', 'IID_IDispatch', 'PTR_SIZE']