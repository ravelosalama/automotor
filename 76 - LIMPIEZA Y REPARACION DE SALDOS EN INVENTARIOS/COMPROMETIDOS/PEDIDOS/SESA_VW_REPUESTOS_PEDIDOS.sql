-- VISTA QUE MUESTRA LOS PEDIDOS SOBRE ORDENES DONDE SE HA DESPACHADO UN PRODUCTO 
-- APLICACION: COMPLEMENTO SOLUCION 76 / REPORTES AGREGADOS 201 
-- REALIZADO EL:07/07/2011 POR: JOSE RAVELO

DROP VIEW dbo.SESA_VW_REPUESTOS_PEDIDOS
GO
 
 
CREATE VIEW dbo.SESA_VW_REPUESTOS_PEDIDOS
WITH ENCRYPTION

 
AS

 SELECT     X.TipoFac, X.NumeroD, X.Nro_OR, X.Vale, Y.TipoFac AS Expr1, Y.NumeroD AS Expr2, Y.Placa, Y.Kilometraje, Y.Liquidacion, Y.Status, Y.Cierre_OR, 
                      Y.Apertura_OR, Z.TipoFac AS Expr3, Z.NumeroD AS Expr4, Z.OTipo, Z.ONumero, Z.Status AS Expr5, Z.NroLinea, Z.NroLineaC, Z.CodItem, Z.CodUbic, 
                      Z.CodMeca, Z.CodVend, Z.Descrip1, Z.Descrip2, Z.Descrip3, Z.Descrip4, Z.Descrip5, Z.Descrip6, Z.Descrip7, Z.Descrip8, Z.Descrip9, Z.Descrip10, 
                      Z.Refere, Z.Signo, Z.CantMayor, Z.Cantidad, Z.CantidadO, Z.ExistAntU, Z.ExistAnt, Z.CantidadU, Z.CantidadC, Z.CantidadA, Z.CantidadUA, Z.Costo, 
                      Z.Precio, Z.Descto, Z.NroLote, Z.FechaE, Z.FechaL, Z.FechaV, Z.EsServ, Z.EsUnid, Z.EsFreeP, Z.EsPesa, Z.EsExento, Z.UsaServ, Z.DEsLote, 
                      Z.DEsSeri, Z.DEsComp, Z.NroUnicoL, Z.Tara, Z.TotalItem, Z.NumeroE, W.TipoFac AS Expr6, W.NumeroD AS Expr7, W.NroCtrol, W.Status AS Expr8, 
                      W.CodSucu, W.CodEsta, W.CodUsua, W.Signo AS Expr9, W.OTipo AS Expr10, W.ONumero AS Expr11, W.TipoTra, W.NumeroC, W.NumeroK, 
                      W.NumeroF, W.NumeroP, W.EsExPickup, W.Moneda, W.Factor, W.MontoMEx, W.CodClie, W.CodVend AS Expr12, W.CodUbic AS Expr13, W.Descrip, 
                      W.Direc1, W.Direc2, W.Direc3, W.Pais, W.Estado, W.Ciudad, W.Telef, W.ID3, W.NIT, W.Monto, W.MtoTax, W.Fletes, W.TGravable, W.TExento, 
                      W.CostoPrd, W.CostoSrv, W.DesctoP, W.RetenIVA, W.FechaE AS Expr14, W.FechaV AS Expr15, W.CancelI, W.CancelA, W.CancelE, W.CancelC, 
                      W.CancelT, W.CancelG, W.Cambio, W.EsConsig, W.MtoExtra, W.Descto1, W.PctAnual, W.MtoInt1, W.Descto2, W.PctManejo, W.MtoInt2, W.MtoFinanc, 
                      W.DetalChq, W.TotalPrd, W.TotalSrv, W.OrdenC, W.CodOper, W.NGiros, W.NMeses, W.MtoComiVta, W.MtoComiCob, W.MtoComiVtaD, 
                      W.MtoComiCobD, W.Notas1, W.Notas2, W.Notas3, W.Notas4, W.Notas5, W.Notas6, W.Notas7, W.Notas8, W.Notas9, W.Notas10, W.NumeroR, 
                      W.NumeroD1, W.FechaD1, W.SaldoAct, W.MtoPagos, W.MtoNCredito, W.MtoNDebito, W.FechaI, W.ValorPtos, W.CancelP, W.NumeroT, W.MtoTotal, 
                      W.Contado, W.Credito, W.NumeroZ, W.FechaR, W.FechaT, W.NROUNICO, W.NumeroE AS Expr16, W.Municipio, W.CodConv, W.ZipCode
FROM         SAFACT_03 AS X INNER JOIN
                      SAFACT_01 AS Y ON X.Nro_OR = Y.NumeroD AND Y.TipoFac = 'G' INNER JOIN
                      SAITEMFAC AS Z ON X.TipoFac = Z.TipoFac AND X.NumeroD = Z.NumeroD INNER JOIN
                      SAFACT AS W ON W.NumeroD = X.NumeroD AND W.TipoFac = X.TipoFac
WHERE     (X.TipoFac = 'E')
 

GO

 
----------------

declare @TNAME CHAR(25)
declare @ALIAS CHAR(25)
SET @TNAME = 'SESA_VW_REPUESTOS_PEDIDOS'
SET @ALIAS = 'SESA_VW_REPUESTOS_PEDIDOS'
 
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




