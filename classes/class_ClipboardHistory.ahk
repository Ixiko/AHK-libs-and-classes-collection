;***********************************************************************************************
; 
; クリップボード履歴
; 
;***********************************************************************************************
;-----------------------------------------------------------------------
; クリップボード履歴の初期化
;-----------------------------------------------------------------------
InitClipboardHistory(MaxItemCount = 100) {
	global ClipboardHistory := new CClipboardHistory(MaxItemCount)
}

;-----------------------------------------------------------------------
; クリップボード履歴を起動
;-----------------------------------------------------------------------
ShowClipboardHistory(x = 0, y = 0) {
	global ClipboardHistory
	ClipboardHistory.Update()
	ClipboardHistory.Show(x, y)
}

;-----------------------------------------------------------------------
; OnClipboardChange
;-----------------------------------------------------------------------
ClipboardHistory_OnClipboardChange() {
	if (IsObject(CClipboardHistory.Instance)) {
		CClipboardHistory.Instance.OnClipboardChange()
	}
}

;***********************************************************************************************
; ランチャー制御
;***********************************************************************************************
class CClipboardHistory
{
	static Instance :=
	
	;-----------------------------------------------------------------------
	; コンストラクタ
	;-----------------------------------------------------------------------
	__New(MaxItemCount = 100) {
		if (IsObject(CClipboardHistory.Instance)) {
			this.__Delete()
		}
		CClipboardHistory.Instance := this
		
		; 初期化
		this.MaxItemCount := MaxItemCount
		this.MaxMenuCount := 10
		this.MaxMenuLen := 50
		this.MaxTooltipLen := 1024
		this.Items := []
		this.SubMenus := ""
		this.Result := 0
		
		; メニュー生成
		PumParams := {"selMethod"   : "fill"	; may be "frame","fill"
					 ;,"selBGColor"	: -1		; background color of selected item, -1 means invert, default - COLOR_MENUHILIGHT
					 ;,"selTColor"	: -1		; text color of selected item, -1 means invert, default - COLOR_HIGHLIGHTTEXT
					 ;,"frameWidth"	: 1			; width of select frame when selMethod = "frame"
					 ;,"oninit"		: ""
					 ;,"onuninit"	: ""
					 ,"onselect"	: "CClipboardHistory_PumHandler_"
					 ;,"onrbutton"	: ""
					 ;,"onmbutton"	: ""
					 ,"onrun"		: "CClipboardHistory_PumHandler_"
					 ;,"onshow"		: ""
					 ,"onclose"		: "CClipboardHistory_PumHandler_"
					 ;,"pumfont"	: ""
					 ,"mnemonicCmd": "select"}	; may be "select","run"
		this.Pum := new PUM(PumParams)
		this.Menu := ""
	}
	
	;-----------------------------------------------------------------------
	; デストラクタ
	;-----------------------------------------------------------------------
	__Delete() {
		this.Items := ""
		this.Pum.Destroy()
	}
	
	;-----------------------------------------------------------------------
	; OnClipboardChange
	;-----------------------------------------------------------------------
	OnClipboardChange() {
		Sleep, 100
		ClipWait, 1
		if (ErrorLevel == 0) {
			this.AppendText(ClipBoard)
		}
	}
	
	;-----------------------------------------------------------------------
	; メニュー表示
	;-----------------------------------------------------------------------
	Show(x = 0, y = 0, flags = "") {
		WinGet, active_id, ID, A
		this.Result := 0
		this.Menu.Show(x, y, flags)
		this.DestroyMenu_(this.Menu)
		this.SubMenus := ""
		WinWaitActive, ahk_id %active_id%, , 1
		
		WinGet, current_active_id, ID, A
		if (current_active_id == active_id) {
			; テキストのインデックスが返ってきた場合はペーストする
			if (this.Result > 0) {
				SetTextToClipboard(this.Items[this.Result, 1])
				PasteFromClipboard()
				
				; 選択されたテキストは一番新しい履歴に移動
				Append := this.AppendText(this.Items[this.Result, 1], false)
				if (Append) {
					this.Items.Remove(this.Result)
				}
			}
		}
	}

