Loop, 10
{
  Sleep 2000
  OutputDebug, OutputDebug %A_Index%`n
  FileAppend, StdOut %A_Index%`n, *
  FileAppend, StdErr %A_Index%`n, **
}