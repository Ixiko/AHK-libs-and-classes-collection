Global PROCESS_ALL_ACCESS        := 0x001F0FFF
Global PROCESS_VM_READ           := 0x10
Global PROCESS_QUERY_INFORMATION := 0x400

Global TOKEN_ALL_ACCESS        := 0xF01FF
Global TOKEN_QUERY             := 0x8
Global TOKEN_ADJUST_PRIVILEGES := 0x20

Global SE_PRIVILEGE_ENABLED := 2

Global PAGE_READWRITE         := 0x04
Global PAGE_EXECUTE_READWRITE := 0x40

Global TH32CS_SNAPMODULE := 0x00000008

Global INVALID_HANDLE_VALUE := -1

Global MODULEENTRY32_SIZE := 548

Global MODULEENTRY32_modBaseAddr := 20

Global MODULEENTRY32_hModule := 29

Global MODULEENTRY32_szModule := 32

Memory_GetProcessID(process_name)
{
    Process, Exist, %process_name%
    process_id = %ErrorLevel%

    Return, process_id
}

Memory_GetProcessHandle(process_id)
{
    process_handle := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", false, "UInt", process_id, "Ptr") ; PROCESS_ALL_ACCESS

    Return, process_handle
}

Memory_GetModuleBase(process_id, module_name)
{
    snapshot_handle := DllCall("CreateToolhelp32Snapshot", "UInt", 0x00000008, "UInt", process_id) ; TH32CS_SNAPMODULE

    If (snapshot_handle = INVALID_HANDLE_VALUE)
    {
        Return, False
    }

    VarSetCapacity(me32, 548, 0) ; MODULEENTRY32_SIZE

    NumPut(548, me32) ; MODULEENTRY32_SIZE

    If (DllCall("Module32First", "UInt", snapshot_handle, "UInt", &me32))
    {
        While (DllCall("Module32Next", "UInt", snapshot_handle, "UInt", &me32))
        {
            If (module_name == StrGet(&me32 + 32, 256, "CP0")) ; MODULEENTRY32_szModule
            ;If (DllCall("lstrcmpi", "Str", module_name, "UInt", &me32 + 32) = -1)
            {
                DllCall("CloseHandle", "UInt", snapshot_handle)

                Return, NumGet(&me32, 20) ; MODULEENTRY32_modBaseAddr
            }
        }
    }

    DllCall("CloseHandle", "UInt", snapshot_handle)

    Return, False
}

Memory_CloseHandle(process_handle)
{
    DllCall("CloseHandle", "Ptr", process_handle)
}

Memory_Read(process_handle, address)
{
    VarSetCapacity(value, 4, 0)
    DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", value, "UInt", 4, "UInt *", 0)

    Return, NumGet(value, 0, "UInt")

    ;Return, *(&value + 3) << 24 | *(&value + 2) << 16 | *(&value + 1) << 8 | *(&value)
}

Memory_ReadEx(process_handle, address, size)
{
    VarSetCapacity(value, size, 0)
    DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", value, "UInt", size, "UInt *", 0)

    Return, NumGet(value, 0, "UInt")
}

Memory_ReadFloat(process_handle, address)
{
    VarSetCapacity(value, 4, 0)
    DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", value, "UInt", 4, "UInt *", 0)

    Return, NumGet(value, 0, "Float")
}

Memory_ReadReverse(process_handle, address)
{
    VarSetCapacity(value, 4, 0)
    DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", value, "UInt", 4, "UInt *", 0)

    Return, *(&value + 3) | *(&value + 2) << 8 | *(&value + 1) << 16 | *(&value) << 24
}

Memory_ReadString(process_handle, address, size)
{
    VarSetCapacity(value, size, 0)
    DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", value, "UInt", size, "UInt *", 0)

    Loop, %size%
    {
        current_value := NumGet(value, A_Index - 1, "UChar")

        ;MsgBox, current_value = %current_value%

        If (current_value = 0)
        {
            Break
        }

        result .= Chr(current_value)
    }

    ;MsgBox, result = %result%

    Return, result
}

Memory_ReadStringEx(process_handle, address, size)
{
    result = 

    Loop, %size%
    {
        output := "x"

        read := DllCall("ReadProcessMemory", "UInt", process_handle, "UInt", address, "Str", output, "UInt", 1, "UInt *", 0)
        If (ErrorLevel or !read)
        {
            Return, result
        }

        If output = 
        {
            Break
        }

        output_character := *(&output)

        IfEqual, output_character, 32 ; Space
        {
            result .= " "
        }
        Else
        {
            result = %result%%output%
        }

        address++
    }

    Return, result
}

Memory_Write(process_handle, address, value)
{
    DllCall("VirtualProtectEx", "UInt", process_handle, "UInt", address, "UInt", 4, "UInt", 0x04, "UInt *", 0) ; PAGE_READWRITE

    DllCall("WriteProcessMemory", "UInt", process_handle, "UInt", address, "UInt *", value, "UInt", 4, "UInt *", 0)
}

Memory_WriteEx(process_handle, address, value, size)
{
    DllCall("VirtualProtectEx", "UInt", process_handle, "UInt", address, "UInt", size, "UInt", 0x04, "UInt *", 0) ; PAGE_READWRITE

    DllCall("WriteProcessMemory", "UInt", process_handle, "UInt", address, "UInt *", value, "UInt", size, "UInt *", 0)
}

Memory_WriteFloat(process_handle, address, value)
{
    value := FloatToHex(value)

    DllCall("VirtualProtectEx", "UInt", process_handle, "UInt", address, "UInt", 4, "UInt", 0x04, "UInt *", 0) ; PAGE_READWRITE

    DllCall("WriteProcessMemory", "UInt", process_handle, "UInt", address, "UInt *", value, "UInt", 4, "UInt *", 0)
}

Memory_WriteNops(process_handle, address, size)
{
    If (size <= 0)
    {
        Return
    }

    VarSetCapacity(value, size)

    Loop, %size%
    {
        NumPut(0x90, value, A_Index - 1, "UChar")
    }

    DllCall("VirtualProtectEx", "UInt", process_handle, "UInt", address, "UInt", size, "UInt", 0x04, "UInt *", 0) ; PAGE_READWRITE

    DllCall("WriteProcessMemory", "UInt", process_handle, "UInt", address, "UInt", &value, "UInt", size, "UInt *", 0)
}

Memory_WriteBytes(process_handle, address, bytes)
{
    bytes_size := 0
    Loop, Parse, bytes, `,
    {
        bytes_size += 1
    }

    ;Sort, bytes, D`, N R ; bytes in reverse order

    VarSetCapacity(value, bytes_size)

    Loop, Parse, bytes, `,
    {
        byte = 0x%A_LoopField% ; pre-append 0x

        NumPut(byte, value, A_Index - 1, "UChar")
    }

    DllCall("VirtualProtectEx", "UInt", process_handle, "UInt", address, "UInt", bytes_size, "UInt", 0x04, "UInt *", 0) ; PAGE_READWRITE

    DllCall("WriteProcessMemory", "UInt", process_handle, "UInt", address, "UInt", &value, "UInt", bytes_size, "UInt *", 0)
}
