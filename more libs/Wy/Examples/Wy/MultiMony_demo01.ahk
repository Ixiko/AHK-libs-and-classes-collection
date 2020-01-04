#include %A_ScriptDir%\..\..\lib\Wy.ahk
#include %A_ScriptDir%\..\..\lib\Wy\MultiMony.ahk

OutputDebug "DBGVIEWCLEAR"

debug := 1
mm := new MultiMony(debug)

monCnt := mm.monitorsCount
primary := mm.idPrimary
size := mm.virtualScreenSize

mm.identify()

Loop monCnt	{
	mon := new Mony(A_Index, debug)
    x := mon.name
    x := mon.hmon
	x := mon.boundary
    x := mon.size
    x := mon.workingArea
    x := mon.idNext
    x := mon.idPrev
}


ExitApp