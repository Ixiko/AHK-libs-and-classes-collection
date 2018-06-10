;----------------------------------------------------
; libhpdf_annotation.ahk
;----------------------------------------------------
HPDF_LinkAnnot_SetHighlightMode(ByRef annot,mode) {
   HPDF_ANNOT_NO_HIGHTLIGHT := 0
   HPDF_ANNOT_INVERT_BOX := 1
   HPDF_ANNOT_INVERT_BORDER := 2
   HPDF_ANNOT_DOWN_APPEARANCE := 3

   this_mode := HPDF_ANNOT_%mode%

   Return, DllCall("libhpdf\HPDF_LinkAnnot_SetHighlightMode", "UInt", annot, "Int", thisMode)
}

HPDF_LinkAnnot_SetBorderStyle(ByRef annot,width,dash_on,dash_off) {
   Return, DllCall("libhpdf\HPDF_LinkAnnot_SetBorderStyle", "UInt", annot, "Float", width, "Uint", dash_on, "UInt", dash_off)
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

   Return, DllCall("libhpdf\HPDF_TextAnnot_SetIcon", "UInt", annot, "Int", thisIcon)
}

HPDF_TextAnnot_SetOpened(ByRef annot,open) {
   Return, DllCall("libhpdf\HPDF_TextAnnot_SetOpened", "UInt", annot, "Int", open)
}

HPDF_Annotation_SetBorderStyle(ByRef annot,subtype,width,dash_on,dash_off,dash_phase) {

   HPDF_BS_SOLID := 0
   HPDF_BS_DASHED := 1
   HPDF_BS_BEVELED := 2
   HPDF_BS_INSET := 3
   HPDF_BS_UNDERLINED := 4

   thisSubtype := HPDF_BS_%subtype%

   Return, DllCall("libhpdf\HPDF_Annotation_SetBorderStyle", "UInt", annot, "Int", thisSubtype, "Float", width, "Uint", dash_on, "UInt", dash_off, "UInt", dash_phase)
}



;----------------------------------------------------
; libhpdf_destination.ahk
;----------------------------------------------------
HPDF_Destination_SetXYZ(ByRef dst, left, top, zoom) {
   Return, DllCall("libhpdf\HPDF_Destination_SetXYZ", "UInt", dst, "Float", left, "Float", top, "Float", zoom, "Cdecl int")
}

HPDF_Destination_SetFit(ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFit", "UInt", dst, "Cdecl int")
}

HPDF_Destination_SetFitH(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitH", "UInt", dst, "Float", top, "Cdecl int")
}

HPDF_Destination_SetFitV(ByRef dst, left) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitV", "UInt", dst, "Float", left, "Cdecl int")
}

HPDF_Destination_SetFitR(ByRef dst, left, bottom, right, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitR", "UInt", dst, "Float", left, "Float", bottom, "Float", right, "Float", top, "Cdecl int")
}

HPDF_Destination_SetFitB(ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitB", "UInt", dst, "Cdecl int")
}

HPDF_Destination_SetFitBH(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitBH", "UInt", dst, "Float", top, "Cdecl int")
}

HPDF_Destination_SetFitBV(ByRef dst, top) {
   Return, DllCall("libhpdf\HPDF_Destination_SetFitBV", "UInt", dst, "Float", top, "Cdecl int")
}



;----------------------------------------------------
; libhpdf_documentHandling_basic.ahk
;----------------------------------------------------

HPDF_LoadDLL(dll) {
   return, DllCall("LoadLibrary", "str", dll)
}

HPDF_UnloadDLL(hDll) {
   DllCall("FreeLibrary", "UInt", hDll)
}


HPDF_New(user_error_fn,user_data) {
   Return, DllCall("libhpdf\HPDF_New", "UInt", user_error_fn, "UInt", user_data, "Cdecl int")
}

HPDF_NewEx(user_error_fn,user_data) {
   Return, DllCall("libhpdf\HPDF_New", "UInt", user_error_fn, "UInt", user_data, "Cdecl int")
}


HPDF_Free(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_Free", "UInt", hDoc, "Cdecl int")
}


HPDF_NewDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_NewDoc", "UInt", hDoc, "Cdecl int")
}


HPDF_FreeDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_FreeDoc", "UInt", hDoc, "Cdecl int")
}

