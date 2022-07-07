/*
	AHK-HOOK-API
	
	MIT License

	Copyright (c) 2018 Rinat_Namazov

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

; WinApi defines.
global PAGE_EXECUTE_READWRITE := 0x40

; WinApi functions.
GetProcAddress(hModule, lpProcName)
{
	return DllCall("kernel32.dll\GetProcAddress", "UInt", hModule, "AStr", lpProcName)
}

GetModuleHandle(lpModuleName)
{
	return DllCall("kernel32.dll\GetModuleHandle", "Str", lpModuleName)
}

VirtualProtect(lpAddress, dwSize, flNewProtect, ByRef lpflOldProtect)
{
	return DllCall("VirtualProtect", "Ptr", lpAddress, "UInt", dwSize, "UInt", flNewProtect, "UInt *", lpflOldProtect)
}

CreateThread(lpThreadAttributes, dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId)
{
	return DllCall("CreateThread", "UInt", lpThreadAttributes, "UInt", dwStackSize, "Ptr", lpStartAddress, "UInt", lpParameter, "UInt", dwCreationFlags, "UInt", lpThreadId, "UInt")
}

memcpy(destptr, srcptr, num)
{
	return DllCall("msvcrt\memcpy", "Ptr", destptr, "Ptr", srcptr, "UInt", num, "CDecl Ptr")
}

class Hook
{
	static SIZE := 6
		, ProcAddr := 0, OldBytesAddr = 0, JMPAddr := 0
	
	__New(ModuleName, ProcAddrOrName, NewProcAddr, CallBackOptions := "")
	{
		if ProcAddrOrName is not integer ; Если это не адрес, а название функции.
			this.ProcAddr := GetProcAddress(GetModuleHandle(ModuleName), ProcAddrOrName) ; Получаем адрес функции.
		else
			this.ProcAddr := GetModuleHandle(ModuleName) + ProcAddrOrName
		if NewProcAddr is not integer ; Если это не адрес, а название ахк функции.
			NewProcAddr := RegisterCallback(NewProcAddr, CallBackOptions) ; Регистрируем функцию.
		if (!this.ProcAddr || !NewProcAddr) ; Если адреса неверные.
			return false
		VirtualProtect(this.ProcAddr, this.SIZE, PAGE_EXECUTE_READWRITE, oldProtect) ; Получаем доступ к памяти.
		VarSetCapacity(OldBytes, 6, 0) ; Выделяем память на оригинальные байты.
		this.OldBytesAddr := &OldBytes + 1
		memcpy(this.OldBytesAddr, this.ProcAddr, this.SIZE) ; Запоминаем оригинальные байты.
		JMPSize := NewProcAddr - this.ProcAddr - 5 ; Вычисляем смещение относительно оригинальной функции.
		VarSetCapacity(JMP, 6, 0) ; Выделяем память на команду перехода.
		this.JMPAddr := &JMP + 1
		NumPut(0xE9, this.JMPAddr, 0, "UChar")		; jmp
		NumPut(JMPSize, this.JMPAddr, 1, "UInt")	; addr
		NumPut(0xC3, this.JMPAddr, 5, "UChar")		; ret
		memcpy(this.ProcAddr, this.JMPAddr, this.SIZE) ; Записываем прыжок.
		VirtualProtect(this.ProcAddr, this.SIZE, oldProtect, 0) ; Восстанавливаем старые права доступа.
		return this
	}
	
	__Delete()
	{
		this.SetStatus(false)
	}
	
	SetStatus(status)
	{
		VirtualProtect(this.ProcAddr, this.SIZE, PAGE_EXECUTE_READWRITE, oldProtect) ; Получаем доступ к памяти.
		if (status)
			memcpy(this.ProcAddr, this.JMPAddr, this.SIZE) ; Ставим хук.
		else if (!status)
			memcpy(this.ProcAddr, this.OldBytesAddr, this.SIZE) ; Убираем хук.
		VirtualProtect(this.ProcAddr, this.SIZE, oldProtect, 0) ; Восстанавливаем старые права доступа.
	}
}