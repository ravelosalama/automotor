 DROP VIEW dbo.VW_ADM_libro_Vehiculo
GO
CREATE VIEW dbo.VW_ADM_Libro_vehiculo
AS

 
SELECT Y.Color,                                                 
       Y.Kilometraje, 
       Y.Serial, 
       Y.Serial_motor, 
       Y.CodProd                                          AS PLACA,
 Right(Y.Serial,6)                                        AS SERIAL_CORTO,
       
       X.NumeroD                                             AS NROVENTA,                                              
       X.TipoFac,
       x.coditem                    as modelo,
       W.TipoCom, 
       W.NumeroD                                             AS NROCOMPRA, 
       V.CodProv,
       V.Descrip                                                AS PROVEEDOR,
       V.MONTO                                                  AS SUBTOTAL_COM,
       V.FECHAE                                                 AS REGISTRO_COM,
       V.TGravable                                              AS GRAVABLE_COM,
       V.Mtotax                                                 AS TAX_COM,
       V.TExento                                                AS EXENTO_COM,
      (V.MONTO + V.MTOTAX)                                      AS TOTAL_COM,
       V.FECHAI                                                 AS EMISION_COM,
       Z.NOTAS4                                                 AS CERT_ORIGEN,
       Z.CodClie, 
       Z.Descrip                                                AS CLIENTE,
       Z.MONTO                                                  AS SUBTOTAL_FAC,
       Z.TGRAVABLE                                              AS GRAVABLE_FAC,
       Z.MTOTAX                                                 AS TAX_FAC,
       Z.TEXENTO                                                AS EXENTO_FAC,
      (Z.MONTO + Z.MTOTAX)                                 AS TOTAL_FAC,
       Z.NOTAS3                                                 AS FINANCIA,
      
       Z.FECHAE                                                 AS EMISION_FAC,
       Z.CODVEND                                                AS CODVEND,
       Z.MONTO-V.MONTO                                         AS UTILIDAD
                                                 

FROM         SASEPRFAC X INNER JOIN
                      SAPROD_12_01 Y ON X.NroSerial = Y.Serial AND X.CodItem = Y.Modelo INNER JOIN
                      SAFACT Z ON X.TipoFac = Z.TipoFac AND X.NumeroD = Z.NumeroD INNER JOIN
                      SASEPRCOM W ON X.NroSerial = W.NroSerial INNER JOIN
                      SACOMP V ON W.NumeroD = V.NumeroD AND W.TipoCom = V.TipoCom
WHERE     (X.TipoFac = 'A') AND (Z.NumeroR IS NULL OR
                      Z.NumeroR = '') AND (W.TipoCom = 'H')   





  
GO
----------------

declare @TNAME CHAR(21)
declare @ALIAS CHAR(21)
SET @TNAME = 'VW_ADM_libro_vehiculo'
SET @ALIAS = 'VW_ADM_libro_vehiculo'
 
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

