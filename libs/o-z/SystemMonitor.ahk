/*
�V�X�e�����j�^�p�֐��Q	by���s�点���[�W�Ǘ��l


���擾�ł��镨
�V�X�e���S�̂�PU�g�p��
    GetCPUState
�V�X�e���S�̂̃��������e�ʁA�󂫗e��
    GetMemoryState
�o�b�e���̏�A�c��
    GetSystemPowerStatus
�v���Z�X���Ƃ�PU�g�p��
    GetProcessCPUState
�v���Z�X���Ƃ̃������g�p��
    GetProcessMemoryState
�l�b�g���[�N�̑�����x(B/s)
�V�X�e���N���������l�b�g���[�N���]����Bytes)
    OpenNetworkMonitor
    GetNetWorkMonitor
    CloseNetworkMonitor
�p�t�H�[�}���X���j�^�Ŏ擾�ł�������
    SelectCounter
    OpenCounter
    GetCounter
    CloseCounter





���֐��d�l

���V�X�e���S�̗p
GetCPUState(period=0)
  �w�肵�����Ԃ̃V�X�e���S�̂�PU�g�p���������  ����
    period
      �v�����鎞�Ԃ���b�Ŏw��      �����Ŏw�肵�����Ԃ����A�֐���Sleep����      0(�ȗ���)�́A�O��������獡����̊Ԃ�PU�g�p�����擾����
  �Ԃ�
    �w�肵�����Ԃ̊Ԃ�PU�g�p�������

GetMemoryState(type=0,mode=1)
  �V�X�e���S�̂̃������g�p�ʂ����e�ʂ������  ����
    type
      0 ����������
      1 �y�[�W�t�@�C��
      2 ���z�A�h���X��
    mode
      0 ���e��
      1 �󂫗e��
  �Ԃ�
    �v�����ꂽ�l(Bytes)

GetSystemPowerStatus(type=0)
  �m�[�gPC�Ȃǂ̃o�b�e���[����ʂ������  ����
    type
      �擾����������        0 �o�b�e���[�̗L���Ə���
          �Ԃ��͈ȉ��̕��ɂȂ�            0 �o�b�e���[����
            1 ���d��
            2 �[�d��
            3 AC�d���g�p��
        1 �o�b�e���[�̎c�ʂ��擾(�s���̎�255)
        2 �o�b�e���[�̎c�������(�擾�s�\�̎�0xFFFFFFFF)
        3 �o�b�e���[�̍ő������(�擾�s�\�̎�0xFFFFFFFF)
  �Ԃ�
    �擾�����l

��������Z�X�p
GetProcessCPUState(pid,period=0)
  �w�����Z�X��PU�g�p���������  ����
    pid
      �v���Z�XID(WinGet,var,PID�ȂǂŎ擾�ł���
    period
      �v�����鎞�Ԃ���b�Ŏw��      �����Ŏw�肵�����Ԃ����A�֐���Sleep����      0(�ȗ���)�́A�O��������獡����̊Ԃ�PU�g�p�����擾����
  �Ԃ�
    �w�肵�����Ԃ̊Ԃ�PU�g�p�������


GetProcessMemoryState(pid,type=8)
  �w�����Z�X�̃������g�p��������  ����
    pid
      �v���Z�XID(WinGet,var,PID�ȂǂŎ擾�ł���
    type
      1 �y�[�W�t�H���g�J�E���g
      2 ���[�L���O�Z�b�g�ō��l
      3 ���[�L���O�Z�b�g���ݒl
      4 �y�[�W�v�[���ő�
      5 �y�[�W�v�[�����ݒl
      6 ��[�W�v�[���ő�
      7 ��[�W�v�[�����ݒl
      8 ���z�������T�C�Y���ݒl(�f�t�H���g)
      9 ���z�������T�C�Y�ő�
  �Ԃ�
    �擾�����l


���l�b�g���[�N���j�^�[
�擾�����l�͈ȉ��̃O���[�o���ϐ��Ɋi�[����
Network_InPS
    1�b��������f�[�^��B/s)
Network_OutPS
    1�b���������M�f�[�^��B/s)
Network_In
    �V�X�e���N����������f�[�^����
Network_Out
    �V�X�e���N�����������M�f�[�^����
NumNetwork
    �l�b�g���[�N�C���^�[�t�F�C�X�̐�
Network_1_InPS
Network_1_OutPS
Network_1_In
Network_1_Out
    �l�b�g���[�N�C���^�[�t�F�C�X�ʂ̐��l


OpenNetworkMonitor()
  �l�b�g���[�N���j�^�[�̏��������

GetNetWorkMonitor(period=0)
  �l�b�g���[�N���j�^�[�̒l��V����  ����
    period
      �v�����鎞�Ԃ���b�Ŏw��      �����Ŏw�肵�����Ԃ����A�֐���Sleep����      0(�ȗ���)�́A�O��������獡����̊Ԃ�/s�ɂȂ�
CloseNetworkMonitor()
  �l�b�g���[�N���j�^�[������ADLL�ƍ\���̂������


���p�t�H�[�}���X�J�E���^�[
�p�t�H�[�}���X�J�E���^�[�ł́A�l�X�ȏ�����ł���
�擾���������̓J�E���^�[���Ŏw�肷��
SelectCounter�֐���p�����A���p�\�ȃJ�E���^�[��C�A���O�őI��āA
�J�E���^�[������ł���
�J�E���^�[���̗����ẮA�ȉ��̂悤�ȕ�������

\LogicalDisk(_Total)\% Disk Read Time
    �f�B�X�N���ǂݍ��݂��Ă������Ԃ̊���
\LogicalDisk(_Total)\% Disk Write Time
    �f�B�X�N���������݂��Ă������Ԃ̊���
\LogicalDisk(_Total)\% Disk Time
    �f�B�X�N�ɃA�N�Z�X���Ă������Ԃ̊���
\LogicalDisk(_Total)\% Idle Time
    �f�B�X�N�ɃA�N�Z�X���Ă��Ȃ�������Ԃ̊���

�u_Total�v�̑����uD:�v�̂悤�ȃh���C�u����������DD�̂��B
Disk Time+Idle Time ��00�ɂȂ��͌�����B
�X�N���v�g���ɋL�q�������́A�u%�v��%�v�ƃG�X�P�[�v���Ȃ����Ȃ����ꍇ�����邱�Ƃɒ��ӁB

�J�E���^�[����s�����񋓂�������nCounter�̈����ɓn���ēo�^����
GetCounter��s�����A�O���[�o���ϐ��ɃJ�E���^�[�̒l���i�[�����B
1�s�ڂŎw�肵���J�E���^�[�̒l�́uCounter_1�v�ɁA2�s�ڂ́uCounter_2�v�Ɋi�[�����B



SelectCounter(default="")
  �J�E���^�[�I��C�A���O������A���[�U�[�����͂����J�E���^�[������B
  �_�C�A���O���\�������܂łɐ��b���������������
  ����
    default
      �ŏ��ɕ\�������E���^�[��
  �Ԃ�
    �I��ꂽ�J�E���^�[��
    �L�����Z�����ꂽ�ꍇ�A�ŏ��ɕ\�������������ɂȂ�

OpenCounter(Counters="")
  �p�t�H�[�}���X�J�E���^�[���������  �������ɂ͐��b���������������
  ����
    Counters
      �J�E���^�[����s�����񋓂��������� �Ԃ�
    DLL�̃��[�h�ɐ�������ǂ���

GetCounter(period=0)
  �p�t�H�[�}���X�J�E���^�[�̒l�������
  ����
    period
      �v�����鎞�Ԃ���b�Ŏw��      �����Ŏw�肵�����Ԃ����A�֐���Sleep����      0(�ȗ���)�́A�O��������獡����̊Ԃ�PU�g�p�����擾����

CloseCounter()
  �p�t�H�[�}���X�J�E���^�[������ADLL�ƃn���h���������
*/
SAlloc(size){
	return DllCall("GlobalAlloc",UInt,0x40,UInt,size,UInt)
}
SFree(ptr){
	DllCall("GlobalFree","UInt",ptr)
}
SGetDouble(pStruct,offset){
	DllCall("RtlMoveMemory", "DoubleP",val, UInt,pStruct+offset, Int,8)
	return val
}
SGetInt(pStruct,offset){
	DllCall("RtlMoveMemory", "UIntP",val, "UInt",pStruct+offset, "Int",4)
	return val
}
SGetByte(pStruct,offset){
	DllCall("RtlMoveMemory", UCharP,val, UInt,pStruct+offset, Int,1)
	return val
}
SSetInt(pStruct,offset,val){
	DllCall("RtlMoveMemory", UInt,pStruct+offset, UIntP,val, Int,4, Int)
}
getProcessHandle(pid,mode=0x001F0FFF){
	return DllCall("OpenProcess",UInt,mode,UInt,0,UInt,pid,UInt)
}
releaseProcessHandle(hProcess){
	DllCall("psapi.dll\CloseProcess","Int",hProcess)
}
GetSystemPowerStatus(type=0){
	pSPS:=SAlloc(12)
	if(DllCall("GetSystemPowerStatus",UInt,pSPS,Int)){
		if(type<2){
			if(type<1){
				f:=SGetByte(pSPS,1)
				if(f=128){
					return 0
				}else if(f=8){
					return 2
				}else if(SGetByte(pSPS,0)=1){
					return 3
				}else{
					return 1
				}
			}else{
				return SGetByte(pSPS,2)
			}
		}else{
			if(type<3){
				return SGetInt(pSPS,4)
			}else{
				return SGetInt(pSPS,8)
			}
		}
	}

	SFree(pSPS)
}
GetMemoryState(type=0,mode=1){
	pMemSt:=SAlloc(32)
	DllCall("GlobalMemoryStatus",UInt,pMemSt)
	val:=SGetInt(pMemSt,(2+type*2+mode)*4)
	SFree(pMemSt)
	return val
}
GetCPUState(period=0){
	static lastTimeIdle,lastTimeKernel,lastTimeUser
	if(period>0){
		DllCall("GetSystemTimes",Int64P,lastTimeIdle,Int64P,lastTimeKernel,Int64P,lastTimeUser)
		Sleep,%period%
	}
	DllCall("GetSystemTimes",Int64P,TimeIdle,Int64P,TimeKernel,Int64P,TimeUser)
	cpu:=100-100*(TimeIdle-lastTimeIdle)/(TimeUser-lastTimeUser+TimeKernel-lastTimeKernel)
	lastTimeIdle=%TimeIdle%
	lastTimeKernel=%TimeKernel%
	lastTimeUser=%TimeUser%
	return cpu
}
GetProcessMemoryState(pid,type=8){
	pMemSt:=SAlloc(40)
	hProcess:=getProcessHandle(pid)

	if(DllCall("psapi.dll\GetProcessMemoryInfo", UInt,hProcess, UInt,pMemst, UInt,40)){
	val:=SGetInt(pMemSt,type*4)
	}

	releaseProcessHandle(hProcess)
	SFree(pMemSt)
	return val
}
GetProcessCPUState(pid,period=0){
	global
	local hProcess,ct,et,it,TimeUser,TimeKernel,TimeUserP,TimeKernelP,cpu,lastTimeTotal,lastTimeProcess
	hProcess:=getProcessHandle(pid)
	if(period>0){
		DllCall("GetSystemTimes", Int64P,it, Int64P,TimeKernel,Int64P,TimeUser)
		DllCall("GetProcessTimes", UInt,hProcess, Int64P,ct, Int64P,et, Int64P,TimeKernelP,Int64P,TimeUserP)
		lastTimeTotal:=TimeKernel+TimeUser
		lastTimeProcess:=TimeKernelP+TimeUserP
		Sleep,%period%
	}else{
		lastTimeTotal:=lastTimeTotal_%pid%
		lastTimeProcess:=lastTimeProcess_%pid%
	}
	DllCall("GetProcessTimes",UInt,hProcess, Int64P,ct, Int64P,et, Int64P,TimeKernelP,Int64P,TimeUserP)
	DllCall("GetSystemTimes",Int64P,it,Int64P,TimeKernel,Int64P,TimeUser)
	releaseProcessHandle(hProcess)

	cpu:=100*(TimeUserP+TimeKernelP-lastTimeProcess)/(TimeUser+TimeKernel-lastTimeTotal)

	lastTimeTotal_%pid%:=TimeUser+TimeKernel
	lastTimeProcess_%pid%:=TimeUserP+TimeKernelP
	return cpu
}
OpenNetworkMonitor(){
	global
	local count,ifr,type,tmp,size
	hModuleIPHLP:=DllCall("LoadLibrary",Str,"iphlpapi.dll")
	DllCall("iphlpapi.dll\GetIfTable", UInt,0, UIntP,size, Int,1)
	NetworkTable:=SAlloc(size)
	DllCall("iphlpapi.dll\GetIfTable", UInt,NetworkTable, UIntP,size, Int,1)
	count:=SGetInt(NetworkTable,0)
	NumNetwork=0
	Network_In=0
	Network_Out=0
	Network_LastGet=%A_TickCount%
	Loop,%count%{
		ifr:=NetworkTable+4+860*(A_Index-1)
		type:=SGetInt(ifr,516)
		if((type=6)||(type=23)){
			NumNetwork++
			Network_%NumNetwork%_P=%ifr%
			tmp:=SGetInt(ifr,552)
			Network_In+=%tmp%
			Network_%NumNetwork%_In=%tmp%
			tmp:=SGetInt(ifr,576)
			Network_Out+=%tmp%
			Network_%NumNetwork%_Out=%tmp%

		}
	}
}
GetNetWorkMonitor(period=0){
	global
	local ifr,t_in,t_out,tc,tmp,ex
	if(period>0){
		Network_In=0
		Network_Out=0
		Network_LastGet=%A_TickCount%
		Loop,%NumNetwork%{
			ifr:=Network_%A_Index%_P
			DllCall("iphlpapi.dll\GetIfEntry", UInt,ifr)
			tmp:=SGetInt(ifr,552)
			Network_In+=%tmp%
			Network_%A_Index%_In=%tmp%
			tmp:=SGetInt(ifr,576)
			Network_Out+=%tmp%
			Network_%A_Index%_Out=%tmp%
		}
		Sleep,%period%
	}
	t_in=0
	t_out=0
	tc=%A_TickCount%
	ex:=tc-Network_LastGet
	if ex<=0
		ex=1
	Loop,%NumNetwork%{
		ifr:=Network_%A_Index%_P
		DllCall("iphlpapi.dll\GetIfEntry", UInt,ifr)
		tmp:=SGetInt(ifr,552)
		t_in+=%tmp%
		Network_%A_Index%_InPS:=(tmp-Network_%A_Index%_In)*1000/ex
		Network_%A_Index%_In=%tmp%

		tmp:=SGetInt(ifr,576)
		t_out+=%tmp%
		Network_%A_Index%_OutPS:=(tmp-Network_%A_Index%_Out)*1000/ex
		Network_%A_Index%_Out=%tmp%
	}
	Network_InPS:=(t_in-Network_In)*1000/ex
	Network_In=%t_in%
	Network_OutPS:=(t_out-Network_Out)*1000/ex
	Network_Out=%t_out%
	Network_LastGet=%tc%
}
CloseNetworkMonitor(){
	global
	if(hModuleIPHLP<>0){
		SFree(NetworkTable)
		DllCall("FreeLibrary", UInt, hModuleIPHLP)
		hModuleIPHLP=0
		Loop,%NumNetwork%{
			Network_%A_Index%_P=
			Network_%A_Index%_InPS=
			Network_%A_Index%_In=
			Network_%A_Index%_OutPS=
			Network_%A_Index%_Out=
		}
		Network_InPS=
		Network_In=
		Network_OutPS=
		Network_Out=
		NumNetwork=
	}
}
SelectCounter(default=""){
	if(default=""){
		default=\Process(_Total)\`% Processor Time
	}
	dlg:=SAlloc(40)
	VarSetCapacity(cpath,1024)
	cpath=\Process(_Total)\`% Processor Time

	SSetInt(dlg,0,0x47)
	SSetInt(dlg,12,&cpath)
	SSetInt(dlg,16,1024)
	SSetInt(dlg,32,400)
	DllCall("PDH.DLL\PdhBrowseCountersA",UInt,dlg)
	return cpath
}
OpenCounter(Counters=""){
	global
	hModulePDH=0
	hModulePDH:=DllCall("LoadLibrary",Str,"PDH.DLL")
	DllCall("PDH.DLL\PdhOpenQueryA",UInt,0, UInt,0, UIntP,hCounterQuery)

	NumCounters=0
	Loop,Parse,Counters,`n,`r
	{
		if A_LoopField=
			continue
		DllCall("PDH.DLL\PdhAddCounterA",UInt,hCounterQuery, Str,A_LoopField, UInt,0, UIntP,hCounter_%A_Index%)
		NumCounters++
	}
	return hModulePDH<>0
}
GetCounter(period=0){
	global
	local fcv
	if(period>0){
		DllCall("PDH.DLL\PdhCollectQueryData",UInt,hCounterQuery)
		Sleep,%period%
	}
	DllCall("PDH.DLL\PdhCollectQueryData",UInt,hCounterQuery)

	fcv:=SAlloc(16)
	Loop,%NumCounters%{
		if(hCounter_%A_Index% &&(DllCall("PDH.DLL\PdhGetFormattedCounterValue",UInt,hCounter_%A_Index%, UInt,0x200, UInt,0, UInt,fcv)=0)){
			Counter_%A_Index%:=SGetDouble(fcv,8)
		}
	}
	SFree(fcv)
}
CloseCounter(){
	global
	if(hModulePDH){
		DllCall("PDH.DLL\PdhCloseQuery",UInt,hCounterQuery)
		DllCall("FreeLibrary", UInt, hModulePDH)
		hModulePDH=0
		hCounterQuery=0
		Loop,%NumCounters%{
			hCounter_%A_Index%=
			Counter_%A_Index%=
		}
		NumCounters=0
	}
}


