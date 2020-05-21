drop view dbo.VW_ADM_TAXCOMCRE
go

-- ULTIMA COMPILACION 28/11/2007 SE AGREGA FILTRO TIPOCOM='I' EN CLAUSULA WHERE Y SIGNO.
-- JOSE RAVELO NOV - 2007
-- MODIFICACION ABRIL - 2013 SE CORRIGE UNION Y FILTROS DE SEGUNDA FUENTE PARA INCORPORAR ND/NC ES LA VIGENTE
-- MODIFICACION MAYO - 2013 SE AGREGAN 2 UNIONES MAS
-- MODIFICACION 27FEB2019 SE AGREGA FRAGMENTO DE CODIGO QUE GREGA TABLA Y CAMPOS A SATABL Y SAFIELD.


CREATE VIEW dbo.VW_ADM_TAXCOMCRE 
  WITH ENCRYPTION
AS

-- seccion principl de compras y devoluciones
SELECT      TOP 100 PERCENT
            SACOMP.FechaE, 
            SACOMP.FechaI                                                                               AS FecReal,
            SACOMP.CodProv                                                                              AS CodProv,
            SACOMP.ID3                                                                                  AS RIF,
            SACOMP.codoper                                                                              AS OPERACION,
            SACOMP.SIGNO,
            SACOMP.NUMERON                      AS COMPRA_AFECTADA,
            SACOMP.NOTAS4                       AS MOTIVO_DEVOLUCION,
            SACOMP.NOTAS5                       AS NroNC,
            SACOMP.Descrip, 
            SACOMP.NumeroD, 
            SACOMP.NroCtrol, 
            ''                                                                                          AS NroDebito, 
            SACOMP.NOTAS5                                                                                          AS NroCredito,  
        MAX(SACOMP.Monto -(SACOMP.Descto1+SACOMP.Descto2) + SACOMP.MtoTax)*SACOMP.SIGNO                 AS MTotVta, 
            SACOMP.TExento * SACOMP.SIGNO                                                               AS MExento, 
            0                                                                AS RetIVA,
	SUM(CASE WHEN SATAXCOM.CodTaxs='IVA'  THEN SATAXCOM.TGravable*SACOMP.SIGNO else 0 END)          AS BIIVA,
	SUM(CASE WHEN SATAXCOM.CodTaxs='IVA'  THEN SATAXCOM.Monto*SACOMP.SIGNO else 0 END)              AS IMPIVA,
	SUM(CASE WHEN SATAXCOM.CodTaxs='RED'    THEN SATAXCOM.TGravable*SACOMP.SIGNO else 0 END)        AS BIRED,
	SUM(CASE WHEN SATAXCOM.CodTaxs='RED'    THEN SATAXCOM.Monto*SACOMP.SIGNO else 0 END)            AS IMPRED,
	SUM(CASE WHEN SATAXCOM.CodTaxs='ADI' THEN SATAXCOM.TGravable*SACOMP.SIGNO else 0 END)           AS BIADI,
        SUM(CASE WHEN SATAXCOM.CodTaxs='ADI' THEN SATAXCOM.Monto*SACOMP.SIGNO else 0 END)               AS IMPADI,
            SACOMP.NUMEROD                                                                              AS NRO,
            SACOMP.TIPOCOM                                                                              AS TIPO
FROM        dbo.SACOMP SACOMP LEFT JOIN dbo.SACOMP_01 SACOMP01 
ON         (SACOMP.CodProv=SACOMP01.CodProv AND SACOMP.TipoCom=SACOMP01.TipoCom AND SACOMP.NumeroD=SACOMP01.NumeroD) 
            LEFT OUTER JOIN dbo.SATAXCOM SATAXCOM 
ON         (SACOMP.CodProv=SATAXCOM.CodProv AND SACOMP.TipoCom=SATAXCOM.TipoCom AND SACOMP.NumeroD=SATAXCOM.NumeroD)  
WHERE      (SACOMP.TipoCom = 'H') OR SACOMP.TIPOCOM='I'
GROUP BY    FechaE,SACOMP.FechaI, SACOMP.CodProv,ID3,Descrip,SACOMP.NumeroD,NroCtrol,TExento,RetenIVA,SACOMP.TIPOCOM,SACOMP.CODOPER,SACOMP.SIGNO,SACOMP.NOTAS3,SACOMP.NOTAS4,SACOMP.NOTAS5,SACOMP.NUMERON
           
