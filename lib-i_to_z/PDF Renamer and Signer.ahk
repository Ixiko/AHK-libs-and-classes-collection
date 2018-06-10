#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir "D:\Eigene Dokumente\Mein ScanSnap"  ; Ensures a consistent starting directory.

WinGetActiveTitle, AWin
If AWin=