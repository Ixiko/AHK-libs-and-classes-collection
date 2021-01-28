;

	/*    	DESCRIPTION of library GetColor
        	-------------------------------------------------------------------------------------------------------------------
			Description  	:	Take color And regional Take color
			Link              	:	https://autohotkey.com/boards/viewtopic.php?t=7451
			Author         	:	arcticir
			Date	            	:	17-May-2015
			AHK-Version	:	AHK-V1
			License         	:	
			Parameter(s)	:	
			Remark(s)    	:	
			Dependencies	:	
			KeyWords    	:	GDIP, Color, Cursor
        	-------------------------------------------------------------------------------------------------------------------
	*/



GetColor(x:="",y:="",w:=1,h:=1){ ;取色
    static pt
    pt?"":(DllCall("GetModuleHandle","str","gdiplus","UPtr"),VarSetCapacity(i,A_PtrSize=8?24:16,0),i:=Chr(1)
            ,DllCall("gdiplus\GdiplusStartup","UPtr*",pt,"UPtr",&i,"UPtr",0))
    ,(x="")?GetCursorPos(x,y):""
    ,d:=DllCall("CreateCompatibleDC","Uint",0),VarSetCapacity(b,40,0),NumPut(w,b,4,"uint")
    ,NumPut(h,b,8,"uint"),NumPut(40,b,0,"uint"),NumPut(1,b,12,"ushort"),NumPut(0,b,16,"uInt"),NumPut(32,b,14,"ushort")
    ,m:=DllCall("CreateDIBSection","UPtr",d,"UPtr",&b,"uint",0,"UPtr*",0,"UPtr",0,"uint",0,"UPtr")
    ,o:=DllCall("SelectObject","UPtr",d,"UPtr",m)
    ,DllCall("BitBlt","UPtr",d,"int",0,"int",0,"int",w,"int",h,"UPtr",i:=DllCall("GetDC","UPtr",0),"int",x,"int",y,"uint",0x00CC0020)
    ,DllCall("ReleaseDC","UPtr",0,"UPtr",i)
    ,DllCall("gdiplus\GdipCreateBitmapFromHBITMAP","UPtr",m,"UPtr",Palette,"UPtr*",p)
    ,DllCall("SelectObject","UPtr",d,"UPtr",o),DllCall("DeleteObject","UPtr",m)
    ,DllCall("DeleteDC","UPtr",i),DllCall("DeleteDC","UPtr",d),VarSetCapacity(t,16)
    ,NumPut(0,t,0,"uint"),NumPut(0,t,4,"uint"),NumPut(w,t,8,"uint"),NumPut(h,t,12,"uint")
    ,VarSetCapacity(b,16+2*A_PtrSize,0),DllCall("Gdiplus\GdipBitmapLockBits","UPtr",p,"UPtr",&t,"uint",3,"int",0x26200a,"UPtr",&b)
    ,e:= NumGet(b,8,"Int"),u:=NumGet(b,16,"UPtr"),r:=A_FormatInteger
    SetFormat,IntegerFast,hex
    if (w>1 or h>1)
    {
        f:=[]
        Loop,%h%
        {
            f[A_Index]:=j:=[],s:=(A_Index-1)*e
            Loop,%w%
                j[A_Index]:=NumGet(u+0,((A_Index-1)*4)+s,"UInt")  & 0x00ffffff ""
        }
    }
    else f:=NumGet(u+0,0,"UInt") & 0x00ffffff  ""
    SetFormat,IntegerFast,%r%
    DllCall("Gdiplus\GdipBitmapUnlockBits","UPtr",p,"UPtr",0)
    DllCall("gdiplus\GdipDisposeImage", "uint", p)
    return f
}

GetCursorPos(byref x,byref y){
	static i:=VarSetCapacity(i,8,0)
	DllCall("GetCursorPos","Ptr",&i),X:=NumGet(i,0,"Int"),y:=NumGet(i,4,"Int")
}