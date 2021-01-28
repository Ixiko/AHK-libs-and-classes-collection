#NoEnv
SetBatchLines, -1
FileSelectFile, FilePath					; Select a file to use for this example.

PropName := FGP_Name(0)						; Gets a property name based on the property number.
PropNum  := FGP_Num("Size")					; Gets a property number based on the property name.
PropVal1 := FGP_Value(FilePath, PropName)	; Gets a file property value by name.
PropVal2 := FGP_Value(FilePath, PropNum)	; Gets a file property value by number.
PropList := FGP_List(FilePath)				; Gets all of a file's non-blank properties.

MsgBox, % PropName ":`t" PropVal1			; Display the results.
. "`n" PropNum ":`t" PropVal2
. "`n`nList:`n" PropList.CSV