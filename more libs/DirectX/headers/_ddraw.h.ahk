#include <DirectX\headers\ddraw.h>
#include <DirectX\headers\d3d.h>
#include <DirectX\headers\d3dtypes.h>

ddraw.result[2147942487 . ""] := "DDERR_INVALIDPARAMS"
ddraw.result[0 . ""] := "DDERR_OK"
ddraw.result[2147500034 . ""] := "E_NOINTERFACE"

global DDCOLORKEY := "DWORD dwColorSpaceLowValue, DWORD dwColorSpaceHighValue"
global DDPIXELFORMAT =
(
" 
    DWORD       dwSize;
    DWORD       dwFlags;
    DWORD       dwFourCC;
        {
        DWORD   dwRGBBitCount;
        DWORD   dwYUVBitCount;
        DWORD   dwZBufferBitDepth;
        DWORD   dwAlphaBitDepth;
        DWORD   dwLuminanceBitCount;
        DWORD   dwBumpBitCount;
        DWORD   dwPrivateFormatBitCount;
    };
        {
        DWORD   dwRBitMask;
        DWORD   dwYBitMask;
        DWORD   dwStencilBitDepth;
        DWORD   dwLuminanceBitMask;
        DWORD   dwBumpDuBitMask;
        DWORD   dwOperations;
    };
        {
        DWORD   dwGBitMask;
        DWORD   dwUBitMask;
        DWORD   dwZBitMask;
        DWORD   dwBumpDvBitMask;
        struct        {
            WORD    wFlipMSTypes;
            WORD    wBltMSTypes;
        };
    };
        {
        DWORD   dwBBitMask;
        DWORD   dwVBitMask;
        DWORD   dwStencilBitMask;
        DWORD   dwBumpLuminanceBitMask;
    };
        {
        DWORD   dwRGBAlphaBitMask;
        DWORD   dwYUVAlphaBitMask;
        DWORD   dwLuminanceAlphaBitMask;
        DWORD   dwRGBZBitMask;
        DWORD   dwYUVZBitMask;
    };
"
)

global DDSCAPS := "DWORD dwCaps;"    
global DDSURFACEDESC :=
(
"
    DWORD               dwSize;                 
    DWORD               dwFlags;                
    DWORD               dwHeight;               
    DWORD               dwWidth;               
    {
        LONG            lPitch;                 
        DWORD           dwLinearSize;          
    };
    DWORD               dwBackBufferCount;      
    {
        DWORD           dwMipMapCount;          
        DWORD           dwZBufferBitDepth;      
        DWORD           dwRefreshRate;          
    };
    DWORD               dwAlphaBitDepth;       
    DWORD               dwReserved;             
    LPVOID              lpSurface;             
    DDCOLORKEY          ddckCKDestOverlay;      
    DDCOLORKEY          ddckCKDestBlt;          
    DDCOLORKEY          ddckCKSrcOverlay;       
    DDCOLORKEY          ddckCKSrcBlt;          
    DDPIXELFORMAT       ddpfPixelFormat;
    DDSCAPS             ddsCaps; 
"    
)    

global DDSCAPS2 := "DWORD dwCaps, DWORD dwCaps2, DWORD dwCaps3, {DWORD dwCaps4, DWORD dwVolumeDepth}"
global DDSURFACEDESC2 :=
(
" 
    DWORD               dwSize;
    DWORD               dwFlags;
    DWORD               dwHeight;
    DWORD               dwWidth;
        {
        LONG            lPitch;
        DWORD           dwLinearSize;
    };
        {
        DWORD           dwBackBufferCount;
        DWORD           dwDepth;
    };
        {
        DWORD           dwMipMapCount;
        DWORD           dwRefreshRate;
        DWORD           dwSrcVBHandle;
    };
    DWORD               dwAlphaBitDepth;
    DWORD               dwReserved;
    LPDWORD              lpSurface;
        {
        DDCOLORKEY      ddckCKDestOverlay;
        DWORD           dwEmptyFaceColor;
    };
    DDCOLORKEY          ddckCKDestBlt;
    DDCOLORKEY          ddckCKSrcOverlay;
    DDCOLORKEY          ddckCKSrcBlt;
        {
        DDPIXELFORMAT   ddpfPixelFormat;
        DWORD           dwFVF;
    };
    DDSCAPS2            ddsCaps;
    DWORD               dwTextureStage;
"
)