HPDF_FreeDocAll(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_FreeDocAll", "UInt", hDoc, "Cdecl int")
}


HPDF_SaveToFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_SaveToFile", "UInt", hDoc, "str", filename, "Cdecl int")
}


HPDF_HasDoc(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_HasDoc", "UInt", hDoc, "Cdecl int")
}


HPDF_SetErrorHandler(ByRef hDoc, ByRef errorhandler) {
   Return, DllCall("libhpdf\HPDF_SetErrorHandler", "UInt", hDoc, "UInt", errorhandler, "Cdecl int")
}


HPDF_GetError(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetError", "UInt", hDoc, "Cdecl int")
}


HPDF_ResetError(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_ResetError", "UInt", hDoc, "Cdecl int")
}


; unused

HPDF_SaveToStream(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_SaveToStream", "UInt", hDoc, "Cdecl int")
}


HPDF_GetStreamSize(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetStreamSize", "UInt", hDoc, "Cdecl int")
}


HPDF_ReadFromStream(ByRef hDoc, ByRef buffer, ByRef buffer_size) {
   Return, DllCall("libhpdf\HPDF_ReadFromStream", "UInt", hDoc, "UInt", buffer, "UInt", buffer_size,  "Cdecl int")
}


HPDF_ResetStream(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_ResetStream", "UInt", hDoc, "Cdecl int")
}

HPDF_HasDoc(ByRef hDoc)
HPDF_SetErrorHandler(ByRef hDoc, user_error_fn)
HPDF_GetError(ByRef hDoc)
HPDF_ResetError(ByRef hDoc)


;----------------------------------------------------
; libhpdf_documentHandling_encodings.ahk
;----------------------------------------------------
HPDF_GetEncoder(ByRef hDoc, encoding_name) {
   Return, DllCall("libhpdf\HPDF_GetEncoder", "UInt", hDoc, "Str", encoding_name, "Cdecl int")
}

HPDF_GetCurrentEncoder(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetCurrentEncoder", "UInt", hDoc, "Cdecl int")
}

HPDF_SetCurrentEncoder(ByRef hDoc, encoding_name) {
   Return, DllCall("libhpdf\HPDF_SetCurrentEncoder", "UInt", hDoc, "Str", encoding_name, "Cdecl int")
}

HPDF_UseJPEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseJPEncodings", "UInt", hDoc, "Cdecl int")
}

HPDF_UseKREncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseKREncodings", "UInt", hDoc, "Cdecl int")
}

HPDF_UseCNSEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNSEncodings", "UInt", hDoc, "Cdecl int")
}

HPDF_UseCNTEncodings(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNTEncodings", "UInt", hDoc, "Cdecl int")
}

;----------------------------------------------------
; libhpdf_documentHandling_font.ahk
;----------------------------------------------------
HPDF_AddPageLabel(ByRef hDoc, page_num, style, first_page, prefix) {
   HPDF_PAGE_NUM_STYLE_DECIMAL = 0
   HPDF_PAGE_NUM_STYLE_UPPER_ROMAN = 1
   HPDF_PAGE_NUM_STYLE_LOWER_ROMAN = 2
   HPDF_PAGE_NUM_STYLE_UPPER_LETTERS = 3
   HPDF_PAGE_NUM_STYLE_LOWER_LETTERS = 4
   HPDF_PAGE_NUM_STYLE_EOF = 5

   thisStyle := HPDF_PAGE_NUM_STYLE_%style%

   Return, DllCall("libhpdf\HPDF_AddPageLabel", "UInt", hDoc, "Int", page_num, "Int", thisStyle, "Int", first_page, "Str", prefix, "Cdecl int")
}

HPDF_GetFont(ByRef hDoc, font_name, encoding_name) {

   if encoding_name = 0
      Return, DllCall("libhpdf\HPDF_GetFont", "UInt", hDoc, "Str", font_name, "Int", 0)
   else
      Return, DllCall("libhpdf\HPDF_GetFont", "UInt", hDoc, "Str", font_name, "Str", encoding_name, "Cdecl int")
}

HPDF_GetFont2(ByRef hDoc, ByRef font_name, encoding_name) {

   if encoding_name = 0
      Return, DllCall("libhpdf\HPDF_GetFont", "UInt", hDoc, "UInt", font_name, "Int", 0)
   else
      Return, DllCall("libhpdf\HPDF_GetFont", "UInt", hDoc, "UInt", font_name, "Str", encoding_name, "Cdecl int")
}


