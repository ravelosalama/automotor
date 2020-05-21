-- NO ESTA VIGENTE. SE SUSTITUYE POR TRIGGER PRINCIPAL SOLUCION 40

-- ***********************************************************************************
-- PROCESA LA ORDEN DE REPARACION CUANDO SE GUARDA
-- ORIGINAL CARLOS SILVA, MODIFICADA JOSE RAVELO NOV-2007
-- 1ra Modificacion: SE ACTUALIZA RANGO DE VALORES DEL CAMPO DE LIQUIDACION
-- 2da Modificacion: SE AGREGA CAMPO DE FECHA DE CIERRE DE LA ORDEN.
-- 1.- Revisa y corrige los datos de la Orden de reparacion.
-- 2.- Crea ficha del vehiculo si no existe.
-- ***********************************************************************************

DROP PROCEDURE SESA_SP_PROCESA_ESPERA_OR
GO 

CREATE PROCEDURE SESA_SP_PROCESA_ESPERA_OR
@TipoDoc varchar(1),
@NumeroD varchar(10)
WITH ENCRYPTION
AS

DECLARE @FechaHoy datetime
DECLARE @CodClie varchar(10)
DECLARE @NroPedido varchar(10)
DECLARE @EsExento smallint
DECLARE @OrdenCompra varchar(20)
DECLARE @OrdenReparacion varchar(10)
DECLARE @Placa varchar(10)
DECLARE @Codigo varchar (15)
DECLARE @Modelo varchar (40)
DECLARE @Serial varchar (35)
DECLARE @Color varchar (25)
DECLARE @FechaVenta datetime
DECLARE @Kilometraje int
DECLARE @Liquidacion varchar (15)
DECLARE @Status varchar (15)
DECLARE @Revisado varchar(3)
DECLARE @NombClie varchar (40)
DECLARE @CodVend varchar (10)
DECLARE @FechaE datetime 
DECLARE @TipoFac varchar (1)
DECLARE @NroFact varchar (10)
DECLARE @Notas1 varchar (60)
DECLARE @Notas2 varchar (60)
DECLARE @Notas3 varchar (60)
DECLARE @Notas4 varchar (60)
DECLARE @Notas5 varchar (60)
DECLARE @Notas6 varchar (60)
DECLARE @Notas7 varchar (60)
DECLARE @Notas8 varchar (60)
DECLARE @Notas9 varchar (60)
DECLARE @Notas10 varchar (60)
DECLARE @FechaInicio datetime
DECLARE @FechaFin datetime
DECLARE @Marca varchar(20)
DECLARE @MontoIVA decimal (23,2)
DECLARE @EsPorct smallint
DECLARE @CodItem varchar(10)
DECLARE @DescItem varchar(80)
DECLARE @NroLinea int
DECLARE @Cantidad decimal (28,2)
DECLARE @Costo decimal (28,2)
DECLARE @Precio decimal (28,2)
DECLARE @Descrip1 varchar(40)
DECLARE @Descrip2 varchar(40)
DECLARE @Descrip3 varchar(40)

-- Variables de trabajo
DECLARE @CodOper varchar(10)
DECLARE @Deposito varchar(10)
DECLARE @CodInst varchar(10)
DECLARE @CodTaxs varchar(5)
DECLARE @Tmp_Codigo varchar (15)
DECLARE @Tmp_Serial varchar (35)
DECLARE @Tmp_Color varchar (25)

SET @FechaHoy = getdate()
SET @Deposito = '020'
SET @CodTaxs  = 'IVA'
SET @Modelo   = 'NO EXISTE'
SET @CodInst  = 12

