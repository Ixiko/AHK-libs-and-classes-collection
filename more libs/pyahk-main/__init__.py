from .comproxy import *
from ctypes import CDLL, POINTER, WINFUNCTYPE, _CFuncPtr, _FUNCFLAG_CDECL, Structure, Union, addressof, byref, c_bool, c_double, c_int, c_ubyte
from ctypes import c_int64, c_size_t, c_uint, c_void_p, c_wchar_p, cast, create_unicode_buffer, pointer, py_object, pythonapi
from threading import get_native_id, local

__all__ = ['AhkApi', 'IAhkObject', 'WINFUNCTYPE', 'Var', 'InputVar']

class Var(Structure):
    _fields_ = (('Contents', c_int64),
                ('CharContents', c_wchar_p),
                ('ByteLength', c_size_t),
                ('ByteCapacity', c_size_t),
                ('HowAllocated', c_ubyte),
                ('Attrib', c_ubyte),
                ('Scope', c_ubyte),
                ('Type', c_ubyte),
                ('Name', c_wchar_p))
    _out = True
    def __init__(self, val = 0):
        self.Name = ''
        self.Type = 1
        self.Attrib = 0x11
        if val:
            _local.api.VarAssign(byref(self), byref(ExprTokenType(val)))

    def _output(self):
        if out := self._out:
            _local.api.VarToToken(byref(self), byref(tk := ExprTokenType()))
            self.value = tk.value
        _local.api.VarFree(byref(self))
        return out

def InputVar(val):
    val = Var(val)
    val._out = False
    return val

class ExprTokenType(Structure):
    class _V(Union):
        class _(Structure):
            class _u1(Union):
                _fields_ = (('object', c_void_p), ('marker', c_wchar_p))
            class _u2(Union):
                _fields_ = (('marker_length', c_size_t), ('var_usage', c_int))
            _fields_ = (('_u1', _u1), ('_u2', _u2))
            _anonymous_ = ('_u1', '_u2')
        _fields_ = (('value_int64', c_int64),
                    ('value_double', c_double),
                    ('_', _))
        _anonymous_ = ('_',)
    _fields_ = (('v', _V), ('symbol', c_int))
    _anonymous_ = ('v',)

    def __init__(self, *val):
        if val:
            self.value = val[0]

    @property
    def value(self):
        symbol = self.symbol
        if symbol == 1:
            return self.value_int64
        elif symbol == 2:
            return self.value_double
        elif symbol == 0:
            return self.marker
        elif symbol == 5:
            obj = IAhkObject(self.object)
            obj.AddRef()
            if obj.Type() == 'ComObject':
                pdisp = IDispatch.from_address(self.object + PTR_SIZE * 2)
                pdisp._free = True
                try:
                    pdisp.QueryInterface(IID_PYOBJECT)
                    return py_object.from_address(pdisp.value + PTR_SIZE).value
                except:
                    try:
                        pdisp.QueryInterface(IID_IAhkObject)
                        pdisp._free = False
                        return IAhkObject(pdisp)
                    except:
                        pdisp.AddRef()
                        return Dispatch(pdisp)
            return obj

    @value.setter
    def value(self, val):
        if isinstance(val, str):
            self.marker = val
            self.marker_length = len(val)
            self.symbol = 0
        else:
            self.marker_length = 0
            if isinstance(val, int):
                self.value_int64 = val
                if self.value_int64 == val:
                    self.symbol = 1
                else: self.value = str(val)
            elif isinstance(val, float):
                self.value_double = val
                self.symbol = 2
            elif val == None:
                self.symbol = 3
            elif isinstance(val, Var):
                self.object = addressof(val)
                self.symbol = 4
                self.marker_length = 4
            else:
                self.object = self._objcache = AhkApi._wrap_pyobj(val)
                self.symbol = 5

BUF256 = create_unicode_buffer(256)
class ResultToken(Structure):
    _fields_ = (('_', ExprTokenType), ('buf', c_void_p), ('mem_to_free', c_void_p), ('func', c_void_p), ('result', c_int))
    _anonymous_ = ('_',)
    value = ExprTokenType.value

    def __init__(self):
        self.value = ''
        self.result = 1
        self.buf = addressof(BUF256)

    def __del__(self):
        if self.symbol == 5:
            IDispatch(self.object)
            self.symbol = 1
        elif self.mem_to_free:
            pythonapi.PyMem_RawFree(c_void_p(self.mem_to_free))
            self.mem_to_free = None

