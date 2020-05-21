-- ********************************************************************************
-- CREA TRIGGER PARA PROCESAR NUEVA COMPRA Y DEVOLUCION DE COMPRA  DE VEHICULO
-- ********************************************************************************
DROP TRIGGER [SESA_TG_COMPRA_VEHICULO_INSERT]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [SESA_TG_COMPRA_VEHICULO_INSERT] ON [dbo].[SACOMP_01] 
WITH ENCRYPTION
AFTER INSERT
AS

DECLARE @TipoDoc varchar (1),
        @NumeroD varchar (15),
        @CodProv varchar (10),
        @CodOper varchar (10),
        @Compra varchar (10)

BEGIN
   SELECT @TipoDoc = TipoCom,
          @NumeroD = NumeroD,
          @CodProv = CodProv
         
      FROM INSERTED

   SELECT @CodOper = X.CodOper
      FROM dbo.SACOMP AS X
      WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv)

   -- Procesa nueva compra en espera
   IF @TipoDoc = 'M'
   BEGIN
      UPDATE dbo.SACOMP
         SET OrdenC = @Compra
         WHERE (TipoCom = @TipoDoc AND NumeroD = @NumeroD AND CodProv = @CodProv)
   END

   -- Procesa nueva compra de vehiculo
   IF @TipoDoc = 'H' AND @CodOper = '05-101'
      EXECUTE dbo.SESA_SP_COMPRA_VEHICULO @TipoDoc, @NumeroD, @CodProv
   ELSE
   -- Procesa devolucion de compra de vehiculo
   IF @TipoDoc = 'I' AND @CodOper = '05-101'
      EXECUTE dbo.SESA_SP_DEVCOMPRA_VEHICULO @TipoDoc, @NumeroD, @CodProv

END




GO  