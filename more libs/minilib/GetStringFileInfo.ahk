/*
�v���O�����t�@�C���̐��Ȃǂ��	by���s�点���[�W�Ǘ��l
GetStringFileInfo(fn,type)
	fn
		�t�@�C���p�X���	type
		�ȉ��̉��ꂩ���			CompanyName			����
			FileDescription		��
			FileVersion			�t�@�C���E�o�[�W����
			InternalName		 ����
			LegalCopyright		���쌠
			OriginalFileName	�����t�@�C����
			ProductName			���i��
			ProductVersion		���i�o�[�W����
			Comments			�R�����g
			LegalTrademarks		���W
			PrivateBuild		�ײ��āE��ޏ�
			SpecialBuild		����فE��ޏ�

��MsgBox,% GetStringFileInfo("VERSION.dll","FileDescription")
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
