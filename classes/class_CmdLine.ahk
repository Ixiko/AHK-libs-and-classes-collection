/**

Class:
    CmdLine.ahk - Utility class for running cmdline utils.

Version: 
    v1.0.0

Requirements:
    AutoHotkey v1.1.21.00+

Usage:
    inputFile := "../myfile.mp4"
    outputFile := "../cut_myfile.mp4"
    fromTime := "00:10"
    toTime := "00:31"

    cmd := new CmdLine("ffmpeg.exe")

    cmd.AddParam("-ss", fromTime)
    cmd.AddParam("-i", inputFile)

    cmd.AddParam("-c", "copy")
    cmd.AddFlag("-copyts")

    cmd.AddParam("-to", toTime)

    cmd.AddFlag(outputFile)
    cmd.Execute()

Links:
    Github - https://github.com/sidola/AHK-Utils

*/
class CmdLine {

    __New(programPath) {
        this.programPath := programPath
        this.flagsAndParams := ""
    }

    AddFlag(flag) {
        this.flagsAndParams .= Format(" {}", flag)
    }

    AddParam(key, value) {
        this.flagsAndParams .= Format(" {} {}", key, value)
    }

    GetCommand() {
        return Format("{}{}", this.programPath, this.flagsAndParams)
    }
 
    Execute(workingDir := "", minMaxHide := "") {
        RunWait, % this.GetCommand(), %workingDir%, %minMaxHide%
    }

}


