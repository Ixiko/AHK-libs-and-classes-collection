#include <DirectX\headers\dinput.h>

dinput.result["" . 0] := "DI_OK"
dinput.result[2147942487 . ""] := "DIERR_INVALIDPARAMS"

global DIDEVICEINSTANCE_DX3A := Struct("DWORD dwSize, GUID guidInstance, GUID guidProduct, DWORD dwDevType,"
                                       . "CHAR tszInstanceName[260], CHAR tszProductName[260]")
global DIJOYSTATE :=
(
"
	LONG lX;
    LONG lY;
    LONG lZ;
    LONG lRx;
    LONG lRy;
    LONG lRz;
    LONG rglSlider[2];
    DWORD rgdwPOV[4];
    BYTE rgbButtons[32];
"
)
DIJOYSTATE := Struct(DIJOYSTATE) 									   
global DIJOYSTATE60 :=	
(
"	
	LONG lX;
    LONG lY;
    LONG lZ;
    LONG lRx;
    LONG lRy;
    LONG lRz;
    Byte rgdwPOV[4];
    Byte rgbButtons[32];
"
)
DIJOYSTATE60 := Struct(DIJOYSTATE60)
global DIEffectInfo :=
(
"
    DWORD dwSize;
    GUID guid;
    DWORD dwEffType;
    DWORD dwStaticParams;
    DWORD dwDynamicParams;
    TCHAR tszName[MAX_PATH];
"
)
DIEffectInfo := struct(DIEffectInfo)
