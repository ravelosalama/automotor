DROP VIEW dbo.VW_PROCOMPETENCIA_13_DIF_CONTADO
GO

CREATE VIEW dbo.VW_PROCOMPETENCIA_13_DIF_CONTADO
AS

SELECT   X.CODITEM
    ,descrip1
    ,SUM(Cantidad)   OVER(PARTITION BY x.coditem) AS 'Totalcantidad'
    ,SUM(Costo)      OVER(PARTITION BY x.coditem) AS 'Totalcosto'
    ,SUM(Precio)      OVER(PARTITION BY x.coditem) AS 'Totalprecio'
    ,AVG(Cantidad)   OVER(PARTITION BY x.coditem) AS 'Promediocantidad'
    ,COUNT(Cantidad) OVER(PARTITION BY x.coditem) AS 'Count'
    ,y.FechaE as Emision
    ,y.NumeroD as documento
    ,y.TipoFac as tipo
    ,z.liquidacion
    ,X.EsServ
      
FROM   SAITEMFAC  AS x INNER JOIN 
       SAFACT     AS y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac  left outer join SAFACT_01 z on x.TipoFac=Z.tipofac and x.NumeroD=z.NumeroD 
      
WHERE Y.CODOPER='01-301' AND (y.TipoFac = 'A') AND (y.NumeroR IS NULL OR y.NumeroR = '') AND (Y.FechaE >= CONVERT(DATETIME, '04/01/2000', 120))
      AND Z.LIQUIDACION<>'CONTADO'
      
-- Order by  X.CODITEM,y.fechae

GO
----------------

declare @TNAME CHAR(32)
declare @ALIAS CHAR(32)
SET @TNAME = 'VW_PROCOMPETENCIA_13_DIF_CONTADO'
SET @ALIAS = 'VW_PROCOMPETENCIA_13_DIF_CONTADO'
 
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






 