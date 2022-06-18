/*   __    __  __          __ __       __    __                 _       __
    / /_  / /_/ /_____  _ / // /____ _/ /_  / /________________(_)___  / /_ ____  _______
   / __ \/ __/ __/ __ \(_) // // __ '/ __ \/ //_/ ___/ ___/ __/ / __ \/ __// __ \/ __/ _ \
  / / / / /_/ /_/ /_/ / / // // /_/ / / / / ,< (__  ) /__/ / / / /_/ / /__/ /_/ / / / // /
 /_/ /_/\__/\__/ .___(_) // / \__,_/_/ /_/_/|_/____/\___/_/ /_/ .___/\__(_)____/_/  \__ /
              /_/     /_//_/                                 /_/                   (___/

  http://ahkscript.org/boards/viewtopic.php?&t=4542

  XNET is a Class wrapper that simplifies access to MIB_IFROW2 structure.
  XNET helps in monitoring network connection and data.
  added identification (converting )
__________________________________________________________________________________________

  STRUCTURE MIB_IFROW2 ( MSDN http://goo.gl/Fufv7m )
  ----------------------------------------------------------------------------------------
  Offset Size Type   Description                     Comment
  ----------------------------------------------------------------------------------------
  0        8  INT64  InterfaceLuid
  8        4  UINT   InterfaceIndex
  12      16  GUID   InterfaceGuid
  28     514  WSTR   Alias
  542    514  WSTR   Description                     Friendly name
  1056     4  UINT   PhysicalAddressLength
  1060    32  BYTE   PhysicalAddress                 MAC address
  1092    32  BYTE   PermanentPhysicalAddress        MAC address
  1124     4  UINT   Mtu
  1128     4  UINT   Type ( IFTYPE )
  1132     4  UINT   TunnelType
  1136     4  UINT   MediaType
  1140     4  UINT   PhysicalMediumType
  1144     4  UINT   AccessType
  1148     4  UINT   DirectionType
  1152     4  UINT   InterfaceAndOperStatusFlags
  1156     4  UINT   OperStatus
  1160     4  UINT   AdminStatus
  1164     4  UINT   MediaConnectState
  1168    16  GUID   NetworkGuid
  1184     4  UINT   ConnectionType
  1188     4  ----   ----                            Padding for x64 alignment
  1192     8  UINT64 TransmitLinkSpeed
  1200     8  UINT64 ReceiveLinkSpeed
  1208     8  UINT64 InOctets                        Received Bytes
  1216     8  UINT64 InUcastPkts
  1224     8  UINT64 InNUcastPkts
  1232     8  UINT64 InDiscards
  1240     8  UINT64 InErrors
  1248     8  UINT64 InUnknownProtos
  1256     8  UINT64 InUcastOctets                   Received bytes
  1264     8  UINT64 InMulticastOctets
  1272     8  UINT64 InBroadcastOctets
  1280     8  UINT64 OutOctets                       Sent Bytes
  1288     8  UINT64 OutUcastPkts
  1296     8  UINT64 OutNUcastPkts
  1304     8  UINT64 OutDiscards
  1312     8  UINT64 OutErrors
  1320     8  UINT64 OutUcastOctets                  Sent Bytes
  1328     8  UINT64 OutMulticastOctets
  1336     8  UINT64 OutBroadcastOctets
  1344     8  UINT64 OutQLen
  ----------------------------------------------------------------------------------------
  1352 bytes in total + 16 extra bytes follow
  ----------------------------------------------------------------------------------------
  1352     8  PTR    Pointer to InUcastOctets
  1360     8  PTR    Pointer to OutUcastOctets
  ----------------------------------------------------------------------------------------
*/






