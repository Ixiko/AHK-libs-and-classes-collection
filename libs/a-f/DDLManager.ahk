;********************
;*                  *
;*    DDLManager    *
;*                  *
;********************
;
;
;   Description
;   ===========
;   This function is used to manage one or more DDLs (drop-down lists).  This
;   function can also be used to manage other types of lists.
;
;
;
;   Parameters
;   ==========
;
;       Name                Description
;       ----                -----------
;       p_Command           DDL command.  [Required].
;
;                           Valid commands include the following:
;
;                             Command       Description
;                             -------       -----------
;                             Push          Push (add to the top) the value of
;                                           p_Item.  This command is often used
;                                           just before a DDL is saved.
;
;                                           This command also resets the
;                                           FirstPush flag.
;
;
;                             PushIf        Conditional push.  See the 
;                                           "Processing Notes" section (below)
;                                           for the conditions and associated
;                                           actions.
;
;                                           The "PushIf" command is useful for 
;                                           an ever-changing combobox objects
;                                           where the object needs to be updated
;                                           from sources other than the user.
;                                           Ex: favorites, saved, etc.
;
;
;                             Pop           Pop the first item from the list
;                                           if it exits.
;
;                                           This command also resets the
;                                           FirstPush flag.
;
;
;                             PopIf         Conditional pop.  If a conditional
;                                           push (PushIf) created a temporary
;                                           item, this command will pop that
;                                           temporary item from the list.
;
;                                           This command also resets the
;                                           FirstPush flag.
;
;
;                             Reset         Resets the FirstPush flag so that
;                                           if called for, the next "PushIf"
;                                           command will push instead of
;                                           replace.
;                                           
;
;       p_ListID            List identifier [Optional]  Valid values include
;                           null or an integer from 1 to 9.  This limit can
;                           easily be expanded if needed)  Any other values in 
;                           this field may update the list incorrectly or return
;                           invalid values.
;
;
;       p_List              The list variable.  [Required]  This parameter must
;                           contain a variable name.
;
;
;       p_Delimiter         The character that delimits each list item.
;                           [Required].  If no value is defined (null), the
;                           parameter is set to "|".
;
;
;       p_Item              Item to search for and/or to be pushed on to the top
;                           of the list.  [Required]
;
;
;       p_MaxItems          Maximum number of list items.  [Optional]  The
;                           default is 0 (no limit).
;
;
;
;   Processing Notes
;   ================
;    o  The conditions and associated actions of the "PushIf" command are as
;       follows:
;
;           Condition/Actions
;           ----------------
;           IF the value of p_Item already exists in the list THEN
;               Return the list position where the value of p_Item is located.
;
;           ELSE (new item)
;
;            IF the list has never been pushed THEN
;               Push (insert at the top) the value of p_Item to the list 
;               Return 1.
;
;             ELSE (new item, list previously pushed)
;               Replace the first item in list with the value of p_Item 
;               Return 1.
;
;
;    o  If an item is is to be added to the list by force ("Push" command) or 
;       because the item is unique ("PushIf" command), the following actions are
;       performed before the item is added:
;
;        -  Any occurrences of the value of p_Item in the list ("duplicates" if
;           you will) are removed.
;
;        -  Empty (null) items are removed.  Not only does this keep the list
;           clean, it insures that the only possible empty (null) item is at the
;           top of the list.
;
;
;   o   The p_MaxItems parameter is not enforced until a new and/or unique
;       item is added to the list.  This is to insure that the function:
;
;        1) Operates as quickly as possible.
;
;        2) Does not return a pointer to a list item that no longer exists
;           because it has been truncated.
;
;
;
;   Return Codes
;   ============
;   If p_Command is "Push" or "PushIf", the the position in the list where the
;   value of p_Item is located is returned.
;
;
;   If P_Command is "Pop", the item that was popped from the list is returned.
;   Note that the return value can be empty (null) because the value of the
;   popped item is empty (null) or because the list was empty.
;
;
;   If p_Command is "PopIf", the item that was popped from the list (if
;   anything) is returned. Note that the return value can be empty (null)
;   because the value of the popped item is empty (null) or because nothing
;   was popped.
;
;
;   if p_Command is "Reset", nothing is returned.
;
;   
;
;   Calls To Other Functions
;   ========================
;   None
;
;
;-------------------------------------------------------------------------------
DDLManager(p_Command
          ,p_ListID=""
          ,ByRef p_List=""
          ,p_Delimiter=""
          ,p_Item=""
          ,p_MaxItems=0)
    {
;;;;;    outputdebug Function: %A_ThisFunc%


    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_FirstPush :=true
          ,s_FirstPush1:=true
          ,s_FirstPush2:=true
          ,s_FirstPush3:=true
          ,s_FirstPush4:=true
          ,s_FirstPush5:=true
          ,s_FirstPush6:=true
          ,s_FirstPush7:=true
          ,s_FirstPush8:=true
          ,s_FirstPush9:=true


    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_ItemPos=0


    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    p_Command=%p_Command%      ;-- AutoTrim
    p_ListID=%p_ListID%        ;-- AutoTrim
    if StrLen(p_Delimiter)=0
        p_Delimiter:="|"


    ;[==================]
    ;[  Command: Reset  ]
    ;[==================]
    if p_Command=Reset
        {
        s_FirstPush%p_ListID%:=true
        return
        }


    ;[===========================]
    ;[  PushIf AND Item exists?  ]
    ;[===========================]
    if p_Command=PushIf
        ;-- Is the value of p_Item already in the list?
        if InStr(p_Delimiter . p_List . p_Delimiter
                ,p_Delimiter . p_Item . p_Delimiter)
            loop parse,p_List,%p_Delimiter%
                if (A_LoopField=p_Item)
                    return A_Index


    ;[================]
    ;[  Command: Pop  ]
    ;[================]
    if p_Command=Pop
        {
        ;-- Reset FirstPush
        s_FirstPush%p_ListID%:=true


        ;-- Find 1st delimiter position
        l_DelimiterPos:=InStr(p_List,p_Delimiter)


        ;-- Only 1 item in the list?
        if l_DelimiterPos=0
            {
            l_Pop:=p_List
            p_List:=""
            }
         else
            {
            ;-- Pop and trim
            l_Pop:=SubStr(p_List,1,l_DelimiterPos-1)
            StringTrimLeft p_List,p_List,l_DelimiterPos
            }


        return l_Pop
        }



    ;[==================]
    ;[  Command: PopIf  ]
    ;[==================]
    if p_Command=PopIf
        {
        ;-- Been pushed?
        if not s_FirstPush%p_ListID%
            {
            ;-- Reset FirstPush
            s_FirstPush%p_ListID%:=true


            ;-- Find 1st delimiter position
            l_DelimiterPos:=InStr(p_List,p_Delimiter)
    

            ;-- Only 1 item in the list?
            if l_DelimiterPos=0
                {
                l_Pop:=p_List
                p_List:=""
                }
             else
                {
                ;-- Pop and trim
                l_Pop:=SubStr(p_List,1,l_DelimiterPos-1)
                StringTrimLeft p_List,p_List,l_DelimiterPos
                }
    
    
            return l_Pop
            }


        return
        }


    ;[=====================]
    ;[  Remove duplicates  ]
    ;[       (if any)      ]
    ;[=====================]
    if StrLen(p_Item)
        {
        ;-- Add temporary delimiter borders
        p_List:=p_Delimiter . p_List . p_Delimiter
    
    
        ;-- Remove all occurrences of p_Item, if any
        StringReplace
            ,p_List
            ,p_List
            ,% p_Delimiter . p_Item . p_Delimiter
            ,% p_Delimiter
            ,All
    
    
        ;-- Remove temporary borders
        p_List:=SubStr(p_List,2,StrLen(p_List)-2)
        }


    ;[=====================]
    ;[  Remove null items  ]
    ;[       (if any)      ]
    ;[=====================]
    loop
        {
        StringReplace
            ,p_List
            ,p_List
            ,% p_Delimiter . p_Delimiter
            ,% p_Delimiter
            ,UseErrorLevel

        if ErrorLevel=0
            break
        }

    ;-- Remove leading/trailing delimiters if they exist
    if SubStr(p_List,1,1)=p_Delimiter
        StringTrimLeft p_List,p_List,1

    if SubStr(p_List,StrLen(p_List),1)=p_Delimiter
        StringTrimRight p_List,p_List,1



    ;[=================]
    ;[  Command: Push  ]
    ;[=================]
    if p_Command=Push
        {
        ;-- Reset FirstPush
        s_FirstPush%p_ListID%:=true

        ;-- Push it
        l_ListPos=1
        if StrLen(p_List)=0
            p_List:=p_Item
         else
            ;-- Insert at the top of the list
            p_List:=p_Item . p_Delimiter . p_List 
        }



    ;[===================]
    ;[  Command: PushIf  ]
    ;[===================]
    if p_Command=PushIf
        {
        l_ListPos=1

        ;-- Empty list?
        if StrLen(p_list)=0
            {
            p_List:=p_Item
            s_FirstPush%p_ListID%:=false
            }
         else
            {
            ;-- First push?
            if s_FirstPush%p_ListID%
                {
                ;-- Insert at the top of the list
                p_List:=p_Item . p_Delimiter . p_List  
                s_FirstPush%p_ListID%:=false
                }
             else
                {
                ;-- Find 1st delimiter position
                l_DelimiterPos:=InStr(p_List,p_Delimiter)

                ;-- Only 1 item in the list?
                if l_DelimiterPos=0
                    p_List:=p_Item
                 else
                    {
                    ;-- Replace the first list item with p_Item
                    StringTrimLeft p_List,p_List,l_DelimiterPos
                    p_List:=p_Item . p_Delimiter . p_List
                    }
                }
            }
        }


    ;[=================]
    ;[  Truncate list  ]
    ;[   (if needed)   ]
    ;[=================]
    if p_MaxItems
        {
        l_DelimiterPos=0
        loop parse,p_list,%p_Delimiter%
            {
            l_DelimiterPos:=l_DelimiterPos+StrLen(A_LoopField)+1
            if (A_Index+1>p_MaxItems)
                {
                p_List:=SubStr(p_List,1,l_DelimiterPos-1)
                break
                }
            }
        }


    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
;;;;;    outputdebug End Func: %A_ThisFunc%
    return l_ListPos
    }
