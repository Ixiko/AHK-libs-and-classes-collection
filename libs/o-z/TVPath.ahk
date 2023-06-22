; 注册表打开时跳转到相应条目 主窗口\OpenButton.ahk
; 复制注册表相应条目路径  注册表.ahk
; 64 位程序不适用与 32 位程序, 反之亦然

; https://autohotkey.com/boards/viewtopic.php?t=5999
;
; 更新记录：
; TVPath v1.2   更新支持64位系统 by wyagd001  2019-04-22
; TVPath v1.1   based on wz520 v1.0 Patched by TSiNGKONG [tsingkong~gmail.com] 2015-05-15
; TVPath v1.0   Written By wz520 [wingzero1040~gmail.com]
; 
;
; 函数:TVPath_Get
; 说明:
; 读取任意 SysTreeView32 控件的选中项目的路径。格式如 Root\Parent\SelectedItem（分隔符可自定义）。
; 语法:TVPath_Get(hTreeView, ByRef outPath, Delimiter="\")
; 参数:
; hTreeView - SysTreeView32 控件的句柄(HWND)，用ControlGet, hwnd取得
; outPath - 输出参数，接收结果。
; Delimiter - 自定义路径分隔符。可以是任意字符串。默认为"\"。
; 返回值:
; 字符串，指示错误出现的位置。无错误返回空串。
; 
; 相关命令:TVPath_Set
;
TVPath_Get(hTreeView, ByRef outPath, Delimiter="\")
{
	;判断窗口是否是Unicode
	isUnicode:=DllCall("IsWindowUnicode", uint, hTreeView)

	;消息和消息参数常量
	TVM_GETITEM := isUnicode=1 ? 0x113E : 0x110C
	BytePerChar := isUnicode=1 ? 2 : 1
	DllTextEncode := isUnicode=1 ? "UTF-16" : "CP0"

	TVM_GETNEXTITEM = 0x110A
	TVGN_CARET = 0x09
	TVGN_PARENT = 0x03
	TVIF_TEXT = 0x01
	NULL = 0
	;变量
	cchTextMax=128
	sizeof_TVITEMEX := A_PtrSize = 8 ? 80 : 60
	outPath=
	VarSetCapacity(szTextByte, cchTextMax * BytePerChar, 0)
	VarSetCapacity(tvitem, sizeof_TVITEMEX, 0)

	;获取选中项目的HTREEITEM
	SendMessage, TVM_GETNEXTITEM, TVGN_CARET, 0, ,ahk_id %hTreeView%
	if(errorlevel=NULL) ;没有选中项目
		return "selection"
	Else
		hSelItem:=errorlevel

	;以下Process系函数用
	;常量声明
	PROCESS_VM_OPERATION=0x8
	PROCESS_VM_WRITE=0x20
	PROCESS_VM_READ=0x10

	MEM_COMMIT=0x1000
	MEM_RESERVE=0x2000
	MEM_RELEASE := 0x8000
	MEM_FREE=0x10000
	PAGE_READWRITE=0x4
	;常量声明结束

	;变量初始化
	hProcess=0
	ret=0
	HasError:=""
	;变量初始化结束

	ControlGet, hwnd, HWND, , ,ahk_id %hTreeView%
	WinGet, pid, PID, ahk_id %hwnd%
	if (!pid)
		return "pid"

	hProcess := OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ, 0, pid)
	if (hProcess)
	{
		pTVItemRemote := VirtualAllocEx(hProcess, 0, sizeof_TVITEMEX, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)
		pszTextRemote := VirtualAllocEx(hProcess, 0, cchTextMax * BytePerChar, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)
		if (pszTextRemote && pTVItemRemote)
		{
			while hSelItem != 0 ;到根节点结束
			{
        if (A_PtrSize = 4)
				{
					;写tvitem结构体
					NumPut(TVIF_TEXT, tvitem, 0) ;mask
					NumPut(hSelItem, tvitem, 4) ;hItem
					NumPut(pszTextRemote, tvitem, 16) ;szTextByte
					NumPut(cchTextMax, tvitem, 20) ;cchTextMax
				}
        if (A_PtrSize = 8)
				{
					;写tvitem结构体
					NumPut(TVIF_TEXT, tvitem, 0) ;mask
					NumPut(hSelItem, tvitem, 8) ;hItem
					NumPut(pszTextRemote, tvitem, 24) ;szTextByte
					NumPut(cchTextMax, tvitem, 32) ;cchTextMax
				}

				ret := WriteProcessMemory(hProcess, pTVItemRemote, &tvitem, sizeof_TVITEMEX, 0)
				if (ret)
				{
					; 获取文字， errorlevel 为真表示成功， false 表示失败
					SendMessage, TVM_GETITEM, 0, pTVItemRemote, , ahk_id %hTreeView%
					if(errorlevel!="FAIL" && errorlevel!=0) ;获取文字成功
					{
						;fileappend, % "成功时errorlevel= " errorlevel " - " hTreeView " - 测试`n",%A_Desktop%\123.txt
						ret := ReadProcessMemory(hProcess, pszTextRemote, szTextByte, cchTextMax * BytePerChar)
						if (ret)
						{
							szText := StrGet(&szTextByte, cchTextMax, DllTextEncode)
							VarSetCapacity(szText, -1)
							outPath := (outPath="") ? szText : szText . Delimiter . outPath
							;fileappend, % outPath "`n",%A_Desktop%\123.txt
							;获取父节点
							SendMessage, TVM_GETNEXTITEM, TVGN_PARENT, hSelItem, , ahk_id %hTreeView%
							hSelItem := errorlevel ;返回NULL则跳出
						}
						else
						{
							HasError:="read"
							break
						}
					}
					else
					{
						HasError := "gettext - " errorlevel
						;fileappend, % TVM_GETITEM " - " errorlevel " - " hTreeView " - 测试`n",%A_Desktop%\123.txt
						break
					}
				}
				else
				{
					HasError := "write - " errorlevel
					break
				}
			}
		}
	else
		HasError:="alloc"
	}
    else
	HasError:="process"


	;释放内存
	if(pszTextRemote)
		VirtualFreeEx(hProcess, pszTextRemote, cchTextMax * BytePerChar, MEM_RELEASE)
	if(pTVItemRemote)
		VirtualFreeEx(hProcess, pTVItemRemote, sizeof_TVITEMEX, MEM_RELEASE)
	if(hProcess)
		CloseHandle(hProcess)

	return HasError
}
; 
; 函数: TVPath_Set
; 说明:
;		选中任意 SysTreeView32 控件的节点。格式如 Root\Parent\Item（分隔符可自定义）
; 语法:TVPath_Set(hTreeView, inPath, ByRef outMatchPath,  EscapeChar="", Delimiter="\", RetryTimesForGetChild=0, NoSelection=False)
; 参数:
;		hTreeView - SysTreeView32 控件的句柄(HWND)，用ControlGet, hwnd取得
;		inPath - 需要设置的路径。若需要匹配更复杂的路径，使用下面的EscapeChar参数。
;		outMatchPath - 输出参数，返回控件实际可以匹配的最长路径。
;		EscapeChar - 默认为空，不使用转义符。
;			如果不为空，则会使用该参数所定义的转义符。
;			转义符可以是任何字符串，必须出现于节点名的开头，否则不会被转义。
;			关于转义符的详细说明，参见“注意事项”。
;		Delimiter - 自定义路径分隔符。可以是任意字符串。默认为"\"。
;		RetryTimesForGetChild - 用于解决某些程序（如Windows XP的资源管理器）只能选择前几层节点的问题。
;			当 TVPath_Set() 发送“展开节点”消息(TVM_EXPAND)给目标TreeView控件时，如果该控件返回0，表示失败或无子节点。通常情况下函数应该直接返回，但是像资源管理器这样的程序，貌似是另开一个线程去搜子目录，导致在子目录搜索完并且添加到TreeView控件之前该消息永远返回0。
;			那么一个解决方法就是，每隔100毫秒不断发送TVM_EXPAND，直到返回非0为止。该参数就是指定这样重复发送消息的次数。默认为0，表示不重复发送消息（实际最大发送消息次数 = 该参数值 + 1）。
;			总之该值越大，展开节点的成功率越高，但可能会有一些停顿。
;		NoSelection - 默认为False，如果只想获取 outMatchPath 而不想实际选中任何节点（但是展开是不可避免的），可以将此参数设为True。
; 返回值:
;		字符串，指示错误出现的位置。无错误返回空串。
; 
;		关于转义符的说明：
;		利用转义符可以更方便地匹配各层节点。详细说明如下（为了方便，以下用 @# 表示转义符）：
;			如果 @# 后面是数字（可以是十六进制），比如 @#2，那么会将此项解析为序号。
;				举例：root\@#1\@#2 ，将会选中 root 节点下的第1个节点下的第2个节点，而不管节点名是什么。
;			如果 @# 后面带一个*，那么*后面的内容就被解析为正则表达式（直接作为NeedleRegEx参数交给AHK的 RegExMatch() 函数去处理），但只能匹配第一个。
;				如果正则表达式本身有错，函数立即出错返回。返回值将等于 RegExMatch() 执行后的 errorlevel 值（详见AHK关于RegExMatch()函数的帮助）。
;				如果在调用本函数时没有指定Delimiter参数（后述）的话，由于默认的路径节点分隔符是“\”，正则自身的“\”转义符需要使用AHK的转义符“ `”代替（注意：在脚本中必须写2个``，因为单独的 ` 会被AHK本身转义），比如 `s 代表空白字符。但如果指定了不包含"\"的分隔符，则正则自身的转义符还是“\”。
;				举例：选中第一层中第一个以t开头的节点下的第一个以z结尾的节点：@#*^t\@#*z$
;			如果 @# 后面为空，出错返回。
;			如果 @# 后面的内容不满足以上条件，则会将后面的内容解析为一个函数名。每次 TVPath_Set() 找到该层中的一个节点时，会调用该函数，由该函数（下称“回调函数”）的返回值决定下一步的操作，这样可以实现更加精确的匹配。
;				对于目前版本的 TVPath_Set()，回调函数应该“最多”接收5个参数（从左到右）：
;					#1: 当前找到的节点名
;					#2: 当前层数
;					#3: 当前节点的路径（不以路径分隔符结尾，不包括节点名）
;					#4: 当前节点的句柄
;					#5: 当前节点所属 SysTreeView32 控件的句柄。
;				回调函数应该返回的值：
;					>0: 匹配。选中（也可能不选中，取决于下面的NoSelection参数）并展开该节点，继续查找其子节点。
;					=0: 不匹配。继续查找同级节点。
;					<0: 匹配。选中该节点，但终止查找。
;				若回调函数不存在，出错返回。
;				示例：在 资源管理器 的目录树中选中第2个带“本地磁盘”字样的盘符。回调函数可以这样写：
;					MatchNode(NodeText) ;剩下的几个参数用不到，所以可以只接受一个参数
;					{
;						static count=1
;						IfInString, NodeText, 本地磁盘
;						{
;							if count=2
;								return, -1 ;返回小于0的值，表示选中该项并终止查找。
;							count++
;						}
;						return 0 ;不匹配则继续查找同级节点
;					}
;					调用 TVPath_Set:
;					TVPath_Set(hTreeView, "桌面\我的电脑\@#MatchNode", MatchPath, "@#")
;
TVPath_Set(hTreeView, inPath, ByRef outMatchPath,  EscapeChar="", Delimiter="\", RetryTimesForGetChild=0, NoSelection=False)
{
	if Delimiter=
		return "Delimiter"
	outMatchPath =

	;判断窗口是否是Unicode
	isUnicode:=DllCall("IsWindowUnicode", "uint", hTreeView)
	BytePerChar:= isUnicode = 1 ? 2 : 1

	;消息和消息参数常量
	TVM_GETNEXTITEM = 0x110A
	TVGN_ROOT = 0
	NULL = 0
	;变量
	cchTextMax=128
	sizeof_TVITEMEX := A_PtrSize = 8 ? 80 : 60	;TVITEMEXA and TVITEMEXW is same
	VarSetCapacity(szTextByte, cchTextMax * BytePerChar, 0)
	VarSetCapacity(tvitem, sizeof_TVITEMEX, 0)

	;获取根节点的HTREEITEM
	SendMessage, TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %hTreeView%
	if(errorlevel=NULL) ;没有根节点
		return "root"
	Else
		hSelItem:=errorlevel

		htext:=TVPath_GetText(hTreeView, hSelItem)
		CF_tooltip(htext, 2000)
		;if (htext = "收藏夹") || (htext = "快速访问") ; 资源管理器 首个节点为收藏夹
		if (htext != "此电脑") && (htext != "计算机")
		{
			Loop 20
			{
				hSelItem:=TVPath_GetNext(hTreeView, hSelItem,"full")
				htext:=TVPath_GetText(hTreeView, hSelItem)
				if (htext="计算机") || (htext="此电脑")  ; 找到 计算机 节点为止
				{
					CF_tooltip("找到了根目录: " htext, 3000)
					break
				}
			}
		}

	;以下Process系函数用
	;常量声明
	PROCESS_VM_OPERATION=0x8
	PROCESS_VM_WRITE=0x20
	PROCESS_VM_READ=0x10

	MEM_COMMIT=0x1000
	MEM_RESERVE=0x2000
	MEM_FREE=0x10000
	MEM_RELEASE := 0x8000
	PAGE_READWRITE=0x4
	;常量声明结束

	;变量初始化
	hProcess=0
	ret=0
	HasError:=""
	;变量初始化结束

	ControlGet, hwnd, HWND, , ,ahk_id %hTreeView%
	WinGet, pid, PID, ahk_id %hwnd%
	if (!pid)
		return "pid"

	hProcess := OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ, 0, pid)
	if (hProcess)
	{
		pTVItemRemote := VirtualAllocEx(hProcess, 0, sizeof_TVITEMEX, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)

		pszTextRemote := VirtualAllocEx(hProcess, 0, cchTextMax * BytePerChar, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)
			;
		if (pszTextRemote && pTVItemRemote)
__dummySetPathToTreeView(hProcess, hTreeView, hSelItem, inPath, tvitem, szTextByte, pszTextRemote, pTVItemRemote, inPath, outMatchPath, HasError, EscapeChar, NoSelection, 0, Delimiter, RetryTimesForGetChild)

		else
			HasError:="alloc"
	} else
		HasError:="process"

	;释放内存
	if(pszTextRemote)
		VirtualFreeEx(hProcess, pszTextRemote, cchTextMax * BytePerChar, MEM_RELEASE)
	if(pTVItemRemote)
		VirtualFreeEx(hProcess, pTVItemRemote, sizeof_TVITEMEX, MEM_RELEASE)
	if(hProcess)
		CloseHandle(hProcess)

	return HasError
}

;由 TVPath_Set 函数调用，勿直接调用此函数。
__dummySetPathToTreeView(hProcess, hTreeView, hItem, RestPath, ByRef tvitem, ByRef szTextByte, pszTextRemote, pTVItemRemote, ByRef FullPath, ByRef MatchPath, ByRef HasError, ByRef EscapeChar, ByRef NoSelection, Depth, ByRef Delimiter, ByRef RetryTimesForGetChild)
{

	if RestPath=
		return
	Depth++
	DelimiterPos:=instr(RestPath, Delimiter)
	FindText := DelimiterPos>0 ? substr(RestPath, 1, DelimiterPos-1) : RestPath
	StringTrimLeft, RestPath, RestPath, % StrLen(FindText)+Strlen(Delimiter)

	FuncName=
	RegExStr=
	MatchCount=0
	;处理转义符
	if(EscapeChar!="" && instr(FindText, EscapeChar)=1)
	{
		StringTrimLeft, FindText, FindText, % Strlen(EscapeChar)
		if FindText is integer
			MatchCount:=FindText
		else if(instr(FindText, "*")=1) {
			StringTrimLeft, RegExStr, FindText, 1
			IfInString, Delimiter, \, StringReplace, RegExStr, RegExStr, ``, \, All
		}
		else if FindText=
		{
			HasError=EscapeChar
			return
		} else {
			FuncName=%FindText%
			if(!IsFunc(FuncName)) {
				HasError=FuncName
				return
			}
		}
	}
	;fileappend, % "路径: " RestPath "`n",%A_Desktop%\345.txt
	;fileappend, % FindText "`n",%A_Desktop%\345.txt
	;判断窗口是否是Unicode
	isUnicode:=DllCall("IsWindowUnicode", uint, hTreeView)

	;消息和消息参数常量
	TVM_GETITEM := isUnicode=1 ? 0x113E : 0x110C
	BytePerChar := isUnicode=1 ? 2 : 1
	DllTextEncode := isUnicode=1 ? "UTF-16" : "CP0"

	TVM_EXPAND = 0x1102
	TVM_GETNEXTITEM = 0x110A
	TVM_SELECTITEM = 0x110B

	TVGN_CARET = 0x09
	TVGN_CHILD = 0x04
	TVGN_NEXT = 0x01

	TVE_EXPAND = 0x02
	TVIF_TEXT = 0x01
	;变量
	cchTextMax=128
	sizeof_TVITEMEX := A_PtrSize = 8 ? 80 : 60
	while hItem != 0
	{
		Matches:=False
		Continues:=True

        if (A_PtrSize = 4)
				{
					;写tvitem结构体
					NumPut(TVIF_TEXT, tvitem, 0) ;mask
					NumPut(hItem, tvitem, 4) ;hItem
					NumPut(pszTextRemote, tvitem, 16) ;szTextByte
					NumPut(cchTextMax, tvitem, 20) ;cchTextMax
				}
        if (A_PtrSize = 8)
				{
					;写tvitem结构体
					NumPut(TVIF_TEXT, tvitem, 0) ;mask
					NumPut(hItem, tvitem, 8) ;hItem
					NumPut(pszTextRemote, tvitem, 24) ;szTextByte
					NumPut(cchTextMax, tvitem, 32) ;cchTextMax
				}

		;准备获取文字
		ret := WriteProcessMemory(hProcess, pTVItemRemote, &tvitem, sizeof_TVITEMEX, 0)
		if (ret)
		{
			;获取文字
			SendMessage, TVM_GETITEM, 0, pTVItemRemote, , ahk_id %hTreeView%
			if(errorlevel!="FAIL" && errorlevel!=0) ;获取文字成功
			{
				ret := ReadProcessMemory(hProcess, pszTextRemote, szTextByte, cchTextMax * BytePerChar)
				if (ret)
				{
					szText := StrGet(&szTextByte, cchTextMax, DllTextEncode)
					VarSetCapacity(szText, -1)
					;msgbox % szText
					if (MatchCount=A_Index)
						Matches:=True
					else if FuncName!=
					{
						ret:=%FuncName%(szText, Depth, MatchPath, hItem, hTreeView)
						if(ret>0)
							Matches:=True
						else if(ret<0)
						{
							Matches:=True
							Continues:=False
						}
					}
					else if RegExStr!=
					{
						FoundPos:=RegExMatch(szText, RegExStr)
						if errorlevel=0
						{
							if(FoundPos>0)
								Matches:=True
						} else {
							HasError:=errorlevel
							break
						}
					} else if (szText=FindText)
						Matches:=True

					if (Matches) ;匹配
					{
						MatchPath := (MatchPath="") ? szText : MatchPath . Delimiter . szText
						;选中节点
						if(!NoSelection)
							SendMessage, TVM_SELECTITEM, TVGN_CARET, hItem, , ahk_id %hTreeView%

						if(Continues)
						{
							;展开
							looptimes:=RetryTimesForGetChild+1
							Loop, % looptimes
							{
								SendMessage, TVM_EXPAND, TVE_EXPAND, hItem, , ahk_id %hTreeView%
								if ( RestPath!="" && (errorlevel=0 || errorlevel="FAIL") ) ;不是指定路径的最后一个节点，但却返回无子节点，重试10次。
									Sleep, 100
								else
									break
							}
							if (errorlevel!="FAIL" && errorlevel!=0) ;展开成功
							{
								;获取第一个子节点
								SendMessage, TVM_GETNEXTITEM, TVGN_CHILD, hItem, , ahk_id %hTreeView%
								hItem:=errorlevel
								;递归查找下一层
								__dummySetPathToTreeView(hProcess, hTreeView, hItem, RestPath, tvitem, szTextByte, pszTextRemote, pTVItemRemote, FullPath, MatchPath, HasError, EscapeChar, NoSelection, Depth, Delimiter, RetryTimesForGetChild)
							}
						}
						break
					}
				} else {
					HasError:="read"
					break
				}
			} else {
				HasError:="gettext"
				;fileappend, % TVM_GETITEM " - " errorlevel " - " hTreeView " - 测试`n",%A_Desktop%\345.txt
				break
			}
		} else {
			HasError:="write"
			break
		}
		;获取下一个同级节点
		SendMessage, TVM_GETNEXTITEM, TVGN_NEXT, hItem, , ahk_id %hTreeView%
		hItem:=errorlevel
	}
}

TVPath_GetText(hTreeView, pItem)
{
	TVM_GETITEMW := 0x113E
	TVM_GETITEMA := 0x110C
	PROCESS_VM_OPERATION=0x8
	PROCESS_VM_WRITE=0x20
	PROCESS_VM_READ=0x10
	PROCESS_QUERY_INFORMATION := (0x1000)

	MEM_COMMIT=0x1000
	MEM_RESERVE=0x2000
	MEM_FREE=0x10000
	PAGE_READWRITE=0x4

	TVIF_TEXT  := 0x0001
	TVIF_HANDLE             := 0x0010
	MEM_RELEASE := 0x8000

	TVM_GETITEM := A_IsUnicode ? TVM_GETITEMW : TVM_GETITEMA
	WinGet ProcessId, pid, % "ahk_id " hTreeView
	hProcess := OpenProcess(PROCESS_VM_OPERATION|PROCESS_VM_READ
                               |PROCESS_VM_WRITE|PROCESS_QUERY_INFORMATION
                               , false, ProcessId)
	if (!hProcess)
	return "No Open"
	; Try to determine the bitness of the remote tree-view's process
	ProcessIs32Bit := A_PtrSize = 8 ? False : True
	;msgbox % ProcessIs32Bit
	If (A_Is64bitOS) && DllCall("Kernel32.dll\IsWow64Process", "Ptr", hProcess, "UIntP", WOW64)
		ProcessIs32Bit := WOW64

	Size := ProcessIs32Bit ?  60 : 80 ; Size of a TVITEMEX structure

	_tvi := VirtualAllocEx(hProcess, 0, Size, MEM_COMMIT, PAGE_READWRITE)
	_txt := VirtualAllocEx(hProcess, 0, 256,  MEM_COMMIT, PAGE_READWRITE)
	if (!_tvi)
	return "No _tvi"
	if (!_txt)
	return "No _txt"
	; TVITEMEX Structure
	VarSetCapacity(tvi, Size, 0)
	NumPut(TVIF_TEXT|TVIF_HANDLE, tvi, 0, "UInt")
	If (ProcessIs32Bit)
	{
		NumPut(pItem, tvi,  4, "UInt")
		NumPut(_txt , tvi, 16, "UInt")
		NumPut(127  , tvi, 20, "UInt")
	}
	Else
	{
		NumPut(pItem, tvi,  8, "UInt64")
		NumPut(_txt , tvi, 24, "UInt64")
		NumPut(127  , tvi, 32, "UInt")
	}

	VarSetCapacity(txt, 256, 0)
	WriteProcessMemory(hProcess, _tvi, &tvi, Size)

	SendMessage TVM_GETITEM, 0, _tvi, ,  % "ahk_id " hTreeView
	if(errorlevel!="FAIL" && errorlevel!=0)
		ReadProcessMemory(hProcess, _txt, txt, 256)

	VirtualFreeEx(hProcess, _txt, 0, MEM_RELEASE)
	VirtualFreeEx(hProcess, _tvi, 0, MEM_RELEASE)
	CloseHandle(hProcess)
	szText := StrGet(&txt, 127, "UTF-16")
	;msgbox % szText
	return szText
}

TVPath_GetNext(hTreeView, pItem = 0, flag = "")
{
	TVM_EXPAND = 0x1102
	TVM_GETNEXTITEM = 0x110A
	TVM_SELECTITEM = 0x110B

	TVGN_CARET = 0x09
	TVGN_CHILD = 0x04
	TVGN_NEXT = 0x01
	TVGN_PARENT             := 0x0003

	TVE_EXPAND = 0x02
	TVIF_TEXT = 0x01

		static Root := -1
		
		if (RegExMatch(flag, "i)^\s*(F|Full)\s*$")) {
			if (Root = -1) {
				Root := pItem
			}
			SendMessage TVM_GETNEXTITEM, TVGN_CHILD, pItem, , % "ahk_id " hTreeView
			if (ErrorLevel = 0) {
				SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , % "ahk_id " hTreeView
				if (ErrorLevel = 0) {
					Loop {
						SendMessage TVM_GETNEXTITEM, TVGN_PARENT, pItem, , % "ahk_id " hTreeView
						if (ErrorLevel = Root) {
							Root := -1
							return 0
						}
						pItem := ErrorLevel
						SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , % "ahk_id " hTreeView
					} until ErrorLevel
				}
			}
			return ErrorLevel
		}
		
		Root := -1
		if (!pItem)
			SendMessage TVM_GETNEXTITEM, TVGN_ROOT, 0, , % "ahk_id " hTreeView
		else
			SendMessage TVM_GETNEXTITEM, TVGN_NEXT, pItem, , % "ahk_id " hTreeView
		return ErrorLevel
}