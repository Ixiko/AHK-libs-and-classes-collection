loadfromfile(filename){
	global loadedimg
	if(!loadedimg[filename]){
		tmp:=gdip_createbitmapfromfile(filename)
		gdip_getimagedimensions(tmp,w,h)
		tmp2:=gdip_createbitmap(w,h)
		g:=gdip_graphicsfromimage(tmp2)
		gdip_drawimage(g,tmp,0,0,w,h,0,0,w,h)
		gdip_deletegraphics(g)
		gdip_disposeimage(tmp)
		loadedimg[filename]:=tmp2
	}
	return loadedimg[filename]
}

loadimage(num){
	global loadedimg
	if(!loadedimg[num]){
		loadedimg[num]:=loadimage2(num)
	}
	return loadedimg[num]
}

loadimage2(num){
	getpng(i,num)
	dllcall("Crypt32\CryptStringToBinary",ptr,&i,uint,0,uint,1,ptr,0,uintp,nsize,ptr,0,ptr,0)
	varsetcapacity(buffer,nsize,0)
	dllcall("Crypt32\CryptStringToBinary",ptr,&i,uint,0,uint,1,ptr,&buffer,uintp,nsize,ptr,0,ptr,0)
	hdata:=dllcall("GlobalAlloc",uint,2,uint,nsize)
	dllcall("RtlMoveMemory",uint,dllcall("GlobalLock",uint,hdata),uint,&buffer,uint,nsize)
	dllcall("GlobalUnlock",uint,hdata)
	dllcall("ole32\CreateStreamOnHGlobal",uint,hdata,int,1,uintp,pstream)
	dllcall("gdiplus\GdipCreateBitmapFromStream",uint,pstream,uintp,pbitmap)
	return pbitmap
}

#include ..\Build\sprites.ahk