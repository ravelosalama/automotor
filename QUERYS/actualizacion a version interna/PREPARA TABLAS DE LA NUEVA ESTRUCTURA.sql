
-- prepara las tablas a LA NUEVA ESTRUCTURA 
-- ELABORADO POR: JOSE RAVELO / OM System Consulting, C.A. JULIO - 2008




-- REPARA DATOS



UPDATE    SAFACT_01
SET              LIQUIDACION = 'CONTADO'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND ((UPPER(SUBSTRING(Liquidacion, 1, 1)) = 'C') OR LIQUIDACION='???')

UPDATE    SAFACT_01
SET              LIQUIDACION = 'GARANTIA'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (UPPER(SUBSTRING(Liquidacion, 1, 1)) = 'G')

UPDATE    SAFACT_01
SET              LIQUIDACION = 'INTERNA'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (UPPER(SUBSTRING(Liquidacion, 1, 1)) = 'I')

UPDATE    SAFACT_01
SET              LIQUIDACION = 'ACCESORIOS'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (UPPER(SUBSTRING(Liquidacion, 1, 1)) = 'A')

UPDATE    SAFACT_01
SET              STATUS = 'PENDIENTE'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (UPPER(SUBSTRING(STATUS, 1, 1)) = 'P')

UPDATE    SAFACT_01
SET              STATUS = 'CERRADA'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (UPPER(SUBSTRING(STATUS, 1, 1)) = 'C')


DELETE SAFACT_01  
WHERE     (TipoFac = 'C') OR (TipoFac = 'D') OR (TipoFac = 'E') OR TIPOFAC='F'

DELETE SAFACT_02
WHERE     (TipoFac = 'C') OR (TipoFac = 'D') OR (TipoFac = 'E') OR TIPOFAC='F'

DELETE SAFACT_03
WHERE     (TipoFac = 'A') OR (TipoFac = 'F') OR (TipoFac = 'G') OR TIPOFAC='B'

DELETE FROM SACODBAR


-- VINCULA FACTURA CON ORDENES Y VICEVERSA CON PLACAS 

-- ACTUALIZA SAFACT CASO: FACTURA DE SERVICIO

 
UPDATE    safact_01
SET              STATUS = 'VEHICULO', APERTURA_OR=FECHAE,CIERRE_OR=FECHAE 
FROM         SAFACT_01 x INNER JOIN
                      SAFACT y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac
WHERE     (x.TipoFac = 'A') AND (y.CodOper = '01-101')

UPDATE    SAFACT_01
SET              PLACA = W.CODPROD
FROM         SAFACT X INNER JOIN
                      SAFACT_01 Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac INNER JOIN
                      SASEPRFAC Z ON X.NumeroD = Z.NumeroD AND X.TipoFac = Z.TipoFac INNER JOIN
                      SAPROD_12_01 W ON Z.NroSerial = W.Serial
WHERE     (X.CodOper = '01-101') AND (Y.Placa = '')

UPDATE    safact
SET              ORDENC = 'VEHICULO/'+X.PLACA
FROM         SAFACT_01 x INNER JOIN
                      SAFACT y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac
WHERE     (x.TipoFac = 'A') AND (y.CodOper = '01-101')


-- ACTUALIZA SAFACT_01 CASO: DEVOLUCION VEHICULO
UPDATE    SAFACT_01
SET              STATUS = 'VEHICULO',APERTURA_OR=FECHAE, CIERRE_OR=FECHAE
FROM         SAFACT_01 x INNER JOIN
                      SAFACT y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac
WHERE     (x.TipoFac = 'B') AND (y.CodOper = '01-101')

UPDATE    SAFACT
SET              ORDENC = 'VEHICULO/'+X.PLACA
FROM         SAFACT_01 x INNER JOIN
                      SAFACT y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac
WHERE     (x.TipoFac = 'B') AND (y.CodOper = '01-101')



-- ACTUALIZA SAFACT_01 CASO: FACTURA DE REPUESTO
UPDATE    SAFACT_01
SET              STATUS = 'REPUESTO',APERTURA_OR=FECHAE, CIERRE_OR=FECHAE
FROM         SAFACT_01 x INNER JOIN
                      SAFACT y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac
WHERE     (x.TipoFac = 'A') AND (y.CodOper = '01-201')

-- ACTUALIZA OPERACIONES DE SERVICIO
UPDATE    SAFACT_01
SET              STATUS = Y.ORDEN_DE_REPARACION, APERTURA_OR=Z.FECHAE, CIERRE_OR=Z.FECHAE
FROM         SAFACT_01 x INNER JOIN
                      SAFACT_01b y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAFACT z ON x.NumeroD = z.NumeroD AND y.TipoFac = z.TipoFac
