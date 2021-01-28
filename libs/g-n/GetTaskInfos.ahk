/*
MsgBox,% GetTaskInfos()
return
ExitApp
*/

GetTaskInfos() {
    objService := ComObjCreate("Schedule.Service")
    objService.Connect()
    rootFolder := objService.GetFolder("\")
    taskCollection := rootFolder.GetTasks(0)
    numberOfTasks := taskCollection.Count
    ; ?RegistrationInfo.Author
    For registeredTask, state in taskCollection
    {
        if (registeredTask.state == 0)
            state:= "Unknown"
        else if (registeredTask.state == 1)
            state:= "Disabled"
        else if (registeredTask.state == 2)
            state:= "Queued"
        else if (registeredTask.state == 3)
            state:= "Ready"
        else if (registeredTask.state == 4)
            state:= "Running"
        tasklist .= registeredTask.Name "=" state "=" registeredTask.state "`n"
}
    return tasklist
}
 