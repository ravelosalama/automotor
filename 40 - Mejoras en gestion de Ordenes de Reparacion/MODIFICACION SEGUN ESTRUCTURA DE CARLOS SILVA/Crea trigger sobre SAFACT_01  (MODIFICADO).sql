 -- ************************************************
-- TRIGGER PARA PROCESAR ORDENES DE REPARCION
-- *************************************************
-- MODIFICADO MAY-2008 POR JOSE RAVELO
-- SE AGREGA ADAPTACIONES PARA OPTIMIZACION DE GESTION EN ORDENES DE REPARACION
-- ESTE TRIGGER QUEDA UNICAMENTE PARA CASOS CREACION Y EDICION DE ORDENES DE REPARACION

DROP TRIGGER SESA_TG_ESPERA_OR
GO
 
CREATE TRIGGER SESA_TG_ESPERA_OR ON SAFACT_01
WITH ENCRYPTION
AFTER INSERT, UPDATE
AS

DECLARE @TipoDoc varchar (1),
        @NumeroD varchar (15),
        @CodOper varchar (10),
        @OrdenReparacion Varchar(10),
        @liquidacion Varchar(15),
        @status Varchar(15),
        @Codclie Varchar(10)
BEGIN
   -- RECOGE DATOS DE TABLA INSERTED.SAFACT_01
   SELECT @TipoDoc = TipoFac,
          @NumeroD = NumeroD
--        @OrdenReparacion = Orden_de_reparacion 
   FROM INSERTED

   -- RECOGE DATOS DE SAFACT 
   SELECT @CodOper = X.CodOper,
          @CODCLIE=X.CodClie  FROM SAFACT AS X
      WHERE (X.TipoFac = @TipoDoc AND X.NumeroD = @NumeroD)

   -- RECOGE DATOS DE SAFACT_01 REGISTRO DE LA ORDEN DE REPARACION
   SELECT @LIQUIDACION=LIQUIDACION, @STATUS=STATUS
   FROM SAFACT_01 
   WHERE NUMEROD=@OrdenReparacion AND TipoFac='G'

-- -- Procesa nuevo pedido de repuestos para orden de reparacion
-- IF @TipoDoc = 'E' AND @CodOper = '01-301'
--    EXECUTE SESA_SP_PROCESA_PEDIDO_OR @TipoDoc, @OrdenReparacion, @NUMEROD, @CODCLIE, @LIQUIDACION, @STATUS
   -- Procesa nueva orden de reparacion
   IF @TipoDoc = 'G' AND @CodOper = '01-301'
      EXECUTE SESA_SP_PROCESA_ESPERA_OR @TipoDoc, @NumeroD 
-- -- Procesa nueva Entrega de repuesto para OR de Garantia, Interna Accesorio.
-- IF @TipoDoc = 'C' AND @CodOper = '01-301'
--    EXECUTE SESA_SP_PROCESA_ENTREGA_OR @TipoDoc, @OrdenReparacion, @NUMEROD, @CODCLIE, @LIQUIDACION, @STATUS
END