HPDF_LoadType1FontFromFile(ByRef hDoc, afmfilename, pfmfilename) {
   Return, DllCall("libhpdf\HPDF_LoadType1FontFromFile", "UInt", hDoc, "Str", afmfilename, "Str", pfmfilename, "Cdecl int")
}

HPDF_LoadTTFontFromFile(ByRef hDoc, file_name, embedding) {
   Return, DllCall("libhpdf\HPDF_LoadTTFontFromFile", "UInt", hDoc, "Str", file_name, "Int", embedding, "Cdecl int")
}

HPDF_LoadTTFontFromFile2(ByRef hDoc, file_name, index, embedding) {
   Return, DllCall("libhpdf\HPDF_LoadTTFontFromFile2", "UInt", hDoc, "Str", file_name, "Int", index, "Int", embedding, "Cdecl int")
}

HPDF_UseJPFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseJPFonts", "UInt", hDoc, "Cdecl int")
}

HPDF_UseKRFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseKRFonts", "UInt", hDoc, "Cdecl int")
}

HPDF_UseCNSFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNSFonts", "UInt", hDoc, "Cdecl int")
}

HPDF_UseCNTFonts(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_UseCNTFonts", "UInt", hDoc, "Cdecl int")
}

;----------------------------------------------------
; libhpdf_documentHandling_other.ahk
;----------------------------------------------------
HPDF_CreateOutline(ByRef hDoc, ByRef parent, title, ByRef encoder) {
   if parent = 0
   {
      if encoder = 0
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UInt", hDoc, "Int", 0, "Str", title, "Int", 0, "Cdecl int")
      else
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UInt", hDoc, "Int", 0, "Str", title, "UInt", encoder, "Cdecl int")
   }
   else
   {
      if encoder = 0
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UInt", hDoc, "UInt", parent, "Str", title, "Int", 0, "Cdecl int")
      else
         Return, DllCall("libhpdf\HPDF_CreateOutline", "UInt", hDoc, "UInt", parent, "Str", title, "UInt", encoder, "Cdecl int")
   }
}

HPDF_LoadPngImageFromFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_LoadPngImageFromFile", "UInt", hDoc, "str", filename, "Cdecl int")
}

