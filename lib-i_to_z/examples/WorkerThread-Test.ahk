#SingleInstance, off ;required for obvious reasons
;This function needs to be called in the Autoexecute section so this instance
;can possibly turn into a worker thread. The worker thread stays in this function during its runtime.
InitWorkerThread()
;Main thread continues here
Gui, Add, Progress, vProgressBar w400, 0
Gui, Add, Button, vMainStart gMainStart y+10, Start
Gui, Add, Button, vMainPause gMainPause x+10 w50 Disabled, Pause
Gui, Add, Button, vMainStop gMainStop x+10 Disabled, Stop
Gui, Add, Button, vMainData gMainData x+10 Disabled, Send Data

Gui, +LabelMainGUI
Gui, Show

;Create the worker thread! It will be reused in this program to demonstrate the possibility
;If the last parameter is set to 0, the worker thread will stay running and wait for tasks
WorkerThread := new CWorkerThread("WorkerFunction", 1, 1, 1)

;Setup event handlers for the main thread
WorkerThread.OnPause.Handler := "OnPausedByWorker"
WorkerThread.OnResume.Handler := "OnResumedByWorker"
WorkerThread.OnStop.Handler := "OnStoppedByWorker"
WorkerThread.OnData.Handler := "OnDataFromWorker"
WorkerThread.OnProgress.Handler := "ProgressHandler"
WorkerThread.OnFinish.Handler := "OnFinish"
return

MainGUIClose:
if(WorkerThread.State = "Running" || WorkerThread.State = "Paused")
	WorkerThread.Stop("Main thread exit") ;Stop the worker thread if it is still running
ExitApp

;The main thread can control the execution of the worker thread, demonstrated by the event handlers of the buttons below:
MainStart:
if(WorkerThread.State = "Stopped" || WorkerThread.State = "Finished")
{
	WorkerThread.Start("A Parameter", "Another unused parameter") ;Starting works only when in stopped state. The progress is reset to zero.
	GuiControl, Disable, MainStart
	GuiControl, Enable, MainStop
	GuiControl, Enable, MainPause
	GuiControl, Enable, MainData
	Gui, Show,, Running
}
return

MainPause:
if(WorkerThread.State = "Paused")
{
	WorkerThread.Resume()
	GuiControl, , MainPause, Pause
	Gui, Show,, Running
}
else if(WorkerThread.State = "Running")
{
	WorkerThread.Pause()
	GuiControl, , MainPause, Resume
	Gui, Show,,Paused by main thread
}
return

MainStop:
if(WorkerThread.State = "Running" || WorkerThread.State = "Paused")
{
	WorkerThread.Stop("Stop running, worker!") ;We can pass a reason for the stop to the worker thread
	GuiControl, Disable, MainStop
	GuiControl, Disable, MainPause
	GuiControl, Disable, MainData
	GuiControl, Enable, MainStart
	Gui, Show,,Stopped by main thread
}
return

MainData:
if(WorkerThread.State = "Running" || WorkerThread.State = "Paused")
	WorkerThread.SendData("Data from main thread") ;We can pass arbitrary data between the threads
return
;The functions below are event handlers of the main thread. They were specified above.
OnPausedByWorker(WorkerThread)
{
	global MainPause
	GuiControl, ,MainPause, Resume
	Gui, Show,, Paused by worker thread
}
OnResumedByWorker(WorkerThread)
{
	global MainPause
	GuiControl, ,MainPause, Pause
	Gui, Show,, Running
}
OnStoppedByWorker(WorkerThread, Result)
{
	global
	GuiControl, Enable, MainStart
	GuiControl, Disable, MainPause
	GuiControl, Disable, MainStop
	GuiControl, Disable, MainData
	Gui, Show,, Stopped by worker thread! Result: %Result%
}
OnFinish(WorkerThread, Result)
{
	global
	Gui, Show,, Finished! Result: %Result%
	GuiControl, Enable, MainStart
	GuiControl, Disable, MainPause
	GuiControl, Disable, MainStop
	GuiControl, Disable, MainData
}
OnDataFromWorker(WorkerThread, Data)
{
	MsgBox Data from worker: %Data%
}

;Progress is a numeric integer value
ProgressHandler(WorkerThread, Progress)
{
	global ProgressBar
	GuiControl, , ProgressBar, %Progress%
}


;This is the main worker function that is executed in the worker thread.
;The thread will exit shortly after this function returns.
;This function may have a many parameters as desired, but they need to be specified during the worker thread creation.
WorkerFunction(WorkerThread, Param)
{
	global WorkerProgress, WorkerPause, WorkerStop, WorkerData
	;We can set up some event handlers for the worker thread here
	;so it can react to pause/resume/stop events coming from the main thread
	WorkerThread.OnPause.Handler := "OnPausedByMain"
	WorkerThread.OnResume.Handler := "OnResumedByMain"
	WorkerThread.OnStop.Handler := "OnStoppedByMain"
	WorkerThread.OnData.Handler := "OnDataFromMain"
	Gui, Add, Progress, vWorkerProgress w400, 0
	Gui, Add, Button, vWorkerPause gWorkerPause w50, Pause
	Gui, Add, Button, vWorkerStop gWorkerStop x+10, Stop
	Gui, Add, Button, vWorkerData gWorkerData x+10, Send Data
	Gui, +LabelWorkerGUI
	Gui, Show,, Passed Parameter: %Param%
	;This is a suggested structure for a worker thread that uses a loop.
	;It properly accounts for state changes (which can be caused by the main thread or this thread)
	while(A_Index < 100 && WorkerThread.State = "Running")
	{
		GuiControl,,WorkerProgress, %A_Index%
		Sleep 40 ;This simulates work that takes some time
		WorkerThread.Progress := A_Index ;Report the progress of the worker thread.
		while(WorkerThread.State = "Paused") ;Optionally wait a while for resuming the worker thread.
			Sleep 10
	}
	Gui, Destroy
	;the return value of this function is only used when the worker thread wasn't stopped.
	return 42
}

;Prevent closing of the worker thread. Alternatively, the worker thread could stop itself.
WorkerGUIClose:
return

;The worker thread can control the execution of itself, demonstrated by the event handlers of the buttons below:
WorkerPause:
if(WorkerThread.State = "Paused")
{
	WorkerThread.Resume()
	GuiControl, , WorkerPause, Pause
}
else if(WorkerThread.State = "Running")
{
	WorkerThread.Pause()
	GuiControl, , WorkerPause, Resume
}
return

WorkerStop:
if(WorkerThread.State = "Running" || WorkerThread.State = "Paused")
{
	WorkerThread.Stop(23) ;Parameter is passed back to main thread as result
	Gui, Destroy
}
return

WorkerData:
if(WorkerThread.State = "Running" || WorkerThread.State = "Paused")
	WorkerThread.SendData("Data from worker thread!") ;We can send arbitrary data between threads!
return

;The functions below are event handlers of the worker thread. They were specified above.
OnPausedByMain()
{
	global WorkerPause
	GuiControl, , WorkerPause, Resume
	Gui, Show,, Paused by main thread
}
OnResumedByMain()
{	
	global WorkerPause
	GuiControl, , WorkerPause, Pause
	Gui, Show,, Running Worker thread
}
OnStoppedByMain(reason)
{
	Msgbox Stopped by main thread! Reason: %reason%
}
OnDataFromMain(Data)
{
	Msgbox Data from main thread: %Data%
}

#include <WorkerThread>