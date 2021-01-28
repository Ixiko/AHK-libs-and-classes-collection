class OpenCV {

	__New() {
		this.Libs := new this.Libs(this)
		this.error := this.__Init.error
	}

	class Constants {
		static PI := 3.1415926535897932384626433832795
		static LOG2 := 0.69314718055994530941723212145818
		static AUTO_STEP := 0x7fffffff
		static DEFAULT := 0

		static LOAD_IMAGE_UNCHANGED := -1
		static LOAD_IMAGE_GRAYSCALE := 0
		static LOAD_IMAGE_COLOR := 1
		static LOAD_IMAGE_ANYDEPTH := 2
		static LOAD_IMAGE_ANYCOLOR := 4

		; These 4 flags are used by cvSet/GetWindowProperty
		static WND_PROP_FULLSCREEN := 0 	; to change/get window's fullscreen property
		static WND_PROP_AUTOSIZE := 1 		; to change/get window's autosize property
		static WND_PROP_ASPECTRATIO := 2 	; to change/get window's aspectratio property
		static WND_PROP_OPENGL := 3 		; to change/get window's opengl support

		; These 3 flags are used by cvNamedWindow and cvSet/GetWindowProperty
		static WINDOW_NORMAL := 0x00000000		; the user can resize the window (no constraint)  / also use to switch a fullscreen window to a normal size
		static WINDOW_AUTOSIZE := 0x00000001	; the user cannot resize the window, the size is constrainted by the image displayed
		static WINDOW_OPENGL := 0x00001000		; window with opengl support

		; Those flags are only for Qt
		static GUI_EXPANDED := 0x00000000	; status bar and tool bar
		static GUI_NORMAL := 0x00000010	; old fashious way

		; These 3 flags are used by cvNamedWindow and cvSet/GetWindowProperty
		static WINDOW_FULLSCREEN := 1			; change the window to fullscreen
		static WINDOW_FREERATIO := 0x00000100	; the image expends as much as it can (no ratio constraint)
		static WINDOW_KEEPRATIO := 0x00000000	; the ration image is respected.

		; Video Files and Cameras types and parameters
		static CAP_PROP_POS_MSEC := 0
		static CAP_PROP_POS_FRAMES := 1
		static CAP_PROP_POS_AVI_RATIO := 2
		static CAP_PROP_FRAME_WIDTH := 3
		static CAP_PROP_FRAME_HEIGHT := 4
		static CAP_PROP_FPS := 5
		static CAP_PROP_FOURCC := 6
		static CAP_PROP_FRAME_COUNT := 7
		static CAP_PROP_FORMAT := 8
		static CAP_PROP_MODE := 9
		static CAP_PROP_BRIGHTNESS := 10
		static CAP_PROP_CONTRAST := 11
		static CAP_PROP_SATURATION := 12
		static CAP_PROP_HUE := 13
		static CAP_PROP_GAIN := 14
		static CAP_PROP_EXPOSURE := 15
		static CAP_PROP_CONVERT_RGB := 16
		static CAP_PROP_WHITE_BALANCE_BLUE_U := 17
		static CAP_PROP_RECTIFICATION := 18
		static CAP_PROP_MONOCROME := 19
		static CAP_PROP_SHARPNESS := 20
		static CAP_PROP_AUTO_EXPOSURE := 21
		static CAP_PROP_GAMMA := 22
		static CAP_PROP_TEMPERATURE := 23
		static CAP_PROP_TRIGGER := 24
		static CAP_PROP_TRIGGER_DELAY := 25
		static CAP_PROP_WHITE_BALANCE_RED_V := 26
		static CAP_PROP_ZOOM := 27
		static CAP_PROP_FOCUS := 28
		static CAP_PROP_GUID := 29
		static CAP_PROP_ISO_SPEED := 30
		static CAP_PROP_MAX_DC1394 := 31
		static CAP_PROP_BACKLIGHT := 32
		static CAP_PROP_PAN := 33
		static CAP_PROP_TILT := 34
		static CAP_PROP_ROLL := 35
		static CAP_PROP_IRIS := 36
		static CAP_PROP_SETTINGS := 37

		; Different constant used by opencv for selecting webcam ie. dshow web cam index would be 700, 701, 702, etc...
		static CAP_ANY := 0 ;     // autodetect
		static CAP_MIL := 100 ;   // MIL proprietary drivers
		static CAP_VFW := 200 ;   // platform native
		static CAP_V4L := 200 ;
		static CAP_V4L2 := 200 ;
		static CAP_FIREWARE := 300 ;   // IEEE 1394 drivers
		static CAP_FIREWIRE := 300 ;
		static CAP_IEEE1394 := 300 ;
		static CAP_DC1394 := 300 ;
		static CAP_CMU1394 := 300 ;
		static CAP_STEREO := 400 ;   // TYZX proprietary drivers
		static CAP_TYZX := 400 ;
		static TYZX_LEFT := 400 ;
		static TYZX_RIGHT := 401 ;
		static TYZX_COLOR := 402 ;
		static TYZX_Z := 403 ;
		static CAP_QT := 500 ;   // QuickTime
		static CAP_UNICAP := 600 ;   // Unicap drivers
		static CAP_DSHOW := 700 ;   // DirectShow (via videoInput)
		static CAP_MSMF := 1400 ;  // Microsoft Media Foundation (via videoInput)
		static CAP_PVAPI := 800 ;   // PvAPI, Prosilica GigE SDK
		static CAP_OPENNI := 900 ;   // OpenNI (for Kinect)
		static CAP_OPENNI_ASUS := 910 ;   // OpenNI (for Asus Xtion)
		static CAP_ANDROID := 1000 ;  // Android
		static CAP_XIAPI := 1100 ;   // XIMEA Camera API
		static CAP_AVFOUNDATION := 1200 ;  // AVFoundation framework for iOS (OS X Lion will have the same API)
		static CAP_GIGANETIX := 1300 ;  // Smartek Giganetix GigEVisionSDK

		;/* Image smooth methods */
		static BLUR_NO_SCALE := 0
		static BLUR := 1
		static GAUSSIAN := 2
		static MEDIAN := 3
		static BILATERAL := 4

		; image types
		static IPL_DEPTH_SIGN := 0x80000000

		static IPL_DEPTH_1U := 1
		static IPL_DEPTH_8U := 8
		static IPL_DEPTH_16U := 16
		static IPL_DEPTH_32F := 32

		static IPL_DEPTH_8S := 0x80000000 | 8
		static IPL_DEPTH_16S := 0x80000000 | 16
		static IPL_DEPTH_32S := 0x80000000 | 32

		; CV channel types
		static 8UC1 := 0
		static 8UC2 := 8
		static 8UC3 := 16
		static 8UC4 := 24

		static 8SC1 := 1
		static 8SC2 := 9
		static 8SC3 := 17
		static 8SC4 := 25

		static 16UC1 := 2
		static 16UC2 := 10
		static 16UC3 := 18
		static 16UC4 := 26

		static 16SC1 := 3
		static 16SC2 := 11
		static 16SC3 := 19
		static 16SC4 := 27

		static 32SC1 := 3
		static 32SC2 := 12
		static 32SC3 := 20
		static 32SC4 := 28

		static 32FC1 := 5
		static 32FC2 := 13
		static 32FC3 := 21
		static 32FC4 := 29

		static 64FC1 := 6
		static 64FC2 := 14
		static 64FC3 := 22
		static 64FC4 := 30

		; Mouse
		static EVENT_MOUSEMOVE := 0
		static EVENT_LBUTTONDOWN := 1
		static EVENT_RBUTTONDOWN := 2
		static EVENT_MBUTTONDOWN := 3
		static EVENT_LBUTTONUP := 4
		static EVENT_RBUTTONUP := 5
		static EVENT_MBUTTONUP := 6
		static EVENT_LBUTTONDBLCLK := 7
		static EVENT_RBUTTONDBLCLK := 8
		static EVENT_MBUTTONDBLCLK := 9

		static EVENT_FLAG_LBUTTON := 1
		static EVENT_FLAG_RBUTTON := 2
		static EVENT_FLAG_MBUTTON := 4
		static EVENT_FLAG_CTRLKEY := 8
		static EVENT_FLAG_SHIFTKEY := 16
		static EVENT_FLAG_ALTKEY := 32

		; Save file image format
		static IMWRITE_JPEG_QUALITY := 1
		static IMWRITE_PNG_COMPRESSION := 16
		static IMWRITE_PNG_STRATEGY := 17
		static IMWRITE_PNG_BILEVEL := 18
		static IMWRITE_PNG_STRATEGY_DEFAULT := 0
		static IMWRITE_PNG_STRATEGY_FILTERED := 1
		static IMWRITE_PNG_STRATEGY_HUFFMAN_ONLY := 2
		static IMWRITE_PNG_STRATEGY_RLE := 3
		static IMWRITE_PNG_STRATEGY_FIXED := 4
		static IMWRITE_PXM_BINARY := 32

		; cvConvertImage flip types
		static CVTIMG_FLIP := 1
		static CVTIMG_SWAP_RB := 2

		; compare operation
		static CMP_EQ := 0
		static CMP_GT := 1
		static CMP_GE := 2
		static CMP_LT := 3
		static CMP_LE := 4
		static CMP_NE := 5

		; cvSort flags
		static SORT_EVERY_ROW := 0
		static SORT_EVERY_COLUMN := 1
		static SORT_ASCENDING := 0
		static SORT_DESCENDING := 16

		;/* types of array norm */
		static C := 1
		static L1 := 2
		static L2 := 4
		static NORM_MASK := 7
		static RELATIVE := 8
		static DIFF := 16
		static MINMAX := 32

		static DIFF_C := 16 | 1
		static DIFF_L1 := 16 | 2
		static DIFF_L2 := 16 | 4
		static RELATIVE_C := 8 | 1
		static RELATIVE_L1 := 8 | 2
		static RELATIVE_L2 := 8 | 4

		;/*********************************** CPU capabilities ***********************************/

		static CPU_NONE := 0
		static CPU_MMX := 1
		static CPU_SSE := 2
		static CPU_SSE2 := 3
		static CPU_SSE3 := 4
		static CPU_SSSE3 := 5
		static CPU_SSE4_1 := 6
		static CPU_SSE4_2 := 7
		static CPU_POPCNT := 8
		static CPU_AVX := 10
		static HARDWARE_MAX_FEATURE := 255

		; cvFindChessBoard flag

		static CALIB_CB_ADAPTIVE_THRESH := 1
		static CALIB_CB_NORMALIZE_IMAGE := 2
		static CALIB_CB_FILTER_QUADS := 4
		static CALIB_CB_FAST_CHECK := 8

		static CALIB_USE_INTRINSIC_GUESS := 1
		static CALIB_FIX_ASPECT_RATIO := 2
		static CALIB_FIX_PRINCIPAL_POINT := 4
		static CALIB_ZERO_TANGENT_DIST := 8
		static CALIB_FIX_FOCAL_LENGTH := 16
		static CALIB_FIX_K1 := 32
		static CALIB_FIX_K2 := 64
		static CALIB_FIX_K3 := 128
		static CALIB_FIX_K4 := 2048
		static CALIB_FIX_K5 := 4096
		static CALIB_FIX_K6 := 8192
		static CALIB_RATIONAL_MODEL := 16384

		;/* Filters used in pyramid decomposition */

		static GAUSSIAN_5x5 := 7

		;/* Special filters */


		static SCHARR := -1
		static MAX_SOBEL_KSIZE := 7

		;/* Constants for color conversion */


		static BGR2BGRA := 0
		static RGB2RGBA := 0

		static BGRA2BGR := 1
		static RGBA2RGB := 1

		static BGR2RGBA := 2
		static RGB2BGRA := 2

		static RGBA2BGR := 3
		static BGRA2RGB := 3

		static BGR2RGB := 4
		static RGB2BGR := 4

		static BGRA2RGBA := 5
		static RGBA2BGRA := 5

		static BGR2GRAY := 6
		static RGB2GRAY := 7
		static GRAY2BGR := 8
		static GRAY2RGB := 8
		static GRAY2BGRA := 9
		static GRAY2RGBA := 9
		static BGRA2GRAY := 10
		static RGBA2GRAY := 11

		static BGR2BGR565 := 12
		static RGB2BGR565 := 13
		static BGR5652BGR := 14
		static BGR5652RGB := 15
		static BGRA2BGR565 := 16
		static RGBA2BGR565 := 17
		static BGR5652BGRA := 18
		static BGR5652RGBA := 19

		static GRAY2BGR565 := 20
		static BGR5652GRAY := 21

		static BGR2BGR555 := 22
		static RGB2BGR555 := 23
		static BGR5552BGR := 24
		static BGR5552RGB := 25
		static BGRA2BGR555 := 26
		static RGBA2BGR555 := 27
		static BGR5552BGRA := 28
		static BGR5552RGBA := 29

		static GRAY2BGR555 := 30
		static BGR5552GRAY := 31

		static BGR2XYZ := 32
		static RGB2XYZ := 33
		static XYZ2BGR := 34
		static XYZ2RGB := 35

		static BGR2YCrCb := 36
		static RGB2YCrCb := 37
		static YCrCb2BGR := 38
		static YCrCb2RGB := 39

		static BGR2HSV := 40
		static RGB2HSV := 41

		static BGR2Lab := 44
		static RGB2Lab := 45

		static BayerBG2BGR := 46
		static BayerGB2BGR := 47
		static BayerRG2BGR := 48
		static BayerGR2BGR := 49

		static BayerBG2RGB := 48
		static BayerGB2RGB := 49
		static BayerRG2RGB := 46
		static BayerGR2RGB := 47

		static BGR2Luv := 50
		static RGB2Luv := 51
		static BGR2HLS := 52
		static RGB2HLS := 53

		static HSV2BGR := 54
		static HSV2RGB := 55

		static Lab2BGR := 56
		static Lab2RGB := 57
		static Luv2BGR := 58
		static Luv2RGB := 59
		static HLS2BGR := 60
		static HLS2RGB := 61

		static BayerBG2BGR_VNG := 62
		static BayerGB2BGR_VNG := 63
		static BayerRG2BGR_VNG := 64
		static BayerGR2BGR_VNG := 65

		static BayerBG2RGB_VNG := 64
		static BayerGB2RGB_VNG := 65
		static BayerRG2RGB_VNG := 62
		static BayerGR2RGB_VNG := 63

		static BGR2HSV_FULL := 66
		static RGB2HSV_FULL := 67
		static BGR2HLS_FULL := 68
		static RGB2HLS_FULL := 69

		static HSV2BGR_FULL := 70
		static HSV2RGB_FULL := 71
		static HLS2BGR_FULL := 72
		static HLS2RGB_FULL := 73

		static LBGR2Lab := 74
		static LRGB2Lab := 75
		static LBGR2Luv := 76
		static LRGB2Luv := 77

		static Lab2LBGR := 78
		static Lab2LRGB := 79
		static Luv2LBGR := 80
		static Luv2LRGB := 81

		static BGR2YUV := 82
		static RGB2YUV := 83
		static YUV2BGR := 84
		static YUV2RGB := 85

		static BayerBG2GRAY := 86
		static BayerGB2GRAY := 87
		static BayerRG2GRAY := 88
		static BayerGR2GRAY := 89

		;    //YUV 4:2:0 formats family
		static YUV2RGB_NV12 := 90
		static YUV2BGR_NV12 := 91
		static YUV2RGB_NV21 := 92
		static YUV2BGR_NV21 := 93
		static YUV420sp2RGB := 92
		static YUV420sp2BGR := 93

		static YUV2RGBA_NV12 := 94
		static YUV2BGRA_NV12 := 95
		static YUV2RGBA_NV21 := 96
		static YUV2BGRA_NV21 := 97
		static YUV420sp2RGBA := 96
		static YUV420sp2BGRA := 97

		static YUV2RGB_YV12 := 98
		static YUV2BGR_YV12 := 99
		static YUV2RGB_IYUV := 100
		static YUV2BGR_IYUV := 101
		static YUV2RGB_I420 := 100
		static YUV2BGR_I420 := 101
		static YUV420p2RGB := 98
		static YUV420p2BGR := 99

		static YUV2RGBA_YV12 := 102
		static YUV2BGRA_YV12 := 103
		static YUV2RGBA_IYUV := 104
		static YUV2BGRA_IYUV := 105
		static YUV2RGBA_I420 := 104
		static YUV2BGRA_I420 := 105
		static YUV420p2RGBA := 102
		static YUV420p2BGRA := 103

		static YUV2GRAY_420 := 106
		static YUV2GRAY_NV21 := 106
		static YUV2GRAY_NV12 := 106
		static YUV2GRAY_YV12 := 106
		static YUV2GRAY_IYUV := 106
		static YUV2GRAY_I420 := 106
		static YUV420sp2GRAY := 106
		static YUV420p2GRAY := 106

		;    //YUV 4:2:2 formats family
		static YUV2RGB_UYVY := 107
		static YUV2BGR_UYVY := 108
		;   //YUV2RGB_VYUY := 109
		;    //YUV2BGR_VYUY := 110
		static YUV2RGB_Y422 := 107
		static YUV2BGR_Y422 := 108
		static YUV2RGB_UYNV := 107
		static YUV2BGR_UYNV := 108

		static YUV2RGBA_UYVY := 111
		static YUV2BGRA_UYVY := 112
		;    //YUV2RGBA_VYUY := 113
		;    //YUV2BGRA_VYUY := 114
		static YUV2RGBA_Y422 := 111
		static YUV2BGRA_Y422 := 112
		static YUV2RGBA_UYNV := 111
		static YUV2BGRA_UYNV := 112

		static YUV2RGB_YUY2 := 115
		static YUV2BGR_YUY2 := 116
		static YUV2RGB_YVYU := 117
		static YUV2BGR_YVYU := 118
		static YUV2RGB_YUYV := 115
		static YUV2BGR_YUYV := 116
		static YUV2RGB_YUNV := 115
		static YUV2BGR_YUNV := 116

		static YUV2RGBA_YUY2 := 119
		static YUV2BGRA_YUY2 := 120
		static YUV2RGBA_YVYU := 121
		static YUV2BGRA_YVYU := 122
		static YUV2RGBA_YUYV := 119
		static YUV2BGRA_YUYV := 120
		static YUV2RGBA_YUNV := 119
		static YUV2BGRA_YUNV := 120

		static YUV2GRAY_UYVY := 123
		static YUV2GRAY_YUY2 := 124
		;    //YUV2GRAY_VYUY := 123
		static YUV2GRAY_Y422 := 123
		static YUV2GRAY_UYNV := 123
		static YUV2GRAY_YVYU := 124
		static YUV2GRAY_YUYV := 124
		static YUV2GRAY_YUNV := 124

		;    // alpha premultiplication
		static RGBA2mRGBA := 125
		static mRGBA2RGBA := 126

		static RGB2YUV_I420 := 127
		static BGR2YUV_I420 := 128
		static RGB2YUV_IYUV := 127
		static BGR2YUV_IYUV := 128

		static RGBA2YUV_I420 := 129
		static BGRA2YUV_I420 := 130
		static RGBA2YUV_IYUV := 129
		static BGRA2YUV_IYUV := 130
		static RGB2YUV_YV12 := 131
		static BGR2YUV_YV12 := 132
		static RGBA2YUV_YV12 := 133
		static BGRA2YUV_YV12 := 134

		static COLORCVT_MAX := 135


		;/* Sub-pixel interpolation methods */


		static INTER_NN := 0
		static INTER_LINEAR := 1
		static INTER_CUBIC := 2
		static INTER_AREA := 3
		static INTER_LANCZOS4 := 4


		;/* ... and other image warping flags */


		static WARP_FILL_OUTLIERS := 8
		static WARP_INVERSE_MAP := 16


		;/* Shapes of a structuring element for morphological operations */


		static SHAPE_RECT := 0
		static SHAPE_CROSS := 1
		static SHAPE_ELLIPSE := 2
		static SHAPE_CUSTOM := 100


		;/* Morphological operations */


		static MOP_ERODE := 0
		static MOP_DILATE := 1
		static MOP_OPEN := 2
		static MOP_CLOSE := 3
		static MOP_GRADIENT := 4
		static MOP_TOPHAT := 5
		static MOP_BLACKHAT := 6

		;/* Template matching methods */

		static TM_SQDIFF := 0
		static TM_SQDIFF_NORMED := 1
		static TM_CCORR := 2
		static TM_CCORR_NORMED := 3
		static TM_CCOEFF := 4
		static TM_CCOEFF_NORMED := 5

		;/* Contour retrieval modes */

		static RETR_EXTERNAL := 0
		static RETR_LIST := 1
		static RETR_CCOMP := 2
		static RETR_TREE := 3
		static RETR_FLOODFILL := 4

		;/* Contour approximation methods */

		static CHAIN_CODE := 0
		static CHAIN_APPROX_NONE := 1
		static CHAIN_APPROX_SIMPLE := 2
		static CHAIN_APPROX_TC89_L1 := 3
		static CHAIN_APPROX_TC89_KCOS := 4
		static LINK_RUNS := 5

		;/* Histogram comparison methods */

		static COMP_CORREL := 0
		static COMP_CHISQR := 1
		static COMP_INTERSECT := 2
		static COMP_BHATTACHARYYA := 3
		static COMP_HELLINGER := 3

		;/* Mask size for distance transform */

		static DIST_MASK_3 := 3
		static DIST_MASK_5 := 5
		static DIST_MASK_PRECISE := 0

		;/* Content of output label array: connected components or pixels */

		static DIST_LABEL_CCOMP := 0
		static DIST_LABEL_PIXEL := 1

		;/* Distance types for Distance Transform and M-estimators */

		static DIST_USER := -1  ;/* User defined distance */
		static DIST_L1 := 1   ;/* distance = |x1-x2| + |y1-y2| */
		static DIST_L2 := 2   ;/* the simple euclidean distance */
		static DIST_C := 3   ;/* distance = max(|x1-x2||y1-y2|) */
		static DIST_L12 := 4   ;/* L1-L2 metric: distance = 2(sqrt(1+x*x/2) - 1)) */
		static DIST_FAIR := 5   ;/* distance = c^2(|x|/c-log(1+|x|/c)) c = 1.3998 */
		static DIST_WELSCH := 6   ;/* distance = c^2/2(1-exp(-(x/c)^2)) c = 2.9846 */
		static DIST_HUBER := 7    ;/* distance = |x|<c ? x^2/2 : c(|x|-c/2) c=1.345 */

		;/* Threshold types */

		static THRESH_BINARY := 0  ;/* value = value > threshold ? max_value : 0       */
		static THRESH_BINARY_INV := 1  ;/* value = value > threshold ? 0 : max_value       */
		static THRESH_TRUNC := 2  ;/* value = value > threshold ? threshold : value   */
		static THRESH_TOZERO := 3  ;/* value = value > threshold ? value : 0           */
		static THRESH_TOZERO_INV := 4  ;/* value = value > threshold ? 0 : value           */
		static THRESH_MASK := 7
		static THRESH_OTSU := 8  ;/* use Otsu algorithm to choose the optimal threshold value;
												;   combine the flag with one of the above THRESH_* values */

		;/* Adaptive threshold methods */

		static ADAPTIVE_THRESH_MEAN_C := 0
		static ADAPTIVE_THRESH_GAUSSIAN_C := 1

		;/* FloodFill flags */

		static FLOODFILL_FIXED_RANGE := 1 << -16
		static FLOODFILL_MASK_ONLY := 1 << -17

		;/* Variants of a Hough transform */

		static HOUGH_STANDARD := 0
		static HOUGH_PROBABILISTIC := 1
		static HOUGH_MULTI_SCALE := 2
		static HOUGH_GRADIENT := 3

		;/* For font */
		static FONT_LIGHT := 25 ;//QFont::Light,
		static FONT_NORMAL := 50 ;//QFont::Normal,
		static FONT_DEMIBOLD := 63 ;//QFont::DemiBold,
		static FONT_BOLD := 75 ;//QFont::Bold,
		static FONT_BLACK := 87 ;//QFont::Black

		static STYLE_NORMAL := 0 ;//QFont::StyleNormal,
		static STYLE_ITALIC := 1 ;//QFont::StyleItalic,
		static STYLE_OBLIQUE := 2 ;//QFont::StyleOblique

		; type of button
		static PUSH_BUTTON := 0
		static CHECKBOX := 1
		static RADIOBOX := 2

		static TERMCRIT_ITER := 1
		static TERMCRIT_NUMBER := 1
		static TERMCRIT_EPS := 2

		;/* Contour approximation algorithms */

		static POLY_APPROX_DP := 0
	}

	class Libs {
		static path := "\Lib\DLL"
		static libraries := {max
		(Join,
			opencv_core: "opencv_core2413.dll"
			opencv_highgui: "opencv_highgui2413.dll"
			opencv_imgproc: "opencv_imgproc2413.dll"
			opencv_objdetect: "opencv_objdetect2413.dll"
		)}

		__New(parent) {
			this.generateCallMethods(parent)
		}

		__Call(method, args*) {
			if (method == "call") {
				if (IsObject(args[2])) ; Remove passed 'this' inside 'call' function
					args.RemoveAt(2)
				return this.Call(args*)
			}
		}

		generateCallMethods(ctx) {
			for libName, dllName in this.libraries {
				ctx[libName] := ObjBindMethod(this, "call", libName)
			}
		}

		getDLL(libName) {
			return this.libraries[libName]
		}

		call(libName, fnName, params*) {
			return DllCall(this.getDLL(libName) . "\" . fnName, params*)
		}

		load() {
			static OriginalWorkingDir := A_ScriptDir
			SetWorkingDir % OriginalWorkingDir . this.path
			for libName, dllName in this.libraries {
				If !FileExist(thisdll := OriginalWorkingDir . this.path . "\" . dllName) {
					throw % "dll not exist: " thisdll
					ExitApp
				}
				dllp := DllCall("LoadLibrary", "Str", thisdll, "Ptr")
				If (dllp = 0) {
					throw % "Can't load dll (" A_LastError ")`n" thisdll
					ExitApp
				}
			}
			SetWorkingDir % OriginalWorkingDir
		}

		unload() {
			for libName, dllName in this.libraries
				if (hModule := DllCall("GetModuleHandle", "str", dllName))
					DllCall("FreeLibrary", "ptr", hModule)
		}
	}

	class __Init {
		static _ := OpenCV.__Init := new OpenCV.__Init()

		__New() {
			OpenCV.Libs.load()
			OnExit(ObjBindMethod(OpenCV.Libs, "unload"))
		}

		error(additionalMsg := "")	{
			Tooltip % additionalMsg
			stackTrace := (A_ThisFunc "`n" ErrorLevel)
			errorCode := "`nLastError - " A_LastError
			if ErrorLevel
				MsgBox % additionalMsg . " " . stackTrace . " " . errorCode
			return ErrorLevel
		}
	}

	__wrapAround(result := "") {
		this._error()
		return result
	}

	BmpToIPL(pBitmap) {
		if (!IsFunc("Gdip_GetImageDimensions")) {
			MsgBox % "BmpToIPL >> GDI+ Library is missing!"
			return
		}

		Func("Gdip_GetImageDimensions").Call(pBitmap, iW, iH)
		tBitmapData := Func("Gdip_LockBits").Call(pBitmap, 0, 0, iW, iH, Stride, Scan0, BitmapData)
		pIPL := this.CreateImageHeader(this.Size(iW, iH), 8, 4)
		this.SetData(pIPL, Scan0, Stride)
		Func("Gdip_UnlockBits").Call(pBitmap, tBitmapData)
		return pIPL
	}

	Load(cvfilename, cvmemstorage := 0, cvname := 0, cvreal_name := 0) {
		result := this.opencv_core("cvLoad", "AStr", cvfilename, "ptr", cvmemstorage, "ptr", cvname, "ptr", cvreal_name, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	NamedWindow(name, flags := 0x00000001) {
		result := this.opencv_highgui("cvNamedWindow", "AStr", name, "int", flags, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	LoadImage(filename, iscolor := 1) {
		result := this.opencv_highgui("cvLoadImage", "AStr", filename, "int", iscolor, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	ShowImage(name, pimage) {
		result := this.opencv_highgui("cvShowImage", "AStr", name, "ptr", pimage, "Cdecl")
		return this.__wrapAround(result)
	}

	CreateImage(cvsize, cvdepth, cvchannels) {
		result :=  this.opencv_core("cvCreateImage", "int64", cvsize, "int", cvdepth, "int", cvchannels, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	CreateImageHeader(cvsize, cvdepth, cvchannels) {
		result := this.opencv_core("cvCreateImageHeader", "int64", cvsize, "int", cvdepth, "int", cvchannels, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	CreateMat(cvrows, cvcols, cvtype) {
		result := this.opencv_core("cvCreateMat", "int", cvrows, "int", cvcols, "int", cvtype, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	MatchTemplate(cvimage, cvtempl, cvresult, cvmethod) {
		result := this.opencv_imgproc("cvMatchTemplate", "ptr", cvimage, "ptr", cvtempl, "ptr", cvresult, "int", cvmethod, "Cdecl")
		return this.__wrapAround(result)
	}

	Normalize(cvsrc, cvdst, cva, cvb, cvnorm_type, cvmask) {
		result := this.opencv_core("cvNormalize", "ptr", cvsrc, "ptr", cvdst, "Double", cva, "Double", cvb, "int", cvnorm_type, "ptr", cvmask, "Cdecl")
		return this.__wrapAround(result)
	}

	Threshold(cvsrc, cvdst, cvthreshold, cvmax_value, cvthreshold_type) {
		result := this.opencv_imgproc("cvThreshold", "ptr", cvsrc, "ptr", cvdst, "Double", cvthreshold, "Double", cvmax_value, "int", cvthreshold_type, "Cdecl double")
		return this.__wrapAround(result)
	}

	ArrTohBitmap(pimage, byref width = "", byref height = "") {
		result := this.CreateImage(this.GetSize(pimage, width, height), 8, 4)
		this.CvtColor(pimage, Result, 0)
		pData := NumGet(Result + 0, 68 + 20 * (A_PtrSize = 8), "Ptr")
		hBitmap := DllCall("CreateBitmap", "Int", width, "Int", height, "UInt", 1, "UInt", 32, "Ptr", pData)
		Return this.__wrapAround(hBitmap), this.ReleaseImage(result)
	}

	Scalar(value) {
		VarSetCapacity(vScalar, 32, 0)
		if IsObject(value) {
			Loop 4
			NumPut(value%A_Index%, vScalar, (A_Index - 1) * 8, "double")
		} else {
			Loop 4
			NumPut(value, vScalar, (A_Index - 1) * 8, "double")
		}
		return this.__wrapAround(&vScalar)
	}

	Set(cvarr, cvvalue, cvmask := 0) {
		if (A_PtrSize = 4)
			result := this.opencv_core("cvSet", "ptr", cvarr, "double", NumGet(cvvalue+0, 0, "double"), "double", NumGet(cvvalue+0, 8, "double"), "double", NumGet(cvvalue+0, 16, "double"), "double", NumGet(cvvalue+0, 24, "double"), "ptr", cvmask, "Cdecl")
		else
			result := this.opencv_core("cvSet", "ptr", cvarr, "ptr", cvvalue, "ptr", cvmask, "Cdecl")
		return this.__wrapAround(result)
	}

	GetSize(pimage, ByRef width := 0, ByRef height := 0) {
		WidthHeight := this.opencv_core("cvGetSize", "ptr", pimage, "Cdecl int64")

		width := 0xFFFFFFFF & WidthHeight
		height := WidthHeight >> 32

		return this.__wrapAround(WidthHeight)
	}

	Size(width, height) {
	   return this.__wrapAround(width & 0xFFFFFFFF | height << 32)
	}

	CvtColor(cvsrc, cvdst, cvcode) {
		result := this.opencv_imgproc("cvCvtColor", "ptr", cvsrc, "ptr", cvdst, "int", cvcode, "Cdecl")
		return this.__wrapAround(result)
	}

	Resize(cvsrc, cvdst, cvinterpolation := 1) {
		result := this.opencv_imgproc("cvResize", "ptr", cvsrc, "ptr", cvdst, "int", cvinterpolation, "Cdecl")
		return this.__wrapAround(result)
	}

	EqualizeHist(cvsrc, cvdst) {
		result := this.opencv_imgproc("cvEqualizeHist", "ptr", cvsrc, "ptr", cvdst, "Cdecl")
		return this.__wrapAround(result)
	}

	CreateMemStorage(cvblock_size) {
		result := this.opencv_core("cvCreateMemStorage", "int", cvblock_size, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	ClearMemStorage(cvstorage) {
	   result := this.opencv_core("cvClearMemStorage", "ptr", cvstorage, "Cdecl")
	   return this.__wrapAround(result)
	}

	HaarDetectObjects(cvimage, cvcascade, cvstorage, cvscale_factor := 1.1, cvmin_neighbors := 3, cvflags := 0, cvmin_size := 0, cvmax_size := 0) {
		result := this.opencv_objdetect("cvHaarDetectObjects", "ptr", cvimage, "ptr", cvcascade, "ptr", cvstorage, "double", cvscale_factor, "int", cvmin_neighbors, "int", cvflags, "int64", cvmin_size, "int64", cvmax_size, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	GetSeqElem(cvseq, cvindex) {
		result := this.opencv_core("cvGetSeqElem", "ptr", cvseq, "int", cvindex, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	Rectangle(cvimg, cvpt1, cvpt2, cvcolor, cvthickness, cvline_type, cvshift) {
		if (A_PtrSize = 4)
			result := this.opencv_core("cvRectangle", "ptr", cvimg, "int64", cvpt1, "int64", cvpt2, "double", NumGet(cvcolor+0, 0, "double"), "double", NumGet(cvcolor+0, 8, "double"), "double", NumGet(cvcolor+0, 16, "double"), "double", NumGet(cvcolor+0, 24, "double"), "int", cvthickness, "int", cvline_type, "int", cvshift, "Cdecl")
		else
			result := this.opencv_core("cvRectangle", "ptr", cvimg, "int64", cvpt1, "int64", cvpt2, "ptr", cvcolor, "int", cvthickness, "int", cvline_type, "int", cvshift, "Cdecl")
		return this.__wrapAround(result)
	}

	ReleaseImage(pimage) {
		result := this.opencv_core("cvReleaseImage", "ptr*", pimage, "Cdecl")
		return this.__wrapAround(result)
	}

	DestroyAllWindows() {
		result := this.opencv_highgui("cvDestroyAllWindows", "Cdecl")
		return this.__wrapAround(result)
	}

	ClearSeq(cvseq) {
		result := this.opencv_core("cvClearSeq", "ptr", cvseq, "Cdecl")
		return this.__wrapAround(result)
	}

	Point(x, y) {
		return this.__wrapAround(x & 0xFFFFFFFF | y << 32)
	}

	RGB(cvRed, cvGreen, cvBlue) {
		VarSetCapacity(vScalar, 32, 0)
		NumPut(cvBlue, vScalar, 0, "double")
		NumPut(cvGreen, vScalar, 8, "double")
		NumPut(cvRed, vScalar, 16, "double")
		NumPut(0, vScalar, 24, "double")
		return this.__wrapAround(&vScalar)
	}

	SetData(cvarr, data, step) {
		result := this.opencv_core("cvSetData", "ptr", cvarr, "ptr", data, "int", step, "Cdecl")
		return this.__wrapAround(result)
	}

	MinMaxLoc(cvarr, cvmin_val, cvmax_val, cvmin_loc, cvmax_loc, cvmask) {
		result := this.opencv_core("cvMinMaxLoc", "ptr", cvarr, "ptr", cvmin_val, "ptr", cvmax_val, "ptr", cvmin_loc, "ptr", cvmax_loc, "ptr", cvmask, "Cdecl")
		return this.__wrapAround(result)
	}

	CloneImage(pimage) {
		result := this.opencv_core("cvCloneImage", "ptr", pimage, "Cdecl ptr")
		return this.__wrapAround(result)
	}

	ReleaseImageHeader(pimage) {
		result := this.opencv_core("cvReleaseImageHeader", "ptr*", pimage, "Cdecl")
		return this.__wrapAround(result)
	}

	ReleaseMat(cvmat) {
		result := this.opencv_core("cvReleaseMat", "ptr*", cvmat, "Cdecl")
		return this.__wrapAround(result)
	}
}