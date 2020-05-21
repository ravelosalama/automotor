DROP VIEW dbo.SESA_VW_ENTREGAS_SOBRE_ORDENES
GO



CREATE VIEW dbo.SESA_VW_ENTREGAS_SOBRE_ORDENES
-- WITH ENCRYPTION

 
AS

  SELECT     X.TipoFac, X.NumeroD AS NROOR, X.Placa, X.Kilometraje, X.Liquidacion, X.Status, X.Cierre_OR, X.Apertura_OR, Y.TipoFac AS Expr1, Y.NumeroD AS NROPEDIDO, 
                      Y.Nro_OR, Y.Vale, Z.TipoFac AS Expr3, Z.NumeroD AS Expr4, Z.OTipo, Z.ONumero, Z.Status AS Expr5, Z.NroLinea, Z.NroLineaC, Z.CodItem, 
                      Z.CodUbic, Z.CodMeca, Z.CodVend, Z.Descrip1, Z.Descrip2, Z.Descrip3, Z.Descrip4, Z.Descrip5, Z.Descrip6, Z.Descrip7, Z.Descrip8, Z.Descrip9, 
                      Z.Descrip10, Z.Refere, Z.Signo, Z.CantMayor, Z.Cantidad, Z.CantidadO, Z.ExistAntU, Z.ExistAnt, Z.CantidadU, Z.CantidadC, Z.CantidadA, Z.CantidadUA, 
                      Z.Costo, Z.Precio, Z.Descto, Z.NroLote, Z.FechaE, Z.FechaL, Z.FechaV, Z.EsServ, Z.EsUnid, Z.EsFreeP, Z.EsPesa, Z.EsExento, Z.UsaServ, Z.DEsLote, 
                      Z.DEsSeri, Z.DEsComp, Z.NroUnicoL, Z.Tara, Z.TotalItem, Z.NumeroE
  FROM         SAFACT_01 AS X INNER JOIN
                      SAFACT_03 AS Y ON X.NumeroD = Y.Nro_OR AND Y.TipoFac = 'C' INNER JOIN
                      SAITEMFAC AS Z ON Y.NumeroD = Z.NumeroD AND Y.TipoFac = Z.TipoFac
  WHERE     (X.TipoFac = 'G')
 

GO

 
----------------

declare @TNAME CHAR(30)
declare @ALIAS CHAR(30)
SET @TNAME = 'SESA_VW_ENTREGAS_SOBRE_ORDENES'
SET @ALIAS = 'SESA_VW_ENTREGAS_SOBRE_ORDENES'
 
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