IID_IAhkObject = GUID("{619f7e25-6d89-4eb4-b2fb-18e7c73c0ea6}")
class IAhkObject(IDispatch):
    class Property:
        __slots__ = ('obj', 'prop')
        def __init__(self, obj, prop):
            self.obj = obj
            self.prop = prop

        def __call__(self, *args):
            return self.obj.Call(self.prop, *args)

        def __getitem__(self, index):
            if isinstance(index, tuple):
                return self.obj.Invoke(0, self.props, *index)
            return self.obj.Invoke(0, self.prop, index)

        def __setitem__(self, index, value):
            if isinstance(index, tuple):
                return self.obj.Invoke(1, self.prop, value, *index)
            return self.obj.Invoke(1, self.prop, value, index)

    __Invoke = instancemethod(WINFUNCTYPE(c_int, POINTER(ResultToken), c_int, c_wchar_p, POINTER(ExprTokenType), POINTER(POINTER(ExprTokenType)), c_int)(7, 'Invoke', iid=IID_IAhkObject))
    Type = instancemethod(WINFUNCTYPE(c_wchar_p)(8, 'Type', iid=IID_IAhkObject))
    Property = instancemethod(Property)

    def Invoke(self, flags, name, *args, to_ptr=False):
        global _ahk_throwerr
        _ahk_throwerr = True
        result = ResultToken()
        this = ExprTokenType(self)
        l, params = len(args), None
        if l:
            params = (POINTER(ExprTokenType) * l)()
            for i, arg in enumerate(args):
                params[i] = pointer(ExprTokenType(arg))

        rt = self.__Invoke(byref(result), flags, name, byref(this), params, l)
        if rt == 0 or rt == 8:
            if _ahk_throwerr != True:
                _ahk_throwerr = Exception(*_ahk_throwerr)
                raise _ahk_throwerr
        _ahk_throwerr = None
        if to_ptr and result.symbol == 5:
            result.symbol = 1
        return result.value

    def __init__(self, *args):
        if l := len(args):
            val = args[0]
            object.__setattr__(self, 'value', val if isinstance(val, int) else val.value)
            free = args[1] if l > 1 else True
            if free:
                object.__setattr__(self, '_free', _local.threadid)

    def __call__(self, *args):              # call
        return self.Call(None, *args)

    def __getitem__(self, index):           # __item.get
        if isinstance(index, tuple):
            return self.Invoke(0, None, *index)
        return self.Invoke(0, None, index)

    def __setitem__(self, index, value):    # __item.set
        if isinstance(index, tuple):
            return self.Invoke(1, None, value, *index)
        return self.Invoke(1, None, value, index)

    def __getattr__(self, prop):
        flags = self.Invoke(2, 'HasProp', prop)
        if not flags:
            raise AttributeError
        elif flags == 1:
            return self.Invoke(0, prop)
        else:
            return self.Property(prop)

    def __setattr__(self, prop, value):
        self.Invoke(1, prop, value)

    def __iter__(self):
        if not self.Invoke(2, 'HasProp', '__Enum'):
            raise NotImplementedError
        r = self.Invoke(2, '__Enum', 1)
        object.__setattr__(r, '_free', 0)
        class _Enum(IAhkObject):
            def __next__(self):
                r, v = self.Call(None, Var())
                if r:
                    return v
                else: raise StopIteration
        return _Enum(r.value)

    def Get(self, prop, *args):             # prop.get
        return self.Invoke(0, prop, *args)

    def Set(self, prop, value, *args):      # prop.set
        return self.Invoke(1, prop, value, *args)

    def Call(self, prop, *args):            # prop.call
        ret = self.Invoke(2, prop, *args)
        outs = tuple(arg.value for arg in args if isinstance(arg, Var) and arg._output())
        if outs:
            return (ret,) + outs
        return ret

