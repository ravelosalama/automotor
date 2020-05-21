-- ******************************************************************************
-- AGREGA ITEMS DE REPUESTOS DE NOTAS DE ENTREGA A LA ORDEN DE REPARACION DE GARANTIA, INTERNA Y ACCESORIO
-- ORIGINAL AGREGADO EL 01/12/2007 POR: JOSE RAVELO
-- SE AGREGAN VALIDACIONES ESCRITAS EN DOCUMENTO POR VARIABLE RESULTADO
-- ******************************************************************************
DROP PROCEDURE SESA_SP_PROCESA_ENTREGA_OR
GO 

CREATE PROCEDURE SESA_SP_PROCESA_ENTREGA_OR
@TipoDoc varchar(1),
@OrdenReparacion Varchar(10),
@NUMEROD Varchar(10),
@CODCLIE Varchar(10),
@LIQUIDACION Varchar(15),
@STATUS Varchar(15)
WITH ENCRYPTION
AS

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
        @Resultado Varchar(35),
        @Eliminar Varchar(1)


BEGIN

 IF EXISTS (SELECT NumeroD FROM dbo.SAFACT WHERE (TipoFac = 'G' and NumeroD = @OrdenReparacion)) 
  BEGIN 

  IF @CODCLIE='99002' OR @CODCLIE='99003' OR @CODCLIE='99004'
   BEGIN

    IF SUBSTRING(@LIQUIDACION,1,3)='GAR' OR SUBSTRING(@LIQUIDACION,1,3)='INT' OR SUBSTRING(@LIQUIDACION,1,3)='ACC'
     BEGIN

     IF SUBSTRING(@STATUS,1,3)='PEN'
      BEGIN

      -- Borra items de repuestos de la OR
      DELETE dbo.SAITEMFAC
         WHERE (TipoFac = 'G' AND NumeroD = @OrdenReparacion AND EsServ = 0)

      -- Procesa cada tipo de repuesto para todos las notas de entregas relacionados con la OR
      DECLARE MIREG CURSOR FOR
      SELECT DISTINCT X.CodItem
         FROM dbo.SAITEMFAC AS X
         INNER JOIN dbo.SESA_VW_ORDENES_REPARACION AS Y
         ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
         WHERE (X.TipoFac = 'C' AND Y.Orden_de_reparacion = @OrdenReparacion)
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
            INNER JOIN dbo.SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
            WHERE (X.TipoFac = 'C' and Y.Orden_de_reparacion = @OrdenReparacion and X.CodItem = @CodItem)
     
         -- Lee Costo y precio del item pedido.
         SELECT @CodUbic  = X.CodUbic,
                @Descrip1 = X.Descrip1,
                @Costo    = X.Costo,
                @Precio   = X.Precio,
                @FechaE   = X.FechaE,
                @FechaL   = X.FechaL
            FROM  dbo.SAITEMFAC AS X
            INNER JOIN dbo.SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac and X.NumeroD = Y.NumeroD)
            WHERE (X.TipoFac = 'C' and Y.Orden_de_reparacion = @OrdenReparacion and X.CodItem = @CodItem)

         -- Inserta item de repuesto en la OR.
         INSERT dbo.SAITEMFAC (TipoFac, NumeroD, CodItem, NroLinea, CodUbic, Descrip1, Costo, Cantidad, Precio, Signo, FechaE, FechaL)
            VALUES ('G', @OrdenReparacion, @CodItem, @NroLinea, @CodUbic, @Descrip1, @Costo, @Cantidad, @Precio, 1, @FechaE, @FechaL)

         FETCH NEXT FROM MIREG INTO @CodItem
      END
      CLOSE MIREG
      DEALLOCATE MIREG
      SET @ELIMINAR='0'
      SET @RESULTADO='ENTREGA CARGADA SATISFACTORIAMENTE'
      
    END
    ELSE
      BEGIN
    SET @RESULTADO='<<ENTREGA INVALIDA>>   O/R CERRADA  '
    SET @ELIMINAR='1'
      END
  END
  ELSE
      BEGIN
   SET @RESULTADO='<<ENTREGA INVALIDA>>LIQUIDACION INVAL'
   SET @ELIMINAR='1'
      END
  END
  ELSE
       BEGIN
   SET  @RESULTADO='<<ENTREGA INVALIDA>> CLIENTE INVALIDO'
   SET  @ELIMINAR='1'
       END
 END 
 ELSE
       BEGIN
    SET @RESULTADO='<<ENTREGA INVALIDA>> O/R NO EXISTE  '
    SET @ELIMINAR='1'
       END
END
UPDATE SAFACT_01 SET RESULTADO=@RESULTADO, ELIMINAR=@ELIMINAR WHERE NUMEROD=@NUMEROD AND TIPOFAC='C'
 
