;https://www.autohotkey.com/boards/viewtopic.php?t=3861

/* EXAMPLE

#Include SGL.ahk
; This is the DEMO authentication code ,
; every  regular SG−Lock user gets its
; own unique authentication code.
AuthentCode := Struct("UInt[12]",[0xF574D17B,0xA94628EE,0xF2857A8F,0x69346B4A,0x4136E8F2,0x89ADC688,0x80C2C1D4,0xA8C6327C,0x1A72699A,0x574B7CA0,0x1E8D3E98,0xD7DEFDC5])

If (SGL_SUCCESS!=ReturnValue:=SglAuthent(AuthentCode))
	MsgBox, 0, Error, Fehler bei SglAuthent = %ReturnValue%



*/

/****************************************************************************
 SGLW32.H / 11.2005 / MS-WINDOWS W32 (95/98/ME/NT/2000/XP)

 2005 (C) SG Intec Ltd & Co KG

*******************************************************************************/
*/
global SGL_SUCCESS                       :=  0x0000
			,SGL_DGL_NOT_FOUND                 :=  0x0001
			,SGL_LPT_BUSY                      :=  0x0002
			,SGL_LPT_OPEN_ERROR                :=  0x0003
			,SGL_NO_LPT_PORT_FOUND             :=  0x0004
			,SGL_AUTHENTICATION_REQUIRED       :=  0x0005
			,SGL_AUTHENTICATION_FAILED         :=  0x0006
			,SGL_FUNCTION_NOT_SUPPORTED        :=  0x0007
			,SGL_PARAMETER_INVALID             :=  0x0008
			,SGL_SIGNATURE_INVALID             :=  0x0009
			,SGL_USB_BUSY                      :=  0x000A


/*******************************************************************/
/*                                                                 */
/*  SG-Lock API basic functions (supported by all SG-Lock moduls)  */
/*                                                                 */
/*******************************************************************/
 */  

#DllImport SglSearchLock, SglW32.dll\SglSearchLock, UInt, 0, UINT
#DllImport SglReadSerialNumber, SglW32.dll\SglReadSerialNumber, UInt, 0, PTR, 0, UINT
#DllImport SglReadProductId, SglW32.dll\SglReadProductId, PTR, 0, UINT
#DllImport SglWriteProductId, SglW32.dll\SglWriteProductId, UINT, 0, UINT, 0, UINT

/*******************************************************************/
/*                                                                 */
/*  SG-Lock API extended functions (supported only by L3,L4,U3,U4) */
/*                                                                 */
/*******************************************************************/
*/
#DllImport SglReadData, SglW32.dll\SglReadData, UINT, 0, UINT, 0, UINT, 0, PTR, 0, UINT
#DllImport SglWriteData, SglW32.dll\SglWriteData, UINT, 0, UINT, 0, UINT, 0, PTR, 0, UINT
#DllImport SglReadCounter, SglW32.dll\SglReadCounter, UINT, 0, UINT, 0, PTR, 0, UINT
#DllImport SglWriteCounter, SglW32.dll\SglWriteCounter, UINT, 0, UINT, 0, UINT, 0, UINT
#DllImport SglCryptLock, SglW32.dll\SglCryptLock, UINT, 0, UINT, 0, UINT, 0, UINT, 0, PTR, 0, UINT


; Values valid for parameter MODE of Sign functions
global SGL_SIGNATURE_GENERATE         := 0
			 ,SGL_SIGNATURE_VERIFY          := 1
#DllImport SglWriteKey, SglW32.dll\SglWriteKey, UINT, 0, UINT, 0, PTR, 0, UINT
#DllImport SglReadConfig, SglW32.dll\SglReadConfig, UINT, 0, UINT, 0, PTR, 0, UINT

; possible parameters for 'Category'
global SGL_READ_CONFIG_LOCK_INFO         := 0x0000    ; version of dongle hardware
; possible returns    
; Data[0] = ModelId ( see below )
			,SGL_CONFIG_LOCK_SERIES_2          := 0x0001
			,SGL_CONFIG_LOCK_SERIES_3          := 0x0002
			,SGL_CONFIG_LOCK_SERIES_4          := 0x0003
   
; Data[1] = Interface ( see below )  
			,SGL_CONFIG_INTERFACE_USB          := 0x0000
			,SGL_CONFIG_INTERFACE_LPT          := 0x0001

; Data[2] = Software Version of SG-Lock ( high word = major version, low word = minor version )
; Data[3] = Hardware Version of SG-Lock ( high word = major version, low word = minor version ) 
; Data[4] = Serial Number
; Data[5] = Memory Size ( size of memory in DWords !!)
; Data[6] = Counter Count
; Data[7] = 128 bit Key Count

/*******************************************************************/
/*                                                                 */
/*           End of SG-Lock API functions                          */
/*                                                                 */
/*******************************************************************/

