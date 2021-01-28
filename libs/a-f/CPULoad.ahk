;Get CPU load
;by shimanov
;www.autohotkey.com/forum/viewtopic.php?t=5064
;https://autohotkey.com/board/topic/7127-monitor-when-cpu-becomes-idle/
/* EXAMPLE
#Persistent
SetTimer, CheckCPULoad, 1000
return

CheckCPULoad:
  SetFormat, float, 0.0
  ToolTip, % "CPULoad = " GetCPULoad() "%"
return
*/

GetCPULoad_Short() {

    Static IdleTime, Tick
    SetBatchLines, -1
    OldIdleTime = %IdleTime%
    OldTick = %Tick%
    DllCall("kernel32.dll\GetSystemTimes", "uint",&IdleTicks, "uint",0, "uint",0)
    IdleTime := *(&IdleTicks)
    Loop 7
      IdleTime += *( &IdleTicks + A_Index ) << ( 8 * A_Index )
    Tick := A_TickCount

    Return 100 - 0.01*(IdleTime - OldIdleTime)/(Tick - OldTick)

  }

GetCPULoad() {

    Static LastStartTickCount, LastLowTickCounts, LastHighTickCounts

    SetBatchLines, -1

    ;get tickcounts between this and the last call of the subroutine
    StartTickCount    := A_TickCount
    ElapsedTickCounts := StartTickCount - LastStartTickCount

    ;assume CPU load is zero
    CPULOAD = 0

    ;get information from system idle time (i.e., the OS idle process)
    VarSetCapacity( Ticks, 4+4 )
    DllCall( "kernel32.dll\GetSystemTimes", "uint", &Ticks, "uint", 0, "uint", 0 )
    LowTickCounts  := ReadInteger( &Ticks, 0, 4 )
    HighTickCounts := ReadInteger( &Ticks, 4, 4 )

    ;calculate CPU load after second call
    If LastStartTickCount
      {
        Idle_ticks := ( HighTickCounts - LastHighTickCounts ) << 32
        Idle_ticks := Idle_ticks + LowTickCounts - LastLowTickCounts
        CPULOAD    := 100 - Idle_ticks / ElapsedTickCounts / 100
      }

    ;remember current values for next call
    LastStartTickCount := StartTickCount
    LastLowTickCounts  := LowTickCounts
    LastHighTickCounts := HighTickCounts

    Return, CPULOAD
  }

ReadInteger( Address, Offset, Size )  {
    old_FormatInteger := A_FormatInteger
    SetFormat, Integer, hex
    value = 0
    Loop, %Size%
        value := value + ( *( ( Address + Offset ) + ( A_Index - 1 ) ) << ( 8 * ( A_Index - 1 ) ) )
    SetFormat, Integer, %old_FormatInteger%
    Return, value
  }