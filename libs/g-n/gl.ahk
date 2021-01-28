; $Id: gl.h,v 1.3 2003/09/12 13:26:51 earnie Exp $
;
; Mesa 3-D graphics library
; Version:  4.0
;
; Copyright (C) 1999-2001  Brian Paul   All Rights Reserved.
;
; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
; BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
; AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
;
;
;************************************************************************
; 2002-Apr-22, José Fonseca:
;   Removed non Win32 system-specific stuff
;
; 2002-Apr-17, Marcus Geelnard:
;   For win32, OpenGL 1.2 & 1.3 definitions are not made in this file
;   anymore, since under Windows those are regarded as extensions, and
;   are better defined in glext.h (especially the function prototypes may
;   conflict with extension function pointers). A few "cosmetical"
;   changes were also made to this file.
;
; 2002-Apr-15, Marcus Geelnard:
;   Modified this file to better fit a wider range of compilers, removed
;   Mesa specific stuff, and removed extension definitions (this file now
;   relies on GL/glext.h). Hopefully this file should now function as a
;   generic OpenGL gl.h include file for most compilers and environments.
;   Changed GLAPIENTRY to APIENTRY (to be consistent with GL/glext.h).
;
; 2009-Apr-10, Bentschi:
;   Converted this file for use with AutoHotkey.
;************************************************************************

  GL_VERSION_1_1 := 1
  GL_VERSION_1_2 := 1
  GL_VERSION_1_3 := 1
  GL_ARB_imaging := 1

  ; ### Datatypes ### ;

  GLenum      = UInt
  GLboolean   = UChar
  GLbitfield  = UInt
  GLbyte      = Char         ; 1-byte signed 
  GLshort     = Short        ; 2-byte signed 
  GLint       = Int          ; 4-byte signed 
  GLubyte     = UChar        ; 1-byte unsigned 
  GLushort    = UShort       ; 2-byte unsigned 
  GLuint      = UInt         ; 4-byte unsigned 
  GLsizei     = Int          ; 4-byte signed 
  GLfloat     = Float        ; single precision float 
  GLclampf    = Float        ; single precision float in [0,1] 
  GLdouble    = Double       ; double precision float 
  GLclampd    = Double       ; double precision float in

  ; ### Constants ### ;

  ; --- Boolean values --- ;
  GL_FALSE                               := 0x0
  GL_TRUE                                := 0x1

  ; --- Data types --- ;
  GL_BYTE                                := 0x1400
  GL_UNSIGNED_BYTE                       := 0x1401
  GL_SHORT                               := 0x1402
  GL_UNSIGNED_SHORT                      := 0x1403
  GL_INT                                 := 0x1404
  GL_UNSIGNED_INT                        := 0x1405
  GL_FLOAT                               := 0x1406
  GL_DOUBLE                              := 0x140A
  GL_2_BYTES                             := 0x1407
  GL_3_BYTES                             := 0x1408
  GL_4_BYTES                             := 0x1409

  ; --- Primitives --- ;
  GL_POINTS                              := 0x0000
  GL_LINES                               := 0x0001
  GL_LINE_LOOP                           := 0x0002
  GL_LINE_STRIP                          := 0x0003
  GL_TRIANGLES                           := 0x0004
  GL_TRIANGLE_STRIP                      := 0x0005
  GL_TRIANGLE_FAN                        := 0x0006
  GL_QUADS                               := 0x0007
  GL_QUAD_STRIP                          := 0x0008
  GL_POLYGON                             := 0x0009

  ; --- Vertex Arrays --- ;
  GL_VERTEX_ARRAY                        := 0x8074
  GL_NORMAL_ARRAY                        := 0x8075
  GL_COLOR_ARRAY                         := 0x8076
  GL_INDEX_ARRAY                         := 0x8077
  GL_TEXTURE_COORD_ARRAY                 := 0x8078
  GL_EDGE_FLAG_ARRAY                     := 0x8079
  GL_VERTEX_ARRAY_SIZE                   := 0x807A
  GL_VERTEX_ARRAY_TYPE                   := 0x807B
  GL_VERTEX_ARRAY_STRIDE                 := 0x807C
  GL_NORMAL_ARRAY_TYPE                   := 0x807E
  GL_NORMAL_ARRAY_STRIDE                 := 0x807F
  GL_COLOR_ARRAY_SIZE                    := 0x8081
  GL_COLOR_ARRAY_TYPE                    := 0x8082
  GL_COLOR_ARRAY_STRIDE                  := 0x8083
  GL_INDEX_ARRAY_TYPE                    := 0x8085
  GL_INDEX_ARRAY_STRIDE                  := 0x8086
  GL_TEXTURE_COORD_ARRAY_SIZE            := 0x8088
  GL_TEXTURE_COORD_ARRAY_TYPE            := 0x8089
  GL_TEXTURE_COORD_ARRAY_STRIDE          := 0x808A
  GL_EDGE_FLAG_ARRAY_STRIDE              := 0x808C
  GL_VERTEX_ARRAY_POINTER                := 0x808E
  GL_NORMAL_ARRAY_POINTER                := 0x808F
  GL_COLOR_ARRAY_POINTER                 := 0x8090
  GL_INDEX_ARRAY_POINTER                 := 0x8091
  GL_TEXTURE_COORD_ARRAY_POINTER         := 0x8092
  GL_EDGE_FLAG_ARRAY_POINTER             := 0x8093
  GL_V2F                                 := 0x2A20
  GL_V3F                                 := 0x2A21
  GL_C4UB_V2F                            := 0x2A22
  GL_C4UB_V3F                            := 0x2A23
  GL_C3F_V3F                             := 0x2A24
  GL_N3F_V3F                             := 0x2A25
  GL_C4F_N3F_V3F                         := 0x2A26
  GL_T2F_V3F                             := 0x2A27
  GL_T4F_V4F                             := 0x2A28
  GL_T2F_C4UB_V3F                        := 0x2A29
  GL_T2F_C3F_V3F                         := 0x2A2A
  GL_T2F_N3F_V3F                         := 0x2A2B
  GL_T2F_C4F_N3F_V3F                     := 0x2A2C
  GL_T4F_C4F_N3F_V4F                     := 0x2A2D

  ; --- Matrix Mode --- ;
  GL_MATRIX_MODE                         := 0x0BA0
  GL_MODELVIEW                           := 0x1700
  GL_PROJECTION                          := 0x1701
  GL_TEXTURE                             := 0x1702

  ; --- Points --- ;
  GL_POINT_SMOOTH                        := 0x0B10
  GL_POINT_SIZE                          := 0x0B11
  GL_POINT_SIZE_GRANULARITY              := 0x0B13
  GL_POINT_SIZE_RANGE                    := 0x0B12

  ; --- Lines --- ;
  GL_LINE_SMOOTH                         := 0x0B20
  GL_LINE_STIPPLE                        := 0x0B24
  GL_LINE_STIPPLE_PATTERN                := 0x0B25
  GL_LINE_STIPPLE_REPEAT                 := 0x0B26
  GL_LINE_WIDTH                          := 0x0B21
  GL_LINE_WIDTH_GRANULARITY              := 0x0B23
  GL_LINE_WIDTH_RANGE                    := 0x0B22

  ; --- Polygons --- ;
  GL_POINT                               := 0x1B00
  GL_LINE                                := 0x1B01
  GL_FILL                                := 0x1B02
  GL_CW                                  := 0x0900
  GL_CCW                                 := 0x0901
  GL_FRONT                               := 0x0404
  GL_BACK                                := 0x0405
  GL_POLYGON_MODE                        := 0x0B40
  GL_POLYGON_SMOOTH                      := 0x0B41
  GL_POLYGON_STIPPLE                     := 0x0B42
  GL_EDGE_FLAG                           := 0x0B43
  GL_CULL_FACE                           := 0x0B44
  GL_CULL_FACE_MODE                      := 0x0B45
  GL_FRONT_FACE                          := 0x0B46
  GL_POLYGON_OFFSET_FACTOR               := 0x8038
  GL_POLYGON_OFFSET_UNITS                := 0x2A00
  GL_POLYGON_OFFSET_POINT                := 0x2A01
  GL_POLYGON_OFFSET_LINE                 := 0x2A02
  GL_POLYGON_OFFSET_FILL                 := 0x8037

  ; --- Display Lists --- ;
  GL_COMPILE                             := 0x1300
  GL_COMPILE_AND_EXECUTE                 := 0x1301
  GL_LIST_BASE                           := 0x0B32
  GL_LIST_INDEX                          := 0x0B33
  GL_LIST_MODE                           := 0x0B30

  ; --- Depth buffer --- ;
  GL_NEVER                               := 0x0200
  GL_LESS                                := 0x0201
  GL_EQUAL                               := 0x0202
  GL_LEQUAL                              := 0x0203
  GL_GREATER                             := 0x0204
  GL_NOTEQUAL                            := 0x0205
  GL_GEQUAL                              := 0x0206
  GL_ALWAYS                              := 0x0207
  GL_DEPTH_TEST                          := 0x0B71
  GL_DEPTH_BITS                          := 0x0D56
  GL_DEPTH_CLEAR_VALUE                   := 0x0B73
  GL_DEPTH_FUNC                          := 0x0B74
  GL_DEPTH_RANGE                         := 0x0B70
  GL_DEPTH_WRITEMASK                     := 0x0B72
  GL_DEPTH_COMPONENT                     := 0x1902

  ; --- Lighting --- ;
  GL_LIGHTING                            := 0x0B50
  GL_LIGHT0                              := 0x4000
  GL_LIGHT1                              := 0x4001
  GL_LIGHT2                              := 0x4002
  GL_LIGHT3                              := 0x4003
  GL_LIGHT4                              := 0x4004
  GL_LIGHT5                              := 0x4005
  GL_LIGHT6                              := 0x4006
  GL_LIGHT7                              := 0x4007
  GL_SPOT_EXPONENT                       := 0x1205
  GL_SPOT_CUTOFF                         := 0x1206
  GL_CONSTANT_ATTENUATION                := 0x1207
  GL_LINEAR_ATTENUATION                  := 0x1208
  GL_QUADRATIC_ATTENUATION               := 0x1209
  GL_AMBIENT                             := 0x1200
  GL_DIFFUSE                             := 0x1201
  GL_SPECULAR                            := 0x1202
  GL_SHININESS                           := 0x1601
  GL_EMISSION                            := 0x1600
  GL_POSITION                            := 0x1203
  GL_SPOT_DIRECTION                      := 0x1204
  GL_AMBIENT_AND_DIFFUSE                 := 0x1602
  GL_COLOR_INDEXES                       := 0x1603
  GL_LIGHT_MODEL_TWO_SIDE                := 0x0B52
  GL_LIGHT_MODEL_LOCAL_VIEWER            := 0x0B51
  GL_LIGHT_MODEL_AMBIENT                 := 0x0B53
  GL_FRONT_AND_BACK                      := 0x0408
  GL_SHADE_MODEL                         := 0x0B54
  GL_FLAT                                := 0x1D00
  GL_SMOOTH                              := 0x1D01
  GL_COLOR_MATERIAL                      := 0x0B57
  GL_COLOR_MATERIAL_FACE                 := 0x0B55
  GL_COLOR_MATERIAL_PARAMETER            := 0x0B56
  GL_NORMALIZE                           := 0x0BA1

  ; --- User clipping planes --- ;
  GL_CLIP_PLANE0                         := 0x3000
  GL_CLIP_PLANE1                         := 0x3001
  GL_CLIP_PLANE2                         := 0x3002
  GL_CLIP_PLANE3                         := 0x3003
  GL_CLIP_PLANE4                         := 0x3004
  GL_CLIP_PLANE5                         := 0x3005

  ; --- Accumulation buffer --- ;
  GL_ACCUM_RED_BITS                      := 0x0D58
  GL_ACCUM_GREEN_BITS                    := 0x0D59
  GL_ACCUM_BLUE_BITS                     := 0x0D5A
  GL_ACCUM_ALPHA_BITS                    := 0x0D5B
  GL_ACCUM_CLEAR_VALUE                   := 0x0B80
  GL_ACCUM                               := 0x0100
  GL_ADD                                 := 0x0104
  GL_LOAD                                := 0x0101
  GL_MULT                                := 0x0103
  GL_RETURN                              := 0x0102

  ; --- Alpha testing --- ;
  GL_ALPHA_TEST                          := 0x0BC0
  GL_ALPHA_TEST_REF                      := 0x0BC2
  GL_ALPHA_TEST_FUNC                     := 0x0BC1

  ; --- Blending --- ;
  GL_BLEND                               := 0x0BE2
  GL_BLEND_SRC                           := 0x0BE1
  GL_BLEND_DST                           := 0x0BE0
  GL_ZERO                                := 0x0
  GL_ONE                                 := 0x1
  GL_SRC_COLOR                           := 0x0300
  GL_ONE_MINUS_SRC_COLOR                 := 0x0301
  GL_SRC_ALPHA                           := 0x0302
  GL_ONE_MINUS_SRC_ALPHA                 := 0x0303
  GL_DST_ALPHA                           := 0x0304
  GL_ONE_MINUS_DST_ALPHA                 := 0x0305
  GL_DST_COLOR                           := 0x0306
  GL_ONE_MINUS_DST_COLOR                 := 0x0307
  GL_SRC_ALPHA_SATURATE                  := 0x0308
  GL_CONSTANT_COLOR                      := 0x8001
  GL_ONE_MINUS_CONSTANT_COLOR            := 0x8002
  GL_CONSTANT_ALPHA                      := 0x8003
  GL_ONE_MINUS_CONSTANT_ALPHA            := 0x8004

  ; --- Render Mode --- ;
  GL_FEEDBACK                            := 0x1C01
  GL_RENDER                              := 0x1C00
  GL_SELECT                              := 0x1C02

  ; --- Feedback --- ;
  GL_2D                                  := 0x0600
  GL_3D                                  := 0x0601
  GL_3D_COLOR                            := 0x0602
  GL_3D_COLOR_TEXTURE                    := 0x0603
  GL_4D_COLOR_TEXTURE                    := 0x0604
  GL_POINT_TOKEN                         := 0x0701
  GL_LINE_TOKEN                          := 0x0702
  GL_LINE_RESET_TOKEN                    := 0x0707
  GL_POLYGON_TOKEN                       := 0x0703
  GL_BITMAP_TOKEN                        := 0x0704
  GL_DRAW_PIXEL_TOKEN                    := 0x0705
  GL_COPY_PIXEL_TOKEN                    := 0x0706
  GL_PASS_THROUGH_TOKEN                  := 0x0700
  GL_FEEDBACK_BUFFER_POINTER             := 0x0DF0
  GL_FEEDBACK_BUFFER_SIZE                := 0x0DF1
  GL_FEEDBACK_BUFFER_TYPE                := 0x0DF2

  ; --- Selection --- ;
  GL_SELECTION_BUFFER_POINTER            := 0x0DF3
  GL_SELECTION_BUFFER_SIZE               := 0x0DF4

  ; --- Fog --- ;
  GL_FOG                                 := 0x0B60
  GL_FOG_MODE                            := 0x0B65
  GL_FOG_DENSITY                         := 0x0B62
  GL_FOG_COLOR                           := 0x0B66
  GL_FOG_INDEX                           := 0x0B61
  GL_FOG_START                           := 0x0B63
  GL_FOG_END                             := 0x0B64
  GL_LINEAR                              := 0x2601
  GL_EXP                                 := 0x0800
  GL_EXP2                                := 0x0801

  ; --- Logic Ops --- ;
  GL_LOGIC_OP                            := 0x0BF1
  GL_INDEX_LOGIC_OP                      := 0x0BF1
  GL_COLOR_LOGIC_OP                      := 0x0BF2
  GL_LOGIC_OP_MODE                       := 0x0BF0
  GL_CLEAR                               := 0x1500
  GL_SET                                 := 0x150F
  GL_COPY                                := 0x1503
  GL_COPY_INVERTED                       := 0x150C
  GL_NOOP                                := 0x1505
  GL_INVERT                              := 0x150A
  GL_AND                                 := 0x1501
  GL_NAND                                := 0x150E
  GL_OR                                  := 0x1507
  GL_NOR                                 := 0x1508
  GL_XOR                                 := 0x1506
  GL_EQUIV                               := 0x1509
  GL_AND_REVERSE                         := 0x1502
  GL_AND_INVERTED                        := 0x1504
  GL_OR_REVERSE                          := 0x150B
  GL_OR_INVERTED                         := 0x150D

  ; --- Stencil --- ;
  GL_STENCIL_TEST                        := 0x0B90
  GL_STENCIL_WRITEMASK                   := 0x0B98
  GL_STENCIL_BITS                        := 0x0D57
  GL_STENCIL_FUNC                        := 0x0B92
  GL_STENCIL_VALUE_MASK                  := 0x0B93
  GL_STENCIL_REF                         := 0x0B97
  GL_STENCIL_FAIL                        := 0x0B94
  GL_STENCIL_PASS_DEPTH_PASS             := 0x0B96
  GL_STENCIL_PASS_DEPTH_FAIL             := 0x0B95
  GL_STENCIL_CLEAR_VALUE                 := 0x0B91
  GL_STENCIL_INDEX                       := 0x1901
  GL_KEEP                                := 0x1E00
  GL_REPLACE                             := 0x1E01
  GL_INCR                                := 0x1E02
  GL_DECR                                := 0x1E03

  ; --- Buffers, Pixel Drawing/Reading --- ;
  GL_NONE                                := 0x0
  GL_LEFT                                := 0x0406
  GL_RIGHT                               := 0x0407
