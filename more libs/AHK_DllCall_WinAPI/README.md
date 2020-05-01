# AutoHotkey, WinAPI & DllCall's by jNizM
AHK --> DllCall --> WinAPI

## Current

### Clipboard Functions
* [CloseClipboard](src/Clipboard Functions/CloseClipboard.ahk)
* [EmptyClipboard](src/Clipboard Functions/EmptyClipboard.ahk)
* [OpenClipboard](src/Clipboard Functions/OpenClipboard.ahk)

### Cursor Functions
* [GetCursorInfo](src/Cursor Functions/GetCursorInfo.ahk)
* [GetCursorPos](src/Cursor Functions/GetCursorPos.ahk)
* [GetPhysicalCursorPos](src/Cursor Functions/GetPhysicalCursorPos.ahk)
* [SetCursorPos](src/Cursor Functions/SetCursorPos.ahk)
* [SetPhysicalCursorPos](src/Cursor Functions/SetPhysicalCursorPos.ahk)

### Directory Management Functions
* [CreateDirectory](src/Directory Management Functions/CreateDirectory.ahk)
* [RemoveDirectory](src/Directory Management Functions/RemoveDirectory.ahk)
* [SetCurrentDirectory](src/Directory Management Functions/SetCurrentDirectory.ahk)

### Disk Management Functions
* [GetDiskFreeSpace](src/Disk Management Functions/GetDiskFreeSpace.ahk)
* [GetDiskFreeSpaceEx](src/Disk Management Functions/GetDiskFreeSpaceEx.ahk)

### Error Handling Functions
* [Beep](src/Error Handling Functions/Beep.ahk)
* [FormatMessage](src/Error Handling Functions/FormatMessage.ahk)
* [GetLastError](src/Error Handling Functions/GetLastError.ahk)

### File Management Functions
* [CopyFile](src/File Management Functions/CopyFile.ahk)
* [DeleteFile](src/File Management Functions/DeleteFile.ahk)
* [GetFileAttributes](src/File Management Functions/GetFileAttributes.ahk)
* [GetFileSize](src/File Management Functions/GetFileSize.ahk)
* [GetFileSizeEx](src/File Management Functions/GetFileSizeEx.ahk)
* [GetTempPath](src/File Management Functions/GetTempPath.ahk)
* [MoveFile](src/File Management Functions/MoveFile.ahk)
* [MoveFileEx](src/File Management Functions/MoveFileEx.ahk)

### IP Helper Functions
* [GetIpStatistics](src/IP Helper Functions/GetIpStatistics.ahk)
* [GetIpStatisticsEx](src/IP Helper Functions/GetIpStatisticsEx.ahk)
* [GetTcpStatistics](src/IP Helper Functions/GetTcpStatistics.ahk)
* [GetTcpStatisticsEx](src/IP Helper Functions/GetTcpStatisticsEx.ahk)
* [GetUdpStatistics](src/IP Helper Functions/GetUdpStatistics.ahk)
* [GetUdpStatisticsEx](src/IP Helper Functions/GetUdpStatisticsEx.ahk)

### Keyboard Input Functions
* [BlockInput](src/Keyboard Input Functions/BlockInput.ahk)
* [GetKBCodePage](src/Keyboard Input Functions/GetKBCodePage.ahk)
* [GetKeyboardLayout](src/Keyboard Input Functions/GetKeyboardLayout.ahk)

### Memory Management Functions
* [GetPhysicallyInstalledSystemMemory](src/Memory Management Functions/GetPhysicallyInstalledSystemMemory.ahk)
* [GlobalMemoryStatusEx](src/Memory Management Functions/GlobalMemoryStatusEx.ahk)

### Mouse Input Functions
* [ClipCursor](src/Mouse Input Functions/ClipCursor.ahk)
* [GetCapture](src/Mouse Input Functions/GetCapture.ahk)
* [GetDoubleClickTime](src/Mouse Input Functions/GetDoubleClickTime.ahk)
* [ReleaseCapture](src/Mouse Input Functions/ReleaseCapture.ahk)
* [SetDoubleClickTime](src/Mouse Input Functions/SetDoubleClickTime.ahk)
* [SwapMouseButton](src/Mouse Input Functions/SwapMouseButton.ahk)