HPDF_LoadPngImageFromFile2(ByRef hDoc, filename  {
   Return, DllCall("libhpdf\HPDF_LoadPngImageFromFile2", "UInt", hDoc, "str", filename, "Cdecl int")
}

HPDF_LoadRawImageFromFile(ByRef hDoc, filename, width, height, color_space) {
   HPDF_CS_DEVICE_GRAY := 0
   HPDF_CS_DEVICE_RGB := 1
   HPDF_CS_DEVICE_CMYK := 2

   thisColor_space := HPDF_CS_DEVICE_%color_space%

   Return, DllCall("libhpdf\HPDF_LoadRawImageFromFile", "UInt", hDoc, "str", filename, "UInt", width, "UInt", height, "Int", thisColor_space, "Cdecl int")
}

HPDF_LoadRawImageFromMem(ByRef hDoc, buf, width, height, color_space, bits_per_component) {
   HPDF_CS_DEVICE_GRAY = 0
   HPDF_CS_DEVICE_RGB = 1
   HPDF_CS_DEVICE_CMYK = 2

   thisColor_space := HPDF_CS_DEVICE_%color_space%

   Return, DllCall("libhpdf\HPDF_LoadRawImageFromMem", "UInt", hDoc, "UInt", buf, "Int", width, "Int", height, "Int", color_space, "Int", bits_per_component, "Cdecl int")
}

HPDF_LoadJpegImageFromFile(ByRef hDoc, filename) {
   Return, DllCall("libhpdf\HPDF_LoadJpegImageFromFile", "UInt", hDoc, "str", filename, "Cdecl int")
}

HPDF_SetInfoAttr(ByRef hDoc, type, value) {
   HPDF_INFO_AUTHOR = 2
   HPDF_INFO_CREATOR = 3
   HPDF_INFO_PRODUCER = 4
   HPDF_INFO_TITLE = 5
   HPDF_INFO_SUBJECT = 6
   HPDF_INFO_KEYWORDS = 7
   HPDF_INFO_EOF = 8

   thisType := HPDF_INFO_%type%

   Return, DllCall("libhpdf\HPDF_SetInfoAttr", "UInt", hDoc, "Int", thisType, "Str", value "Cdecl int")
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

   Return, DllCall("libhpdf\HPDF_GetInfoAttr", "UInt", hDoc, "Int", thisType, "Cdecl int")
}


HPDF_SetPassword(ByRef hDoc, owner_passwd, user_passwd) {
   Return, DllCall("libhpdf\HPDF_SetPassword", "UInt", hDoc, "str", owner_passwd, "str", user_passwd, "Cdecl int")
}

HPDF_SetPermission(ByRef hDoc, permission) {
   StringReplace, permission, permission, READ, 0
   StringReplace, permission, permission, PRINT, 4
   StringReplace, permission, permission, EDIT_ALL, 8
   StringReplace, permission, permission, COPY, 16
   StringReplace, permission, permission, EDIT, 32

   Return, DllCall("libhpdf\HPDF_SetPermission", "UInt", hDoc, "Int", permission, "Cdecl int")
}

HPDF_SetEncryptionMode(ByRef hDoc, mode, key_len) {
   HPDF_ENCRYPT_R2 = 2
   HPDF_ENCRYPT_R3 = 3

   thisMode := HPDF_ENCRYPT_%mode%

   Return, DllCall("libhpdf\HPDF_SetEncryptionMode", "UInt", hDoc, "Int", thisMode, "Int", key_len, "Cdecl int")
}

HPDF_SetCompressionMode(ByRef hDoc, mode) {
   HPDF_COMP_NONE = 0
   HPDF_COMP_TEXT = 1
   HPDF_COMP_IMAGE = 2
   HPDF_COMP_METADATA = 4
   HPDF_COMP_ALL = 15

   thisMode := HPDF_COMP_%mode%

   Return, DllCall("libhpdf\HPDF_SetCompressionMode", "UInt", hDoc, "Int", thisMode)
}


;----------------------------------------------------
; libhpdf_documentHandling_pages.ahk
;----------------------------------------------------
HPDF_SetPagesConfiguration(ByRef hDoc, page_per_pages) {
   Return, DllCall("libhpdf\HPDF_SetPagesConfiguration", "UInt", hDoc, "Int", page_per_pages, "Cdecl int")
}

HPDF_SetPageLayout(ByRef hDoc, layout) {
   Return, DllCall("libhpdf\HPDF_SetPageLayout", "UInt", hDoc, "Int", layout, "Cdecl int")
}

HPDF_GetPageLayout(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetPageLayout", "UInt", hDoc, "Cdecl int")
}

HPDF_SetPageMode(ByRef hDoc, mode) {
   HPDF_PAGE_MODE_USE_NONE := 0
   HPDF_PAGE_MODE_USE_OUTLINE := 1
   HPDF_PAGE_MODE_USE_THUMBS := 2
   HPDF_PAGE_MODE_FULL_SCREEN := 3

   thisMode := HPDF_PAGE_MODE_%mode%

   Return, DllCall("libhpdf\HPDF_SetPageMode", "UInt", hDoc, "Int", thisMode, "Cdecl int")
}

HPDF_GetPageMode(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetPageMode", "UInt", hDoc, "Cdecl int")
}

HPDF_SetOpenAction(ByRef hDoc, ByRef open_action) {
   Return, DllCall("libhpdf\HPDF_SetOpenAction", "UInt", hDoc, "UInt", open_action, "Cdecl int")
}

HPDF_GetCurrentPage(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_GetCurrentPage", "UInt", hDoc, "Cdecl int")
}

HPDF_AddPage(ByRef hDoc) {
   Return, DllCall("libhpdf\HPDF_AddPage", "UInt", hDoc, "Cdecl int")
}


HPDF_InsertPage(ByRef hDoc, ByRef target) {
   Return, DllCall("libhpdf\HPDF_InsertPage", "UInt", hDoc, "UInt", target, "Cdecl int")
}


;----------------------------------------------------
; libhpdf_graphics.ahk
;----------------------------------------------------
HPDF_Page_Arc(ByRef hPage, x, y, radius, ang1, ang2) {
   Return, DllCall("libhpdf\HPDF_Page_Arc", "UInt", hPage, "Float", x, "Float", y, "Float", radius, "Float", ang1, "Float", ang2, "Cdecl int")
}

HPDF_Page_BeginText(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_BeginText", "UInt", hPage, "Cdecl int")
}

HPDF_Page_Circle(ByRef hPage, x, y, radius) {
   Return, DllCall("libhpdf\HPDF_Page_Circle", "UInt", hPage, "Float", x, "Float", y, "Float", radius, "Cdecl int")
}

HPDF_Page_ClosePath(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePath", "UInt", hPage, "Cdecl int")
}

HPDF_Page_ClosePathStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_ClosePathEofillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathEofillStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_ClosePathFillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_ClosePathFillStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_Concat(ByRef hPage, a, b, c, d, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_Concat", "UInt", hPage, "Float", a, "Float", b, "Float", c, "Float", d, "Float", x, "Float", y, "Cdecl int")
}

HPDF_Page_CurveTo(ByRef hPage, x1, y1, x2, y2, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo", "UInt", hPage, "Float", x1, "Float", y1, "Float", x2, "Float", y2, "Float", x3, "Float", y3, "Cdecl int")
}

HPDF_Page_CurveTo2(ByRef hPage, x2, y2, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo2", "UInt", hPage, "Float", x2, "Float", y2, "Float", x3, "Float", y3, "Cdecl int")
}

HPDF_Page_CurveTo3(ByRef hPage, x1, y1, x3, y3) {
   Return, DllCall("libhpdf\HPDF_Page_CurveTo3", "UInt", hPage, "Float", x1, "Float", y1, "Float", x3, "Float", y3, "Cdecl int")
}

HPDF_Page_DrawImage(ByRef hPage, ByRef hImage, x, y, width, height) {
   Return, DllCall("libhpdf\HPDF_Page_DrawImage", "UInt", hPage, "UInt", hImage, "Float", x, "Float", y, "Float", width, "Float", height, "Cdecl int")
}

HPDF_Page_Ellipse(ByRef hPage, x, y, x_radius, y_radius) {
   Return, DllCall("libhpdf\HPDF_Page_Ellipse", "UInt", hPage, "Float", x, "Float", y, "Float", x_radius, "Float", y_radius, "Cdecl int")
}

HPDF_Page_EndPath(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EndPath", "UInt", hPage, "Cdecl int")
}

HPDF_Page_EndText(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EndText", "UInt", hPage, "Cdecl int")
}

HPDF_Page_Eofill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Eofill", "UInt", hPage, "Cdecl int")
}

