/*
システムモニタ用関数群	by流行らせるページ管理人


●取得できる物
システム全体のCPU使用率
    GetCPUState
システム全体のメモリ総容量、空き容量
    GetMemoryState
バッテリの状態、残量
    GetSystemPowerStatus
プロセスごとのCPU使用率
    GetProcessCPUState
プロセスごとのメモリ使用状況
    GetProcessMemoryState
ネットワークの送受信速度(B/s)
システム起動時からのネットワーク総転送量(Bytes)
    OpenNetworkMonitor
    GetNetWorkMonitor
    CloseNetworkMonitor
パフォーマンスモニタで取得できる各種の情報
    SelectCounter
    OpenCounter
    GetCounter
    CloseCounter





●関数仕様

○システム全体用
GetCPUState(period=0)
  指定した期間のシステム全体のCPU使用率を取得する
  引数
    period
      計測する時間をミリ秒で指定
      ここで指定した時間だけ、関数内でSleepする
      0(省略時)は、前回取得時から今回取得の間のCPU使用率が取得される
  返り値
    指定した時間の間のCPU使用率を小数で

GetMemoryState(type=0,mode=1)
  システム全体のメモリ使用量や空き容量を取得する
  引数
    type
      0 物理メモリ
      1 ページファイル
      2 仮想アドレス空間
    mode
      0 総容量
      1 空き容量
  返り値
    要求された値(Bytes)

GetSystemPowerStatus(type=0)
  ノートPCなどのバッテリー状態や残量を取得する
  引数
    type
      取得する情報の種類を指定
        0 バッテリーの有無と状態を取得
          返り値は以下の物になる
            0 バッテリー無し
            1 放電中
            2 充電中
            3 AC電源使用中
        1 バッテリーの残量を%で取得(不明の時255)
        2 バッテリーの残り秒数を取得(取得不能の時0xFFFFFFFF)
        3 バッテリーの最大秒数を取得(取得不能の時0xFFFFFFFF)
  返り値
    取得した値

○特定プロセス用
GetProcessCPUState(pid,period=0)
  指定プロセスのCPU使用率を取得する
  引数
    pid
      プロセスID(WinGet,var,PIDなどで取得できる)
    period
      計測する時間をミリ秒で指定
      ここで指定した時間だけ、関数内でSleepする
      0(省略時)は、前回取得時から今回取得の間のCPU使用率が取得される
  返り値
    指定した時間の間のCPU使用率を小数で


GetProcessMemoryState(pid,type=8)
  指定プロセスのメモリ使用状態を取得する
  引数
    pid
      プロセスID(WinGet,var,PIDなどで取得できる)
    type
      1 ページフォルトカウント
      2 ワーキングセット最高値
      3 ワーキングセット現在値
      4 ページプール最大値
      5 ページプール現在値
      6 非ページプール最大値
      7 非ページプール現在値
      8 仮想メモリサイズ現在値(デフォルト)
      9 仮想メモリサイズ最大値
  返り値
    取得した値


○ネットワークモニター
取得した値は以下のグローバル変数に格納される
Network_InPS
    1秒あたりの受信データ量(B/s)
Network_OutPS
    1秒あたりの送信データ量(B/s)
Network_In
    システム起動時からの受信データ総量
Network_Out
    システム起動時からの送信データ総量
NumNetwork
    ネットワークインターフェイスの数
Network_1_InPS
Network_1_OutPS
Network_1_In
Network_1_Out
    ネットワークインターフェイス個別の数値


OpenNetworkMonitor()
  ネットワークモニターの初期化を行う

GetNetWorkMonitor(period=0)
  ネットワークモニターの値を更新する
  引数
    period
      計測する時間をミリ秒で指定
      ここで指定した時間だけ、関数内でSleepする
      0(省略時)は、前回取得時から今回取得の間のB/sになる

CloseNetworkMonitor()
  ネットワークモニターを終了し、DLLと構造体を解放する



○パフォーマンスカウンター
パフォーマンスカウンターでは、様々な情報を監視できる。
取得したい情報はカウンター名で指定する。
SelectCounter関数を使用すれば、利用可能なカウンターをダイアログで選択して、
カウンター名を取得できる。
カウンター名の例としては、以下のような物がある。

\LogicalDisk(_Total)\% Disk Read Time
    ディスクが読み込みを行っていた時間の割合
\LogicalDisk(_Total)\% Disk Write Time
    ディスクが書き込みを行っていた時間の割合
\LogicalDisk(_Total)\% Disk Time
    ディスクにアクセスを行っていた時間の割合
\LogicalDisk(_Total)\% Idle Time
    ディスクにアクセスを行っていなかった時間の割合

「_Total」の代わりに「D:」のようなドライブ名も指定できる(HDDのみ)。
Disk Time+Idle Time は100になるとは限らない。
スクリプト中に記述するときは、「%」を「`%」とエスケープしなければならない場合があることに注意。

カウンター名を改行区切りで列挙したものをOpenCounterの引数に渡して登録する。
GetCounterを実行すると、グローバル変数にカウンターの値が格納される。
1行目で指定したカウンターの値は「Counter_1」に、2行目は「Counter_2」に格納される。



SelectCounter(default="")
  カウンター選択ダイアログを表示し、ユーザーが入力したカウンター名を返す。
  ダイアログが表示されるまでに数秒程度かかる場合がある

  引数
    default
      最初に表示するカウンター名
  返り値
    選択されたカウンター名
    キャンセルされた場合、最初に表示されていたものになる。

OpenCounter(Counters="")
  パフォーマンスカウンターを初期化する
  初期化には数秒程度かかる場合がある

  引数
    Counters
      カウンター名を改行区切りで列挙した文字列
  返り値
    DLLのロードに成功したかどうか

GetCounter(period=0)
  パフォーマンスカウンターの値を取得する

  引数
    period
      計測する時間をミリ秒で指定
      ここで指定した時間だけ、関数内でSleepする
      0(省略時)は、前回取得時から今回取得の間のCPU使用率が取得される

CloseCounter()
  パフォーマンスカウンターを終了し、DLLとハンドルを解放する

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


