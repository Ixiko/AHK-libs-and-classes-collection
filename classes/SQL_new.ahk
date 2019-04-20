#Include <DBA>

/*
	Method List
	
	insertimage(imagePath,imagename)
	loadimage(wName,pName,imagename)
	drop_table(table)
	load_image_to_file(wName,pName,imagename)
	insert(table,columns,values)
	delete(table,value,column)
	createtable(table,primarykey)
	rename(set,where,table)
	getvalueshash(field,table)
	getvalues(field,table)
	loadlv(wname,lvname,table,field="*")
	deletevalues(table,field) deleta todos os valores de determinada tabela
	exist(field,values,table) retorna true ou false
	deletetable(tablename)  drop table
	relate(table1,table2) relaciona duas tabelas
	copy(field,newtable,oldtable,primarykey)
	query(sql) sem verificar erros
	queryS(sql) verificando erros
	iquery(sql) query sem record set 
	close()

*/

class SQL
{
	__New(databaseType,connectionString)
	{
		try {
			this.currentDB := DBA.DataBaseFactory.OpenDataBase(databaseType, connectionString)
		} catch e {
			MsgBox,16, Error, % "Failed to create connection. Check your Connection string and DB Settings!`n`n" ExceptionDetail(e)
		}
		try
		{
			this.currentDB.Query("CREATE TABLE reltable (tipo,tabela1,tabela2);")
		}catch{
				
		}		
	}

	insertimage(imagePath,imagename){
		imgBuffer := MemoryBuffer.CreateFromFile(imagePath)
		this.currentDB.Query("CREATE TABLE imagetable (Name, Image BLOB, PRIMARY KEY(Name ASC));")
		record := {}
		record.Name  := imagename
		record.Image := imgBuffer
		this.currentDB.Insert(record, "imagetable")
		imgBuffer.Free()			
	}

	drop_table(table){
		/*
			Confere se a tabela existe 
			e entao remove.
		*/
	}

