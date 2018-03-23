; ==============================================================================
; ==============================================================================
; str GUID2Str(guid)
; Converts GUID to string
; ==============================================================================
; ==============================================================================

GUID2Str(guid)
{
	out:=0
	DllCall("Ole32.dll\StringFromCLSID", "UPtr", guid, "UPtr*", out)
	return StrGet(out, "UTF-16")
}


; ==============================================================================
; ==============================================================================
; RECT GetClientRect(hwnd)
; Retrieves the client rectangle of a window as RECT object
; ==============================================================================
; ==============================================================================

GetClientRect(hwnd)
{
	VarSetCapacity(rc, RECT.SizeOf(), 0)
	DllCall("GetClientRect", "UInt", hwnd, "Ptr", &rc)
	return new Rect(&rc)
}

; ==============================================================================
; ==============================================================================
; NONCLIENTMETRICS GetNONCLIENTMETRICS()
; Retrieves the NONCLIENTMETRICS object
; ==============================================================================
; ==============================================================================

GetNONCLIENTMETRICS()
{
	VarSetCapacity(metrics,NONCLIENTMETRICS.SizeOf(),0)
	NumPut(NONCLIENTMETRICS.SizeOf(),metrics,0,"UInt")
	ret:=DllCall("SystemParametersInfo", "UInt", 0x29, "UInt", NONCLIENTMETRICS.SizeOf(), "Ptr", &metrics, "UInt", 0, "Int") ; SPI_GETNONCLIENTMETRICS
	If (ret)
		return new NONCLIENTMETRICS(&metrics)
	else
		return 0
}

; ==============================================================================
; ==============================================================================
; Variable GetVariantData(p, flag=1)
; Retrieves contents of a Variant
; ==============================================================================
; ==============================================================================

GetVariantData(p, flag=1) 
{
	return, ComObject(0x400C, p+0, flag)[]
}


; ==============================================================================
; ==============================================================================
; class BaseComClass
; Basic definitions to wrap an IUnknown COM object
; ==============================================================================
; ==============================================================================

class BaseComClass
{
	__New(p="") 
	{
		this.Ptr:=p
	}
	
	vt(Index)
	{
		
		return NumGet(NumGet(this.Ptr+0,"Ptr"), Index*A_PtrSize, "Ptr")
	}
	
}


; ==============================================================================
; ==============================================================================
; class RECT
; RECT structure definition
; ==============================================================================
; ==============================================================================

class RECT extends BaseStruct
{
	GetFromStruct(p)
	{
		this.x := NumGet(p+0, "Int")
		this.y := NumGet(p+4, "Int")
		this.w := NumGet(p+8, "Int")
		this.h := NumGet(p+12, "Int")
		return, 1
	}
	
	SizeOf()
	{
		return 16
	}
}	


; ==============================================================================
; ==============================================================================
; class NONCLIENTMETRICS
; NONCLIENTMETRICS structure definition
; ==============================================================================
; ==============================================================================

class NONCLIENTMETRICS extends BaseStruct
{
	GetFromStruct(p)
	{
		this.cbSize:=Numget(p+0,"UInt")
		this.iBorderWidth:=Numget(p+4,"Int")
		this.iScrollWidth:=Numget(p+8,"Int")
		this.iScrollHeight:=Numget(p+12,"Int")
		this.iCaptionWidth:=Numget(p+16,"Int")
		this.iCaptionHeight:=Numget(p+20,"Int")
		this.lfCaptionFont:=new LOGFONT(p+24)
		this.iSmCaptionWidth:=Numget(p+24+LOGFONT.SizeOf(),"Int")
		this.iSmCaptionHeight:=Numget(p+28+LOGFONT.SizeOf(),"Int")
		this.lfSmCaptionFont:=new LOGFONT(p+32+LOGFONT.SizeOf())
		this.iMenuWidth:=Numget(p+32+2*LOGFONT.SizeOf(),"Int")
		this.iMenuHeight:=Numget(p+36+2*LOGFONT.SizeOf(),"Int")
		this.lfMenuFont:=new LOGFONT(p+40+2*LOGFONT.SizeOf())
		this.lfStatusFont:=new LOGFONT(p+40+3*LOGFONT.SizeOf())
		this.lfMessageFont:=new LOGFONT(p+40+4*LOGFONT.SizeOf())
		this.iPaddedBorderWidth:=Numget(p+40+5*LOGFONT.SizeOf(),"Int")
		return, 1
	}	
	
	SizeOf()
	{
		return 44+5*LOGFONT.SizeOf()
	}
}


; ==============================================================================
; ==============================================================================
; class LOGFONT
; LOGFONT structure definition
; ==============================================================================
; ==============================================================================

class LOGFONT extends BaseStruct
{
	GetFromStruct(p)
	{
		this.lfHeight:=Numget(p+0,"Int")
		this.lfWidth:=Numget(p+4,"Int")
		this.lfEscapement:=Numget(p+8,"Int")
		this.lfOrientation:=Numget(p+12,"Int")
		this.lfWeight:=Numget(p+16,"Int")
		this.lfItalic:=Numget(p+20,"UChar")
		this.lfUnderline:=Numget(p+21,"UChar")
		this.lfStrikeOut:=Numget(p+22,"UChar")
		this.lfCharSet:=Numget(p+23,"UChar")
		this.lfOutPrecision:=Numget(p+24,"UChar")
		this.lfClipPrecision:=Numget(p+25,"UChar")
		this.lfQuality:=Numget(p+26,"UChar")
		this.lfPitchAndFamily:=Numget(p+27,"UChar")
		this.lfFaceName:=""
		this.lfFaceName.=DllCall("MulDiv", "Int", p+28, "Int", 1, "Int", 1, "Str") ; Chr(Numget(p+28+(A_Index-1)*(A_IsUnicode ? 2 : 1), A_IsUnicode ? "UShort" : "UChar"))
		return, 1
	}	
	
	SizeOf()
	{
		return 28+32*(A_IsUnicode ? 2 : 1)
	}
}

; ==============================================================================
; ==============================================================================
; class BaseStruct
; Basic definitions to wrap a structure pointer
; ==============================================================================
; ==============================================================================

class BaseStruct
{
	__New(p=0)
	{
		If (!p)
		{
			VarSetCapacity(p,this.SizeOf(),0)
		}
		this.__Ptr:=p
		If (!this.GetFromStruct(p))
			return, 0
	}
	
	GetFromStruct(p)
	{
		throw "Abstract method GetFromStruct not implemented in " this.__Class
		return 0
	}
	
	UpdateStruct(p=0)
	{
		throw "Abstract method UpdateStruct not implemented in " this.__Class
		return 0
	}
	
	SizeOf()
	{
		throw "Abstract method GetSizeOf not implemented in " this.__Class
		return 0
	}
	
}
