#SingleInstance, off ;required for obvious reasons
;This function needs to be called in the Autoexecute section so this instance
;can possibly turn into a worker thread. The worker thread stays in this function during its runtime.
InitWorkerThread()
;Main thread continues here
;Create the worker thread!
WorkerThread := new CWorkerThread("WorkerFunction", 0, 1, 1)

;Setup event handlers for the main thread
WorkerThread.OnStop.Handler := "OnStoppedByWorker"
WorkerThread.OnProgress.Handler := "ProgressHandler"
WorkerThread.OnFinish.Handler := "OnFinish"

;Start the worker thread
WorkerThread.Start("A Parameter")
return

;The functions below are event handlers of the main thread. They were specified above.
OnStoppedByWorker(WorkerThread, Result)
{
	Msgbox Error in worker thread! %Result%
	ExitApp
}

OnFinish(WorkerThread, Result)
{
	MsgBox Worker thread completed successfully! %Result%
	ExitApp
}

;Progress is a numeric integer value
ProgressHandler(WorkerThread, Progress)
{
	Tooltip, Progress: %Progress%
}


;This is the main worker function that is executed in the worker thread.
;The thread will exit shortly after this function returns.
;This function may have a many parameters as desired, but they need to be specified during the worker thread creation.
WorkerFunction(WorkerThread, Param)
{
	;This is a suggested structure for a worker thread that uses a loop.
	;It properly accounts for state changes (which can be caused by the main thread or this thread)
	while(A_Index <= 100 && WorkerThread.State = "Running")
	{
		Sleep 100 ;This simulates work that takes some time
		WorkerThread.Progress := A_Index ;Report the progress of the worker thread.
		
		;Lets allow this thread to randomly fail!
		Random, r, 1, 200
		if(r = 1)
			WorkerThread.Stop("Error: " r) ;Pass the error value to the main thread
	}
	;the return value of this function is only used when the worker thread wasn't stopped.
	return r
}

#include <WorkerThread>