DDSURFACEDESC := Struct(DDSURFACEDESC)
DDSCAPS := Struct(DDSCAPS)

DDSURFACEDESC2 := Struct(DDSURFACEDESC2)
DDPIXELFORMAT := Struct(DDPIXELFORMAT)

global DDBLTFX :=
(
"
  DWORD      dwSize;
  DWORD      dwDDFX;
  DWORD      dwROP;
  DWORD      dwDDROP;
  DWORD      dwRotationAngle;
  DWORD      dwZBufferOpCode;
  DWORD      dwZBufferLow;
  DWORD      dwZBufferHigh;
  DWORD      dwZBufferBaseDest;
  DWORD      dwZDestConstBitDepth;
  {
    DWORD               dwZDestConst;
    LPDWORD lpDDSZBufferDest;
  };
  DWORD      dwZSrcConstBitDepth;
  {
    DWORD               dwZSrcConst;
    LPDWORD  lpDDSZBufferSrc;
  }
  DWORD      dwAlphaEdgeBlendBitDepth;
  DWORD      dwAlphaEdgeBlend;
  DWORD      dwReserved;
  DWORD      dwAlphaDestConstBitDepth;
  {
    DWORD               dwAlphaDestConst;
    LPDWORD  lpDDSAlphaDest;
  };
  DWORD      dwAlphaSrcConstBitDepth;
  {
    DWORD               dwAlphaSrcConst;
    LPDWORD  lpDDSAlphaSrc;
  };
  {
    DWORD               dwFillColor;
    DWORD               dwFillDepth;
    DWORD               dwFillPixel;
    LPDWORD  lpDDSPattern;
  };
  DDCOLORKEY ddckDestColorkey;
  DDCOLORKEY ddckSrcColorkey;
"
)
DDBLTFX := Struct(DDBLTFX)
global RECT := Struct("LONG left; LONG top; LONG right; LONG bottom;")
global _RECT := Struct("LONG left; LONG top; LONG right; LONG bottom;")
global POINT := Struct("LONG x; LONG y;")

global DDBLTBATCH := Struct("ptr lprDest; ptr lpDDSSrc; ptr lprSrc; DWORD dwFlags; ptr lpDDBltFx;")

global DDRAWI_DIRECTDRAW_LCL :=
(
"
DWORD lpDDMore; 
ptr lpGbl; 
DWORD dwUnused0; 
DWORD dwLocalFlags; 
DWORD dwLocalRefCnt; 
DWORD dwProcessId; 
ptr pUnkOuter; 
DWORD dwObsolete1; 
ULONG_PTR hWnd; 
ULONG_PTR hDC; 
DWORD dwErrorMode; 
ptr lpPrimary; 
ptr lpCB; 
DWORD dwPreferredMode; 
HINSTANCE hD3DInstance; 
ptr pD3DIUnknown; 
ptr lpDDCB; 
DWORD hDDVxd; 
DWORD dwAppHackFlags; 
ptr hFocusWnd; 
DWORD dwHotTracking; 
DWORD dwIMEState; 
ptr hWndPopup; 
ptr hDD; 
ptr hGammaCalibrator; 
ptr lpGammaCalibrator; 
"
)
DDRAWI_DIRECTDRAW_LCL := struct(DDRAWI_DIRECTDRAW_LCL)
global DDRAWI_DIRECTDRAW_INT := struct("ptr lpVtbl; ptr lpLcl; ptr lpLink; DWORD dwIntRefCnt;")
 
