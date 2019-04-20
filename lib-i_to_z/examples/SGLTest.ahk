#NoEnv
#Include SGL.ahk

; This is the DEMO authentication code, every  regular SG−Lock user gets its own unique authentication code.
AuthentCode := [0xF574D17B, 0xA94628EE, 0xF2857A8F, 0x69346B4A
               ,0x4136E8F2, 0x89ADC688, 0x80C2C1D4, 0xA8C6327C
               ,0x1A72699A, 0x574B7CA0, 0x1E8D3E98, 0xD7DEFDC5]
               
SGL_Init()
MsgBox, 0, Test SGL_Authent(), % SGL_Authent(AuthentCode)
ExitApp