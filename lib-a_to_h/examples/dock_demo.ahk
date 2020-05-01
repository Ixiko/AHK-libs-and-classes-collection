; #Include Dock.ahk
SetBatchLines, -1 
#SingleInstance, force 
   
   Msgbox This test will monitor Notepad appearance and add customizable number of dock clients to its left side.

   host := "ahk_class Notepad" 
   clientNo := 5 


   loop, %clientNo% 
   { 
      Gui %A_Index%:+LastFound +ToolWindow +Border +Resize -Caption 
      Gui,%A_Index%:Add, Button, 0x8000, %A_Index% 
      c%A_Index% := WinExist() 

      Dock("+" c%A_Index%, "0,-1,-10, 0,0," A_Index*50 ",0,50,0,50") 
   } 

   Dock_OnHostDeath := "OnHostDeath" 

return 

FindHost: 
   if Dock_HostID := WinExist(host) 
   { 
      SetTimer, FindHost, OFF 
       loop, %clientNo% 
         DllCall("ShowWindow", "uint", c%A_Index%, "uint", 5)     
       
      Dock_Toggle(true) 
   } 
return 

OnHostDeath: 
   SetTimer, FindHost, 100 
return 
