;;; Destroys the GUI and removes the key.
;;; Returns the GUI index, or 0 if not found.
GUIUniqueDestroy(key = "") {
	
	; Remove the GUI from the list and destroy the GUI:
	Return GUIUniqueDefault(key, "Destroy")
}

;;; Destroys any existing GUI before setting the thread's default GUI.
;;; Returns the GUI index.
GUIUniqueSingle(key = "") {
	Return GUIUniqueDefault(key, "Single")
}

;;; Creates a unique index based on the key, and sets the thread's default GUI.
;;; Returns the GUI index.
;;; 
;;; If Key is ommitted, the last GoSub/GoTo label will be used.
;;; 
;;; The default GUI Labels are:
;;; [KEY]_Close:  [KEY]_Escape:  [KEY]_Size  [KEY]_ContextMenu  [KEY]_DropFiles
GUIUniqueDefault(key = "", destroyMode = "") {
	Static UsedKeys
	; UsedKeys format:
	; (keyA=20)
	; (keyB=21)
	; (keyD=23)

	; Remove invalid characters, just in case:
	key := RegexReplace(key, "[\s=()]+", "")

	
	If key !=
	{	; See if the key exists in our table:
		guiNumber = 0
		Loop parse, UsedKeys, `n
		{	StringSplit usedKey, A_LoopField, =, ()
			If (key = usedKey1) { ; We have a match!
				guiNumber := usedKey2
				break
			}
		}
	} 
	Else If A_Gui !=
	{	; The key is blank, so let's use the active Gui number
		guiNumber := A_Gui
		Loop parse, UsedKeys, `n
		{	StringSplit usedKey, A_LoopField, =, ()
			If (A_Gui = usedKey2) { ; We have a match!
				key := usedKey1
				break
			}
		}
	} 
	Else 
	{
		MsgBox You must enter a GUI Key!  (error in %A_ThisLabel%)
	}
	






	If (destroyMode = "" OR destroyMode = "Single") {
		; Add/Activate this key
		If guiNumber = 0
		{	; Add the key to our table:
			Loop 90
			{	guiNumber := A_Index + 10
				IfNotInString UsedKeys, =%guiNumber%)
				{	; This is a unique index!
					keyText = (%key%=%guiNumber%)`n
					UsedKeys .= keyText
					break
				}
				If A_Index = 90
					MsgBox All unique GUI numbers have been used!  Please make sure you are calling GUIUniqueDestroy when the GUI is destroyed.
			}
		} Else If (destroyMode = "Single") {
			; Destroy the existing GUI:
			Gui %guiNumber%:Default
			Gui Destroy
		}

		; Set the GUI to be the default and return the number!
		Gui %guiNumber%:Default
		Gui +OwnDialogs
		Gui +Label%key%_
		Return guiNumber
	} Else If (destroyMode = "Destroy") {
		; Remove this key
		If guiNumber > 0
		{	; Remove this key
			keyText = (%key%=%guiNumber%)`n
			StringReplace UsedKeys, UsedKeys, %keyText%, , All
			; Destroy the GUI:
			Gui %guiNumber%:Default
			Gui Destroy
		}
		Return guiNumber
	}
	
	MsgBox "%destroyMode%" is not a valid value!
}






MeasureText(text, ByRef Width, ByRef Height, fontName = "", fontOptions = "") {
	GuiUniqueDefault("MeasureText")
	If fontName !=
		Gui, Font, %fontOptions%, %fontName%
	Gui, Margin, x0 y0
	Gui, Add, Text, , %text%
	Gui -Caption
	Gui, Show, Hide
	Gui +LastFound
	WinGetPos, , , Width, Height
	GuiUniqueDestroy("MeasureText")
}
