;------------------------------
;
; Function: Edit_AutoSetTabStops v0.2 (Preview)
;
; Description:
;
;   Automatically sets the tab stops for an Edit control by examining the
;   tab-delimited data in the control and then setting the tabs stops so that
;   each column is wide enough to show all fields in the column.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_ColumnGap - The amount of empty space, in dialog template units, to
;       separate each column.  The minimum is 1.  The default is 6 which is
;       equal to the width of 1.5 average characters of the edit control's font.
;
;   p_MaxSample - The maximum number of records to sample.  The default is 0
;       which indicates that all records will be sampled.
;
; Returns:
;
;   An AutoHotkey object that contains a simple array of tab stops (measured in
;   dialog template units) that were set for the edit control.  If the MaxIndex
;   property is null (tests as FALSE) then no data was found in the Edit control
;   and the tab stops were set to the system default.  Otherwise, the MaxIndex
;   property contains the number of elements in the array.
;
; Calls to other functions:
;
; * <Edit_GetFont>
; * <Edit_GetText>
; * <Edit_SetTabStops>
; * Fnt_Pixels2DialogTemplateUnits (Fnt library)
;
; Remarks:
;
;   The p_MaxSample parameter contains the maximum number of records to read
;   in order to determine the maximum width of the columns.  The default is 0
;   which indicates that all records will be processed.  For large or very large
;   files, setting a value to this parameter will ensure that the function will
;   return in a timely manner.  However, the results cannot be assured unless
;   all of the records are processed.
;
;   To correctly format tab-delimited data in an edit control, the _minimum_
;   number of tab stops that can be set is equal to the number of tab-delimited
;   columns minus 1.  So for 3 columns, 2 tab stops must be set.  There are two
;   problems with this approach.  First, the tab stop following the last column
;   is not set so if the user wants to manually add a column to the data, the
;   data will not be positioned correctly which is relative to the widest field
;   from the previous column.  Next, the last tab stop set also establishes the
;   default size for all subsequent tab stops.  This can be problematic, or
;   awkward at least, if the last tab stop set is unusually large or small.  To
;   resolve these problems, the number of tab stops set is equal to the number
;   of tab-delimited columns plus 1.  So for 3 columns, 4 tab stops are set.
;   The next-to-last tab stop establishes the width of the right-most column and
;   the final tab stop is set to 32 dialog template units which is the system
;   default.
;
;-------------------------------------------------------------------------------
Edit_AutoSetTabStops(hEdit,p_ColumnGap=6,p_MaxSample=0)
    {
    Static Dummy0105
          ,HWND_DESKTOP:=0
          ,MAXINT      :=0x7FFFFFFF
          ,s_ColumnGap :=6  ;-- Default column gap

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    if p_ColumnGap is not Integer
        p_ColumnGap:=s_ColumnGap
     else if (p_ColumnGap<1)
        p_ColumnGap:=s_ColumnGap

    if p_MaxSample is not Integer
        p_MaxSample:=MAXINT
     else if (p_MaxSample<1)
        p_MaxSample:=MAXINT

    ;[================]
    ;[  Process Prep  ]
    ;[================]
    ;-- Initialize
    ColumnWidth:=[]
    VarSetCapacity(SIZE,8,0)

    ;-- Get the Edit control's font
    hFont:=Edit_GetFont(hEdit)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    hFont_Old:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get text from the Edit control
    l_Data:=Edit_GetText(hEdit)

    ;[===========]
    ;[  Process  ]
    ;[===========]
    ;-- Determine the maximum width, in pixels, for each column
    l_NbrOfColumns:=0
    Loop Parse,l_Data,`n,`r
        {
        ;-- Maximum sample limit?
        if (A_Index>p_MaxSample)
            Break

        Loop Parse,A_LoopField,%A_Tab%
            {
            ;-- Update number of columns?
            if (A_Index>l_NbrOfColumns)
                {
                l_NbrOfColumns:=A_Index

                ;-- Initialize ColumnWidth array value
                ColumnWidth[A_Index]:=0
                }

            ;-- Skip if null
            if not StrLen(A_LoopField)
                Continue

            ;-- Get the string size, in pixels
            DllCall("GetTextExtentPoint32"
                ,"Ptr",hDC                          ;-- hDC
                ,"Str",A_LoopField                  ;-- lpString
                ,"Int",StrLen(A_LoopField)          ;-- c (string length)
                ,"Ptr",&SIZE)                       ;-- lpSize

            l_Width:=NumGet(SIZE,0,"Int")

            ;-- Update the ColumnWidth array if needed
            if (l_Width>ColumnWidth[A_Index])
                ColumnWidth[A_Index]:=l_Width
            }
        }

    ;-- Release the objects needed by the "GetTextExtentPoint32" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",hFont_Old)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Create and populate an array of tab stops
    TabStops:=[]
    l_TabStop:=0  ;-- In dialog template units
    Loop % l_NbrOfColumns
        {
        Fnt_Pixels2DialogTemplateUnits(hFont,ColumnWidth[A_Index],0,l_HorzDTUs)
        l_TabStop+=l_HorzDTUs+p_ColumnGap
        TabStops[A_Index]:=l_TabStop
        }

    ;-- Set tab stops
    if (l_NbrOfColumns=0)
        Edit_SetTabStops(hEdit)  ;-- Set default tab stops
     else
        {
        TabStops.Push(l_TabStop+32)
        Edit_SetTabStops(hEdit,l_NbrOfColumns+1,TabStops)
        }

    ;-- Return tab stop array (can be a null)
    Return TabStops
    }

