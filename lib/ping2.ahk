;http://www.autohotkey.com/forum/topic10260.html

; GetTextLines
; Gets the number of lines in a specified text file.
; Usage: GetTextLines(FilePath)

GetTextLines(FilePath)
   {
   Loop, Read, %FilePath%
      TxtLength := A_Index
   Return TxtLength
   }

; Ping
; Pings a specified site, storing resulting stats to variables.
; SiteOrIP is the site's domain name or IP address.
; AverageVar, MinimumVar, and MaximumVar will store those respective stats.
; StatusVar will store either SUCCESS, ERROR (No response), TIMEOUT (one or more pings got no reply), DNS (could not find host),
; DNS-AS (could not find host, but ping successful on the alternate IP - implies a DNS problem),
; DNS-AF (could not find host, and no response from alternate IP - implies that the connection is dead.)
; LossVar will store how many packets were lost during the ping operation (unless there is no response.)
; Use AltIP to specify an IP address to ping if the domain name could not be resolved.  If SiteOrIP is already an IP, this is useless.
; Include the PingCount parameter to specify the number of pings to send.
; In this case, the AverageVar variable contains the avarage response time.
; Usage: Ping(SiteOrIP, AverageVar, MinimumVar, MaximumVar, StatusVar, LossVar[, PingCount, AltIP])

Ping(SiteOrIP, ByRef AverageVar, ByRef MinimumVar, ByRef MaximumVar, ByRef StatusVar, ByRef LossVar, PingCount = 1, AltIP = 0, Timeout = 0)
   {
   If Timeout = 0
      Timeout = 300
   RunWait, %comspec% /c ping %SiteOrIP% -n %PingCount% -w %Timeout% > pingtemp.txt,, Hide
   LineNum := Pingcount + 8
   LossLineNum := PingCount + 6
   FileReadLine, PingResult, pingtemp.txt, %LineNum%
   FileRead, ReplyResult, *t pingtemp.txt
   If AltIP = 0
      AltIPVar = 0
   Else
      AltIPVar = 1
   IfInString, ReplyResult, could not find host
      {
      StatusVar = DNS
      LossVar = %PingCount%/%PingCount%
      If AltIPVar = 1
         {
         RunWait, %comspec% /c ping %AltIP% -n 1 > pingtempalt.txt,, Hide
         FileRead, AltIPResult, pingtempalt.txt
         IfInString, AltIPResult, Reply from
            StatusVar = DNS-AS
         Else
            StatusVar = DNS-AF
         FileDelete, pingtempalt.txt
         }
      }
   Else IfNotInString, ReplyResult, Reply from
      {
      StatusVar = ERROR
      LossVar = %PingCount%/%PingCount%
      }
   Else IfInString, ReplyResult, Request timed out
      {
      StatusVar = TIMEOUT
      FileReadLine, PingLoss, pingtemp.txt, %LossLineNum%
      StringSplit, PingAvg, PingResult, =
      StringSplit, PingStats, PingResult, %A_Space%
      StringTrimLeft, PingAvg, PingAvg4, 1
      StringTrimRight, PingAvg, PingAvg, 1
      StringTrimRight, PingMin, PingStats7, 1
      StringTrimRight, PingMax, PingStats10, 1
      AverageVar = %PingAvg%
      MinimumVar = %PingMin%
      MaximumVar = %PingMax%
      StringSplit, PingLoss, PingLoss, %A_Space%
      LossVar = %PingLoss14%/%PingCount%
      }
   Else
      {
      StringSplit, PingAvg, PingResult, =
      StringSplit, PingStats, PingResult, %A_Space%
      StringTrimLeft, PingAvg, PingAvg4, 1
      StringTrimRight, PingAvg, PingAvg, 1
      StringTrimRight, PingMin, PingStats7, 1
      StringTrimRight, PingMax, PingStats10, 1
      AverageVar = %PingAvg%
      MinimumVar = %PingMin%
      MaximumVar = %PingMax%
      StatusVar = SUCCESS
      LossVar = 0/%PingCount%
      }
   FileDelete, pingtemp.txt
   Return
   }