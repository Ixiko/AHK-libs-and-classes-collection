; Text = Byref   param1   :=    { 1:"Test" , "Key {2": "" }  ,   param2*  ,   Param3   :=   [ {"t,e[a]s:t{b}":  {1:"t,e[a]s:t{b}","t,e[a]s:t{b}": [4 ] }}]
; Text = param1 := { 1:"Test" , "Key {2": "" } , Param3 := [ {"t,e[a]s:t{b}": {1:"t,e[a]s:t{b}","t,e[a]s:t{b}": [4 ] }}]
; MsgBox % ">" Text "<`n>" RemoveDefaultDefinitions(Text) "<"
ExitApp

/*
;input 
>param1 := { 1:"Test" , "Key {2": "" } , Param3 := [ {"t,e[a]s:t{b}": {1:"t,e[a]s:t{b}","t,e[a]s:t{b}": [4 ] }}]<
;this is the current result
>param1 .. --------------------------- , Param3 .. [ {--------------: ----------------------------------------}]<
;this is what I would like to achieve
>param1 .. --------------------------- , Param3 .. -------------------------------------------------------------<
*/

RemoveDefaultDefinitions(Line){
  static chars := [{"open":Chr(34),"close":Chr(34)}        ; quote character
                  ; ,{"open":"{",    "close":"}"}
                  ,{"open":"\[",    "close":"]"}   
                  ,{"open":"\{",    "close":"}"}
                  ,{"open":":",    "close":"="}]   
  ;replace 
  ;  "quoted strings"
  ;  {objects}
  ;  [Arrays]
  ;  with dots and dashes to keep length of line constant, and that other character positions do not change
  
  CleanLine := Line
  For k,q in chars
  {
    ;Replace quoted literal strings             1) replace two consecutive quotes with dots
    CleanLine := StrReplace(CleanLine, q.open . q.close , "..")

    Pos := 1                                 ;  2) replace ungreedy strings in quotes with dashes
    Needle := q.open . "[^" q.open "]*?" . q.close
    ; Needle := "\s*?" q.open . "[^" q.open "]*?" . q.close
    ; Needle := ":=\s*?" q.open . ".*?" . q.close
    While Pos := RegExMatch(CleanLine, Needle, QuotedString, Pos){
      ; MsgBox % q.open "`n" CleanLine
      ReplaceString =
      Loop, % StrLen(QuotedString)
         ReplaceString .= "-"
      CleanLine := RegExReplace(CleanLine, Needle, ReplaceString, Count, 1, Pos)
    }
  }
  Return CleanLine
}

; File = C:\LokaleDaten\Privat\Code\AHK Project Manager\ParseAHK.ahk
; FileRead, Script, %File%
; StartTime := A_TickCount
; Loop 100
  ; Result := ParseAHK(Script, SearchRE := "Join", DocComment := ">>>")
; Time := A_TickCount - StartTime
; ot(Result)
; MsgBox %Time% 
; ExitApp
; Return

