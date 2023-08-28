bytes_get_integer(ByRef pSource, pOffset=0, pIsSigned=false, pSize=4)
{
    ; pSource is a string (buffer) whose memory area contains a raw/binary integer at pOffset.
    ; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
    ; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
    ; pSource must be ByRef to avoid corruption during the formal-to-actual copying process
    ; (since pSource might contain valid data beyond its first binary zero).

    Loop %pSize% ; Build the integer by adding up its bytes.
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
        return result ; Signed vs. unsigned doesn't matter in these cases.
    ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
    return -(0xFFFFFFFF - result + 1)
}

/**
 * Helper Function
 *     Formats a file size in bytes to a human-readable size string
 *
 * @sample
 *     x := bytest_format(31236)
 *
 * @param   int     Bytes      Number of bytes to be formated
 * @param   int     Decimals   Number of decimals to be shown
 * @param   int     Prefixes   List of which the best matching prefix will be used
 * @return  string
*/
bytes_format(Bytes, Decimals = 1, Prefixes = "B,KB,MB,GB,TB,PB,EB,ZB,YB")
{
    StringSplit, Prefix, Prefixes, `,
    Loop, Parse, Prefixes, `,
        if (Bytes < e := 1024 ** A_Index)
        return % Round(Bytes / (e / 1024), decimals) Prefix%A_Index%
}
