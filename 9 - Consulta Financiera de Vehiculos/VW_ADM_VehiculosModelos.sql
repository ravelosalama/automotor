DROP VIEW dbo.VW_ADM_VehiculoModelo
GO
CREATE VIEW dbo.VW_ADM_VehiculoModelo
AS

SELECT SAPROD_12_01.Color,                                                 
       SAPROD_12_01.Kilometraje, 
       SAPROD_12_01.Serial, 
       SAPROD_12_01.Serial_motor, 
       SAPROD_12_01.CodProd                                          AS PLACA,
 Right(SAPROD_12_01.Serial,6)                                        AS SERIAL_CORTO,
       SAPROD_11_01.Ano, 
       SAPROD_11_01.Cilindros, 
       SAPROD_11_01.Clase, 
       SAPROD_11_01.CodProd                                          AS COD_MODELO,
       SAPROD_11_01.Peso, 
       SAPROD_11_01.Puestos, 
       SAPROD_11_01.Tipo,
       SAPROD_11_01.Uso, 
       SASEPRFAC.NumeroD                                             AS NROVENTA,                                              
       SASEPRFAC.TipoFac,
       SASEPRCOM.TipoCom, 
       SASEPRCOM.NumeroD                                             AS NROCOMPRA, 
       SACOMP.CodProv,
       SACOMP.Descrip                                                AS PROVEEDOR,
       SACOMP.MONTO                                                  AS SUBTOTAL_COM,
       SACOMP.FECHAE                                                 AS REGISTRO_COM,
       SACOMP.TGravable                                              AS GRAVABLE_COM,
       SACOMP.Mtotax                                                 AS TAX_COM,
       SACOMP.TExento                                                AS EXENTO_COM,
      (SACOMP.MONTO + SACOMP.MTOTAX)                                 AS TOTAL_COM,
       SACOMP.FECHAI                                                 AS EMISION_COM,
       SAFACT.NOTAS4                                                 AS CERT_ORIGEN,
       SAFACT.CodClie, 
       SAFACT.Descrip                                                AS CLIENTE,
       SAFACT.MONTO                                                  AS SUBTOTAL_FAC,
       SAFACT.TGRAVABLE                                              AS GRAVABLE_FAC,
       SAFACT.MTOTAX                                                 AS TAX_FAC,
       SAFACT.TEXENTO                                                AS EXENTO_FAC,
      (SAFACT.MONTO + SAFACT.MTOTAX)                                 AS TOTAL_FAC,
       SAFACT.NOTAS3                                                 AS FINANCIA,
      
       SAFACT.FECHAE                                                 AS EMISION_FAC,
       SAFACT.CODVEND                                                AS CODVEND,
       SAVEND.DESCRIP                                                AS VENDEDOR,
      (CASE WHEN SAFACT_01.STATUS = 'ANULADA' AND SAFACT_01.LIQUIDACION IS NOT NULL THEN 'ANULADA' ELSE 'CONFIRMADA' END) AS CONDICION, 
       SAPROD.Descrip                                                AS MODELO,
       SAACXP.SALDO                                                  AS SALDO_COM,
       SAACXC.SALDO                                                  AS SALDO_FAC,
       SAFACT.MONTO-SACOMP.MONTO                                     AS UTILIDAD,
       SACOMP_01.GUIA                                                AS GUIA
      
FROM SAPROD_12_01 SAPROD_12_01
      LEFT OUTER JOIN SAPROD_11_01 SAPROD_11_01 ON 
     (SAPROD_11_01.CodProd = SAPROD_12_01.modelo)
      LEFT OUTER JOIN SASEPRCOM SASEPRCOM ON 
     (SASEPRCOM.NroSerial = SAPROD_12_01.Serial)
      LEFT OUTER JOIN SASEPRFAC SASEPRFAC ON 
     (SASEPRFAC.NroSerial = SAPROD_12_01.Serial)
      LEFT OUTER JOIN SACOMP SACOMP ON 
     (SACOMP.TipoCom = SASEPRCOM.TipoCom)
      AND (SACOMP.NumeroD = SASEPRCOM.NumeroD)
      LEFT OUTER JOIN SAFACT SAFACT ON 
     (SAFACT.TipoFac = SASEPRFAC.TipoFac)
      AND (SAFACT.NumeroD = SASEPRFAC.NumeroD)
      LEFT OUTER JOIN SAPROD SAPROD ON 
     (SAPROD.CodProd = SAPROD_12_01.modelo)
      LEFT OUTER JOIN SAACXP SAACXP ON
     (SAACXP.NUMEROD = SACOMP.NUMEROD)
      AND (SAACXP.CODPROV = SACOMP.CODPROV)AND SAACXP.TIPOCXP='10'
      LEFT OUTER JOIN SAACXC SAACXC ON
     (SAACXC.NUMEROD = SAFACT.NUMEROD) 
      AND (SAACXC.CODCLIE = SAFACT.CODCLIE)AND SAACXC.TIPOCXC='10'
      LEFT OUTER JOIN SAFACT_01 SAFACT_01 ON
     (SAFACT_01.NUMEROD = SAFACT.NUMEROD AND SAFACT_01.TIPOFAC = SAFACT.TIPOFAC)
      LEFT OUTER JOIN SACOMP_01 SACOMP_01 ON
     (SACOMP_01.NUMEROD=SACOMP.NUMEROD AND SACOMP_01.TIPOCOM=SACOMP.TIPOCOM)
      LEFT OUTER JOIN SAVEND SAVEND ON
     (SAFACT.CODVEND = SAVEND.CODVEND)



WHERE     (SASEPRFAC.TipoFac = 'A') AND (SASEPRCOM.TipoCom = 'H') OR
                      (SASEPRFAC.TipoFac IS NULL) AND (SASEPRCOM.TipoCom = 'H') 

-- OR (SASEPRFAC.TipoFac = 'B') AND (SASEPRCOM.TipoCom = 'H')


   

GO
----------------

declare @TNAME CHAR(21)
declare @ALIAS CHAR(21)
SET @TNAME = 'VW_ADM_VehiculoModelo'
SET @ALIAS = 'VW_ADM_VehiculoModelo'
 
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


