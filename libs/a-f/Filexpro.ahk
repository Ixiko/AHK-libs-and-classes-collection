; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

Filexpro( sFile := "", Kind := "", P* ) {           ; v.90 By SKAN on D1CC @ goo.gl/jyXFo9
Local
Static xDetails

  If ( sFile = "" )
    {                                                           ;   Deinit static variable
        xDetails := ""
        Return
    }

  fex := {}, _FileExt := ""

  Loop, Files, % RTrim(sfile,"\*/."), DF
    {
        If not FileExist( sFile:=A_LoopFileLongPath )
          {
              Return
          }

        SplitPath, sFile, _FileExt, _Dir, _Ext, _File, _Drv

        If ( p[p.length()] = "xInfo" )                          ;  Last parameter is xInfo
          {
              p.Pop()                                           ;         Delete parameter
              fex.SetCapacity(11)                               ; Make room for Extra info
              fex["_Attrib"]    := A_LoopFileAttrib
              fex["_Dir"]       := _Dir
              fex["_Drv"]       := _Drv
              fex["_Ext"]       := _Ext
              fex["_File"]      := _File
              fex["_File.Ext"]  := _FileExt
              fex["_FilePath"]  := sFile
              fex["_FileSize"]  := A_LoopFileSize
              fex["_FileTimeA"] := A_LoopFileTimeAccessed
              fex["_FileTimeC"] := A_LoopFileTimeCreated
              fex["_FileTimeM"] := A_LoopFileTimeModified
          }
        Break
    }

  If Not ( _FileExt )                                   ;    Filepath not resolved
    {
        Return
    }


  objShl := ComObjCreate("Shell.Application")
  objDir := objShl.NameSpace(_Dir)
  objItm := objDir.ParseName(_FileExt)

  If ( VarSetCapacity(xDetails) = 0 )                           ;     Init static variable
    {
        i:=-1,  xDetails:={},  xDetails.SetCapacity(309)

        While ( i++ < 309 )
          {
            xDetails[ objDir.GetDetailsOf(0,i) ] := i
          }

        xDetails.Delete("")
    }

  If ( Kind and Kind <> objDir.GetDetailsOf(objItm,11) )        ;  File isn't desired kind
    {
        Return
    }

  i:=0,  nParams:=p.Count(),  fex.SetCapacity(nParams + 11)

  While ( i++ < nParams )
    {
        Prop := p[i]

        If ( (Dot:=InStr(Prop,".")) and (Prop:=(Dot=1 ? "System":"") . Prop) )
          {
              fex[Prop] := objItm.ExtendedProperty(Prop)
              Continue
          }

        If ( PropNum := xDetails[Prop] ) > -1
          {
              fex[Prop] := ObjDir.GetDetailsOf(objItm,PropNum)
              Continue
          }
    }

  fex.SetCapacity(-1)
Return fex

} ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -