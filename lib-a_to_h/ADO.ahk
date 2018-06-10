



/*
* Provides Static ADO Helper classes and Enums
*
*/
class ADO
{
	class CursorType
	{
		static adOpenUnspecified 	:= -1
		static adOpenForwardOnly 	:= 0
		static adOpenKeyset 		:= 1
		static adOpenDynamic 		:= 2
		static adOpenStatic 		:= 3
	}
	
	class LockType
	{
		static adLockUnspecified 		:= -1
		static adLockReadOnly 			:= 1
		static adLockPessimistic 		:= 2
		static adLockOptimistic 		:= 3
		static adLockBatchOptimistic 	:= 4
	}
	
	class CommandType
	{
		static adCmdUnspecified := -1
		static adCmdText 		:= 1
		static adCmdTable 		:= 2
		static adCmdStoredProc 	:= 4
		static adCmdUnknown 	:= 8
		static adCmdFile 		:= 256
		static adCmdTableDirect := 512
	}
	
	class AffectEnum
	{
		static adAffectCurrent 	:= 1
		static adAffectGroup 	:= 2
	}

	class ObjectStateEnum 
	{
		static adStateClosed 		:= 0	; The object is closed
		static adStateOpen			:= 1	; The object is open
		static adStateConnecting 	:= 2	; The object is connecting
		static adStateExecuting		:= 4	; The object is executing a command
		static adStateFetching		:= 8	; The rows of the object are being retrieved
	}

}