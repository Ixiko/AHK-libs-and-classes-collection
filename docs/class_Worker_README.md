Parallelist
===========
A simple parallelism library for the AutoHotkey programming language.

Progress
--------

This project is currently in progress and is suitable for testing and development purposes only.

Goal
----

Parallel and multithreaded programs are uncommon to see in AutoHotkey, and when they do appear, the infrastructure is often ad hoc and single use.

Parallelist is an attempt to create a simpler way to parallelize problems. A script sets up a job, and after starting some workers a queue can be populated with data. Parallelist will manage event handling, worker assignment, and results collection by itself, automatically and behind the scenes. The script can be informed of when the job is done, and easily collect the results.

Parallelist aims to allow more AutoHotkey applications to take advantage of the extra processing power available to many computers today in the form of multiple processors. Already parallel applications will benefit from a decrease in the complexity of the parallel code, while others can easily be augmented to make best use of modern hardware.

Design
------

Parallelist is based on the following workflow:

1. Script creates a job, containing the logic to be used by each worker.
2. Script starts up the number of workers desired.
3. Script starts the job and starts adding data to the queue.
4. Parallelist dispatches tasks to individual workers, which do their processing independently.
5. Workers send their results back to Parallelist, and receive more tasks if there are any left.
6. Parallelist collects the data, cleans it up, and presents the results back to the script.

The Parallelist workflow is designed to abstract the complexity of parallelism away from your code, so you can focus more on what the application _does_.

Usage Example
-------------

A simple script that counts the number of lines in all the ".txt" files in a given library, in parallel.

    #Include <Parallelist.ahk>
    
    LineCounter =                             ;set up a line counter program
    (
    class Worker
    {
        Process(Task)
        {
            FileName := Parallelist.Data       ;retrieve the file name
            LineCount := 0
            Loop, Read, %FileName%             ;loop through each line of the file
            {
                If A_LoopReadLine Is Not Space ;if the line is not blank or purely whitespace
                LineCount ++                   ;increment the line count
            }
            Parallelist.Output := LineCount    ;set the output to the file's line count
            Return, 0
        }
    }
    )
    
    Job := new Parallelist(LineCounter)        ;open a line counter job
    Loop, 3
        Job.AddWorker()                        ;add a worker to the job
    Job.RemoveWorker()                         ;remove a worker from the job
    Job.Start()                                ;start execution of the job
    
    Loop, %A_ScriptDir%\Data\*.txt             ;loop through each ".txt" file in the "Data" subfolder of the script directory
        Job.Queue.Insert(A_LoopFileLongPath)   ;append a task to the queue
    While, Job.Working                         ;wait for the workers to finish the tasks placed on the queue
        Sleep, 1
    
    Job.Stop()                                 ;stop the workers after they have completed the task they are currently working on
    
    TotalLines := 0
    FileCount := Job.Result.MaxIndex()         ;get the number of files processed
    For Index, Value In Job.Result             ;loop through each result
        TotalLines += Value                    ;add up the number of lines
    MsgBox, Found %TotalLines% non-blank lines in %FileCount% files.