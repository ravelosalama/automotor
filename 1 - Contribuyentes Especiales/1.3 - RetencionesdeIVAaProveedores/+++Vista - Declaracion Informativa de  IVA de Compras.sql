DROP VIEW dbo.VW_ADM_DECIVACOMPRA
GO

 
/****** Object:  View [dbo].[VW_ADM_DECIVACOMPRA]    Script Date: 27/02/2019 13:24:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_ADM_DECIVACOMPRA]
AS
SELECT      
            SACOMP.FechaE, 
            SACOMP.FechaI                                                         AS FecReal,
            SACOMP.CodProv                                                        AS CodProv,
            SACOMP.ID3                                                            AS RIF, 
            SACOMP.Descrip, 
            SACOMP.NumeroD                                                        AS NRODOC, 
            SACOMP.NroCtrol, 
            SACOMP.Monto -(SACOMP.Descto1+SACOMP.Descto2) + SACOMP.MtoTax         AS MTotVta, 
            SACOMP.Monto -(SACOMP.Descto1+SACOMP.Descto2+SACOMP.TGravable)      AS MExento, 
            SACOMP.RetenIVA                                                       AS RetIVA,
	    SATAXCOM.TGravable                                                    AS GRAVABLE,
            SATAXCOM.MtoTax                                                       AS ALICUOTA,
	    SATAXCOM.Monto                                                        AS MONTOIVA,
            SACOMP.TIPOCOM                                                        AS TIPO
FROM        dbo.SACOMP SACOMP LEFT JOIN dbo.SACOMP_01 SACOMP01 
ON         (SACOMP.CodProv=SACOMP01.CodProv AND SACOMP.TipoCom=SACOMP01.TipoCom AND SACOMP.NumeroD=SACOMP01.NumeroD) 
            LEFT OUTER JOIN dbo.SATAXCOM SATAXCOM 
ON         (SACOMP.CodProv=SATAXCOM.CodProv AND SACOMP.TipoCom=SATAXCOM.TipoCom AND SACOMP.NumeroD=SATAXCOM.NumeroD)  
WHERE      (SACOMP.TipoCom = 'H') OR SACOMP.TIPOCOM='I'
           
UNION

SELECT     
           SAACXP.FechaI, 
           SAACxP.FechaE                                                   AS FecReal,
           SAACXP.CodProv,                                                  
           SAPROV.ID3                                                      AS RIF , 
           SAPROV.Descrip, 
           SAACXP.NUMEROD                                                  AS NumeroD, 
           SAACXP.NroCtrol, 
           CASE WHEN SAACXP.TipoCxP = '21' THEN (SAACXP.Monto)*-1      ELSE SAACXP.monto END   AS MTotVta, 
           CASE WHEN SAACXP.TipoCxP = '21' THEN (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo))*-1 ELSE (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo)) END AS MExento,
           CASE WHEN SAACXP.TipoCxP = '21' THEN (SAACXP.RetenIVA)*-1   ELSE  SAACXP.RetenIVA END      AS RetIVA, 
	   CASE WHEN SAACXP.TipoCxP = '21' THEN SAACXP.BaseImpo*-1     ELSE  SAACXP.BaseImpo  END     AS GRAVABLE,
           CASE WHEN SAACXP.BaseImpo <> 0  THEN ROUND(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) ELSE 0 END    AS ALICUOTA,
	   CASE WHEN SAACXP.TipoCxP = '21' THEN SAACXP.MtoTax*-1       ELSE  SAACXP.MtoTax    END     AS MONTOIVA,
           SAACXP.TIPOCXP                                                                             AS TIPO  
FROM       dbo.SAACXP SAACXP INNER JOIN dbo.SAPROV SAPROV
ON         SAACXP.CodProv=SAPROV.CodProv
WHERE     (SAACXP.TipoCxP='21'AND SAACXP.EsReten=0) OR (SAACXP.TipoCxP= '30') 



GO

 

GO
----------------

declare @TNAME CHAR(19)
declare @ALIAS CHAR(19)
SET @TNAME = 'VW_ADM_DECIVACOMPRA'
SET @ALIAS = 'VW_ADM_DECIVACOMPRA'
 
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

