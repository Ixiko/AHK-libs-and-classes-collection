; ======================================================================================================================
; Function:          Constants for Hotkey controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; WM_USER = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_HOTKEY       := "msctls_hotkey32"
; Messages =============================================================================================================
Global HKM_GETHOTKEY   := 0x0402 ; (WM_USER + 2)
Global HKM_SETHOTKEY   := 0x0401 ; (WM_USER + 1)
Global HKM_SETRULES    := 0x0403 ; (WM_USER + 3)
; Others ===============================================================================================================
; HKM_GET/SETHOTKEY: Modifiers
Global HOTKEYF_ALT     := 0x04
Global HOTKEYF_CONTROL := 0x02
Global HOTKEYF_EXT     := 0x08
Global HOTKEYF_SHIFT   := 0x01
; HKM_SETRULES: Invalid key combinations
Global HKCOMB_A        := 0x0008 ; Alt
Global HKCOMB_C        := 0x0004 ; Ctrl
Global HKCOMB_CA       := 0x0040 ; Ctrl+Alt
Global HKCOMB_NONE     := 0x0001 ; unmodified
Global HKCOMB_S        := 0x0002 ; Shift
Global HKCOMB_SA       := 0x0020 ; Shift+Alt
Global HKCOMB_SC       := 0x0010 ; Shift+Ctrl
Global HKCOMB_SCA      := 0x0080 ; Chift+Ctrl+Alt
; ======================================================================================================================