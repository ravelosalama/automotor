-- ********************************************************************************
-- CREA TRIGGER PARA NUEVOS ITEMS DE COMPRA Y DEVOLUCION DE COMPRA DE REPUESTOS
-- ********************************************************************************
DROP TRIGGER SESA_TG_COMPRA_REPUESTOS_INSERT
GO
 
CREATE TRIGGER SESA_TG_COMPRA_REPUESTOS_INSERT ON SACOMP 
WITH ENCRYPTION
AFTER INSERT
AS

DECLARE @TipoDoc varchar (1),
        @NumeroD varchar (15),
        @CodProv varchar (10),
        @CodOper varchar (10)

BEGIN
   SELECT @TipoDoc = TipoCom,
          @NumeroD = NumeroD,
          @CodProv = CodProv,
          @CodOper = CodOper
      FROM INSERTED

   -- Procesa nueva compra de repuestos
   IF @TipoDoc = 'H' AND @CodOper = '05-201'
      EXECUTE dbo.SESA_SP_COMPRA_REPUESTOS @TipoDoc, @NumeroD, @CodProv
--   ELSE
   -- Procesa devolucion de compra de repuestos
--   IF @TipoDoc = 'I' AND @CodOper = '05-201'
--      EXECUTE dbo.SESA_SP_DEVCOMPRA_REPUESTO @TipoDoc, @NumeroD, @CodProv

END








