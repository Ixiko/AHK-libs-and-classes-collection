; AutoHotkey Version: 1.0.47.06
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
; Last updated: 2008-12-12
; Copyright:	
;		You are allowed to include the source code in your own product(in any form) when 
;	your product is released in binary form.
;		You are allowed to copy/modify/distribute the code in any way you want except
;	you can NOT modify/remove the copyright details at the top of each script file.

#Include Utils\Kernel32.ahk
#Include Utils\User32.ahk

; typedef struct _TBBUTTON {
;     int iBitmap;					4 bytes
;     int idCommand;				4 bytes
;     BYTE fsState;				1 bytes
;     BYTE fsStyle;				1 bytes
; #ifdef _WIN64
;     BYTE bReserved[6];			6 bytes
; #elif defined(_WIN32)
;     BYTE bReserved[2];			2 bytes
; #endif
;     DWORD_PTR dwData;		4 bytes
;     INT_PTR iString;			4 bytes
; } TBBUTTON, NEAR* PTBBUTTON, *LPTBBUTTON;
; sizeof(TBBUTTON) = 20

sizeof_TBBUTTON := 20	; Do NOT modify this variable!

; ##################################################
; 	Easy2Visit the member of TBBUTTON structure
; ##################################################

_TB_iBitmap(ByRef tbb)
{
	return NumGet(tbb, 0, "Int")
}

_TB_idCommand(ByRef tbb)
{
	return NumGet(tbb, 4, "Int")
}

_TB_fsState(ByRef tbb)
{
	return NumGet(tbb, 8, "UChar")
}

_TB_fsStyle(ByRef tbb)
{
	return NumGet(tbb, 9, "UChar")
}

_TB_dwData(ByRef tbb)
{
	return NumGet(tbb, 12, "UInt")
}

_TB_iString(ByRef tbb)
{
	return NumGet(tbb, 16, "Int")
}

IsTBHidden(ByRef pTBBUTTON)
{
	Global
	return _TB_fsState(pTBBUTTON) & TBSTATE_HIDDEN
}

; ##################################################
; 	Simple wraper functions of some Toolbar messages
; ##################################################

MSG_GetToolbarButton( hToolbar, nButtonIndex, pButton )
{
	Global
	return SendMessage(hToolbar, TB_GETBUTTON, nButtonIndex, pButton)
}

MSG_DeleteToolbarButton( hToolbar, nButtonIndex )
{
	Global
	return SendMessage(hToolbar, TB_DELETEBUTTON, nButtonIndex, 0)
}

MSG_EnableToolbarButton(hToolbar, nButtonIndex, bEnable = true )
{
	Global
	return SendMessage(hToolbar, TB_ENABLEBUTTON, nButtonIndex, bEnable)
}

MSG_IsToolbarButtonEnabled( hToolbar, nButtonIndex )
{
	Global
	return SendMessage(hToolbar, TB_ISBUTTONENABLED, nButtonIndex, 0)
}

MSG_HideToolbarButton(hToolbar, nButtonIndex, bHide = true )
{
	Global
	return SendMessage(hToolbar, TB_HIDEBUTTON, nButtonIndex, bHide)
}

MSG_IsToolbarButtonHidden( hToolbar, nButtonIndex )
{
	Global
	return SendMessage(hToolbar, TB_ISBUTTONHIDDEN, nButtonIndex, 0)
}

MSG_GetToolbarButtonCount( hToolbar )
{
	Global
	return SendMessage(hToolbar, TB_BUTTONCOUNT, 0, 0)
}

MSG_PressToolbarButton(hToolbar, nButtonIndex, bPress = true )
{
	Global
	return SendMessage(hToolbar, TB_PRESSBUTTON, nButtonIndex, bPress)
}

MSG_MoveToolbarButton(hToolbar, nOldIndex, nNewIndex )
{
	Global
	return SendMessage(hToolbar, TB_MOVEBUTTON, nOldIndex, nNewIndex)
}

MSG_GetToolbarButtonText(hToolbar, nButtonIndex, pszText )
{
	Global
	return SendMessage(hToolbar, TB_GETBUTTONTEXT, nButtonIndex, pszText)
}

; ##################################################
; 	Implementations of the Wrapper
; ##################################################

