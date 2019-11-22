; This script creates a new word documennt from a template. Then it inserts text into two bookmarks.
; The template (Bookmarks.dotx) has two bookmarks named "MyBookmark1" and "MyBookmark2".

; Note: To run this example you will first need to open the template (Bookmarks.dotx) and click "Enable Editing".
; (Or just create your own template.) Otherwise the file will be displayed in "Protected View" because it originated
; online. Running this script with a "Protected View" document will cause an error.

FilePath := A_ScriptDir "\Bookmarks.dotx"  ; .dotx is a Word template, but .doc and .docx will also work.
wdApp := ComObjCreate("Word.Application")  ; Create an instance of Word.

; You can remove this after testing so that Word stays invisible. Confirm that the script closes Word at the end so you
; don't get a bunch of invisible Word applications open in the background.
wdApp.Visible := true

MyDocNew := wdApp.Documents.Add(FilePath)  ; Create a new document using the template.

MyDocNew.Bookmarks("MyBookmark1").Range.Text := "Abc123"  ; Put the text into the bookmarks
MyDocNew.Bookmarks("MyBookmark2").Range.Text := "Aut et magnam quas"

MyDocNew.SaveAs(A_ScriptDir "\Bookmarks.docx")  ; Save the document.
MsgBox, 64, Document created, A new Word document was created. Press OK to continue.
MyDocNew.Close()  ; Close the document.
wdApp.Quit()  ; Quit Word.
return

; References:
;   Add a bookmark
;       - https://support.office.com/en-us/article/Add-or-delete-bookmarks-f68d781f-0150-4583-a90e-a4009d99c2a0#bm1
;   How to quickly show or hide bookmarks in Word?
;       - https://www.extendoffice.com/documents/word/848-word-show-hide-bookmarks.html
;   Working with Bookmarks in VBA
;       - http://word.mvps.org/FAQs/MacrosVBA/WorkWithBookmarks.htm
;   https://autohotkey.com/boards/viewtopic.php?p=84712#p84712
;   https://autohotkey.com/boards/viewtopic.php?p=84568#p84568
