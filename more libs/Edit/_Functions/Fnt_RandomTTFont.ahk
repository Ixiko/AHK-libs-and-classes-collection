;------------------------------
;
; Function: Fnt_RandomTTFont
;
; Description:
;
;   Gets a random True Type font.
;
; Type:
;
;   Add-on function.
;
; Returns:
;
;   Typeface name of a random True Type font.  OEM, symbol, and vertical fonts
;   are exclued.
;
; Calls To Other Functions:
;
; * <Fnt_GetListOfFonts>
; * <Fnt_EnumFontFamExProc>  (via callback)
;
; Remarks:
;
;   This add-on function can be used as-is or it can serve as an example or
;   template for a custom function to collect a random font.
;
;-------------------------------------------------------------------------------
Fnt_RandomTTFont()
    {
    Static Dummy7282

          ;-- Character sets
          ,ANSI_CHARSET        :=0
          ,DEFAULT_CHARSET     :=1
          ,SYMBOL_CHARSET      :=2
          ,MAC_CHARSET         :=77
          ,SHIFTJIS_CHARSET    :=128
          ,HANGUL_CHARSET      :=129
          ,JOHAB_CHARSET       :=130
          ,GB2312_CHARSET      :=134
          ,CHINESEBIG5_CHARSET :=136
          ,GREEK_CHARSET       :=161
          ,TURKISH_CHARSET     :=162
          ,VIETNAMESE_CHARSET  :=163
          ,HEBREW_CHARSET      :=177
          ,ARABIC_CHARSET      :=178
          ,BALTIC_CHARSET      :=186
          ,RUSSIAN_CHARSET     :=204
          ,THAI_CHARSET        :=222
          ,EASTEUROPE_CHARSET  :=238
          ,OEM_CHARSET         :=255

          ;-- ChooseFont flags
          ,CF_SCRIPTSONLY:=0x400
                ;-- Exclude OEM and Symbol fonts.

          ,CF_NOOEMFONTS:=0x800
                ;-- Exclude OEM fonts.  Ex: Terminal

          ,CF_NOSIMULATIONS:=0x1000
                ;-- [Future] Exlclude font simulations.

          ,CF_FIXEDPITCHONLY:=0x4000
                ;-- Include fixed-pitch fonts only.

          ,CF_SCALABLEONLY:=0x20000
                ;-- Include scalable fonts only.

          ,CF_TTONLY:=0x40000
                ;-- Include TrueType fonts only.

          ,CF_NOVERTFONTS:=0x1000000
                ;-- Exclude vertical fonts.

          ,CF_INACTIVEFONTS:=0x2000000
                ;-- [Future] Include fonts that are set to Hide in Fonts Control Panel.
                ;   Windows 7+.

          ,CF_NOSYMBOLFONTS:=0x10000000
                ;-- [Custom Flag]  Exclude symbol fonts.

          ,CF_VARIABLEPITCHONLY:=0x20000000
                ;-- [Custom Flag]  Include variable pitch fonts only.

          ,CF_FUTURE:=0x40000000
                ;-- [Custom Flag]  Future.

          ,CF_FULLNAME:=0x80000000
                ;-- [Custom Flag]  If specified, returns the full name of the
                ;   font.  For example, ABC Font Company TrueType Bold Italic
                ;   Sans Serif.  This flag may increase the number of font names
                ;   returned.

    ;-- Build flags
    l_Flags:=0
    l_Flags|=CF_SCRIPTSONLY  ;-- Exclude OEM and Symbol fonts.
    l_Flags|=CF_TTONLY
    l_Flags|=CF_NOVERTFONTS

    ;-- Collect a list of fonts using the specified filters
    l_ListOfFonts:=Fnt_GetListOfFonts("","",l_Flags)

    ;-- Count 'em
    StringReplace l_ListOfFonts,l_ListOfFonts,`n,`n,UseErrorLevel
    l_NumberOfFonts:=ErrorLevel+1

    ;-- Generate a random position
    Random l_RandomPos,1,%l_NumberOfFonts%

    ;-- Extract font name
    Loop Parse,l_ListOfFonts,`n
        if (A_Index=l_RandomPos)
            {
            l_Font:=A_LoopField
            Break
            }

    Return l_Font
    }