	;-----------------------------------------------------------------------
	; メニュー更新
	;-----------------------------------------------------------------------
	Update() {
		; 以前のメニューは破棄する
		this.DestroyMenu_(this.Menu)
		this.SubMenus := ""
		this.Menu := this.CreateMenu_()
		this.SubMenus := []
		
		; 表示する数を計算
		Count := this.MaxItemCount
		MaxIndex := this.Items.MaxIndex()
		if (Count > MaxIndex) {
			Count := MaxIndex
		}
		
		; メニューに追加
		Count := this.UpdateTextMenu_(this.Menu, Count)
		
		; これ以降はサブメニューに追加
		Loop {
			if (Count <= 0) {
				break
			}
			
			; サブメニューに追加
			Index := this.NewIndex_(this.SubMenus)
			this.SubMenus[Index] := this.CreateMenu_()
			Count := this.UpdateTextMenu_(this.SubMenus[Index], Count)
			
			; キャンセルを追加
			this.AppendSeparator_(this.SubMenus[Index])
			this.AppendCancel_(this.SubMenus[Index])
			
			; サブメニュー登録
			this.AppendSubMenu_(this.Menu, this.SubMenus[Index], "NEXT", Index + this.MaxMenuCount)
		}
		
		; キャンセルを追加
		this.AppendSeparator_(this.Menu)
		this.AppendCancel_(this.Menu)
	}
	
	;-----------------------------------------------------------------------
	; テキスト追加
	;-----------------------------------------------------------------------
	AppendText(Text, Limiter = true) {
		Append := false
		
		; 格納先インデックスを取得
		Index := this.NewIndex_(this.Items)
		
		; 最新の履歴と異なるなら追加
		if (Text != this.Items[Index - 1, 1]) {
			if (Limiter) {
				; 上限を超えているなら古いのを削除
				if (Index > this.MaxItemCount) {
					Loop, % Index - this.MaxItemCount {
						this.Items.Remove(1)
					}
					Index := this.NewIndex_(this.Items)
				}
			}
			
			; クリップボードの中身を追加
			this.Items[Index, 1] := Text
			Append := true
		}
		
		return Append
	}
	
	;-----------------------------------------------------------------------
	; テキストメニュー更新
	;-----------------------------------------------------------------------
	UpdateTextMenu_(Byref Menu, Count) {
		MenuCount := this.GetMenuCount_(Count)
		Loop % MenuCount {
			Index := Count - A_Index + 1
			Len := StrLen(this.Items[Index, 1])
			if (Len > this.MaxMenuLen) {
				this.Items[Index, 2] := Len
				Str := SubStr(this.Items[Index, 1], 1, this.MaxMenuLen)
				this.AppendText_(Menu, Str, Index, A_Index)
			}
			else {
				this.Items[Index, 2] := 0
				this.AppendText_(Menu, this.Items[Index, 1], Index, A_Index)
			}
		}
		Count -= MenuCount
		return Count
	}
	
	;-----------------------------------------------------------------------
	; メニュー数を取得
	;-----------------------------------------------------------------------
	GetMenuCount_(Count) {
		if (Count > this.MaxMenuCount) {
			MenuCount := this.MaxMenuCount
		}
		else {
			MenuCount := Count
		}
		
		return MenuCount
	}
	
	;-----------------------------------------------------------------------
	; メニューハンドラ
	;-----------------------------------------------------------------------
	PumHandler_(Msg, Obj) {
		Index := Obj.uid
		if (Msg == "onselect") {
			this.PumOnSelect(Index, Obj)
		}
		else if (Msg == "onrun") {
			this.PumOnRun(Index, Obj)
		}
		else if (Msg == "onclose") {
			this.PumOnClose(Index, Obj)
		}
		else {
			
		}
	}
	