HPDF_Page_EofillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_EofillStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_ExecuteXObject(ByRef hPage, ByRef obj) {
   Return, DllCall("libhpdf\HPDF_Page_ExecuteXObject", "UInt", hPage, "UInt", obj, "Cdecl int")
}

HPDF_Page_Fill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Fill", "UInt", hPage, "Cdecl int")
}

HPDF_Page_FillStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_FillStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GRestore(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GRestore", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GSave(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GSave", "UInt", hPage, "Cdecl int")
}

HPDF_Page_LineTo(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_LineTo", "UInt", hPage, "Float", x, "Float", y)
}

HPDF_Page_MoveTextPos(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTextPos", "UInt", hPage, "Float", x, "Float", y)
}

HPDF_Page_MoveTextPos2(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTextPos2", "UInt", hPage, "Float", x, "Float", y)
}

HPDF_Page_MoveTo(ByRef hPage, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_MoveTo", "UInt", hPage, "Float", x, "Float", y, "Cdecl int")
}

HPDF_Page_MoveToNextLine(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_MoveToNextLine", "UInt", hPage, "Cdecl int")
}

HPDF_Page_Rectangle(ByRef hPage, x, y, width, height) {
   Return, DllCall("libhpdf\HPDF_Page_Rectangle", "UInt", hPage, "Float", x, "Float", y, "Float", width, "Float", height, "Cdecl int")
}

HPDF_Page_SetCharSpace(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetCharSpace", "UInt", hPage, "Float", value, "Cdecl int")
}

