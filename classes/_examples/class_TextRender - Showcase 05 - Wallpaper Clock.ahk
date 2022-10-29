#include TextRender.ahk

; Create new instances of the TextRender class.
time := TextRenderWallpaper()
icon := TextRenderWallpaper()
icon2 := TextRenderWallpaper()

; Update every second.
SetTimer coroutine, 1000

; Use a coroutine instead of a loop for concurrency and to prevent blocking.
; Specifically allows animation while dragging. If you use a loop that won't work.
; Change TextRenderWallpaper() to just TextRender() to see this in action.
coroutine() {
    global

    ; Draw the main clock.
    time.Render(A_Hour ":" A_Min ":" A_Sec          ; Current Time
        , {x:"right", y:"top", c:0x66000000, m:0}   ; top-right, transparent black, no margin
        , "s:10vmin")                               ; font size 10% of viewport minimum

    ; Dark shadow.
    icon.Render(Format("{:02}", mod(A_Sec + 1, 60)) ; Zero pad seconds
        , {x:"right", c:"None", y: time.y + time.h} ; No background
        , "s:10vmin c:0x4A000000")

    ; Light shadow.
    icon2.Render(Format("{:02}", mod(A_Sec + 2, 60))
        , {x:"right", c:"None", y: time.y + 2*time.h}
        , "s:10vmin c:0x11000000")

}

Esc:: ExitApp