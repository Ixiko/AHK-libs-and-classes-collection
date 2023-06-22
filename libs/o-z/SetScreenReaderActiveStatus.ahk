SetScreenReaderActiveStatus(isActive) {

	; https://gist.githubusercontent.com/tmplinshi/66e5f2e8ae1ea7d6ec28f91c0f217fb5/raw/f99414cbc78c0fab1a22d4b89711789e14a059f0/SetScreenReaderActiveStatus.ahk


    SPI_SETSCREENREADER := 0x0047
    SPIF_SENDCHANGE := 0x0002

    return DllCall( "SystemParametersInfo"
                  , "uint", SPI_SETSCREENREADER
                  , "uint", !!isActive
                  , "ptr", 0
                  , "uint", SPIF_SENDCHANGE )
}