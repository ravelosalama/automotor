DROP VIEW dbo.SESA_RP_ITEMFACTSERVICIO
GO
CREATE VIEW dbo.SESA_RP_ITEMFACTSERVICIO -- WITH ENCRYPTION
-- CREATE VIEW dbo.SESA_RP_ITEMFACTSERVICIO
AS
SELECT  SAITEMFAC.CODMECA,  
        SAITEMFAC.TIPOFAC,
	SAITEMFAC.NUMEROD,
	SAITEMFAC.NROLINEA,
	SAITEMFAC.CODITEM,
	SAITEMFAC.DESCRIP1,
	SAITEMFAC.PRECIO,
	SAITEMFAC.CANTIDAD,
	SAITEMFAC.CANTIDAD*SAITEMFAC.PRECIO AS SUBTOTAL,
	0 AS NUMERO
FROM    dbo.SAITEMFAC  SAITEMFAC INNER JOIN DBO.SAPROD
ON	SAITEMFAC.CODITEM=SAPROD.CODPROD
WHERE  	SAITEMFAC.ESSERV=0

UNION

SELECT SAITEMFAC.CODMECA,
       SAITEMFAC.TIPOFAC,
	SAITEMFAC.NUMEROD,
	SAITEMFAC.NROLINEA,
	SAITEMFAC.CODITEM,
	SAITEMFAC.DESCRIP1,
	SAITEMFAC.PRECIO,
	SAITEMFAC.CANTIDAD,
	SAITEMFAC.CANTIDAD*SAITEMFAC.PRECIO AS SUBTOTAL,
	CASE WHEN SASERV.CODINST=14 THEN 2 ELSE 1 END AS NUMERO
FROM    dbo.SAITEMFAC  SAITEMFAC INNER JOIN DBO.SASERV
ON	SAITEMFAC.CODITEM=SASERV.CODSERV
WHERE  	SAITEMFAC.ESSERV=1



GO
----------------

declare @TNAME CHAR(24)
declare @ALIAS CHAR(24)
SET @TNAME = 'SESA_RP_ITEMFACTSERVICIO'
SET @ALIAS = 'SESA_RP_ITEMFACTSERVICIO'
 
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


