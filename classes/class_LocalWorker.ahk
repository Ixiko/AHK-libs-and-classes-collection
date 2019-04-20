class LocalWorker
{
    static WorkerIndex := 0

    __New(Job,WorkerCode)
    {
        ;obtain the code for the worker
        WorkerCode := this.GetWorkerTemplate(WorkerCode)

        ;set up message handler
        OnMessage(0x4A,"LocalWorkerReceiveData") ;WM_COPYDATA

        ;create named pipes to hold the worker code
        this.base.WorkerIndex ++
        PipeName := "\\.\pipe\ParallelistWorker" . A_ScriptHwnd . "_" . this.base.WorkerIndex ;create a globally unique pipe name
        hTempPipe := DllCall("CreateNamedPipe","Str",PipeName,"UInt",2,"UInt",0,"UInt",255,"UInt",0,"UInt",0,"UInt",0,"UInt",0) ;temporary pipe
        If hTempPipe = -1
            throw Exception("Could not create temporary named pipe.")
        hExecutablePipe := DllCall("CreateNamedPipe","Str",PipeName,"UInt",2,"UInt",0,"UInt",255,"UInt",0,"UInt",0,"UInt",0,"UInt",0) ;executable pipe
        If hExecutablePipe = -1
            throw Exception("Could not create executable named pipe.")

        ;start the worker
        CodePage := A_IsUnicode ? 1200 : 65001 ;UTF-16 or UTF-8
        Run, % """" . A_AhkPath . """ /CP" . CodePage . " """ . PipeName . """ " . A_ScriptHwnd . " " . &Job . " " . &this,, UseErrorLevel, WorkerPID
        If ErrorLevel
        {
            DllCall("CloseHandle","UPtr",hTempPipe) ;close the temporary pipe
            DllCall("CloseHandle","UPtr",hExecutablePipe) ;close the executable pipe
            throw Exception("Could not start worker.")
        }

        ;wait for the worker to connect to the temporary pipe and close it
        DllCall("ConnectNamedPipe","UPtr",hTempPipe,"UPtr",0)
        DllCall("CloseHandle","UPtr",hTempPipe)

        ;wait for the worker to connect the executable pipe and transfer the code
        DllCall("ConnectNamedPipe","UPtr",hExecutablePipe,"UPtr",0)
        DllCall("WriteFile","UPtr",hExecutablePipe,"Str",WorkerCode,"UInt",StrLen(WorkerCode) << !!A_IsUnicode,"UPtr",0,"UPtr",0)
        DllCall("CloseHandle","UPtr",hExecutablePipe) ;send the script code

        ;obtain a handle to the worker
        DetectHidden := A_DetectHiddenWindows
        DetectHiddenWindows, On
        WinWait, ahk_pid %WorkerPID%,, 5 ;wait up to five seconds for the script to start
        If ErrorLevel ;worker could not be found
        {
            DetectHiddenWindows, %DetectHidden%
            Process, Close, %WorkerPID% ;close the worker process
            throw Exception("Could not obtain worker handle.")
        }
        this.hWorker := WinExist() ;retrieve the worker ID
        DetectHiddenWindows, %DetectHidden%
        ;wip: check for code failures by using a startup message that also verifies if the IPC is working
    }

    __Delete()
    {
        DetectHidden := A_DetectHiddenWindows
        DetectHiddenWindows, On
        WinClose, % "ahk_id " . this.hWorker ;send the WM_CLOSE message to the worker to allow it to clean up
        WinWaitClose, % "ahk_id " . this.hWorker ;wait for the worker to close
        DetectHiddenWindows, %DetectHidden%
    }

    Send(ByRef Data,Length)
    {
        ;set up the COPYDATASTRUCT structure
        VarSetCapacity(CopyDataStruct,4 + (A_PtrSize << 1)) ;structure contains an integer field and two pointer sized fields
        NumPut(0,CopyDataStruct) ;set data type
        NumPut(Length,CopyDataStruct,A_PtrSize,"UInt") ;insert the length of the data to be sent
        NumPut(&Data,CopyDataStruct,A_PtrSize << 1) ;insert the address of the data to be sent

        ;send the data to the worker
        DetectHidden := A_DetectHiddenWindows
        DetectHiddenWindows, On
        SendMessage, 0x4A, 0, &CopyDataStruct,, % "ahk_id " . this.hWorker ;WM_COPYDATA
        DetectHiddenWindows, %DetectHidden%
        If (ErrorLevel = "FAIL") ;could not send the message
            throw Exception("Could not send data to worker.")
    }

    GetWorkerTemplate(WorkerCode)
    {
        Code = 
        (
        ;#NoTrayIcon

        ParallelistMaster = `%1`% ;obtain a handle to the master
        ParallelistJob = `%2`% ;obtain a handle to the job
        ParallelistWorkerEntry = `%3`% ;obtain a handle to the master's worker entry

        OnMessage(0x4A,"ParallelistWorkerReceiveData") ;WM_COPYDATA

        ParallelistWorker := new Worker

        SetTimer, ParallelistCheckStatus, 1000
        Return

        class ParallelistTask
        {
            static Data := ""
            static Result := ""
        }

        ;incoming message handler
        ParallelistWorkerReceiveData(wParam,lParam)
        {
            global ParallelistData
            Length := NumGet(lParam + A_PtrSize,0,"UInt") ;retrieve the length of the data

            ;store the data
            ParallelistTask.SetCapacity("Data",Length)
            DllCall("RtlMoveMemory","UPtr",ParallelistTask.GetAddress("Data"),"UPtr",NumGet(lParam + A_PtrSize + 4),"UPtr",Length)

            ;clear the result
            ParallelistTask.Result := ""

            SetTimer, ParallelistProcessTask, -0 ;dispatch a subroutine to handle the task processing
            Return, 1 ;successfully processed data ;wip: allow errors to be propagated to the main script
        }

        ParallelistProcessTask:
        ParallelistProcessTask(ParallelistWorker,ParallelistTask,ParallelistJob,ParallelistWorkerEntry,ParallelistMaster)
        Return

        ParallelistProcessTask(Worker,Task,pJob,pWorker,Master)
        {
            ;process the task
            Status := Worker.Process(Task)
            If Status Is Not Integer
                throw Exception("Task status is not integer.") ;wip: do something else about it

            ;set up the result structure
            Length := Task.GetCapacity("Result")
            VarSetCapacity(ResultStruct,Length + (A_PtrSize * 3)) ;allocate the result structure
            NumPut(pJob,ResultStruct) ;insert the address of the job
            NumPut(pWorker,ResultStruct,A_PtrSize) ;insert the address of the worker
            NumPut(Length,ResultStruct,A_PtrSize * 2) ;insert the length of the data
            DllCall("RtlMoveMemory","UPtr",&ResultStruct + (A_PtrSize * 3),"UPtr",Task.GetAddress("Result"),"UPtr",Length) ;copy data to the result structure

            ;set up the COPYDATASTRUCT structure
            VarSetCapacity(CopyDataStruct,4 + (A_PtrSize << 1)) ;structure contains an integer field and two pointer sized fields
            NumPut(Status,CopyDataStruct) ;insert the task status
            NumPut(Length,CopyDataStruct,A_PtrSize,"UInt") ;insert the length of the data to be sent
            NumPut(&ResultStruct,CopyDataStruct,A_PtrSize << 1) ;insert the address of the result structure

            ;send the result to the master
            DetectHidden := A_DetectHiddenWindows
            DetectHiddenWindows, On
            SendMessage, 0x4A, 0, &CopyDataStruct,, ahk_id `%Master`% ;WM_COPYDATA
            DetectHiddenWindows, `%DetectHidden`%
            If (ErrorLevel = "FAIL") ;could not send data
                throw Exception("Could not send result to master.") ;wip: do something else about it, like trying to resend data
        }

        ParallelistCheckStatus:
        ParallelistDetectHidden := A_DetectHiddenWindows
        DetectHiddenWindows, On
        If !WinExist("ahk_id " . ParallelistMaster)
        {
            DetectHiddenWindows, `%ParallelistDetectHidden`%
            ExitApp ;wip: do something else about it, like trying to reconnect
        }
        DetectHiddenWindows, `%ParallelistDetectHidden`%
        Return

        %WorkerCode%
        )
        Return, Code
    }
}

LocalWorkerReceiveData(hWindow,pCopyDataStruct)
{
    Status := NumGet(pCopyDataStruct + 0) ;retrieve the status of the task
    Size := NumGet(pCopyDataStruct + A_PtrSize,0,"UInt") ;retrieve the size of the structure

    ;retrieve the data
    pResultStruct := NumGet(pCopyDataStruct + A_PtrSize + 4)
    pJob := NumGet(pResultStruct + 0)
    pWorker := NumGet(pResultStruct + 0,A_PtrSize)
    Length := NumGet(pResultStruct + 0,A_PtrSize * 2)
    VarSetCapacity(Data,Length)
    DllCall("RtlMoveMemory","UPtr",&Data,"UPtr",pResultStruct + (A_PtrSize * 3),"UPtr",Length)

    ;process the data
    Job := Object(pJob)
    Worker := Object(pWorker)
    Job.Receive(Worker,Data,Length)

    Return, 1
}