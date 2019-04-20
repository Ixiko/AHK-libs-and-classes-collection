#NoEnv
#include class InsertBinToPNG.ahk
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

BinInPNG.init()


; ***************** sample1 *********************
;~ create binMsg from file
file2:=new binMsg("sample.ahk")

;~ select a Picture
BinInPNG.selectPic("test.png")

;~ put binMsg to Picture we selected before
BinInPNG.putBinMsg(file2)

;~ save the output PNG
;~ we will use it later
BinInPNG.savePng("sample_output")	; name without ext(PNG fixed)
; *********************************************



; ***************** sample2 *********************
;~ select a Picture the we create before which has binMsg inside
BinInPNG.selectPic("sample_output.png")

;~ output it with being named test_sample_output.ahk
BinInPNG.getBinMsg("test_$NameNoExt$_output.$Ext$")
;~ 3 constant supported: $FileName$, $NameNoExt$, $Ext$
; *********************************************




; ***************** sample3 *********************
;~ select a Picture which has binMsg inside
BinInPNG.selectPic("mpress.png")

;~ output binMsg in it's original name
; BinInPNG.getBinMsg()
;~ same as above
BinInPNG.getBinMsg("$FileName$")
; *********************************************

ExitApp