UNION

-- seccion notas de debitos normales
SELECT     TOP 100 PERCENT
           SAACXP.FechaE, 
           SAACxP.FechaE                                                   AS FecReal,
           SAACXP.CodProv,                                                  
           SAPROV.ID3                                                      AS RIF ,
           SAACXP.CODOPER                                                  AS OPERACION,
           '1'                                                             AS SIGNO,
           SAACXP.NUMERON AS COMPRA_AFECTADA, 
           ''                                                              AS NumeroD,
           ''                       AS XXX,
           SAACXP.DESCRIP             AS DESCRIP,
           ''                       AS NroNC,
           SAACXP.NroCtrol, 
	      (CASE WHEN SAACXP.TipoCxP = '21' THEN SAACXP.NumeroD WHEN SAACXP.TipoCxP = '30' THEN '' END) AS NroDebito, 
          (CASE WHEN SAACXP.TipoCxP = '21' THEN '' WHEN SAACXP.TipoCxP = '30' THEN SAACXP.NumeroD END) AS NroCredito,
          (CASE WHEN SAACXP.TipoCxP = '21' THEN (SAACXP.Monto)*-1 WHEN SAACXP.TipoCxP = '30' THEN (SAACXP.monto) END) AS MTotVta, 
          (CASE WHEN SAACXP.TipoCxP = '21' THEN (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo))*-1 WHEN SAACXP.TipoCxP = '30' THEN (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo)) END) AS MExento,
           0        AS RetIVA, 
	      (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.BaseImpo else 0 END) AS BIIVA,
	      (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.MtoTax   else 0 END) AS IMPIVA,
	      (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.BaseImpo else 0 END) AS BIRED,
	      (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.MtoTax   else 0 END) AS IMPRED,
	      (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '31' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.BaseImpo else 0 END) AS BIADI,
    	  (CASE WHEN SAACXP.TipoCxP = '21' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.MtoTax   else 0 END) AS IMPADI,          
           SAACXP.NUMEROD                                                  AS NRO,
           SAACXP.TIPOCXP                                                  AS TIPO  
FROM       dbo.SAACXP SAACXP INNER JOIN dbo.SAPROV SAPROV
ON         SAACXP.CodProv=SAPROV.CodProv
WHERE     (SAACXP.TipoCxP='21'AND SAACXP.CodOper='06-007') OR (SAACXP.TipoCxP= '30') 

           
UNION


-- seccion notas de debito / ANTICIPOS
SELECT     TOP 100 PERCENT
           SAACXP.Fechae, 
           SAACxP.FechaI                                                   AS FecReal,
           SAACXP.CodProv,                                                  
           SAPROV.ID3                                                      AS RIF ,
           SAACXP.CODOPER                                                  AS OPERACION,
           '1'                                                             AS SIGNO,
           SAACXP.DOCUMENT                                                 AS COMPRA_AFECTADA, 
           ''                                                              AS MOTIVO_DEVOLUCION,
           ''                                                              AS NRONC,
           SAPROV.Descrip                                                  AS DESCRIP,
           ''                                                              AS NUMEROD, 
           SAACXP.NroCtrol, 
	      (CASE WHEN SAACXP.TipoCxP = '50' THEN SAACXP.NUMEROD WHEN SAACXP.TipoCxP = '30' THEN '' END) AS NroDebito, 
          (CASE WHEN SAACXP.TipoCxP = '50' THEN '' WHEN SAACXP.TipoCxP = '30' THEN SAACXP.NumeroD END) AS NroCredito,
          (CASE WHEN SAACXP.TipoCxP = '50' THEN (SAACXP.Monto)*-1 WHEN SAACXP.TipoCxP = '30' THEN (SAACXP.monto) END) AS MTotVta, 
          (CASE WHEN SAACXP.TipoCxP = '50' THEN (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo))*-1 WHEN SAACXP.TipoCxP = '30' THEN (SAACXP.monto - (SAACXP.MtoTax + SAACXP.BaseImpo)) END) AS MExento,
          0                                AS RetIVA, 
	      (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.BaseImpo else 0 END) AS BIIVA,
	      (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 11 AND 18) THEN SAACXP.MtoTax   else 0 END) AS IMPIVA,
	      (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.BaseImpo else 0 END) AS BIRED,
	      (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 1 AND 9)   THEN SAACXP.MtoTax   else 0 END) AS IMPRED,
	      (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.BaseImpo*-1 WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.BaseImpo else 0 END) AS BIADI,
    	  (CASE WHEN SAACXP.TipoCxP = '50' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.MtoTax*-1   WHEN SAACXP.TipoCxP = '30' AND SAACXP.BaseImpo > 0 and (round(SAACXP.MtoTax / SAACXP.BaseImpo * 100,2) BETWEEN 20 AND 28) THEN SAACXP.MtoTax   else 0 END) AS IMPADI,          
           SAACXP.NUMEROD                                                  AS NRO,
           SAACXP.TIPOCXP                                                  AS TIPO  
