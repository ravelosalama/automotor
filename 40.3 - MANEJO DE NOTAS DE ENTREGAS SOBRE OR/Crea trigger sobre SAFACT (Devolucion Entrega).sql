 -- *********************************************************************************************************
-- ELIMINA ITEMS DE REPUESTOS DE NOTAS DE ENTREGA A LA ORDEN DE REPARACION DE GARANTIA, INTERNA Y ACCESORIO
-- ORIGINAL AGREGADO EL 01/12/2007 POR: JOSE RAVELO
-- SE AGREGAN VALIDACIONES ESCRITAS EN DOCUMENTO POR VARIABLE RESULTADO
-- PROCEDIMIENTO ALMACENADO CONVERTIDO EN TRIGGER EN MAY 2008 POR JOSE RAVELO SE MEJORA SU FUNCIONAMIENTO
-- *********************************************************************************************************


DROP TRIGGER SESA_TG_DEVUELVE_ENTREGA
GO
 
CREATE TRIGGER SESA_TG_DEVUELVE_ENTREGA ON SAFACT_03
WITH ENCRYPTION
AFTER INSERT, UPDATE
AS

DECLARE @Tipofac varchar (1),
        @NumeroD varchar (15),
        @CodOper varchar (10),
        @OrdenReparacion Varchar(10),
        @liquidacion Varchar(15),
        @status Varchar(15),
        @Codclie Varchar(10),
        @VALE varchar(10)

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



   -- RECOGE DATOS DE TABLA INSERTED.SAFACT_03
   SELECT @Tipofac = TipoFac,
          @NumeroD = NumeroD,
          @OrdenReparacion = Nro_OR,
          @Vale=vale 
   FROM INSERTED

   -- RECOGE DATOS DE SAFACT 
   SELECT @CodOper = CodOper,
          @CODCLIE=CodClie  FROM SAFACT 
      WHERE (TipoFac = @Tipofac AND NumeroD = @NumeroD)

   -- RECOGE DATOS DE SAFACT_01 REGISTRO DE LA ORDEN DE REPARACION
   SELECT @LIQUIDACION=LIQUIDACION, @STATUS=STATUS
   FROM SAFACT_01 
   WHERE NUMEROD=@OrdenReparacion AND TipoFac='G'


IF @codoper='01-301' and @tipofac='D' -- ES UNA OPERACION DE SERVICIO Y DEVOLUCION DE NOTA DE ENTREGA EN VENTA

BEGIN

 IF EXISTS (SELECT NumeroD FROM dbo.SAFACT WHERE (TipoFac = 'G' and NumeroD = @OrdenReparacion)) 
  BEGIN 

  IF @CODCLIE='99002' OR @CODCLIE='99003' OR @CODCLIE='99004'
   BEGIN

    IF SUBSTRING(@LIQUIDACION,1,1)='G' OR SUBSTRING(@LIQUIDACION,1,1)='I' OR SUBSTRING(@LIQUIDACION,1,1)='A'
     BEGIN

     IF SUBSTRING(@STATUS,1,1)='P'
      BEGIN

      -- Borra items de repuestos de la OR
      DELETE dbo.SAITEMFAC
         WHERE (TipoFac = 'G' AND NumeroD = @OrdenReparacion AND EsServ = 0)

      -- Procesa cada tipo de repuesto para todos las notas de entregas relacionados con la OR
      DECLARE MIREG CURSOR FOR
      SELECT DISTINCT X.CodItem
         FROM dbo.SAITEMFAC AS X
         INNER JOIN dbo.SAFACT_03 AS Y
         ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD) INNER JOIN SAFACT AS Z
         ON X.TIPOFAC=Z.TIPOFAC AND X.NUMEROD=Z.NUMEROD 
         WHERE (X.TipoFac = 'C' AND Y.Nro_OR = @OrdenReparacion) AND (Z.NUMEROR IS NULL or Z.NUMEROR = '')
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @CodItem
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
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD) INNER JOIN SAFACT AS Z
            ON X.TIPOFAC=Z.TIPOFAC AND X.NUMEROD=Z.NUMEROD
            WHERE (X.TipoFac = 'C' and Y.Nro_OR = @OrdenReparacion and X.CodItem = @CodItem) AND Z.NUMEROR IS NULL
     
         -- Lee Costo y precio del item pedido.
         SELECT @CodUbic  = X.CodUbic,
                @Descrip1 = X.Descrip1,
                @Costo    = X.Costo,
                @Precio   = X.Precio,
                @FechaE   = X.FechaE,
                @FechaL   = X.FechaL
            FROM  dbo.SAITEMFAC AS X
            INNER JOIN dbo.SAFACT_03 AS Y
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD) INNER JOIN SAFACT AS Z
            ON X.TIPOFAC=Z.TIPOFAC AND X.NUMEROD=Z.NUMEROD
            WHERE (X.TipoFac = 'C' and Y.Nro_OR = @OrdenReparacion and X.CodItem = @CodItem) AND Z.NUMEROR IS NULL

         -- Inserta item de repuesto en la OR.
         INSERT dbo.SAITEMFAC (TipoFac, NumeroD, CodItem, NroLinea, CodUbic, Descrip1, Costo, Cantidad, Precio, Signo, FechaE, FechaL)
            VALUES ('G', @OrdenReparacion, @CodItem, @NroLinea, @CodUbic, @Descrip1, @Costo, @Cantidad, @Precio, 1, @FechaE, @FechaL)

         FETCH NEXT FROM MIREG INTO @CodItem
      END
      CLOSE MIREG
      DEALLOCATE MIREG
      SET @ELIMINAR='0'
      SET @RESULTADO='DEVOLUCION REALIZADA SATISFACTORIAMENTE'
      
    END
    ELSE
      BEGIN
    SET @RESULTADO='<<DEVOLUCION INVALIDA>>  O/R ESTA CERRADA, NO PUEDEN ELIMINARSE REPUESTOS EN ELLA.  '
    SET @ELIMINAR='1'
      END
  END
  ELSE
      BEGIN
   SET @RESULTADO='<<DEVOLUCION INVALIDA>> LA LIQUIDACION DE LA O/R NO ES VALIDA PARA PROCESAR ESTA ACCION, REVISE LOS DATOS E INTENTE DE NUEVO'
   SET @ELIMINAR='1'
      END
  END
  ELSE
       BEGIN
   SET  @RESULTADO='<<DEVOLUCION INVALIDA>> CLIENTE INVALIDO, REVISE EL CODIGO DE CLIENTE E INTENTE DE NUEVO '
   SET  @ELIMINAR='1'
       END
 END 
 ELSE
       BEGIN
    SET @RESULTADO='<<DEVOLUCION INVALIDA>> O/R:' + @OrdenReparacion + ' NO EXISTE EN LA BASE DE DATOS, REVISE LOS DATOS E INTENTE DE NUEVO'
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

   UPDATE SAFACT SET NOTAS1=@RESULTADO, ORDENC=@OrdenReparacion WHERE NUMEROD=@NUMEROD AND TIPOFAC='D'   


END   