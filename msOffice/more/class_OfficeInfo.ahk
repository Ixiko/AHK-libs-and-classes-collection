; https://autohotkey.com/boards/viewtopic.php?f=6&t=23164
; Updated: Sept. 7, 2016
class OfficeInfo
{
    __New()
    {
        static Programs := { "Excel":      "{00020813-0000-0000-C000-000000000046}"
                           , "Office":     "{2DF8D04C-5BFA-101B-BDE5-00AA0044DE52}"
                           , "Outlook":    "{00062FFF-0000-0000-C000-000000000046}"
                           , "PowerPoint": "{91493440-5A91-11CF-8700-00AA0060263B}"
                           , "Publisher":  "{0002123C-0000-0000-C000-000000000046}"
                           , "Word":       "{00020905-0000-0000-C000-000000000046}" }
        ObjRawSet(this, "_Unlocked", true)
        for ProgramName, ProgramGUID in Programs
            new this._ProgramInfo(ProgramGUID, this)
        this.Delete("_Unlocked")
    }
    
    __Get(aName)
    {
        if !this.HasKey("_Unlocked")
            throw Exception( "`nThe requested key does not exist. Specifically:`n`n"
                           . "Key: " aName )
    }
    
    __Set(aName, aValue)
    {
        if !this.HasKey("_Unlocked")
            throw Exception( "`nCannot create new keys. Specifically:`n`n"
                           . "Key: "   aName "`n"
                           . "Value: " aValue )
        else
            ObjRawSet(this, aName, aValue)
        return this[aName]
    }
    
    class _ProgramInfo
    {
        __New(GUID, Parent)
        {
            this.GUID := GUID
            this.Parent := Parent
            this.GetTypeLibVersion()
            this.GetTypeLib()
            this.GetFlatTypeLib()
        }

        GetTypeLibVersion()
        {
            Loop, Reg, % "HKCR\TypeLib\" this.GUID, K
            {
                for i, VerPart in StrSplit(A_LoopRegName, ".")
                {
                    if VerPart is integer
                        Version .= VerPart "."
                    else if VerPart is xdigit
                        Version .= Format("{:i}", "0x" VerPart) "."
                }
                return this.Version := RTrim(Version, ".")
            }
        }
        
        GetTypeLib()
        {
            try return this.TypeLib := ImportTypeLib(this.GUID, this.Version)
            catch e
                OutputDebug, % "Failed to load type library!`n" 
                             . "GUID: "    this.GUID    "`n"
                             . "Version: " this.Version "`n"
                             . "Message: " e.Message    "`n"
                             . "What: "    e.What       "`n"
                             . "Extra: "   e.Extra      "`n"
                             . "File: "    e.File       "`n"
                             . "Line: "    e.Line       "`n"
        }
        
        GetFlatTypeLib()
        {
            this.Enumerate(this.TypeLib)
            return this.Parent
        }
        
        ; Get each item in the type library and place it in the parent OfficeInfo object.
        Enumerate(a, Depth:=2)
        {
            try for k, v in a
            {
                if IsObject(v) && Depth > 1
                    this.Enumerate(v, Depth - 1)
                else if !this.Parent[k] && !ITL.Properties.IsInternalProperty(k)
                    this.Parent[k] := v  ; store retrieved value in parent
            }
        }
    }
}