_local = local()
_ahkdll = None
_ahk_throwerr = None
def _ahk_onerr(thr, mode):
    global _ahk_throwerr
    if _ahk_throwerr != True:
        return 0
    if isinstance(thr, IAhkObject):
        _ahk_throwerr = (thr.Message, thr.What, thr.Extra)
    else:
        _ahk_throwerr = (thr,)
    return 1

class AhkApi(c_void_p):
    @classmethod
    def initialize(cls, hmod = None):
        global _ahkdll
        if _ahkdll is None:
            dllpath = __file__ + '/../AutoHotkey.dll'
            if isinstance(hmod, str):
                dllpath, hmod = hmod, None
            _ahkdll = CDLL(dllpath, handle=hmod)
            _ahkdll.ahkGetApi.restype = AhkApi
            _ahkdll.addScript.restype = c_void_p
            _ahkdll.addScript.argtypes = (c_wchar_p, c_int, c_uint)
            _ahkdll.ahkExec.argtypes = (c_wchar_p, c_uint)
        _local.api = _ahkdll.ahkGetApi(None)
        _local.threadid = get_native_id()
        if hmod is None:
            cls['OnError'](_ahk_onerr)

    VarAssign = instancemethod(WINFUNCTYPE(c_bool, POINTER(Var), POINTER(ExprTokenType))(8, 'VarAssign'))
    VarToToken = instancemethod(WINFUNCTYPE(None, POINTER(Var), POINTER(ExprTokenType))(9, 'VarToToken'))
    VarFree = instancemethod(WINFUNCTYPE(None, POINTER(Var))(10, 'VarFree'))

    @staticmethod
    @WINFUNCTYPE(c_int, c_wchar_p, c_int)
    def __onexit(reason, code):
        from gc import get_objects
        threadid = get_native_id()
        for obj in filter(lambda obj: isinstance(obj, IAhkObject) and obj._free == threadid, get_objects()):
            obj.Release()
            object.__setattr__(obj, '_free', 0)
        return 0
    __PumpMessages = instancemethod(WINFUNCTYPE(None)(45, 'PumpMessages'))
    @classmethod
    def pumpMessages(cls):
        if _ := cls['OnExit']:
            _(cls.__onexit)
        _local.api.__PumpMessages()

    @classmethod
    def addScript(cls, script) -> int:
        return _ahkdll.addScript(script, 1, _local.threadid)

    @classmethod
    def execLine(cls, pline) -> int:
        return _ahkdll.ahkExecuteLine(c_void_p.from_param(pline), 1, 1, _local.threadid)

    @classmethod
    def exec(cls, script) -> int:
        return _ahkdll.ahkExec(script, _local.threadid)

    __GetVar = instancemethod(WINFUNCTYPE(c_bool, c_wchar_p, POINTER(ExprTokenType))(19, 'GetVar'))
    def __class_getitem__(cls, varname):
        token = ExprTokenType()
        if _local.api.__GetVar(varname, byref(token)):
            return token.value
    
    __SetVar = instancemethod(WINFUNCTYPE(c_bool, c_wchar_p, POINTER(ExprTokenType))(20, 'SetVar'))
    @classmethod
    def setVar(cls, varname, value):
        _local.api.__SetVar(varname, byref(ExprTokenType(value)))

    @classmethod
    def _wrap_cfunc(cls, cfunc):
        def gettp(tp):
            if tp is None:
                raise TypeError(tp)
            if tp == IAhkObject:
                return 'o'
            tp = tp._type_
            r, t = '', tp.lower()
            y = {'h': 'h', 'l': 'i', 'i': 'i', 'f': 'f', 'd': 'd', 'q': 'i6', 'b': 'c', 'c': 'c', 'z': 'a', 'p': 't', '?': 'c', 'u': 'h'}
            if tp == 'Z':
                r = 'w'
            elif t == 'q':
                r = 'i6'
            elif (r := y.get(t, None)) is None:
                raise TypeError(tp)
            elif tp.isupper():
                r = 'u' + r
            return r

        df = ''
        if cfunc._restype_:
            df = df + gettp(cfunc._restype_)
        df += '='
        if cfunc._flags_ & _FUNCFLAG_CDECL:
            df += '='
        if cfunc._argtypes_:
            for it in cfunc._argtypes_:
                df += gettp(it)
        return cls['DynaCall'](cast(cfunc, c_void_p).value, df)

    @classmethod
    def _wrap_pyobj(cls, obj):
        if isinstance(obj, IAhkObject):
            return obj
        if isinstance(obj, Dispatch):
            obj = obj._comobj_
        elif not isinstance(obj, IDispatch):
            if isinstance(obj, _CFuncPtr):
                return cls._wrap_cfunc(obj)
            obj = ComProxy(obj).as_IDispatch()
        obj.AddRef()
        return IAhkObject(cls['ComObjFromPtr'].Invoke(2, None, obj.value, to_ptr=True))

    @classmethod
    def finalize(cls):
        if exit := cls['ExitApp']:
            exit(); exit = None
            cls.pumpMessages()

    @classmethod
    def loadAllFuncs(cls):
        '''
        docs:
            https://lexikos.github.io/v2/docs/AutoHotkey.htm
            https://hotkeyit.github.io/v2/docs/AutoHotkey.htm
        '''
        ahkfuncs = {}
        allnames = ['Abs','ACos','Alias','ASin','ATan','BlockInput','CallbackCreate','CallbackFree','CaretGetPos','Cast','Ceil','Chr','Click','ClipWait','ComCall','ComObjActive','ComObjConnect','ComObjDll','ComObjFlags','ComObjFromPtr','ComObjGet','ComObjQuery','ComObjType','ComObjValue','ControlAddItem','ControlChooseIndex','ControlChooseString','ControlClick','ControlDeleteItem','ControlFindItem','ControlFocus','ControlGetChecked','ControlGetChoice','ControlGetClassNN','ControlGetEnabled','ControlGetExStyle','ControlGetFocus','ControlGetHwnd','ControlGetIndex','ControlGetItems','ControlGetPos','ControlGetStyle','ControlGetText','ControlGetVisible','ControlHide','ControlHideDropDown','ControlMove','ControlSend','ControlSendText','ControlSetChecked','ControlSetEnabled','ControlSetExStyle','ControlSetStyle','ControlSetText','ControlShow','ControlShowDropDown','CoordMode','Cos','Critical','CryptAES','DateAdd','DateDiff','DetectHiddenText','DetectHiddenWindows','DirCopy','DirCreate','DirDelete','DirExist','DirMove','DirSelect','DllCall','Download','DriveEject','DriveGetCapacity','DriveGetFileSystem','DriveGetLabel','DriveGetList','DriveGetSerial','DriveGetSpaceFree','DriveGetStatus','DriveGetStatusCD','DriveGetType','DriveLock','DriveRetract','DriveSetLabel','DriveUnlock','DynaCall','EditGetCurrentCol','EditGetCurrentLine','EditGetLine','EditGetLineCount','EditGetSelectedText','EditPaste','EnvGet','EnvSet','Exit','ExitApp','Exp','FileAppend','FileCopy','FileCreateShortcut','FileDelete','FileEncoding','FileExist','FileGetAttrib','FileGetShortcut','FileGetSize','FileGetTime','FileGetVersion','FileInstall','FileMove','FileOpen','FileRead','FileRecycle','FileRecycleEmpty','FileSelect','FileSetAttrib','FileSetTime','Floor','Format','FormatTime','GetKeyName','GetKeySC','GetKeyState','GetKeyVK','GetMethod','GetVar','GroupActivate','GroupAdd','GroupClose','GroupDeactivate','GuiCtrlFromHwnd','GuiFromHwnd','HasBase','HasMethod','HasProp','HotIf','HotIfWinActive','HotIfWinExist','HotIfWinNotActive','HotIfWinNotExist','Hotkey','Hotstring','IL_Add','IL_Create','IL_Destroy','ImageSearch','IniDelete','IniRead','IniWrite','InputBox','InstallKeybdHook','InstallMouseHook','InStr','IsAlnum','IsAlpha','IsDate','IsDigit','IsFloat','IsInteger','IsLabel','IsLower','IsNumber','IsObject','IsSet','IsSetRef','IsSpace','IsTime','IsUpper','IsXDigit','KeyHistory','KeyWait','ListLines','ListViewGetContent','Ln','LoadPicture','Log','LTrim','Max','MemoryCallEntryPoint','MemoryFindResource','MemoryFreeLibrary','MemoryGetProcAddress','MemoryLoadLibrary','MemoryLoadResource','MemoryLoadString','MemorySizeOfResource','MenuFromHandle','MenuSelect','Min','Mod','MonitorGet','MonitorGetCount','MonitorGetName','MonitorGetPrimary','MonitorGetWorkArea','MouseClick','MouseClickDrag','MouseGetPos','MouseMove','MsgBox','NumGet','NumPut','ObjAddRef','ObjBindMethod','ObjDump','ObjFromPtr','ObjFromPtrAddRef','ObjGetBase','ObjGetCapacity','ObjHasOwnProp','ObjLoad','ObjOwnPropCount','ObjOwnProps','ObjPtr','ObjPtrAddRef','ObjRelease','ObjSetBase','ObjSetCapacity','OnClipboardChange','OnError','OnExit','OnMessage','Ord','OutputDebug','Pause','Persistent','PixelGetColor','PixelSearch','PostMessage','ProcessClose','ProcessExist','ProcessSetPriority','ProcessWait','ProcessWaitClose','Random','RegDelete','RegDeleteKey','RegExMatch','RegExReplace','RegRead','RegWrite','Reload','ResourceLoadLibrary','Round','RTrim','Run','RunAs','RunWait','Send','SendEvent','SendInput','SendLevel','SendMessage','SendMode','SendPlay','SendRaw','SendText','SetCapsLockState','SetControlDelay','SetDefaultMouseSpeed','SetKeyDelay','SetMouseDelay','SetNumLockState','SetRegView','SetScrollLockState','SetStoreCapsLockMode','SetTimer','SetTitleMatchMode','SetWinDelay','SetWorkingDir','Shutdown','Sin','sizeof','Sleep','Sort','SoundBeep','SoundGetInterface','SoundGetMute','SoundGetName','SoundGetVolume','SoundPlay','SoundSetMute','SoundSetVolume','SplitPath','Sqrt','StatusBarGetText','StatusBarWait','StrCompare','StrGet','StrLen','StrLower','StrPtr','StrPut','StrReplace','StrSplit','StrTitle','StrUpper','SubStr','Suspend','Swap','SysGet','SysGetIPAddresses','Tan','Thread','ToolTip','TraySetIcon','TrayTip','Trim','Type','UArray','UMap','UnZip','UnZipBuffer','UnZipRawMemory','UObject','VarSetStrCapacity','VerCompare','WinActivate','WinActivateBottom','WinActive','WinClose','WinExist','WinGetClass','WinGetClientPos','WinGetControls','WinGetControlsHwnd','WinGetCount','WinGetExStyle','WinGetID','WinGetIDLast','WinGetList','WinGetMinMax','WinGetPID','WinGetPos','WinGetProcessName','WinGetProcessPath','WinGetStyle','WinGetText','WinGetTitle','WinGetTransColor','WinGetTransparent','WinHide','WinKill','WinMaximize','WinMinimize','WinMove','WinMoveBottom','WinMoveTop','WinRedraw','WinRestore','WinSetAlwaysOnTop','WinSetEnabled','WinSetExStyle','WinSetRegion','WinSetStyle','WinSetTitle','WinSetTransColor','WinSetTransparent','WinShow','WinWait','WinWaitActive','WinWaitClose','WinWaitNotActive','ZipAddBuffer','ZipAddFile','ZipAddFolder','ZipCloseBuffer','ZipCloseFile','ZipCreateBuffer','ZipCreateFile','ZipInfo','ZipOptions','ZipRawMemory',]
        for n in allnames:
            ahkfuncs[n] = cls[n]
        return ahkfuncs

def VARIANT_value_getter(self, _VARIANT_value_getter = VARIANT.value.fget):
    if self.vt == 9:
        try:
            val = self.c_void_p
            IDispatch.QueryInterface(c_void_p(val), IID_IAhkObject)
            return IAhkObject(val)
        except:
            pass
    return _VARIANT_value_getter(self)
VARIANT.value = property(VARIANT_value_getter, VARIANT.value.fset)

def __getattr__(name):
    symbol = AhkApi[name]
    if symbol is None:
        raise AttributeError
    return symbol