BEGIN
   -- Toma los datos originales de la orden de reparacion y los prepara
   SELECT @Placa       = UPPER(X.Placa),
          @OrdenCompra = UPPER(X.Orden_de_compra),
          @Codigo      = UPPER(ISNULL(X.Codigo, '')),
          @Serial      = UPPER(X.Serial),
          @Color       = UPPER(X.Color),
          @FechaVenta  = X.Fecha_venta,
          @Kilometraje = ISNULL(X.Kilometraje,0),
          @Status      = UPPER(ISNULL(X.Status, '')),
          @Liquidacion = UPPER(ISNULL(X.Liquidacion, '')),
          @Revisado    = UPPER(X.Revisado),
          @CodOper     = Y.CodOper,
          @CodClie     = Y.CodClie,
          @NombClie    = Y.Descrip,
          @CodVend     = Y.CodVend,
          @FechaE      = Y.FechaE,
          @TipoFac     = Y.TipoFac,
          @NroFact     = Y.NumeroD,
          @Notas1      = Y.Notas1,
          @Notas2      = Y.Notas2,
          @Notas3      = Y.Notas3,
          @Notas4      = Y.Notas4,
          @Notas5      = Y.Notas5,
          @Notas6      = Y.Notas6,
          @Notas7      = Y.Notas7,
          @Notas8      = Y.Notas8,
          @Notas9      = Y.Notas9,
          @Notas10     = Y.Notas10
   FROM  dbo.SESA_VW_ORDENES_REPARACION AS X
   INNER JOIN dbo.SAFACT AS Y
   ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
   WHERE (X.TipoFac = @TipoDoc and X.NumeroD = @NumeroD)


   IF (SUBSTRING(@Liquidacion,1,5) = 'INTER') SET @Liquidacion = 'INTERNA'
   ELSE
   IF (SUBSTRING(@Liquidacion,1,5) = 'GARAN') SET @Liquidacion = 'GARANTIA'
   ELSE
   IF (SUBSTRING(@Liquidacion,1,5) = 'CONTA') SET @Liquidacion = 'CONTADO'
   ELSE
   -- IF (SUBSTRING(@Liquidacion,1,5) = 'CREDI') SET @Liquidacion = 'CREDITO'
   -- ELSE 
   -- IF (SUBSTRING(@Liquidacion,1,5) = 'ANULA') SET @Liquidacion = 'ANULADA'
   -- ELSE 
   IF (SUBSTRING(@Liquidacion,1,5) = 'ACCES') SET @Liquidacion = 'ACCESORIOS'
   ELSE 
   SET @Liquidacion = '???'

END

-----------------------------------------------------------------------------------------
-- CORRIGE LOS DATOS DE LA ORDEN DE REPARACION
-----------------------------------------------------------------------------------------
BEGIN
   -- Determina el status de la orden de reparacion segun a la primera letra
   IF (UPPER(SUBSTRING(@Status,1,1)) = 'P') or LEN(@Status) = 0 -- PENDIENTE
      SET @Status = 'PENDIENTE'
   ELSE
   IF (UPPER(SUBSTRING(@Status,1,1)) = 'C') -- CERRADA
      SET @Status = 'CERRADA'


   -- Actualiza orden de reparacion
   UPDATE dbo.SESA_VW_ORDENES_REPARACION
   SET Orden_de_reparacion = @NumeroD,
       Codigo              = @Codigo,
       Serial              = @Serial,
       Color               = @Color,
       Orden_de_compra     = @NumeroD,
       Status              = @Status,
       Placa               = @Placa,
       Kilometraje         = @Kilometraje,
       Liquidacion         = @Liquidacion,
       Revisado            = @Revisado
   WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
END

