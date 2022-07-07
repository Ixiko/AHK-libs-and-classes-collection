; ====================================================================
; XmlRead(XmlPathStr,XmlDataStr)
; ====================================================================
; Xml paths are writen as tokenized strings with / as the
; delimiter.
;
;
; XmlPathStr = "node|#/node/node|#"
;   this example has 3 tokens
;
;   node = the name of the node
;   # = the instance you want to isolate of that node
;       (in case there are duplicate nodes).
;       Numbers are optional, if omitted then 1 is assumed.
;
;       When omitting numbers, also omit |
;
; This will return everything in the selected node, while
; automatically trimming spaces, tabs, crlf as needed.
;
;
; XmlDataStr
;   This is the var that contains the string to be parsed for
;   the specified xml node.
;
; 
; Known Issues:
;    None at this time.
;
XmlRead(XmlPathStr,XmlDataStr) {
    XmlSubStr := XmlDataStr
    
    Loop, Parse, XmlPathStr, /
    {
        XmlSubStrBackup := XmlSubStr ; we'll need this for accurately capturing nested nodes with identical names
        NodeNameVal := NodeName(A_LoopField)
        NodeNum := NodeNumber(A_LoopField)
        
        NodeStart := "<" . NodeNameVal ; define NodeStart value
        NodeStartLen := StrLen(NodeStart)
        
        NodeStartBeginPos := InStr(XmlSubStr,NodeStart,,1,NodeNum)
        NodeStartClosePos := InStr(XmlSubStr,">",,NodeStartBeginPos,1)
        NodeStartLen := NodeStartClosePos - NodeStartBeginPos + 1
        NodeStart := SubStr(XmlSubStr,NodeStartBeginPos,NodeStartLen) ; redefine NodeStart value to include attributes if any
        
        NodeEnd := "</" . NodeNameVal . ">"
        
        DataStart := InStr(XmlSubStr,NodeStart,,1,NodeNum)
        
        If (DataStart = 0) {
            XmlSubStr := ""
            break
        }
        DataStart := DataStart + NodeStartLen
        
        SearchStart := DataStart
        DataEnd := InStr(XmlSubStr,NodeEnd,,SearchStart,1)
        
        DataLen := DataEnd - DataStart
        
        XmlSubStr := RTrim(SubStr(XmlSubStr,DataStart,DataLen),OmitChars := "`r`n`t ")
        XmlSubStr := LTrim(XmlSubStr,OmitChars := "`r`n")
        
        ; now we need to check for nested nodes with the same name
        
        DupeNodeCount := InStrCount(XmlSubStr,"<" NodeNameVal)
        If (DupeNodeCount > 0) {
            XmlSubStr := XmlSubStrBackup ; reset initial substr value
            
            DataEnd := InStr(XmlSubStr,NodeEnd,,SearchStart,1+DupeNodeCount) ; define new data end point

            DataLen := DataEnd - DataStart
            
            XmlSubStr := RTrim(SubStr(XmlSubStr,DataStart,DataLen),OmitChars := "`r`n`t ")
            XmlSubStr := LTrim(XmlSubStr,OmitChars := "`r`n")
        }
    }
    
    return XmlSubStr
}
; ====================================================================
; XmlCount(XmlPathStr,XmlDataStr)
; ====================================================================
; See XmlRead() for examples no how xml paths are used with these functions.
;
; Given "node|1/node|2/node" as the xml path with 3 tokens, 
; thus a depth of 3 nodes, xml data will be "extracted" up to
; [# of tokens] - 1.  After extraction, the remaining data will
; be parsed to count the number of instances of the last node
; specified in XmlPathStr.
;
; Example:
; XmlPathStr := "node|1/node|2/node"
;    - so, "node|1/node|2" will be extracted...
;    - then "node" will be counted from what was extracted.

XmlCount(XmlPathStr,XmlDataStr) {
    ; get xml path -1 so that we can isolate what to count
    ; first count the path tokens separated by /
    PathLen := StrLen(XmlPathStr)
    LastTokenPos := InStr(XmlPathStr,"/",,0)
    SubStrLen := PathLen - LastTokenPos
    
    LastToken := Right(XmlPathStr,SubStrLen)
    XmlPathSubStr := Left(XmlPathStr,LastTokenPos-1)
    
    i := 1
    XmlPiece := XmlPathStr "|" i

    While (XmlRead(XmlPiece,XmlDataStr) <> "") {
        i := i + 1
        XmlPiece := XmlPathStr "|" i
    }
    
    i := i - 1
    
    return i
}

; ====================================================================
; support functions
; ====================================================================

NodeName(InStr) {
    Loop, Parse, InStr, |
    {
        If (A_Index = 1) {
            Result := A_LoopField
        }
    }
    
    return Result
}

NodeNumber(InStr) {
    Loop, Parse, InStr, |
    {
        If (A_Index = 2) {
            Result := A_LoopField
        }
    }
    If (Result = "") {
        Result := 1
    }
    
    return Result
}