DROP VIEW dbo.VW_ADM_COBROS_DE_VEHICULOS
GO
CREATE VIEW dbo.VW_ADM_COBROS_DE_VEHICULOS
AS

 SELECT SAPAGCXC.NroUnico                         AS NroUnico_Cob, 
       SAPAGCXC.NroRegi                           AS NroRegi_Cob,
       SAPAGCXC.NroPpal                           AS NroPpal_Cob, 
      (CASE WHEN SAPAGCXC.MONTO > 0 OR SAPAGCXC.MONTO IS NOT NULL  THEN SAPAGCXC.MONTO ELSE SBTRAN.MTOCR END) AS MONTO,
      (CASE WHEN SAPAGCXC.MONTO > 0 OR SAPAGCXC.MONTO IS NOT NULL  THEN 0 ELSE SBTRAN.MTOCR END) AS ANTICIPOS,
      (CASE WHEN SAPAGCXC.MONTO > 0 OR SAPAGCXC.MONTO IS NOT NULL  THEN SAPAGCXC.MONTO ELSE 0 END) AS PAGADO,
       SAPAGCXC.Descrip                           AS Descrip_Cob,
       SAACXC.CodOper, 
       SAACXC.Document,
       SAACXC.Codclie                             AS CodClie,
       SAACXC.EsUnPago, 
       SAACXC.FechaE                              AS FechaE_CXC, 
       SAACXC.NumeroD                             AS NumeroD_CXC, 
       SAACXC.TipoCxC                             AS TipoCxC_CXC, 
       SAPAGCXC.NumeroD, 
       SAACXC.NroUnico                            AS NroUnico_CXC, 
       SAACXC.NroRegi                             AS NroRegi_CXC, 
       SBTRAN.NroPpal                             AS NroPpal_CXC,
       SBTRAN.CodBanc, 
       SBTRAN.CodOper CodOper_2, 
       SBTRAN.Comentario1,
       SBTRAN.Descripcion, 
       SBTRAN.Documento                           AS DEPOSITO, 
       SBTRAN.Fecha                               AS FECHA_BANCO, 
       SBTRAN.MtoCr, 
       SBTRAN.MtoDb,
SUBSTRING(SBTRAN.CODUSUA,1,1)                     AS USUARIO,
       SBBANC.Descripcion                         AS Descripcion_BANCO
FROM SAACXC SAACXC
      LEFT OUTER JOIN SAPAGCXC SAPAGCXC ON 
     (SAACXC.NroUnico = SAPAGCXC.NroPpal)
      LEFT OUTER JOIN SBTRAN SBTRAN ON 
     (SBTRAN.NroPpal = SAACXC.NroUNICO)
      LEFT OUTER JOIN SBBANC SBBANC ON 
     (SBBANC.CodBanc = SBTRAN.CodBanc)

WHERE (SAACXC.TIPOCXC='50' OR SAACXC.TIPOCXC='41') AND SAACXC.CODOPER<>'01-201' AND SAACXC.CODOPER<>'01-301'
  
GO
----------------

declare @TNAME CHAR(26)
declare @ALIAS CHAR(26)
SET @TNAME = 'VW_ADM_COBROS_DE_VEHICULOS'
SET @ALIAS = 'VW_ADM_COBROS_DE_VEHICULOS'
 
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