-----------------------------------------------------------------------------------------
-- GENERA Y ACTUALIZA LOS REGISTROS DEL VEHICULO.
-- 1. Crea registro del vehiculo, si no existe.
-- 2. Actualiza la orden de reparacion con los datos del vehiculo si este ya existe. 
-- 3. Actualiza el encabezado en SAFACT de la orden de reparacion.
-----------------------------------------------------------------------------------------
BEGIN
   -- CREA TODA LA DATA DEL VEHICULO
   IF EXISTS (SELECT * FROM SAPROD WHERE (CodProd = @Codigo))
   BEGIN
      SELECT @Modelo   = Descrip,
             @EsExento = EsExento
         FROM SAPROD
         WHERE (CodProd = @Codigo)
   END
   ELSE
   BEGIN
      SET @Modelo   = 'MODELO NO REGISTRADO'
      SET @EsExento = 1
   END
  
   IF NOT EXISTS (SELECT * FROM SAPROD WHERE (CodProd = @Placa))
   BEGIN
      -- Crea vehiculo en inventario
      INSERT SAPROD (CodProd, Descrip, Refere, CodInst, EsExento) 
         VALUES (@Placa, @Modelo, 'VEHICULO', @CodInst, @EsExento)

      -- Crea registro de existencia
      INSERT SAEXIS (CodProd, CodUbic, Existen) 
         VALUES (@Placa, @Deposito, 0)

      -- Crea registro de impuesto
      IF @EsExento = 0
      BEGIN
         SELECT @MontoIVA = MtoTax,
                @EsPorct = EsPorct
            FROM dbo.[SATAXES]
            WHERE (CodTaxs = @CodTaxs)

         INSERT SATAXPRD (CodProd, CodTaxs, Monto, EsPorct) 
            VALUES (@Placa, @CodTaxs, @MontoIVA, @EsPorct)
      END 
      
      -- Crea datos adicionales del vehiculo
      SELECT @Serial = NroSerial 
         FROM dbo.[SASEPRCOM]
         WHERE (TipoCom = @TipoDoc AND NumeroD = @NumeroD)

      INSERT dbo.SESA_VW_VEHICULOS (CodProd, Codigo, Serial, Color, Fecha_venta, Kilometraje) 
         VALUES (@Placa, @Codigo, @Serial, @Color, @FechaVenta, @Kilometraje)
   END
   ELSE
   BEGIN
      -- Lee datos actuales del vehiculo
      SELECT @Tmp_Codigo = UPPER(ISNULL(Codigo, '')),  
             @Tmp_Serial = UPPER(ISNULL(Serial, '')),
             @Tmp_Color  = UPPER(ISNULL(Color,  ''))
         FROM  dbo.SESA_VW_VEHICULOS
         WHERE (CodProd = @Placa)
      IF LEN(@Tmp_Codigo) = 0 SET @Tmp_Codigo = @Codigo
      IF LEN(@Tmp_Serial) = 0 SET @Tmp_Serial = @Serial
      IF LEN(@Tmp_Color)  = 0 SET @Tmp_Color  = @Color

      -- Actualiza datos adicionales del vehiculo
      UPDATE dbo.SESA_VW_VEHICULOS
         SET Codigo = @Tmp_Codigo,
             Serial = @Tmp_Serial,
             Color  = @Tmp_Color,
             Kilometraje = @Kilometraje
         WHERE (CodProd = @Placa)
   END
END

-----------------------------------------------------------------------------------------
-- ACTUALIZA LA ORDEN DE REPARACION CON DATOS DEL VEHICULO
-----------------------------------------------------------------------------------------
BEGIN
   -- Lee datos actuales del vehiculo
   SELECT @Tmp_Codigo = UPPER(ISNULL(Codigo, @Codigo)),
          @Tmp_Serial = UPPER(ISNULL(Serial, @Serial)),
          @Tmp_Color  = UPPER(ISNULL(Color,  @Color))
      FROM  dbo.SESA_VW_VEHICULOS
      WHERE (CodProd = @Placa)

   -- Actualiza la orden de reparacion con datos del vehiculo
   UPDATE dbo.SESA_VW_ORDENES_REPARACION
      SET Codigo = @Tmp_Codigo,
          Serial = @Tmp_Serial,
          Color  = @Tmp_Color
      WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
END

-----------------------------------------------------------------------------------------
-- ACTUALIZA SAFACT DE LA ORDEN DE REPARACION
-----------------------------------------------------------------------------------------
BEGIN
   UPDATE dbo.SAFACT
      SET OrdenC = @NumeroD
      WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
END

-----------------------------------------------------------------------------------------
-- PROCESA CIERRE DE ORDENES DISTINTAS A CONTADO PARA QUE NO SEAN EDITABLES Y TENGAN FECHA DE CORTE
-----------------------------------------------------------------------------------------
BEGIN
   IF @LIQUIDACION<>'CONTADO' AND @STATUS='CERRADA'
      BEGIN
        UPDATE SAFACT SET TIPOFAC='Z' WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD) 
        UPDATE SAFACT_01 SET TIPOFAC='Z' WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
        -- UPDATE SAITEMFAC SET TIPOFAC='Z' WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
        -- LA SIGUENTE INSTRUCCION ES PARA ELIMINAR LOS REGISTROS EN SAITEMFAC QUE SE CREAN 
        -- Y DUPLICAN LA DATA SOLO QUE LO CREA CON TIPOFAC='G' OJO AVERIGUAR POR QUE PASA ESTO
        --DELETE FROM SAITEMFAC WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD) 
      END
 
END