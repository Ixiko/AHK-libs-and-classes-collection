### AutoHotkey-Asynchronous-Timer
=============================

Replacement for SetTimer using an external script and Windows Messages. 

##### Why an External Script?

This allows each timer to run on its own process. Running on its own process affords slightly better accuracy over the long haul as it doesn't have to worry about thread prioritization. Further, this means we aren't bound by variables erasing themselves or being stuck to utilizing labels or label stacks. An external AsyncTimer may be attached to any function, even global objects (or their children). Doing things in this mannar limits global pollution, especially when other classes and scripts that utilize the Asynchronous Timer.


#### Usage
------------------------------
Allows for 3 modes of usage: Manual, OnDemand, or Managed API.

##### Manual Usage

Manual Timers are started with `Run, path\to\asynctimer.ahk(.exe) %params%` You must have an `OnMessage()` call for every message you wish to pass.

##### OnDemand/SetTimer Replacement Usage

Add SetTimer.ahk to your lib directory then call `SetTimer()` with the appropriate arguments.

##### Managed API Usage

Add SetTimer.ahk to your lib directory and include it in your script. Code a function with an id parameter and isFinal parameter. Create a `new AsyncTimer()`, set the properties to your message and function and call `Start()`.

#### Examples (Coming Soon)
--------------------------------
