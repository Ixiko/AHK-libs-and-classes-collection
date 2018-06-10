hwndHung(id){
    return dllCall("user32\IsHungAppWindow","Ptr",id)
}