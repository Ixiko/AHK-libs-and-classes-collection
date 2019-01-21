;========================================================================
; 
; Function:     WaitPixelColor
; Description:  Waits until pixel is a certain color (w/ optional timeout)
; Online Ref.:  http://www.autohotkey.com/forum/topic43807.html
;
; Last Update:  19/July/2009 04:30
;
; Created by:   MasterFocus
;               http://www.autohotkey.net/~MasterFocus/AHK/
;
;========================================================================
;
; p_DesiredColor, p_PosX, p_PosY [, p_TimeOut, p_GetMode, p_ReturnColor]
;
; + Required parameters:
; - p_DesiredColor      The color you are waiting for
; - p_PosX, p_PosY      Pixel coordinates
;
; + Optional parameters:
; - p_TimeOut           Timeout in milliseconds (default is 0, no timeout)
; - p_GetMode           PixelGetColor mode(s) (default is blank)
; - p_ReturnColor       Boolean, see returned values below (deafult is 0)
;
; + Returned values when ReturnColor is 0 (false):
; - 0      The desired color was found
; - 1      There was a problem during PixelGetColor
; - 2      The function timed out
;
; + Returned values when ReturnColor is 1 (true):
; - Blank        There was a problem during PixelGetColor
; - Non-blank    Will be the latest found color, even if not the desired one
;
;========================================================================

WaitPixelColor(p_DesiredColor,p_PosX,p_PosY,p_TimeOut=0,p_GetMode="",p_ReturnColor=0)
{
    l_Start := A_TickCount
    Loop
    {
        PixelGetColor, l_RetrievedColor, %p_PosX%, %p_PosY%, %p_GetMode%
        If ErrorLevel
        {
            If !p_ReturnColor
                Return 1
            Break
        }
        If ( l_RetrievedColor = p_DesiredColor )
        {
            If !p_ReturnColor
                Return 0
            Break
        }
        If ( p_TimeOut ) && ( A_TickCount - l_Start >= p_TimeOut )
        {
            If !p_ReturnColor
                Return 2
            Break
        }
    }
    Return l_RetrievedColor
}