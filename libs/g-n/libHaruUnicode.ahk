;----------------------------------------------------
;-- HPDF - libHaru Wrapper          - Thrawn  2009 --
;--      + Unicode 32&64bit support - gwarble 2018 --
;----------------------------------------------------

HPDF_LoadDLL(dll) {
   return, DllCall("LoadLibrary", "Str", dll)
}
HPDF_UnloadDLL(hDll) {
   DllCall("FreeLibrary", "UPtr", hDll)
}
HPDF_New(user_error_fn,user_data) {
   Return, DllCall("libhpdf\HPDF_New", "UPtr", user_error_fn, "UPtr", user_data, "Cdecl ptr")
}
HPDF_NewEx(user_error_fn,user_data) {
   Return, DllCall("libhpdf\HPDF_New", "UPtr", user_error_fn, "UPtr", user_data, "Cdecl ptr")
}
HPDF_Free(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_Free", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_NewDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_NewDoc", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_FreeDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_FreeDoc", "UPtr", hDoc, "Cdecl ptr")
} 
HPDF_FreeDocAll(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_FreeDocAll", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_SaveToFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_SaveToFile", "UPtr", hDoc, "AStr", filename, "Cdecl ptr")
}
HPDF_HasDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_HasDoc", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_SetErrorHandler(ByRef hDoc, ByRef errorhandler) {
   Return, DllCall("libhpdf\HPDF_SetErrorHandler", "UPtr", hDoc, "UPtr", errorhandler, "Cdecl ptr")
}
HPDF_GetError(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetError", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_ResetError(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_ResetError", "UPtr", hDoc, "Cdecl ptr")
}

