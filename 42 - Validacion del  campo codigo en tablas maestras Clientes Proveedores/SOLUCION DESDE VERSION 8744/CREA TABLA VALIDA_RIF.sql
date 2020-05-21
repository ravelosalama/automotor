USE LIBERTYCARSANUALDB;
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VALIDA_RIF]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[VALIDA_RIF]
GO

CREATE TABLE [dbo].[VALIDA_RIF]

   ([ID_ALTE] VARCHAR(15) UNIQUE NOT NULL , 
	[ID3Org]  VARCHAR(15) NULL ,
	[ID3]     VARCHAR(15) NULL ,
    [TIPOID3] INT NULL )
ON [PRIMARY]
GO
----------------

declare @TNAME CHAR(10)
declare @ALIAS CHAR(10)
SET @TNAME = 'VALIDA_RIF'
SET @ALIAS = 'VALIDA_RIF'
 
Delete SATABL
Where TableName=@TNAME
 
DELETE SAFIEL
Where TableName=@TNAME

Insert Into SATABL
(tablename, tablealias)
Values (@TNAME, @ALIAS)

Insert Into  SAFIEL 
(TableName, FieldName, FieldAlias, DataType, Selectable, Searchable, Sortable, AutoSearch, Mandatory)
 
(Select A.Name As TableName, B.Name As FieldName, B.Name As FieldAlias, 
       Case B.XType
    When 56  Then 'dtLongInt'
	When 58  Then 'dtInteger'
	When 106 Then 'dtDouble'
        When 167 Then 'dtString'
        When 61  Then 'dtDateTime'
	When 35  Then 'dtMemo'
        When 52  Then 'dtInteger'
	When 34  Then 'dtGraphic'
	When 165 Then 'dtBlob'        
        End As DataType,
       'T' Selectable, 
       'T' Searchable,  
       'T' Sortable, 
       'F' AutoSearch, 
       'F' Mandatory
from SysObjects A, syscolumns B 
where A.name=@TNAME
and   A.Id=B.Id
) 