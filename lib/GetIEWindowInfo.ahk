;http://www.autohotkey.com/forum/topic19255.html

COM_Init()
psh :=   COM_CreateObject("Shell.Application")
psw :=   COM_Invoke(psh, "Windows")
Loop, %   COM_Invoke(psw, "Count")
   pwb := COM_Invoke(psw, "Item", A_Index-1), sInfo .= COM_Invoke(pwb, "hWnd") . " : """ . COM_Invoke(pwb, "LocationURL") . """,""" . COM_Invoke(pwb, "LocationName") . """,""" . COM_Invoke(pwb, "StatusText") . """,""" . COM_Invoke(pwb, "Name") . """,""" . COM_Invoke(pwb, "FullName") . """`n", COM_Release(pwb)
COM_Release(psw)
COM_Release(psh)
COM_Term()

MsgBox, % sInfo