WHERE     (z.CodOper = '01-301') AND (x.TipoFac = 'A')

UPDATE    SAFACT
SET              ORDENC = X.STATUS
FROM         SAFACT_01 x INNER JOIN
                      SAFACT_01b y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAFACT z ON x.NumeroD = z.NumeroD AND y.TipoFac = z.TipoFac
WHERE     (z.CodOper = '01-301') AND (x.TipoFac = 'A')


UPDATE    SAFACT_01
SET              LIQUIDACION = 'CONTADO'
FROM         SAFACT_01 X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac
WHERE     (Y.CodOper = '01-301') AND (Y.TipoFac = 'A') AND (X.Liquidacion <> 'CONTADO')


-- ACTUALIZA SAFACT_01 CASO: DOCUMENTOS EN ESPERAS ABIERTAS (ORDENES DE REPARACION ABIERTAS)
UPDATE    SAFACT_01
SET                APERTURA_OR=Z.FECHAE, CIERRE_OR=Z.FECHAE
FROM         SAFACT_01 x INNER JOIN
                      SAFACT_01b y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAFACT z ON x.NumeroD = z.NumeroD AND y.TipoFac = z.TipoFac
WHERE     (z.CodOper = '01-301') AND (x.TipoFac = 'G')

-- ACTUALIZA SAFACT_01 CASO:ORDENES DE REPARACION YA FACTURADAS Y/O DEVUELTAS
UPDATE    SAFACT_01
SET              STATUS = Y.NUMEROD
FROM         SAFACT_01 X INNER JOIN
                      SAFACT_01b Y ON X.NumeroD = Y.Orden_de_reparacion AND X.TipoFac = 'G' AND X.Placa = Y.Placa
WHERE     (Y.TipoFac = 'A') OR
                      Y.TIPOFAC = 'B'

-- ACTUALIZA SAFACT_01: FECHAS DE APERTURA_or Y CIERRE_OR

UPDATE    SAFACT_01
SET              CIERRE_OR = FECHAE, APERTURA_OR = FECHAE
FROM         SAFACT_01 X INNER JOIN
                      SAFACT Y ON X.Status = Y.NumeroD
WHERE     (Y.TipoFac = 'A' OR Y.TipoFac = 'B') AND (X.TipoFac = 'G')

UPDATE    SAFACT_01
SET              APERTURA_OR = Y.FECHAE, CIERRE_OR = Y.FECHAE
FROM         SAFACT_01 X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac


UPDATE    SAFACT_01
SET              Cierre_OR = '01/01/1900', Apertura_OR = '01/01/1900'
WHERE     (Apertura_OR IS NULL) AND (Cierre_OR IS NULL)



-- MARCAS DE REVISION PARA CASOS FUERA DE LOS ESPERADOS.
 
UPDATE    SAFACT_01
SET              LIQUIDACION = X.STATUS, STATUS = 'SUSPENSO'
FROM         SAFACT_01 x INNER JOIN
                      SAFACT_01b y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAFACT z ON x.NumeroD = z.NumeroD AND y.TipoFac = z.TipoFac
WHERE     (z.CodOper = '01-301') AND (x.TipoFac = 'g') AND (x.Status <> 'CERRADA') AND (x.Status <> 'PENDIENTE') 



UPDATE    SAFACT_01
SET              LIQUIDACION = 'REVISAR'
FROM         SAFACT_01
WHERE     (TipoFac = 'G') AND (Liquidacion <> 'CONTADO') AND (Liquidacion <> 'INTERNA') AND (Liquidacion <> 'ACCESORIOS') AND (Liquidacion <> 'GARANTIA')



-- ACTUALIZA COLOR Y PLACA DE SAPROD_11_03 SEGUN SAPROD_12_01 PREVIA IMPORTANCION DESDE SASERI
UPDATE    saprod_11_03
SET              color = y.color, placa = y.codprod
FROM         SAPROD_11_03 X INNER JOIN
                      SAPROD_12_01 Y ON X.Serial = Y.Serial


-- ACTUALIZA EL CONCESIONARIO QUE VENDIO EL VEHICULO 

UPDATE    SAPROD_12_01
SET              Concesionario = Atributos