### Multimedia Functions
* [timeGetTime](src/Multimedia Functions/timeGetTime.ahk)

### National Language Support Functions
* [GetDurationFormat](src/National Language Support Functions/GetDurationFormat.ahk)

### Process and Thread Functions
* [GetActiveProcessorCount](src/Process and Thread Functions/GetActiveProcessorCount.ahk)
* [GetActiveProcessorGroupCount](src/Process and Thread Functions/GetActiveProcessorGroupCount.ahk)
* [GetCommandLine](src/Process and Thread Functions/GetCommandLine.ahk)
* [GetCurrentProcess](src/Process and Thread Functions/GetCurrentProcess.ahk)
* [GetCurrentProcessId](src/Process and Thread Functions/GetCurrentProcessId.ahk)
* [GetCurrentProcessorNumber](src/Process and Thread Functions/GetCurrentProcessorNumber.ahk)
* [GetCurrentThread](src/Process and Thread Functions/GetCurrentThread.ahk)
* [GetCurrentThreadId](src/Process and Thread Functions/GetCurrentThreadId.ahk)
* [GetMaximumProcessorCount](src/Process and Thread Functions/GetMaximumProcessorCount.ahk)
* [GetMaximumProcessorGroupCount](src/Process and Thread Functions/GetMaximumProcessorGroupCount.ahk)
* [GetProcessVersion](src/Process and Thread Functions/GetProcessVersion.ahk)
* [Sleep](src/Process and Thread Functions/Sleep.ahk)
* [SleepEx](src/Process and Thread Functions/SleepEx.ahk)

### PSAPI Functions
* [GetModuleFileNameEx](src/PSAPI Functions/GetModuleFileNameEx.ahk)
* [GetProcessMemoryInfo](src/PSAPI Functions/GetProcessMemoryInfo.ahk)

### String Functions
* [CharLower](src/String Functions/CharLower.ahk)
* [CharLowerBuff](src/String Functions/CharLowerBuff.ahk)
* [CharUpper](src/String Functions/CharUpper.ahk)
* [CharUpperBuff](src/String Functions/CharUpperBuff.ahk)

### System Information Functions
* [GetComputerName](src/System Information Functions/GetComputerName.ahk)
* [GetProductInfo](src/System Information Functions/GetProductInfo.ahk)
* [GetSystemDirectory](src/System Information Functions/GetSystemDirectory.ahk)
* [GetSystemRegistryQuota](src/System Information Functions/GetSystemRegistryQuota.ahk)
* [GetSystemWindowsDirectory](src/System Information Functions/GetSystemWindowsDirectory.ahk)
* [GetSystemWow64Directory](src/System Information Functions/GetSystemWow64Directory.ahk)
* [GetUserName](src/System Information Functions/GetUserName.ahk)
* [GetUserNameEx](src/System Information Functions/GetUserNameEx.ahk)
* [GetVersion](src/System Information Functions/GetVersion.ahk)
* [GetVersionEx](src/System Information Functions/GetVersionEx.ahk)
* [GetWindowsDirectory](src/System Information Functions/GetWindowsDirectory.ahk)
* [QueryPerformanceCounter](src/System Information Functions/QueryPerformanceCounter.ahk)
* [QueryPerformanceFrequency](src/System Information Functions/QueryPerformanceFrequency.ahk)

### System Shutdown Functions
* [LockWorkStation](src/System Shutdown Functions/LockWorkStation.ahk)

### Time Functions
* [GetLocalTime](src/Time Functions/GetLocalTime.ahk)
* [GetSystemTime](src/Time Functions/GetSystemTime.ahk)
* [GetTickCount](src/Time Functions/GetTickCount.ahk)
* [GetTickCount64](src/Time Functions/GetTickCount64.ahk)
* [SetLocalTime](src/Time Functions/SetLocalTime.ahk)
* [SetSystemTime](src/Time Functions/SetSystemTime.ahk)

### Volume Management Functions
* [GetDriveType](src/Volume Management Functions/GetDriveType.ahk)

### Others
* [ZwDelayExecution](src/Others/ZwDelayExecution.ahk)


## Info
* URL: [AHK Thread](http://ahkscript.org/boards/viewtopic.php?f=7&t=406)


## Contributing
* thanks to AutoHotkey Community


## Copyright and License
[Unlicense](LICENSE)