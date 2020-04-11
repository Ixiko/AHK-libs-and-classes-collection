; This script replaces the text "abc" with "xyz" on every slide in the active presentation.

ppApp := ComObjActive("Powerpoint.Application")
ppFindReplace(ppApp, "abc", "xyz")
return

ppFindReplace(ppApp, sFindMe, sSwapme) {
    for osld, in ppApp.ActivePresentation.Slides                      ; For each slide in the active presentation...
        for oshp, in osld.Shapes                                      ; For each shape on the slide...
            If (oshp.HasTextFrame)                                    ; If the shape has a text frame...
                If (oshp.TextFrame.HasText) {                         ; If the textframe has text...
                    otext := oshp.TextFrame.TextRange                 ; Get an object represting the range of text.
                    otemp := otext.Replace(sFindMe, sSwapme, , 0, 0)  ; Replace the first item.
                    while (otemp != "") {  ; Repeat until there are no more items to replace. (Until otemp is blank.)
                        iNewStart := otemp.Start + otemp.Length       ; Calculate where the next search should start.
                        otemp := otext.Replace(sFindMe, sSwapme, iNewStart, 0, 0)  ; Replace again.
                    }
                }
}

; References
; https://stackoverflow.com/questions/9811723/find-and-replace-text-in-powerpoint-2010-from-excel-2010-with-vba/9812463#9812463