	loadimage(wName,pName,imagename){
		Global _wpic

		Static imagePath2
		if(wpic!=1){
			imagePath2 := A_scriptdir "\image.png"
			_wpic:=1
		}Else{
			imagePath2 := A_scriptdir "\image2.png"
			_wpic:=0
		}
		
		FileSetAttrib,-R, % imagePath2
		FileDelete, % imagePath2
		;if ErrorLevel
			;MsgBox, % "A imagem nao pode ser deletada!"
		record := this.currentDB.QueryRow("Select * from  imagetable WHERE Name = '" imagename "'")
		
		if(IsObject(record)){
			record.Image.WriteToFile(imagePath2) ; write the buffer into a file - we get a valid png again :)
			if(wName!=""){	
				gui,%wName%:default 
				guicontrol,,%pName%,% imagePath2
			}
		}else
			FileCopy,%A_scriptdir%\logotipos\semimagem.png,%A_scriptdir%\image.png,1
		return imagePath2
	}

	load_image_to_file(wName,pName,imagename){	
		record := this.currentDB.QueryRow("Select * from  imagetable WHERE Name = '" imagename "'")
		if(IsObject(record)){
			record.Image.WriteToFile(A_WorkingDir "\img\" imagename ".png") ; write the buffer into a file - we get a valid png again :)
			if(wName != ""){	
				gui,%wName%:default 
				guicontrol,,%pName%,% A_WorkingDir "\img\" imagename ".png"
			}
		}else{
			;MsgBox,16,, % "Nao existia imagem para o item " imagename
			imagename := "x"
		}
		return imagename
	}

	insert(record, table)
	{
		return this.currentDB.Insert(record, table)
	}

	delete(table,value,column)
	{
		this.currentDB.BeginTransaction()
		{

				sQry:="DELETE FROM " . table . " WHERE " . column "='" . value . "';"	
					
					if (!this.currentDB.Query(sQry)) {
					  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
					  throw Exception("Query failed: " Msg)
					 ; MsgBox, 0, Query failed, %Msg%
					}
		}this.currentDB.EndTransaction()

	}

	createtable(table,primarykey)    ;(Empresa,Mascara, PRIMARY KEY(Empresa ASC, Mascara ASC))
	{
		try
			{
				this.currentDB.Query("CREATE TABLE " . table . " " . primarykey . ";")
			}catch{
					
			}
	}

	rename(set,where,table)    ;set no formato nome='marcell',telefone='123', e where no formato nome='joao';
	{
		sQry:="UPDATE " . table
		  . "`nSET " . set
		    . "`nWHERE " . where . ";"	
				if (!this.currentDB.Query(sQry)) {
				  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
		
				  throw Exception("Query failed: " Msg)
				 ; MsgBox, 0, Query failed, %Msg%
				}
	}

	getvalueshash(field,table)
	{
		SQL:="SELECT " . field . " FROM " . table
		this.resultSet := this.currentDB.OpenRecordSet(SQL)
		return this.resultSet
	}

	getvalues(field,table)
	{
		SQL:="SELECT " . field . " FROM " . table
		this.resultSet := this.currentDB.OpenRecordSet(SQL)
		; fetch new data
		columns := this.resultSet.getColumnNames()
		columnCount := columns.Count()
		r:=1
		c:=1
		values:=object()
		while(!this.resultSet.EOF){	
			Loop, % columnCount{
				if(this.resultSet[A_Index]!="")
				{
					values[r,c]:=this.resultSet[A_Index]	
					c+=1
				}
			}
			r+=1
			c:=1
			this.resultSet.MoveNext()
		}
		this.resultSet.close()
		return values 
	}

	

	loadlv(wname,lvname,table,field="*",auto_adjust=0){
		SQL:="SELECT " field " FROM " table ";"
		this.resultSet := this.currentDB.OpenRecordSet(SQL)
		if(wname="" || lvname=""){
			MsgBox, % "O handle da janela e o nome do listview sao obrigatorios!!!"
			return  
		}
		sleep 100
		Gui,%wname%:default 
		Gui,listview,%lvname%
		LV_Delete()
		GuiControl,-ReDraw,%lvname%
		Loop, % LV_GetCount("Column")
	   		LV_DeleteCol(1)
		columns := this.resultSet.getColumnNames()
		columnCount := columns.Count()
		for each, colName in columns
			LV_InsertCol(A_Index,"", colName)
		while(!this.resultSet.EOF){	
			rowNum := LV_Add("","")
			Loop, % columnCount{
				LV_Modify(rowNum, "Col" . A_index, this.resultSet[A_index])
			}
			this.resultSet.MoveNext()
		}
		if(auto_adjust = 1)
			LV_ModifyCol(1),LV_ModifyCol(2),LV_ModifyCol(3),LV_ModifyCol(4),LV_ModifyCol(5)
		GuiControl,+ReDraw,%lvname%
		this.resultSet.close()
	}

	deletevalues(table,field) ;deleta todos os valores de determinada tabela
	{
		value:=this.getvalues(field,table)
		progress(value.maxindex())
		for,k,v in value 
		{
			updateprogress("Deletando Codigos antigos! " value[A_Index,1],1)
			this.delete(table,value[A_Index,1],field)
		}
		Gui,progress:destroy
	}

	exist(field,values,table)
	{
		table := this.currentDB.Query("SELECT " . field . " FROM " . table . " WHERE " . values)
		columnCount := table.Columns.Count()
		value:=""
		for each, row in table.Rows
		{
			Loop, % columnCount
				value:=row[A_index]
		}
		table.close()
		if(!value)
		{
			return False
		}else
		{
			return True
		}
	}

	deletetable(tablename)
	{
		sQry:="DROP TABLE " . tablename
			if (!this.currentDB.Query(sQry)) {
			  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
			  FileAppend, %Msg%, sqliteTestQuery.log
			  throw Exception("Query failed: " Msg)
			 ; MsgBox, 0, Query failed, %Msg%
			}		
	}

	relate(table1,table2) ;relaciona duas tabelas 
	{
		if(this.existtable(table1))
		{
			MsgBox, % "A tabela " . table1 . " nao existe por isso nao pode ser relacionada!"
			return 
		}

		if(this.existtable(table2))
		{
			MsgBox, % "A tabela " . table2 . " nao existe por isso nao pode ser relacionada!"
			return 
		}

		sQry:="INSERT INTO reltable (tabela1,tabela2)`nVALUES`n ('" . table1 . "','" . table2 . "');"
			if (!this.currentDB.Query(sQry)) {
			  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
			  FileAppend, %Msg%, sqliteTestQuery.log
			  throw Exception("Query failed: " Msg)
			 ; MsgBox, 0, Query failed, %Msg%
			}		
	}

	copy(field,newtable,oldtable,primarykey)
	{
		this.currentDB.Query("CREATE TABLE " . newtable . " " . primarykey . ";")
		sql:=" INSERT INTO " newtable . " SELECT " . field . " FROM " . oldtable . ";"
		if (!this.currentDB.Query(sql)) {
					  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
					  throw Exception("Query failed: " Msg)
					 ; MsgBox, 0, Query failed, %Msg%
					}
	}
	;query com recordeset sem verificar erros
	query(sql)
	{
		this.resultSet := this.currentDB.OpenRecordSet(sql)
		return this.resultSet
	}
	;query com recordeset VERIFICANDO ERROS
	queryS(sql)
	{
		;MsgBox, % sql
		;MsgBox, % " query sem exeption!"
		if (!this.currentDB.Query(sql)) {
			  Msg := "xiiiiiiiii! deu merda `n: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
			  throw Exception(Msg)
			 ; MsgBox, 0, Query failed, %Msg%
		}
	}

	;query Simples sem record set.
	iquery(sql)
	{
		this.resultSet := this.currentDB.Query(sql)
		return this.resultSet
	}

	close()
	{
		this.currentDB.Close()
	}
}
	;#iterate
	;table := db.Query("Select * from Test")

	;columnCount := table.Columns.Count()
	;for each, row in table.Rows
	;{
	;	Loop, % columnCount
	;		msgbox % row[A_index]
	;}

;	rs := db.query(sql)
;while(!rs.EOF){   
;  name := rs["tipo"] 
;  phone := rs["tabela1"]  ; column-name oder Index

;  MsgBox %name% %phone%
;  rs.MoveNext()
;}
;rs.Close()