/*******************************************************************/
/* helping functions that have to be included, but should not be   */
/* called directly from SG-Lock using application                  */
/*******************************************************************/
*/

#DllImport SglAuthentA, SglW32.dll\SglAuthentA, PTR, 0, PTR, 0, PTR, 0, UINT
#DllImport SglAuthentB, SglW32.dll\SglAuthentB, PTR, 0, UINT

SglAuthent(AuthentCode ) {
	static RandNum := Struct("UInt[2]"),AppRandNum := Struct("UInt[2]"),LibRandNum := Struct("UInt[2]")
				,AuthentCodeLocal := Struct("UInt[8]")

  Loop 8
    AuthentCodeLocal[A_Index] := AuthentCode[A_Index]
    ,AuthentCode[A_Index] := (DllCall("msvcrt\rand")<<16) | DllCall("msvcrt\rand")
  
  DllCall("msvcrt\srand","UInt",AuthentCode[1])
  ,RandNum[1] := (DllCall("msvcrt\rand")<<16) | DllCall("msvcrt\rand")
  ,RandNum[2] := (DllCall("msvcrt\rand")<<16) | DllCall("msvcrt\rand")

  ,AppRandNum[1] := RandNum[1]
  ,AppRandNum[2] := RandNum[2]
  
  RetCode := SglAuthentA(AuthentCodeLocal[],AppRandNum[],LibRandNum[])

  AuthentCode[] := AuthentCodeLocal

  if (RetCode != SGL_SUCCESS)
      return SGL_AUTHENTICATION_FAILED
  
  SglTeaEncipher( RandNum, RandNum, AuthentCode )

  if (RandNum[1] != AppRandNum[1] || RandNum[2] != AppRandNum[2] )
      return SGL_AUTHENTICATION_FAILED

  SglTeaEncipher( LibRandNum,LibRandNum, AuthentCode )
  
  RetCode := SglAuthentB(LibRandNum[])

  if (RetCode != SGL_SUCCESS)
      return SGL_AUTHENTICATION_FAILED
  
  return SGL_SUCCESS
}

; Signing functions

SglSignData( ProductId,AppSignKey,LockSignKeyNum,Mode,LockSignInterval,DataLen,Data,Signature ) {
   return SglSignDataComb(ProductId,AppSignKey,LockSignKeyNum,Mode,LockSignInterval,DataLen,Data,Signature )
}

global SGL_SIGN_DATA_INITVECTOR_1   := 0xC4F8424E
			,SGL_SIGN_DATA_INITVECTOR_2   := 0xAB99A60C
			,SGL_SIGN_DATA_FILLUPDATA     := 0xF6A67A11

SglSignDataApp(SignKey,Mode,DataLen,Data,Signature ) {
   static FeedBackRegister := Struct("UInt[2]")
   if (DataLen = 0)
      return SGL_PARAMETER_INVALID
   
   FeedBackRegister[1] := SGL_SIGN_DATA_INITVECTOR_1
   FeedBackRegister[2] := SGL_SIGN_DATA_INITVECTOR_2
   
   DataIndexMax := DataLen - 1
   While % DataIndexMax>i:=(A_Index-1)*2
      FeedBackRegister[1] := Data[i+1]   ^ FeedBackRegister[1]
      ,FeedBackRegister[2] := Data[i+2] ^ FeedBackRegister[2]
      ,SglTeaEncipher( FeedBackRegister, FeedBackRegister, SignKey )

   if (Mod(DataLen,2)=1)
      FeedBackRegister[1] := Data[i] ^ FeedBackRegister[1]
      ,FeedBackRegister[2] := SGL_SIGN_DATA_FILLUPDATA ^ FeedBackRegister[2]
      ,SglTeaEncipher( FeedBackRegister, FeedBackRegister, SignKey )

   if (Mode=SGL_SIGNATURE_GENERATE)
         return SGL_SUCCESS,Signature[1] := FeedBackRegister[1],Signature[2] := FeedBackRegister[2]
		else if  (Mode = SGL_SIGNATURE_VERIFY) {
         if (Signature[1] = FeedBackRegister[1] && Signature[2] = FeedBackRegister[2])
            return SGL_SUCCESS
         else
            return SGL_SIGNATURE_INVALID
		} else	
      return SGL_PARAMETER_INVALID

}

