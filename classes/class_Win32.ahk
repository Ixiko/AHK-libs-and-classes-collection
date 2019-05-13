;update with all messages?
;https://msdn.microsoft.com/en-us/library/ms644927(v=VS.85).aspx#system_defined

;window styles need to go somewhere in here? Maybe there should be a class for each type of control?

;window
;listbox
;listview
;...

;however some of these belong in Msg32... <-- here we could use aliases?

class Msg32 {
    static WM_NULL = 0x00
    static WM_CREATE = 0x01
    static WM_DESTROY = 0x02
    static WM_MOVE = 0x03
    static WM_SIZE = 0x05
    static WM_ACTIVATE = 0x06
    static WM_SETFOCUS = 0x07
    static WM_KILLFOCUS = 0x08
    static WM_ENABLE = 0x0A
    static WM_SETREDRAW = 0x0B
    static WM_SETTEXT = 0x0C
    static WM_GETTEXT = 0x0D
    static WM_GETTEXTLENGTH = 0x0E
    static WM_PAINT = 0x0F
    static WM_CLOSE = 0x10
    static WM_QUERYENDSESSION = 0x11
    static WM_QUIT = 0x12
    static WM_QUERYOPEN = 0x13
    static WM_ERASEBKGND = 0x14
    static WM_SYSCOLORCHANGE = 0x15
    static WM_ENDSESSION = 0x16
    static WM_SYSTEMERROR = 0x17
    static WM_SHOWWINDOW = 0x18
    static WM_CTLCOLOR = 0x19
    static WM_WININICHANGE = 0x1A
    static WM_SETTINGCHANGE = 0x1A
    static WM_DEVMODECHANGE = 0x1B
    static WM_ACTIVATEAPP = 0x1C
    static WM_FONTCHANGE = 0x1D
    static WM_TIMECHANGE = 0x1E
    static WM_CANCELMODE = 0x1F
    static WM_SETCURSOR = 0x20
    static WM_MOUSEACTIVATE = 0x21
    static WM_CHILDACTIVATE = 0x22
    static WM_QUEUESYNC = 0x23
    static WM_GETMINMAXINFO = 0x24
    static WM_PAINTICON = 0x26
    static WM_ICONERASEBKGND = 0x27
    static WM_NEXTDLGCTL = 0x28
    static WM_SPOOLERSTATUS = 0x2A
    static WM_DRAWITEM = 0x2B
    static WM_MEASUREITEM = 0x2C
    static WM_DELETEITEM = 0x2D
    static WM_VKEYTOITEM = 0x2E
    static WM_CHARTOITEM = 0x2F

    static WM_SETFONT = 0x30
    static WM_GETFONT = 0x31
    static WM_SETHOTKEY = 0x32
    static WM_GETHOTKEY = 0x33
    static WM_QUERYDRAGICON = 0x37
    static WM_COMPAREITEM = 0x39
    static WM_COMPACTING = 0x41
    static WM_WINDOWPOSCHANGING = 0x46
    static WM_WINDOWPOSCHANGED = 0x47
    static WM_POWER = 0x48
    static WM_COPYDATA = 0x4A
    static WM_CANCELJOURNAL = 0x4B
    static WM_NOTIFY = 0x4E
    static WM_INPUTLANGCHANGEREQUEST = 0x50
    static WM_INPUTLANGCHANGE = 0x51
    static WM_TCARD = 0x52
    static WM_HELP = 0x53
    static WM_USERCHANGED = 0x54
    static WM_NOTIFYFORMAT = 0x55
    static WM_CONTEXTMENU = 0x7B
    static WM_STYLECHANGING = 0x7C
    static WM_STYLECHANGED = 0x7D
    static WM_DISPLAYCHANGE = 0x7E
    static WM_GETICON = 0x7F
    static WM_SETICON = 0x80

    static WM_NCCREATE = 0x81
    static WM_NCDESTROY = 0x82
    static WM_NCCALCSIZE = 0x83
    static WM_NCHITTEST = 0x84
    static WM_NCPAINT = 0x85
    static WM_NCACTIVATE = 0x86
    static WM_GETDLGCODE = 0x87
    static WM_NCMOUSEMOVE = 0xA0
    static WM_NCLBUTTONDOWN = 0xA1
    static WM_NCLBUTTONUP = 0xA2
    static WM_NCLBUTTONDBLCLK = 0xA3
    static WM_NCRBUTTONDOWN = 0xA4
    static WM_NCRBUTTONUP = 0xA5
    static WM_NCRBUTTONDBLCLK = 0xA6
    static WM_NCMBUTTONDOWN = 0xA7
    static WM_NCMBUTTONUP = 0xA8
    static WM_NCMBUTTONDBLCLK = 0xA9

    static WM_KEYFIRST = 0x100
    static WM_KEYDOWN = 0x100
    static WM_KEYUP = 0x101
    static WM_CHAR = 0x102
    static WM_DEADCHAR = 0x103
    static WM_SYSKEYDOWN = 0x104
    static WM_SYSKEYUP = 0x105
    static WM_SYSCHAR = 0x106
    static WM_SYSDEADCHAR = 0x107
    static WM_KEYLAST = 0x108

    static WM_IME_STARTCOMPOSITION = 0x10D
    static WM_IME_ENDCOMPOSITION = 0x10E
    static WM_IME_COMPOSITION = 0x10F
    static WM_IME_KEYLAST = 0x10F

