wComment(text, header="", URL = "",  title = ""){
    oWord := ComObjActive("Word.Application")
    if header <> ; Run only if header isn't empty 
    {
        author := oWord.Application.UserName  ; Get current author
        oWord.Application.UserName := header ; Set heading as author 
    }
    
    try
    {
        oWord.ActiveDocument.Comments.Add(oWord.Selection.Range) ; Add comment 
        ErrorLevel = 0
    }
    catch ; Catch errors
    {
        MsgBox,16, %A_ScriptName%, Something whent wrong. `rCheck the text you have selected and try again.
        ErrorLevel = 1
    }
    if ErrorLevel = 0
    {
        oWord.Selection.TypeText(text) ; Send text 
        if URL <> ; Run only if URL isn't empty
        {
            oWord.Selection.TypeParagraph ; New line 
            if title <> ; Run only if title isn't empty
                oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range, URL,"","", title) ; Add titled link
            Else ; Else use URL as title 
                oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range, URL,"","", URL) ; Add untitled link
        }
        if header <> ; Run only if header isn't empty 
            oWord.Application.UserName := author ; Restore original author 
        Send, {Esc}
    }
}