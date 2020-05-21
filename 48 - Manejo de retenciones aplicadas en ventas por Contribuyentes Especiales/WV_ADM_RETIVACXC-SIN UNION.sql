-- (*) cambios efectuados en Jun 2012 
-- VIGENTE A MAYO 2013
-- YA NO ESTA VIGENTE

 DROP VIEW dbo.VW_ADM_RETIVACXC
GO
CREATE VIEW dbo.VW_ADM_RETIVACXC WITH ENCRYPTION
AS
 


SELECT     TOP 100 PERCENT 
                      
           Z.FECHAPAGO    AS FPAGO,
           X.CODCLIE      AS RIF,
           Y.DESCRIP      AS CLIENTE,
          (CASE WHEN X.TipoCxC = '41' THEN X.DOCUMENT WHEN X.TipoCxC = '81' THEN X.NUMEROD END) AS NRETENCION,
           X.FECHAE       AS FRETENCION,
           z.NUMEROD      AS FACTURA,
           X.FECHAR       AS FFACTURA,
           Y.TGravable    AS BIMPONIBLE,
           X.MTOTAX       AS IMPUESTO,
           -- (*) W.MTOTAX       AS PIMPUESTO,
           ROUND(X.MTOTAX /x.BASEIMPO *100,0) as PIMPUESTO,
           X.MONTO        AS IRETENIDO,
           -- (*) ROUND(X.MONTO / Y.MTOTAX * 100,0) AS PRETENIDO,
           ROUND(X.reteniva/x.mtotax *100,0) as PRETENIDO,
           X.MTOTAX-X.RETENIVA AS IPERCIBIDO,
           --  (*) el siguiente es campo nuevo 
           y.tgravable+y.mtotax as totalfac
FROM         SASE_RETIVACXC Z INNER JOIN
                      SAACXC X ON Z.NROPPAL = X.NroUnico INNER JOIN
                      SAFACT Y ON Z.NUMEROD = Y.NumeroD INNER JOIN 
                      SATAXVTA W ON Y.NUMEROD=W.NUMEROD
WHERE     (Y.TipoFac = 'A') 


GO
----------------

declare @TNAME CHAR(16)
declare @ALIAS CHAR(16)
SET @TNAME = 'VW_ADM_RETIVACXC'
SET @ALIAS = 'VW_ADM_RETIVACXC'
 
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


