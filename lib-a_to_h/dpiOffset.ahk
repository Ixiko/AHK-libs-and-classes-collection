dpiOffset(val){
    return A_ScreenDpi=96?0:floor(val*(floor(A_ScreenDpi/96)/100))
}