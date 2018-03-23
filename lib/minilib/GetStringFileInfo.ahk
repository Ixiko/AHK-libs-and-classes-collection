/*
プログラムファイルの説明などを取得	by流行らせるページ管理人
GetStringFileInfo(fn,type)
	fn
		ファイルパスを指定
	type
		以下の何れかを指定
			CompanyName			会社名
			FileDescription		説明
			FileVersion			ファイル・バージョン
			InternalName		 内部名
			LegalCopyright		著作権
			OriginalFileName	正式ファイル名
			ProductName			製品名
			ProductVersion		製品バージョン
			Comments			コメント
			LegalTrademarks		商標
			PrivateBuild		ﾌﾟﾗｲﾍﾞｰﾄ・ﾋﾞﾙﾄﾞ情報
			SpecialBuild		ｽﾍﾟｼｬﾙ・ﾋﾞﾙﾄﾞ情報

例
MsgBox,% GetStringFileInfo("VERSION.dll","FileDescription")
*/
GetStringFileInfo(fn,type){
	len:=DllCall("VERSION.dll\GetFileVersionInfoSizeA",Str,fn, UIntP,h,	UInt)
	vbuf:=DllCall("GlobalAlloc",UInt,0x40,UInt,len,UInt)
	DllCall("VERSION.dll\GetFileVersionInfoA",Str,fn, UInt,h, UInt,len,	UInt,vbuf)

	DllCall("VERSION.dll\VerQueryValueA",UInt,vbuf,	Str,"\VarFileInfo\Translation",	UIntP,inf, UIntP,l)
	DllCall("RtlMoveMemory", UIntP,val,	UInt,inf, Int,l, Int)
	SetFormat,Integer,H
	val+=0x100000000
	StringMid,l1,val,8,4
	StringMid,l2,val,4,4
	locale=%l1%%l2%
	StringUpper,locale,locale

	q=\StringFileInfo\%locale%\%type%
	DllCall("VERSION.dll\VerQueryValueA",UInt,vbuf,	Str,q, UIntP,inf, UIntP,l)
	VarSetCapacity(buf,l)
	DllCall("RtlMoveMemory", Str,buf, UInt,inf,	Int,l)
	DllCall("GlobalFree",UInt,vbuf)
	return buf
}