	;-----------------------------------------------------------------------
	; OnSelect
	;-----------------------------------------------------------------------
	PumOnSelect(Index, Obj) {
		if (Index == 0) {
			tooltip
		}
		else {
			if (this.Items[Index, 2] == 0) {
				tooltip
			}
			else {
				if (this.Items[Index, 2] > this.MaxTooltipLen) {
					Str := SubStr(this.Items[Index, 1], 1, this.MaxTooltipLen)
					Str .= "`n`n----`n※表示文字数の上限までしか表示していません。"
				}
				else {
					Str := this.Items[Index, 1]
				}
				StringReplace, Str, Str, `t, % "    ", All
				rect := Obj.GetRECT()
			    tooltip, % Str, % rect.right, % rect.top
			}
		}
	}
	
	;-----------------------------------------------------------------------
	; OnRun
	;-----------------------------------------------------------------------
	PumOnRun(Index, Obj) {
		this.Result := Index
	}
	
	;-----------------------------------------------------------------------
	; OnClose
	;-----------------------------------------------------------------------
	PumOnClose(Index, Obj) {
		tooltip
	}
	
	;-----------------------------------------------------------------------
	; メニュー作成
	;-----------------------------------------------------------------------
	CreateMenu_() {
		MenuParams := {"iconssize"	: 16
					  ;,"tcolor"	: pumAPI.GetSysColor(7)	; default - COLOR_MENUTEXT
					  ;,"bgcolor"	: pumAPI.GetSysColor(4)	; default - COLOR_MENU
					  ;,"nocolors"	: 0
					  ,"noicons"	: 1
					  ;,"notext"	: 0
					  ;,"maxheight"	: 0
					  ,"xmargin"	: 8
					  ,"ymargin"	: 3
					  ,"textMargin"	: -20		; this is a pixels zmount which will be added after the text to make menu look pretty
					  ,"textoffset"	: 5}		; gap between icon and item's text in pixels
		Menu := this.Pum.CreateMenu(MenuParams)
		return Menu
	}
	
	;-----------------------------------------------------------------------
	; メニュー破棄
	;-----------------------------------------------------------------------
	DestroyMenu_(Byref Menu) {
		if (IsObject(Menu)) {
			Menu.Destroy()
		}
		Menu := ""
	}
	
	;-----------------------------------------------------------------------
	; テキスト追加
	;-----------------------------------------------------------------------
	AppendText_(Byref Menu, Text, uid, Index) {
		Key := this.NewAccessKey_(Index)
		ItemParams := {"uid"			: uid
					  ,"name"			: "&" Key A_SPACE A_SPACE Text
					  ,"icon"			: 0
					  ;,"bold"			: 0
					  ;,"iconUseHandle"	: 0
					  ;,"break"			: 0			;0,1,2
					  ;,"submenu"		: 0
					  ;,"tcolor"		: ""
					  ;,"bgcolor"		: ""
					  ;,"noPrefix"		: 0
					  ;,"disabled"		: 0
					  ;,"noicons"		: -1		;-1 means use parent menu's setting
					  ;,"notext"		: -1
					  ,"issep"			: 0}
		Menu.Add(ItemParams)
	}
	
	;-----------------------------------------------------------------------
	; キャンセル追加
	;-----------------------------------------------------------------------
	AppendCancel_(Byref Menu) {
		CancelParams := {"uid"			: 0
					  ,"name"			: "&@  キャンセル"
					  ,"icon"			: 0
					  ;,"bold"			: 0
					  ;,"iconUseHandle"	: 0
					  ;,"break"			: 0			;0,1,2
					  ;,"submenu"		: 0
					  ;,"tcolor"		: ""
					  ;,"bgcolor"		: ""
					  ;,"noPrefix"		: 0
					  ;,"disabled"		: 0
					  ;,"noicons"		: -1		;-1 means use parent menu's setting
					  ;,"notext"		: -1
					  ,"issep"			: 0}
		Menu.Add(CancelParams)
	}
	
	;-----------------------------------------------------------------------
	; サブメニュー追加
	;-----------------------------------------------------------------------
	AppendSubMenu_(Byref Menu, Byref SubMenu, SubMenuName, Index) {
		Key := this.NewAccessKey_(Index)
		CancelParams := {"uid"			: 0
					  ,"name"			: "&" Key A_SPACE A_SPACE SubMenuName
					  ,"icon"			: 0
					  ;,"bold"			: 0
					  ;,"iconUseHandle"	: 0
					  ;,"break"			: 0			;0,1,2
					  ,"submenu"		: SubMenu
					  ;,"tcolor"		: ""
					  ;,"bgcolor"		: ""
					  ;,"noPrefix"		: 0
					  ;,"disabled"		: 0
					  ;,"noicons"		: -1		;-1 means use parent menu's setting
					  ;,"notext"		: -1
					  ,"issep"			: 0}
		Menu.Add(CancelParams)
	}
	
	;-----------------------------------------------------------------------
	; セパレーター追加
	;-----------------------------------------------------------------------
	AppendSeparator_(Byref Menu) {
		Menu.Add()
	}
	
	;-----------------------------------------------------------------------
	; 新規メニュー番号取得
	;-----------------------------------------------------------------------
	NewIndex_(Byref Items) {
		Index := Items.MaxIndex()
		++Index
		return Index
	}
	
	;-----------------------------------------------------------------------
	; 新規アクセラレータキー取得
	;-----------------------------------------------------------------------
	NewAccessKey_(Index) {
		KeyList := "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		if (Index < 0 || StrLen(KeyList) < Index) {
			Index := 1
		}
		Key := SubStr(KeyList, Index, 1)
		return Key
	}
}

;-----------------------------------------------------------------------
; メニューハンドラ
;-----------------------------------------------------------------------
CClipboardHistory_PumHandler_(Msg, Obj) {
	CClipboardHistory.Instance.PumHandler_(Msg, Obj)
}

;***********************************************************************************************
; インクルード
;***********************************************************************************************
#Include <PUM/PUM_API>
#Include <PUM/PUM>
#include Clipboard.ahk
