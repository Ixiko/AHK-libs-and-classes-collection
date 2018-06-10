/*
Name          : Standard functions, can also be shared by bundle scripts by including LLInit() in your bundle script
Version       : 1.0
Date          : 20101010
Functions     :
	- LLInit()
	- GetActiveWindowStats()
	- Sendkey()
	- ClipSet() mod of virclip by Learning one http://www.autohotkey.com/forum/topic56926.html
*/

GetActiveWindowStats() ; Get Active Window & Control
	{
	 global
	 WinGet, ActiveWindowID, ID, A
	 WinGet, ActiveWindowProcessName, ProcessName, A ; TODO TODOMC
	 WinGetClass, ActiveWindowClass, A
	 ControlGetFocus, ActiveControl, A
	 WinGetActiveTitle, ActiveWindowTitle
	 StringReplace, ActiveWindowTitle, ActiveWindowTitle, [, , All
	 StringReplace, ActiveWindowTitle, ActiveWindowTitle, ], , All
	 
	 ; we can use this in our bundles to make sure we have 
	 ; the default functions available to our scripts defined in the bundle
	 
	 LLInit= ; pass on basic data + functions to script from snippet
	 (
	  
		ActiveWindowID=%ActiveWindowID%
		ActiveWindowClass=%ActiveWindowClass%
		ActiveControl=%ActiveControl%
		ActiveWindowTitle=%ActiveWindowTitle%
		PasteDelay=%PasteDelay%
		SendMethod=%SendMethod%
		#include %A_ScriptDir%\include\default.ahk  	  
	  
	 )
	}

LLInit() ; Fake function call -> If you use this in a snippet script Lintalist will replace this with the variables above from LLInit.
	{
	;
	}


SendKey(Method = 1, Keys = "")
	{
	 ; Method: 1 = SendInput
	 ; Method: 2 = SendEvent
	 ; Method: 3 = SendPlay
	 ; Method: 4 = ControlSend
 
 global PasteDelay
 Sleep, % PasteDelay
 
;	 If ((Save = 1) or (Save = ""))
;		ClipSet("s",1) ; safe current content and clear clipboard
;		ClearClipboard()

	 If (Method = 1)
		{ 
		 WinActivate ahk_id %ActiveWindowID%
		 SendInput %keys%
		}
	 Else If (Method = 2)
		{ 
		 WinActivate ahk_id %ActiveWindowID%
		 SendEvent %keys%
		}
	 Else If (Method = 3)
		{ 
		 WinActivate ahk_id %ActiveWindowID%
		 SendPlay %keys%
		}
	 Else If (Method = 4)
		{ 
		 WinActivate ahk_id %ActiveWindowID%
		 ControlSend, %ActiveControl%, %keys%, ahk_id %ActiveWindowID%
		}

	 Sleep 50 ; some time to get data to clipboard
	 
;	 If (Restore = 1)
;		 Clipboard:=ClipSet("g",2) ; restore
	
	 Return
	}

; mod of virclip by Learning one http://www.autohotkey.com/forum/topic56926.html
/* original VirClip tasks: (renamed to ClipSet for Lintalist)
"c" or "Copy"        ; copies just text. (Clipboard)
"ca" or "CopyAll"    ; copies all data; text, pictures, formatting. (ClipboardAll)
"x" or "Cut"
"xa" or "CutAll"
"v" or "Paste"
"vt" or "PasteText"  ; pastes only text from virtual clipboard.

"e" or "Empty"
"ea" or "EmptyAll"
"g" or "Get"
"s" or "Set"
"a" or "Append"
"p" or "Prepend"
"as" or "AppendSelected"   ; Appends selected text, not pictures etc.
"ps" or "PrependSelected"   

"uc" or "UpperCase"
"lc" or "LowerCase"
"tc" or "TitleCase"
*/

