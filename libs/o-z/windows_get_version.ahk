/**
 * Helper Function
 *     Get the version ID of the current Windows installation
 *
 * @sample
 *     windows_get_version()     ; ie: returns 10.0
 *
 * @return  integer
 */
windows_get_version()
{
    Version := DllCall("GetVersion", "uint") & 0xFFFF
    return (Version & 0xFF) "." (Version >> 8)
}