    static WM_INITDIALOG = 0x110
    static WM_COMMAND = 0x111
    static WM_SYSCOMMAND = 0x112
    static WM_TIMER = 0x113
    static WM_HSCROLL = 0x114
    static WM_VSCROLL = 0x115
    static WM_INITMENU = 0x116
    static WM_INITMENUPOPUP = 0x117
    static WM_MENUSELECT = 0x11F
    static WM_MENUCHAR = 0x120
    static WM_ENTERIDLE = 0x121

    static WM_CTLCOLORMSGBOX = 0x132
    static WM_CTLCOLOREDIT = 0x133
    static WM_CTLCOLORLISTBOX = 0x134
    static WM_CTLCOLORBTN = 0x135
    static WM_CTLCOLORDLG = 0x136
    static WM_CTLCOLORSCROLLBAR = 0x137
    static WM_CTLCOLORSTATIC = 0x138

    static WM_MOUSEFIRST = 0x200
    static WM_MOUSEMOVE = 0x200
    static WM_LBUTTONDOWN = 0x201
    static WM_LBUTTONUP = 0x202
    static WM_LBUTTONDBLCLK = 0x203
    static WM_RBUTTONDOWN = 0x204
    static WM_RBUTTONUP = 0x205
    static WM_RBUTTONDBLCLK = 0x206
    static WM_MBUTTONDOWN = 0x207
    static WM_MBUTTONUP = 0x208
    static WM_MBUTTONDBLCLK = 0x209
    static WM_MOUSEWHEEL = 0x20A
    static WM_MOUSEHWHEEL = 0x20E

    static WM_PARENTNOTIFY = 0x210
    static WM_ENTERMENULOOP = 0x211
    static WM_EXITMENULOOP = 0x212
    static WM_NEXTMENU = 0x213
    static WM_SIZING = 0x214
    static WM_CAPTURECHANGED = 0x215
    static WM_MOVING = 0x216
    static WM_POWERBROADCAST = 0x218
    static WM_DEVICECHANGE = 0x219

    static WM_MDICREATE = 0x220
    static WM_MDIDESTROY = 0x221
    static WM_MDIACTIVATE = 0x222
    static WM_MDIRESTORE = 0x223
    static WM_MDINEXT = 0x224
    static WM_MDIMAXIMIZE = 0x225
    static WM_MDITILE = 0x226
    static WM_MDICASCADE = 0x227
    static WM_MDIICONARRANGE = 0x228
    static WM_MDIGETACTIVE = 0x229
    static WM_MDISETMENU = 0x230
    static WM_ENTERSIZEMOVE = 0x231
    static WM_EXITSIZEMOVE = 0x232
    static WM_DROPFILES = 0x233
    static WM_MDIREFRESHMENU = 0x234

    static WM_IME_SETCONTEXT = 0x281
    static WM_IME_NOTIFY = 0x282
    static WM_IME_CONTROL = 0x283
    static WM_IME_COMPOSITIONFULL = 0x284
    static WM_IME_SELECT = 0x285
    static WM_IME_CHAR = 0x286
    static WM_IME_KEYDOWN = 0x290
    static WM_IME_KEYUP = 0x291

    static WM_MOUSEHOVER = 0x2A1
    static WM_NCMOUSELEAVE = 0x2A2
    static WM_MOUSELEAVE = 0x2A3

    static WM_CUT = 0x300
    static WM_COPY = 0x301
    static WM_PASTE = 0x302
    static WM_CLEAR = 0x303
    static WM_UNDO = 0x304

    static WM_RENDERFORMAT = 0x305
    static WM_RENDERALLFORMATS = 0x306
    static WM_DESTROYCLIPBOARD = 0x307
    static WM_DRAWCLIPBOARD = 0x308
    static WM_PAINTCLIPBOARD = 0x309
    static WM_VSCROLLCLIPBOARD = 0x30A
    static WM_SIZECLIPBOARD = 0x30B
    static WM_ASKCBFORMATNAME = 0x30C
    static WM_CHANGECBCHAIN = 0x30D
    static WM_HSCROLLCLIPBOARD = 0x30E
    static WM_QUERYNEWPALETTE = 0x30F
    static WM_PALETTEISCHANGING = 0x310
    static WM_PALETTECHANGED = 0x311

    static WM_HOTKEY = 0x312
    static WM_PRINT = 0x317
    static WM_PRINTCLIENT = 0x318

    static WM_HANDHELDFIRST = 0x358
    static WM_HANDHELDLAST = 0x35F
    static WM_PENWINFIRST = 0x380
    static WM_PENWINLAST = 0x38F
    static WM_COALESCE_FIRST = 0x390
    static WM_COALESCE_LAST = 0x39F
    static WM_DDE_FIRST = 0x3E0
    static WM_DDE_INITIATE = 0x3E0
    static WM_DDE_TERMINATE = 0x3E1
    static WM_DDE_ADVISE = 0x3E2
    static WM_DDE_UNADVISE = 0x3E3
    static WM_DDE_ACK = 0x3E4
    static WM_DDE_DATA = 0x3E5
    static WM_DDE_REQUEST = 0x3E6
    static WM_DDE_POKE = 0x3E7
    static WM_DDE_EXECUTE = 0x3E8
    static WM_DDE_LAST = 0x3E8

    static WM_USER = 0x400
    static WM_APP = 0x8000
}