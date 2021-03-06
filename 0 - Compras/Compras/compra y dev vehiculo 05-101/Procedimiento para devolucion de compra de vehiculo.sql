-- *****************************************************************************************
-- PROCESA DEVOLUCION DE COMPRA DE VEHICULO
-- 1. Borra registro de del vehiculo.
-- 5. Borra registro de extension del vehiculo.
-- *****************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SESA_SP_DEVCOMPRA_VEHICULO]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SESA_SP_DEVCOMPRA_VEHICULO]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.SESA_SP_DEVCOMPRA_VEHICULO
@TipoDoc varchar(1), @NumeroD Varchar(10), @CodProv Varchar(10)
WITH ENCRYPTION
AS

DECLARE @Placa varchar (10)

BEGIN
   SELECT @Placa = UPPER(ISNULL(X.Placa, ''))
      FROM dbo.SESA_VW_COMPRA_VEHICULO AS X
      WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv)

   IF EXISTS (SELECT CodProd FROM dbo.SAPROD WHERE (CodProd = @Placa))
   BEGIN
      -- Actualiza vehiculo en inventario.
      DELETE FROM dbo.SAPROD 
         WHERE (CodProd = @Placa)

      -- Actualiza registro de extension del vehiculo.
      DELETE FROM dbo.SESA_VW_VEHICULOS 
         WHERE (CodProd = @Placa)
   END
END

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON
  