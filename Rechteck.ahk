SetBatchLines, -1
Process Priority,,high


wsize := 400
hsize := 400

ImageListID1 := DllCall("comctl32.dll\ImageList_Create",int,wsize,int,hsize,uint,0x00000018,int,250,int,128)
Loop 128 {
updown := A_Index
SetFormat,integer,hex
updown += 0 ,updn:= SubStr(("0" . SubStr(updown,3,2)),-1,2)
,Pcol:= SubStr((255 + -updown+(updown>64 ? 1 : 0)),3,2)
,R00 := Pcol . updn . updn
,RG0 := Pcol . Pcol . updn
,0G0 := updn . Pcol . updn
,0GB := updn . Pcol . Pcol
,00B := updn . updn . Pcol
,R0B := Pcol . updn . Pcol
SetFormat,integer,dez
Hbm := GET_HBITMAP_FROM_Array( 400 , 49
,Array(["ffffff","ffffff","ffffff","ffffff","ffffff","ffffff","ffffff"]
		 ,[R00 . "",RG0 . "",0G0 . "",0GB . "",00B . "",R0B . "",R00 . ""]
		 ,["000000","000000","000000","000000","000000","000000","000000"]))
DllCall("comctl32.dll\ImageList_Add",ptr,ImageListID1,ptr,DllCall("CopyImage",ptr,hBM,UInt,0,Int,wsize,Int,hsize,UInt,0x2008,UInt),uint,"")
}

Gui,2:+LastFound +HwndHWin2 +MinSize100x100 -0x400000 +0x40000 -0x80000 +0x02000000
Gui,2:Add, Picture,x0 y0 w%wsize% h%hsize% 0x120E hwndhStatic
hDC := DllCall( "GetDC", ptr,hStatic )
Gui,2:Show, x0 y0 w%wsize% h%hsize% , % " "
DllCall("ImageList_Draw",ptr,ImageListID1,Int,2,ptr,hDC,Int,0,Int,0,Int,0)

updown := 0
Loop {
updown += (GetKeyState( "up" ,"P") ? (1 + DllCall("Sleep",UInt,10)) : DllCall("Sleep",UInt,10))
,updown:=updown + (GetKeyState("down","P") ? ( -1 + DllCall("Sleep",UInt,10)) : DllCall("Sleep",UInt,10))
,updown:=(updown > 128 ? "128" : (updown < 0 ? "0" : updown))
if ((GetKeyState("down","P") || GetKeyState("up","P"))
? DllCall("ImageList_Draw",UInt,ImageListID1,Int,updown,UInt,hDC,Int,0,Int,0,Int,0)
: DllCall("Sleep",UInt,10)){
tooltip, % updown
}else
tooltip,
}
Return



GET_HBITMAP_FROM_Array(wt,ht,Array){
DllCall("SelectObject",ptr,tDC:=DllCall("CreateCompatibleDC",Int,0,UInt),ptr,tBM:=DllCall("CopyImage",ptr,DllCall("CreateBitmap"
,Int,Array[1].MaxIndex(),Int,Array.MaxIndex(),UInt,1,UInt,24,UInt,0),UInt,0,Int,0,Int,0,UInt,0x2008,UInt)),X:=Y:=0
Loop % Array.MaxIndex(){
Loop % Array[Index := A_Index].MaxIndex()
	 DllCall("SetPixel",ptr,tDC,Int,x,Int,y,UInt,DllCall("Ws2_32\ntohl",UInt,("0x" Array[Index,A_Index] "00"))),X:=((X+=1)>=Array[1].MaxIndex()&&(Y+=1))?0:X
}Return DllCall("CopyImage",ptr,tBM,UInt,0,Int,wt,Int,ht,UInt,0x2008,UInt),DllCall("DeleteDC",ptr,tDC)
}