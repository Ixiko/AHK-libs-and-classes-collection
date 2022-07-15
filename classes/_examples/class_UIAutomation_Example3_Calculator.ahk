#NoEnv
#SingleInstance force
#include ..\class_UIA_Interface.ahk

Run, calc.exe
UIA := UIA_Interface() ; Initialize UIA interface
WinWaitActive, Calculator
cEl := UIA.ElementFromHandle(WinExist("Calculator")) ; Get the element for the Calculator window
; All the calculator buttons are of "Button" ControlType, and if the system language is English then the Name of the elements are the English words for the buttons (eg button 5 is named "Five", = sign is named "Equals")
cEl.FindFirstBy("Name=Six").Click() ; Find the first "Six" button by name and click it
cEl.FindFirstBy("Name=Five AND ControlType=Button").Click() ; Specify both name "Five" and control type "Button"
cEl.FindFirstByName("Plus").Click() ; An alternative method to FindFirstBy("Name=Plus")
cEl.FindFirstByNameAndType("Four", UIA.ButtonControlTypeId).Click() ; The type can be specified as "Button", UIA.ButtonControlTypeId, UIA_Enum.UIA_ButtonControlTypeId, or 50000 (which is the value of UIA.ButtonControlTypeId)
cEl.FindFirstByNameAndType("Equals", "Button").Click()
ExitApp