HPDF_Page_SetCMYKFill(ByRef hPage, c, m, y, k) {
   Return, DllCall("libhpdf\HPDF_Page_SetCMYKFill", "UInt", hPage, "Float", c, "Float", m, "Float", y, "Float", k, "Cdecl int")
}

HPDF_Page_SetCMYKStroke(ByRef hPage, c, m, y, k) {
   Return, DllCall("libhpdf\HPDF_Page_SetCMYKStroke", "UInt", hPage, "Float", c, "Float", m, "Float", y, "Float", k, "Cdecl int")
}

HPDF_Page_SetDash(ByRef hPage, ByRef dash_ptn, num_elem, phase) {
   Return, DllCall("libhpdf\HPDF_Page_SetDash", "UInt", hPage, "UInt", dash_ptn, "Int", num_elem, "Int", phase, "Cdecl int")
}

HPDF_Page_SetExtGState(ByRef hPage, ByRef ext_gstate) {
   Return, DllCall("libhpdf\HPDF_Page_SetExtGState", "UInt", hPage, "UInt", ext_gstate, "Cdecl int")
}

HPDF_Page_SetFontAndSize(ByRef hPage, ByRef font, size) {
   Return, DllCall("libhpdf\HPDF_Page_SetFontAndSize", "UInt", hPage, "UInt", font, "Float", size, "Cdecl int")
}

HPDF_Page_SetGrayFill(ByRef hPage, gray) {
   Return, DllCall("libhpdf\HPDF_Page_SetGrayFill", "UInt", hPage, "Float", gray, "Cdecl int")
}

HPDF_Page_SetGrayStroke(ByRef hPage, gray) {
   Return, DllCall("libhpdf\HPDF_Page_SetGrayStroke", "UInt", hPage, "Float", gray, "Cdecl int")
}

HPDF_Page_SetHorizontalScalling(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetHorizontalScalling", "UInt", hPage, "Float", value, "Cdecl int")
}

HPDF_Page_SetLineCap(ByRef hPage, line_cap) {
   HPDF_BUTT_END = 0
   HPDF_ROUND_END = 1
   HPDF_PROJECTING_SCUARE_END = 2
   HPDF_LINECAP_EOF = 3

   thisLine_cap := HPDF_%line_cap%

   Return, DllCall("libhpdf\HPDF_Page_SetLineCap", "UInt", hPage, "Int", thisLine_cap, "Cdecl int")
}

HPDF_Page_SetLineJoin(ByRef hPage, line_join) {
   HPDF_MITER_JOIN = 0
   HPDF_ROUND_JOIN = 1
   HPDF_BEVEL_JOIN = 2
   HPDF_LINEJOIN_EOF = 3

   thisLine_join := HPDF_%line_join%

   Return, DllCall("libhpdf\HPDF_Page_SetLineJoin", "UInt", hPage, "Int", thisLine_join, "Cdecl int")
}

HPDF_Page_SetLineWidth(ByRef hPage, line_width) {
   Return, DllCall("libhpdf\HPDF_Page_SetLineWidth", "UInt", hPage, "Float", line_width, "Cdecl int")
}

HPDF_Page_SetMiterLimit(ByRef hPage, miter_limit) {
   Return, DllCall("libhpdf\HPDF_Page_SetMiterLimit", "UInt", hPage, "Float", miter_limit, "Cdecl int")
}

HPDF_Page_SetRGBFill(ByRef hPage, r, g, b) {
   Return, DllCall("libhpdf\HPDF_Page_SetRGBFill", "UInt", hPage, "Float", r, "Float", g, "Float", b)
}

HPDF_Page_SetRGBStroke(ByRef hPage, r, g, b) {
   Return, DllCall("libhpdf\HPDF_Page_SetRGBStroke", "UInt", hPage, "Float", r, "Float", g, "Float", b, "Cdecl int")
}

HPDF_Page_SetTextLeading(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextLeading", "UInt", hPage, "Float", value, "Cdecl int")
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

   Return, DllCall("libhpdf\HPDF_Page_SetTextRenderingMode", "UInt", hPage, "Int", thisMode, "Cdecl int")
}

HPDF_Page_SetTextRise(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextRise", "UInt", hPage, "Float", value, "Cdecl int")
}

HPDF_Page_SetWordSpace(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetWordSpace", "UInt", hPage, "Float", value, "Cdecl int")
}

