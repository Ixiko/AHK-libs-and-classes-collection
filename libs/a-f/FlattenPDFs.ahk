; Flatten Selected PDFs in a folder
AVDoc := ComObjCreate("acroExch.AVDoc")      ; create an AV document object
Folder := A_Desktop "\Test\"								; target folder
FileSelectFile, Files, M3, %Folder%, Select PDFs to Flatten, PDFs (*.PDF)		; Multiselect existing PDF files
if ErrorLevel	; dialog canceled without selection
	return			; end script
Loop, Parse, Files, `n
{
	if (A_Index = 1)		; first item in Files is the directory
	{
		Dir := A_LoopField		; save directory for later loops
		continue						; continue to next loop
	}
	AVDoc.Open(Dir "\" A_LoopField, "")	; open a pdf into the AVDoc (this is a view but it is hidden by default)
	PDDoc := AVDoc.GetPDDoc()			; get the underlining PDDoc of the AVDoc (this is kind of like the HTML of a webpage before it is processed and rendered)
	JSO	:= PDDoc.GetJSObject				; this JavaScript object is mainly used by Acrobat to run its scripts engine
	JSO.FlattenPages()							; Flatten Pages of current AVDoc
	JSO.SaveAs(Dir "\" A_LoopField)	; save flattened document with same name and path
	AVDoc.Close(1)	; otherwise there could be a hidden document still running in processes
}
PDDoc.Close()	; this is not necessarily required but is probably good practice