; GL_FRONT                               := 0x0404
; GL_BACK                                := 0x0405
; GL_FRONT_AND_BACK                      := 0x0408
  GL_FRONT_LEFT                          := 0x0400
  GL_FRONT_RIGHT                         := 0x0401
  GL_BACK_LEFT                           := 0x0402
  GL_BACK_RIGHT                          := 0x0403
  GL_AUX0                                := 0x0409
  GL_AUX1                                := 0x040A
  GL_AUX2                                := 0x040B
  GL_AUX3                                := 0x040C
  GL_COLOR_INDEX                         := 0x1900
  GL_RED                                 := 0x1903
  GL_GREEN                               := 0x1904
  GL_BLUE                                := 0x1905
  GL_ALPHA                               := 0x1906
  GL_LUMINANCE                           := 0x1909
  GL_LUMINANCE_ALPHA                     := 0x190A
  GL_ALPHA_BITS                          := 0x0D55
  GL_RED_BITS                            := 0x0D52
  GL_GREEN_BITS                          := 0x0D53
  GL_BLUE_BITS                           := 0x0D54
  GL_INDEX_BITS                          := 0x0D51
  GL_SUBPIXEL_BITS                       := 0x0D50
  GL_AUX_BUFFERS                         := 0x0C00
  GL_READ_BUFFER                         := 0x0C02
  GL_DRAW_BUFFER                         := 0x0C01
  GL_DOUBLEBUFFER                        := 0x0C32
  GL_STEREO                              := 0x0C33
  GL_BITMAP                              := 0x1A00
  GL_COLOR                               := 0x1800
  GL_DEPTH                               := 0x1801
  GL_STENCIL                             := 0x1802
  GL_DITHER                              := 0x0BD0
  GL_RGB                                 := 0x1907
  GL_RGBA                                := 0x1908

  ; --- Implementation limits --- ;
  GL_MAX_LIST_NESTING                    := 0x0B31
  GL_MAX_ATTRIB_STACK_DEPTH              := 0x0D35
  GL_MAX_MODELVIEW_STACK_DEPTH           := 0x0D36
  GL_MAX_NAME_STACK_DEPTH                := 0x0D37
  GL_MAX_PROJECTION_STACK_DEPTH          := 0x0D38
  GL_MAX_TEXTURE_STACK_DEPTH             := 0x0D39
  GL_MAX_EVAL_ORDER                      := 0x0D30
  GL_MAX_LIGHTS                          := 0x0D31
  GL_MAX_CLIP_PLANES                     := 0x0D32
  GL_MAX_TEXTURE_SIZE                    := 0x0D33
  GL_MAX_PIXEL_MAP_TABLE                 := 0x0D34
  GL_MAX_VIEWPORT_DIMS                   := 0x0D3A
  GL_MAX_CLIENT_ATTRIB_STACK_DEPTH       := 0x0D3B

  ; --- Gets --- ;
  GL_ATTRIB_STACK_DEPTH                  := 0x0BB0
  GL_CLIENT_ATTRIB_STACK_DEPTH           := 0x0BB1
  GL_COLOR_CLEAR_VALUE                   := 0x0C22
  GL_COLOR_WRITEMASK                     := 0x0C23
  GL_CURRENT_INDEX                       := 0x0B01
  GL_CURRENT_COLOR                       := 0x0B00
  GL_CURRENT_NORMAL                      := 0x0B02
  GL_CURRENT_RASTER_COLOR                := 0x0B04
  GL_CURRENT_RASTER_DISTANCE             := 0x0B09
  GL_CURRENT_RASTER_INDEX                := 0x0B05
  GL_CURRENT_RASTER_POSITION             := 0x0B07
  GL_CURRENT_RASTER_TEXTURE_COORDS       := 0x0B06
  GL_CURRENT_RASTER_POSITION_VALID       := 0x0B08
  GL_CURRENT_TEXTURE_COORDS              := 0x0B03
  GL_INDEX_CLEAR_VALUE                   := 0x0C20
  GL_INDEX_MODE                          := 0x0C30
  GL_INDEX_WRITEMASK                     := 0x0C21
  GL_MODELVIEW_MATRIX                    := 0x0BA6
  GL_MODELVIEW_STACK_DEPTH               := 0x0BA3
  GL_NAME_STACK_DEPTH                    := 0x0D70
  GL_PROJECTION_MATRIX                   := 0x0BA7
  GL_PROJECTION_STACK_DEPTH              := 0x0BA4
  GL_RENDER_MODE                         := 0x0C40
  GL_RGBA_MODE                           := 0x0C31
  GL_TEXTURE_MATRIX                      := 0x0BA8
  GL_TEXTURE_STACK_DEPTH                 := 0x0BA5
  GL_VIEWPORT                            := 0x0BA2

  ; --- Evaluators --- ;
  GL_AUTO_NORMAL                         := 0x0D80
  GL_MAP1_COLOR_4                        := 0x0D90
  GL_MAP1_GRID_DOMAIN                    := 0x0DD0
  GL_MAP1_GRID_SEGMENTS                  := 0x0DD1
  GL_MAP1_INDEX                          := 0x0D91
  GL_MAP1_NORMAL                         := 0x0D92
  GL_MAP1_TEXTURE_COORD_1                := 0x0D93
  GL_MAP1_TEXTURE_COORD_2                := 0x0D94
  GL_MAP1_TEXTURE_COORD_3                := 0x0D95
  GL_MAP1_TEXTURE_COORD_4                := 0x0D96
  GL_MAP1_VERTEX_3                       := 0x0D97
  GL_MAP1_VERTEX_4                       := 0x0D98
  GL_MAP2_COLOR_4                        := 0x0DB0
  GL_MAP2_GRID_DOMAIN                    := 0x0DD2
  GL_MAP2_GRID_SEGMENTS                  := 0x0DD3
  GL_MAP2_INDEX                          := 0x0DB1
  GL_MAP2_NORMAL                         := 0x0DB2
  GL_MAP2_TEXTURE_COORD_1                := 0x0DB3
  GL_MAP2_TEXTURE_COORD_2                := 0x0DB4
  GL_MAP2_TEXTURE_COORD_3                := 0x0DB5
  GL_MAP2_TEXTURE_COORD_4                := 0x0DB6
  GL_MAP2_VERTEX_3                       := 0x0DB7
  GL_MAP2_VERTEX_4                       := 0x0DB8
  GL_COEFF                               := 0x0A00
  GL_DOMAIN                              := 0x0A02
  GL_ORDER                               := 0x0A01

  ; --- Hints --- ;
  GL_FOG_HINT                            := 0x0C54
  GL_LINE_SMOOTH_HINT                    := 0x0C52
  GL_PERSPECTIVE_CORRECTION_HINT         := 0x0C50
  GL_POINT_SMOOTH_HINT                   := 0x0C51
  GL_POLYGON_SMOOTH_HINT                 := 0x0C53
  GL_DONT_CARE                           := 0x1100
  GL_FASTEST                             := 0x1101
  GL_NICEST                              := 0x1102

  ; --- Scissor box --- ;
  GL_SCISSOR_TEST                        := 0x0C11
  GL_SCISSOR_BOX                         := 0x0C10

  ; --- Pixel Mode / Transfer --- ;
  GL_MAP_COLOR                           := 0x0D10
  GL_MAP_STENCIL                         := 0x0D11
  GL_INDEX_SHIFT                         := 0x0D12
  GL_INDEX_OFFSET                        := 0x0D13
  GL_RED_SCALE                           := 0x0D14
  GL_RED_BIAS                            := 0x0D15
  GL_GREEN_SCALE                         := 0x0D18
  GL_GREEN_BIAS                          := 0x0D19
  GL_BLUE_SCALE                          := 0x0D1A
  GL_BLUE_BIAS                           := 0x0D1B
  GL_ALPHA_SCALE                         := 0x0D1C
  GL_ALPHA_BIAS                          := 0x0D1D
  GL_DEPTH_SCALE                         := 0x0D1E
  GL_DEPTH_BIAS                          := 0x0D1F
  GL_PIXEL_MAP_S_TO_S_SIZE               := 0x0CB1
  GL_PIXEL_MAP_I_TO_I_SIZE               := 0x0CB0
  GL_PIXEL_MAP_I_TO_R_SIZE               := 0x0CB2
  GL_PIXEL_MAP_I_TO_G_SIZE               := 0x0CB3
  GL_PIXEL_MAP_I_TO_B_SIZE               := 0x0CB4
  GL_PIXEL_MAP_I_TO_A_SIZE               := 0x0CB5
  GL_PIXEL_MAP_R_TO_R_SIZE               := 0x0CB6
  GL_PIXEL_MAP_G_TO_G_SIZE               := 0x0CB7
  GL_PIXEL_MAP_B_TO_B_SIZE               := 0x0CB8
  GL_PIXEL_MAP_A_TO_A_SIZE               := 0x0CB9
  GL_PIXEL_MAP_S_TO_S                    := 0x0C71
  GL_PIXEL_MAP_I_TO_I                    := 0x0C70
  GL_PIXEL_MAP_I_TO_R                    := 0x0C72
  GL_PIXEL_MAP_I_TO_G                    := 0x0C73
  GL_PIXEL_MAP_I_TO_B                    := 0x0C74
  GL_PIXEL_MAP_I_TO_A                    := 0x0C75
  GL_PIXEL_MAP_R_TO_R                    := 0x0C76
  GL_PIXEL_MAP_G_TO_G                    := 0x0C77
  GL_PIXEL_MAP_B_TO_B                    := 0x0C78
  GL_PIXEL_MAP_A_TO_A                    := 0x0C79
  GL_PACK_ALIGNMENT                      := 0x0D05
  GL_PACK_LSB_FIRST                      := 0x0D01
  GL_PACK_ROW_LENGTH                     := 0x0D02
  GL_PACK_SKIP_PIXELS                    := 0x0D04
  GL_PACK_SKIP_ROWS                      := 0x0D03
  GL_PACK_SWAP_BYTES                     := 0x0D00
  GL_UNPACK_ALIGNMENT                    := 0x0CF5
  GL_UNPACK_LSB_FIRST                    := 0x0CF1
  GL_UNPACK_ROW_LENGTH                   := 0x0CF2
  GL_UNPACK_SKIP_PIXELS                  := 0x0CF4
  GL_UNPACK_SKIP_ROWS                    := 0x0CF3
  GL_UNPACK_SWAP_BYTES                   := 0x0CF0
  GL_ZOOM_X                              := 0x0D16
  GL_ZOOM_Y                              := 0x0D17

  ; --- Texture mapping --- ;
  GL_TEXTURE_ENV                         := 0x2300
  GL_TEXTURE_ENV_MODE                    := 0x2200
  GL_TEXTURE_1D                          := 0x0DE0
  GL_TEXTURE_2D                          := 0x0DE1
  GL_TEXTURE_WRAP_S                      := 0x2802
  GL_TEXTURE_WRAP_T                      := 0x2803
  GL_TEXTURE_MAG_FILTER                  := 0x2800
  GL_TEXTURE_MIN_FILTER                  := 0x2801
  GL_TEXTURE_ENV_COLOR                   := 0x2201
  GL_TEXTURE_GEN_S                       := 0x0C60
  GL_TEXTURE_GEN_T                       := 0x0C61
  GL_TEXTURE_GEN_MODE                    := 0x2500
  GL_TEXTURE_BORDER_COLOR                := 0x1004
  GL_TEXTURE_WIDTH                       := 0x1000
  GL_TEXTURE_HEIGHT                      := 0x1001
  GL_TEXTURE_BORDER                      := 0x1005
  GL_TEXTURE_COMPONENTS                  := 0x1003
  GL_TEXTURE_RED_SIZE                    := 0x805C
  GL_TEXTURE_GREEN_SIZE                  := 0x805D
  GL_TEXTURE_BLUE_SIZE                   := 0x805E
  GL_TEXTURE_ALPHA_SIZE                  := 0x805F
  GL_TEXTURE_LUMINANCE_SIZE              := 0x8060
  GL_TEXTURE_INTENSITY_SIZE              := 0x8061
  GL_NEAREST_MIPMAP_NEAREST              := 0x2700
  GL_NEAREST_MIPMAP_LINEAR               := 0x2702
  GL_LINEAR_MIPMAP_NEAREST               := 0x2701
  GL_LINEAR_MIPMAP_LINEAR                := 0x2703
  GL_OBJECT_LINEAR                       := 0x2401
  GL_OBJECT_PLANE                        := 0x2501
  GL_EYE_LINEAR                          := 0x2400
  GL_EYE_PLANE                           := 0x2502
  GL_SPHERE_MAP                          := 0x2402
  GL_DECAL                               := 0x2101
  GL_MODULATE                            := 0x2100
  GL_NEAREST                             := 0x2600
  GL_REPEAT                              := 0x2901
  GL_CLAMP                               := 0x2900
  GL_S                                   := 0x2000
  GL_T                                   := 0x2001
  GL_R                                   := 0x2002
  GL_Q                                   := 0x2003
  GL_TEXTURE_GEN_R                       := 0x0C62
  GL_TEXTURE_GEN_Q                       := 0x0C63

  ; --- Utility --- ;
  GL_VENDOR                              := 0x1F00
  GL_RENDERER                            := 0x1F01
  GL_VERSION                             := 0x1F02
  GL_EXTENSIONS                          := 0x1F03

  ; --- Errors --- ;
  GL_NO_ERROR                            := 0x0
  GL_INVALID_VALUE                       := 0x0501
  GL_INVALID_ENUM                        := 0x0500
  GL_INVALID_OPERATION                   := 0x0502
  GL_STACK_OVERFLOW                      := 0x0503
  GL_STACK_UNDERFLOW                     := 0x0504
  GL_OUT_OF_MEMORY                       := 0x0505

  ; --- glPush/PopAttrib bits --- ;
  GL_CURRENT_BIT                         := 0x00000001
  GL_POINT_BIT                           := 0x00000002
  GL_LINE_BIT                            := 0x00000004
  GL_POLYGON_BIT                         := 0x00000008
  GL_POLYGON_STIPPLE_BIT                 := 0x00000010
  GL_PIXEL_MODE_BIT                      := 0x00000020
  GL_LIGHTING_BIT                        := 0x00000040
  GL_FOG_BIT                             := 0x00000080
  GL_DEPTH_BUFFER_BIT                    := 0x00000100
  GL_ACCUM_BUFFER_BIT                    := 0x00000200
  GL_STENCIL_BUFFER_BIT                  := 0x00000400
  GL_VIEWPORT_BIT                        := 0x00000800
  GL_TRANSFORM_BIT                       := 0x00001000
  GL_ENABLE_BIT                          := 0x00002000
  GL_COLOR_BUFFER_BIT                    := 0x00004000
  GL_HINT_BIT                            := 0x00008000
  GL_EVAL_BIT                            := 0x00010000
  GL_LIST_BIT                            := 0x00020000
  GL_TEXTURE_BIT                         := 0x00040000
  GL_SCISSOR_BIT                         := 0x00080000
  GL_ALL_ATTRIB_BITS                     := 0x000FFFFF

  ; --- OpenGL 1.1 --- ;
  GL_PROXY_TEXTURE_1D                    := 0x8063
  GL_PROXY_TEXTURE_2D                    := 0x8064
  GL_TEXTURE_PRIORITY                    := 0x8066
  GL_TEXTURE_RESIDENT                    := 0x8067
  GL_TEXTURE_BINDING_1D                  := 0x8068
  GL_TEXTURE_BINDING_2D                  := 0x8069
  GL_TEXTURE_INTERNAL_FORMAT             := 0x1003
  GL_ALPHA4                              := 0x803B
  GL_ALPHA8                              := 0x803C
  GL_ALPHA12                             := 0x803D
  GL_ALPHA16                             := 0x803E
  GL_LUMINANCE4                          := 0x803F
  GL_LUMINANCE8                          := 0x8040
  GL_LUMINANCE12                         := 0x8041
  GL_LUMINANCE16                         := 0x8042
  GL_LUMINANCE4_ALPHA4                   := 0x8043
  GL_LUMINANCE6_ALPHA2                   := 0x8044
  GL_LUMINANCE8_ALPHA8                   := 0x8045
  GL_LUMINANCE12_ALPHA4                  := 0x8046
  GL_LUMINANCE12_ALPHA12                 := 0x8047
  GL_LUMINANCE16_ALPHA16                 := 0x8048
  GL_INTENSITY                           := 0x8049
  GL_INTENSITY4                          := 0x804A
  GL_INTENSITY8                          := 0x804B
  GL_INTENSITY12                         := 0x804C
  GL_INTENSITY16                         := 0x804D
  GL_R3_G3_B2                            := 0x2A10
  GL_RGB4                                := 0x804F
  GL_RGB5                                := 0x8050
  GL_RGB8                                := 0x8051
  GL_RGB10                               := 0x8052
  GL_RGB12                               := 0x8053
  GL_RGB16                               := 0x8054
  GL_RGBA2                               := 0x8055
  GL_RGBA4                               := 0x8056
  GL_RGB5_A1                             := 0x8057
  GL_RGBA8                               := 0x8058
  GL_RGB10_A2                            := 0x8059
  GL_RGBA12                              := 0x805A
  GL_RGBA16                              := 0x805B
  GL_CLIENT_PIXEL_STORE_BIT              := 0x00000001
  GL_CLIENT_VERTEX_ARRAY_BIT             := 0x00000002
  GL_ALL_CLIENT_ATTRIB_BITS              := 0xFFFFFFFF
  GL_CLIENT_ALL_ATTRIB_BITS              := 0xFFFFFFFF

  ; --- OpenGL 1.2 --- ;
  GL_RESCALE_NORMAL                      := 0x803A
  GL_CLAMP_TO_EDGE                       := 0x812F
  GL_MAX_ELEMENTS_VERTICES               := 0x80E8
  GL_MAX_ELEMENTS_INDICES                := 0x80E9
  GL_BGR                                 := 0x80E0
  GL_BGRA                                := 0x80E1
  GL_UNSIGNED_BYTE_3_3_2                 := 0x8032
  GL_UNSIGNED_BYTE_2_3_3_REV             := 0x8362
  GL_UNSIGNED_SHORT_5_6_5                := 0x8363
  GL_UNSIGNED_SHORT_5_6_5_REV            := 0x8364
  GL_UNSIGNED_SHORT_4_4_4_4              := 0x8033
  GL_UNSIGNED_SHORT_4_4_4_4_REV          := 0x8365
  GL_UNSIGNED_SHORT_5_5_5_1              := 0x8034
  GL_UNSIGNED_SHORT_1_5_5_5_REV          := 0x8366
  GL_UNSIGNED_INT_8_8_8_8                := 0x8035
  GL_UNSIGNED_INT_8_8_8_8_REV            := 0x8367
  GL_UNSIGNED_INT_10_10_10_2             := 0x8036
  GL_UNSIGNED_INT_2_10_10_10_REV         := 0x8368
  GL_LIGHT_MODEL_COLOR_CONTROL           := 0x81F8
  GL_SINGLE_COLOR                        := 0x81F9
  GL_SEPARATE_SPECULAR_COLOR             := 0x81FA
  GL_TEXTURE_MIN_LOD                     := 0x813A
  GL_TEXTURE_MAX_LOD                     := 0x813B
  GL_TEXTURE_BASE_LEVEL                  := 0x813C
  GL_TEXTURE_MAX_LEVEL                   := 0x813D
  GL_SMOOTH_POINT_SIZE_RANGE             := 0x0B12
  GL_SMOOTH_POINT_SIZE_GRANULARITY       := 0x0B13
  GL_SMOOTH_LINE_WIDTH_RANGE             := 0x0B22
  GL_SMOOTH_LINE_WIDTH_GRANULARITY       := 0x0B23
  GL_ALIASED_POINT_SIZE_RANGE            := 0x846D
  GL_ALIASED_LINE_WIDTH_RANGE            := 0x846E
  GL_PACK_SKIP_IMAGES                    := 0x806B
  GL_PACK_IMAGE_HEIGHT                   := 0x806C
  GL_UNPACK_SKIP_IMAGES                  := 0x806D
  GL_UNPACK_IMAGE_HEIGHT                 := 0x806E
  GL_TEXTURE_3D                          := 0x806F
  GL_PROXY_TEXTURE_3D                    := 0x8070
  GL_TEXTURE_DEPTH                       := 0x8071
  GL_TEXTURE_WRAP_R                      := 0x8072
  GL_MAX_3D_TEXTURE_SIZE                 := 0x8073
  GL_TEXTURE_BINDING_3D                  := 0x806A

  ; --- OpenGL 1.2 imaging subset --- ;

  ; GL_EXT_color_table ;
  GL_COLOR_TABLE                         := 0x80D0
  GL_POST_CONVOLUTION_COLOR_TABLE        := 0x80D1
  GL_POST_COLOR_MATRIX_COLOR_TABLE       := 0x80D2
  GL_PROXY_COLOR_TABLE                   := 0x80D3
  GL_PROXY_POST_CONVOLUTION_COLOR_TABLE  := 0x80D4
  GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE := 0x80D5
  GL_COLOR_TABLE_SCALE                   := 0x80D6
  GL_COLOR_TABLE_BIAS                    := 0x80D7
  GL_COLOR_TABLE_FORMAT                  := 0x80D8
  GL_COLOR_TABLE_WIDTH                   := 0x80D9
  GL_COLOR_TABLE_RED_SIZE                := 0x80DA
  GL_COLOR_TABLE_GREEN_SIZE              := 0x80DB
  GL_COLOR_TABLE_BLUE_SIZE               := 0x80DC
  GL_COLOR_TABLE_ALPHA_SIZE              := 0x80DD
  GL_COLOR_TABLE_LUMINANCE_SIZE          := 0x80DE
  GL_COLOR_TABLE_INTENSITY_SIZE          := 0x80DF

  ; GL_EXT_convolution and GL_HP_convolution_border_modes ;
  GL_CONVOLUTION_1D                      := 0x8010
  GL_CONVOLUTION_2D                      := 0x8011
  GL_SEPARABLE_2D                        := 0x8012
  GL_CONVOLUTION_BORDER_MODE             := 0x8013
  GL_CONVOLUTION_FILTER_SCALE            := 0x8014
  GL_CONVOLUTION_FILTER_BIAS             := 0x8015
  GL_REDUCE                              := 0x8016
  GL_CONVOLUTION_FORMAT                  := 0x8017
  GL_CONVOLUTION_WIDTH                   := 0x8018
  GL_CONVOLUTION_HEIGHT                  := 0x8019
  GL_MAX_CONVOLUTION_WIDTH               := 0x801A
  GL_MAX_CONVOLUTION_HEIGHT              := 0x801B
  GL_POST_CONVOLUTION_RED_SCALE          := 0x801C
  GL_POST_CONVOLUTION_GREEN_SCALE        := 0x801D
  GL_POST_CONVOLUTION_BLUE_SCALE         := 0x801E
  GL_POST_CONVOLUTION_ALPHA_SCALE        := 0x801F
  GL_POST_CONVOLUTION_RED_BIAS           := 0x8020
  GL_POST_CONVOLUTION_GREEN_BIAS         := 0x8021
  GL_POST_CONVOLUTION_BLUE_BIAS          := 0x8022
  GL_POST_CONVOLUTION_ALPHA_BIAS         := 0x8023
  GL_CONSTANT_BORDER                     := 0x8151
  GL_REPLICATE_BORDER                    := 0x8153
  GL_CONVOLUTION_BORDER_COLOR            := 0x8154

  ; GL_SGI_color_matrix ;
  GL_COLOR_MATRIX                        := 0x80B1
  GL_COLOR_MATRIX_STACK_DEPTH            := 0x80B2
  GL_MAX_COLOR_MATRIX_STACK_DEPTH        := 0x80B3
  GL_POST_COLOR_MATRIX_RED_SCALE         := 0x80B4
  GL_POST_COLOR_MATRIX_GREEN_SCALE       := 0x80B5
  GL_POST_COLOR_MATRIX_BLUE_SCALE        := 0x80B6
  GL_POST_COLOR_MATRIX_ALPHA_SCALE       := 0x80B7
  GL_POST_COLOR_MATRIX_RED_BIAS          := 0x80B8
  GL_POST_COLOR_MATRIX_GREEN_BIAS        := 0x80B9
  GL_POST_COLOR_MATRIX_BLUE_BIAS         := 0x80BA
  GL_POST_COLOR_MATRIX_ALPHA_BIAS        := 0x80BB

  ; GL_EXT_histogram ;
  GL_HISTOGRAM                           := 0x8024
  GL_PROXY_HISTOGRAM                     := 0x8025
  GL_HISTOGRAM_WIDTH                     := 0x8026
  GL_HISTOGRAM_FORMAT                    := 0x8027
  GL_HISTOGRAM_RED_SIZE                  := 0x8028
  GL_HISTOGRAM_GREEN_SIZE                := 0x8029
  GL_HISTOGRAM_BLUE_SIZE                 := 0x802A
  GL_HISTOGRAM_ALPHA_SIZE                := 0x802B
  GL_HISTOGRAM_LUMINANCE_SIZE            := 0x802C
  GL_HISTOGRAM_SINK                      := 0x802D
  GL_MINMAX                              := 0x802E
  GL_MINMAX_FORMAT                       := 0x802F
  GL_MINMAX_SINK                         := 0x8030
  GL_TABLE_TOO_LARGE                     := 0x8031

  ; GL_EXT_blend_color, GL_EXT_blend_minmax ;
  GL_BLEND_EQUATION                      := 0x8009
  GL_MIN                                 := 0x8007
  GL_MAX                                 := 0x8008
  GL_FUNC_ADD                            := 0x8006
  GL_FUNC_SUBTRACT                       := 0x800A
  GL_FUNC_REVERSE_SUBTRACT               := 0x800B
  GL_BLEND_COLOR                         := 0x8005

  ; --- OpenGL 1.3 --- ;

  ; multitexture ;
  GL_TEXTURE0                            := 0x84C0
  GL_TEXTURE1                            := 0x84C1
  GL_TEXTURE2                            := 0x84C2
  GL_TEXTURE3                            := 0x84C3
  GL_TEXTURE4                            := 0x84C4
  GL_TEXTURE5                            := 0x84C5
  GL_TEXTURE6                            := 0x84C6
  GL_TEXTURE7                            := 0x84C7
  GL_TEXTURE8                            := 0x84C8
  GL_TEXTURE9                            := 0x84C9
  GL_TEXTURE10                           := 0x84CA
  GL_TEXTURE11                           := 0x84CB
  GL_TEXTURE12                           := 0x84CC
  GL_TEXTURE13                           := 0x84CD
  GL_TEXTURE14                           := 0x84CE
  GL_TEXTURE15                           := 0x84CF
  GL_TEXTURE16                           := 0x84D0
  GL_TEXTURE17                           := 0x84D1
  GL_TEXTURE18                           := 0x84D2
  GL_TEXTURE19                           := 0x84D3
  GL_TEXTURE20                           := 0x84D4
  GL_TEXTURE21                           := 0x84D5
  GL_TEXTURE22                           := 0x84D6
  GL_TEXTURE23                           := 0x84D7
  GL_TEXTURE24                           := 0x84D8
  GL_TEXTURE25                           := 0x84D9
  GL_TEXTURE26                           := 0x84DA
  GL_TEXTURE27                           := 0x84DB
  GL_TEXTURE28                           := 0x84DC
  GL_TEXTURE29                           := 0x84DD
  GL_TEXTURE30                           := 0x84DE
  GL_TEXTURE31                           := 0x84DF
  GL_ACTIVE_TEXTURE                      := 0x84E0
  GL_CLIENT_ACTIVE_TEXTURE               := 0x84E1
  GL_MAX_TEXTURE_UNITS                   := 0x84E2

  ; texture_cube_map ;
  GL_NORMAL_MAP                          := 0x8511
  GL_REFLECTION_MAP                      := 0x8512
  GL_TEXTURE_CUBE_MAP                    := 0x8513
  GL_TEXTURE_BINDING_CUBE_MAP            := 0x8514
  GL_TEXTURE_CUBE_MAP_POSITIVE_X         := 0x8515
  GL_TEXTURE_CUBE_MAP_NEGATIVE_X         := 0x8516
  GL_TEXTURE_CUBE_MAP_POSITIVE_Y         := 0x8517
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Y         := 0x8518
  GL_TEXTURE_CUBE_MAP_POSITIVE_Z         := 0x8519
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Z         := 0x851A
  GL_PROXY_TEXTURE_CUBE_MAP              := 0x851B
  GL_MAX_CUBE_MAP_TEXTURE_SIZE           := 0x851C

  ; texture_compression ;
  GL_COMPRESSED_ALPHA                    := 0x84E9
  GL_COMPRESSED_LUMINANCE                := 0x84EA
  GL_COMPRESSED_LUMINANCE_ALPHA          := 0x84EB
  GL_COMPRESSED_INTENSITY                := 0x84EC
  GL_COMPRESSED_RGB                      := 0x84ED
  GL_COMPRESSED_RGBA                     := 0x84EE
  GL_TEXTURE_COMPRESSION_HINT            := 0x84EF
  GL_TEXTURE_COMPRESSED_IMAGE_SIZE       := 0x86A0
  GL_TEXTURE_COMPRESSED                  := 0x86A1
  GL_NUM_COMPRESSED_TEXTURE_FORMATS      := 0x86A2
  GL_COMPRESSED_TEXTURE_FORMATS          := 0x86A3

  ; multisample ;
  GL_MULTISAMPLE                         := 0x809D
  GL_SAMPLE_ALPHA_TO_COVERAGE            := 0x809E
  GL_SAMPLE_ALPHA_TO_ONE                 := 0x809F
  GL_SAMPLE_COVERAGE                     := 0x80A0
  GL_SAMPLE_BUFFERS                      := 0x80A8
  GL_SAMPLES                             := 0x80A9
  GL_SAMPLE_COVERAGE_VALUE               := 0x80AA
  GL_SAMPLE_COVERAGE_INVERT              := 0x80AB
  GL_MULTISAMPLE_BIT                     := 0x20000000

  ; transpose_matrix ;
  GL_TRANSPOSE_MODELVIEW_MATRIX          := 0x84E3
  GL_TRANSPOSE_PROJECTION_MATRIX         := 0x84E4
  GL_TRANSPOSE_TEXTURE_MATRIX            := 0x84E5
  GL_TRANSPOSE_COLOR_MATRIX              := 0x84E6

  ; texture_env_combine ;
  GL_COMBINE                             := 0x8570
  GL_COMBINE_RGB                         := 0x8571
  GL_COMBINE_ALPHA                       := 0x8572
  GL_SOURCE0_RGB                         := 0x8580
  GL_SOURCE1_RGB                         := 0x8581
  GL_SOURCE2_RGB                         := 0x8582
  GL_SOURCE0_ALPHA                       := 0x8588
  GL_SOURCE1_ALPHA                       := 0x8589
  GL_SOURCE2_ALPHA                       := 0x858A
  GL_OPERAND0_RGB                        := 0x8590
  GL_OPERAND1_RGB                        := 0x8591
  GL_OPERAND2_RGB                        := 0x8592
  GL_OPERAND0_ALPHA                      := 0x8598
  GL_OPERAND1_ALPHA                      := 0x8599
  GL_OPERAND2_ALPHA                      := 0x859A
  GL_RGB_SCALE                           := 0x8573
  GL_ADD_SIGNED                          := 0x8574
  GL_INTERPOLATE                         := 0x8575
  GL_SUBTRACT                            := 0x84E7
  GL_CONSTANT                            := 0x8576
  GL_PRIMARY_COLOR                       := 0x8577
  GL_PREVIOUS                            := 0x8578

  ; texture_env_dot3 ;
  GL_DOT3_RGB                            := 0x86AE
  GL_DOT3_RGBA                           := 0x86AF
  ; texture_border_clamp ;
  GL_CLAMP_TO_BORDER                     := 0x812D

  ; ### Function prototypes ### ;

  glClearIndex(c) {
    Return DllCall("opengl32.dll\glClearIndex", "Float", c)
  }
  glClearColor(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glClearColor", "Float", red, "Float", green, "Float", blue, "Float", alpha)
  }
  glClear(mask) {
    Return DllCall("opengl32.dll\glClear", "UInt", mask)
  }
  glIndexMask(mask) {
    Return DllCall("opengl32.dll\glIndexMask", "UInt", mask)
  }
  glColorMask(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColorMask", "UChar", red, "UChar", green, "UChar", blue, "UChar", alpha)
  }
  glAlphaFunc(func, ref) {
    Return DllCall("opengl32.dll\glAlphaFunc", "UInt", func, "Float", ref)
  }
  glBlendFunc(sfactor, dfactor) {
    Return DllCall("opengl32.dll\glBlendFunc", "UInt", sfactor, "UInt", dfactor)
  }
  glLogicOp(opcode) {
    Return DllCall("opengl32.dll\glLogicOp", "UInt", opcode)
  }
  glCullFace(mode) {
    Return DllCall("opengl32.dll\glCullFace", "UInt", mode)
  }
  glFrontFace(mode) {
    Return DllCall("opengl32.dll\glFrontFace", "UInt", mode)
  }
  glPointSize(size) {
    Return DllCall("opengl32.dll\glPointSize", "Float", size)
  }
  glLineWidth(width) {
    Return DllCall("opengl32.dll\glLineWidth", "Float", width)
  }
  glLineStipple(factor, pattern) {
    Return DllCall("opengl32.dll\glLineStipple", "Int", factor, "UShort", pattern)
  }
  glPolygonMode(face, mode) {
    Return DllCall("opengl32.dll\glPolygonMode", "UInt", face, "UInt", mode)
  }
  glPolygonOffset(factor, units) {
    Return DllCall("opengl32.dll\glPolygonOffset", "Float", factor, "Float", units)
  }
  glPolygonStipple(byref mask) {
    Return DllCall("opengl32.dll\glPolygonStipple", "UChar",  mask)
  }
  glGetPolygonStipple(byref mask) {
    Return DllCall("opengl32.dll\glGetPolygonStipple", "UChar",  mask)
  }
  glEdgeFlag(flag) {
    Return DllCall("opengl32.dll\glEdgeFlag", "UChar", flag)
  }
  glEdgeFlagv(byref flag) {
    Return DllCall("opengl32.dll\glEdgeFlagv", "UChar",  flag)
  }
  glScissor(x, y, width, heigh) {
    Return DllCall("opengl32.dll\glScissor", "Int", x, "Int", y, "Int", width, "Int", heigh)
  }
  glClipPlane(plane, equation) {
    Return DllCall("opengl32.dll\glClipPlane", "UInt", plane, "Double",  equation)
  }
  glGetClipPlane(plane, equation) {
    Return DllCall("opengl32.dll\glGetClipPlane", "UInt", plane, "Double",  equation)
  }
  glDrawBuffer(mode) {
    Return DllCall("opengl32.dll\glDrawBuffer", "UInt", mode)
  }
  glReadBuffer(mode) {
    Return DllCall("opengl32.dll\glReadBuffer", "UInt", mode)
  }
  glEnable(cap) {
    Return DllCall("opengl32.dll\glEnable", "UInt", cap)
  }
  glDisable(cap) {
    Return DllCall("opengl32.dll\glDisable", "UInt", cap)
  }
  glIsEnabled(cap) {
    Return DllCall("opengl32.dll\glIsEnabled", "UInt", cap)
  }
  glEnableClientState(cap) {
    Return DllCall("opengl32.dll\glEnableClientState", "UInt", cap)
  }
  glDisableClientState(cap) {
    Return DllCall("opengl32.dll\glDisableClientState", "UInt", cap)
  }
  glGetBooleanv(pname, params) {
    Return DllCall("opengl32.dll\glGetBooleanv", "UInt", pname, "UChar",  params)
  }
  glGetDoublev(pname, params) {
    Return DllCall("opengl32.dll\glGetDoublev", "UInt", pname, "Double",  params)
  }
  glGetFloatv(pname, params) {
    Return DllCall("opengl32.dll\glGetFloatv", "UInt", pname, "Float",  params)
  }
  glGetIntegerv(pname, params) {
    Return DllCall("opengl32.dll\glGetIntegerv", "UInt", pname, "Int",  params)
  }
  glPushAttrib(mask) {
    Return DllCall("opengl32.dll\glPushAttrib", "UInt", mask)
  }
  glPopAttrib() {
    Return DllCall("opengl32.dll\glPopAttrib", "")
  }
  glPushClientAttrib(mask) {
    Return DllCall("opengl32.dll\glPushClientAttrib", "UInt", mask)
  }
  glPopClientAttrib() {
    Return DllCall("opengl32.dll\glPopClientAttrib", "")
  }
  glRenderMode(mode) {
    Return DllCall("opengl32.dll\glRenderMode", "UInt", mode)
  }
  glGetError() {
    Return DllCall("opengl32.dll\glGetError", "")
  }
  glGetString(name) {
    Return DllCall("opengl32.dll\glGetString", "UInt", name)
  }
  glFinish() {
    Return DllCall("opengl32.dll\glFinish", "")
  }
  glFlush() {
    Return DllCall("opengl32.dll\glFlush", "")
  }
  glHint(target, mode) {
    Return DllCall("opengl32.dll\glHint", "UInt", target, "UInt", mode)
  }
  
  glClearDepth(depth) {
    Return DllCall("opengl32.dll\glClearDepth", "Double", depth)
  }
  glDepthFunc(func) {
    Return DllCall("opengl32.dll\glDepthFunc", "UInt", func)
  }
  glDepthMask(flag) {
    Return DllCall("opengl32.dll\glDepthMask", "UChar", flag)
  }
  glDepthRange(near_val, far_val) {
    Return DllCall("opengl32.dll\glDepthRange", "Double", near_val, "Double", far_val)
  }
  
  glClearAccum(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glClearAccum", "Float", red, "Float", green, "Float", blue, "Float", alpha)
  }
  glAccum(op, value) {
    Return DllCall("opengl32.dll\glAccum", "UInt", op, "Float", value)
  }
  
  glMatrixMode(mode) {
    Return DllCall("opengl32.dll\glMatrixMode", "UInt", mode)
  }
  glOrtho(left, right, bottom, top, near_val, far_val) {
    Return DllCall("opengl32.dll\glOrtho", "Double", left, "Double", right, "Double", bottom, "Double", top, "Double", near_val, "Double", far_val)
  }
  glFrustum(left, right, bottom, top, near_val, far_val) {
    Return DllCall("opengl32.dll\glFrustum", "Double", left, "Double", right, "Double", bottom, "Double", top, "Double", near_val, "Double", far_val)
  }
  glViewport(x, y, width, height) {
    Return DllCall("opengl32.dll\glViewport", "Int", x, "Int", y, "Int", width, "Int", height)
  }
  glPushMatrix() {
    Return DllCall("opengl32.dll\glPushMatrix", "")
  }
  glPopMatrix() {
    Return DllCall("opengl32.dll\glPopMatrix", "")
  }
  glLoadIdentity() {
    Return DllCall("opengl32.dll\glLoadIdentity", "")
  }
  glLoadMatrixd(byref m) {
    Return DllCall("opengl32.dll\glLoadMatrixd", "Double",  m)
  }
  glLoadMatrixf(byref m) {
    Return DllCall("opengl32.dll\glLoadMatrixf", "Float",  m)
  }
  glMultMatrixd(byref m) {
    Return DllCall("opengl32.dll\glMultMatrixd", "Double",  m)
  }
  glMultMatrixf(byref m) {
    Return DllCall("opengl32.dll\glMultMatrixf", "Float",  m)
  }
  glRotated(angle, x, y, z) {
    Return DllCall("opengl32.dll\glRotated", "Double", angle, "Double", x, "Double", y, "Double", z)
  }
  glRotatef(angle, x, y, z) {
    Return DllCall("opengl32.dll\glRotatef", "Float", angle, "Float", x, "Float", y, "Float", z)
  }
  glScaled(x, y, z) {
    Return DllCall("opengl32.dll\glScaled", "Double", x, "Double", y, "Double", z)
  }
  glScalef(x, y, z) {
    Return DllCall("opengl32.dll\glScalef", "Float", x, "Float", y, "Float", z)
  }
  glTranslated(x, y, z) {
    Return DllCall("opengl32.dll\glTranslated", "Double", x, "Double", y, "Double", z)
  }
  glTranslatef(x, y, z) {
    Return DllCall("opengl32.dll\glTranslatef", "Float", x, "Float", y, "Float", z)
  }
  
  glIsList(list) {
    Return DllCall("opengl32.dll\glIsList", "UInt", list)
  }
  glDeleteLists(list, range) {
    Return DllCall("opengl32.dll\glDeleteLists", "UInt", list, "Int", range)
  }
  glGenLists(range) {
    Return DllCall("opengl32.dll\glGenLists", "Int", range)
  }
  glNewList(list, mode) {
    Return DllCall("opengl32.dll\glNewList", "UInt", list, "UInt", mode)
  }
  glEndList() {
    Return DllCall("opengl32.dll\glEndList", "")
  }
  glCallList(list) {
    Return DllCall("opengl32.dll\glCallList", "UInt", list)
  }
  glCallLists(n, type, lists) {
    Return DllCall("opengl32.dll\glCallLists", "Int", n, "UInt", type, "Int",  lists)
  }
  glListBase(base) {
    Return DllCall("opengl32.dll\glListBase", "UInt", base)
  }
  
  glBegin(mode) {
    Return DllCall("opengl32.dll\glBegin", "UInt", mode)
  }
  glEnd() {
    Return DllCall("opengl32.dll\glEnd", "")
  }
  glVertex2d(x, y) {
    Return DllCall("opengl32.dll\glVertex2d", "Double", x, "Double", y)
  }
  glVertex2f(x, y) {
    Return DllCall("opengl32.dll\glVertex2f", "Float", x, "Float", y)
  }
  glVertex2i(x, y) {
    Return DllCall("opengl32.dll\glVertex2i", "Int", x, "Int", y)
  }
  glVertex2s(x, y) {
    Return DllCall("opengl32.dll\glVertex2s", "Short", x, "Short", y)
  }
  glVertex3d(x, y, z) {
    Return DllCall("opengl32.dll\glVertex3d", "Double", x, "Double", y, "Double", z)
  }
  glVertex3f(x, y, z) {
    Return DllCall("opengl32.dll\glVertex3f", "Float", x, "Float", y, "Float", z)
  }
  glVertex3i(x, y, z) {
    Return DllCall("opengl32.dll\glVertex3i", "Int", x, "Int", y, "Int", z)
  }
  glVertex3s(x, y, z) {
    Return DllCall("opengl32.dll\glVertex3s", "Short", x, "Short", y, "Short", z)
  }
  glVertex4d(x, y, z, w) {
    Return DllCall("opengl32.dll\glVertex4d", "Double", x, "Double", y, "Double", z, "Double", w)
  }
  glVertex4f(x, y, z, w) {
    Return DllCall("opengl32.dll\glVertex4f", "Float", x, "Float", y, "Float", z, "Float", w)
  }
  glVertex4i(x, y, z, w) {
    Return DllCall("opengl32.dll\glVertex4i", "Int", x, "Int", y, "Int", z, "Int", w)
  }
  glVertex4s(x, y, z, w) {
    Return DllCall("opengl32.dll\glVertex4s", "Short", x, "Short", y, "Short", z, "Short", w)
  }
  glVertex2dv(byref v) {
    Return DllCall("opengl32.dll\glVertex2dv", "Double",  v)
  }
  glVertex2fv(byref v) {
    Return DllCall("opengl32.dll\glVertex2fv", "Float",  v)
  }
  glVertex2iv(byref v) {
    Return DllCall("opengl32.dll\glVertex2iv", "Int",  v)
  }
  glVertex2sv(byref v) {
    Return DllCall("opengl32.dll\glVertex2sv", "Short",  v)
  }
  glVertex3dv(byref v) {
    Return DllCall("opengl32.dll\glVertex3dv", "Double",  v)
  }
  glVertex3fv(byref v) {
    Return DllCall("opengl32.dll\glVertex3fv", "Float",  v)
  }
  glVertex3iv(byref v) {
    Return DllCall("opengl32.dll\glVertex3iv", "Int",  v)
  }
  glVertex3sv(byref v) {
    Return DllCall("opengl32.dll\glVertex3sv", "Short",  v)
  }
  glVertex4dv(byref v) {
    Return DllCall("opengl32.dll\glVertex4dv", "Double",  v)
  }
  glVertex4fv(byref v) {
    Return DllCall("opengl32.dll\glVertex4fv", "Float",  v)
  }
  glVertex4iv(byref v) {
    Return DllCall("opengl32.dll\glVertex4iv", "Int",  v)
  }
  glVertex4sv(byref v) {
    Return DllCall("opengl32.dll\glVertex4sv", "Short",  v)
  }
  glNormal3b(nx, ny, nz) {
    Return DllCall("opengl32.dll\glNormal3b", "Char", nx, "Char", ny, "Char", nz)
  }
  glNormal3d(nx, ny, nz) {
    Return DllCall("opengl32.dll\glNormal3d", "Double", nx, "Double", ny, "Double", nz)
  }
  glNormal3f(nx, ny, nz) {
    Return DllCall("opengl32.dll\glNormal3f", "Float", nx, "Float", ny, "Float", nz)
  }
  glNormal3i(nx, ny, nz) {
    Return DllCall("opengl32.dll\glNormal3i", "Int", nx, "Int", ny, "Int", nz)
  }
  glNormal3s(nx, ny, nz) {
    Return DllCall("opengl32.dll\glNormal3s", "Short", nx, "Short", ny, "Short", nz)
  }
  glNormal3bv(byref v) {
    Return DllCall("opengl32.dll\glNormal3bv", "Char",  v)
  }
  glNormal3dv(byref v) {
    Return DllCall("opengl32.dll\glNormal3dv", "Double",  v)
  }
  glNormal3fv(byref v) {
    Return DllCall("opengl32.dll\glNormal3fv", "Float",  v)
  }
  glNormal3iv(byref v) {
    Return DllCall("opengl32.dll\glNormal3iv", "Int",  v)
  }
  glNormal3sv(byref v) {
    Return DllCall("opengl32.dll\glNormal3sv", "Short",  v)
  }
  glIndexd(c) {
    Return DllCall("opengl32.dll\glIndexd", "Double", c)
  }
  glIndexf(c) {
    Return DllCall("opengl32.dll\glIndexf", "Float", c)
  }
  glIndexi(c) {
    Return DllCall("opengl32.dll\glIndexi", "Int", c)
  }
  glIndexs(c) {
    Return DllCall("opengl32.dll\glIndexs", "Short", c)
  }
  glIndexub(c) {
    Return DllCall("opengl32.dll\glIndexub", "UChar", c)
  }
  glIndexdv(byref c) {
    Return DllCall("opengl32.dll\glIndexdv", "Double",  c)
  }
  glIndexfv(byref c) {
    Return DllCall("opengl32.dll\glIndexfv", "Float",  c)
  }
  glIndexiv(byref c) {
    Return DllCall("opengl32.dll\glIndexiv", "Int",  c)
  }
  glIndexsv(byref c) {
    Return DllCall("opengl32.dll\glIndexsv", "Short",  c)
  }
  glIndexubv(byref c) {
    Return DllCall("opengl32.dll\glIndexubv", "UChar",  c)
  }
  glColor3b(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3b", "Char", red, "Char", green, "Char", blue)
  }
  glColor3d(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3d", "Double", red, "Double", green, "Double", blue)
  }
  glColor3f(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3f", "Float", red, "Float", green, "Float", blue)
  }
  glColor3i(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3i", "Int", red, "Int", green, "Int", blue)
  }
  glColor3s(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3s", "Short", red, "Short", green, "Short", blue)
  }
  glColor3ub(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3ub", "UChar", red, "UChar", green, "UChar", blue)
  }
  glColor3ui(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3ui", "UInt", red, "UInt", green, "UInt", blue)
  }
  glColor3us(red, green, blue) {
    Return DllCall("opengl32.dll\glColor3us", "UShort", red, "UShort", green, "UShort", blue)
  }
  glColor4b(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4b", "Char", red, "Char", green, "Char", blue, "Char", alpha)
  }
  glColor4d(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4d", "Double", red, "Double", green, "Double", blue, "Double", alpha)
  }
  glColor4f(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4f", "Float", red, "Float", green, "Float", blue, "Float", alpha)
  }
  glColor4i(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4i", "Int", red, "Int", green, "Int", blue, "Int", alpha)
  }
  glColor4s(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4s", "Short", red, "Short", green, "Short", blue, "Short", alpha)
  }
  glColor4ub(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4ub", "UChar", red, "UChar", green, "UChar", blue, "UChar", alpha)
  }
  glColor4ui(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4ui", "UInt", red, "UInt", green, "UInt", blue, "UInt", alpha)
  }
  glColor4us(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glColor4us", "UShort", red, "UShort", green, "UShort", blue, "UShort", alpha)
  }
  glColor3bv(byref v) {
    Return DllCall("opengl32.dll\glColor3bv", "Char",  v)
  }
  glColor3dv(byref v) {
    Return DllCall("opengl32.dll\glColor3dv", "Double",  v)
  }
  glColor3fv(byref v) {
    Return DllCall("opengl32.dll\glColor3fv", "Float",  v)
  }
  glColor3iv(byref v) {
    Return DllCall("opengl32.dll\glColor3iv", "Int",  v)
  }
  glColor3sv(byref v) {
    Return DllCall("opengl32.dll\glColor3sv", "Short",  v)
  }
  glColor3ubv(byref v) {
    Return DllCall("opengl32.dll\glColor3ubv", "UChar",  v)
  }
  glColor3uiv(byref v) {
    Return DllCall("opengl32.dll\glColor3uiv", "UInt",  v)
  }
  glColor3usv(byref v) {
    Return DllCall("opengl32.dll\glColor3usv", "UShort",  v)
  }
  glColor4bv(byref v) {
    Return DllCall("opengl32.dll\glColor4bv", "Char",  v)
  }
  glColor4dv(byref v) {
    Return DllCall("opengl32.dll\glColor4dv", "Double",  v)
  }
  glColor4fv(byref v) {
    Return DllCall("opengl32.dll\glColor4fv", "Float",  v)
  }
  glColor4iv(byref v) {
    Return DllCall("opengl32.dll\glColor4iv", "Int",  v)
  }
  glColor4sv(byref v) {
    Return DllCall("opengl32.dll\glColor4sv", "Short",  v)
  }
  glColor4ubv(byref v) {
    Return DllCall("opengl32.dll\glColor4ubv", "UChar",  v)
  }
  glColor4uiv(byref v) {
    Return DllCall("opengl32.dll\glColor4uiv", "UInt",  v)
  }
  glColor4usv(byref v) {
    Return DllCall("opengl32.dll\glColor4usv", "UShort",  v)
  }
  glTexCoord1d(s) {
    Return DllCall("opengl32.dll\glTexCoord1d", "Double", s)
  }
  glTexCoord1f(s) {
    Return DllCall("opengl32.dll\glTexCoord1f", "Float", s)
  }
  glTexCoord1i(s) {
    Return DllCall("opengl32.dll\glTexCoord1i", "Int", s)
  }
  glTexCoord1s(s) {
    Return DllCall("opengl32.dll\glTexCoord1s", "Short", s)
  }
  glTexCoord2d(s, t) {
    Return DllCall("opengl32.dll\glTexCoord2d", "Double", s, "Double", t)
  }
  glTexCoord2f(s, t) {
    Return DllCall("opengl32.dll\glTexCoord2f", "Float", s, "Float", t)
  }
  glTexCoord2i(s, t) {
    Return DllCall("opengl32.dll\glTexCoord2i", "Int", s, "Int", t)
  }
  glTexCoord2s(s, t) {
    Return DllCall("opengl32.dll\glTexCoord2s", "Short", s, "Short", t)
  }
  glTexCoord3d(s, t, r) {
    Return DllCall("opengl32.dll\glTexCoord3d", "Double", s, "Double", t, "Double", r)
  }
  glTexCoord3f(s, t, r) {
    Return DllCall("opengl32.dll\glTexCoord3f", "Float", s, "Float", t, "Float", r)
  }
  glTexCoord3i(s, t, r) {
    Return DllCall("opengl32.dll\glTexCoord3i", "Int", s, "Int", t, "Int", r)
  }
  glTexCoord3s(s, t, r) {
    Return DllCall("opengl32.dll\glTexCoord3s", "Short", s, "Short", t, "Short", r)
  }
  glTexCoord4d(s, t, r, q) {
    Return DllCall("opengl32.dll\glTexCoord4d", "Double", s, "Double", t, "Double", r, "Double", q)
  }
  glTexCoord4f(s, t, r, q) {
    Return DllCall("opengl32.dll\glTexCoord4f", "Float", s, "Float", t, "Float", r, "Float", q)
  }
  glTexCoord4i(s, t, r, q) {
    Return DllCall("opengl32.dll\glTexCoord4i", "Int", s, "Int", t, "Int", r, "Int", q)
  }
  glTexCoord4s(s, t, r, q) {
    Return DllCall("opengl32.dll\glTexCoord4s", "Short", s, "Short", t, "Short", r, "Short", q)
  }
  glTexCoord1dv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord1dv", "Double",  v)
  }
  glTexCoord1fv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord1fv", "Float",  v)
  }
  glTexCoord1iv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord1iv", "Int",  v)
  }
  glTexCoord1sv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord1sv", "Short",  v)
  }
  glTexCoord2dv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord2dv", "Double",  v)
  }
  glTexCoord2fv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord2fv", "Float",  v)
  }
  glTexCoord2iv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord2iv", "Int",  v)
  }
  glTexCoord2sv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord2sv", "Short",  v)
  }
  glTexCoord3dv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord3dv", "Double",  v)
  }
  glTexCoord3fv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord3fv", "Float",  v)
  }
  glTexCoord3iv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord3iv", "Int",  v)
  }
  glTexCoord3sv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord3sv", "Short",  v)
  }
  glTexCoord4dv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord4dv", "Double",  v)
  }
  glTexCoord4fv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord4fv", "Float",  v)
  }
  glTexCoord4iv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord4iv", "Int",  v)
  }
  glTexCoord4sv(byref v) {
    Return DllCall("opengl32.dll\glTexCoord4sv", "Short",  v)
  }
  glRasterPos2d(x, y) {
    Return DllCall("opengl32.dll\glRasterPos2d", "Double", x, "Double", y)
  }
  glRasterPos2f(x, y) {
    Return DllCall("opengl32.dll\glRasterPos2f", "Float", x, "Float", y)
  }
  glRasterPos2i(x, y) {
    Return DllCall("opengl32.dll\glRasterPos2i", "Int", x, "Int", y)
  }
  glRasterPos2s(x, y) {
    Return DllCall("opengl32.dll\glRasterPos2s", "Short", x, "Short", y)
  }
  glRasterPos3d(x, y, z) {
    Return DllCall("opengl32.dll\glRasterPos3d", "Double", x, "Double", y, "Double", z)
  }
  glRasterPos3f(x, y, z) {
    Return DllCall("opengl32.dll\glRasterPos3f", "Float", x, "Float", y, "Float", z)
  }
  glRasterPos3i(x, y, z) {
    Return DllCall("opengl32.dll\glRasterPos3i", "Int", x, "Int", y, "Int", z)
  }
  glRasterPos3s(x, y, z) {
    Return DllCall("opengl32.dll\glRasterPos3s", "Short", x, "Short", y, "Short", z)
  }
  glRasterPos4d(x, y, z, w) {
    Return DllCall("opengl32.dll\glRasterPos4d", "Double", x, "Double", y, "Double", z, "Double", w)
  }
  glRasterPos4f(x, y, z, w) {
    Return DllCall("opengl32.dll\glRasterPos4f", "Float", x, "Float", y, "Float", z, "Float", w)
  }
  glRasterPos4i(x, y, z, w) {
    Return DllCall("opengl32.dll\glRasterPos4i", "Int", x, "Int", y, "Int", z, "Int", w)
  }
  glRasterPos4s(x, y, z, w) {
    Return DllCall("opengl32.dll\glRasterPos4s", "Short", x, "Short", y, "Short", z, "Short", w)
  }
  glRasterPos2dv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos2dv", "Double",  v)
  }
  glRasterPos2fv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos2fv", "Float",  v)
  }
  glRasterPos2iv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos2iv", "Int",  v)
  }
  glRasterPos2sv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos2sv", "Short",  v)
  }
  glRasterPos3dv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos3dv", "Double",  v)
  }
  glRasterPos3fv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos3fv", "Float",  v)
  }
  glRasterPos3iv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos3iv", "Int",  v)
  }
  glRasterPos3sv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos3sv", "Short",  v)
  }
  glRasterPos4dv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos4dv", "Double",  v)
  }
  glRasterPos4fv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos4fv", "Float",  v)
  }
  glRasterPos4iv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos4iv", "Int",  v)
  }
  glRasterPos4sv(byref v) {
    Return DllCall("opengl32.dll\glRasterPos4sv", "Short",  v)
  }
  glRectd(x1, y1, x2, y2) {
    Return DllCall("opengl32.dll\glRectd", "Double", x1, "Double", y1, "Double", x2, "Double", y2)
  }
  glRectf(x1, y1, x2, y2) {
    Return DllCall("opengl32.dll\glRectf", "Float", x1, "Float", y1, "Float", x2, "Float", y2)
  }
  glRecti(x1, y1, x2, y2) {
    Return DllCall("opengl32.dll\glRecti", "Int", x1, "Int", y1, "Int", x2, "Int", y2)
  }
  glRects(x1, y1, x2, y2) {
    Return DllCall("opengl32.dll\glRects", "Short", x1, "Short", y1, "Short", x2, "Short", y2)
  }
  glRectdv(byref v1, v2) {
    Return DllCall("opengl32.dll\glRectdv", "Double",  v1, "Double",  v2)
  }
  glRectfv(byref v1, v2) {
    Return DllCall("opengl32.dll\glRectfv", "Float",  v1, "Float",  v2)
  }
  glRectiv(byref v1, v2) {
    Return DllCall("opengl32.dll\glRectiv", "Int",  v1, "Int",  v2)
  }
  glRectsv(byref v1, v2) {
    Return DllCall("opengl32.dll\glRectsv", "Short",  v1, "Short",  v2)
  }
  
  glShadeModel(mode) {
    Return DllCall("opengl32.dll\glShadeModel", "UInt", mode)
  }
  glLightf(light, pname, param) {
    Return DllCall("opengl32.dll\glLightf", "UInt", light, "UInt", pname, "Float", param)
  }
  glLighti(light, pname, param) {
    Return DllCall("opengl32.dll\glLighti", "UInt", light, "UInt", pname, "Int", param)
  }
  glLightfv(light, pname, params) {
    Return DllCall("opengl32.dll\glLightfv", "UInt", light, "UInt", pname, "Float",  params)
  }
  glLightiv(light, pname, params) {
    Return DllCall("opengl32.dll\glLightiv", "UInt", light, "UInt", pname, "Int",  params)
  }
  glGetLightfv(light, pname, params) {
    Return DllCall("opengl32.dll\glGetLightfv", "UInt", light, "UInt", pname, "Float",  params)
  }
  glGetLightiv(light, pname, params) {
    Return DllCall("opengl32.dll\glGetLightiv", "UInt", light, "UInt", pname, "Int",  params)
  }
  glLightModelf(pname, param) {
    Return DllCall("opengl32.dll\glLightModelf", "UInt", pname, "Float", param)
  }
  glLightModeli(pname, param) {
    Return DllCall("opengl32.dll\glLightModeli", "UInt", pname, "Int", param)
  }
  glLightModelfv(pname, params) {
    Return DllCall("opengl32.dll\glLightModelfv", "UInt", pname, "Float",  params)
  }
  glLightModeliv(pname, params) {
    Return DllCall("opengl32.dll\glLightModeliv", "UInt", pname, "Int",  params)
  }
  glMaterialf(face, pname, param) {
    Return DllCall("opengl32.dll\glMaterialf", "UInt", face, "UInt", pname, "Float", param)
  }
  glMateriali(face, pname, param) {
    Return DllCall("opengl32.dll\glMateriali", "UInt", face, "UInt", pname, "Int", param)
  }
  glMaterialfv(face, pname, params) {
    Return DllCall("opengl32.dll\glMaterialfv", "UInt", face, "UInt", pname, "Float",  params)
  }
  glMaterialiv(face, pname, params) {
    Return DllCall("opengl32.dll\glMaterialiv", "UInt", face, "UInt", pname, "Int",  params)
  }
  glGetMaterialfv(face, pname, params) {
    Return DllCall("opengl32.dll\glGetMaterialfv", "UInt", face, "UInt", pname, "Float",  params)
  }
  glGetMaterialiv(face, pname, params) {
    Return DllCall("opengl32.dll\glGetMaterialiv", "UInt", face, "UInt", pname, "Int",  params)
  }
  glColorMaterial(face, mode) {
    Return DllCall("opengl32.dll\glColorMaterial", "UInt", face, "UInt", mode)
  }
  
  glPixelZoom(xfactor, yfactor) {
    Return DllCall("opengl32.dll\glPixelZoom", "Float", xfactor, "Float", yfactor)
  }
  glPixelStoref(pname, param) {
    Return DllCall("opengl32.dll\glPixelStoref", "UInt", pname, "Float", param)
  }
  glPixelStorei(pname, param) {
    Return DllCall("opengl32.dll\glPixelStorei", "UInt", pname, "Int", param)
  }
  glPixelTransferf(pname, param) {
    Return DllCall("opengl32.dll\glPixelTransferf", "UInt", pname, "Float", param)
  }
  glPixelTransferi(pname, param) {
    Return DllCall("opengl32.dll\glPixelTransferi", "UInt", pname, "Int", param)
  }
  glPixelMapfv(map, mapsize, values) {
    Return DllCall("opengl32.dll\glPixelMapfv", "UInt", map, "Int", mapsize, "Float",  values)
  }
  glPixelMapuiv(map, mapsize, values) {
    Return DllCall("opengl32.dll\glPixelMapuiv", "UInt", map, "Int", mapsize, "UInt",  values)
  }
  glPixelMapusv(map, mapsize, values) {
    Return DllCall("opengl32.dll\glPixelMapusv", "UInt", map, "Int", mapsize, "UShort",  values)
  }
  glGetPixelMapfv(map, values) {
    Return DllCall("opengl32.dll\glGetPixelMapfv", "UInt", map, "Float",  values)
  }
  glGetPixelMapuiv(map, values) {
    Return DllCall("opengl32.dll\glGetPixelMapuiv", "UInt", map, "UInt",  values)
  }
  glGetPixelMapusv(map, values) {
    Return DllCall("opengl32.dll\glGetPixelMapusv", "UInt", map, "UShort",  values)
  }
  glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap) {
    Return DllCall("opengl32.dll\glBitmap", "Int", width, "Int", height, "Float", xorig, "Float", yorig, "Float", xmove, "Float", ymove, "UChar",  bitmap)
  }
  glReadPixels(x, y, width, height, format, type, pixels) {
    Return DllCall("opengl32.dll\glReadPixels", "Int", x, "Int", y, "Int", width, "Int", height, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glDrawPixels(width, height, format, type, pixels) {
    Return DllCall("opengl32.dll\glDrawPixels", "Int", width, "Int", height, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glCopyPixels(x, y, width, height, type) {
    Return DllCall("opengl32.dll\glCopyPixels", "Int", x, "Int", y, "Int", width, "Int", height, "UInt", type)
  }
  
  glStencilFunc(func, ref, mask) {
    Return DllCall("opengl32.dll\glStencilFunc", "UInt", func, "Int", ref, "UInt", mask)
  }
  glStencilMask(mask) {
    Return DllCall("opengl32.dll\glStencilMask", "UInt", mask)
  }
  glStencilOp(fail, zfail, zpass) {
    Return DllCall("opengl32.dll\glStencilOp", "UInt", fail, "UInt", zfail, "UInt", zpass)
  }
  glClearStencil(s) {
    Return DllCall("opengl32.dll\glClearStencil", "Int", s)
  }
  
  glTexGend(coord, pname, param) {
    Return DllCall("opengl32.dll\glTexGend", "UInt", coord, "UInt", pname, "Double", param)
  }
  glTexGenf(coord, pname, param) {
    Return DllCall("opengl32.dll\glTexGenf", "UInt", coord, "UInt", pname, "Float", param)
  }
  glTexGeni(coord, pname, param) {
    Return DllCall("opengl32.dll\glTexGeni", "UInt", coord, "UInt", pname, "Int", param)
  }
  glTexGendv(coord, pname, params) {
    Return DllCall("opengl32.dll\glTexGendv", "UInt", coord, "UInt", pname, "Double",  params)
  }
  glTexGenfv(coord, pname, params) {
    Return DllCall("opengl32.dll\glTexGenfv", "UInt", coord, "UInt", pname, "Float",  params)
  }
  glTexGeniv(coord, pname, params) {
    Return DllCall("opengl32.dll\glTexGeniv", "UInt", coord, "UInt", pname, "Int",  params)
  }
  glGetTexGendv(coord, pname, params) {
    Return DllCall("opengl32.dll\glGetTexGendv", "UInt", coord, "UInt", pname, "Double",  params)
  }
  glGetTexGenfv(coord, pname, params) {
    Return DllCall("opengl32.dll\glGetTexGenfv", "UInt", coord, "UInt", pname, "Float",  params)
  }
  glGetTexGeniv(coord, pname, params) {
    Return DllCall("opengl32.dll\glGetTexGeniv", "UInt", coord, "UInt", pname, "Int",  params)
  }
  glTexEnvf(target, pname, param) {
    Return DllCall("opengl32.dll\glTexEnvf", "UInt", target, "UInt", pname, "Float", param)
  }
  glTexEnvi(target, pname, param) {
    Return DllCall("opengl32.dll\glTexEnvi", "UInt", target, "UInt", pname, "Int", param)
  }
  glTexEnvfv(target, pname, params) {
    Return DllCall("opengl32.dll\glTexEnvfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glTexEnviv(target, pname, params) {
    Return DllCall("opengl32.dll\glTexEnviv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glGetTexEnvfv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetTexEnvfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glGetTexEnviv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetTexEnviv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glTexParameterf(target, pname, param) {
    Return DllCall("opengl32.dll\glTexParameterf", "UInt", target, "UInt", pname, "Float", param)
  }
  glTexParameteri(target, pname, param) {
    Return DllCall("opengl32.dll\glTexParameteri", "UInt", target, "UInt", pname, "Int", param)
  }
  glTexParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glTexParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glTexParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glTexParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glGetTexParameterfv(target, pname, param) {
    Return DllCall("opengl32.dll\glGetTexParameterfv", "UInt", target, "UInt", pname, "Float",  param)
  }
  glGetTexParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetTexParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glGetTexLevelParameterfv(target, level, pname, params) {
    Return DllCall("opengl32.dll\glGetTexLevelParameterfv", "UInt", target, "Int", level, "UInt", pname, "Float",  params)
  }
  glGetTexLevelParameteriv(target, level, pname, params) {
    Return DllCall("opengl32.dll\glGetTexLevelParameteriv", "UInt", target, "Int", level, "UInt", pname, "Int",  params)
  }
  glTexImage1D(target, level, internalFormat, width, border, format, type, pixels) {
    Return DllCall("opengl32.dll\glTexImage1D", "UInt", target, "Int", level, "Int", internalFormat, "Int", width, "Int", border, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glTexImage2D(target, level, internalFormat, width, height, border, format, type, pixels) {
    Return DllCall("opengl32.dll\glTexImage2D", "UInt", target, "Int", level, "Int", internalFormat, "Int", width, "Int", height, "Int", border, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glGetTexImage(target, level, format, type, pixels) {
    Return DllCall("opengl32.dll\glGetTexImage", "UInt", target, "Int", level, "UInt", format, "UInt", type, "Int",  pixels)
  }
  
  glMap1d(target, u1, u2, stride, order, points) {
    Return DllCall("opengl32.dll\glMap1d", "UInt", target, "Double", u1, "Double", u2, "Int", stride, "Int", order, "Double",  points)
  }
  glMap1f(target, u1, u2, stride, order, points) {
    Return DllCall("opengl32.dll\glMap1f", "UInt", target, "Float", u1, "Float", u2, "Int", stride, "Int", order, "Float",  points)
  }
  glMap2d(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points) {
    Return DllCall("opengl32.dll\glMap2d", "UInt", target, "Double", u1, "Double", u2, "Int", ustride, "Int", uorder, "Double", v1, "Double", v2, "Int", vstride, "Int", vorder, "Double",  points)
  }
  glMap2f(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points) {
    Return DllCall("opengl32.dll\glMap2f", "UInt", target, "Float", u1, "Float", u2, "Int", ustride, "Int", uorder, "Float", v1, "Float", v2, "Int", vstride, "Int", vorder, "Float",  points)
  }
  glGetMapdv(target, query, v) {
    Return DllCall("opengl32.dll\glGetMapdv", "UInt", target, "UInt", query, "Double",  v)
  }
  glGetMapfv(target, query, v) {
    Return DllCall("opengl32.dll\glGetMapfv", "UInt", target, "UInt", query, "Float",  v)
  }
  glGetMapiv(target, query, v) {
    Return DllCall("opengl32.dll\glGetMapiv", "UInt", target, "UInt", query, "Int",  v)
  }
  glEvalCoord1d(u) {
    Return DllCall("opengl32.dll\glEvalCoord1d", "Double", u)
  }
  glEvalCoord1f(u) {
    Return DllCall("opengl32.dll\glEvalCoord1f", "Float", u)
  }
  glEvalCoord1dv(byref u) {
    Return DllCall("opengl32.dll\glEvalCoord1dv", "Double",  u)
  }
  glEvalCoord1fv(byref u) {
    Return DllCall("opengl32.dll\glEvalCoord1fv", "Float",  u)
  }
  glEvalCoord2d(u, v) {
    Return DllCall("opengl32.dll\glEvalCoord2d", "Double", u, "Double", v)
  }
  glEvalCoord2f(u, v) {
    Return DllCall("opengl32.dll\glEvalCoord2f", "Float", u, "Float", v)
  }
  glEvalCoord2dv(byref u) {
    Return DllCall("opengl32.dll\glEvalCoord2dv", "Double",  u)
  }
  glEvalCoord2fv(byref u) {
    Return DllCall("opengl32.dll\glEvalCoord2fv", "Float",  u)
  }
  glMapGrid1d(un, u1, u2) {
    Return DllCall("opengl32.dll\glMapGrid1d", "Int", un, "Double", u1, "Double", u2)
  }
  glMapGrid1f(un, u1, u2) {
    Return DllCall("opengl32.dll\glMapGrid1f", "Int", un, "Float", u1, "Float", u2)
  }
  glMapGrid2d(un, u1, u2, vn, v1, v2) {
    Return DllCall("opengl32.dll\glMapGrid2d", "Int", un, "Double", u1, "Double", u2, "Int", vn, "Double", v1, "Double", v2)
  }
  glMapGrid2f(un, u1, u2, vn, v1, v2) {
    Return DllCall("opengl32.dll\glMapGrid2f", "Int", un, "Float", u1, "Float", u2, "Int", vn, "Float", v1, "Float", v2)
  }
  glEvalPoint1(i) {
    Return DllCall("opengl32.dll\glEvalPoint1", "Int", i)
  }
  glEvalPoint2(i, j) {
    Return DllCall("opengl32.dll\glEvalPoint2", "Int", i, "Int", j)
  }
  glEvalMesh1(mode, i1, i2) {
    Return DllCall("opengl32.dll\glEvalMesh1", "UInt", mode, "Int", i1, "Int", i2)
  }
  glEvalMesh2(mode, i1, i2, j1, j2) {
    Return DllCall("opengl32.dll\glEvalMesh2", "UInt", mode, "Int", i1, "Int", i2, "Int", j1, "Int", j2)
  }
  
  glFogf(pname, param) {
    Return DllCall("opengl32.dll\glFogf", "UInt", pname, "Float", param)
  }
  glFogi(pname, param) {
    Return DllCall("opengl32.dll\glFogi", "UInt", pname, "Int", param)
  }
  glFogfv(pname, params) {
    Return DllCall("opengl32.dll\glFogfv", "UInt", pname, "Float",  params)
  }
  glFogiv(pname, params) {
    Return DllCall("opengl32.dll\glFogiv", "UInt", pname, "Int",  params)
  }
  
  glFeedbackBuffer(size, type, buffer) {
    Return DllCall("opengl32.dll\glFeedbackBuffer", "Int", size, "UInt", type, "Float",  buffer)
  }
  glPassThrough(token) {
    Return DllCall("opengl32.dll\glPassThrough", "Float", token)
  }
  glSelectBuffer(size, buffer) {
    Return DllCall("opengl32.dll\glSelectBuffer", "Int", size, "UInt",  buffer)
  }
  glInitNames() {
    Return DllCall("opengl32.dll\glInitNames", "")
  }
  glLoadName(name) {
    Return DllCall("opengl32.dll\glLoadName", "UInt", name)
  }
  glPushName(name) {
    Return DllCall("opengl32.dll\glPushName", "UInt", name)
  }
  glPopName() {
    Return DllCall("opengl32.dll\glPopName", "")
  }
  
  glGenTextures(n, textures) {
    Return DllCall("opengl32.dll\glGenTextures", "Int", n, "UInt",  textures)
  }
  glDeleteTextures(n, texture) {
    Return DllCall("opengl32.dll\glDeleteTextures", "Int", n, "UInt",  texture)
  }
  glBindTexture(target, texture) {
    Return DllCall("opengl32.dll\glBindTexture", "UInt", target, "UInt", texture)
  }
  glPrioritizeTextures(n, textures, priorities) {
    Return DllCall("opengl32.dll\glPrioritizeTextures", "Int", n, "UInt",  textures, "Float",  priorities)
  }
  glAreTexturesResident(n, textures, residences) {
    Return DllCall("opengl32.dll\glAreTexturesResident", "Int", n, "UInt",  textures, "UChar",  residences)
  }
  glIsTexture(texture) {
    Return DllCall("opengl32.dll\glIsTexture", "UInt", texture)
  }
  
  glTexSubImage1D(target, level, xoffset, width, format, type, pixels) {
    Return DllCall("opengl32.dll\glTexSubImage1D", "UInt", target, "Int", level, "Int", xoffset, "Int", width, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels) {
    Return DllCall("opengl32.dll\glTexSubImage2D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", width, "Int", height, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glCopyTexImage1D(target, level, internalformat, x, y, width, border) {
    Return DllCall("opengl32.dll\glCopyTexImage1D", "UInt", target, "Int", level, "UInt", internalformat, "Int", x, "Int", y, "Int", width, "Int", border)
  }
  glCopyTexImage2D(target, level, internalformat, x, y, width, height, border) {
    Return DllCall("opengl32.dll\glCopyTexImage2D", "UInt", target, "Int", level, "UInt", internalformat, "Int", x, "Int", y, "Int", width, "Int", height, "Int", border)
  }
  glCopyTexSubImage1D(target, level, xoffset, x, y, width) {
    Return DllCall("opengl32.dll\glCopyTexSubImage1D", "UInt", target, "Int", level, "Int", xoffset, "Int", x, "Int", y, "Int", width)
  }
  glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height) {
    Return DllCall("opengl32.dll\glCopyTexSubImage2D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", x, "Int", y, "Int", width, "Int", height)
  }
  
  glVertexPointer(size, type, stride, ptr) {
    Return DllCall("opengl32.dll\glVertexPointer", "Int", size, "UInt", type, "Int", stride, "Int",  ptr)
  }
  glNormalPointer(type, stride, ptr) {
    Return DllCall("opengl32.dll\glNormalPointer", "UInt", type, "Int", stride, "Int",  ptr)
  }
  glColorPointer(size, type, stride, ptr) {
    Return DllCall("opengl32.dll\glColorPointer", "Int", size, "UInt", type, "Int", stride, "Int",  ptr)
  }
  glIndexPointer(type, stride, ptr) {
    Return DllCall("opengl32.dll\glIndexPointer", "UInt", type, "Int", stride, "Int",  ptr)
  }
  glTexCoordPointer(size, type, stride, ptr) {
    Return DllCall("opengl32.dll\glTexCoordPointer", "Int", size, "UInt", type, "Int", stride, "Int",  ptr)
  }
  glEdgeFlagPointer(stride, ptr) {
    Return DllCall("opengl32.dll\glEdgeFlagPointer", "Int", stride, "Int",  ptr)
  }
  glGetPointerv(pname, params) {
    Return DllCall("opengl32.dll\glGetPointerv", "UInt", pname, "Int",  params)
  }
  glArrayElement(i) {
    Return DllCall("opengl32.dll\glArrayElement", "Int", i)
  }
  glDrawArrays(mode, first, count) {
    Return DllCall("opengl32.dll\glDrawArrays", "UInt", mode, "Int", first, "Int", count)
  }
  glDrawElements(mode, count, type, indices) {
    Return DllCall("opengl32.dll\glDrawElements", "UInt", mode, "Int", count, "UInt", type, "Int",  indices)
  }
  glInterleavedArrays(format, stride, pointer) {
    Return DllCall("opengl32.dll\glInterleavedArrays", "UInt", format, "Int", stride, "Int",  pointer)
  }
  
  glDrawRangeElements(mode, start, end, count, type, indices) {
    Return DllCall("opengl32.dll\glDrawRangeElements", "UInt", mode, "UInt", start, "UInt", end, "Int", count, "UInt", type, "Int",  indices)
  }
  glTexImage3D(target, level, internalFormat, width, height, depth, border, format, type, pixels) {
    Return DllCall("opengl32.dll\glTexImage3D", "UInt", target, "Int", level, "UInt", internalFormat, "Int", width, "Int", height, "Int", depth, "Int", border, "UInt", format, "UInt", type, "Int",  pixels)
  }
  glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixel) {
    Return DllCall("opengl32.dll\glTexSubImage3D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", zoffset, "Int", width, "Int", height, "Int", depth, "UInt", format, "UInt", type, "Int",  pixel)
  }
  glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height) {
    Return DllCall("opengl32.dll\glCopyTexSubImage3D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", zoffset, "Int", x, "Int", y, "Int", width, "Int", height)
  }
  
  glColorTable(target, internalformat, width, format, type, table) {
    Return DllCall("opengl32.dll\glColorTable", "UInt", target, "UInt", internalformat, "Int", width, "UInt", format, "UInt", type, "Int",  table)
  }
  glColorSubTable(target, start, count, format, type, data) {
    Return DllCall("opengl32.dll\glColorSubTable", "UInt", target, "Int", start, "Int", count, "UInt", format, "UInt", type, "Int",  data)
  }
  glColorTableParameteriv(target, pname, param) {
    Return DllCall("opengl32.dll\glColorTableParameteriv", "UInt", target, "UInt", pname, "Int",  param)
  }
  glColorTableParameterfv(target, pname, param) {
    Return DllCall("opengl32.dll\glColorTableParameterfv", "UInt", target, "UInt", pname, "Float",  param)
  }
  glCopyColorSubTable(target, start, x, y, width) {
    Return DllCall("opengl32.dll\glCopyColorSubTable", "UInt", target, "Int", start, "Int", x, "Int", y, "Int", width)
  }
  glCopyColorTable(target, internalformat, x, y, width) {
    Return DllCall("opengl32.dll\glCopyColorTable", "UInt", target, "UInt", internalformat, "Int", x, "Int", y, "Int", width)
  }
  glGetColorTable(target, format, type, table) {
    Return DllCall("opengl32.dll\glGetColorTable", "UInt", target, "UInt", format, "UInt", type, "Int",  table)
  }
  glGetColorTableParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetColorTableParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glGetColorTableParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetColorTableParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glBlendEquation(mode) {
    Return DllCall("opengl32.dll\glBlendEquation", "UInt", mode)
  }
  glBlendColor(red, green, blue, alpha) {
    Return DllCall("opengl32.dll\glBlendColor", "Float", red, "Float", green, "Float", blue, "Float", alpha)
  }
  glHistogram(target, width, internalformat, sink) {
    Return DllCall("opengl32.dll\glHistogram", "UInt", target, "Int", width, "UInt", internalformat, "UChar", sink)
  }
  glResetHistogram(target) {
    Return DllCall("opengl32.dll\glResetHistogram", "UInt", target)
  }
  glGetHistogram(target, reset, format, type, values) {
    Return DllCall("opengl32.dll\glGetHistogram", "UInt", target, "UChar", reset, "UInt", format, "UInt", type, "Int",  values)
  }
  glGetHistogramParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetHistogramParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glGetHistogramParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetHistogramParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glMinmax(target, internalformat, sink) {
    Return DllCall("opengl32.dll\glMinmax", "UInt", target, "UInt", internalformat, "UChar", sink)
  }
  glResetMinmax(target) {
    Return DllCall("opengl32.dll\glResetMinmax", "UInt", target)
  }
  glGetMinmax(target, reset, format, types, values) {
    Return DllCall("opengl32.dll\glGetMinmax", "UInt", target, "UChar", reset, "UInt", format, "UInt", types, "Int",  values)
  }
  glGetMinmaxParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetMinmaxParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glGetMinmaxParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetMinmaxParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glConvolutionFilter1D(target, internalformat, width, format, type, image) {
    Return DllCall("opengl32.dll\glConvolutionFilter1D", "UInt", target, "UInt", internalformat, "Int", width, "UInt", format, "UInt", type, "Int",  image)
  }
  glConvolutionFilter2D(target, internalformat, width, height, format, type, image) {
    Return DllCall("opengl32.dll\glConvolutionFilter2D", "UInt", target, "UInt", internalformat, "Int", width, "Int", height, "UInt", format, "UInt", type, "Int",  image)
  }
  glConvolutionParameterf(target, pname, params) {
    Return DllCall("opengl32.dll\glConvolutionParameterf", "UInt", target, "UInt", pname, "Float", params)
  }
  glConvolutionParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glConvolutionParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glConvolutionParameteri(target, pname, params) {
    Return DllCall("opengl32.dll\glConvolutionParameteri", "UInt", target, "UInt", pname, "Int", params)
  }
  glConvolutionParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glConvolutionParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glCopyConvolutionFilter1D(target, internalformat, x, y, width) {
    Return DllCall("opengl32.dll\glCopyConvolutionFilter1D", "UInt", target, "UInt", internalformat, "Int", x, "Int", y, "Int", width)
  }
  glCopyConvolutionFilter2D(target, internalformat, x, y, width, heigh) {
    Return DllCall("opengl32.dll\glCopyConvolutionFilter2D", "UInt", target, "UInt", internalformat, "Int", x, "Int", y, "Int", width, "Int", heigh)
  }
  glGetConvolutionFilter(target, format, type, image) {
    Return DllCall("opengl32.dll\glGetConvolutionFilter", "UInt", target, "UInt", format, "UInt", type, "Int",  image)
  }
  glGetConvolutionParameterfv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetConvolutionParameterfv", "UInt", target, "UInt", pname, "Float",  params)
  }
  glGetConvolutionParameteriv(target, pname, params) {
    Return DllCall("opengl32.dll\glGetConvolutionParameteriv", "UInt", target, "UInt", pname, "Int",  params)
  }
  glSeparableFilter2D(target, internalformat, width, height, format, type, row, column) {
    Return DllCall("opengl32.dll\glSeparableFilter2D", "UInt", target, "UInt", internalformat, "Int", width, "Int", height, "UInt", format, "UInt", type, "Int",  row, "Int",  column)
  }
  glGetSeparableFilter(target, format, type, row, column, span) {
    Return DllCall("opengl32.dll\glGetSeparableFilter", "UInt", target, "UInt", format, "UInt", type, "Int",  row, "Int",  column, "Int",  span)
  }
  
  glActiveTexture(texture) {
    Return DllCall("opengl32.dll\glActiveTexture", "UInt", texture)
  }
  glClientActiveTexture(texture) {
    Return DllCall("opengl32.dll\glClientActiveTexture", "UInt", texture)
  }
  glCompressedTexImage1D(target, level, internalformat, width, border, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexImage1D", "UInt", target, "Int", level, "UInt", internalformat, "Int", width, "Int", border, "Int", imageSize, "Int",  data)
  }
  glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexImage2D", "UInt", target, "Int", level, "UInt", internalformat, "Int", width, "Int", height, "Int", border, "Int", imageSize, "Int",  data)
  }
  glCompressedTexImage3D(target, level, internalformat, width, height, depth, border, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexImage3D", "UInt", target, "Int", level, "UInt", internalformat, "Int", width, "Int", height, "Int", depth, "Int", border, "Int", imageSize, "Int",  data)
  }
  glCompressedTexSubImage1D(target, level, xoffset, width, format, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexSubImage1D", "UInt", target, "Int", level, "Int", xoffset, "Int", width, "UInt", format, "Int", imageSize, "Int",  data)
  }
  glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexSubImage2D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", width, "Int", height, "UInt", format, "Int", imageSize, "Int",  data)
  }
  glCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data) {
    Return DllCall("opengl32.dll\glCompressedTexSubImage3D", "UInt", target, "Int", level, "Int", xoffset, "Int", yoffset, "Int", zoffset, "Int", width, "Int", height, "Int", depth, "UInt", format, "Int", imageSize, "Int",  data)
  }
  glGetCompressedTexImage(target, lod, img) {
    Return DllCall("opengl32.dll\glGetCompressedTexImage", "UInt", target, "Int", lod, "Int",  img)
  }
  glMultiTexCoord1d(target, s) {
    Return DllCall("opengl32.dll\glMultiTexCoord1d", "UInt", target, "Double", s)
  }
  glMultiTexCoord1dv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord1dv", "UInt", target, "Double",  v)
  }
  glMultiTexCoord1f(target, s) {
    Return DllCall("opengl32.dll\glMultiTexCoord1f", "UInt", target, "Float", s)
  }
  glMultiTexCoord1fv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord1fv", "UInt", target, "Float",  v)
  }
  glMultiTexCoord1i(target, s) {
    Return DllCall("opengl32.dll\glMultiTexCoord1i", "UInt", target, "Int", s)
  }
  glMultiTexCoord1iv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord1iv", "UInt", target, "Int",  v)
  }
  glMultiTexCoord1s(target, s) {
    Return DllCall("opengl32.dll\glMultiTexCoord1s", "UInt", target, "Short", s)
  }
  glMultiTexCoord1sv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord1sv", "UInt", target, "Short",  v)
  }
  glMultiTexCoord2d(target, s, t) {
    Return DllCall("opengl32.dll\glMultiTexCoord2d", "UInt", target, "Double", s, "Double", t)
  }
  glMultiTexCoord2dv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord2dv", "UInt", target, "Double",  v)
  }
  glMultiTexCoord2f(target, s, t) {
    Return DllCall("opengl32.dll\glMultiTexCoord2f", "UInt", target, "Float", s, "Float", t)
  }
  glMultiTexCoord2fv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord2fv", "UInt", target, "Float",  v)
  }
  glMultiTexCoord2i(target, s, t) {
    Return DllCall("opengl32.dll\glMultiTexCoord2i", "UInt", target, "Int", s, "Int", t)
  }
  glMultiTexCoord2iv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord2iv", "UInt", target, "Int",  v)
  }
  glMultiTexCoord2s(target, s, t) {
    Return DllCall("opengl32.dll\glMultiTexCoord2s", "UInt", target, "Short", s, "Short", t)
  }
  glMultiTexCoord2sv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord2sv", "UInt", target, "Short",  v)
  }
  glMultiTexCoord3d(target, s, t, r) {
    Return DllCall("opengl32.dll\glMultiTexCoord3d", "UInt", target, "Double", s, "Double", t, "Double", r)
  }
  glMultiTexCoord3dv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord3dv", "UInt", target, "Double",  v)
  }
  glMultiTexCoord3f(target, s, t, r) {
    Return DllCall("opengl32.dll\glMultiTexCoord3f", "UInt", target, "Float", s, "Float", t, "Float", r)
  }
  glMultiTexCoord3fv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord3fv", "UInt", target, "Float",  v)
  }
  glMultiTexCoord3i(target, s, t, r) {
    Return DllCall("opengl32.dll\glMultiTexCoord3i", "UInt", target, "Int", s, "Int", t, "Int", r)
  }
  glMultiTexCoord3iv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord3iv", "UInt", target, "Int",  v)
  }
  glMultiTexCoord3s(target, s, t, r) {
    Return DllCall("opengl32.dll\glMultiTexCoord3s", "UInt", target, "Short", s, "Short", t, "Short", r)
  }
  glMultiTexCoord3sv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord3sv", "UInt", target, "Short",  v)
  }
  glMultiTexCoord4d(target, s, t, r, q) {
    Return DllCall("opengl32.dll\glMultiTexCoord4d", "UInt", target, "Double", s, "Double", t, "Double", r, "Double", q)
  }
  glMultiTexCoord4dv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord4dv", "UInt", target, "Double",  v)
  }
  glMultiTexCoord4f(target, s, t, r, q) {
    Return DllCall("opengl32.dll\glMultiTexCoord4f", "UInt", target, "Float", s, "Float", t, "Float", r, "Float", q)
  }
  glMultiTexCoord4fv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord4fv", "UInt", target, "Float",  v)
  }
  glMultiTexCoord4i(target, s, t, r, q) {
    Return DllCall("opengl32.dll\glMultiTexCoord4i", "UInt", target, "Int", s, "Int", t, "Int", r, "Int", q)
  }
  glMultiTexCoord4iv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord4iv", "UInt", target, "Int",  v)
  }
  glMultiTexCoord4s(target, s, t, r, q) {
    Return DllCall("opengl32.dll\glMultiTexCoord4s", "UInt", target, "Short", s, "Short", t, "Short", r, "Short", q)
  }
  glMultiTexCoord4sv(target, v) {
    Return DllCall("opengl32.dll\glMultiTexCoord4sv", "UInt", target, "Short",  v)
  }
  glLoadTransposeMatrixd(m[16]) {
    Return DllCall("opengl32.dll\glLoadTransposeMatrixd", "Double", m[16])
  }
  glLoadTransposeMatrixf(m[16]) {
    Return DllCall("opengl32.dll\glLoadTransposeMatrixf", "Float", m[16])
  }
  glMultTransposeMatrixd(m[16]) {
    Return DllCall("opengl32.dll\glMultTransposeMatrixd", "Double", m[16])
  }
  glMultTransposeMatrixf(m[16]) {
    Return DllCall("opengl32.dll\glMultTransposeMatrixf", "Float", m[16])
  }
  glSampleCoverage(value, invert) {
    Return DllCall("opengl32.dll\glSampleCoverage", "Float", value, "UChar", invert)
  }
  glSamplePass(pass) {
    Return DllCall("opengl32.dll\glSamplePass", "UInt", pass)
  }