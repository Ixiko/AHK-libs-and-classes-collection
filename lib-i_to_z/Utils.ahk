; AutoHotkey Version: 1.0.47.06
; Language:       Chinese/English
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
; Last updated: 2008-12-11
; Copyright:	
;		You are allowed to include the source code in your own product(in any form) when 
;	your product is released in binary form.
;		You are allowed to copy/modify/distribute the code in any way you want except
;	you can NOT modify/remove the copyright details at the top of each script file.

#Include Utils\Kernel32.ahk
#Include Utils\User32.ahk
;#Include Utils\Gdi32.ahk

; ##################################################
; 	Helper functions in common use
; ##################################################

; Open the process of the target window
; 获得目标窗口所属进程句柄
OpenWindowProcess(dwDesiredAccess, bInheritHandle, hWnd)
{
	nPID := 0
	GetWindowThreadProcessId(hWnd, &nPID)
	nPID := NumGet(nPID) 
	if (nPID)
		return OpenProcess(dwDesiredAccess, bInheritHandle, nPID)
	return 0
}

GetWindowHICON( hWnd )
{
	Global
	Local hIcon := 0
	hIcon := SendMessage( hWnd, WM_GETICON, ICON_SMALL2, 0)
	if( hIcon = 0)
		hIcon := GetClassLong( hWnd, GCL_HICONSM )
	if( hIcon = 0)
		hIcon := GetClassLong( hWnd, GCL_HICON )
	return hIcon
}

GetWindowProcessID( hWnd )
{
	VarSetCapacity(nProcessId, 4, 0)
	NumPut(-1, nProcessId)
	GetWindowThreadProcessId(hWnd, &nProcessId)
	nProcessId := NumGet(nProcessId) 
	return nProcessId
}

IsProcessExist(nPID)
{
	Process, Exist, % nPID
	return ErrorLevel = nPID
}

IsWindowExist( hWnd, szClassName = 0, szWindowName = 0)
{
	Criterion := "ahk_id " . hWnd
	if( szClassName != 0)
		Criterion .= " ahk_class " . szClassName
	if( szWindowName != 0)
		Criterion := szWindowName . " " . Criterion
	return WinExist( Criterion )
}

TransformWideCharToMultiByte(pWideChar, nWideCharNumber)
{
	Global
	Local nRequiredSize := WideCharToMultiByte(CP_ACP, 0, pWideChar, nWideCharNumber, 0, 0, 0, 0)
	if(nRequiredSize)
	{
		Local pMultiByteBuffer
		VarSetCapacity( pMultiByteBuffer, nRequiredSize, 0 )
		Local nBytesWritten := WideCharToMultiByte(CP_ACP, 0, pWideChar, nWideCharNumber, &pMultiByteBuffer, nRequiredSize, 0, 0)
		return pMultiByteBuffer
	}
	return 0
}

TransformMultiByteToWideChar(pMultiByte, ByRef pWideCharBuffer)
{
	Global
	Local nRequiredSize := MultiByteToWideChar(CP_ACP, 0, pMultiByte, -1, 0, 0)
	if(nRequiredSize)
	{
		VarSetCapacity( pWideCharBuffer, nRequiredSize, 0 )
		Local nBytesWritten := MultiByteToWideChar(CP_ACP, 0, pMultiByte, -1, &pWideCharBuffer, nRequiredSize)
		return nBytesWritten
	}
	return -1
}

SizeOfType(TypeName)
{
	if TypeName in Char,UChar
		return 1
	if TypeName in Short,UShort
		return 2
	if TypeName in Int,UInt,Float
		return 4
	if TypeName in Int64,Double
		return 8
}

CopyVar(ByRef dest, ByRef source, nSize, UnitType = "UInt" )
{
	loop, % nSize
	{
		nOffset := (A_Index-1) * SizeOfType(UnitType)
		tmp := NumGet(source, nOffset, UnitType) 
		NumPut( tmp, dest, nOffset, UnitType)
	}
}