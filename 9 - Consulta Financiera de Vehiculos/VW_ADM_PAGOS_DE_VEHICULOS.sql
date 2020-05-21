DROP VIEW dbo.VW_ADM_PAGOS_DE_VEHICULOS
GO
CREATE VIEW dbo.VW_ADM_PAGOS_DE_VEHICULOS
AS

SELECT SAPAGCXP.NroUnico                          AS NroUnico_PAG, 
       SAPAGCXP.NroRegi                           AS NroRegi_PAG,
       SAPAGCXP.NroPpal                           AS NroPpal_PAG, 
       SAPAGCXP.Monto, 
       SAPAGCXP.Descrip                           AS Descrip_PAG,
       SAACXP.CodOper, 
       SAACXP.Document,
       SAACXP.EsUnPago, 
       SAACXP.FechaE                              AS FechaE_CXP, 
       SAACXP.NumeroD                             AS NumeroD_CXP, 
       SAACXP.TipoCxP                             AS TipoCxP_CXP, 
       SAPAGCXP.NumeroD, 
       SAACXP.NroUnico                            AS NroUnico_CXP, 
       SAACXP.NroRegi                             AS NroRegi_CXP, 
       SBTRAN.NroPpal                             AS NroPpal_CXP,
       SBTRAN.CodBanc, 
       SBTRAN.CodOper CodOper_2, 
       SBTRAN.Comentario1,
       SBTRAN.Descripcion, 
       SBTRAN.Documento                           AS DEPOSITO, 
       SBTRAN.Fecha                               AS FECHA_BANCO, 
       SBTRAN.MtoCr, 
       SBTRAN.MtoDb, 
       SBTRAN.AOD                                 AS TRANSAC,
       SUBSTRING(SBTRAN.CODUSUA,1,1)              AS USUARIO,
       SBBANC.Descripcion                         AS Descripcion_BANCO
FROM SAPAGCXP SAPAGCXP
      LEFT OUTER JOIN SAACXP SAACXP ON 
     (SAACXP.NroUnico = SAPAGCXP.NroPpal)
      LEFT OUTER JOIN SBTRAN SBTRAN ON 
     (SBTRAN.NroPpal = SAPAGCXP.NroPpal AND SBTRAN.AOD='-')
      LEFT OUTER JOIN SBBANC SBBANC ON 
     (SBBANC.CodBanc = SBTRAN.CodBanc)

   

GO
----------------

declare @TNAME CHAR(25)
declare @ALIAS CHAR(25)
SET @TNAME = 'VW_ADM_PAGOS_DE_VEHICULOS'
SET @ALIAS = 'VW_ADM_PAGOS_DE_VEHICULOS'
 
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