;----------------------------------------------------
;---- Pages -----------------------------------------
;----------------------------------------------------
HPDF_SetPagesConfiguration(ByRef hDoc, page_per_pages) {
   Return, DllCall("libhpdf\HPDF_SetPagesConfiguration", "UPtr", hDoc, "Ptr", page_per_pages, "Cdecl ptr")
}
HPDF_SetPageLayout(ByRef hDoc, layout) {
   Return, DllCall("libhpdf\HPDF_SetPageLayout", "UPtr", hDoc, "Ptr", layout, "Cdecl ptr")
}
HPDF_GetPageLayout(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetPageLayout", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_SetPageMode(ByRef hDoc, mode) {
   HPDF_PAGE_MODE_USE_NONE := 0
   HPDF_PAGE_MODE_USE_OUTLINE := 1
   HPDF_PAGE_MODE_USE_THUMBS := 2
   HPDF_PAGE_MODE_FULL_SCREEN := 3
   thisMode := HPDF_PAGE_MODE_%mode%
   Return, DllCall("libhpdf\HPDF_SetPageMode", "UPtr", hDoc, "Ptr", thisMode, "Cdecl ptr")
}
HPDF_GetPageMode(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetPageMode", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_SetOpenAction(ByRef hDoc, ByRef open_action) {
   Return, DllCall("libhpdf\HPDF_SetOpenAction", "UPtr", hDoc, "UPtr", open_action, "Cdecl ptr")
}
HPDF_GetCurrentPage(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetCurrentPage", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_AddPage(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_AddPage", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_InsertPage(ByRef hDoc, ByRef target) {
   Return, DllCall("libhpdf\HPDF_InsertPage", "UPtr", hDoc, "UPtr", target, "Cdecl ptr")
}

;----------------------------------------------------
;---- Page ------------------------------------------
;----------------------------------------------------
HPDF_Page_SetWidth(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetWidth", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetHeight(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetHeight", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetSize(ByRef hPage, size, direction) {
   HPDF_PAGE_SIZE_LETTER = 0
   HPDF_PAGE_SIZE_LEGAL = 1
   HPDF_PAGE_SIZE_A3 = 2
   HPDF_PAGE_SIZE_A4 = 3
   HPDF_PAGE_SIZE_A5 = 4
   HPDF_PAGE_SIZE_B4 = 5
   HPDF_PAGE_SIZE_B5 = 6
   HPDF_PAGE_SIZE_EXECUTIVE = 7
   HPDF_PAGE_SIZE_US4x6 = 8
   HPDF_PAGE_SIZE_US4x8 = 9
   HPDF_PAGE_SIZE_US5x7 = 10
   HPDF_PAGE_SIZE_COMM10 = 11
   HPDF_PAGE_SIZE_EOF = 12
   HPDF_PAGE_PORTRAIT = 0
   HPDF_PAGE_LANDSCAPE = 1
   thisSize := HPDF_PAGE_SIZE_%size%
   thisDirection := HPDF_PAGE_%direction%
   Return, DllCall("libhpdf\HPDF_Page_SetSize", "UPtr", hPage, "UPtr", thisSize, "UPtr", thisDirection, "Cdecl ptr")
}
HPDF_Page_SetRotate(ByRef hPage, angle) {
   Return, DllCall("libhpdf\HPDF_Page_SetRotate", "UPtr", hPage, "Ptr", angle, "Cdecl ptr")
}
HPDF_Page_GetWidth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetWidth", "UPtr", hPage, "Cdecl Float")
}
HPDF_Page_GetHeight(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetHeight", "UPtr", hPage, "Cdecl Float")
}
HPDF_Page_CreateDestination(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_CreateDestination", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_CreateTextAnnot(ByRef hPage, rect, text, encoder) {
   Return, DllCall("libhpdf\HPDF_Page_CreateTextAnnot", "UPtr", hPage, "UPtr", rect, "AStr", text, "UPtr", encoder, "Cdecl ptr")
}
HPDF_Page_CreateLinkAnnot(ByRef hPage, ByRef rect, ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Page_CreateLinkAnnot", "UPtr", hPage, "UPtr", &rect, "UPtr", dst, "Cdecl ptr")
}
HPDF_Page_CreateURILinkAnnot(ByRef hPage, ByRef rect, uri) {
   Return, DllCall("libhpdf\HPDF_Page_CreateURILinkAnnot", "UPtr", hPage, "UPtr", rect, "AStr", uri, "Cdecl ptr")
}
HPDF_Page_TextWidth(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_TextWidth", "UPtr", hPage, "AStr", text, "Cdecl Float")
}
HPDF_Page_MeasureText(ByRef hPage, text, width, wordwrap, real_width) {
   if real_width = 0
      Return, DllCall("libhpdf\HPDF_Page_MeasureText", "UPtr", hPage, "AStr", text, "Float", width, "Ptr", wordwrap, "Ptr", 0, "Cdecl ptr")
   else
      Return, DllCall("libhpdf\HPDF_Page_MeasureText", "UPtr", hPage, "AStr", text, "Float", width, "Ptr", wordwrap, "Float", real_width, "Cdecl ptr")
}
HPDF_Page_GetGMode(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGMode", "UPtr", hPage, "Cdecl Char")
}
HPDF_Page_GetCurrentPos(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentPos", "UPtr", hPage, "Cdecl Uint")
}
HPDF_Page_GetCurrentTextPos(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentTextPos", "UPtr", hPage, "Cdecl Uint")
}
HPDF_Page_GetCurrentFont(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentFont", "UPtr", hPage)
}
HPDF_Page_GetCurrentFontSize(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentFontSize", "UPtr", hPage, "Cdecl Float")
}
HPDF_Page_GetTransMatrix(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTransMatrix", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetLineWidth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineWidth", "UPtr", hPage, "Cdecl Float")
}
HPDF_Page_GetLineCap(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineCap", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetLineJoin(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineJoin", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetMiterLimit(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetMiterLimit", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetDash(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetDash", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetFlat(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetFlat", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetCharSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCharSpace", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetWordSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetWordSpace", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetHorizontalScalling(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetHorizontalScalling", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetHorizontalScaling(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetHorizontalScalling", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetTextLeading(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextLeading", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetTextRenderingMode(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextRenderingMode", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetTextRise(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextRise", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetRGBFill(ByRef hPage) {
   return, DllCall("libhpdf\HPDF_Page_GetRGBFill", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetRGBStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetRGBStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetCMYKFill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCMYKFill", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetCMYKStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCMYKStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetGrayFill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGrayFill", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetGrayStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGrayStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetStrokingColorSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetStrokingColorSpace", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetFillingColorSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetFillingColorSpace", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetTextMatrix(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextMatrix", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GetGStateDepth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGStateDepth", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_SetSlideShow(ByRef hPage, type, disp_time, trans_time) {
   HPDF_TS_WIPE_RIGHT = 0
   HPDF_TS_WIPE_UP = 1
   HPDF_TS_WIPE_LEFT = 2
   HPDF_TS_WIPE_DOWN = 3
   HPDF_TS_BARN_DOORS_HORIZONTAL_OUT = 4
   HPDF_TS_BARN_DOORS_HORIZONTAL_IN = 5
   HPDF_TS_BARN_DOORS_VERTICAL_OUT = 6
   HPDF_TS_BARN_DOORS_VERTICAL_IN = 7
   HPDF_TS_BOX_OUT = 8
   HPDF_TS_BOX_IN = 9
   HPDF_TS_BLINDS_HORIZONTAL = 10
   HPDF_TS_BLINDS_VERTICAL = 11
   HPDF_TS_DISSOLVE = 12
   HPDF_TS_GLITTER_RIGHT = 13
   HPDF_TS_GLITTER_DOWN = 14
   HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT = 15
   HPDF_TS_REPLACE = 16
   HPDF_TS_EOF = 17
   thisType := HPDF_TS_%type%
   Return, DllCall("libhpdf\HPDF_Free", "UPtr", hPage, "Ptr", thisType, "Float", disp_time, "Float", trans_time, "Cdecl ptr")
}

;----------------------------------------------------
;---- Destination -----------------------------------
;----------------------------------------------------
HPDF_Destination_SetXYZ(ByRef dst, left, top, zoom) {
   Return, DllCall("libhpdf\HPDF_Destination_SetXYZ", "UPtr", dst, "Float", left, "Float", top, "Float", zoom, "Cdecl ptr")
}
HPDF_Destination_SetFit(ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFit", "UPtr", dst, "Cdecl ptr")
}
HPDF_Destination_SetFitH(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitH", "UPtr", dst, "Float", top, "Cdecl ptr")
}
HPDF_Destination_SetFitV(ByRef dst, left) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitV", "UPtr", dst, "Float", left, "Cdecl ptr")
}
HPDF_Destination_SetFitR(ByRef dst, left, bottom, right, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitR", "UPtr", dst, "Float", left, "Float", bottom, "Float", right, "Float", top, "Cdecl ptr")
}
HPDF_Destination_SetFitB(ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitB", "UPtr", dst, "Cdecl ptr")
}
HPDF_Destination_SetFitBH(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitBH", "UPtr", dst, "Float", top, "Cdecl ptr")
}
HPDF_Destination_SetFitBV(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitBV", "UPtr", dst, "Float", top, "Cdecl ptr")
}

;----------------------------------------------------
;---- Encodings -------------------------------------
;----------------------------------------------------
HPDF_GetEncoder(ByRef hDoc, encoding_name) {
   Return, DllCall("libhpdf\HPDF_GetEncoder", "UPtr", hDoc, "AStr", encoding_name, "Cdecl ptr")
}
HPDF_GetCurrentEncoder(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetCurrentEncoder", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_SetCurrentEncoder(ByRef hDoc, encoding_name) {
   Return, DllCall("libhpdf\HPDF_SetCurrentEncoder", "UPtr", hDoc, "AStr", encoding_name, "Cdecl ptr")
}
HPDF_UseJPEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseJPEncodings", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseKREncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseKREncodings", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseCNSEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNSEncodings", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseCNTEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNTEncodings", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseUTFEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseUTFEncodings", "UPtr", hDoc, "Cdecl ptr")
}
;----------------------------------------------------
;---- Font ------------------------------------------
;----------------------------------------------------
HPDF_AddPageLabel(ByRef hDoc, page_num, style, first_page, prefix) {
   HPDF_PAGE_NUM_STYLE_DECIMAL = 0
   HPDF_PAGE_NUM_STYLE_UPPER_ROMAN = 1
   HPDF_PAGE_NUM_STYLE_LOWER_ROMAN = 2
   HPDF_PAGE_NUM_STYLE_UPPER_LETTERS = 3
   HPDF_PAGE_NUM_STYLE_LOWER_LETTERS = 4
   HPDF_PAGE_NUM_STYLE_EOF = 5
   thisStyle := HPDF_PAGE_NUM_STYLE_%style%
   Return, DllCall("libhpdf\HPDF_AddPageLabel", "UPtr", hDoc, "Ptr", page_num, "Ptr", thisStyle, "Ptr", first_page, "AStr", prefix, "Cdecl ptr")
}

HPDF_GetFont(ByRef hDoc, font_name, encoding_name) {
   if encoding_name = 0
      Return, DllCall("libhpdf\HPDF_GetFont", "UPtr", hDoc, "AStr", font_name, "Ptr", 0)
   else
      Return, DllCall("libhpdf\HPDF_GetFont", "UPtr", hDoc, "AStr", font_name, "AStr", encoding_name, "Cdecl ptr")
}
HPDF_GetFont2(ByRef hDoc, ByRef font_name, encoding_name) {
   if encoding_name = 0
      Return, DllCall("libhpdf\HPDF_GetFont", "UPtr", hDoc, "UPtr", font_name, "Ptr", 0)
   else
      Return, DllCall("libhpdf\HPDF_GetFont", "UPtr", hDoc, "UPtr", font_name, "AStr", encoding_name, "Cdecl ptr")
}
HPDF_LoadType1FontFromFile(ByRef hDoc, afmfilename, pfmfilename) {
   Return, DllCall("libhpdf\HPDF_LoadType1FontFromFile", "UPtr", hDoc, "AStr", afmfilename, "AStr", pfmfilename, "Cdecl ptr")
}
HPDF_LoadTTFontFromFile(ByRef hDoc, file_name, embedding) {
   Return, DllCall("libhpdf\HPDF_LoadTTFontFromFile", "UPtr", hDoc, "AStr", file_name, "Ptr", embedding, "Cdecl ptr")
}
HPDF_LoadTTFontFromFile2(ByRef hDoc, file_name, index, embedding) {
   Return, DllCall("libhpdf\HPDF_LoadTTFontFromFile2", "UPtr", hDoc, "AStr", file_name, "Ptr", index, "Ptr", embedding, "Cdecl ptr")
}
HPDF_UseJPFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseJPFonts", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseKRFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseKRFonts", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseCNSFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNSFonts", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_UseCNTFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNTFonts", "UPtr", hDoc, "Cdecl ptr")
}

;----------------------------------------------------
;---- Attributes ------------------------------------
;----------------------------------------------------
HPDF_SetInfoAttr(ByRef hDoc, type, value) {
   HPDF_INFO_AUTHOR = 2
   HPDF_INFO_CREATOR = 3
   HPDF_INFO_PRODUCER = 4
   HPDF_INFO_TITLE = 5
   HPDF_INFO_SUBJECT = 6
   HPDF_INFO_KEYWORDS = 7
   HPDF_INFO_EOF = 8
   thisType := HPDF_INFO_%type%
   Return, DllCall("libhpdf\HPDF_SetInfoAttr", "UPtr", hDoc, "Ptr", thisType, "AStr", value, "Cdecl ptr")
}
HPDF_GetInfoAttr(ByRef hDoc, type) {
   HPDF_INFO_CREATION_DATE = 0
   HPDF_INFO_MOD_DATE = 1
   HPDF_INFO_AUTHOR = 2
   HPDF_INFO_CREATOR = 3
   HPDF_INFO_PRODUCER = 4
   HPDF_INFO_TITLE = 5
   HPDF_INFO_SUBJECT = 6
   HPDF_INFO_KEYWORDS = 7
   HPDF_INFO_EOF = 8
   thisType := HPDF_INFO_%type%
   Return, DllCall("libhpdf\HPDF_GetInfoAttr", "UPtr", hDoc, "Ptr", thisType, "Cdecl ptr")
}
HPDF_SetPassword(ByRef hDoc, owner_passwd, user_passwd) {
   Return, DllCall("libhpdf\HPDF_SetPassword", "UPtr", hDoc, "AStr", owner_passwd, "AStr", user_passwd, "Cdecl ptr")
}
HPDF_SetPermission(ByRef hDoc, permission) {
   StringReplace, permission, permission, READ, 0
   StringReplace, permission, permission, PRINT, 4
   StringReplace, permission, permission, EDIT_ALL, 8
   StringReplace, permission, permission, COPY, 16
   StringReplace, permission, permission, EDIT, 32
   Return, DllCall("libhpdf\HPDF_SetPermission", "UPtr", hDoc, "Ptr", permission, "Cdecl ptr")
}
HPDF_SetEncryptionMode(ByRef hDoc, mode, key_len) {
   HPDF_ENCRYPT_R2 = 2
   HPDF_ENCRYPT_R3 = 3
   thisMode := HPDF_ENCRYPT_%mode%
   Return, DllCall("libhpdf\HPDF_SetEncryptionMode", "UPtr", hDoc, "Ptr", thisMode, "Ptr", key_len, "Cdecl ptr")
}
HPDF_SetCompressionMode(ByRef hDoc, mode) {
   HPDF_COMP_NONE = 0
   HPDF_COMP_TEXT = 1
   HPDF_COMP_IMAGE = 2
   HPDF_COMP_METADATA = 4
   HPDF_COMP_ALL = 15
   thisMode := HPDF_COMP_%mode%
   Return, DllCall("libhpdf\HPDF_SetCompressionMode", "UPtr", hDoc, "Ptr", thisMode)
}

;----------------------------------------------------
;---- Graphics --------------------------------------
;----------------------------------------------------
HPDF_Page_Arc(ByRef hPage, x, y, radius, ang1, ang2) {
   Return, DllCall("libhpdf\HPDF_Page_Arc", "UPtr", hPage, "Float", x, "Float", y, "Float", radius, "Float", ang1, "Float", ang2, "Cdecl ptr")
}
HPDF_Page_BeginText(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_BeginText", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_Circle(ByRef hPage, x, y, radius) {
   Return, DllCall("libhpdf\HPDF_Page_Circle", "UPtr", hPage, "Float", x, "Float", y, "Float", radius, "Cdecl ptr")
}
HPDF_Page_ClosePath(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePath", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_ClosePathStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_ClosePathEofillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathEofillStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_ClosePathFillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathFillStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_Concat(ByRef hPage, a, b, c, d, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_Concat", "UPtr", hPage, "Float", a, "Float", b, "Float", c, "Float", d, "Float", x, "Float", y, "Cdecl ptr")
}
HPDF_Page_CurveTo(ByRef hPage, x1, y1, x2, y2, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo", "UPtr", hPage, "Float", x1, "Float", y1, "Float", x2, "Float", y2, "Float", x3, "Float", y3, "Cdecl ptr")
}
HPDF_Page_CurveTo2(ByRef hPage, x2, y2, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo2", "UPtr", hPage, "Float", x2, "Float", y2, "Float", x3, "Float", y3, "Cdecl ptr")
}
HPDF_Page_CurveTo3(ByRef hPage, x1, y1, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo3", "UPtr", hPage, "Float", x1, "Float", y1, "Float", x3, "Float", y3, "Cdecl ptr")
}
HPDF_Page_DrawImage(ByRef hPage, ByRef hImage, x, y, width, height) {
   Return, DllCall("libhpdf\HPDF_Page_DrawImage", "UPtr", hPage, "UPtr", hImage, "Float", x, "Float", y, "Float", width, "Float", height, "Cdecl ptr")
}
HPDF_Page_Ellipse(ByRef hPage, x, y, x_radius, y_radius) {
   Return, DllCall("libhpdf\HPDF_Page_Ellipse", "UPtr", hPage, "Float", x, "Float", y, "Float", x_radius, "Float", y_radius, "Cdecl ptr")
}
HPDF_Page_EndPath(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EndPath", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_EndText(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EndText", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_Eofill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Eofill", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_EofillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EofillStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_ExecuteXObject(ByRef hPage, ByRef obj) {
   Return, DllCall("libhpdf\HPDF_Page_ExecuteXObject", "UPtr", hPage, "UPtr", obj, "Cdecl ptr")
}
HPDF_Page_Fill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Fill", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_FillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_FillStroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GRestore(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GRestore", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_GSave(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GSave", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_LineTo(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_LineTo", "UPtr", hPage, "Float", x, "Float", y)
}
HPDF_Page_MoveTextPos(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTextPos", "UPtr", hPage, "Float", x, "Float", y)
}
HPDF_Page_MoveTextPos2(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTextPos2", "UPtr", hPage, "Float", x, "Float", y)
}
HPDF_Page_MoveTo(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTo", "UPtr", hPage, "Float", x, "Float", y, "Cdecl ptr")
}
HPDF_Page_MoveToNextLine(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_MoveToNextLine", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_Rectangle(ByRef hPage, x, y, width, height) {
   Return, DllCall("libhpdf\HPDF_Page_Rectangle", "UPtr", hPage, "Float", x, "Float", y, "Float", width, "Float", height, "Cdecl ptr")
}
HPDF_Page_SetCharSpace(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetCharSpace", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetCMYKFill(ByRef hPage, c, m, y, k) {
   Return, DllCall("libhpdf\HPDF_Page_SetCMYKFill", "UPtr", hPage, "Float", c, "Float", m, "Float", y, "Float", k, "Cdecl ptr")
}
HPDF_Page_SetCMYKStroke(ByRef hPage, c, m, y, k) {
   Return, DllCall("libhpdf\HPDF_Page_SetCMYKStroke", "UPtr", hPage, "Float", c, "Float", m, "Float", y, "Float", k, "Cdecl ptr")
}
HPDF_Page_SetDash(ByRef hPage, ByRef dash_ptn, num_elem, phase) {
   Return, DllCall("libhpdf\HPDF_Page_SetDash", "UPtr", hPage, "UPtr", dash_ptn, "Ptr", num_elem, "Ptr", phase, "Cdecl ptr")
}
HPDF_Page_SetExtGState(ByRef hPage, ByRef ext_gstate) {
   Return, DllCall("libhpdf\HPDF_Page_SetExtGState", "UPtr", hPage, "UPtr", ext_gstate, "Cdecl ptr")
}
HPDF_Page_SetFontAndSize(ByRef hPage, ByRef font, size) {
   Return, DllCall("libhpdf\HPDF_Page_SetFontAndSize", "UPtr", hPage, "UPtr", font, "Float", size, "Cdecl ptr")
}
HPDF_Page_SetGrayFill(ByRef hPage, gray) {
   Return, DllCall("libhpdf\HPDF_Page_SetGrayFill", "UPtr", hPage, "Float", gray, "Cdecl ptr")
}
HPDF_Page_SetGrayStroke(ByRef hPage, gray) {
   Return, DllCall("libhpdf\HPDF_Page_SetGrayStroke", "UPtr", hPage, "Float", gray, "Cdecl ptr")
}
HPDF_Page_SetHorizontalScalling(ByRef hPage, value) {     ; not a typo scalling = scaling
   Return, DllCall("libhpdf\HPDF_Page_SetHorizontalScalling", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetHorizontalScaling(ByRef hPage, value) {     ; fixed typo scalling = scaling
   Return, DllCall("libhpdf\HPDF_Page_SetHorizontalScalling", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetLineCap(ByRef hPage, line_cap) {
   HPDF_BUTT_END = 0
   HPDF_ROUND_END = 1
   HPDF_PROJECTING_SCUARE_END = 2
   HPDF_LINECAP_EOF = 3
   thisLine_cap := HPDF_%line_cap%
   Return, DllCall("libhpdf\HPDF_Page_SetLineCap", "UPtr", hPage, "Ptr", thisLine_cap, "Cdecl ptr")
}
HPDF_Page_SetLineJoin(ByRef hPage, line_join) {
   HPDF_MITER_JOIN = 0
   HPDF_ROUND_JOIN = 1
   HPDF_BEVEL_JOIN = 2
   HPDF_LINEJOIN_EOF = 3
   thisLine_join := HPDF_%line_join%
   Return, DllCall("libhpdf\HPDF_Page_SetLineJoin", "UPtr", hPage, "Ptr", thisLine_join, "Cdecl ptr")
}
HPDF_Page_SetLineWidth(ByRef hPage, line_width) {
   Return, DllCall("libhpdf\HPDF_Page_SetLineWidth", "UPtr", hPage, "Float", line_width, "Cdecl ptr")
}
HPDF_Page_SetMiterLimit(ByRef hPage, miter_limit) {
   Return, DllCall("libhpdf\HPDF_Page_SetMiterLimit", "UPtr", hPage, "Float", miter_limit, "Cdecl ptr")
}
HPDF_Page_SetRGBFill(ByRef hPage, r, g, b) {
   Return, DllCall("libhpdf\HPDF_Page_SetRGBFill", "UPtr", hPage, "Float", r, "Float", g, "Float", b)
}
HPDF_Page_SetRGBStroke(ByRef hPage, r, g, b) {
   Return, DllCall("libhpdf\HPDF_Page_SetRGBStroke", "UPtr", hPage, "Float", r, "Float", g, "Float", b, "Cdecl ptr")
}
HPDF_Page_SetTextLeading(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextLeading", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetTextRenderingMode(ByRef hPage, mode) {
   HPDF_FILL = 0
   HPDF_STROKE = 1
   HPDF_FILL_THEN_STROKE = 2
   HPDF_INVISIBLE = 3
   HPDF_FILL_CLIPPING = 4
   HPDF_STROKE_CLIPPING = 5
   HPDF_FILL_STROKE_CLIPPING = 6
   HPDF_CLIPPING = 7
   HPDF_RENDERING_MODE_EOF = 8
   thisMode := HPDF_%mode%
   Return, DllCall("libhpdf\HPDF_Page_SetTextRenderingMode", "UPtr", hPage, "Ptr", thisMode, "Cdecl ptr")
}
HPDF_Page_SetTextRise(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextRise", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_SetWordSpace(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetWordSpace", "UPtr", hPage, "Float", value, "Cdecl ptr")
}
HPDF_Page_ShowText(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowText", "UPtr", hPage, "AStr", text, "Cdecl ptr")
}
HPDF_Page_ShowTextNextLine(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowTextNextLine", "UPtr", hPage, "AStr", text, "Cdecl ptr")
}
HPDF_Page_ShowTextNextLineEx(ByRef hPage, word_space, char_space, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowTextNextLineEx", "UPtr", hPage, "Float", word_space, "Float", char_space, "AStr", text, "Cdecl ptr")
}
HPDF_Page_Stroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Stroke", "UPtr", hPage, "Cdecl ptr")
}
HPDF_Page_TextOut(ByRef hPage, xpos, ypos, text) {
   Return, DllCall("libhpdf\HPDF_Page_TextOut", "UPtr", hPage, "Float", xpos, "Float", ypos, "AStr", text, "Cdecl ptr")
}
HPDF_Page_TextRect(ByRef hPage, left, top, right, bottom, text, align, ByRef len) {
   HPDF_TALIGN_LEFT = 0
   HPDF_TALIGN_RIGHT = 1
   HPDF_TALIGN_CENTER = 2
   HPDF_TALIGN_JUSTIFY = 3
   thisAlignment := HPDF_TALIGN_%align%
   Return, DllCall("libhpdf\HPDF_Page_TextRect", "UPtr", hPage, "Float", left, "Float", top, "Float", right, "Float", bottom, "AStr", text, "Ptr", thisAlignment, "UIntP", len, "Cdecl ptr")
}
HPDF_Page_SetTextMatrix(ByRef hPage, a, b, c, d, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextMatrix", "UPtr", hPage, "Float", a, "Float", b, "Float", c, "Float", d, "Float", x, "Float", y, "Cdecl ptr")
}
;HPDF_Page_ExecuteXObject()
;HPDF_Page_Eoclip()
HPDF_Page_Clip(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Clip", "UPtr", hPage, "Cdecl ptr")
}

;----------------------------------------------------
;---- Images ----------------------------------------
;----------------------------------------------------
HPDF_LoadPngImageFromFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_LoadPngImageFromFile", "UPtr", hDoc, "AStr", filename, "Cdecl ptr")
}
HPDF_LoadPngImageFromFile2(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_LoadPngImageFromFile2", "UPtr", hDoc, "AStr", filename, "Cdecl ptr")
}
HPDF_LoadPngImageFromMem(ByRef hDoc, BufAdr, BufSize) { ; v2.2.0+  ; return hImage
	Return,  DllCall("libhpdf\HPDF_LoadPngImageFromMem", "UPtr", hDoc, "UPtr", BufAdr, "UPtr", BufSize, "Cdecl ptr")
}
HPDF_LoadRawImageFromFile(ByRef hDoc, filename, width, height, color_space) {
   HPDF_CS_DEVICE_GRAY := 0
   HPDF_CS_DEVICE_RGB := 1
   HPDF_CS_DEVICE_CMYK := 2
   thisColor_space := HPDF_CS_DEVICE_%color_space%
   Return, DllCall("libhpdf\HPDF_LoadRawImageFromFile", "UPtr", hDoc, "AStr", filename, "UPtr", width, "UPtr", height, "Ptr", thisColor_space, "Cdecl ptr")
}
HPDF_LoadRawImageFromMem(ByRef hDoc, buf, width, height, color_space, bits_per_component) {
   HPDF_CS_DEVICE_GRAY = 0
   HPDF_CS_DEVICE_RGB = 1
   HPDF_CS_DEVICE_CMYK = 2
   thisColor_space := HPDF_CS_DEVICE_%color_space%
   Return, DllCall("libhpdf\HPDF_LoadRawImageFromMem", "UPtr", hDoc, "UPtr", buf, "Ptr", width, "Ptr", height, "Ptr", color_space, "Ptr", bits_per_component, "Cdecl ptr")
}
HPDF_LoadJpegImageFromFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_LoadJpegImageFromFile", "UPtr", hDoc, "AStr", filename, "Cdecl ptr")
}
HPDF_LoadJpegImageFromMem(ByRef hDoc, BufAdr, BufSize) { ; v2.2.0+  ; return hImage
	Return,  DllCall("libhpdf\HPDF_LoadJpegImageFromMem", "UPtr", hDoc, "UPtr", BufAdr, "UPtr", BufSize, "Cdecl ptr")
}
HPDF_Image_GetSize(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetSize", "UPtr", image, "Cdecl ptr")
}
HPDF_Image_GetWidth(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetWidth", "UPtr", image, "Cdecl ptr")
}
HPDF_Image_GetHeight(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetHeight", "UPtr", image, "Cdecl ptr")
}
HPDF_Image_GetBitsPerComponent(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetBitsPerComponent", "UPtr", image, "Cdecl ptr")
}
HPDF_Image_GetColorSpace(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetColorSpace", "UPtr", image, "Cdecl ptr")
}
HPDF_Image_SetColorMask(ByRef image, rmin, rmax, gmin, gmax, bmin, bmax) {
   Return, DllCall("libhpdf\HPDF_Image_SetColorMask", "UPtr", image, "Ptr", rmin, "Ptr", rmax, "Ptr", gmin, "Ptr", gmax, "Ptr", bmin, "Ptr", bmax)
}
HPDF_Image_SetMaskImage(ByRef image, ByRef mask_image) {
   Return, DllCall("libhpdf\HPDF_Image_SetMaskImage", "UPtr", image, "UPtr", mask_image, "Cdecl ptr")
}

;----------------------------------------------------
;---- Outlines --------------------------------------
;----------------------------------------------------
HPDF_CreateOutline(ByRef hDoc, ByRef parent, title, ByRef encoder) {
   if parent = 0
   {
      if encoder = 0
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UPtr", hDoc, "Ptr", 0, "AStr", title, "Ptr", 0, "Cdecl ptr")
      else
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UPtr", hDoc, "Ptr", 0, "AStr", title, "UPtr", encoder, "Cdecl ptr")
   }
   else
   {
      if encoder = 0
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UPtr", hDoc, "UPtr", parent, "AStr", title, "Ptr", 0, "Cdecl ptr")
      else
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UPtr", hDoc, "UPtr", parent, "AStr", title, "UPtr", encoder, "Cdecl ptr")
   }
}
HPDF_Outline_SetOpened(ByRef outline, opened) {
   Return, DllCall("libhpdf\HPDF_Outline_SetOpened", "UPtr", outline, "Ptr", opened)
}
HPDF_Outline_SetDestination(ByRef outline, ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Outline_SetDestination", "UPtr", outline, "UPtr", dst, "Cdecl ptr")
}

;----------------------------------------------------
;--- Annotations ------------------------------------
;----------------------------------------------------
HPDF_LinkAnnot_SetHighlightMode(ByRef annot,mode) {
   HPDF_ANNOT_NO_HIGHTLIGHT := 0
   HPDF_ANNOT_INVERT_BOX := 1
   HPDF_ANNOT_INVERT_BORDER := 2
   HPDF_ANNOT_DOWN_APPEARANCE := 3
   this_mode := HPDF_ANNOT_%mode%
   Return, DllCall("libhpdf\HPDF_LinkAnnot_SetHighlightMode", "UPtr", annot, "Ptr", thisMode)
}

HPDF_LinkAnnot_SetBorderStyle(ByRef annot,width,dash_on,dash_off) {
   Return, DllCall("libhpdf\HPDF_LinkAnnot_SetBorderStyle", "UPtr", annot, "Float", width, "UPtr", dash_on, "UPtr", dash_off)
}

HPDF_TextAnnot_SetIcon(ByRef annot,icon) {
   HPDF_ANNOT_ICON_COMMENT := 0
   HPDF_ANNOT_ICON_KEY := 1
   HPDF_ANNOT_ICON_NOTE := 2
   HPDF_ANNOT_ICON_HELP := 3
   HPDF_ANNOT_ICON_NEW_PARAGRAPH := 4
   HPDF_ANNOT_ICON_PARAGRAPH := 5
   HPDF_ANNOT_ICON_INSERT := 6
   thisIcon := HPDF_ANNOT_ICON_%icon%
   Return, DllCall("libhpdf\HPDF_TextAnnot_SetIcon", "UPtr", annot, "Ptr", thisIcon)
}

HPDF_TextAnnot_SetOpened(ByRef annot,open) {
   Return, DllCall("libhpdf\HPDF_TextAnnot_SetOpened", "UPtr", annot, "Ptr", open)
}

HPDF_Annotation_SetBorderStyle(ByRef annot,subtype,width,dash_on,dash_off,dash_phase) {
   HPDF_BS_SOLID := 0
   HPDF_BS_DASHED := 1
   HPDF_BS_BEVELED := 2
   HPDF_BS_INSET := 3
   HPDF_BS_UNDERLINED := 4
   thisSubtype := HPDF_BS_%subtype%
   Return, DllCall("libhpdf\HPDF_Annotation_SetBorderStyle", "UPtr", annot, "Ptr", thisSubtype, "Float", width, "UPtr", dash_on, "UPtr", dash_off, "UPtr", dash_phase)
}

;----------------------------------------------------
;---- Structures ------------------------------------
;----------------------------------------------------
HPDF_CreateRect(ByRef rect,left,bottom,right,top) {
   VarSetCapacity(rect, 16, 0)
   Numput(left,rect,0,"Float")
   Numput(bottom,rect,4,"Float")
   Numput(right,rect,8,"Float")
   Numput(top,rect,12,"Float")
}
HPDF_ReadRect(ByRef rect,Byref left,Byref bottom,Byref right,Byref top) {
   left := NumGet(rect,0,"Float")
   bottom := NumGet(rect,4,"Float")
   right := NumGet(rect,8,"Float")
   top := NumGet(rect,12,"Float")
}
HPDF_GetPoint(ByRef point, ByRef x, ByRef y) {
   x := NumGet(&NumGet(point,0,"UPtr")+0,0,"Float")
   y := NumGet(point,4,"UFloat")
}

;----------------------------------------------------
;---- Helpers ---------------------------------------
;----------------------------------------------------
print_grid(ByRef pdf, ByRef page,inc=5,stepsize=2,bigstep=2) {
    height := HPDF_Page_GetHeight(page)
    width := HPDF_Page_GetWidth(page)
    font := HPDF_GetFont(pdf, "Helvetica", 0)
    HPDF_Page_SetFontAndSize(page, font, 5)
    HPDF_Page_SetGrayFill(page, 0.5)
    HPDF_Page_SetGrayStroke(page, 0.8)
    ;Draw horizontal lines
    y := 0
    while (y < height)
    {
        if(mod(y,inc*stepsize) == 0)
            HPDF_Page_SetLineWidth(page, 0.5)
        else
        {
            if (HPDF_Page_GetLineWidth(page) != 0.25)
                HPDF_Page_SetLineWidth(page, 0.25)
        }
        HPDF_Page_MoveTo(page, 0, y)
        HPDF_Page_LineTo(page, width, y)
        HPDF_Page_Stroke(page)
        if (mod(y,inc*stepsize*bigstep) == 0 && y > 0)
        {
            HPDF_Page_SetGrayStroke(page, 0.5)
            HPDF_Page_MoveTo(page, 0, y)
            HPDF_Page_LineTo(page, 5, y)
            HPDF_Page_Stroke(page)
            HPDF_Page_MoveTo(page, width, y)
            HPDF_Page_LineTo(page, width-5, y)
            HPDF_Page_Stroke(page)
            HPDF_Page_SetGrayStroke(page, 0.8)
        }
        y += inc
    }
    ;Draw vertical lines
    x := 0
    while (x < width)
    {
        if (mod(x,inc*stepsize) == 0)
            HPDF_Page_SetLineWidth(page, 0.5)
        else
        {
            if(HPDF_Page_GetLineWidth(page) != 0.25)
                HPDF_Page_SetLineWidth(page, 0.25)
        }
        HPDF_Page_MoveTo(page, x, 0)
        HPDF_Page_LineTo(page, x, height)
        HPDF_Page_Stroke(page)
        if(mod(x,inc*stepsize*bigstep) == 0 && x > 0)
        {
            HPDF_Page_SetGrayStroke(page, 0.5)
            HPDF_Page_MoveTo(page, x, 0)
            HPDF_Page_LineTo(page, x, 5)
            HPDF_Page_Stroke(page)
            HPDF_Page_MoveTo(page, x, height)
            HPDF_Page_LineTo(page, x, height - 5)
            HPDF_Page_Stroke(page)
            HPDF_Page_SetGrayStroke(page, 0.8)
        }
        x += inc
    }
    ;Draw horizontal text
    y := 0
    while (y < height)
    {
        if (mod(y,inc*stepsize*bigstep) == 0 && y > 0)
        {
            HPDF_Page_BeginText(page)
            HPDF_Page_MoveTextPos(page, 5, y - 2)
            HPDF_Page_ShowText(page, y)
            HPDF_Page_EndText(page)

            HPDF_Page_BeginText(page)
            HPDF_Page_MoveTextPos(page, width - 15, y - 2)
            HPDF_Page_ShowText(page, y)
            HPDF_Page_EndText(page)
        }

        y += inc
    }
    ;Draw vertical text
    x := 0
    while (x < width)
    {
        if (mod(x,inc*stepsize*bigstep) == 0 && x > 0)
        {
            HPDF_Page_BeginText(page)
            HPDF_Page_MoveTextPos(page, x, 5)
            HPDF_Page_ShowText(page, x)
            HPDF_Page_EndText(page)

            HPDF_Page_BeginText(page)
            HPDF_Page_MoveTextPos(page, x, height - 10)
            HPDF_Page_ShowText(page, x)
            HPDF_Page_EndText(page)
        }

        x += inc
    }
    HPDF_Page_SetGrayFill(page, 0)
    HPDF_Page_SetGrayStroke(page, 0)
}


;----------------------------------------------------
;--- Unused ? ---------------------------------------
;----------------------------------------------------
HPDF_SaveToStream(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_SaveToStream", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_GetStreamSize(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetStreamSize", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_ReadFromStream(ByRef hDoc, ByRef buffer, ByRef buffer_size) {
   Return, DllCall("libhpdf\HPDF_ReadFromStream", "UPtr", hDoc, "UPtr", buffer, "UPtr", buffer_size,  "Cdecl ptr")
}
HPDF_ResetStream(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_ResetStream", "UPtr", hDoc, "Cdecl ptr")
}
HPDF_HasDoc(ByRef hDoc)
HPDF_SetErrorHandler(ByRef hDoc, user_error_fn)
HPDF_GetError(ByRef hDoc)
HPDF_ResetError(ByRef hDoc)