UPDATE    SAPROD_12_01
SET              CONCESIONARIO = 'PRESTIGE CARS, C.A.', FACTURA_COMPRA = Y.NUMEROD
FROM         SAPROD_12_01 X INNER JOIN
                      SASEPRCOM Y ON X.Serial = Y.NroSerial
UPDATE    SAPROD_12_01
SET              CONCESIONARIO = 'PRESTIGE CARS, C.A.'
FROM         SAPROD_12_01 X INNER JOIN
                      SASEPRFAC Y ON X.Serial = Y.NroSerial

UPDATE    SAPROD_12_01
SET              CONCESIONARIO = 'X DEFINIR'
FROM         SAPROD_12_01
WHERE     (Concesionario IS NULL) OR
                      (Concesionario = '')

UPDATE    SAFACT_02
SET              VENDIO_CONCESIONARIO = 'LIBERTY CARS'
FROM         SAFACT_02 X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac
WHERE     (Y.CodOper = '01-101') 
  

UPDATE    SAFACT_02
SET              VENDIO_CONCESIONARIO = CONCESIONARIO
FROM         SAFACT_02 X INNER JOIN
                      SAPROD_12_01 Y ON X.Serial = Y.Serial


-- ACTUALIZA TABLAS DE PRODUCTOS ADICIONALES
UPDATE    SAPROD_11_03
SET              PLACA = Y.CODPROD, COLOR = Y.COLOR, FECTRN = '07/08/2008'
FROM         SAPROD_11_03 X INNER JOIN
                      SAPROD_12_01 Y ON X.Serial = Y.Serial


UPDATE    SAFACT
SET              ORDENC = Y.LIQUIDACION + '/' + Y.PLACA
FROM         SAFACT X INNER JOIN
                      SAFACT_01 Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac
WHERE     (X.CodOper = '01-301') AND (X.TipoFac = 'G')

UPDATE    SAFACT
SET              OTIPO = '1'
FROM         SAFACT_01 X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac
WHERE     (X.Liquidacion <> 'CONTADO') AND (X.Status = 'CERRADA')

UPDATE    SAFACT_01
SET              TIPOFAC = 'Z'
FROM         SAFACT_01
WHERE     (Liquidacion <> 'CONTADO') AND (Status = 'CERRADA')

UPDATE    SAFACT
SET              TipoFac = 'Z'
WHERE     (OTipo = '1')

UPDATE    SAFACT
SET              OTIPO = NULL
WHERE     (OTipo = '')

UPDATE    SAPROD_12_01
SET              FACTURA_VENTA = X.NUMEROD, FECHA_VENTA = Y.FECHAE
FROM         SASEPRFAC X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac INNER JOIN
                      SAPROD_12_01 Z ON X.NroSerial = Z.Serial

UPDATE    SAPROD
SET              REFERE = CODPROD,DESCRIP3='VEHICULO'
FROM         SAPROD
WHERE     (CodInst = '12')

UPDATE    SAPROD
SET              DESCRIP3='MODELO'
FROM         SAPROD
WHERE     (CodInst = '11')

UPDATE    SAPROD
SET          DESCRIP3 = PUESTOI
FROM         SAPROD X INNER JOIN
                      SAEXIS Y ON X.CodProd = Y.CodProd
WHERE       (X.CodInst <> '12') AND (X.CodInst <> '11')  


UPDATE    SAFACT
SET              ORDENC = NRO_OR
FROM         SAFACT_03 X INNER JOIN
                      SAFACT Y ON X.NumeroD = Y.NumeroD AND X.TipoFac = Y.TipoFac
WHERE     X.TIPOFAC = 'E' OR
                      X.TIPOFAC = 'C' OR
                      X.TIPOFAC = 'D'

UPDATE    SAFACT
SET              NUMEROR = NOTAS6
FROM         SAFACT
WHERE     (CodOper = '01-101') AND (TipoFac = 'B') AND (NumeroR IS NULL)


UPDATE    SAFACT_01
SET              LIQUIDACION = X.NUMEROD, STATUS = 'ANULADA'
FROM         SAFACT X INNER JOIN
                      SAFACT_01 Y ON X.NumeroR = Y.NumeroD AND Y.TipoFac = 'A'
WHERE     (X.CodOper = '01-101') AND (X.TipoFac = 'B')


UPDATE    safact
SET              numeror = x.numerod
FROM         SAFACT2 x INNER JOIN
                      SAFACT y ON x.Notas6 = y.NumeroD AND y.TipoFac = 'a'
WHERE     (x.TipoFac = 'b') AND (x.NumeroR IS NULL OR
                      x.NumeroR = '')




 