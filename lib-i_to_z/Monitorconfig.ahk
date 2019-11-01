;#warn
#include <MonitorConstants>


; Gets monitor sizes using their numbering in Windows settings rather than AutoHotkey's unstable alternative
Getmonitorsizes(returnarray:=false)
{
  global
  sysget,monitorCount,MonitorCount
  monitorsizesarray := []
  loop,%monitorCount%
  {
    sysget,monitorReal,Monitor,%A_Index%
    sysget,monitor,MonitorWorkArea,%A_Index%
    sysget, thisname, monitorname, %a_index%
    thisname := substr(thisname, 0)
    monitor%thisname%Left   :=MonitorLeft
    monitor%thisname%Bottom :=MonitorBottom
    monitor%thisname%Right  :=MonitorRight
    monitor%thisname%Top    :=MonitorTop
    monitor%thisname%Width  :=MonitorRight - MonitorLeft
    monitor%thisname%Height :=MonitorBottom - MonitorTop
    
    monitorreal%thisname%Left   :=MonitorRealLeft
    monitorreal%thisname%Bottom :=MonitorRealBottom
    monitorreal%thisname%Right  :=MonitorRealRight
    monitorreal%thisname%Top    :=MonitorRealTop
    monitorreal%thisname%Width  :=MonitorRealRight - MonitorRealLeft
    monitorreal%thisname%Height :=MonitorRealBottom - MonitorRealTop
    if returnarray
        monitorsizesarray[thisname] := {"left" : MonitorLeft, "bottom" : MonitorBottom,  "right" : MonitorRight, "top" : MonitorTop, "width" : MonitorRight - MonitorLeft, "height" : MonitorBottom - MonitorTop, "rleft" : MonitorRealLeft, "rbottom" : MonitorRealBottom,  "rright" : MonitorRealRight, "rtop" : MonitorRealTop, "rwidth" : MonitorRealRight - MonitorRealLeft, "rheight" : MonitorRealBottom - MonitorRealTop}
  }
  if returnarray
    return monitorsizesarray
}
