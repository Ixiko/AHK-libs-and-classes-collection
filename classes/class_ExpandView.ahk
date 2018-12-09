;

	/*    	DESCRIPTION of library class_expandView
        	-------------------------------------------------------------------------------------------------------------------
			Description  	:	A listview of expandable Gui's - use it to display xml info. You can use it for anything you want.
			                        	double click the captions to expand them
			Link              	:	https://autohotkey.com/boards/viewtopic.php?t=8030
			Author         	:	dd900 https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=427
			Date	            	:	04-Jun-2015
			AHK-Version	:	AHK-V1
			License         	:	
			Parameter(s)	:	
			Remark(s)    	:	
			Dependencies	:	class_Scrollgui by just me Link: https://github.com/AHK-just-me/Class_ScrollGUI
			KeyWords    	:	Listview
        	-------------------------------------------------------------------------------------------------------------------
	*/



class expandView
{
	__New( pHwnd, X:=0, Y:=0, W:=200, H:=200 ) {
		Gui New, Hwnd_hwnd -Caption +Parent%pHwnd%
		Gui New, Hwnd_chwnd -Caption +Parent%_hwnd%
		Gui %_hwnd%:Margin, 0, 0
		this.hwnd := _hwnd
		this.canvasHwnd := _chwnd
		this.expandable := []
		this.__Info := { x: X, y: Y, h: H, w: W - 17, pHwnd: pHwnd, yOffset: 0 }
	}

	newExpandable( H:=200, caption_H:=16, captionText:="DoubleClick-2-Expand" ) {
		this.expandable.Push( new this.__expandable( this, H, caption_H, captionText ) )
		this.__Info.yOffset += caption_H
		return this.expandable[ this.expandable.Length() ].hwnd
	}

	Show() {
		_mH := this.__minHeight()
		_chwnd := this.canvasHwnd
		Gui %_chwnd%:Show, % "x0 y0 w" this.__Info.w " h" this.__Info.h
		this.__ScrollGUI := New ScrollGUI( this.hwnd, 0, 0, "-Caption +Border +Parent" this.__Info.pHwnd, 2 )
		this.__ScrollGUI.Show( "", "x" this.__Info.x " y" this.__Info.y )
		WinMove % "ahk_id " this.canvasHwnd,, 0, 0, % this.__Info.w, % _mH > this.__Info.h ? _mH : this.__Info.h
		this.__ScrollGUI.AdjustToChild()
	}

	Destroy( slow:=0 ) {
		for i in this.expandable
		{
			_hwnd := this.expandable[ i ].hwnd
			Gui %_hwnd%:Destroy
			this.expandable[ i ].hwnd := ""
			this.expandable[ i ].__Info := ""
			this.expandable[ i ].__parent := ""
			if slow
				sleep %slow%
		}
		_hwnd := this.canvasHwnd
		Gui %_hwnd%:Destroy
		_hwnd := this.hwnd
		Gui %_hwnd%:Destroy
		this.canvasHwnd := ""
		this.hwnd := ""
		this.expandable := ""
		this.__Info := ""
		this.__ScrollGUI := ""
	}

	class __expandable
	{
		__New( pObj, H, caption_H, captionText ) {
			_fn := ObjBindMethod( this, "__CaptionClick" )
			this.__parent := pObj
			_pHwnd := pObj.canvasHwnd
			_y := pObj.__Info.yOffset
			_w := pObj.__Info.w
			Gui New, Hwnd_hwnd -Caption +Parent%_pHwnd%
			Gui %_hwnd%:Margin, 0, 0
			Gui %_hwnd%:Add, Text, HwndtHwnd +Border x0 y0 w%_w% h%caption_H% center, %captionText%
			GuiControl +g, %tHwnd%, %_fn%
			Gui %_hwnd%:Show, x0 y%_y% w%_w% h%caption_H%
			this.hwnd := _hwnd
			this.__Info := { expanded: 0, y: _y, h: H, cH: caption_H, Index: pObj.expandable.Length() + 1 }
		}

		__CaptionClick() {
			KeyWait, LButton, U
			KeyWait, LButton, D T0.2
			if !ErrorLevel {
				_h := this.__Info.h + this.__Info.cH
				_cnvsH := _h + this.__Info.y
				_pH := this.__parent.__Info.h
				if !this.__Info.expanded {
					if this.__parent.__hasExpanded()
						this.__parent.__collapseAll()
					this.__parent.__expand( this.__Info.Index )
				} else
					this.__parent.__collapseAll()
				this.__parent.__ScrollGUI.AdjustToChild()
			}
		}
	}

	__minHeight() {
		out := 0
		for i in this.expandable
			out += this.expandable[ i ].__Info.cH
		return out
	}

	__currentHeight() {
		out := 0
		for i in this.expandable
		{
			out += this.expandable[ i ].__Info.cH
			if this.expandable[ i ].__Info.expanded
				out += this.expandable[ i ].__Info.h
		}
		return out
	}

	__expand( index ) {
		_h := this.expandable[ index ].__Info.cH + this.expandable[ index ].__Info.h
		WinMove % "ahk_id " this.expandable[ index ].hwnd,, 0, this.expandable[ index ].__Info.y, % this.__Info.w, %_h%
		this.expandable[ index ].__Info.expanded := 1
		_ch := this.__currentHeight()
		WinMove % "ahk_id " this.canvasHwnd,, 0, 0, % this.__Info.w, % _cH > this.__Info.h ? _cH : this.__Info.h
		Loop % this.expandable.Length() {
			if ( A_Index <= index )
				continue
			_y := this.expandable[ A_Index ].__Info.y + this.expandable[ index ].__Info.h
			WinMove % "ahk_id " this.expandable[ A_Index ].hwnd,, 0, %_y%, % this.__Info.w, % this.expandable[ A_Index ].__Info.cH
		}
	}

	__collapseAll() {
		_h := this.__Info.h
		_mH := this.__minHeight()
		for i in this.expandable
		{
			WinMove % "ahk_id " this.expandable[ i ].hwnd,, 0, % this.expandable[ i ].__Info.y, % this.__Info.w, % this.expandable[ i ].__Info.cH
			this.expandable[ i ].__Info.expanded := 0
		}
		WinMove % "ahk_id " this.canvasHwnd,, 0, 0, % this.__Info.w, % _mH > _h ? _mH : _h
	}

	__hasExpanded() {
		out := 0
		for i in this.expandable
		{
			if this.expandable[ i ].__Info.expanded {
				out := 1
				break
			}
		}
		return out
	}
}