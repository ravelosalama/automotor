-- ESTUDIO ESPECIAL (incluye iva)

DROP VIEW dbo.ESTUDIO_ESPECIAL

GO
CREATE VIEW dbo.ESTUDIO_ESPECIAL
AS
                                                  
SELECT     X.FECHAE  AS FECHA_VENTA,
           X.NUMEROD AS VENTA,
           X.MTOTOTAL-X.TEXENTO AS TOTAL_VENTA,
           X.CODCLIE AS RIF,
           X.DESCRIP AS CLIENTE,
           H.FECHAE AS FECHA_COMPRA,
           H.NUMEROD AS COMPRA,
           H.MONTO+H.MTOTAX AS TOTAL_COMPRA,
           M.MODELO   AS MODELO,
           M.CODPROD  AS PLACA,
           X.CODCLIE AS CODCLIE,
           SUBSTRING(STR(MONTH(X.FechaE)),9,2) + SUBSTRING(STR(YEAR(X.FechaE)),7,5) AS MESANO

FROM         SAFACT X INNER JOIN
                      SASEPRFAC Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac INNER JOIN
                      SASEPRCOM Z ON Y.NroSerial = Z.NroSerial INNER JOIN
                      SACOMP H ON H.NumeroD = Z.NumeroD AND H.TipoCom = 'H'INNER JOIN
                      SAPROD_12_01 M ON Z.NroSerial = M.Serial
WHERE      (X.TipoFac = 'A') AND (X.NumeroR IS NULL) and H.TIPOCOM='H'





  
GO
----------------

declare @TNAME CHAR(16)
declare @ALIAS CHAR(16)
SET @TNAME = 'ESTUDIO_ESPECIAL'
SET @ALIAS = 'ESTUDIO_ESPECIAL'
 
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