; Create/Reset global variables
TW_ResetVariables( szToolbarName )
{
	Global
	%szToolbarName%_hToolbar					:= 0		; �������
	%szToolbarName%_hProcess					:= 0		; ����������̾�
	%szToolbarName%_nProcessId				:= -1		; �����������D
	%szToolbarName%_pLastAllocatedAddr	:= -1		; �һ����ռ�������
	%szToolbarName%_nLastAllocatedSize		:= -1		; �һ����ռ������}

; Release the memory of target process
TW_ReleaseResources( szToolbarName )
{
	Global
	if ( %szToolbarName%_hProcess )
	{
		if ( %szToolbarName%_pLastAllocatedAddr >= 0 && IsProcessExist( %szToolbarName%_nProcessId ) )
		{
			_FreeTBProcessMemory(szToolbarName)
		}
		CloseHandle( %szToolbarName%_hProcess )
	}
}

; Releases the resources and resets the related variables when needed
TW_Cleanup(szToolbarName)
{
	TW_ReleaseResources(szToolbarName)
	TW_ResetVariables(szToolbarName)
}

; Get the handle of target toolbar
; *** You MUST define a finder function named %szToolbarName%_FindToolbar ***
TW_GetToolbarHwnd( szToolbarName )
{
	Global
	if( %szToolbarName%_hToolbar && IsWindowExist( %szToolbarName%_hToolbar, "ToolbarWindow32" ) )
		return %szToolbarName%_hToolbar
		
	%szToolbarName%_hToolbar := %szToolbarName%_FindToolbar()
	return %szToolbarName%_hToolbar
}

; Get the ID of the process that created the Toolbar
TW_GetToolbarProcessId( szToolbarName )
{
	Global
	if ( %szToolbarName%_nProcessId > 0 )
	{
		; Check the process
		if( IsProcessExist(%szToolbarName%_nProcessId) )
			return %szToolbarName%_nProcessId
		else
		{
			TW_ResetVariables(szToolbarName)
			OutputDebug, % szToolbarName . " ToolbarProcess [" . %szToolbarName%_nProcessId . "] was not exist(terminated?)`, attempt to retrieve it now."
		}
	}
	
	if( !TW_GetToolbarHwnd(szToolbarName) )
	{
		OutputDebug, Failed to get the %szToolbarName% Toolbar
		return -1
	}
	
	%szToolbarName%_nProcessId := GetWindowProcessID( %szToolbarName%_hToolbar )
	if( %szToolbarName%_nProcessId > 0)
		OutputDebug, % szToolbarName . " ToolbarProcessId [" . %szToolbarName%_nProcessId . "] was updated!"
	else
		OutputDebug, Can't get the %szToolbarName% ProcessId from the Toolbar!
	return %szToolbarName%_nProcessId
}

; Get the handle of the process that created the Toolbar
TW_GetToolbarProcessHandle( szToolbarName )
{
	Global
	; Incase the process has exited, call TW_GetToolbarProcessId() to verify first
	if( TW_GetToolbarProcessId(szToolbarName) < 0 )
		return 0
	if ( %szToolbarName%_hProcess )
		return %szToolbarName%_hProcess
	%szToolbarName%_hProcess := OpenProcess( PROCESS_VM_OPERATION|PROCESS_VM_READ|PROCESS_VM_WRITE, 0, %szToolbarName%_nProcessId)
	if(%szToolbarName%_hProcess)
		OutputDebug, % "The handle of ". szToolbarName . " Process[" . %szToolbarName%_hProcess . "] was updated!"
	else
		OutputDebug, Can't open the %szToolbarName% Process!
	return %szToolbarName%_hProcess
}

; Get/Allocate specify size of memory from the process that created the toolbar
; ��oolbar������л�������ڴ棬�����������ڴ��������������������
TW_GetToolbarProcessMemory( szToolbarName, nSize )
{
	Global
	if ( TW_GetToolbarProcessHandle(szToolbarName) )
	{
		if ( nSize > %szToolbarName%_nLastAllocatedSize )	; we need to realloc a new memory
		{
			if ( %szToolbarName%_pLastAllocatedAddr >= 0 )
				_FreeTBProcessMemory(szToolbarName)
			%szToolbarName%_pLastAllocatedAddr := _AllocTBProcessMemory(szToolbarName, nSize)
			if ( %szToolbarName%_pLastAllocatedAddr >= 0 )
				%szToolbarName%_nLastAllocatedSize := nSize
			else
				%szToolbarName%_nLastAllocatedSize := 0
		}
		return %szToolbarName%_pLastAllocatedAddr
	}
	return 0
}