SglSignDataLock(ProductId,SignKeyNum,Mode,DataLen,Data,Signature ) {
   static FeedBackRegister := Struct("Uint[2]")

   if (DataLen = 0)
      return SGL_PARAMETER_INVALID
   
   FeedBackRegister[1] := SGL_SIGN_DATA_INITVECTOR_1
   ,FeedBackRegister[2] := SGL_SIGN_DATA_INITVECTOR_2
   
   DataIndexMax := DataLen - 1
   While % DataIndexMax>i:=(A_Index-1)*2 {
      FeedBackRegister[1]:= Data[i+1]   ^ FeedBackRegister[1]
      ,FeedBackRegister[2]= Data[i+2] ^ FeedBackRegister[2]
			,RetCode := SglCryptLock(ProductId,SignKeyNum,0,1,FeedBackRegister[])
      if (RetCode != SGL_SUCCESS)
         return RetCode
   }

   if (Mod(DataLen,2)=1) {
      FeedBackRegister[1] := Data[i+1] ^ FeedBackRegister[1]
      ,FeedBackRegister[2] := SGL_SIGN_DATA_FILLUPDATA ^ FeedBackRegister[2]

      ,RetCode := SglCryptLock(ProductId,SignKeyNum,0,1,FeedBackRegister[])

      if (RetCode != SGL_SUCCESS)
         return RetCode
   }

   if (Mode = SGL_SIGNATURE_GENERATE)
         return SGL_SUCCESS, Signature[1] := FeedBackRegister[1],Signature[2] := FeedBackRegister[2]
	 else if (Mode = SGL_SIGNATURE_VERIFY) {
         if (Signature[1] = FeedBackRegister[1] && Signature[2] = FeedBackRegister[2])
            return SGL_SUCCESS
         else 
            return SGL_SIGNATURE_INVALID
   } else return SGL_PARAMETER_INVALID
}

SglSignDataComb(ProductId,AppSignKey,LockSignKeyNum,Mode,LockSignInterval,DataLen,Data,Signature){
	 static FeedBackRegister := Struct("UInt[2]")
   
   if (DataLen = 0)
      return SGL_PARAMETER_INVALID
   
   if (LockSignInterval = 0)
      return SGL_PARAMETER_INVALID
   
   DataIndexMax := DataLen - 1
   ,Interval := 0x01 << LockSignInterval
   
   ,FeedBackRegister[1] := SGL_SIGN_DATA_INITVECTOR_1
   ,FeedBackRegister[2] := SGL_SIGN_DATA_INITVECTOR_2
   
   While % (DataIndexMax>i:=(A_Index-1)*2) {
      FeedBackRegister[1] := Data[i+1]   ^ FeedBackRegister[1]
      FeedBackRegister[2] = Data[i+2] ^ FeedBackRegister[2]

      if (Mod(i,Interval) = 0) {
         if (SGL_SUCCESS != RetCode := SglCryptLock(ProductId,LockSignKeyNum,0,1,FeedBackRegister[]))
            return RetCode
      } else
         SglTeaEncipher( FeedBackRegister, FeedBackRegister, AppSignKey )
   }

   if  (Mod(DataLen,2)=1)  {
      FeedBackRegister[1] := Data[i+1] ^ FeedBackRegister[1]
      ,FeedBackRegister[2] := SGL_SIGN_DATA_FILLUPDATA ^ FeedBackRegister[2]
      if (Mod(i,Interval) = 0) {
         if (SGL_SUCCESS != RetCode := SglCryptLock(ProductId,LockSignKeyNum,0,1,FeedBackRegister[]))
            return RetCode
      } else
         SglTeaEncipher( FeedBackRegister, FeedBackRegister, AppSignKey )
   }

   if (Mode = SGL_SIGNATURE_GENERATE)
         return SGL_SUCCESS,Signature[1] := FeedBackRegister[1],Signature[2] := FeedBackRegister[2]
   else if (Mode = SGL_SIGNATURE_VERIFY) {
         if (Signature[1] = FeedBackRegister[1] && Signature[2] = FeedBackRegister[2])
            return SGL_SUCCESS
         else 
            return SGL_SIGNATURE_INVALID
	 } else 
      return SGL_PARAMETER_INVALID
}

SglTeaEncipher(InData,OutData,Key) {
    static delta:=0x9E3779B9
    y:=InData[1]
    ,z:=InData[2]
    ,sum:=0
    ,a:=Key[9]
    ,b:=Key[10]
    ,c:=Key[11]
    ,d:=Key[12]
    ,n:=32
    
    while( n-->0 ) {
        sum += delta
        ,y += (z << 4)+a ^ z+sum ^ (z >> 5)+b
        ,z += (y << 4)+c ^ y+sum ^ (y >> 5)+d
    }
    OutData[1]:=y
    ,OutData[2]:=z
}

SglTeaDecipher(InData,OutData,Key) {
    static delta:=0x9E3779B9
    y:=InData[1]
    ,z:=InData[2]
    ,sum:=0xC6EF3720
    ,a:=Key[9]
    ,b:=Key[10]
    ,c:=Key[11]
    ,d:=Key[12]
    ,n:=32

    ; sum = delta<<5, in general sum = delta * n
    while( n-->0 ) {
        z -= (y << 4)+c ^ y+sum ^ (y >> 5)+d
        ,y -= (z << 4)+a ^ z+sum ^ (z >> 5)+b
        ,sum -= delta
    }
    OutData[1]:=y
    OutData[2]:=z
}