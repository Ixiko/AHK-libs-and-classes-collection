
Class ProcessMonitor
{
    m_ProcessName :=
    m_ProcessPath :=
    m_ProcessID :=
    m_ActiveWindowhWnd :=
    m_ActiveWindowTitle :=
    m_WindowClassName := 
    m_ActiveControlName :=
    m_ActiveControlText :=
    m_ActiveControlHWnd :=
    m_ProcessExe :=
    m_MyPID :=
    m_IsMine :=
    m_root_exe_extra_data :=
    Init()
    {
        Debug.WriteStackPush("ProcessMonitor Init Start",Debug.ErrLevelCore)
        ProcessMonitor.m_WinActiveTitle := ""
        ProcessMonitor.m_ProcessName := ""
        ProcessMonitor.m_ProcessExe := ""
        ProcessMonitor.m_ProcessPathName := ""
        ProcessMonitor.m_WindowClassName := ""
        ProcessMonitor.m_ActiveControlText := ""
        ProcessMonitor.m_ActiveControlhWnd := 0
        ProcessMonitor.m_IsMine:=False
        ProcessMonitor.m_root_exe_extra_data := 0
        

        ProcessMonitor.m_MyPID := DllCall("GetCurrentProcessId")
        

        EventManager.AddHandler(ProcessMonitor)
        Debug.WriteStackPop("ProcessMonitor Init End",Debug.ErrLevelCore)
    }
    GetProcessExe()
    {
        return ProcessMonitor.m_ProcessExe
    }
    GetProcessName()
    {
        return ProcessMonitor.m_ProcessName
    }
    GetProcessPath()
    {
        return ProcessMonitor.m_ProcessPath
    }
    GetProcessID()
    {
        return ProcessMonitor.m_ProcessID
    }
    GetActiveWindowhWnd()
    {
        return ProcessMonitor.m_ActiveWindowhWnd
    }
    GetActiveWindowTitle()
    {
        return ProcessMonitor.m_ActiveWindowTitle
    }
    GetActiveControlName()
    {
        return ProcessMonitor.m_ActiveControlName
    }
    GetActiveControlText()
    {
        return ProcessMonitor.m_ActiveControlText
    }
    GetActiveWindowClassName()
    {
        return ProcessMonitor.m_WindowClassName
    }
    GetActiveControlhWnd()
    {
        return ProcessMonitor.m_ActiveControlHWnd
    }
    IsWindowMine()
    {
        return ProcessMonitor.m_IsMine
    }
    
    
    FindMatchingItem()
    {
        ret_extra_data:=ProcessMonitor.m_root_exe_extra_data
        Stack:=Debug.WriteStackPush("ProcessMonitor.FindMatchingItem() Start",Debug.ErrLevelCore)
        ;Selects a window context item in the treeview if found one matching what the process monitor found

        ;Get a window context item list
        TVHelper.IgnoreDisabled(True)
        arr := TVHelper.recurse_filter(ProcessMonitor.m_root_exe_extra_data.GetTreeviewItemIndex(), [TV_TYPES.WINDOWCONTEXT],[TV_TYPES.APPS,TV_TYPES.EXE,TV_TYPES.GROUP])
        TVHelper.IgnoreDisabled(False)
        Debug.WriteStack("For Each Window Context Item Found",Debug.ErrLevelCore)
        for Each, item in arr ;loop through the window context item list and comapre each field to what the process monitor found
        {
            Debug.WriteStackPush("Is RegExMatch On Class Name?",Debug.ErrLevelCore)
            ClassName := item.GetClassName()
            if(ClassName = "*" || ClassName == "") ;convert * to find all
            {
                ClassName := "[\s\S]*"
            }
            if(RegExMatch(ProcessMonitor.GetActiveWindowClassName(), ClassName)) ;class mattch?
            {
                Debug.WriteStackPush("Yes RegEx Match on ClassName",Debug.ErrLevelCore)
                Debug.WriteStack("Is RegExMatch on Title?",Debug.ErrLevelCore)
                Title := item.GetTitle()
                if(Title = "*" || Title == "")
                {
                    Title := "[\s\S]*"
                }
                if(RegExMatch(ProcessMonitor.GetActiveWindowTitle(), Title)) ;Title match?
                {
                    Debug.WriteStackPush("Yes RegEx Match on Title",Debug.ErrLevelCore)
                    Debug.WriteStack("Is RegExMatch on Control Name?",Debug.ErrLevelCore)
                    ControlName := item.GetControlName()
                    if(ControlName = "*" || ControlName == "")
                    {
                        ControlName := "[\s\S]*"
                    }
                    if(RegExMatch(ProcessMonitor.GetActiveControlName(), ControlName)) ;ControlName match
                    {
                        Debug.WriteStackPush("RegEx Match on Control Name",Debug.ErrLevelCore)
                        Debug.WriteStack("Is RegExMatch on Control Tex?",Debug.ErrLevelCore)
                        ControlText := item.GetControlText()
                        if(ControlText = "*" || ControlText == "")
                        {
                            ControlText := "[\s\S]*"
                        }
                        if(RegExMatch(ProcessMonitor.GetActiveControlText(), ControlText)) ;control text match?
                        {
                            Debug.WriteStackPush("Yes RegEx Match on Control Text",Debug.ErrLevelCore)
                            ret_extra_data := item
                            Debug.WriteStackPop("Found! Break!!!",Debug.ErrLevelCore)
                            break
                        }
                        Debug.WriteStackPop("}",Debug.ErrLevelCore)
                    }
                    Debug.WriteStackPop("}",Debug.ErrLevelCore)
                }
                Debug.WriteStackPop("}",Debug.ErrLevelCore)
            }
            Debug.WriteStackPop("}",Debug.ErrLevelCore)
        }
        Debug.SetStack(Stack)
        Debug.WriteStack("For Each End",Debug.ErrLevelCore)
                
        arr := TVHelper.ClearArray(arr)

        
        Debug.WriteStackPop("ProcessMonitor.FindMatchingItem() End",Debug.ErrLevelCore)
        return ret_extra_data
    }
    OnProcessChanged()
    {
        Debug.WriteStackPush("ProcessMonitor.OnProcessChanged() Start",Debug.ErrLevelCore)
        ;ProcessMonitor.SelectTVProcess()
        if(!ProcessMonitor.IsWindowMine() && !gEditing)
        {
            TVHelper.IgnoreDisabled(True)
            exeTVItem:=FindFirstItem.FindMatchingExeItem(ProcessMonitor.GetProcessExe())
            exeExtraData := TVHelper.ToExtraData(exeTVItem)
            EventManager.SetActiveProcess(exeExtraData)
            TVHelper.IgnoreDisabled(False)
        }
        Debug.WriteStackPop("ProcessMonitor.OnProcessChanged() End",Debug.ErrLevelCore)
    }
    OnWindowChanged()
    {
        Debug.WriteStackPush("ProcessMonitor.OnWindowChanged() Start",Debug.ErrLevelCore)
        ;ProcessMonitor.SelectTVWindowContext()
        if(!ProcessMonitor.IsWindowMine() && !gEditing)
        {
            EventManager.SetActiveItem(ProcessMonitor.FindMatchingItem())
        }
        Debug.WriteStackPop("ProcessMonitor.OnWindowChanged() End",Debug.ErrLevelCore)
    }
    OnControlChanged()
    {
        Debug.WriteStackPush("ProcessMonitor.OnControlChanged() Start",Debug.ErrLevelCore)
        ;Control change is handled by the window seletor
        ;ProcessMonitor.SelectTVWindowContext()
        if(!ProcessMonitor.IsWindowMine() && !gEditing)
        {
            EventManager.SetActiveItem(ProcessMonitor.FindMatchingItem())
        }
        Debug.WriteStackPop("ProcessMonitor.OnControlChanged() End",Debug.ErrLevelCore)
    }


    ;event manager notification
    OnProcessActivate(extra_data)
    {
        ;extra data is a exe item, can be 0, can be the same as previoulsy activated one
        ;this class decides to be sure not to do things twice if same
        ;right now this class triggered this event but nonetheless re-grab this exe extra data
        ProcessMonitor.m_root_exe_extra_data := extra_data
        
    }
    ;event manager notification
    OnProcessDeactivate(extra_data)
    {
        ;extra data is a exe item, can be 0, can be the same as previoulsy activated one
        ;this class decides to be sure not to do things twice if same
        ;right now this class triggered this event, still, nuke it untill we get the Activate
        ProcessMonitor.m_root_exe_extra_data := 0
    }
    ;event manager notification
    OnItemActivate(extra_data)
    {
        ;extra data is a command, context or window context, can be 0, can be the same as previoulsy activated one
        ;this class decides to be sure not to do things twice if same
    }
    ;event manager notification
    OnItemDeactivate(extra_data)
    {
        ;extra data is a command, context or window context, , can be 0, can be the same as previoulsy activated one
        ;this class decides to be sure not to do things twice if same
    }
    ;event manager notification
    OnTimer()
    {
        ;Called every n millisecs by the singleton EventManager Timer
    
        
        ;window and process change detection
        ;Get the active window
        hwnd := WinExist("A")
        ProcessHasChanged:=false
        WindowHasChanged:=false
        ControlHasChanged:=false
        if(hwnd != ProcessMonitor.m_ActiveWindowhWnd && hwnd !=0) ;not same as old?
        {
            WindowHasChanged := true
            Debug.WriteStackPush("ProcessMonitor.OnTimer() Window Change: " . hwnd,Debug.ErrLevelCore)
            WinGet, PID, PID, ahk_id %hwnd% ;get pid

            
            if(ProcessMonitor.m_ProcessID != PID) ;pid changed
            {
                Debug.WriteStack("Process Changed: " . PID,Debug.ErrLevelCore)
                ProcessMonitor.m_ProcessID := PID
                ProcessHasChanged:=true
            }

            ProcessMonitor.m_ActiveWindowhWnd := hwnd ;set the window
            WinGetTitle, title, ahk_id %hwnd%
            ProcessMonitor.m_ActiveWindowTitle := title

            WinGet, PPath, ProcessPath, ahk_id %hwnd% ;get the window process file and path
            ;get component parts of the path
			SplitPath, PPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

            ProcessMonitor.m_IsMine := false
            if(ProcessMonitor.m_ProcessID == ProcessMonitor.m_MyPID) ;check and see if my window
            {
                Debug.WriteStack("PID Is Mine",Debug.ErrLevelCoreInfo)
                ProcessMonitor.m_IsMine := true
            }

            if(OutNameNoExt!=ProcessMonitor.m_ProcessName) ;Process changed? update path
            {
                ProcessMonitor.m_ProcessExe := OutFileName
                ProcessMonitor.m_ProcessName := OutNameNoExt
                ProcessMonitor.m_ProcessPath := PPath
            }
            

            WinGetClass, ClassName , ahk_id %hwnd% ;get the class
            ProcessMonitor.m_WindowClassName := ClassName
            

            if(!ProcessMonitor.m_IsMine) ;call the treeview updating
            {
                Debug.WriteStack("",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("------------------",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("NEW WINDOW DETECTED",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("hWnd: " . ProcessMonitor.GetActiveWindowhWnd(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Class: " . ProcessMonitor.GetActiveWindowClassName(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Title: " . ProcessMonitor.GetActiveWindowTitle(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Process: " . ProcessMonitor.GetProcessName(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Process ID: " . ProcessMonitor.GetProcessID(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Path: " . ProcessMonitor.GetProcessPath(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("------------------",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("",Debug.ErrLevelUsefulInfo)
                
                
            }
            
            Debug.WriteStackPop("ProcessMonitor.OnTimer() Window Change End",Debug.ErrLevelCore)
        }
        ;control change detection
        if(hwnd == ProcessMonitor.m_ActiveWindowhWnd && !ProcessMonitor.m_IsMine)
        {
            ;ttl := ProcessMonitor.m_WinActiveTitle ;get the active control name
            ;ControlGetFocus, OutputVar, %ttl%
            ;ControlGetFocus, OutputVar, % "ahk_id " hwnd
                ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
                ControlGet, hCtl, Hwnd,, % vCtlClassNN, % "ahk_id " hWnd
            ;if(OutputVar != ProcessMonitor.GetActiveControlText()) ;if changed
                if(hCtl != ProcessMonitor.GetActiveControlhWnd())
            {
                    ControlGetFocus, OutputVar, % "ahk_id " hwnd
                Debug.WriteStackPush("ProcessMonitor.OnTimer() Control Change: " . OutputVar,Debug.ErrLevelCore)
                ;ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
                
                ;ControlGet, hCtl, Hwnd,, % vCtlClassNN, % "ahk_id " hWnd
                ProcessMonitor.m_ActiveControlHWnd := hCtl
                ProcessMonitor.m_ActiveControlName := OutputVar
                ControlName := ProcessMonitor.m_ActiveControlName
                ControlGetText, OutputVar, %ControlName% ;get the control text
                ProcessMonitor.m_ActiveControlText := OutputVar
                Debug.WriteStack("",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("------------------",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("NEW CONTROL DETECTED",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Name: " . ProcessMonitor.GetActiveControlName(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("hWnd: " . ProcessMonitor.GetActiveControlhWnd(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("Text: " . ProcessMonitor.GetActiveControlText(),Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("------------------",Debug.ErrLevelUsefulInfo)
                Debug.WriteStack("",Debug.ErrLevelUsefulInfo)
                if(!ProcessMonitor.m_IsMine) ;perform the control changed event
                {
                    ControlHasChanged:=true
                    
                }
                Debug.WriteStackPop("ProcessMonitor.OnTimer() Control Change End",Debug.ErrLevelCore)
                
            }
        }
        if(ProcessHasChanged)
        {
            ProcessMonitor.OnProcessChanged()
        }
        If(WindowHasChanged)
        {
            ProcessMonitor.OnWindowChanged()
        }
        if(ControlHasChanged)
        {
            ProcessMonitor.OnControlChanged()
        }
        
    }
}



