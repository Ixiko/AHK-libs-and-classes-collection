; Dll文件在此下载 https://github.com/CodyGuo/skinh
; 官方说明与皮肤文件 http://www.skinsharp.com/htdocs/docs.htm
#SingleInstance Force

; 强制使用32位运行
if !(A_IsUnicode=1 and A_PtrSize=4)
{
	SplitPath, A_AhkPath, , dir
	Run, %dir%\AutoHotkeyU32.exe "%A_ScriptFullPath%"		;必须加引号，否则文件名中含空格的文件无法识别
	ExitApp
}

; SkinH.dll for ansi.
; SkinHu.dll for unicode32.
; There is no trial version of x64, the only way i know is pay for it.
hSkinH := DllCall("LoadLibrary", "Str", "SkinHu.dll")
DllCall("SkinHu\SkinH_AttachEx", "Str", A_ScriptDir "\skins\skinh.she")

界面:
	; 菜单栏
	Menu FileMenu, Add, test1, MenuHandler
	Menu FileMenu, Add, test2, MenuHandler
	Menu FileMenu, Add, test3, MenuHandler
	Menu FileMenu, Add, test4, MenuHandler
	Menu FileMenu, Add, test5, MenuHandler
	Menu FileMenu, Add, test6, MenuHandler
	Menu MenuBar, Add, &File, :FileMenu
	Menu MenuBar, Add, &Test, testMenu
	Gui Menu, MenuBar
	Menu ContextMenu, Add, &Open...`tCtrl+O, MenuHandler
	Menu ContextMenu, Icon, &Open...`tCtrl+O, shell32.dll, 4
	Menu ContextMenu, Add, &Save`tCtrl+S, MenuHandler
	Menu ContextMenu, Icon, &Save`tCtrl+S, shell32.dll, 259

	; 显示皮肤文件
	Gui Add, GroupBox, x24 y8 w248 h650, 控件演示
	Gui Add, ListView, x40 y40 w215 h586 gchange vlv AltSubmit, 皮肤
	Loop, skins\*.she																	; 从文件夹中获取文件名列表并把它们放入 ListView:
		LV_Add("", A_LoopFileName)
	LV_ModifyCol()																		; 根据内容自动调整每列的大小.

	; 下面全是右侧演示控件
	Gui Add, Tab3, x288 y8 w495 h650, Tab 1|Tab 2

	Gui Add, Text, x336 y45 w96 h24, 测试文本
	Gui Add, Link, x472 y45 w96 h24, <a href="https://autohotkey.com">autohotkey.com</a>
	Gui Add, ComboBox, x608 y40 w120, combobox

	Gui Add, Checkbox, x336 y80 w96 h24, checkbox
	Gui Add, Radio, x472 y80 w96 h24, radiobutton
	Gui Add, DropDownList, x608 y80 w120, DropDownList|123|456

	Gui Add, Edit, x336 y120 w96 h24, edit
	Gui Add, UpDown, x432 y120 w17 h24 -16, 1
	Gui Add, Hotkey, x608 y120 w120 h20

	Gui Add, Progress, x336 y160 w233 h24, 50
	Gui Add, Slider, x336 y200 w233 h24, 50
	Gui Add, Button, x608 y160 w120 h65, 测试按钮

	Gui Add, ListView, x336 y240 w120 h148, Red|Green|
	LV_Add("", "Item1", "Item2")
	LV_Add("", "Item3", "Item4")
	LV_Add("", "Item5", "Item6")
	LV_Add("", "Item7", "Item8")
	LV_Add("", "Item9", "Item10")
	Gui Add, ListBox, x472 y240 w120 h148, Red|Green|Blue|Black|White
	Gui Add, TreeView, x608 y240 w120 h148
	P1 := TV_Add("First parent")
	P1C1 := TV_Add("Parent 1's first child", P1)  ; 指定 P1 为此项目的父项目.
	P2 := TV_Add("Second parent")
	P2C1 := TV_Add("Parent 2's first child", P2)
	P2C2 := TV_Add("Parent 2's second child", P2)
	P2C2C1 := TV_Add("Child 2's first child", P2C2)

	Gui Add, Text, x336 y408 w398 h2 +0x10

	Gui Add, DateTime, x336 y424 w225 h20, 2021-01-29
	Gui Add, MonthCal, x336 y448 w225 h176
	Gui Add, Picture, x608 y448 w120 h176, mspaint.exe
	Gui Add, StatusBar,, Status Bar

	Gui ListView, lv		; 设置换肤里的 LV_GetText() 函数默认操作第一个 ListView
	Gui Show, w805 h694, 换肤测试
Return

change:
	LV_GetText(OutputVar, A_EventInfo)
	DllCall("SkinHu\SkinH_AttachEx", "Str", A_ScriptDir "\skins\" OutputVar)
Return

MenuHandler:
Return
testMenu:
Return
GuiContextMenu:
	Menu ContextMenu, Show
Return

GuiEscape:
GuiClose:
	ExitApp
Return