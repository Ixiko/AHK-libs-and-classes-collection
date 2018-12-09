class hIconFromhBitmap extends LoadPictureType{
	__new(hBitmap, bkColor:=0x000000,deleteSourceHBITMAP:=false){
		this.hImg:=hBitmap
		bkColor:=this.rgbToBgr(bkColor)
		this.deleteSourceHBITMAP:=deleteSourceHBITMAP
		this.makeIcon(bkColor)
		return this.getHandle()
	}
}
class hCursorFromhBitmap extends LoadPictureType{
	__new(hBitmap, bkColor:=0x000000, xHotspot:=0, yHotspot:=0,deleteSourceHBITMAP:=false){
		this.hImg:=hBitmap
		bkColor:=this.rgbToBgr(bkColor, xHotspot, yHotspot)
		this.deleteSourceHBITMAP:=deleteSourceHBITMAP
		this.makeCursor(bkColor)
		return this.getHandle()
	}
}
#Include %A_ScriptDir%\class_LoadPictureType.ahk