; Read data from specified area in toolbar Process and write to pBuffer
; the base address would be LastAllocatedAddr when pBaseAddress = -1
TW_ReadToolbarProcessMemory( szToolbarName, ByRef pBuffer, nSize, pBaseAddress = -1)
{
	Global
	Local nNumberOfBytesRead := 0

	if( !nSize )
		return -1
	if( pBaseAddress < 0 )
	{
		pBaseAddress := %szToolbarName%_pLastAllocatedAddr
	}
	if( !TW_GetToolbarProcessHandle(szToolbarName) ||  pBaseAddress < 0 )
		return -2
		
	VarSetCapacity(pBuffer, nSize, 0)
	
	ReadProcessMemory( %szToolbarName%_hProcess, pBaseAddress, &pBuffer, nSize, &nNumberOfBytesRead)
	nNumberOfBytesRead := NumGet(nNumberOfBytesRead)
			
	return nNumberOfBytesRead
}

TW_GetToolbarButton( szToolbarName, nIndex, ByRef pTBBUTTON )
{
	Global
	if ( TW_GetToolbarProcessMemory( szToolbarName, sizeof_TBBUTTON ) )
	{
		if( MSG_GetToolbarButton(TW_GetToolbarHwnd(szToolbarName), nIndex, %szToolbarName%_pLastAllocatedAddr) )
		{
			return sizeof_TBBUTTON = TW_ReadToolbarProcessMemory( szToolbarName, pTBBUTTON, sizeof_TBBUTTON )
		}
	}
	return false
}

TW_GetToolbarButtonCount(szToolbarName)
{
	return MSG_GetToolbarButtonCount( TW_GetToolbarHwnd(szToolbarName) )
}

TW_GetVisibleToolbarButtonCount(szToolbarName)
{
	nButtonCount := TW_GetToolbarButtonCount(szToolbarName)
	nVisibleBtnCount := 0
	Loop, % nButtonCount
	{
		if ( TW_GetToolbarButton( szToolbarName, A_Index-1, tbb) )
		{
			if( !IsTBHidden(tbb) )
				++nVisibleBtnCount
		}
	}
	return nVisibleBtnCount
}

TW_MoveToolbarButton( szToolbarName, nOldIndex, nNewIndex )
{
	MSG_MoveToolbarButton(TW_GetToolbarHwnd(szToolbarName), nOldIndex, nNewIndex )
}

TW_GetToolbarButtonText( szToolbarName, nIndex, ByRef pszText )
{
	Global
	Local nRequiredSize := MSG_GetToolbarButtonText(TW_GetToolbarHwnd(szToolbarName), nIndex, 0)+1
	if ( nRequiredSize )
	{
		if( TW_GetToolbarProcessMemory( szToolbarName,  nRequiredSize) )
		{
			if( MSG_GetToolbarButtonText(TW_GetToolbarHwnd(szToolbarName), nIndex, %szToolbarName%_pLastAllocatedAddr) )
			{
				Return TW_ReadToolbarProcessMemory( szToolbarName, pszText, nRequiredSize )
			}
		}
	}
	return false
}

; ##################################################
; 	Simple wraper functions of some APIs
; ##################################################

_AllocTBProcessMemory( szToolbarName, nSize )
{
	Global
	pBaseAddress := VirtualAllocEx( %szToolbarName%_hProcess, 0, nSize, MEM_COMMIT|MEM_RESERVE, PAGE_READWRITE)
	if(pBaseAddress)
		OutputDebug, New memory space was allocated at %pBaseAddress%, size = %nSize%
	else
		OutputDebug, Failed to allocate memory!
	return pBaseAddress
}

_FreeTBProcessMemory( szToolbarName )
{
	Global
	bRtn := VirtualFreeEx( %szToolbarName%_hProcess, %szToolbarName%_pLastAllocatedAddr, 0, MEM_RELEASE)
	if(bRtn)
		OutputDebug, % "Memory space was released at " . %szToolbarName%_pLastAllocatedAddr
	else
		OutputDebug, Failed to free memory!
	return bRtn
}