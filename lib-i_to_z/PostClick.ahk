PostClick(x, y, class, title) 
{
  lParam := x & 0xFFFF | (y & 0xFFFF) << 16 
  PostMessage, 0x201, 1, %lParam%, %class%, %title% ;WM_LBUTTONDOWN 
  PostMessage, 0x202, 0, %lParam%, %class%, %title% ;WM_LBUTTONUP 
}