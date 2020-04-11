FormatSQL(ByRef fnText,fnAllowFormatAlterationsSql := 0)
{
	; function description
	; MsgBox fnText: %fnText%`nfnAllowFormatAlterationsSql: %fnAllowFormatAlterationsSql%`n


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnText
			Return ReturnValue


		; initialise variables


		; data types
		DataTypesList =
		( LTrim Join, Comments
			bigint,binary,bit
			char,character
			date,datetime,datetime2,datetimeoffset,dec,decimal
			float
			image,int,integer
			money
			national,nchar,numeric,ntext,nvarchar
			real
			smalldatetime,smallint,smallmoney,sql_variant,sysname
			text,time,timestamp,tinyint
			uniqueidentifier
			varbinary,varchar,varying
			; xml
		)

		; t-sql keywords
		KeywordsList =
		( LTrim Join, Comments
			ABSOLUTE,ACTION,ADD,ADMIN,AFTER,AGGREGATE,ALIAS,ALL,ALLOCATE,ALTER,AND,ANSI_DEFAULTS,ANSI_NULL_DFLT_OFF,ANSI_NULL_DFLT_ON,ANSI_NULLS,ANSI_PADDING,ANSI_WARNINGS,ANY,APPLY,ARE,ARITHABORT,ARITHIGNORE,ARRAY,AS,ASC,ASENSITIVE,ASSERTION,ASYMMETRIC,AT,ATOMIC,AUTHORIZATION,AVG
			BACKUP,BEFORE,BEGIN,BETWEEN,BINARY,BLOB,BOOLEAN,BOTH,BREADTH,BREAK,BROWSE,BULK,BY
			CALL,CALLED,CARDINALITY,CASCADE,CASCADED,CASE,CAST,CATALOG,CATCH,CHARINDEX,CHECKDB,CHECKPOINT,CHECKSUM,CLASS,CLOB,CLOSE,CLUSTERED,COALESCE,COLLATE,COLLATION,COLLECT,COLUMN,COLUMNS_UPDATED,COMMIT,COMMITTED,COMPLETION,COMPRESSION,COMPUTE,CONCAT_NULL_YIELDS_NULL,CONDITION,CONNECT,CONNECTION,CONSTRAINT,CONSTRAINTS,CONSTRUCTOR,CONTAINS,CONTAINSTABLE,CONTINUE,CONVERT,CORR,CORRESPONDING,COUNT,COVAR_POP,COVAR_SAMP,CREATE,CROSS,CUBE,CUME_DIST,CURRENT,CURRENT_CATALOG,CURRENT_DATE,CURRENT_DEFAULT_TRANSFORM_GROUP,CURRENT_PATH,CURRENT_ROLE,CURRENT_SCHEMA,CURRENT_TIME,CURRENT_TIMESTAMP,CURRENT_TRANSFORM_GROUP_FOR_TYPE,CURRENT_USER,CURSOR,CURSOR_CLOSE_ON_COMMIT,CYCLE ;,CHECK
			DATA,DATABASE,DATA_COMPRESSION,DATALENGTH,DATEADD,DATEDIFF,DATEFIRST,DATEFORMAT,DATEPART,DAY,DBCC,DEADLOCK_PRIORITY,DEALLOCATE,DECLARE,DECRYPTBYKEY,DEFAULT,DEFERRABLE,DEFERRED,DELAY,DELETE,DENSE_RANK,DENY,DEPTH,DEREF,DESC,DESCRIBE,DESCRIPTOR,DESTROY,DESTRUCTOR,DETERMINISTIC,DIAGNOSTICS,DICTIONARY,DISABLE,DISCONNECT,DISK,DISTINCT,DISTRIBUTED,DOMAIN,DOUBLE,DROP,DROPCLEANBUFFERS,DUMP,DYNAMIC
			EACH,ELEMENT,ELSE,END,END-EXEC,EQUALS,ERROR,ERROR_LINE,ERROR_MESSAGE,ERROR_NUMBER,ERROR_PROCEDURE,ERROR_SEVERITY,ERROR_STATE,ESCAPE,EVENTDATA,EVERY,EXCEPT,EXCEPTION,EXEC,EXECUTE,EXISTS,EXIT,EXTERNAL
			FALSE,FETCH,FILE,FILLFACTOR,FILTER,FIPS_FLAGGER,FIRST,FMTONLY,FOR,FORCEPLAN,FORCESCAN,FORCESEEK,FOREIGN,FOUND,FREE,FREEPROCCACHE,FREETEXT,FREETEXTTABLE,FROM,FULL,FULLTEXTTABLE,FUNCTION,FUSION
			GENERAL,GET,GETDATE,GETUTCDATE,GLOBAL,GO,GOTO,GRANT,GROUP,GROUPING
			HASHBYTES,HAVING,HOLD,HOLDLOCK,HOST,HOUR
			IDENTITY,IDENTITY_INSERT,IDENTITYCOL,IF,IGNORE,IGNORE_CONSTRAINTS,IGNORE_TRIGGERS,IMMEDIATE,IMPLICIT_TRANSACTIONS,IN,INCLUDE,INDEX,INDICATOR,INITIALIZE,INITIALLY,INNER,INOUT,INPUT,INSERT,INTERSECT,INTERSECTION,INTERVAL,INTO,IO,IS,ISDATE,ISNULL,ISNUMERIC,ISOLATION,ITERATE
			JOIN
			KEEPIDENTITY,KEEPDEFAULTS,KEY,KILL
			LANGUAGE,LARGE,LAST,LATERAL,LEADING,LEFT,LEN,LESS,LEVEL,LIKE,LIKE_REGEX,LIMIT,LINENO,LN,LOAD,LOCAL,LOCALTIME,LOCALTIMESTAMP,LOCATOR,LOCK_TIMEOUT,LOG,LOWER,LTRIM
			MAP,MATCH,MATCHED,MAX,MAXDOP,MEMBER,MERGE,METHOD,MIN,MINUTE,MOD,MODIFIES,MODIFY,MODULE,MONTH,MULTISET
			NAMES,NATURAL,NCLOB,NEW,NEXT,NO,NOCHECK,NOCOUNT,NOEXEC,NOEXPAND,NOFORMAT,NOINIT,NOLOCK,NONCLUSTERED,NONE,NOREWIND,NORMALIZE,NOT,NOUNLOAD,NOWAIT,NTILE,NULL,NULLIF,NUMERIC_ROUNDABORT
			OBJECT,OBJECT_ID,OBJECT_NAME,OCCURRENCES_REGEX,OF,OFF,OFFSETS,OLD,ON,ONLY,OPEN,OPENDATASOURCE,OPENQUERY,OPENROWSET,OPENXML,OPERATION,OPTION,OPTIONS,OR,ORDER,ORDINALITY,OUT,OUTER,OUTPUT,OVER,OVERLAY
			PAD,PAGE,PAGLOCK,PARAMETER,PARAMETERS,PARSEONLY,PARTIAL,PARTITION,PATH,PATINDEX,PERCENT,PERCENT_RANK,PERCENTILE_CONT,PERCENTILE_DISC,PERSISTED,PIVOT,PLAN,POSITION_REGEX,POSTFIX,POWER,PRECISION,PREFIX,PREORDER,PREPARE,PRESERVE,PRIMARY,PRINT,PRIOR,PRIVILEGES,PROC,PROCID,PROCEDURE,PROFILE,PUBLIC,RAISERROR
			QUERY_GOVERNOR_COST_LIMIT,QUOTED_IDENTIFIER
			RANGE,RANK,READ,READCOMMITTED,READCOMMITTEDLOCK,READONLY,READPAST,READS,READTEXT,READUNCOMMITTED,REAL,REBUILD,RECOMPILE,RECONFIGURE,RECURSIVE,REFERENCES,REFERENCING,REGR_AVGX,REGR_AVGY,REGR_COUNT,REGR_INTERCEPT,REGR_R2,REGR_SLOPE,REGR_SXX,REGR_SXY,REGR_SYY,RELATIVE,RELEASE,REMOTE_PROC_TRANSACTIONS,REPEATABLE,REPEATABLEREAD,REPLACE,REPLICATE,REPLICATION,RESTORE,RESTRICT,RESULT,RETURN,RETURNS,REVERSE,REVERT,REVOKE,RIGHT,ROLE,ROLLBACK,ROLLUP,ROUND,ROUTINE,ROW,ROWCOUNT,ROWGUIDCOL,ROWLOCK,ROWS,RTRIM,RULE ;,REF
			SAVE,SAVEPOINT,SCHEMA,SCOPE,SCOPE_IDENTITY,SCROLL,SEARCH,SECOND,SECTION,SECURITYAUDIT,SELECT,SEMANTICKEYPHRASETABLE,SEMANTICSIMILARITYDETAILSTABLE,SEMANTICSIMILARITYTABLE,SENSITIVE,SEQUENCE,SERIALIZABLE,SERVERPROPERTY,SESSION,SESSION_USER,SET,SETERROR,SETS,SETUSER,SHOWPLAN_ALL,SHOWPLAN_TEXT,SHOWPLAN_XML,SHUTDOWN,SIMILAR,SIZE,SKIP,SNAPSHOT,SOME,SOURCE,SPACE,SPATIAL_WINDOW_MAX_CELLS,SPECIFIC,SPECIFICTYPE,SPID,SQL,SQLEXCEPTION,SQLSTATE,SQLWARNING,START,STATE,STATEMENT,STATIC,STATISTICS,STATS,STDDEV_POP,STDDEV_SAMP,STDEV,STDEVP,STR,STRUCTURE,STUFF,SUBMULTISET,SUBSTRING,SUBSTRING_REGEX,SUM,SUSER_NAME,SUSER_SNAME,SYMMETRIC,SYNONYM,SYSTEM,SYSTEM_TIME,SYSTEM_USER,SYSUTCDATETIME
			TABLE,TABLESAMPLE,TABLOCK,TABLOCKX,TARGET,TEMPORARY,TERMINATE,TEXTSIZE,THAN,THEN,THROW,TIMESTAMP,TIMEZONE_HOUR,TIMEZONE_MINUTE,TO,TOP,TRACEOFF,TRACEON,TRAILING,TRAN,TRANSACTION,TRANSLATE_REGEX,TRANSLATION,TREAT,TRIGGER,TRIGGER_NESTLEVEL,TRUE,TRUNCATE,TRY,TRY_CONVERT,TRY_PARSE,TSEQUAL
			UESCAPE,UNCOMMITTED,UNDER,UNION,UNIQUE,UNKNOWN,UNNEST,UNPIVOT,UPDATE,UPDATETEXT,UPDLOCK,UPPER,USAGE,USE,USER,USER_NAME,USEROPTIONS,USING
			VALUE,VALUES,VAR,VAR_POP,VAR_SAMP,VARIABLE,VARP,VERIFYONLY,VIEW
			WAITFOR,WHEN,WHENEVER,WHERE,WHILE,WIDTH_BUCKET,WINDOW,WITH,WITHIN,WITHOUT,WORK,WRITE,WRITETEXT
			XACT_ABORT,XLOCK,XML,XMLAGG,XMLATTRIBUTES,XMLBINARY,XMLCAST,XMLCOMMENT,XMLCONCAT,XMLDOCUMENT,XMLELEMENT,XMLEXISTS,XMLFOREST,XMLITERATE,XMLNAMESPACES,XMLPARSE,XMLPI,XMLQUERY,XMLSERIALIZE,XMLTABLE,XMLTEXT,XMLVALIDATE
			YEAR
			ZONE
		)

		; system views
		SystemViewsList =
		( LTrim Join, Comments
			INFORMATION_SCHEMA.CHECK_CONSTRAINTS
			INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE
			INFORMATION_SCHEMA.COLUMN_PRIVILEGES
			INFORMATION_SCHEMA.COLUMNS
			INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
			INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
			INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS
			INFORMATION_SCHEMA.DOMAINS
			INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			INFORMATION_SCHEMA.PARAMETERS
			INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
			INFORMATION_SCHEMA.ROUTINE_COLUMNS
			INFORMATION_SCHEMA.ROUTINES
			INFORMATION_SCHEMA.SCHEMATA
			INFORMATION_SCHEMA.TABLE_CONSTRAINTS
			INFORMATION_SCHEMA.TABLE_PRIVILEGES
			INFORMATION_SCHEMA.TABLES
			INFORMATION_SCHEMA.VIEW_COLUMN_USAGE
			INFORMATION_SCHEMA.VIEW_TABLE_USAGE
			INFORMATION_SCHEMA.VIEWS
		)

		; database names
		DatabaseNamesList =
		( LTrim Join, Comments
			LiteSpeedLocal
			MDS
		)

		; schema names
		SchemaNamesList =
		( LTrim Join, Comments
			dbo.
			guest.
			INFORMATION_SCHEMA.
			sys.
			util.
		)

		; complete list
		WordList =
		( LTrim Join, Comments
			%DataTypesList%
			%KeywordsList%
			%SystemViewsList%
			%DatabaseNamesList%
			%SchemaNamesList%
		)
		
		
		; create pseudo array of each word to be formatted
		Loop, Parse, WordList, CSV 
		{
			Word%A_Index% := A_LoopField
			NumWords := A_Index
		}
		
		
		; prepare the text
		NormaliseLineEndings(fnText)
		NewText := fnText
		FormatStoreStrings(NewText,"/*nf>*/","/*<nf*/","NoFormat")
		FormatStoreStrings(NewText,"'",,"SingleQuotes")
		FormatStoreStrings(NewText,"[","]","Brackets")
		FormatStoreComments(NewText,"--")
		FormatStoreStrings(NewText,"/*","*/","StreamComments")
		

		; loop through each word, replacing each instance with its correctly formatted version
		Loop, %NumWords% 
		{
			Word := StrReplace(Word%A_Index%,".","\.")
			ReplaceString := Word%A_Index%
			PCRE := "imS)(?<![@#])\b" Word "\b"
			
			If Word in %DataTypesList%
				PCRE := "imS)(?<![@#])\[?\b" Word "\b\]?"
			
			NewText := RegExReplace(NewText,PCRE,ReplaceString)

			If (Word = "MAX")
			{
				PCRE := "imS)\(MAX\)"
				ReplaceString := "(max)"
				NewText := RegExReplace(NewText,PCRE,ReplaceString)
			}
		}
		
		
		; additional formatting
		If fnAllowFormatAlterationsSql
		{
			SystemColumnNames := "address|data|file_id|master|name|object_id|rows|schema_id|type|type_desc|type_name|value"
			PCRE    := "imS)\b(" SystemColumnNames ")\b"
			NewText := RegExReplace(NewText,PCRE,"$l1")
			PCRE    := "imS)(?<![\[_@#])\b(" SystemColumnNames ")\b(?!\])(\s*)(?!\()" ; delimit certain system column names
			NewText := RegExReplace(NewText,PCRE,"[$l1]$2")
			PCRE    := "imS)(?<!\[)\b(object_id|object_name|schema_id|type_name)\b(?!\])(\s*)(?=\()" ; functions with same name as system columns
			NewText := RegExReplace(NewText,PCRE,"$u1$2")

			PCRE    := "S)([^<>+\-*/ `t])([<>+\-*/])?([=])"
			NewText := RegExReplace(NewText,PCRE,"$1 $2$3") ; one space in front of any equals
			PCRE    := "S)([=])([^ `t])"
			NewText := RegExReplace(NewText,PCRE,"$1 $2") ; one space after any equals
			PCRE    := "S)([^ `t])([<>])"
			NewText := RegExReplace(NewText,PCRE,"$1 $2") ; space around gte, lte
			PCRE    := "S)([<>])([^= `t])"
			NewText := RegExReplace(NewText,PCRE,"$1 $2 $3") ; space around gte, lte
		
			PCRE    := "S)[ `t]*[!][ `t]*[=][ `t]*"
			NewText := RegExReplace(NewText,PCRE," <> ") ; replace != with ANSI <>
			PCRE    := "S)[ `t]*[<][ `t]*[>][ `t]*"
			NewText := RegExReplace(NewText,PCRE," <> ") ; format <> correctly

			PCRE    := "iS)([^\d])(1[ `t]=[ `t])(1|0)"
			NewText := RegExReplace(NewText,PCRE,"$11=$3") ; contract 1 = 1 and 1 = 0 to 1=1, 1=0

			PCRE    := "imS)(top)(\s+?)([\d]+?)(\s+?)"
			NewText := RegExReplace(NewText,PCRE,"TOP($3) ") ; surround TOP n digits with parentheses e.g. TOP (n)

			PCRE    := "xiS`a) ([,]) ([\t ]*) (--.*)? (\R) ([\t ]*) (--)?"
			NewText := RegExReplace(NewText,PCRE,"$2$3$4$5$6$1 ") ; move trailing comma to leading comma on next line
			PCRE    := "xiS`a) ([\t ]OR) ([\t ]*) (--.*)? (\R) ([\t ]*) (--)?"
			NewText := RegExReplace(NewText,PCRE,"$2$3$4$5$6$1 ") ; move trailing OR to leading OR on next line
			PCRE    := "xiS`a) ([\t ]AND) ([\t ]*) (--.*)? (\R) ([\t ]*) (--)?"
			NewText := RegExReplace(NewText,PCRE,"$2$3$4$5$6$1 ") ; move trailing AND to leading AND on next line

			PCRE    := "imS)(?<!_)INSERT[ `t]+(INTO)?[ `t]*"
			NewText := RegExReplace(NewText,PCRE,"INSERT INTO ") ; INSERT to INSERT INTO
			PCRE    := "imS)BULK INSERT INTO"
			NewText := RegExReplace(NewText,PCRE,"BULK INSERT") ; INSERT to INSERT INTO

			PCRE    := "imS)JOIN"
			NewText := RegExReplace(NewText,PCRE,"INNER JOIN") ; JOIN to INNER JOIN
			PCRE    := "imS)(INNER|OUTER|CROSS)[ `t]+INNER JOIN"
			NewText := RegExReplace(NewText,PCRE,"$1 JOIN") ; remove erroneous INNER for outer joins
			PCRE    := "imS)(LEFT|RIGHT|FULL)[ `t]+INNER JOIN"
			NewText := RegExReplace(NewText,PCRE,"$1 OUTER JOIN") ; swap erroneous INNER for OUTER joins

			TotalCountOfReplacements := 1 ; force entry into while loop
			While TotalCountOfReplacements > 0
			{
				PCRE    := "xiS) (\([^\)]*?) ([,][ ]) (?=[^\)]*\))" ; comma-space between brackets
				NewText := RegExReplace(NewText,PCRE,"$1,$3",CountOfReplacements)
				TotalCountOfReplacements := CountOfReplacements

				PCRE    := "xiS) (\([^\)]*?) ([ ][,]) (?=[^\)]*\))" ; space-comma between brackets
				NewText := RegExReplace(NewText,PCRE,"$1,",CountOfReplacements)
				TotalCountOfReplacements += CountOfReplacements
			}

			TotalCountOfReplacements := 1 ; force entry into while loop
			While TotalCountOfReplacements > 0
			{
				PCRE    := "xiS) [(][ ] (.*?) [)]" ; space after an opening bracket
				NewText := RegExReplace(NewText,PCRE,"($1)",CountOfReplacements)
				TotalCountOfReplacements := CountOfReplacements

				PCRE    := "xiS) [(] (.*?) [ ][)]" ; space before a closing bracket
				NewText := RegExReplace(NewText,PCRE,"($1)",CountOfReplacements)
				TotalCountOfReplacements += CountOfReplacements
			}

			PCRE    := "imS)([ \t])([\+\-\*\/\%])([ \t])"
			NewText := RegExReplace(NewText,PCRE,"$2") ; whitespace around maths symbols
			PCRE    := "imS)SELECT\*"
			NewText := RegExReplace(NewText,PCRE,"SELECT * ") ; preserve SELECT *
			PCRE    := "imS)[ \t]*\*[ \t]*FROM"
			NewText := RegExReplace(NewText,PCRE," * FROM") ; preserve * FROM

			PCRE    := "ximSU) (CAST) (\s*) ([(]) (\s*) (.*) (\s+AS\s+) (image|text|uniqueidentifier|date|time|datetime2|datetimeoffset|tinyint|smallint|int|smalldatetime|real|money|datetime|float|sql_variant|ntext|bit|decimal|numeric|smallmoney|bigint|hierarchyid|geometry|geography|varbinary|varchar|binary|char|timestamp|nvarchar|nchar|xml|sysname) (\s*) ([(]([\d]+|max)[,]?[\d]*[)])? (\s*) ([)]) "
			NewText := RegExReplace(NewText,PCRE,"CONVERT($7$9,$5)") ; cast function to convert function

			PCRE    := "imS)(CONVERT[(])(n)?(varchar)([,])"
			NewText := RegExReplace(NewText,PCRE,"CONVERT($2varchar(30),") ; explicit value for default varchar

			PCRE    := "ximS) (EXISTS) (\s*) ([(]) (\s*) (SELECT) (\s*) (TOP[(][\d]+[)])? (\s*) ([\d]+) "
			NewText := RegExReplace(NewText,PCRE,"$1$2$3$4$5$6$7$8*") ; EXISTS (SELECT [TOP (1)] 1 ... to EXISTS (SELECT * ...

			PCRE    := "imS)COUNT[(]1[)]"
			NewText := RegExReplace(NewText,PCRE,"COUNT(*)")

			PCRE    := "imS)(char|decimal|numeric|float|datetime2|datetimeoffset|time)([ \t]+[(])"
			NewText := RegExReplace(NewText,PCRE,"$1(")

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(year|yyyy)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3yy$5") ; year

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(quarter|q)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3qq$5") ; quarter

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(month|m)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3mm$5") ; month

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(dayofyear|y)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3dy$5") ; dayofyear

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(day|d)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3dd$5") ; day

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(week|ww)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3wk$5") ; week

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(weekday|w)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3dw$5") ; weekday

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(hour)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3hh$5") ; hour

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(minute|n)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3mi$5") ; minute

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(second|s)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3ss$5") ; second

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(millisecond)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3ms$5") ; millisecond

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(microsecond)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3mcs$5") ; microsecond

			PCRE    := "imS)(DATE)(ADD|DIFF|PART)([(])(nanosecond)(,)"
			NewText := RegExReplace(NewText,PCRE,"$1$2$3ns$5") ; nanosecond

			PCRE    := "imS)(DROP INDEX \[.*\])( WITH \(.*\))?\R+"
			NewText := RegExReplace(NewText,PCRE,"$1$2`n")

			PCRE    := "imS)(DROP INDEX)(.*)\RGO\R+(?=DROP INDEX)"
			NewText := RegExReplace(NewText,PCRE,"$1$2`n$3")

			PCRE    := "imS)(DROP INDEX)(.*)\R(DROP TABLE)"
			NewText := RegExReplace(NewText,PCRE,"$1$2`n`n$3")

			PCRE    := "imS)SET ANSI_NULLS ON\R+GO\R+"
			NewText := RegExReplace(NewText,PCRE,"")

			PCRE    := "imS)SET QUOTED_IDENTIFIER ON\R+GO\R+"
			NewText := RegExReplace(NewText,PCRE,"")

			PCRE    := "imS)SET ANSI_PADDING (ON|OFF)\R+GO\R+"
			NewText := RegExReplace(NewText,PCRE,"")

			PCRE    := "imS)(DROP TABLE \[.*\]\.\[.*\])\R+GO\R+"
			NewText := RegExReplace(NewText,PCRE,"$1`nGO`n`n")

			PCRE    := "imSU)CREATE TABLE \[(.*)\]\.\[(.*)\]\s*?\(\R(\s*?)"
			NewText := RegExReplace(NewText,PCRE,"CREATE TABLE $1.$2 (`n$3  ")

			PCRE    := "imSU), CONSTRAINT (.*)\R\(\R\s*?(.*)\R\)"
			NewText := RegExReplace(NewText,PCRE,", CONSTRAINT $1 ($2)") ; 

			PCRE    := "imS)(CREATE (UNIQUE )?(NON)?CLUSTERED INDEX \[.*?\]) (ON \[.*?\]\.\[.*?\])\R\(\R\s*"
			NewText := RegExReplace(NewText,PCRE,"$1`n$4 (")

			PCRE    := "imS)\)\s*?WITH \(PAD_INDEX(.*?)\) (ON \[(INDEX|PRIMARY)\])"
			NewText := RegExReplace(NewText,PCRE,")`nWITH (PAD_INDEX$1)`n$2")

			PCRE    := "imS)(IDENTITY[(]\d+[,]\d+[)])(\s+)(NOT)(\s+)?(NULL)" ; )
			NewText := RegExReplace(NewText,PCRE,"$3 $5 $1")

			PCRE    := "imSU)INCLUDE \(\s*?(.*)\R\s*?,\s*?([^\)]*)"
			CountOfReplacements := 1 ; just to force entry into while loop
			While CountOfReplacements > 0
				NewText := RegExReplace(NewText,PCRE,"INCLUDE ($1,$2",CountOfReplacements)

			PCRE    := "imSU)ON \[(.*)\]\.\[(.*)\] \(\[(.*)\] (ASC|DESC)\R\s*?"
			CountOfReplacements := 1 ; just to force entry into while loop
			While CountOfReplacements > 0
				NewText := RegExReplace(NewText,PCRE,"ON [$1].[$2] ([$3] $4",CountOfReplacements)

			PCRE    := "imS)varchar[(]max[)]"
			NewText := RegExReplace(NewText,PCRE,"varchar(max)")

			PCRE    := "imS)n('.*?')" ; capitalize nvarchar prefix
			NewText := RegExReplace(NewText,PCRE,"N$1")

			PCRE    := "imS)(\[?)\b((sp|xp|fn)(_\w*))\b(\]?)" ; add sys schema prefix to system sp calls
			NewText := RegExReplace(NewText,PCRE,"$1sys$5.$1$2$5")
			PCRE    := "imSs)((\[)?(sys|dbo)(\])?\s*\.\s*)((\[)?(sys)(\])?\.)" ; remove double sys.sys.
			NewText := RegExReplace(NewText,PCRE,"$1")

			PCRE    := "imS)\bEXEC\b" 
			NewText := RegExReplace(NewText,PCRE,"EXECUTE")
			PCRE    := "imS)\bEXECUTE\b\(" 
			NewText := RegExReplace(NewText,PCRE,"EXECUTE (")

			PCRE    := "imS)\bPROC\b" 
			NewText := RegExReplace(NewText,PCRE,"PROCEDURE")

			PCRE    := "imS)\b(n?char\((9|10|13)\))" 
			NewText := RegExReplace(NewText,PCRE,"$u1")

			PCRE    := "iS)(JOIN.*?)([ \t]*\R[ \t]*)(ON)([ \t]*)" 
			NewText := RegExReplace(NewText,PCRE,"$1 $3 ")
		}
		
		
		; restore comments and strings
		FormatRestoreStrings(NewText,"StreamComments")
		FormatRestoreComments(NewText)
		FormatRestoreStrings(NewText,"Brackets")
		FormatRestoreStrings(NewText,"SingleQuotes")
		FormatRestoreStrings(NewText,"NoFormat")
		
		
		; line spacing adjustments
		If fnAllowFormatAlterationsSql
		{
			; PCRE    := "imS)(IF[^\r\n]*)\R^\s*BEGIN\s*$" ; BEGIN ends line
			; NewText := RegExReplace(NewText,PCRE,"$1 BEGIN")		
			
			PCRE    := "imS)(\bGO\b\R)(?!\R)" ; ensure empty line after GO
			NewText := RegExReplace(NewText,PCRE,"$1`r`n")
		}

		; trim whitespace from end of line
		PCRE := "imS)([ \t]+)$"
		NewText := RegExReplace(NewText,PCRE,"")
		
		
		; assign back to ByRef parameter
		fnText := NewText

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,1,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
#Include <RegExDebug>
#Include %A_ScriptDir%\ahkfn_FormatRestoreComments.ahk
#Include %A_ScriptDir%\ahkfn_FormatRestoreStreamComments.ahk
#Include %A_ScriptDir%\ahkfn_FormatRestoreStrings.ahk
#Include %A_ScriptDir%\ahkfn_FormatStoreComments.ahk
#Include %A_ScriptDir%\ahkfn_FormatStoreStreamComments.ahk
#Include %A_ScriptDir%\ahkfn_FormatStoreStrings.ahk

; FileRead, SomeText, D:\Users\natha\Desktop\test.sql
; SomeText := "EXEC [sp_helpdb]"
; SomeText := "EXEC sp_helpdb"
; SomeText := "EXEC sys.sp_helpdb"
; SomeText := "EXEC [sys].[sp_helpdb]"
SomeText := "EXEC sp_objectfilegroup @objid = @objid;"
MsgBox, FormatSQL`n`nSomeText`n`n%SomeText%

; FormatSQL(SomeText,0)
; MsgBox, FormatSQL`n`nSomeText`n`n%SomeText%

FormatSQL(SomeText,1)
MsgBox, FormatSQL`n`nSomeText`n`n%SomeText%

ExitApp

^p::
Pause
Return
*/