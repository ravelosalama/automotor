-- *****************************************************************************************
-- PROCESA DEVOLUCION DE COMPRA DE REPUESTOS
-- 1. Borra registro de del vehiculo.
-- 5. Borra registro de extension del vehiculo.
-- *****************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SESA_SP_DEVCOMPRA_REPUESTOS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SESA_SP_DEVCOMPRA_REPUESTOS]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.SESA_SP_DEVCOMPRA_REPUESTOS
@TipoDoc varchar(1), @NumeroD Varchar(10), @CodProv Varchar(10)
WITH ENCRYPTION
AS

BEGIN
   IF EXISTS (SELECT CodProd FROM dbo.SAPROD WHERE (CodProd = @Placa))
   BEGIN
      -- Actualiza vehiculo en inventario.
      DELETE FROM dbo.SAPROD 
         WHERE (TipoCom = @TipoDoc AND NumeroD = @NumeroD AND CodProv = @CodProv)

   END
END

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON

