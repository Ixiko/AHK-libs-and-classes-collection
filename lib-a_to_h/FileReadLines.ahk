FileReadLines(FromTo=0,FileIn*){
	F:=(!(IsObject(FileIn[1]))?(FileOpen(FileIn[1],0)):F:=FileIn[1]),FileSize:=F.Length(),FileEncodedIn:=F.Encoding(),StartEnd:=StrSplit(FromTo,"-"," `t"),pPoss:="",LinesOut:=""
    if (FileIn[1] = "")
        Return Mbx()
    if (((StartEnd[2])?1:0)&&(StartEnd[1]>StartEnd[2])) ; When the first number is greater then the second one.
		StartEnd.InsertAt(1,StartEnd.pop(StartEnd[2]))  ; Swap places.
    Loop{ ; If there is a ending line. Search starting line, join lines to LinesOut when found. Break loop if end is found. :  If there is no ending line. Search starting line, join lines to LinesOut when found. Break loop if EOF is found.
        if (StartEnd[2])?(((A_Index>=StartEnd[1])?1:!(F.readLine()))&&(((StartEnd[2]-A_Index)=0),LinesOut.=F.readLine())):(((A_Index>=StartEnd[1])?1:!(F.readLine()))&&(((((pPoss:=F.tell())=FileSize))=1),LinesOut.=F.readLine()))
            Break
    }F.Close()
	Return LinesOut
}

Mbx(){
    MsgBox,,Help: FileReadLines, 
    (
    This function will read a series of lines from a file,
    then returns them to OutVar.
        OutVar := FileReadLines( [FromTo, ] FileIn* )

    Parameter info.
    FromTo:
     The range of lines to retrieve from a file.
     Parameter can be:
      - Empty, then all lines will be retrieved.
      - A single number, all lines starting from
        that line number will be retrieved.
      - Two numbers - a range - devided by a minus character.
        Spaces may exist anywhere within the string.
        The lower number will alway's be the starting line.
        
    FileIn:
     This 'Thing' that is the input file.
     It can be one of the following:
      - A quoted path to some file.
      - A variable containing file path.
      - A file Object, returned by FileOpen().
    ----------------------------- EXAMPLES ------------------------------
    File        := "Q:\dummy.txt"
    ReadStart   := 22
    ReadEnd     := 88
    ReturnValue := FileReadLines("22 - 88", File)
    ReturnValue := FileReadLines(ReadEnd "-" ReadStart, File)

    ReturnValue would contain lines 22 through 88 in dummy.txt
    ------------------------------------------------------------------------
    File        := FileOpen("Q:\dummy.txt", 0)
    ReadStart   := 144
    ReturnValue := FileReadLines("144", File)
    ReturnValue := FileReadLines(ReadStart, "Q:\dummy.txt")

    ReturnValue would contain everything beyond line 143 in dummy.txt
    ------------------------------------------------------------------------
    ReturnValue := FileReadLines("Q:\dummy.txt")

    ReturnValue would contain all lines in dummy.txt.
    )
}