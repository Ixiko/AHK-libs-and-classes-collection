; AHK v2
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
;#NoTrayIcon

#INCLUDE TheArkive_MsgBox2.ahk
#INCLUDE _JXON.ahk

Global mb2ex, bigMsg, bigMsg2

StartGui()

StartGui() {
    Global mb2ex, bigMsg, bigMsg2
	mb2ex := Gui("","MsgBox2 Examples")
	mb2ex.OnEvent("Close",mb2ex_Close)
	mb2ex.AddButton("","Ex #1").OnEvent("Click",Example1)
	mb2ex.Show("w200")
}

Example1(ctl,*) {
    Global mb2ex, bigMsg, bigMsg2
	sTitle := "File Delete Action" ; title ... can be anything
	
	; ===========================================================================
	; Here are a variety of different test messages for experimenting.
	; ===========================================================================
	
	; sMsg := bigMsg ; large columns of text, see below
	
	; sMsg := bigMsg2 ; long text that simulates log output, see below
	
	sMsg := "This is a short message."
	
	; sMsg := "BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
	
	; sMsg := "BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
	
	; ===========================================================================
	; === Use this to modify font, font size, text color...
	; ===========================================================================
	msgboxStyle := "txtColor:Red,fontFace:Verdana,fontSize:8," ; always end with a comma, it's just easier
	sOptions := msgboxStyle
	
	; ===========================================================================
	; define parent window with one of these options.  Do NOT use modal: and parent: together
	; ===========================================================================
	sOptions .= "modal:" mb2ex.hwnd "," ; prevents taskbar icon, and disables parent window
	; sOptions .= "parent:" MainHwnd "," ; prevents taskbar icon, does NOT disable parent window
	
	; ===========================================================================
	; === some common options
	; ===========================================================================
	sOptions .= "noCloseBtn:true," ; removes close button on dialog
	; sOptions .= "btnAlign:center," ; button alignment: left, center right / default = right
    ; sOptions .= "x:200,y:200," ; specify dialog x,y (top left corner)
	sOptions .= "maxWidth:400," ; don't enable maxWidth and width together
    ; sOptions .= "width:500," ; don't enable maxWidth and width together
    ; sOptions .= "Height:50," ; sets height of sMsg, implies selectable:1, makes sMsg an edit box with vScroll instead of a text control.
    ; sOptions .= "selectable:1," ; best used with larger dialog sizes
    ; sOptions .= "help:?:helpFunc," ; adds a help button and defines the callback func for clicking the help button.
    ; sOptions .= "margin:20," ; sets custom dialog margin
	
	; ===========================================================================
	; check library comments for more icon options
	; you can use HICON / HBITMAP, icon:file.jpg, or icon:file.dll/[index]
	; ===========================================================================
	sOptions .= "icon:warning," ; generic icons: warning, info, question, error
	
	; ===========================================================================
	; === add controls for additional user input
	; === modify / comment out as desired
	; === check library comments for detailed options list and instructions
	; ===========================================================================
	sOptions .= "list:Option 1|Option 2|Option 3|Option 4|Option 5|Option 6|Option 7|Option 8|Option 9|Option 10|Option 11:3:5,"
	sOptions .= "check:Don't show again.:1,"	; add global style + checkBox
	sOptions .= "dropList:Long Long Long Long Long Long Long Option1|Option2|Option 3:2,"
	sOptions .= "combo:Option 4|Option 5|Option 6:3,"
	sOptions .= "edit:New_file_name.txt," ; adds edit box with prefilled text
	
	; ===========================================================================
	; button list, can be a number 0-6 like original MsgBox command, or
	; "|" delimited string of your own custom button text
	; ===========================================================================
	sOptions .= "btnList:OK|Cancel|Try Again," ; selectable
    ; sOptions .= "btnTextW:1" ; forces button width to only be as wide as button text + default button margin.
	
	mb2 := msgbox2(sMsg,sTitle,sOptions) ; bigMsg
	
	msgbox "edit: " mb2.editText
	     . "`r`nlist: " mb2.list
		 . "`r`nlistText: " mb2.listText
	     . "`r`ndropList: " mb2.dropList 
		 . "`r`ndropListText: " mb2.dropListText
		 . "`r`ncombo: " mb2.combo 
		 . "`r`ncomboText: " mb2.comboText
		 . "`r`ncheck: " mb2.checkValue
		 . "`r`nbutton: " mb2.buttonText
		 . "`r`nclassNN: " mb2.classNN
	mb2 := ""
}

helpFunc() {
    Msgbox "This represents a custom help action."
}

mb2ex_Close(gui) {
    Global mb2ex, bigMsg, bigMsg2
	if (gui.hwnd = mb2ex.hwnd)
		ExitApp
}

bigMsg := "
(
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
data data data data data data data data data data data data data data
)"

bigMsg2 := "
(
data data data data data data data 
data data data data data data data data data data data data data data
data data data data data data data data 
data data data data data data data data data data 
data data data
data data data data data data data dat
data data ddata data
data data data data data data data data data data data data data data
data data dadata data data
data data data data data data data 
data data data data data data data data d
data data data data data data data data dat
data data data data data data data data data data
data data d
data data dat
data data data data data dat
data data data data data data data data data data data data data data
data data data data data data data data data data 
data data data dat
data data data data data data data 
data data data data data data data data data data data data data data
data data data data data data data data 
data data data data data data data data data data 
data data data
data data data data data data data dat
data data ddata data
data data data data data data data data data data data data data data
data data dadata data data
data data data data data data data 
data data data data data data data data d
data data data data data data data data dat
data data data data data data data data data data
data data d
data data dat
data data data data data dat
data data data data data data data data data data data data data data
data data data data data data data data data data 
data data data dat
)"