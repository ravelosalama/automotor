 DROP VIEW dbo.LISTADO_SUGERIDO

GO
CREATE VIEW dbo.LISTADO_SUGERIDO
AS
                                                  
SELECT 
       CODPROD AS MODELO,
       FECHA_LISTA AS FECHA_LISTA,
       PRECIO_SUGERIDO_POR_PLANTA AS PRECIO_SUGERIDO,
       SUBSTRING(STR(MONTH(FECHA_LISTA)), 9, 2) + SUBSTRING(STR(YEAR(FECHA_LISTA)), 7, 5) AS MESANO 
        

  FROM SAPROD_11_04
     



  
GO
----------------

declare @TNAME CHAR(16)
declare @ALIAS CHAR(16)
SET @TNAME = 'LISTADO_SUGERIDO'
SET @ALIAS = 'LISTADO_SUGERIDO'
 
Delete SATABL
Where TableName=@TNAME
 
DELETE SAFIEL
Where TableName=@TNAME

Insert Into SATABL
(tablename, tablealias)
Values (@TNAME, @ALIAS)

Insert Into  SAFIEL 
(TableName, FieldName, FieldAlias, DataType, Selectable, Searchable, Sortable, AutoSearch, Mandatory)
 
(
Select A.Name As TableName, B.Name As FieldName, B.Name As FieldAlias, 
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

