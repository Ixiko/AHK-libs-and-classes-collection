; Title:     Dock 
;            *Dock desired top level windows (dock clients) to any top level window (dock host)* 
;
; 
;
;			 Using dock module you can glue your or third-party windows to any top level window.
;			 Docked windows in module terminology are called Clients and the window that keeps their 
;			 position relative to itself is called Host. Once Clients are connected to the Host, this
;			 group of windows will behave like single window - moving, sizing, focusing, hiding and other
;			 OS events will be handled by the module so that the "composite window" behaves like the single window.
;
;			 Module uses system hook to monitor windows changes, so it's idle when it is not aranging windows.
; 
;---------------------------------------------------------------------------------------------------------------------------------- 
; Function:  Dock 
;            Instantiate dock of given client upon host. Multiple clients per one host are supported. 
; 
; 
; Parameters: 
; 
;            pClientId   - HWND of the Client GUI. Dock is created or updated (if already exists) for that hwnd.    
;                       If "+" is the first char of pClientId, Dock will first show the window if it is hidden (for smoother initialisation) 
;            pDockDef   - Dock definition, see bellow. To remove dock client pass "-". 
;                       If you pass empty string, client will be docked to the host according to its current position relative to the host. 
;            reset      - internal parameter, do not use. 
; 
; Globals: 
;            Dock_HostID   - Sets docking host 
;         Dock_OnHostDeath - Sets label that will be called when host dies. Afterwards, module will disable itself using Dock_Toggle(false).
;
; Dock definition:  
;			Dock definition is string containing 10 numbers that describe Client positon relative to the Host. The big number of parameters allows
;			fine tuning of Client's postion and basicly every setup is possible. Parameters are grouped in 4 classes - first 3 influence X coordinate 
;			of the client, next 3 Y coordinate, next 2 Client's width and final 2 Client's height:
;			
;> 					xhw,xw,xd,  yhh,yh,yd [, whw,wd,  hhh,hd] 
;> 						X			Y			W		H
; 
;            o The *X* coordinate of the top, left corner of the client window is computed as 
;            *HostX + xhw*HostWidth + xw*ClientWidth + xd*, with the parameters xhw, xw and xd 
; 
;            o The *Y* coordinate of the top, left corner of the client window is computed as 
;            *HostY + yhh*HostHeight + yh*ClientHeight + yd*, with the parameters yhh, yh and yd 
; 
;            o The width *W* of the client window is computed as *whw*HostWidth + wd*, with the parameters whw and wd. 
;              Skip to let the client have its own width (or set to 0,0) 
; 
;            o The height *H* of the client window is computed as *hhh*HostHeight + hd*, with the parameters hhh and hd. 
;              Skip to let the client have its own height (or set to 0,0) 
; 
; Returns: 
;            "OK" or "Err" with text describing last succesiful or failed action.
;
; Remarks:
;			You must set DetectHiddenWindows if Host is practicing hiding. Otherwise, Dock will treat Host hiding as death.
;			All clients will be hidden once host is terminated or it becomes hidden itself.
;
;			Use SetBatchLines, -1 with dock module for fluid client movement. You will experience delay in clients moving otherwise.
;			However, if CPU usage is very high, you might experience a delay in client movement anyway.
;
;			If you are using *Gui, Show* command imediately before registering client, make sure you specify *NoActivate* flag.
;
;			Currently its not supported to set Client window on top Host window. AlwaysOnTop (or TopMost) flag will not influence 
;			behavior of the module so avoid setups in which client is entirely covered by the Host.
; 
; Example: 
;>      Dock(Client1ID, "0,-1,-10, 0,0,0, 0,63, 1,0")      ;top left, host height 
;>      Dock(Client2ID, "0,0,0, 0,-1,-5, 1,0,0,30")        ;top above, host width 
; 
Dock(pClientID, pDockDef="", reset=0) {                    ;Reset is internal parameter, used by Dock_Shutdown 
   local cnt, new, cx, cy, hx, hY 
   static init=0, idDel 

    if (reset)                                             ;Used by Dock Shutdown to reset the function 
		return init := 0 

	if !init
		Dock_aClient[0] := 0

   cnt := Dock_aClient[0] 

   ;remove dock client ? 
   if (pDockDef="-") and (Dock_%pClientID%){ 

      idDel := Dock_%pClientID% 

      loop, 10 
         Dock_%pClientID%_%A_Index% := 0 
      Dock_%pClientID% := "" 
       
      ;move last one to the place of the deleted one 
      Dock_aClient[%idDel%] := Dock_aClient[%cnt%], Dock_aClient[%cnt%] := "", Dock_aClient[0]-- 
      return "OK - Remove" 
   } 

   if *&pClientID = 43         ; 43 = "+" 
      DllCall("ShowWindow", "uint", pClientID := SubStr(pClientID, 2), "int", 4)  ;using this isntead WinShow cuz of A_WinDelay 


   if pDockDef = 
   { 
      WinGetPos hX, hY,,, ahk_id %Dock_HostID% 
      WinGetPos cX, cY,,, ahk_id %pClientID% 
      pDockDef := "0,0," cX - hX ",  0,0," cY - hY 
   } 

   ;add new dock client if it not exists, or update its dock settings if it exists 
   pDockDef .= ",0,0,0,0"      ;if user skiped last 4 params, add them here. If user gave 10 params, bottom loop will exit anyway. 
   loop, parse, pDockDef, `,,%A_Space%%A_Tab% 
         if A_Index > 10       
            break 
         else Dock_%pClientID%_%A_Index% := A_LoopField 


	if !Dock_%pClientID% {
		Dock_%pClientID%   := ++cnt, 
		Dock_aClient[%cnt%] := pClientId 
		Dock_aClient[0]++ 
	}

   ;start the dock if its not already started
   If !init { 
	
      init++, Dock_hookProcAdr := RegisterCallback("Dock_HookProc")
      return Dock_Toggle(true)	 
   } 

   Dock_Update()
   return "OK" 
}       


;----------------------------------------------------------------------------------------------------- 
;Function:  Dock_Shutdown 
;			Uninitialize dock module. This will clear all clients and internal data and unregister hooks. 
;			Dock_OnHostDeath, Dock_HostId are kept on user values. 
; 
Dock_Shutdown() { 
   local cID 

   Dock_Toggle(false) 
   DllCall("GlobalFree", "UInt", Dock_hookProcAdr), Dock_hookProcAdr := "" 
   Dock(0,0,1)         ;reset dock function 

   ;erase clients 
   loop, % Dock_aClient[0] 
   { 
      cId := Dock_aClient[%A_Index%], Dock_aClient[%A_Index%] := "" 
      Dock_%cID% := "" 
      loop, 10 
         Dock_%cID%_%A_Index% := "" 
   }
}    

;----------------------------------------------------------------------------------------------------- 
;Function: Dock_Toggle 
;          Toggles the dock module ON or OFF.
; 
;Parameters: 
;         enable - Set to true to set the dock ON, set to FALSE to turn it OFF. Skip to toggle. 
; 
;Remarks: 
;         Use Dock_Toggle(false) to suspend the dock module (to unregister hook), leaving its internal data in place. 
;         This is different from Dock_Shutdown as latest removes module completely from memory and 
;         unregisters its clients. 
;          
;         You can also use this function to temporary disable module when you don't want dock update routine to interrupt your time critical sections. 
;
Dock_Toggle( enable="" ) { 
   global 

   if Dock_hookProcAdr = 
      return "ERR - Dock must be loaded." 

   if enable = 
      enable := !Dock_hHook1 
   else if (enable && Dock_hHook1)
		return	"ERR - Dock already enabled"

   if !enable 
      API_UnhookWinEvent(Dock_hHook1), API_UnhookWinEvent(Dock_hHook2), API_UnhookWinEvent(Dock_hHook3), Dock_hHook3 := Dock_hHook1 := Dock_hHook2 := "" 
   else  { 
      Dock_hHook1 := API_SetWinEventHook(3,3,0,Dock_hookProcAdr,0,0,0)				; EVENT_SYSTEM_FOREGROUND 
      Dock_hHook2 := API_SetWinEventHook(0x800B,0x800B,0,Dock_hookProcAdr,0,0,0)	; EVENT_OBJECT_LOCATIONCHANGE 
	  Dock_hHook3 := API_SetWinEventHook(0x8002,0x8003,0,Dock_hookProcAdr,0,0,0)	; EVENT_OBJECT_SHOW, EVENT_OBJECT_HIDE

      if !(Dock_hHook1 && Dock_hHook2 && Dock_hHook3) {	   ;some of them failed, unregister everything
         API_UnhookWinEvent(Dock_hHook1), API_UnhookWinEvent(Dock_hHook2), API_UnhookWinEvent(Dock_hHook3) 
         return "ERR - Hook failed" 
      } 

	 Dock_Update() 
   } 
} 

;==================================== INTERNAL ====================================================== 
Dock_Update() { 
   local hX, hY, hW, hh, W, H, X, Y, cx, cy, cw, ch, fid, wd, cid 
   static gid=0   ;fid & gid are function id and global id. I use them to see if the function interupted itself. 

   wd := A_WinDelay 
   SetWinDelay, -1 
   fid := gid += 1 
   WinGetPos hX, hY, hW, hH, ahk_id %Dock_HostID% 
;   OutputDebug %hX% %hY% %hW% %hH%	 %event%

   ;xhw,xw,xd,  yhh,yh,yd,  whw,wd,  hhh,hd 
   loop, % Dock_aClient[0] 
   { 
      cId := Dock_aClient[%A_Index%] 
      WinGetPos cX, cY, cW, cH, ahk_id %cID% 
      W := Dock_%cId%_7*hW + Dock_%cId%_8,  H := Dock_%cId%_9*hH + Dock_%cId%_10 
      X := hX + Dock_%cId%_1*hW + Dock_%cId%_2* (W ? W : cW) + Dock_%cId%_3
      Y := hY + Dock_%cId%_4*hH + Dock_%cId%_5* (H ? H : cH) + Dock_%cId%_6 

	  if (fid != gid)   {				;some newer instance of the function was running, so just return (function was interupted by itself). Without this, older instance will continue with old host window position and clients will jump to older location. This is not so visible with WinMove as it is very fast, but SetWindowPos shows this in full light. 
         SetWinDelay, %wd% 
		 break
      } 

      if (W+H)				
           WinMove ahk_id %cId%,,X,Y, W ? W : "" ,H ? H : "" 
      else WinMove ahk_id %cId%,,X,Y 
  } 
	SetTimer, Dock_SetZOrder, -20		;set z-order in another thread (protects also from spaming z-order changes when host is rapidly moved).
	SetWinDelay, %wd% 
} 


Dock_SetZOrder: 
   loop, % Dock_aClient[0] 
      DllCall("SetWindowPos", "uint", Dock_aClient[%A_Index%], "uint", Dock_HostID, "uint", 0, "uint", 0, "uint", 0, "uint", 0, "uint", 19) ;SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE

;   OutputDebug setzorder
return 

Dock_SetZOrder_OnClientFocus:
   loop, % Dock_aClient[0] 
      DllCall("SetWindowPos", "uint", Dock_aClient[%A_Index%], "uint", A_Client, "uint", 0, "uint", 0, "uint", 0, "uint", 0, "uint", 19) ;SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE

  DllCall("SetWindowPos", "uint", Dock_HostID, "uint", A_Client, "uint", 0, "uint", 0, "uint", 0, "uint", 0, "uint", 19) ;SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE
;  OutputDebug onclientfocus
return 

;-----------------------------------------------------------------------------------------
; Events :
;			3	  - Host is set to foreground
;			32779 - Location change
;			32770 - Show
;			32771 - Hide (also called on exit)
;
Dock_HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime ) { 
   global 

	if (event = 3) 
		loop, % Dock_aClient[0]
 		  if (hwnd = Dock_aClient[%A_Index%])
		  {
			   A_Client := hwnd
			   SetTimer, Dock_SetZOrder_OnClientFocus, -20 
			   return
		  }			

	If (hwnd != Dock_HostID){				
      if !WinExist("ahk_id " Dock_HostID) && IsLabel(Dock_OnHostDeath)
	  {
 		 Dock_Toggle(false)
		 gosub %Dock_OnHostDeath% 
	  }
	  return 
	} 

	if (idChild or idObject)
		return
	

	if event in 32770,32771
	{
	   event := (event - 32771) * -5
	   loop, % Dock_aClient[0] 
			DllCall("ShowWindow", "uint", Dock_aClient[%A_Index%], "uint",  event)
	}

	Dock_Update() 
} 


API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) { 
   DllCall("CoInitialize", "uint", 0) 
   return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "uint", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags) 
} 

API_UnhookWinEvent( hWinEventHook ) { 
   return DllCall("UnhookWinEvent", "uint", hWinEventHook) 
} 

;--------------------------------------------------------------------------------------------------------------------- 
; Group: Presets
;		 This section contains some common docking setups. You can just copy/paste dock definition strings in your script.
;
;		0,-1,0,   0,0,0					- top left, own size
;		0,-1,10,  0,0,0					- top left, own size, 10px padding 
;		0,-1,0,   0,0,0,   0,0,   1,0	- top left, use host's height, keep own width
;		0,-1,20,  0,0,0,   0,50,  1,0	- top left, use host's height, set width to 50 and padding to 20px
;		0,-1,0,   .5,-.5,0				- middle left, keep own size
;				
;		0,-1,0,   1,-1,0,  0,20,  0,20	- bottom left, fixed width & height to 20px
;		0,-1,0,   1,-1,0,  0,0,  .5,0   - bottom left, keep height half of the Host's height, keep own width
;		1,-1,0,   1,0,0,   .25,0  .25,0	- bottom right, width and height 1/5 of the Host
;
;		0,0,0,	  1,0,0,    1,0,  0,100 - below the host, use host's width, height = 100
;		0,0,0,	  0,-1,-5,  1,0   	    - above the host, use host's width, keep own height, 5px padding
;		.5,-.5,0, 0,-1,0,   0,200, 0,30	- center above the host, width=200, height=30
;		.5,-.5,0, 1,0,0,   0.3,0, 0,30	- center bellow the host, use 1/3 Host's width, height=30
;
;		1,0,0,   0,0,0					- top right, own size
;		1,0,0,   0,0,0,     0,40,  1,0  - top right, use host's height, width = 40
;       1,0,0,	 .5,-.5,0				- middle right, keep own size

;--------------------------------------------------------------------------------------------------------------------- 
; Group: About 
;      o Ver 1.0 by majkinetor. See http://www.autohotkey.com/forum/topic19400.html 
;	   o Thank You's: Laszlo, JGR, Joy2World, bmcclure 
;      o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.
