GetGUIThreadInfo(retVal:="", idThread:=0)  {                                                                            	;-- calls the GetGUIThreadInfo function

	/* 			‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹‹›‹›‹‹›‹›‹›‹›‹›‹›‹›
																 CAPTURE MOUSE- AND KEYBOARD FOCUS
					‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹‹›‹›‹‹›‹›‹›‹›‹›‹›‹›

						Get information about the current mouse or keyboard focus in the foreground or a selected window thread.
						The function is based on the previous ♻ work 👷 of possibly Thalon and Philo.
						(see here: ➩ https://www.autohotkey.com/board/topic/952-controlgetfocus-disables-doubleclick/page-2).
						The function takes all information from the guiThreadInfo struct and transfers it into an autohotkey object.


						edited by:          	IXIKO
						licence:              	feel free to use
						last modified on: 	27.11.2021
					‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹›‹‹›‹›‹‹›‹›‹›‹›‹›‹›‹›


					       				━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
					       				📖 typedef struct tag GUITHREADINFO {
					       				━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

			link:              	➩ https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-guithreadinfo

			offset typedef    ahk   struct                           description
			───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
				  0 DWORD [UInt] cbSize;                       	The size of this structure, in bytes. The caller must set this member to sizeof(GUITHREADINFO).
				  4 DWORD [UInt] flags;                        	The thread state. This member can be one or more of the following values.

																					Value										Meaning
																					──────────────────────────────────────────────────────────────────────
																					GUI_CARETBLINKING				The caret's blink state. This bit is set if the
																					0x00000001								caret is visible.

																					GUI_INMENUMODE					The thread's menu state. This bit is set if the
																					0x00000004                           	thread is in menu mode.

																					GUI_INMOVESIZE						The thread's move state. This bit is set if the
																					0x00000002                           	thread is in a move or size loop.

																					GUI_POPUPMENUMODE			The thread's pop-up menu state. This bit is
																					0x00000010                            	set if the thread has an active pop-up menu.

																					GUI_SYSTEMMENUMODE			The thread's system menu state. This bit is set
																					0x00000008                           	if the thread is in a system menu mode.

				  8 HWND [Ptr]  	hwndActive;             		A handle to the active window within the thread.handle of active window
				16 HWND [Ptr]  	hwndFocus;                  	A handle to the window that has the keyboard focus.
				24 HWND [Ptr]  	hwndCapture;            	A handle to the window that has captured the mouse.
				32 HWND [Ptr]  	hwndMenuOwner;     	A handle to the window that owns any active menus.
				40 HWND [Ptr]  	hwndMoveSize;           	A handle to the window in a move or size loop.
				48 HWND [Ptr]  	hwndCaret;               	A handle to the window that is displaying the caret.
				56 RECT    [    ]  	rcCaret;                     	The caret's bounding rectangle, in client coordinates, relative to the window
																				specified by the hwndCaret member.
				72 bit structsize (ahk 64bit)

			} GUITHREADINFO, *PGUITHREADINFO, *LPGUITHREADINFO;


								━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
								📖 GetGuiThreadInfo(idThread, PGUITHREADINFO)
								━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

		link:              	➩ https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getguithreadinfo

		parameter: 		idThread (Type: DWORD)
								The identifier for the thread for which information is to be retrieved. To retrieve this value,
								use the GetWindowThreadProcessId function. If this parameter is NULL, the function returns
								information for the foreground thread.

								PGUITHREADINFO pgui (Type: LPGUITHREADINFO)
								A pointer to a GUITHREADINFO structure that receives information describing the thread.
								Note that you must set the cbSize member to sizeof(GUITHREADINFO) before calling this function.

		return value:		Type: BOOL
								If the function succeeds, the return value is nonzero.
								If the function fails, the return value is zero. To get extended error information, call GetLastError.

		‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗

		                        ╔═════════════════════════════════════════════════════════╗
		   	         📖 ═══╣   Description of GetGuiThreadInfo(idThread := 0, retVal := "")    ╠════ 📖
		                        ╚═════════════════════════════════════════════════════════╝

		parameter: 		idThread (integer)
								Leave zero if you want to get informations about the active windowthread, otherwise
								specifies the id of the guiThread whose information you need.

								retVal (string)
								Leave it empty if you want to get all information from the window thread. Otherwise
								pass the name of a member of the guiThreadInfo structure. This way the function
								can be used in IF queries without detours. Like here:

									hFocus := GetGuiThreadInfo("hFocus")
									While (GetGUIThreadInfo("hFocus") = hFocus)
										sleep 50
									MsgBox, The input focus has been removed!

		return values:	returns an object containing all informations from the guiThreadInfo struct or if
								retVal is a valid member name of the guiThreadInfo struct it will return only the
								value of the member.
								For better usability the returned object contains a list of thread states which are
								hidden in the member flags. In this list each item except the last is terminated by
								a linefeed (`n). Change the linefeed here in the function to get an otherwise
								separated list.


	 */

		static guiThreadInfoSize:=8+(A_PtrSize*6)+16, hwndCaret:=8+A_PtrSize*5
		static gTIflags := {	"0x1":"GUI_CARETBLINKING", "0x2":"GUI_INMOVESIZE", "0x4":"GUI_INMENUMODE"
								, 	"0x8":"GUI_SYSTEMMENUMODE", "0x10":"GUI_POPUPMENUMODE"}

   ; This script requires Windows 98+ or NT 4.0 SP3+.
    	VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
    	NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)

		 ;~ vTID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")

		DllCall("RtlFillMemory", "PTR", addr, "PTR", 1, "UChar", guiThreadInfoSize)	        	; Below 0xFF, one call only is needed
    	if (DllCall("GetGUIThreadInfo", "UInt", idThread, "PTR", &guiThreadInfo) = 0) {   	; Foreground thread if idThread is zero
			ErrorLevel := A_LastError   ; Failure
			Return 0
    	}

		gti := {	"flags"           	: Format("0x{:X}", NumGet(guiThreadInfo,   4, "Uint"))
				,	"hActive"          	: Format("0x{:X}", NumGet(guiThreadInfo,   8, "Ptr"))
				,	"hFocus"          	: Format("0x{:X}", NumGet(guiThreadInfo, 16, "Ptr"))
				,	"hCapture"     	: Format("0x{:X}", NumGet(guiThreadInfo, 24, "Ptr"))
				,	"hMenuOwner" 	: Format("0x{:X}", NumGet(guiThreadInfo, 32, "Ptr"))
				,	"hMoveSize"     	: Format("0x{:X}", NumGet(guiThreadInfo, 40, "Ptr"))
				,	"hCaret"          	: Format("0x{:X}", NumGet(guiThreadInfo, 48, "Ptr"))
				,	"CaretX"          	: NumGet(guiThreadInfo, 56, "Int")
				,	"CaretY"          	: NumGet(guiThreadInfo, 60, "Int")
				,	"CaretW"          	: NumGet(guiThreadInfo, 64, "Int")
				,	"CaretH"          	: NumGet(guiThreadInfo, 68, "Int")}

		gti.CaretW := gti.CaretW 	- gti.CaretX
		gti.CaretH := gti.CaretH 	- gti.CaretY

		hit := 0
		For hexState, state in gTIflags
			If (hexState & git.flags)
				gti.states := gti.states ((hit++) > 1 ? "`n" : "") state

Return retVal && gti.haskey(retVal) ? gti[retVal] : gti
}