;>>> Parse AHK Function ================================================================================================
ParseAHK(FileContent, SearchRE := "", DocComment := "") {
  ; internal vars
  local InCommentSection := False             ; true if within a comment section '/* ... */'
      , ContinuationBuffer := ""              ; buffer to collect continuation lines
      , ContinuationBufferLineNum := 0        ; buffer for first line number of continuation lines
      , InContinuationBlock2 := False         ; true if within a continuation block of method 2 '( ... )'
      , AllowComments := 0                    ; true if comments are allowed within a continuation block of method 2
      , Match3 := ""                          ; variable names for subpatterns of options for continuation block of method 2
      , Match4 := ""
      , Match7 := ""
      , ClassLevel := 0                       ; current class level, 0 if none
      , tnClasses := []                       ; array of tree nodes of classes, index is class Level
      , BlockLevel := []                      ; number of open blocks '{ ... }' per class level, index is class Level

      , tnCurrentFuncDef := ""                 ; tree node of function while in definition, 0 if not
      , FuncBlockLevel := 0                   ; number of open blocks '{ ... }' in the current function definition

  ;create resultobject
      , oResult := {"Classes":[],"Functions":[],"Labels":[]
                   ,"DllCalls":[],"Notes":[]
                   ,"HotKeys":[],"HotStrings":[]
                   ,"Includes":[],"GlobalVars":[]
                   ,"SearchResults":[]}

  ;>>> define RegEx Needles
      , DocCommRE :="
              ( Join LTrim Comment       ; DocComment allows comments to show up in Code Explorer as Notes
                    OiS)(*UCP)                  ;case insensitive (for the DocComment string), Study and Unicode (for \s and DocComment)
                    (^|.*\s);                  ;a ';' either at start of line or with some code and a whitespace infront, thus it is an AHK comment
                    \s*                        ;optional whitespace
                    \Q" DocComment "\E         ;the literal DocComment string
                    \s*                        ;optional whitespace
                    (.*)                       ;$2 the documentation string
              )"
      , HotStringRE :="
              ( Comment Join LTrim
                    OS)                         ;Study
                    ^:                         ;a ':' at start of line
                    .*?                        ;options (ungreedy)
                    :                          ;a ':'
                    (.+)                       ;$1 the hotstring
                    ::                         ;two ':'s
                    .*                         ;rest of line
                    $                          ;end of line
              )"
      , HotKeyRE :="
              ( LTrim Join Comment
                    OS)                         ;Study
                    ^                          ;at start of line
                    (.+)                       ;$1 the hotkey at least one character (but including whitespace)
                    ::                         ;two ':'s
                    .*                         ;rest of line
                    $                          ;end of line
              )"
      , HotKeyCommandRE :="
              ( LTrim Join Comment
                    OiS)(*UCP)                  ;case insensitive (for the Hotkey texts), Study and Unicode (for \s)
                    ^Hotkey                    ;the text 'Hotkey' at start of line
                    (\s*,\s*|\s+)              ;a comma or space
                    (?!If)                     ;not the text 'If'
                    (.+?)                      ;$2 the hotkey
                    \s*                        ;spaces
                    ,                          ;a comma
                    .*                         ;rest of line
                    $                          ;end of line
              )"
      , ContinuationBlock2RE :="
              ( Comment LTrim Join         ; for Continuation Block Method 2
                    OiS)(*UCP)                  ;case insensitive (for the option texts), Study and Unicode (for \s and JoinString)
                    ^\(                        ;a '(' at start of line
                    (
                        \s*                         ;optional white space(s)
                        (
                          (Join)                       ;the option Join (Match3)
                          (\S{0,15})                   ;and an optional joinstring (up to 15 characters long) (Match4)
                          |(LTrim)                     ;or the option LTrim (Match5)
                          |(L|R)Trim0                  ;or the option LTrim0 and RTrim0
                          |(C\S*)                      ;or the option Comments (a string that starts with a 'C') (Match7)
                          |(Q\S*)                      ;or the option Quotes (for AHK v2; a string that starts with a 'Q')
                          |(`%)                        ;or the option %
                          |(,)                         ;or the option ,
                          |(``))                       ;or the option `
                   `)*                         ;the above items are optional and can exits multiple times
                    (?!                        ;and the following itmes are not to exist to the right
                        .*?                        ;any optional text (ungreedy)
                        (
                          \)                          ;and a ')'
                          |:$))                       ;or a ':' at the end of line
              )"
      , LabelRE :="
              ( Join LTrim Comment
                    OS)(*UCP)                  ;Study and Unicode (for \s)
                    ^([^\s,`:]+)              ;$1 some characters at the start of the line (but no whitespace, comma, backtick or colon)
                    :$                        ;a ':' at the end of line
              )"
      , ContinuationOperatorsRE :="
              (LTrim Join Comment
                    iS)(*UCP)                 ;case insensitive (for 'and' and 'or'), Study and Unicode (for \w)
                    ^(                        ;at the start of line
                       (and|or)[^\w#@$]|      ;either "And" or "Or" followed by non word character
                       &|,|-(?!-)|!|~|/|<|>|=|:|    ;or operators that do not need to be escaped, but no --
                       \\|\.|\*|\?|\+(?!\+)|\||\^)  ;or these operators (that must be preceded by a backslash to be seen as literal), but no ++
              )"
      , DllCallRE :="
              ( Join LTrim Comment
                    Oi)                        ;case insensitive (for 'DllCall')
                    .*                        ;some code
                    (                         ;$1
                       DllCall                ;the text 'DllCall'
                       \(                     ;a '('
                       .*                     ;some code         ;            if i would make this ungreedy the first ) would be taken, not necessary the right one.
                       \))                    ;closing bracket   ;>>> to fix: takes the last ) in the line, not necessary the right one.
              )"
      , ClassRE :="
              ( Join LTrim Comment
                    OiS)(*UCP)                 ;case insensitive (for \s, \w and 'Class'), Study and Unicode (for \s and \w)
                    ^Class                    ;the text 'Class' at the start of line
                    \s+                       ;at least one whitespace
                    ([\w#$@]+)                ;$1 one ore more chracters (A-Za-z0-9_) or #, $, @  (all allowed characters in variable names)
                    .*                        ;rest of the line
              )"
      , FunctionRE :="
              ( Join LTrim Comment            ;$1 the whole line will be a match
                    S)(*UCP)                  ;Study and Unicode (for \w)
                    ^                         ;at the start of line
                    [\w$#@]+                  ;one ore more chracters (A-Za-z0-9_) or #, $, @  (all allowed characters in variable names)
                    \(                        ;a '('
              )"
      , PropertyRE :="
              ( Join LTrim Comment            ;$1 the whole line will be a match
                    S)(*UCP)                  ;Study and Unicode (for \w)
                    ^                         ;at the start of line
                    [\w$#@]+                  ;one ore more chracters (A-Za-z0-9_) or #, $, @  (all allowed characters in variable names)
              )"
      , OTBCommandsRE :="
              ( Join LTrim Comment
                    iS)(*UCP)^(                                           ;case insensitive and at start of line
                    If((Not)?Exist|MsgBox)?|                              ; either If|If[Not]Exit|IfMsgBox
                    If((Not)?(Equal|InString)|(Greater|Less)(OrEqual)?)|  ; or If[not]Equal|If[not]Equal|If[Greater|Less][OrEqual]
                    IfWin(Not)?(Active|Exist)|                            ; or IfWin[Not][Active|Exist]
                    Else|Try|Catch|Finally|                               ; or
                    Loop|While|For)                                       ; or
                    [,\s(]                                                ; followed by an ',' space or '('
              )"
      , IncludeRE :="
              ( Join LTrim Comment
                    OiS)(*UCP)                 ;case insensitive
                    ^#Include                 ;the text '#Include' at the start of line
                    \s+                       ;at least one whitespace
                    (\*i\s)?                  ;maybe the option "*i" and at least a single whitespace
                    \s*                       ;potentially more whitespaces
                    (?P<File>.*)              ;rest of the line
              )"
      , GlobalVarsRE :=" 
              ( Join LTrim Comment
                    OiS)(*UCP)                 ;case insensitive
                    ^global                   ;the text 'global' at the start of line
                    \s+                       ;at least one whitespace
                    (.*)                      ;rest of the line
              )"
      ;distinguish super globals and globals?        
      ;local variable without initialization
      , TotalNumberOfLine, PhysicalLineNum, Line, Lines, TempLine, TempLineNum, FuncName, IM, Count, JoinString, Match, tn, Type, i

  ;>>> Begin to parse script line by line
  Lines := StrSplit(FileContent, "`n", "`r")
  TotalNumberOfLine := Lines.MaxIndex()
  For PhysicalLineNum, Line In Lines {
    Line := Trim(Line)        ;remove leading/trailing whitespaces

    ;search for SearchRE
    If RegExMatch(Line, SearchRE)
      oResult.SearchResults[PhysicalLineNum] := Line

    If (DocComment <> "")     ;extract DocComment regardless of where it is (even inside a comment or comment section)
      If RegExMatch(Line, DocCommRE, Match)
        oResult.Notes[PhysicalLineNum] := Match.2

    ;>>> Remove all comments and skip empty lines ----------------------------------------------------------------------
    ;Skip comment section
    ;the /* and */ symbols comment out an entire section, but only if the symbols appear at the beginning of a line
    ;code after the */ is not part of the comment section
    If (InCommentSection) {
      If (SubStr(Line, 1, 2) = "*/"){
        InCommentSection := False
        Line := Trim(SubStr(Line, 3))   ;remove the /* from the beginning of the line and continue checking
      }Else
        Continue                        ;discard this line, it is in a Comment Section
    }Else If (SubStr(Line, 1, 2) = "/*") {
      InCommentSection := True
      Continue
    }

    ;when InContinuationBlock2 empty lines matter and maybe even comments
    ;hence, this has to be done before comments are stipped off and empty lines are skipped
    If (InContinuationBlock2) {
      If (SubStr(Line, 1, 1) = ")"){             ;it's the end of the continuation section
        InContinuationBlock2 := False
        AllowComments := False
        Line := SubStr(Line, 2)                  ;remove ) from line
      }
      If !AllowComments                          ;check if comments are allowed literaly
        Line := RemoveComments(Line)
      ;when still in continuation section concatenate the line with the JoinString,
      ;otherwise the code after the ) will be concatenated without any string
      ContinuationBuffer .= (InContinuationBlock2 ? JoinString : "") . Line
      Continue                                   ;go to next line
    }

    ;Remove any comment and skip empty lines (If not the last line)
    If ((!Line := RemoveComments(Line)) AND PhysicalLineNum <> TotalNumberOfLine)
      Continue

    ;>>> HotStrings & HotKeys ----------------------------------------------------------------------------------------
    ;HotStrings & HotKeys are not allowed inside of functions or classes or on the same line as the } of a {} block
    ;but AHK takes care of it, so I will not worry and assume that the code provided is valid AHK code.
    ;potential HotKeys and HotStrings contain a double colon
    If (InStr(RemoveQuotedStrings(Line), "::")){
      If RegExMatch(Line, HotStringRE, Match){
        oResult.HotStrings[PhysicalLineNum] := Match.1
        Continue                                   ;>>> to fix: escaped characters are not escaped in code explorer
      }
      If RegExMatch(Line, HotKeyRE, Match){
        oResult.HotKeys[PhysicalLineNum] := Match.1
        Continue                                   ;>>> to fix: DLLCalls on same line will not be shown, but it should be rare
      }
    }
    
    ;>>> #Include ----------------------------------------------------------------------------------------------------
    If RegExMatch(Line, IncludeRE, Match){
        oResult.Includes[PhysicalLineNum] := Match.File
        Continue                                   
    }

    ;>>> Collect continuation lines ==================================================================================

    ;>>> Check for Labels And/Or Start collecting continuation lines
    ;Label names are not case sensitive, and may consist of any characters other than space, tab, comma and the escape character (`).
    ;they are allowed inside of functions definitions, thus they are detected here but will be used later (detected again)
    If (RegExMatch(Line, LabelRE) or ContinuationBuffer = "") {
      ;this is not a continuation line. It is a label or the first line to be put into the buffer.

      ;Labels checked here to avoid false positives in checks below
      ;Since labels are allowed within a function body, they might be preceded with a brace,
      ;e.g. when a label is the first line after a multiline function definition without OTB
;       FuncDef()
;       { Label:    ;this label would not be catched correctly here
;
;       }
      ;or when it is following immediatly a {} block  (within in a function body or outside)
;       If(  )
;       {
;
;       } Label:    ;this label would not be catched correctly here

      ;thus do nothing just now, it will be catched later
      ;within functions first the {} blocks have to be analysed and the barces trimmed off,
      ;then the line has to be scanned again, but re-scanning can not start before the swap of lines
      ; (due to check for continuation) since this might screw up the order of lines
      ;thus, everything that is relevant within the function body has to be processed after the swap of lines

      ;in case there is no line in buffer, get next one
      ;this could happen when a label was detected very early, e.g. on the very first line in file.
      If (ContinuationBuffer = ""){
        ContinuationBuffer := Line
        ContinuationBufferLineNum := PhysicalLineNum
        If (PhysicalLineNum <> TotalNumberOfLine)
          Continue                    ;go to next line, but not in case of last line
      }

    ;>>> Collect continuation section Method 2
    ;used to merge a large number of lines; can also be used with any command or expression (assignment)
    ;in most cases there shouldn't be any valuable info for the code explorer on any of these lines (including any code on last line after ")")
    }Else If (RegExMatch(Line, ContinuationBlock2RE, Match)) {  ;it's the start of the continuation section when it starts with (
      InContinuationBlock2 := True                                ;but doesn't have a ), execption is after Join; it could be an expressions like (x.y)[z]()
                                                                ;and doesn't have a : at it's start or end, execption is after Join; it could be a label, hotkey or hoststring
      JoinString := Match3 ? "``n" : ""               ;JoinString is by default `n, when Join is present it is 'no space'
      JoinString := Match4 ? Match4 : JoinString      ;when a string is given right after Join, it is used instead
      AllowComments := Match7 ? True : False
      Continue                   ;go to next line     ;other parameters are ignored, because they do not matter for code explorer, e.g. LTRIM or `s

    ;>>> Collect continuation lines Method 1
    ;A line that starts with the following operators is automatically merged with the line directly above it
    ;operators: "and", "or", ||, &&, a comma or a period and all other expression operators except ++ and --
    ;AHK ignores also ::, but since hotstrings are caught above I see no need in this script
    }Else If (RegExMatch(Line, ContinuationOperatorsRE)){
      ContinuationBuffer .= " " Line   ;merge lines with a space
      If (PhysicalLineNum <> TotalNumberOfLine)
        Continue                       ;go to next line, but not in case of last line
    }

    ;>>> Swap buffer with current line
    ProcessLastLine:
    TempLine           := ContinuationBuffer
    ContinuationBuffer := Line             ;the current line is now buffered to be checked later
    Line               := TempLine         ;Line is now the previously buffered line
    TempLineNum               := ContinuationBufferLineNum
    ContinuationBufferLineNum := PhysicalLineNum
    PhysicalLineNum           := TempLineNum

    ;>>> GlobalVars ----------------------------------------------------------------------------------------------------
    If InStr(Line, "global")                 ;>>> this line can potentially be removed the RefgExMatch should be enough, check speed before and after removal
      If RegExMatch(Line, GlobalVarsRE, Match){
        ; oResult.GlobalVars[PhysicalLineNum] := StrSplit(Match.1,",", " ")  ;>>> problem with comma in strings or in objects and arrays
        oResult.GlobalVars[PhysicalLineNum] := Match.1
      }

    ;>>> DllCalls ----------------------------------------------------------------------------------------------------
    ;>>> who has a need for showing DllCall in code explorer?
    If InStr(Line, "DllCall")                ;>>> this line can potentially be removed the RefgExMatch should be enough, check speed before and after removal
      If RegExMatch(Line, DllCallRE, Match)
        oResult.DllCalls[PhysicalLineNum] := Match.1

    ;>>> Open block counter for classes and functions ------------------------------------------------------------------
    ;Process braces at the start of a line
    ;the concept with InStr() was taken from CoCo's ListClasses scipt (line 52; http://ahkscript.org/boards/viewtopic.php?p=43349#p42793)
    While (i := InStr("}}{", SubStr(Line, 1, 1)) ) {
      If (ClassLevel > 0  AND !isObject(tnCurrentFuncDef) ){  ;we are in a class definition
        BlockLevel[ClassLevel] += i - 2
        If (BlockLevel[ClassLevel] < 1)
          ClassLevel--
      }Else If (isObject(tnCurrentFuncDef)){                  ;we are in a function definition
        FuncBlockLevel += i - 2
        If (FuncBlockLevel < 1){
          FuncBlockLevel = 0
          tnCurrentFuncDef := ""
        }
      }Else                                         ;neither in a class nor function definition
        Break                                         ;don't trim line and break loop
      If !(Line := LTrim(SubStr(Line, 2), " `t"))
        Continue, 2             ;when no more braces and line is empty go to next line
    }


    ;>>> Class definitions ===========================================================================================
    ;a Class definition starts with the keyword "class"
    ;Class definitions can contain variable declarations, method and property definitions, Meta-Functions and nested class definitions
    ;they are not alowed inside a function definition
    tn := ClassLevel > 0 ? tnClasses[ClassLevel] : oResult.Classes
    If (RegExMatch(Line, ClassRE, Match)) {
      tn[PhysicalLineNum] := {"Name":Match.1,"Type":"Class","Inside":[]}
      ClassLevel++
      tnClasses[ClassLevel] := tn[PhysicalLineNum, "Inside"]
      BlockLevel[ClassLevel] := 0
      If RegExMatch(Line, "\{$")      ;check OTB
        BlockLevel[ClassLevel]++
      Continue
    }

    ;>>> Functions / methods / meta functions / class properties =====================================================
    ;function/method/metaFunction definitions are only allowed outside of function/method definitions (outside or inside of class) and on base level of a class
;     func()      ;case 1
;     {
;     }
;
;     func(){     ;case 2
;     }
;
;     class classname
;     {
;        MethodOrMetaFunction()    ;case 3
;        {
;        }
;
;        MethodOrMetaFunction(){   ;case 4
;        }
;     }

    If (!isObject(tnCurrentFuncDef) AND (ClassLevel = 0 Or BlockLevel[ClassLevel] = 1)){
    ; we are not in another function definition and (outside of a class or at the base level of a class)
      ;>>> Check for a new function/method/metaFunction definition
      If (RegExMatch(Line, FunctionRE, FuncName)) {    ;potential function definition or call without return value, let's check the end of line or next not empty linep
        If ( (SubStr(Line, 0) = ")" AND SubStr(ContinuationBuffer, 1, 1) = "{")   ;case 1 & 3: function definition with { on next line
          OR (SubStr(Line, 0) = "{" ))                                            ;case 2 & 4: function definition with OTB
          tnCurrentFuncDef := ["dummy"]                  ;set that something was found, (the var for the hwnd os misused as a flag)
      }

      ;class property definitions are only allowed on base level of a class
      ;they can only have Get and Set functions, but since these would be function definitions within function definition, these will be skipped
;       class classname
;       {
;          prop      ;case 1
;          {
;             get {
;                 return ...
;             }
;             set {
;                 return ... := value
;             }
;          }
;
;          prop{     ;case 2
;          }
;
;          prop[]    ;case 3
;          {
;          }
;
;          prop[]{   ;case 4
;          }
;       }
             ;"ClassLevel > 0" is redundant because BlockLevel[0] would not be 1, but for clearity I leave it in
      Else If (ClassLevel > 0 AND BlockLevel[ClassLevel] = 1){
      ;we are not in another function definition and in a class and at the base level of a class

        ;>>> Check for a new class property definition
        If (RegExMatch(Line, PropertyRE, FuncName)) {    ;potential a property definition, let's check the end of line or next not empty linep
           If (SubStr(FuncName, 0) = "["
               AND ((SubStr(Line, 0) = "]" AND SubStr(ContinuationBuffer, 1, 1) = "{") OR SubStr(Line, 0) = "{")   ;case 3 & 4
            Or SubStr(Line, 0) = "{" )                                                                                                       ;case 1 & 2
              tnCurrentFuncDef := ["dummy"]              ;set that something was found, (the var for the hwnd os misused as a flag)
        }
      }

      ;>>> Previous checks found a function, method, meta function or class property
      If (isObject(tnCurrentFuncDef)){
        If (SubStr(Line, 0) = "{"){       ;check again for OTB
          FuncBlockLevel++
          Line := RTrim(Line , " {")
        }
        tn := ClassLevel > 0 ? tnClasses[ClassLevel] : oResult.Functions   ;distinguish Functions       from methods/meta functions/ClassProperties
        ; Type := InStr(FuncName, "(") ? "Function" : "Property"             ;distinguish ClassProperties from methods/meta functions
        If (ClassLevel > 0)
          Type := InStr(FuncName, "(") ? "Method" : "Property" 
        Else
          Type := "Function"
        tn[PhysicalLineNum] := {"Name":Line,"FunctionName":FuncName,"Type":Type,"Inside":[]}
        tnCurrentFuncDef := tn[PhysicalLineNum, "Inside"]
        ; tnCurrentFuncDef := ParseAndAddNode(Tree, tn, IM, Line, "(.*)", "$1", PhysicalLineNum)
        Continue
      }
    }

    ;>>> Search for braces at the end of a line (OTB)
    ;    for classes no check at end of the line is done, because only definitions are allowed inside a class definition,
    ;    no flow commands that would allow OTB
    If (isObject(tnCurrentFuncDef) AND SubStr(Line, 0) = "{"){
        ;we are in a function definition and at end of line is a { with some text before it
        ;class, functions/methods and parameters have been checked for OTB previously
        ;need to check if the line is a command that supports OTB
        ;this avoids false positives like "Msgbox, {" or "StringReplace, Out, In, Search, {"
        ;it is still not 100% robust but close, e.g. "IfEqual, var, {" would still be a false positive.
        If (RegExMatch(Line, OTBCommandsRE)){
          FuncBlockLevel++
          Continue
        }
    }

    ;>>> Labels ----------------------------------------------------------------------------------------------------
    ;Label names are not case sensitive, and may consist of any characters other than space, tab, comma and the escape character (`).
    ;they are allowed inside of functions definitions, in this case they are 'belonging' to the function definitions
    ;since all the block braces are trimmed off, the remaining of the line is the label
    tn := isObject(tnCurrentFuncDef) ? tnCurrentFuncDef : oResult.Labels
    If RegExMatch(Line, LabelRE, Match){
      tn[PhysicalLineNum] := Match.1 
      Continue
    }

    ;>>> Hotkey Command
    If RegExMatch(Line, HotKeyCommandRE, Match){
      oResult.HotKeys[PhysicalLineNum] := Match.2 
      Continue
    }

    If (PhysicalLineNum = TotalNumberOfLine - 1 )
      GoTo ProcessLastLine

    ;every line that makes it through to this point is a 'normal' command
    ;in the case of the code explorer nothig needs to be done
   }
  Return oResult
}

;>>> Internal Helper Functions -----------------------------------------------------------------------------------------
RemoveComments(Line){
  If !(Pos := InStr(Trim(Line), ";"))
    Return Line             ; no quote character in this line

  If (Pos = 1)
    Return                  ; whole line is pure comment

  ;remove comments (first clean line of quotes strings)
  If (Pos := RegExMatch(RemoveQuotedStrings(Line), "\s+;.*$"))
    Line := SubStr(Line, 1, Pos - 1)

  Return Line
}

RemoveQuotedStrings(Line){
  ;the concept how to remove quoted strings was taken from CoCo's ListClasses scipt (line 77; http://ahkscript.org/boards/viewtopic.php?p=43349#p42793)
  ;replace quoted strings with dots and dashes to keep length of line constant, and that other character positions do not change
  static q := Chr(34)       ; quote character

  ;Replace quoted literal strings             1) replace two consecutive quotes with dots
  CleanLine := StrReplace(Line, q . q, "..")

  Pos := 1                                 ;  2) replace ungreedy strings in quotes with dashes
  Needle := q . ".*?" . q
  While Pos := RegExMatch(CleanLine, Needle, QuotedString, Pos){
    ReplaceString =
    Loop, % StrLen(QuotedString)
       ReplaceString .= "-"
    CleanLine := RegExReplace(CleanLine, Needle, ReplaceString, Count, 1, Pos)
  }
  Return CleanLine
}


_D(Title := "Debug", Vars*){      ;small helper to Debug
  local Var,Value,Text := ""
  For Var,Value in Vars           ;call it like this
    Text .= Var ": " Value "`n"   ;>>> _D("end of line", {i:i, Line:Line, FuncBlockLevel:FuncBlockLevel}*)
  MsgBox, 0, %Title%, %Text%
}

; #Include C:\LokaleDaten\Privat\Code\Toleranz Vergleichsblatt\Skripte\ObjTree.ahk
; #Include C:\LokaleDaten\Privat\Code\Toleranz Vergleichsblatt\Skripte\Attach.ahk
