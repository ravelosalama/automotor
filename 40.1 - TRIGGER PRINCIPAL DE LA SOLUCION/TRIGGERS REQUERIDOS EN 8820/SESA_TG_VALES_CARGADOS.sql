--MODIFICACION OCT 2013 TRIGGER ORIGINAL DESDE SAFACT_03 SE CAMBIA A SAITEMFAC X CAMBIO DE SECUENCIA DE GRABACION DE TABLAS EN REVISION DE VERSION 8820
-- 
--
--
--
-- *********************************************************************************************************
-- AGREGA ITEMS DE REPUESTOS DE PEDIDOS  A LA ORDEN DE REPARACION DE CLIENTE PUBLICO CONTADO 
-- ORIGINAL AGREGADO EL 01/12/2007 POR: JOSE RAVELO
-- SE AGREGAN VALIDACIONES ESCRITAS EN DOCUMENTO POR VARIABLE RESULTADO
-- PROCEDIMIENTO ALMACENADO CONVERTIDO EN TRIGGER EN MAY 2008 POR JOSE RAVELO SE MEJORA SU FUNCIONAMIENTO
-- MODIFICACION 13/03/2013 PARA RORAIMA SE INCLUYE GARANTIA PARA FACTURAR POR CAJA LINEA 67
-- *********************************************************************************************************



drop trigger sesa_tg_vales_cargados

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER SESA_TG_VALES_CARGADOS ON SAitemfac -- modificada
WITH ENCRYPTION
AFTER INSERT, update
AS
 
DECLARE @TipoFAC varchar (1),
        @NumeroD varchar (15),
        @CodOper varchar (10),
        @OrdenReparacion Varchar(10),
        @Vale Varchar(10),
        @liquidacion Varchar(15),
        @status Varchar(15),
        @Codclie Varchar(10)

DECLARE @NroPedido varchar(10),
        @CodItem varchar(15),
        @NroLinea int,
        @CodUbic varchar(10),
        @Descrip1 varchar(50),
        @Cantidad decimal (28,2),
        @Costo decimal (28,2),
        @Precio decimal (28,2),
        @FechaE datetime,
        @FechaL datetime,  
        @Resultado Varchar(200),
        @Eliminar Varchar(1)


   -- RECOGE DATOS DE TABLA INSERTED
   SELECT @TipoFac = TipoFac,
          @NumeroD = NumeroD
   from inserted       
          
   select      
          @OrdenReparacion = Nro_OR,
          @Vale=vale 
   FROM safact_03  
   where tipofac=@tipofac and numerod=@numerod
   
      -- modificada

   -- RECOGE DATOS DE SAFACT 
   SELECT @CodOper = CodOper,
          @CODCLIE=CodClie  FROM SAFACT 
      WHERE (TipoFac = @TipoFac AND NumeroD = @NumeroD)

   -- RECOGE DATOS DE SAFACT_01 REGISTRO DE LA ORDEN DE REPARACION
   SELECT @LIQUIDACION=LIQUIDACION, @STATUS=STATUS
   FROM SAFACT_01 
   WHERE NUMEROD=@OrdenReparacion AND TipoFac='G'

IF @CODOPER='01-301' AND @TIPOFAC='E' -- ES UNA OPERACION DE SERVICIOS EN UN PEDIDO DE VENTA.