Class XNET  ;             By SKAN,  http://goo.gl/zNmlqm,  CD:27/Aug/2014 | MD:12/Sep/2014
{

	static AliasTypes   := Object()

			  AliasTypes.Type			:={"#1"  	: "Some other type of network interface"
        										,	"#6"   	: "Ethernet network interface"
        										,   "#9"   	: "Fiber Distributed Data Interface (FDDI) network interface"
        										,   "#15" 	: "Token ring network interface (ISO88025_TOKENRING)"
        										,   "#23" 	: "PPP network interface"
        										,   "#24" 	: "software loopback network interface"
        										,   "#37"	: "ATM network interface"
        										,   "#71"  	: "IEEE 802.11 wireless network interface"
        										,   "#131" 	: "Tunnel type encapsulation network interface"
        										,   "#144"	: "IEEE 1394 (Firewire) high performance serial bus network interface"
        										,   "#237"	: "Mobile broadband interface for WiMax devices"
        										,   "#243"	: "Mobile broadband interface for GSM-based devices (WWANPP)"
        										,   "#244" 	: "mobile broadband interface for CDMA-based device (WWANPP2)"}

	AliasTypes.TunnelType			:={"#0"  	: "TYPE_NONE: Not a tunnel"
        										,	"#1"		: "TYPE_OTHER: None of the other tunnel types"
        										,	"#2"		: "TYPE_DIRECT: A packet is encapsulated directly within a normal IP header, with no intermediate header, and unicast to the remote tunnel endpoint"
        										, 	"#3"		: "TYPE-GRE: GRE encapsulation"
        										,   "#4"		: "TYPE_MINIMAL: Minimal encapsulation"
        										,	"#5"		: "TYPE_l2tp: L2TP encapsulation"
        										,	"#6"		: "TYPE_pptp: PPTP encapsulation"
        										,	"#7"		: "TYPE_l2f: L2F encapsulation"
        										,	"#8"		: "TYPE_udp: UDP encapsulation"
        										,	"#9"		: "TYPE_atmp: ATMP encapsulation"
        										,	"#10"	: "TYPE_msdp: MSDP encapsulation"
        										,	"#11"	: "TYPE_6TO4: An IPv6 packet is encapsulated directly within an IPv4 header, with no intermediate header, and unicast to the destination determined by the 6to4 protocol"
        										,	"#12"	: "TYPE_sixOverFour: 6over4 encapsulation"
        										,	"#13"	: "TYPE_ISATAP: An IPv6 packet is encapsulated directly within an IPv4 header, with no intermediate header, and unicast to the destination determined by the ISATAP protocol"
        										,	"#14"	: "TYPE_TEREDO: Teredo encapsulation"
        										,   "#15"	: "TYPE_ipHttps: IPHTTPS"
        										,   "#16"	: "TYPE_softwireMesh: softwire mesh tunnel"
        										,   "#17"	: "TYPE_dsLite: DS-Lite tunnel"
        										,   "#18"	: "TYPE_aplusp: A+P encapsulation"
        										,   "#19"	: "TYPE_ipsectunnelmode: IpSec tunnel mode encapsulation"}

AliasTypes.ConnectionType    	:={"#1"	 	: "The connection type is dedicated. The connection comes up automatically when media sense is TRUE. For example, an Ethernet connection is dedicated."
			                    	        	,	"#2" 		: "The connection type is passive. The remote end must bring up the connection to the local station. For example, a RAS interface is passive."
			                    	        	,	"#3" 		: "The connection type is demand-dial. A connection of this type comes up in response to a local action (sending a packet, for example)."
			                    	        	,	"#4" 		: "The maximum possible value for the NET_IF_CONNECTION_TYPE enumeration type. This is not a legal value for ConnectionType member."}

	AliasTypes.MediaType	    	:={"#0"	: "The physical medium is none of the below values. For example, a one-way satellitefeed is an unspecified physical medium."
			                    	        	,	"#1" 		: "Packets aretransferred over a wireless LAN network througha miniport driver that conforms to the 802.11 interface."
			                    	        	,	"#2" 		: "Packets aretransferred over a DOCSIS-based cable network."
			                    	        	,	"#3" 		: "Packets aretransferred over standard phonelines. This includes HomePNA media, for example."
			                    	        	,	"#4" 		: "Packets aretransferred over wiring that is connected to a power distribution system."
			                    	        	,	"#5" 		: "Packets aretransferred over a DigitalSubscriber Line(DSL) network. This includes ADSL, UADSL (G.Lite), and SDSL, for example."
			                    	        	,	"#6" 		: "Packets aretransferred over a Fibre Channel interconnect."
			                    	        	,	"#7" 		: "Packets aretransferred over an IEEE 1394 bus."
			                    	        	,	"#8" 		: "Packets aretransferred over a Wireless WAN link. This includes mobile broadband devices that support CDPD, CDMA, GSM, and GPRS, for example."}

AliasTypes.MediumType         	:={"#0"   	: "An Ethernet (802.3) network."
									          	,	"#1"    	: "A Token Ring (802.5) network."
									          	,	"#2"  	: "A Fiber Distributed Data Interface (FDDI) network."
									          	,	"#3"  	: "A wide area network (WAN). This type covers various forms of point-to-point and WAN NICs, as well as variant address/header formats."
									          	,	"#4"  	: "A LocalTalk network."
									          	,	"#5"  	: "An Ethernet network for which the drivers use the DIX Ethernet header format."
									          	,	"#6"  	: "An ARCNET network."
									          	,	"#7"  	: "An ARCNET (878.2) network."
									          	,	"#8"  	: "An ATM network. Connection-oriented client protocol drivers can bind themselves to an underlying miniport driver that returns this value."
									          	,	"#9"  	: "A wireless network. NDIS 5.X miniport drivers that support wireless LAN (WLAN) or wireless WAN (WWAN) "
									          	,	"#10"	: "An infrared (IrDA) network."
									          	,	"#11"	: "A broadcast PC network."
									          	,	"#12"	: "A wide area network in a connection-oriented environment."
									          	,	"#13"	: "An IEEE 1394 (fire wire) network."
									          	,	"#14"	: "An InfiniBand network."
									          	,	"#15"	: "A tunnel network."
									          	,	"#16"	: "A native IEEE 802.11 network."
									          	,	"#17"	: "An NDIS loopback network."
									          	,	"#18"	: "An WiMax network."}

AliasTypes.PhysicalMediumType	:= {"#0"   : "The physical medium is none of the below values. For example, a one-way satellite feed is an unspecified physical medium.network."
									          	,	"#1"    	: "Packets are transferred over a wireless LAN network through a miniport driver that conforms to the 802.11 interface.  network."
									          	,	"#2"  	: "Packets are transferred over a DOCSIS-based cable network. "
									          	,	"#3"  	: "Packets are transferred over standard phone lines. This includes HomePNA media, for example. "
									          	,	"#4"  	: "Packets are transferred over wiring that is connected to a power distribution system. "
									          	,	"#5"  	: "Packets are transferred over a Digital Subscriber Line (DSL) network. This includes ADSL, UADSL (G.Lite), and SDSL, for exa "
									          	,	"#6"  	: "Packets are transferred over a Fibre Channel interconnect."
									          	,	"#7"  	: "Packets are transferred over an IEEE 1394 bus. twork."
									          	,	"#8"  	: "Packets are transferred over a Wireless WAN link. "
									          	,	"#9"  	: "Packets are transferred over a wireless LAN network through a miniport driver that conforms to the Native 802.11 interface."
									          	,	"#10"	: "Packets are transferred over a Bluetooth network. Bluetooth is a short-range wireless technology that uses the 2.4 GHz spect etwork."
									          	,	"#11"	: "Packets are transferred over an Infiniband interconnect."
									          	,	"#12"	: "Packets are transferred over a WiMax network. in a connection-oriented environment."
									          	,	"#13"	: "Packets are transferred over an ultra wide band network. ire) network."
									          	,	"#14"	: "Packets are transferred over an Ethernet (802.3) network."
									          	,	"#15"	: "Packets are transferred over a Token Ring (802.5) network."
									          	,	"#16"	: "Packets are transferred over an infrared (IrDA) network."
									          	,	"#17"	: "Packets are transferred over a wired WAN network."
									          	,	"#18"	: "Packets are transferred over a wide area network in a connection-oriented environment."
									          	,	"#19"	: "Packets are transferred over a network that is not described by other possible values."}



    __New( AutoIF := True )    {

		Local IfIndex := 0


        this.hModule := DllCall( "LoadLibrary", "Str","Iphlpapi.dll", "Ptr" )
        this.SetCapacity( "MIB_IF_ROW2", 1368 ),  this.ZeroFill( 1368 )
        this.SetDataOffsets(), this.GetTime( True )
        DllCall( "iphlpapi\GetBestInterface", "Ptr",0, "PtrP",IfIndex )
        If ( AutoIF and IfIndex )
          NumPut( IfIndex, this.GetAddress( "MIB_IF_ROW2" ) + 8, "UInt" )
        , this.Update( True )


    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    __Delete()    {
        DllCall( "FreeLibrary", "Ptr",this.hModule )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    __Set( Member, Value )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" ),  nIfCount := 0,  Found := 0

        If ( Member = "InterfaceLuid" )        {
             this.ZeroFill( 12 )
             this.NET_LUID( Value )
        }


        If ( Member = "InterfaceIndex" )        {
             this.ZeroFill( 12 )
             NumPut( Value, pData+8, "UInt" )
        }


        If ( Member = "InterfaceGuid" )        {
             this.ZeroFill( 12 )
             DllCall( "ole32\CLSIDFromString", "WStr",Value, "Ptr",pData+12 )
             DllCall( "iphlpapi\ConvertInterfaceGuidToLuid", "Ptr",pData+12, "Ptr",pData )
        }


        If ( Member = "Alias" )        {
             this.ZeroFill( 12 )
             DllCall( "iphlpapi\ConvertInterfaceAliasToLuid", "WStr",Value,  "Ptr",pData )
        }


        If ( Member = "Description" )        {
             DllCall( "iphlpapi\GetNumberOfInterfaces", "PtrP",nIfCount )
             Loop % ( nIfCount )
             {
                 NumPut( A_Index, NumPut( 0, pData+0, "Int64" ), "UInt" )
                 DllCall( "iphlpapi\GetIfEntry2", "Ptr",pData )
                 If ( StrGet( pData+542, "UTF-16" ) = Value and ( Found := True ) )
                     Break
             }

             ErrorLevel := ( not Found ) ? this.ZeroFill( 12 ) : ""
        }

    If Member in InterfaceLuid,InterfaceIndex,InterfaceGuid,Alias,Description
       Return this.Update( True ) ? Value : ""
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    __Get( Member )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" )

        IfEqual, Member, InterfaceLuid,               Return this.NET_LUID()
        IfEqual, Member, InterfaceIndex,              Return NumGet( pData+  8,   "UInt" )
        IfEqual, Member, Alias,                       Return StrGet( pData+ 28, "UTF-16" )
        IfEqual, Member, Description,                 Return StrGet( pData+542, "UTF-16" )
        IfEqual, Member, InterfaceGuid,               Return this.GUID( 12 )
        IfEqual, Member, PhysicalAddress,             Return this.MAC( 1060 )
        IfEqual, Member, PermanentPhysicalAddress,    Return this.MAC( 1092 )
        IfEqual, Member, Mtu,                         Return NumGet( pData+1124,  "UInt" )
        IfEqual, Member, Type,                        Return NumGet( pData+1128,  "UInt" )
        IfEqual, Member, TunnelType,                  Return NumGet( pData+1132,  "UInt" )
        IfEqual, Member, MediaType,                   Return NumGet( pData+1136,  "UInt" )
        IfEqual, Member, PhysicalMediumType,          Return NumGet( pData+1140,  "UInt" )
        IfEqual, Member, AccessType,                  Return NumGet( pData+1144,  "UInt" )
        IfEqual, Member, DirectionType,               Return NumGet( pData+1148,  "UInt" )
        IfEqual, Member, InterfaceAndOperStatusFlags, Return NumGet( pData+1152,  "UInt" )
        IfEqual, Member, OperStatus,                  Return NumGet( pData+1156,  "UInt" )
        IfEqual, Member, AdminStatus,                 Return NumGet( pData+1160,  "UInt" )
        IfEqual, Member, MediaConnectState,           Return NumGet( pData+1164,  "UInt" )
        IfEqual, Member, NetworkGuid,                 Return this.GUID( 1168 )
        IfEqual, Member, ConnectionType,              Return NumGet( pData+1184,  "UInt" )
        IfEqual, Member, TransmitLinkSpeed,           Return NumGet( pData+1192, "Int64" )
        IfEqual, Member, ReceiveLinkSpeed,            Return NumGet( pData+1200, "Int64" )
        IfEqual, Member, InOctets,                    Return NumGet( pData+1208, "Int64" )
        IfEqual, Member, InUcastPkts,                 Return NumGet( pData+1216, "Int64" )
        IfEqual, Member, InNUcastPkts,                Return NumGet( pData+1224, "Int64" )
        IfEqual, Member, InDiscards,                  Return NumGet( pData+1232, "Int64" )
        IfEqual, Member, InErrors,                    Return NumGet( pData+1240, "Int64" )
        IfEqual, Member, InUnknownProtos,             Return NumGet( pData+1248, "Int64" )
        IfEqual, Member, InUcastOctets,               Return NumGet( pData+1256, "Int64" )
        IfEqual, Member, InMulticastOctets,           Return NumGet( pData+1264, "Int64" )
        IfEqual, Member, InBroadcastOctets,           Return NumGet( pData+1272, "Int64" )
        IfEqual, Member, OutOctets,                   Return NumGet( pData+1280, "Int64" )
        IfEqual, Member, OutUcastPkts,                Return NumGet( pData+1288, "Int64" )
        IfEqual, Member, OutNUcastPkts,               Return NumGet( pData+1296, "Int64" )
        IfEqual, Member, OutDiscards,                 Return NumGet( pData+1304, "Int64" )
        IfEqual, Member, OutErrors,                   Return NumGet( pData+1312, "Int64" )
        IfEqual, Member, OutUcastOctets,              Return NumGet( pData+1320, "Int64" )
        IfEqual, Member, OutMulticastOctets,          Return NumGet( pData+1328, "Int64" )
        IfEqual, Member, OutBroadcastOctets,          Return NumGet( pData+1336, "Int64" )
        IfEqual, Member, OutQLen,                     Return NumGet( pData+1344, "Int64" )

    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    InterfaceAndOperStatusFlags( SubMember := "" )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" )
            , Flags := NumGet( pData+1152, "UInt" )

        IfEqual, SubMember, HardwareInterface,        Return ( Flags >> 0 & 1 )
        IfEqual, SubMember, FilterInterface,          Return ( Flags >> 1 & 1 )
        IfEqual, SubMember, ConnectorPresent,         Return ( Flags >> 2 & 1 )
        IfEqual, SubMember, NotAuthenticated,         Return ( Flags >> 3 & 1 )
        IfEqual, SubMember, NotMediaConnected,        Return ( Flags >> 4 & 1 )
        IfEqual, SubMember, Paused,                   Return ( Flags >> 5 & 1 )
        IfEqual, SubMember, LowPower,                 Return ( Flags >> 6 & 1 )
        IfEqual, SubMember, EndPointInterface,        Return ( Flags >> 7 & 1 )

    Return -1
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    Update( Reset := 0 )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" ), MS, OldTx, OldRx, Tx, Rx, MCS
        MS    := this.GetTime( Reset )

        OldTx := NumGet( NumGet( pData+1360 ), "Int64" )
        OldRx := NumGet( NumGet( pData+1352 ), "Int64" )

        If ErrorLevel := DllCall( "iphlpapi\GetIfEntry2", "Ptr",pData )
           Return 0,  this.ZeroFill()

        this.Tx    := Tx := NumGet( NumGet( pData+1360 ), "Int64" )
        this.Rx    := Rx := NumGet( NumGet( pData+1352 ), "Int64" )
        this.TxBPS := Round( ( ( Tx-OldTx ) / 1000 ) / ( MS/1000 ) * 1000 )
        this.RxBPS := Round( ( ( Rx-OldRx ) / 1000 ) / ( MS/1000 ) * 1000 )

        MCS := NumGet( pData+1164,"UInt" )
        this.State := ( MCS=1 ? "Connected" : MCS=2 ? "Disconnected" : "Unknown" )

    Return True
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    SetDataOffsets( In := 1256, Out := 1320 ) {
         Local pData := this.GetAddress( "MIB_IF_ROW2" )
         NumPut( pData + In, pData + 1352 ), NumPut( pData + Out, pData + 1360 )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ZeroFill( Bytes := 1352, FillChar := 0 ) {
        Local pData := this.GetAddress( "MIB_IF_ROW2" )
        DllCall( "RtlFillMemory", "Ptr",pData, "Ptr",Bytes, "UChar",FillChar )
    }


    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	ConvertAlias(Member, Alias) {
		return this.AliasTypes[Member]["#" Alias]
	}

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    NET_LUID( sLUID := "" )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" ), AFI := "", L := 0

        If ( not SLUID )
        {
           SetFormat, IntegerFast, % "H" ( AFI := A_FormatInteger )
           sLUID := SubStr( 0x1000000 | ( NumGet( pData+0, "UInt" ) & 0xFFFFFF ), -5 ) "-"
                 .  SubStr( 0x1000000 | ( NumGet( pData+3, "UInt" ) & 0xFFFFFF ), -5 ) "-"
                 .  SubStr( 0x1000000 |   NumGet( pData+6, "UShort" ), -3 )
           SetFormat, IntegerFast, %AFI%

        Return "{" sLUID "}"
        }

        StringSplit, L, sLUID, -, {}%A_Space%
        NumPut( "0x" L1, pData+0, "UInt" )
        NumPut( "0x" L2, pData+3, "UInt" )
        NumPut( "0x" L3, pData+6, "UShort" )

    Return NumGet( pData+0, "Int64" )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    MAC( Offset := 1092 )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" ),  PhysAddr := ""
        SetFormat, IntegerFast, % "H" ( AFI := A_FormatInteger )
        Loop % NumGet( pData + 1056, "UInt" )
           PhysAddr .= "-" SubStr( 0x100 | NumGet( pData+OffSet+A_Index-1, "UChar" ), -1 )
        SetFormat, IntegerFast, %AFI%

    Return SubStr( PhysAddr, 2 )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUID( Offset := 12 )    {
        Local pData := this.GetAddress( "MIB_IF_ROW2" )
        VarSetCapacity( GUID,80,0 )
        DllCall( "ole32\StringFromGUID2", "Ptr",pData + Offset, "Ptr",&GUID, "Int",39 )

    Return StrGet( &GUID, "UTF-16" )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GetTime( Reset := 0 )    {
        Local T1601 := 0, OldTime := 0

        DllCall( "GetSystemTimeAsFileTime", "Int64P",T1601 ), T1601 //= 10000
        OldTime := this.Time, this.Time := T1601

    Return Reset ? ( this.Time := T1601 ) - T1601 : ( this.Time - OldTime )
    }

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}   ;                                                                          end of XNET
;= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =