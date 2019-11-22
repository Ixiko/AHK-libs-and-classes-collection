; This script creates a new email and adds a hyperlink.

; Constants
olMailItem := 0

m := ComObjActive("Outlook.Application").CreateItem(olMailItem)  ; Create a new mail item. Outlook must be running.
m.Display  ; Display the mail item.
Insp := m.GetInspector  ; Get the inspector that is displaying the mail item.
Doc := Insp.WordEditor  ; Assumes Word is the default editor. 'Doc' now contains a Word Document object.
Sel := Doc.Windows(1).Selection   ; Get the current selection.

; Insert a hyperlink at the current selection. The link will point to this script (A_ScriptFullPath).
Doc.Hyperlinks.Add( Sel.Range           ; Anchor
                  , A_ScriptFullPath    ; Address
                  , ""                  ; SubAddress
                  , ""                  ; ScreenTip
                  , "This is a link"    ; TextToDisplay
                  , "")                 ; Target

; References
;   Hyperlinks.Add Method (Word) - https://msdn.microsoft.com/en-us/library/office/ff837214.aspx
