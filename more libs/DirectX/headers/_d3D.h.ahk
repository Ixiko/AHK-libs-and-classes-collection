#include <DirectX\headers\d3d.h>
#include <DirectX\headers\d3dtypes.h>

d3d.result[2147942487 . ""] := "D3DERR_INVALIDPARAMS"
d3d.result[0 . ""] := "D3DERR_OK"
d3d.result[2147500034 . ""] := "E_NOINTERFACE"

global d3d_D3DMATRIX := "float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24,"
. "float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44"

global D3DMATRIX := "float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24,"
. "float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44"

D3DMATRIX := Struct(D3DMATRIX)

global D3DVERTEXBUFFERDESC := Struct("DWORD dwSize; DWORD dwCaps; DWORD dwFVF; DWORD dwNumVertices;")
global D3DLVERTEX := Struct("float x, float y, float z, int color, int specular, float u, float v")

global D3DVIEWPORT := 
(
"
    DWORD       dwSize;
    DWORD       dwX;
    DWORD       dwY;            
    DWORD       dwWidth;
    DWORD       dwHeight;       
    Float    dvScaleX;       
    Float    dvScaleY;       
    Float    dvMaxX;         
    Float    dvMaxY;         
    Float    dvMinZ;
    Float    dvMaxZ; 
"
)
global D3DVIEWPORT2 := 
(
"
    DWORD       dwSize;
    DWORD       dwX;
    DWORD       dwY;
    DWORD       dwWidth;
    DWORD       dwHeight;
    Float    dvClipX;
    Float    dvClipY;
    Float    dvClipWidth;
    Float    dvClipHeight;
    Float    dvMinZ;
    Float    dvMaxZ; 
"
)
global D3DVIEWPORT7 := 
(
"
    DWORD       dwX;
    DWORD       dwY;
    DWORD       dwWidth;
    DWORD       dwHeight;
    float       dvMinZ;
    float       dvMaxZ;
"
)
global D3DVIEWPORT7 := Struct(D3DVIEWPORT7)
global D3DVIEWPORT2 := Struct(D3DVIEWPORT2)
global D3DVIEWPORT := Struct(D3DVIEWPORT)
global D3DEXECUTEBUFFERDESC := Struct("DWORD dwSize, DWORD dwFlags, DWORD dwCaps, DWORD dwBufferSize, ptr lpData")

global D3DSTATUS := 
(
"
    DWORD   dwFlags;   
    DWORD   dwStatus; 
    RECT drExtent;
"
)
global D3DEXECUTEDATA := 
(
"
    DWORD     dwSize;
    DWORD     dwVertexOffset;
    DWORD     dwVertexCount;
    DWORD     dwInstructionOffset;
    DWORD     dwInstructionLength;
    DWORD     dwHVertexOffset;
    D3DSTATUS dsStatus;
"
)
D3DEXECUTEDATA := struct(D3DEXECUTEDATA)


/* 'Custom' structtures
 */
 
global VERTEX_TRANSFORM_PARAMETERS :=
(
"
DWORD p_DrawPrimitive;
DWORD p_DrawPrimitiveVB;
DWORD p_DrawIndexedPrimitive;
DWORD p_GetVertexBufferDesc;
DWORD p_LockVertexBuffer;
DWORD p_UnLockVertexBuffer;
BOOL scale;
float scale_delta;
BOOL displace;
float displacement;
BOOL callback;
uint pCallback;
"
)
VERTEX_TRANSFORM_PARAMETERS := struct(VERTEX_TRANSFORM_PARAMETERS)