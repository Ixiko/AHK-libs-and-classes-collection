/*		Example Code
VarSetCapacity(GdiplusStartupInput,3*A_PtrSize,0),NumPut(1,GdiplusStartupInput ,0,"UInt")
GdiplusStartup(getvar(token:=0), &GdiplusStartupInput, 0)

k:=GuiCreate()
f:=showGif(k.hwnd,"D:\float\Synch\Picture\92e8647agy1fcmebv0skdg20aw0cdx6q.gif")
k.show("w" f.width " h" f.height)
MsgBox "destroy gif"
f:=""
return
*/

showGif(hwnd,img:="",w:="",h:="",x:=0,y:=0){
	if A_EventInfo
	{
		KillTimer(0,w)
		if isobject((this:=object(A_EventInfo))) and isobject(this.gui)
		{
			t:=ahktime(),GdipImageSelectActiveFrame(this.pBitmap,this.ad,id:=this.id++)
			,GdipDrawImageRectRectI(this.G,this.pBitmap,0,0,this.width,this.height,0,0,this.gifWidth,this.gifHeight,2)
			,UpdateLayeredWindow(this.hwnd,0,this.pt[],getvar(temp1:=this.width|this.height<<32),this.hdc, getvar(temp2:=0),0,getvar(temp3:=255<<16|1<<24),2)
			,this.st:=SetTimer_(0,0,Abs(this.delay[id]- (ahktime(t)*1000)),this.rc)
			if this.id=this.count
				this.id:=0

		}
	} else if isobject(hwnd)
	{
		f:=hwnd,KillTimer(0,f.st),(f.delete("gui").Destroy())
		GlobalFree(f.rc),SelectObject(f.hdc, f.obm)
		DeleteObject(f.hbm),DeleteDC(f.hdc),GdipDeleteGraphics(f.G),GdipDisposeImage(f.pBitmap)
	}
	else
	{
		this:={gui:gui:=GuiCreate("+E0x80000 +Parent" hwnd),id:1,x:x,y:y,Base:{__Delete: Func("showGif")},pt:pt:=Struct("x,y"),hwnd:gui.hwnd},gui.show("x" x " y" y)
		GdipCreateBitmapFromFile(&img,getvar(pBitmap:=0))
		GdipGetImageDimension(pBitmap,__w:=getvar(width:=0), __h:=getvar(height:=0))
		this.gifwidth:=width:=NumGet(__w,"Float"),this.gifheight:=height:=NumGet(__h,"Float")
		this.width:=w?w:width,this.height:=h?h:height,VarSetCapacity(bi, 40, 0)
		,NumPut(this.width,bi,4),NumPut(this.height,bi,8),NumPut(40, bi, 0),NumPut(1,bi,12,"ushort"),NumPut(0, bi, 16),NumPut(32, bi, 14, "ushort")
		this.hbm:=hbm := CreateDIBSection( hdc:=GetDC(), &bi),ReleaseDC(0,hdc)
		this.hdc:=hdc := CreateCompatibleDC(),this.obm :=obm := SelectObject(hdc, hbm)
		GdipCreateFromHDC(hdc,getvar(G:=0)),GdipSetInterpolationMode(this.G:=G, 7)
		GdipImageGetFrameDimensionsCount(pBitmap,getvar(frameDimensions:=0))
		this.SetCapacity("dimensionIDs", 32)
		GdipImageGetFrameDimensionsList(pBitmap,this.ad:=this.GetAddress("dimensionIDs"), frameDimensions)
		GdipImageGetFrameCount(pBitmap,this.ad,getvar(count:=0))
		this.pBitmap:=pBitmap,this.count:=count,this.hdc:=hdc
		GdipGetPropertyItemSize(pBitmap, 0x5100, getvar(ItemSize:=0))
		VarSetCapacity(Item, ItemSize,0)
		GdipGetPropertyItem(pBitmap,0x5100, ItemSize, &Item)
		PropLen := NumGet(Item, 4,"UInt"),PropVal := NumGet(Item, 8 + A_PtrSize, "UPtr")
		this.delay :=r := [],pt.x:=this.x,pt.y:=this.y
		Loop PropLen//4
			r[A_Index-1] := (n := NumGet(PropVal+0, (A_Index-1)*4, "UInt"))?n * 10:100
		GdipImageSelectActiveFrame(pBitmap,this.ad,0)
		GdipDrawImageRectRectI(G,pBitmap,0,0,this.width,this.height,0,0,width,height,2)
		UpdateLayeredWindow(this.hwnd,0,pt[],getvar(temp1:=this.width|this.height<<32),this.hdc, getvar(temp2:=0),0,getvar(temp3:=255<<16|1<<24),2)
		this.rc		:=	RegisterCallback("showGif","F",4,&this)
		this.st		:=	SetTimer_(0,0,Abs(this.delay[0]),this.rc)
		return this
	}
}


ahkTime(s:=0,i:=6){
	static r:=(DllCall("QueryPerformanceFrequency",Int64P,r),r)
	DllCall("QueryPerformanceCounter",Int64P,n)
	if !i
	{
		p:=s/1000*r,n2:=n,c:=A_IsCritical,Critical("on")
		if s>15
			sleep(((s-5)//15)*15)
		while ((n2-n)<p)
			DllCall("QueryPerformanceCounter", "Int64P", n2)
		Return (Critical("c"),Round((n2-n)/r, 6))
	}
	Return (s ? Round((n-s)/r, i) : n)
}