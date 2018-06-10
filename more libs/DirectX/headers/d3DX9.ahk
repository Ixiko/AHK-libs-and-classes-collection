#include <DirectX\Headers\d3DX9core.h>

global D3DX_FILTER_NONE :=             (1 << 0)
global D3DX_FILTER_POINT :=            (2 << 0)
global D3DX_FILTER_LINEAR :=           (3 << 0)
global D3DX_FILTER_TRIANGLE :=         (4 << 0)
global D3DX_FILTER_BOX  :=             (5 << 0)
global D3DX_FILTER_MIRROR_U :=         (1 << 16)
global D3DX_FILTER_MIRROR_V :=         (2 << 16)
global D3DX_FILTER_MIRROR_W :=         (4 << 16)
global D3DX_FILTER_MIRROR :=           (7 << 16)
global D3DX_FILTER_DITHER :=           (1 << 19)
global D3DX_FILTER_DITHER_DIFFUSION := (2 << 19)
global D3DX_FILTER_SRGB_IN :=          (1 << 21)
global D3DX_FILTER_SRGB_OUT :=         (2 << 21)
global D3DX_FILTER_SRGB  :=            (3 << 21)


d3DX9core.ID3DXFont:= {}
d3DX9core.ID3DXFont.name := "ID3DXFont"
d3DX9core.ID3DXFont.def :=
( 
"
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9 *ppDevice) PURE;
    STDMETHOD(GetDescA)(THIS_ D3DXFONT_DESCA *pDesc) PURE;
    STDMETHOD(GetDescW)(THIS_ D3DXFONT_DESCW *pDesc) PURE;
    STDMETHOD_(BOOL, GetTextMetricsA)(THIS_ TEXTMETRICA *pTextMetrics) PURE;
    STDMETHOD_(BOOL, GetTextMetricsW)(THIS_ TEXTMETRICW *pTextMetrics) PURE;
    STDMETHOD_(HDC, GetDC)(THIS) PURE;
    STDMETHOD(GetGlyphData)(THIS_ UINT Glyph, LPDIRECT3DTEXTURE9 *ppTexture, RECT *pBlackBox, POINT *pCellInc) PURE;
    STDMETHOD(PreloadCharacters)(THIS_ UINT First, UINT Last) PURE;
    STDMETHOD(PreloadGlyphs)(THIS_ UINT First, UINT Last) PURE;
    STDMETHOD(PreloadTextA)(THIS_ LPCSTR pString, INT Count) PURE;
    STDMETHOD(PreloadTextW)(THIS_ LPCWSTR pString, INT Count) PURE;
    STDMETHOD_(INT, DrawTextA)(THIS_ LPD3DXSPRITE pSprite, LPCSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;
    STDMETHOD_(INT, DrawTextW)(THIS_ LPD3DXSPRITE pSprite, LPCWSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;
    STDMETHOD(OnLostDevice)(THIS) PURE;
    STDMETHOD(OnResetDevice)(THIS) PURE;
"
)

global D3DX9Mesh := {}

D3DX9Mesh.ID3DXBuffer := {}
D3DX9Mesh.ID3DXBuffer.name := "ID3DXBuffer"
D3DX9Mesh.ID3DXBuffer.def :=
( 
"
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;
    STDMETHOD(GetBufferPointer)(THIS) PURE;
    STDMETHOD(GetBufferSize)(THIS) PURE;
"    
)