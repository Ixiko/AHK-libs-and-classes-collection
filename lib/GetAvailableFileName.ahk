; Get next/free Available File Name by toralf
; http://www.autohotkey.com/forum/viewtopic.php?t=6297

GetAvailableFileName( GivenFileName, GivenPath = "", StartID = 1 )
{
  ;check if GivenPath exist and add "\" if necessary
  If GivenPath is not space
    {
      StringRight, LastChar, GivenPath, 1
      If ( LastChar <> "\" )
        GivenPath = %GivenPath%\
      If ( InStr(FileExist(GivenPath), "D") = 0 )
        {
          ErrorLevel = The given path >%GivenPath%< doesn't exist.
          Return 0
        }
    }

  ;check if StartID is reasonable
  If ( StartID < 0 Or Mod(StartID, 1) <> 0 )
    {
      ErrorLevel =
        (LTrim
           The StartID >%StartID%< is smaller then zero or not an integer.
           It has to be a positive integer.
        )
      Return 0
    }

  ;split GivenFileName with #
  StringSplit, NameArray, GivenFileName, #
 
  ;if GivenFileName doesn't contain # ...
  If NameArray0 < 2
    {
      ;check if GivenFileName exists
      If FileExist(GivenPath . GivenFileName)
        {
          ErrorLevel =
            (LTrim
              The given file >%GivenFileName%< does exist
              in path >%GivenPath%<.
              (if path is empty, it's the path of the script/exe)
            )
          Return 0
        }
      Else
          Return GivenPath . GivenFileName
    }

  ;check if StartID isn't too large
  If ( StrLen(StartID) > NameArray0 - 1 )
    {
      ErrorLevel =
        (LTrim
           The StartID >%StartID%< is too large
           for the filename >%GivenFileName%<.
        )
      Return 0
    }
 
  ;Search from StartID ...
  Loop
    {
      Number := A_Index + StartID - 1
             
      ;untill number is too large ...
      If ( StrLen(Number) > NameArray0 - 1 )
        {
          ErrorLevel =
            (LTrim
              All files exist for >%GivenFileName%<
              with all # between %StartID% and %Number%.
            )
          Return 0
        }

      ;otherwise fill number with leading zeros
      Loop, % NameArray0 - 1 - StrLen(Number) ;%
          Number = 0%Number%
     
      ;split number in an array
      StringSplit, NumberArray, Number
     
      ;mix and concatenate the names array with the numbers array
      FileName =
      Loop, %NameArray0%
          FileName := FileName . NameArray%A_Index% . NumberArray%A_Index%
     
      ;check if GivenFileName doesn't exist
      If not FileExist(GivenPath . FileName)
          Return GivenPath . FileName
     }
}

GetAvailableFileName_fast( GivenFileName, GivenPath = "", StartID = 1 )
{
  StringSplit, NameArray, GivenFileName, #
  Loop
    {
      Number := A_Index + StartID - 1
      Loop, % NameArray0 - 1 - StrLen(Number) ;%
          Number = 0%Number%
      StringSplit, NumberArray, Number
      FileName =
      Loop, %NameArray0%
          FileName := FileName . NameArray%A_Index% . NumberArray%A_Index%
      If not FileExist(GivenPath . FileName)
          Return GivenPath . FileName
     }
}