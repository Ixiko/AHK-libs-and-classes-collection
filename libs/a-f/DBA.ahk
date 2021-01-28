/*
	DataBase NameSpace Import
*/

#Include <Base>
#Include <ArchLogger>
#Include <MemoryBuffer>
#Include <Collection>

; drivers / header definitions
#Include <ADO>
#Include <SQLite_L>
#Include <mySQL>


class DBA ; namespace DBA
{
	/*
	* All thefollowing included classes will be contained in the DBA namespace
	* which is actually just an encapsulating class
	*
	*/
	
	;base classes
	#Include <DataBaseFactory>
	#Include <DataBaseAbstract>
	

	; Concrete SQL-Provider Implementations
	#Include <DataBaseSQLLite>
	#Include <DataBaseMySQL>
	#Include <DataBaseADO>
	
	#Include <RecordSetSqlLite>
	#Include <RecordSetADO>
	#Include <RecordSetMySQL>
}