HPDF_Page_ShowText(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowText", "UInt", hPage, "Str", text, "Cdecl int")
}

HPDF_Page_ShowTextNextLine(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowTextNextLine", "UInt", hPage, "Str", text, "Cdecl int")
}

HPDF_Page_ShowTextNextLineEx(ByRef hPage, word_space, char_space, text) {
   Return, DllCall("libhpdf\HPDF_Page_ShowTextNextLineEx", "UInt", hPage, "Float", word_space, "Float", char_space, "Str", text, "Cdecl int")
}

HPDF_Page_Stroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Stroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_TextOut(ByRef hPage, xpos, ypos, text) {
   Return, DllCall("libhpdf\HPDF_Page_TextOut", "UInt", hPage, "Float", xpos, "Float", ypos, "Str", text, "Cdecl int")
}

HPDF_Page_TextRect(ByRef hPage, left, top, right, bottom, text, align, ByRef len) {
   HPDF_TALIGN_LEFT = 0
   HPDF_TALIGN_RIGHT = 1
   HPDF_TALIGN_CENTER = 2
   HPDF_TALIGN_JUSTIFY = 3

   thisAlignment := HPDF_TALIGN_%align%

   Return, DllCall("libhpdf\HPDF_Page_TextRect", "UInt", hPage, "Float", left, "Float", top, "Float", right, "Float", bottom, "Str", text, "Int", thisAlignment, "UIntP", len, "Cdecl int")
}


HPDF_Page_SetTextMatrix(ByRef hPage, a, b, c, d, x, y) {
   Return, DllCall("libhpdf\HPDF_Page_SetTextMatrix", "UInt", hPage, "Float", a, "Float", b, "Float", c, "Float", d, "Float", x, "Float", y, "Cdecl int")
}


;HPDF_Page_ExecuteXObject()
;HPDF_Page_Eoclip()

HPDF_Page_Clip(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_Clip", "UInt", hPage, "Cdecl int")
}



;----------------------------------------------------
; libhpdf_helpers.ahk
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
; libhpdf_image.ahk
;----------------------------------------------------
HPDF_Image_GetSize(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetSize", "UInt", image, "Cdecl int")
}

HPDF_Image_GetWidth(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetWidth", "UInt", image, "Cdecl int")
}

HPDF_Image_GetHeight(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetHeight", "UInt", image, "Cdecl int")
}

HPDF_Image_GetBitsPerComponent(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetBitsPerComponent", "UInt", image, "Cdecl int")
}

HPDF_Image_GetColorSpace(ByRef image) {
   Return, DllCall("libhpdf\HPDF_Image_GetColorSpace", "UInt", image, "Cdecl int")
}

HPDF_Image_SetColorMask(ByRef image, rmin, rmax, gmin, gmax, bmin, bmax) {
   Return, DllCall("libhpdf\HPDF_Image_SetColorMask", "UInt", image, "Int", rmin, "Int", rmax, "Int", gmin, "Int", gmax, "Int", bmin, "Int", bmax)
}

HPDF_Image_SetMaskImage(ByRef image, ByRef mask_image) {
   Return, DllCall("libhpdf\HPDF_Image_SetMaskImage", "UInt", image, "UInt", mask_image, "Cdecl int")
}



;----------------------------------------------------
; libhpdf_outline.ahk
;----------------------------------------------------
HPDF_Outline_SetOpened(ByRef outline, opened) {
   Return, DllCall("libhpdf\HPDF_Outline_SetOpened", "UInt", outline, "Int", opened)
}

HPDF_Outline_SetDestination(ByRef outline, ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Outline_SetDestination", "UInt", outline, "UInt", dst, "Cdecl int")
}

;----------------------------------------------------
; libhpdf_page.ahk
;----------------------------------------------------
HPDF_Page_SetWidth(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetWidth", "UInt", hPage, "Float", value, "Cdecl Int")
}

HPDF_Page_SetHeight(ByRef hPage, value) {
   Return, DllCall("libhpdf\HPDF_Page_SetHeight", "UInt", hPage, "Float", value, "Cdecl int")
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


   Return, DllCall("libhpdf\HPDF_Page_SetSize", "UInt", hPage, "UInt", thisSize, "UInt", thisDirection, "Cdecl int")
}

