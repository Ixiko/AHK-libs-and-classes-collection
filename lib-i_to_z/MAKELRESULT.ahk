MAKELRESULT(a, b){
  return (ToShort(a) & 0xffff) | (ToShort(b) & 0xffff) << 16
}