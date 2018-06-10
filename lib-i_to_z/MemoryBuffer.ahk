/*
* Abstraction of basic memory buffer handling
*
*/
class MemoryBuffer
{
   static HEAP_NO_SERIALIZE          := 0x00000001
   static HEAP_GENERATE_EXCEPTIONS    := 0x00000004
   static HEAP_ZERO_MEMORY          := 0x00000008
   static HEAP_CREATE_ENABLE_EXECUTE    := 0x00040000
   
   static Heap := 0   ; Heap handle
   Address    := 0   ; lp to our buffer
   Size       := 0   ; size of the buffer
      
   
   /*
   * Creates a new MemoryBuffer from the existing buffer
   *
   * srcPtr   pointer to the source
   * size      size of the source
   */
   Create(srcPtr, size)
   {   
      buf := new MemoryBuffer()
      buf.AllocMemory( size )
      buf.memcpy( buf.Address, srcPtr, size )
      
      return buf
   }
   
   /*
   *  Creates a new MemoryBuffer from the given file
   */
   CreateFromFile(filePath){
      
      buf := new MemoryBuffer()
      
      if(!FileExist(filePath))
         throw Exception("File must exist and be readable!")
      
      binFile := FileOpen(filePath, "r")
      buf.AllocMemory(binFile.Length)
      buf.Size := binFile.RawRead(buf.Address+0, binFile.Length)
      
      binFile.Close()
      
      return buf
   }
   
   /*
   * Create a new MemoryBuffer from the given base64 encoded data string
   */
   CreateFromBase64(base64str){
      static CryptStringToBinary := "Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A")
      static CRYPT_STRING_BASE64 := 0x00000001
      
      buf := new MemoryBuffer()
      
      len := StrLen(base64str)
      DllCall(CryptStringToBinary, "ptr",&base64str, "uint", len, "uint", CRYPT_STRING_BASE64, "ptr",0, "uint*",cp, "ptr",0,"ptr",0) ; get size
      buf.AllocMemory(cp)
      DllCall(CryptStringToBinary, "ptr",&base64str, "uint", len, "uint", CRYPT_STRING_BASE64, "ptr", buf.Address, "uint*",cp, "ptr",0,"ptr",0)
      
      return buf
   }
   
   GetPtr(){
      return this.Address
   }
   
   /*
   * Write the binary buffer to a file
   *
   * returns true on succes, otherwise false
   */
   WriteToFile(filePath){
      binFile := FileOpen(filePath, "rw")
      bytesWritten := binFile.RawWrite(this.Address+0, this.Size)
      binFile.Close()
      return (bytesWritten == this.Size) ; we expect that all bytes were written down
   }
   


   
   /*
   * Free this Buffer, releases the reserved memory
   */
   Free(){
      if(this.IsValid())
      {
         DllCall("HeapFree"
                  , Ptr, this.Heap
                  , Ptr, 0
                  , Ptr, this.Address)
                  
            this.Address := 0
            this.Size := 0
      }
   }
   
   /*
   * Is this Buffer a valid allocation of memory?
   */
   IsValid(){
      return (this.Heap != 0 && this.Address != 0)
   }
   
   /*
   * Returns a base64 encoded string of this buffer
   */
   ToBase64(){
      static CryptBinaryToString := "Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A")
      static CRYPT_STRING_BASE64 := 0x00000001
      
      DllCall(CryptBinaryToString, "ptr",this.Address, "uint",this.Size, "uint",CRYPT_STRING_BASE64, "ptr",0, "uint*",cp) ; get size
      VarSetCapacity(str, cp*(A_IsUnicode ? 2:1))
      DllCall(CryptBinaryToString, "ptr",this.Address, "uint",this.Size, "uint",CRYPT_STRING_BASE64, "str",str, "uint*",cp)
      
      return str
   }
   


   /*
   * Destructor
   */
   __Delete()
    {
        this.Free()
    }
   

   ToString(){
      return "MemoryBuffer: @ " this.GetPtr() " size: " this.Size " bytes"
   }
   

   memcpy(dst, src, cnt) {
      return DllCall("MSVCRT\memcpy"
                  , Ptr, dst
                  , Ptr, src
                  , Ptr, cnt)
   }
   

   /*
   * Allocates the requested size of memory
   * returns the base adress of the new reserved memory
   */
   AllocMemory(size){

      if(!MemoryBuffer.Heap)
      {
         ;MemoryBuffer.Heap :=  DllCall("GetProcessHeap", Ptr)
         
         MemoryBuffer.Heap :=  DllCall("HeapCreate"
                           , UInt, 0            ; heap options
                           , Ptr,  0            ; initital size: 0 = 1 page
                           , Ptr,    0, Ptr)         ; max size: 0 = no limit
      }
      
      if(!this.Address)
         this.Free()

      this.Address := DllCall("HeapAlloc"
                  , Ptr,  MemoryBuffer.Heap
                  , UInt, MemoryBuffer.HEAP_ZERO_MEMORY
                  , Ptr,    size, Ptr)
      this.Size := size            
      ;MsgBox  % "allocated " size " bytes memory @" this.Address
   }

}