BEGIN

 IF EXISTS (SELECT NumeroD FROM dbo.SAFACT WHERE (TipoFac = 'G' and NumeroD = @OrdenReparacion)) 
  BEGIN 

  IF @CODCLIE='99001'
   BEGIN

     IF SUBSTRING(@LIQUIDACION,1,3)='CON' --OR SUBSTRING(@LIQUIDACION,1,3)='GAR' -- MODIFICACION ESPECIAL RORAIMA MOTORS CODIGO ORIGINAL: IF SUBSTRING(@LIQUIDACION,1,3)='CON'
     BEGIN

     IF SUBSTRING(@STATUS,1,3)='PEN'
      BEGIN

      -- Borra items de repuestos de la OR
      DELETE dbo.SAITEMFAC
         WHERE (TipoFac = 'G' AND NumeroD = @OrdenReparacion AND EsServ = 0)

      -- Procesa cada tipo de repuesto para todos los pedidos relacionados con la OR
      DECLARE MIREG SCROLL CURSOR FOR
      SELECT DISTINCT X.CodItem
         FROM dbo.SAITEMFAC AS X
         INNER JOIN dbo.SAFACT_03 AS Y
         ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
         WHERE (X.TipoFac = 'E' AND Y.NRO_OR = @OrdenReparacion)
      OPEN MIREG
      FETCH FIRST FROM MIREG INTO @CodItem
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN

         -- Determina el proximo nro de linea
         SELECT @NroLinea = NroLinea + 1
            FROM  dbo.SAITEMFAC
            WHERE (TipoFac = 'G' and NumeroD = @OrdenReparacion)

         -- Determina la cantidad del repuesto entregado
         SELECT @Cantidad = SUM(X.Cantidad)
            FROM  dbo.SAITEMFAC AS X
            INNER JOIN dbo.SAFACT_03 AS Y
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
            WHERE (X.TipoFac = 'E' and Y.Nro_OR = @OrdenReparacion and X.CodItem = @CodItem)
     
         -- Lee Costo y precio del item pedido.
         SELECT @CodUbic  = X.CodUbic,
                @Descrip1 = X.Descrip1,
                @Costo    = X.Costo,
                @Precio   = X.Precio,
                @FechaE   = X.FechaE,
                @FechaL   = X.FechaL
            FROM  dbo.SAITEMFAC AS X
            INNER JOIN dbo.SAFACT_03 AS Y
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
            WHERE (X.TipoFac = 'E' and Y.Nro_OR = @OrdenReparacion and X.CodItem = @CodItem)

         -- Inserta item de repuesto en la OR.
         INSERT dbo.SAITEMFAC (TipoFac, NumeroD, CodItem, NroLinea, CodUbic, Descrip1, Costo, Cantidad, Precio, Signo, FechaE, FechaL)
            VALUES ('G', @OrdenReparacion, @CodItem, @NroLinea, @CodUbic, @Descrip1, @Costo, @Cantidad, @Precio, 1, @FechaE, @FechaL)

         FETCH NEXT FROM MIREG INTO @CodItem
      END
      CLOSE MIREG
      DEALLOCATE MIREG
      SET @ELIMINAR='0'
      SET @RESULTADO='PEDIDO CARGADO SATISFACTORIAMENTE'
     
      -- Actualiza OrdenC en Safact 
      UPDATE SAFACT SET ORDENC=@ORDENREPARACION WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
    
      
    END
    ELSE
      BEGIN
    SET @RESULTADO= '<<PEDIDO NO PROCESADO>> O/R CITADA SE ENCUENTRA CERRADA NO PUEDE CARGARSE REPUESTOS EN ELLA, VERIFIQUE EL STATUS E INTENTE DE NUEVO'
    SET @ELIMINAR='1'
      END
  END
  ELSE
      BEGIN
   SET @RESULTADO='<<PEDIDO NO PROCESADO>> O/R CITADA NO TIENE LIQUIDACION VALIDA PARA ESTA OPERACION, NO PUEDE CARGARSE REPUESTOS EN ELLA,  VERIFIQUE LIQUIDACION E INTENTE DE NUEVO'
   SET @ELIMINAR='1'
      END
  END
  ELSE
       BEGIN
   SET  @RESULTADO='<<PEDIDO NO PROCESADO>> HA REGISTRADO UN CLIENTE INVALIDO PARA ESTA OPERACION EL CODIGO CORRECTO ES: 99001'
   SET  @ELIMINAR='1'
       END
 END 
 ELSE
       BEGIN
    SET @RESULTADO='<<PEDIDO NO PROCESADO>> O/R:'+ @ORDENREPARACION + ' CITADA NO EXISTE EN LA BASE DE DATOS VERIFIQUE LOS DATOS E INTENTE DE NUEVO '
    SET @ELIMINAR='1'
       END


 

-- MUESTRA PANTALLA CON RESULTADO DE VALIDACIONES SI LAS HAY.

   IF @ELIMINAR=1
   BEGIN
      RAISERROR (@RESULTADO,16,1)
      ROLLBACK TRANSACTION
      RETURN
   END
   ELSE
   UPDATE SAFACT SET NOTAS1=@RESULTADO WHERE NUMEROD=@NUMEROD AND TIPOFAC='E'   
   
END



GO
