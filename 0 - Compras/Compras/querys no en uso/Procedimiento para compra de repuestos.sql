-- *****************************************************************************************
-- PROCESA COMPRA DE REPUESTOS
-- 1. Crea registro de movimiento en el kardex.
-- *****************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SESA_SP_COMPRA_REPUESTOS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SESA_SP_COMPRA_REPUESTOS]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.SESA_SP_COMPRA_REPUESTOS
   @TipoDoc varchar (1),
   @NumeroD varchar (10),
   @CodProv varchar (10)

WITH ENCRYPTION
AS


DECLARE @FechaHoy datetime

-- Datos del registro de kardex
DECLARE @CodItem varchar (15),
        @NroLinea int,
        @TipoEntidad varchar (1),
        @Entidad varchar (10),
        @NombreEntidad varchar (40),
        @FechaMov datetime,
        @CodUbic varchar (10),
        @DescRepuesto varchar (40),
        @Refere varchar (20),
        @Existen decimal(28,3),
        @Cantidad decimal(28,3),
        @Costo decimal(28,3),
        @Precio decimal(28,3),
        @Signo smallint,
        @EsServ smallint,
        @ES varchar (1),
        @Departamento varchar (20),
        @Faltante decimal(28,3),
        @CodOper varchar (10),
        @Compro decimal(28,3),
        @Pedido decimal(28,3),
        @Minimo decimal(28,3),
        @EsUnid smallint,
        @EsExento smallint,
        @CodEsta varchar (20),
        @CodUsua varchar (20)

-- Campos de registro de IVA
DECLARE @CodIva   varchar (5),
        @MontoIva decimal(28,3),
        @BaseIva  decimal(28,3),
        @TazaIva  decimal(28,3)

SET @FechaHoy     = getdate()
SET @TipoEntidad  = 'P'
SET @ES           = 'E'
SET @Departamento = 'ALMACEN'
SET @Faltante     = 0

BEGIN
   DECLARE MIREG2 CURSOR FOR
   SELECT X.CodItem, X.NroLinea, X.Descrip1, X.CodUbic, X.Cantidad, X.Costo, X.Precio, X.Signo, X.EsServ, X.EsUnid, X.EsExento
      FROM dbo.SAITEMCOM AS X
      WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv AND X.EsServ = 0)
   OPEN MIREG2
   FETCH NEXT FROM MIREG2 INTO @CodItem, @NroLinea, @DescRepuesto, @CodUbic, @Cantidad, @Costo, @Precio, @Signo, @EsServ, @EsUnid, @EsExento
   WHILE (@@FETCH_STATUS = 0) 
   BEGIN
      SELECT @CodOper       = X.CodOper,
             @FechaMov      = X.FechaE,
             @NombreEntidad = Descrip,
             @CodEsta       = X.CodEsta,
             @CodUsua       = X.CodUsua
         FROM dbo.SACOMP AS X
         WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv)

      SELECT @Refere  = Refere,
             @Existen = Existen, 
             @Pedido  = Pedido,
             @Compro  = Compro,
             @Minimo  = Minimo
         FROM dbo.SAPROD AS X
         WHERE (CodProd = @CodItem)

      IF @EsExento = 0
         SELECT @CodIva   = X.CodTaxs,
                @MontoIva = X.Monto,
                @BaseIva  = X.TGravable,
                @TazaIva  = X.MtoTax
         FROM dbo.SATAXITC AS X
         WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv AND X.CodItem = @CodItem AND X.NroLinea = @NroLinea)

      IF @EsServ = 0
      BEGIN
         -- Crea registro de movimiento en el kardex.
         INSERT SEXX_KARDEX (TipoMov,  NumeroD,  NroLinea,  CodProd,  Descrip1,      Refere,  CodUbic,  FechaMov,  TipoEntidad,  Entidad,  NombreEntidad,  TipoDoc,  NroDoc,   ES,  CodOper,  Departamento,  Signo,  Cantidad,  Faltante,  Costo,  Precio,  Existen,  Deficit,                                  EsUnid,  EsExento,  CodIva,  BaseIva,  MontoIva,  TazaIva,  CodEsta,  CodUsua)
            VALUES         (@TipoDoc, @NumeroD, @NroLinea, @CodItem, @DescRepuesto, @Refere, @CodUbic, @FechaMov, @TipoEntidad, @CodProv, @NombreEntidad, @TipoDoc, @NumeroD, @ES, @CodOper, @Departamento, @Signo, @Cantidad, @Faltante, @Costo, @Precio, @Existen, (@Existen + @Pedido - @Minimo - @Compro), @EsUnid, @EsExento, @CodIva, @BaseIva, @MontoIva, @TazaIva, @CodEsta, @CodUsua)
      END

      FETCH NEXT FROM MIREG2 INTO @CodItem, @NroLinea, @DescRepuesto, @CodUbic, @Cantidad, @Costo, @Precio, @Signo, @EsServ, @EsUnid, @EsExento
   END
   CLOSE MIREG2
   DEALLOCATE MIREG2
END
 
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