ClipSet(Task,ClipNum=1,SendMethod=1,Value="") ; by Learning one http://www.autohotkey.com/forum/topic56926.html
  { 
   Static Clip1, Clip2, Clip3, Clip4
   if ClipNum not between 1 and 30
   Return
   IsClipEmpty := (Clipboard = "") ? 1 : 0
   if (task = "c" or task = "ca" or task = "x" or task = "xa" or task = "Copy" or task = "CopyAll" or task = "Cut" or task = "CutAll")
   {
      ClipboardBackup := ClipboardAll
      While !(Clipboard = "") {
         Clipboard =
         Sleep, 10
      }
      if (task = "c" or task = "ca" or task = "Copy" or task = "CopyAll")
      	SendKey(SendMethod, "^c")
      Else
      	SendKey(SendMethod, "^x")
      if (task = "c" or task = "x" or task = "Copy" or task = "Cut") {
         ClipWait, 0.5
         if !(Clipboard = "")
         Clip%ClipNum% := Clipboard
      }
      Else {
         ClipWait, 0.5, 1
         if !(Clipboard = "")
         Clip%ClipNum% := ClipboardAll
      }
      Clipboard := ClipboardBackup
      if !IsClipEmpty
      ClipWait, 0.5, 1
      Return Clip%ClipNum%
   }
   else if (task = "v" or task = "vt" or task = "Paste" or task = "PasteText") {
      if (Clip%ClipNum% = "")
      Return
      ClipboardBackup := ClipboardAll
      While !(Clipboard = "") {
         Clipboard =
         Sleep, 10
      }
      Clipboard := Clip%ClipNum%
      ClipWait, 0.5, 1
      Sleep, 40
      if (task = "vt" or task = "PasteText") {
         Clipboard := Clipboard
         ClipWait, 0.5
         Sleep, 30
      }
      	SendKey(SendMethod, "^v")
      Sleep, 20
      While !(Clipboard = "") {
         Clipboard =
         Sleep, 10
      }
      Clipboard := ClipboardBackup
      if !IsClipEmpty
      ClipWait, 0.5, 1
      Return Clip%ClipNum%
   }
   else if (task = "e" or task = "Empty") {
      Clip%ClipNum% =
      Return
   }
   else if (task = "ea" or task = "EmptyAll") {
      Loop, 30
      Clip%A_Index% =
      Return
   }
   else if (task = "g" or task = "Get")
   Return Clip%ClipNum%
   else if (task = "s" or task = "Set") {
      Clip%ClipNum% := Value
      Return Clip%ClipNum%
   }
   else if (task = "a" or task = "Append") {
      Clip%ClipNum% .= Value
      Return Clip%ClipNum%
   }
   else if (task = "p" or task = "Prepend") {
      Clip%ClipNum% := Value Clip%ClipNum%
      Return Clip%ClipNum%
   }
   else if (task = "as" or task = "ps" or task = "AppendSelected" or task = "PrependSelected") {
      ClipboardBackup := ClipboardAll
      While !(Clipboard = "") {
         Clipboard =
         Sleep, 10
      }
      SendKey(SendMethod, "^c")
      ClipWait, 0.5
      if !(Clipboard = "") {
         if (Clip%ClipNum% = "")
         Clip%ClipNum% := Clipboard
         Else {
            if (task = "as" or task = "AppendSelected")
            Clip%ClipNum% .= value Clipboard
            Else
            Clip%ClipNum% := Clipboard Value Clip%ClipNum%
         }
      }
      While !(Clipboard = "") {
         Clipboard =
         Sleep, 10
      }
      Clipboard := ClipboardBackup
      if !IsClipEmpty
      ClipWait, 0.5, 1
      Return Clip%ClipNum%
   }
   else if (task = "uc" or task = "UpperCase") {
      StringUpper, Clip%ClipNum%, Clip%ClipNum%
      Return Clip%ClipNum%
   }
   else if (task = "lc" or task = "LowerCase") {
      StringLower, Clip%ClipNum%, Clip%ClipNum%
      Return Clip%ClipNum%
   }
   else if (task = "tc" or task = "TitleCase") {
      StringUpper, Clip%ClipNum%, Clip%ClipNum%, T
      Return Clip%ClipNum%
   }
}

ClearClipboard()
	{
	   While !(Clipboard = "")
	    {
	     Clipboard =
	     Sleep, 10
	    }
	   Return
	}