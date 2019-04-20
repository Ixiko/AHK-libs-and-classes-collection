/*
	DataBase NameSpace Import
*/

#Include <Base>
#Include <Collection>

;drivers
#Include <SQLite_L>
;#Include <mySQL>
;#Include <ADO>

class DBA ; namespace DBA
{
	#Include <DataBaseFactory>
	#Include <DataBaseAbstract>
	

	; Concrete SQL Providers
	#Include <DataBaseSQLLite>
	;#Include <DataBaseMySQL>
	;#Include <DataBaseADO>
	
	#Include <RecordSetSqlLite>
	;#Include <RecordSetADO>
	;#Include <RecordSetMySQL>
}