HPDF_Page_SetRotate(ByRef hPage, angle) {
   Return, DllCall("libhpdf\HPDF_Page_SetRotate", "UInt", hPage, "Int", angle, "Cdecl int")
}

HPDF_Page_GetWidth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetWidth", "UInt", hPage, "Cdecl Float")
}

HPDF_Page_GetHeight(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetHeight", "UInt", hPage, "Cdecl Float")
}

HPDF_Page_CreateDestination(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_CreateDestination", "UInt", hPage, "Cdecl int")
}

HPDF_Page_CreateTextAnnot(ByRef hPage, rect, text, encoder) {
   Return, DllCall("libhpdf\HPDF_Page_CreateTextAnnot", "UInt", hPage, "UInt", rect, "Str", text, "UInt", encoder, "Cdecl int")
}

HPDF_Page_CreateLinkAnnot(ByRef hPage, ByRef rect, ByRef dst) {
   Return, DllCall("libhpdf\HPDF_Page_CreateLinkAnnot", "UInt", hPage, "UInt", rect, "UInt", dst)
}

HPDF_Page_CreateURILinkAnnot(ByRef hPage, ByRef rect, uri) {
   Return, DllCall("libhpdf\HPDF_Page_CreateURILinkAnnot", "UInt", hPage, "UInt", rect, "Str", uri, "Cdecl int")
}

HPDF_Page_TextWidth(ByRef hPage, text) {
   Return, DllCall("libhpdf\HPDF_Page_TextWidth", "UInt", hPage, "Str", text, "Cdecl Float")
}

HPDF_Page_MeasureText(ByRef hPage, text, width, wordwrap, real_width) {
   if real_width = 0
      Return, DllCall("libhpdf\HPDF_Page_MeasureText", "UInt", hPage, "Str", text, "Float", width, "Int", wordwrap, "Int", 0, "Cdecl int")
   else
      Return, DllCall("libhpdf\HPDF_Page_MeasureText", "UInt", hPage, "Str", text, "Float", width, "Int", wordwrap, "Float", real_width, "Cdecl int")
}

HPDF_Page_GetGMode(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGMode", "UInt", hPage, "Cdecl Char")
}

HPDF_Page_GetCurrentPos(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentPos", "UInt", hPage, "Cdecl Uint")
}

HPDF_Page_GetCurrentTextPos(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentTextPos", "UInt", hPage, "Cdecl Uint")
}

HPDF_Page_GetCurrentFont(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentFont", "UInt", hPage)
}

HPDF_Page_GetCurrentFontSize(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCurrentFontSize", "UInt", hPage, "Cdecl Float")
}

HPDF_Page_GetTransMatrix(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTransMatrix", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetLineWidth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineWidth", "UInt", hPage, "Cdecl Float")
}

HPDF_Page_GetLineCap(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineCap", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetLineJoin(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetLineJoin", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetMiterLimit(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetMiterLimit", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetDash(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetDash", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetFlat(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetFlat", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetCharSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCharSpace", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetWordSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetWordSpace", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetHorizontalScalling(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetHorizontalScalling", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetTextLeading(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextLeading", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetTextRenderingMode(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextRenderingMode", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetTextRise(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextRise", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetRGBFill(ByRef hPage) {
   return, DllCall("libhpdf\HPDF_Page_GetRGBFill", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetRGBStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetRGBStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetCMYKFill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCMYKFill", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetCMYKStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetCMYKStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetGrayFill(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGrayFill", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetGrayStroke(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGrayStroke", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetStrokingColorSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetStrokingColorSpace", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetFillingColorSpace(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetFillingColorSpace", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetTextMatrix(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetTextMatrix", "UInt", hPage, "Cdecl int")
}

HPDF_Page_GetGStateDepth(ByRef hPage) {
   Return, DllCall("libhpdf\HPDF_Page_GetGStateDepth", "UInt", hPage, "Cdecl int")
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

   Return, DllCall("libhpdf\HPDF_Free", "UInt", hPage, "Int", thisType, "Float", disp_time, "Float", trans_time, "Cdecl int")
}

;----------------------------------------------------
; libhpdf_structures.ahk
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
   x := NumGet(&NumGet(point,0,"UInt")+0,0,"Float")
   y := NumGet(point,4,"UFloat")
}

