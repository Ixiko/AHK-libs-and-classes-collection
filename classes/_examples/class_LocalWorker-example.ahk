#NoEnv

;MsgBox % ComObjGet("winmgmts:root\cimv2:Win32_Processor='cpu0'").CurrentClockSpeed

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

This file is part of Parallelist. Source code is available at <https://github.com/Uberi/Parallelist>.

Parallelist is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#Warn All
#Warn LocalSameAsGlobal, Off

;wip: outputs should be in the same order as the inputs
;wip: have the design support multiple partitioners for better scalability. paritioning can be done with BucketIndex := Mod(Hash(Key),BucketCount)
;wip: periodically give out heartbeats to detect worker failures and close or cleanup the worker (or detect if it times out processing a task)
;wip: the master server should log worker and scheduling state to storage periodically, so when master is restarted, it can read in the state again and keep scheduling
;wip: worker should wait if the master does not respond, and then send the data again when it receives the new master's startup ping

class Queue
{
    __New()
    {
        ;wip: implement a singly linked list and use it for all queues
    }

    Peek()
    {
        ;wip: return the first element
        Return, this
    }

    Pop()
    {
        ;wip: remove the first element and return it
        Return, this
    }

    Append(Data,Length = -1)
    {
        If Length = -1
            Length := StrLen(Data)

        ;wip: add value to the end of the queue
        Return, this
    }
}

WorkerCode = 
(
class Worker
{
    __New()
    {
        ;startup code goes here, throws exception on error
    }

    __Delete()
    {
        ;cleanup code goes here, throws exception on error
    }

    Process(Task)
    {
        ;task processing code goes here, throws exception on error
        Task.Result := "Finished " . Task.Data . "."
        Return True
    }
}
)

Counter := 0
Job := new Parallelist(WorkerCode)
Job.AddWorker().AddWorker().RemoveWorker()
Job.Queue := ["task1","task2","task3","task4","task5","task6","task7","task8","task9"]
Job.Start().Wait()
For Index, Value In Job.Result
    MsgBox Index: %Index%`nValue: %Value%
Job.Stop()
Job.Close()
ExitApp

Esc::
Job.Close()
ExitApp

class Parallelist
{
    __New(WorkerCode,Worker = "")
    {
        global LocalWorker
        If IsObject(Worker)
            this.Worker := Worker
        Else
            this.Worker := LocalWorker

        this.WorkerCode := WorkerCode
        this.Working := False
        this.Workers := Object()
        this.Workers.Active := Object()
        this.Workers.Idle := Object()
        this.Queue := []
        this.Result := []
    }

    AddWorker()
    {
        Worker := new this.Worker(this,this.WorkerCode)
        this.Workers.Idle[Worker] := 0
        Return, this
    }

    RemoveWorker()
    {
        If !this.Workers.Idle.NewEnum().Next(Worker) ;no idle workers
            throw Exception("No idle workers to remove.") ;wip: stop a worker to do this
        this.Workers.Idle.Remove(Worker)
        Return, this
    }

    Start()
    {
        If !this.Workers.Idle.NewEnum().Next(Worker)
            throw Exception("No idle workers to start.")
        this.Working := True
        For Worker In this.Workers.Idle
        {
            ;assign a task to the worker
            Length := this.Queue.GetCapacity(1)
            Task := this.Queue.Remove(1) ;wip: remove the task only after the worker has completed it
            Worker.Send(Task,Length)
        }
        Return, this
    }

    Wait(Timeout = -1)
    {
        If Timeout Is Not Number
            throw Exception("Timeout must be a number.")
        StartTime := A_TickCount
        While, Job.Working
        {
            If (Timeout < 0 || (A_TickCount - StartTimer) > Timeout)
                Break ;wip: give some indication that the operation timed out
            Sleep, 0
        }
        Return, this
    }

    Stop()
    {
        For Worker In this.Workers.Active
        {
            ;wip: send stop message to workers
        }
        this.Working := False
        Return, this
    }

    Receive(Worker,ByRef Data,Length)
    {
        ;assign another task to the now idle worker
        MsgBox % Data
        ;wip: do something with the data
        this.Update(Worker)
        Return, this
    }

    Update(Worker)
    {
        If !this.Queue.HasKey(1) ;no tasks left
            Return, this.Stop()
        Length := this.Queue.GetCapacity(1)
        Task := this.Queue.Remove(1)
        Worker.Send(Task,Length)
        Return, this
    }
}

#Include %A_ScriptDir%\..\classes\Class_LocalWorker.ahk