FROM       dbo.SAACXP SAACXP INNER JOIN dbo.SAPROV SAPROV
ON         SAACXP.CodProv=SAPROV.CodProv
WHERE     (SAACXP.TipoCxP='50'AND SAACXP.CODOPER='06-007')  



           
UNION

-- seccion retenciones de IVA
SELECT     TOP 100 PERCENT
           SAACXP.Fechae, 
           SAACxP.Fechat                                                   AS FecReal,
           SAACXP.CodProv,                                                  
           SAPROV.ID3                                                      AS RIF ,
           SAACXP.CODOPER                                                  AS OPERACION,
           '1'                                                             AS SIGNO,
           ''                                                              AS COMPRA_AFECTADA, 
           ''                                                              AS MOTIVO_DEVOLUCION,
           ''                                                              AS NRONC,
           SAPROV.Descrip                                                  AS DESCRIP,
           ''                                                              AS NUMEROD, 
           ''                                                              AS NroCtrol, 
	       ''  AS NroDebito, 
           ''  AS NroCredito,
           0   AS MTotVta, 
           0   AS MExento,
          SAACXP.RetenIVA                                                  AS RetIVA, 
	       0   AS BIIVA,
	       0   AS IMPIVA,
	       0   AS BIRED,
	       0   AS IMPRED,
	       0   AS BIADI,
    	   0   AS IMPADI,          
           SAACXP.NUMEROD                                                  AS NRO,
           SAACXP.TIPOCXP                                                  AS TIPO  
FROM       dbo.SAACXP SAACXP INNER JOIN dbo.SAPROV SAPROV
ON         SAACXP.CodProv=SAPROV.CodProv
WHERE     (SAACXP.TipoCxP='81')  


          
UNION

-- seccion reversos de retenciones de IVA
SELECT     TOP 100 PERCENT
           SAACXP.Fechae, 
           SAACxP.Fechat                                                   AS FecReal,
           SAACXP.CodProv,                                                  
           SAPROV.ID3                                                      AS RIF ,
           SAACXP.CODOPER                                                  AS OPERACION,
           '1'                                                             AS SIGNO,
           ''                                                              AS COMPRA_AFECTADA, 
           ''                                                              AS MOTIVO_DEVOLUCION,
           ''                                                              AS NRONC,
           SAPROV.Descrip                                                  AS DESCRIP,
           ''                                                              AS NUMEROD, 
           ''                                                              AS NroCtrol, 
	       ''  AS NroDebito, 
           ''  AS NroCredito,
           0   AS MTotVta, 
           0   AS MExento,
          SAACXP.RetenIVA *-1                                                 AS RetIVA, 
	       0   AS BIIVA,
	       0   AS IMPIVA,
	       0   AS BIRED,
	       0   AS IMPRED,
	       0   AS BIADI,
    	   0   AS IMPADI,          
           SAACXP.NUMEROD                                                  AS NRO,
           SAACXP.TIPOCXP                                                  AS TIPO  
FROM       dbo.SAACXP SAACXP INNER JOIN dbo.SAPROV SAPROV
ON         SAACXP.CodProv=SAPROV.CodProv
WHERE     (SAACXP.TipoCxP='31')  




GO
----------------

declare @TNAME CHAR(16)
declare @ALIAS CHAR(16)
SET @TNAME = 'VW_ADM_TAXCOMCRE'
SET @ALIAS = 'VW_ADM_TAXCOMCRE'
 
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











