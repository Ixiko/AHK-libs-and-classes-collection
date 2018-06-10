#pragma once
#define IMPORT extern "C" __declspec(dllimport)

IMPORT int TextCreate(const char *Font, int FontSize, bool bBold, bool bItalic, int x, int y, unsigned int color, const char *text, bool bShadow, bool bShow);
IMPORT int TextCreateUnicode(const wchar_t *Font, int FontSize, bool bBold, bool bItalic, int x, int y, unsigned int color, const wchar_t *text, bool bShadow, bool bShow);
IMPORT int TextDestroy(int ID);
IMPORT int TextSetShadow(int id, bool b);
IMPORT int TextSetShown(int id, bool b);
IMPORT int TextSetColor(int id, unsigned int color);
IMPORT int TextSetPos(int id, int x, int y);
IMPORT int TextSetString(int id, const char *str);
IMPORT int TextSetStringUnicode(int id, const wchar_t *str);
IMPORT int TextUpdate(int id, const char *Font, int FontSize, bool bBold, bool bItalic);
IMPORT int TextUpdateUnicode(int id, const wchar_t *Font, int FontSize, bool bBold, bool bItalic);

IMPORT int BoxCreate(int x, int y, int w, int h, unsigned int dwColor, bool bShow);
IMPORT int BoxDestroy(int id);
IMPORT int BoxSetShown(int id, bool bShown);
IMPORT int BoxSetBorder(int id, int height, bool bShown);
IMPORT int BoxSetBorderColor(int id, unsigned int dwColor);
IMPORT int BoxSetColor(int id, unsigned int dwColor);
IMPORT int BoxSetHeight(int id, int height);
IMPORT int BoxSetPos(int id, int x, int y);
IMPORT int BoxSetWidth(int id, int width);

IMPORT int LineCreate(int x1, int y1, int x2, int y2, int width, unsigned int color, bool bShow);
IMPORT int LineDestroy(int id);
IMPORT int LineSetShown(int id, bool bShown);
IMPORT int LineSetColor(int id, unsigned int color);
IMPORT int LineSetWidth(int id, int width);
IMPORT int LineSetPos(int id, int x1, int y1, int x2, int y2);

IMPORT int ImageCreate(const char *path, int x, int y, int rotation, int align, bool bShow);
IMPORT int ImageDestroy(int id);
IMPORT int ImageSetShown(int id, bool bShown);
IMPORT int ImageSetAlign(int id, int align);
IMPORT int ImageSetPos(int id, int x, int y);
IMPORT int ImageSetRotation(int id, int rotation);

IMPORT int DestroyAllVisual();
IMPORT int ShowAllVisual();
IMPORT int HideAllVisual();

IMPORT int GetFrameRate();
IMPORT int GetScreenSpecs(int& width, int& height);

IMPORT int SetCalculationRatio(int width, int height);

IMPORT int SetOverlayPriority(int id, int priority);

IMPORT int  Init();
IMPORT void SetParam(const char *_szParamName, const char *_szParamValue);
