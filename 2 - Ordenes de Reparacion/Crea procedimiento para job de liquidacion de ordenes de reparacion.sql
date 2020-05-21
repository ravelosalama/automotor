-- *****************************************************************************************
-- PROCEDIMIENTO QUE LIQUIDA ORDENES DE REPARACION
-- PARTE 1. PROCESO DE ORDENES DE REPARACION FACTURADAS.
-- PARTE 2. PROCESA LA ORDENES DE REPARACION CERRADA CON LIQUIDACION 'INTERNA', 'GARANTIA'.
-- *****************************************************************************************
-- NO SE ENCUENTRA EN USO


DROP PROCEDURE SESA_SP_LIQUIDA_OR
GO 

CREATE PROCEDURE SESA_SP_LIQUIDA_OR
WITH ENCRYPTION
AS


DECLARE @TipoDoc varchar (1),
        @CodOper varchar(10),
        @NumeroD varchar(10),
        @FechaE datetime,
        @Liquidacion varchar (15),
        @Status varchar (15),
        @Placa varchar(10),
        @OrdenReparacion varchar(10),
        @NroPedido varchar(10)

DECLARE @TotCompro decimal (28,3)

DECLARE @FechaHoy datetime
SET @FechaHoy  = getdate()
SET @CodOper = '01-301'

----------------------------------------------------------------------------------
-- PARTE 1. PROCESO DE ORDENES DE REPARACIONES FACTURADAS
-- 1. Crea registro de historico de ordenes de reparacion (encabezado).
-- 2. Crea registro de historico de ordenes de reparacion (items).
-- 3. Elimina pedidos de repuestos asociados a la orden de reparacion.
-- 4. Actualiza monto comprometido del producto.
-- 5. Limpia rastro del documento en espera OR. 
-- 6. Coloca en status de 'HISTORICO' a la orden de reparacion.
----------------------------------------------------------------------------------
SET @TipoDoc  = 'A'

BEGIN
   DECLARE CURSOR_FACT CURSOR FOR
   SELECT X.NumeroD, X.FechaE, Y.Placa, Y.Orden_de_reparacion
      FROM SAFACT AS X
      INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
      ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
      WHERE (X.TipoFac = 'A' AND X.CodOper = @CodOper AND Y.Status <> 'HISTORICO')
   OPEN CURSOR_FACT
   FETCH NEXT FROM CURSOR_FACT INTO @NumeroD, @FechaE, @Placa, @OrdenReparacion
   WHILE (@@FETCH_STATUS = 0) 
   BEGIN
      -- 1. Crea registro de historico de ordenes de reparacion (encabezado).
      DELETE SESA_HOR
         WHERE (OrdenReparacion = @OrdenReparacion)
           AND (NroFact = @NumeroD)
      INSERT INTO SESA_HOR (OrdenReparacion, NroFact, Placa, FechaInicio, FechaFinal,
                            Kilometraje, Liquidacion, Status, Revisado, CodClie,
                            NombClie, CodVend, Notas1, Notas2, Notas3, Notas4,
                            Notas5, Notas6, Notas7, Notas8, Notas9, Notas10)
         SELECT Y.Orden_de_reparacion, Y.NumeroD, isnull(Y.Placa, 'XXXXXX'), X.FechaE, @FechaHoy, 
                ISNULL(Y.Kilometraje,0), Y.Liquidacion, Y.Status, Y.Revisado, X.CodClie,
                       X.Descrip, X.CodVend, X.Notas1, X.Notas2, X.Notas3, X.Notas4, 
                       X.Notas5, X.Notas6, X.Notas7, X.Notas8, X.Notas9, X.Notas10
            FROM SAFACT AS X
            INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
            WHERE (Y.Orden_de_Reparacion = @OrdenReparacion)
              AND (Y.NumeroD = @NumeroD)

      -- 2. Crea registro de historico de ordenes de reparacion (items).
      DELETE SESA_HORIT
         WHERE (OrdenReparacion = @OrdenReparacion)
           AND (NroFact = @NumeroD)
   
      INSERT INTO SESA_HORIT (OrdenReparacion, NroFact, CodItem, NroLinea, DescItem,
                              Cantidad, Costo, Precio, EsServ, CodMeca)
         SELECT Y.Orden_de_reparacion, X.NumeroD, X.CodItem, X.NroLinea, X.Descrip1,
                X.Cantidad, X.Costo, X.Precio, X.EsServ, X.CodMeca 
            FROM SAITEMFAC AS X
            INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
            WHERE (Y.Orden_de_reparacion = @OrdenReparacion)
              AND (Y.NumeroD = @NumeroD)            

      -- 3. Elimina pedidos de repuestos asociados a la orden de reparacion.
      SELECT @NroPedido = X.NumeroD
         FROM SAFACT AS X
         INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
         ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
         WHERE (X.TipoFac = 'E' AND X.CodOper = @CodOper AND Y.Orden_de_Reparacion = @OrdenReparacion)
      DELETE FROM SAITEMFAC
         WHERE (TipoFac = 'E' AND NumeroD = @NroPedido)
      DELETE FROM SAFACT
         WHERE (TipoFac = 'E' AND NumeroD = @NroPedido)

      -- 4. Actualiza monto comprometido del producto. <<<<<<<<<<<<<<<<<<<


      -- 5. Limpia rastro del documento en espera OR.
      DELETE FROM dbo.SESA_VW_ORDENES_REPARACION
         WHERE (TipoFac = 'G' AND NumeroD = @OrdenReparacion)

      -- 5. Coloca en status de 'HISTORICO' a la factura de la orden de reparacion
      UPDATE SESA_VW_ORDENES_REPARACION
         WITH (ROWLOCK)
         SET Status = 'HISTORICO'
         WHERE (TipoFac = 'A' and NumeroD = @NumeroD)

      FETCH NEXT FROM CURSOR_FACT INTO @NumeroD, @FechaE, @Placa, @OrdenReparacion
   END
   CLOSE CURSOR_FACT
   DEALLOCATE CURSOR_FACT
END



--------------------------------------------------------------------------------------
-- PARTE 2. PROCESA LA ORDENES DE REPARACION CERRADA CON LIQUIDACION 'INTERNA', 'GARANTIA'
-- 1. Crea registro de historico de ordenes de reparacion (encabezado).
-- 2. Crea registro de historico de ordenes de reparacion (items).
-- 3. Elimina pedidos de repuestos asociados a la orden de reparacion.
-- 4. Actualiza monto comprometido del producto.
-- 5. Genera movimiento de inventario, si la orden de reparacion tiene repuestos.
-- 6. Actualiza existencia del producto para el deposito en cuestion.
-- 7. Actualiza existencia a nivel de producto.
-- 8. Limpia rastro del documento en espera OR. 
--------------------------------------------------------------------------------------
DECLARE @PrxDesc int,
        @NroDesc Varchar (10),
        @MontoDesc decimal (28,3),
        @OPerDesc Varchar (10),
        @CodUbic Varchar (10),
        @UsoMat Varchar (40)

SET @OperDesc = '09-010'   -- Cod.oper para los descargos automaticos de repuestos por servicios
SET @CodUbic  = '001'      -- Almacen de repuestos
SET @TipoDoc  = 'G'

BEGIN
   DECLARE CURSOR_OR CURSOR FOR
   SELECT X.NumeroD, X.FechaE, Y.Placa, Y.Orden_de_reparacion
      FROM SAFACT AS X
      INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
      ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
      WHERE (X.TipoFac = @TipoDoc)
        AND (X.CodOper = @CodOper)
        AND (Y.Status = 'CERRADA')
        AND (Y.Liquidacion = 'INTERNA' OR Y.Liquidacion = 'GARANTIA')
   OPEN CURSOR_OR
   FETCH NEXT FROM CURSOR_OR INTO @NumeroD, @FechaE, @Placa, @OrdenReparacion
   WHILE (@@FETCH_STATUS = 0) 
   BEGIN
      -- 1. Crea registro de historico de ordenes de reparacion (encabezado).
      DELETE SESA_HOR
         WHERE (OrdenReparacion = @OrdenReparacion)
           AND (NroFact = @NumeroD)
      INSERT INTO SESA_HOR (OrdenReparacion, NroFact, Placa, FechaInicio, FechaFinal,
                            Kilometraje, Liquidacion, Status, Revisado, CodClie,
                            NombClie, CodVend, Notas1, Notas2, Notas3, Notas4,
                            Notas5, Notas6, Notas7, Notas8, Notas9, Notas10)
         SELECT Y.Orden_de_reparacion, Y.NumeroD, isnull(Y.Placa, 'XXXXXX'), X.FechaE, @FechaHoy, 
                isnull(Y.Kilometraje,0), Y.Liquidacion, Y.Status, Y.Revisado, X.CodClie,
                       X.Descrip, X.CodVend, X.Notas1, X.Notas2, X.Notas3, X.Notas4, 
                       X.Notas5, X.Notas6, X.Notas7, X.Notas8, X.Notas9, X.Notas10
            FROM SAFACT AS X
            INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
            WHERE (Y.Orden_de_Reparacion = @OrdenReparacion)
              AND (Y.NumeroD = @NumeroD)

      -- 2. Crea registro de historico de ordenes de reparacion (items).
      DELETE SESA_HORIT
         WHERE (OrdenReparacion = @OrdenReparacion)
           AND (NroFact = @NumeroD)
   
      INSERT INTO SESA_HORIT (OrdenReparacion, NroFact, CodItem, NroLinea, DescItem,
                              Cantidad, Costo, Precio, EsServ, CodMeca)
         SELECT Y.Orden_de_reparacion, X.NumeroD, X.CodItem, X.NroLinea, X.Descrip1,
                X.Cantidad, X.Costo, X.Precio, X.EsServ, X.CodMeca 
            FROM SAITEMFAC AS X
            INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
            ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
            WHERE (Y.Orden_de_reparacion = @OrdenReparacion)
              AND (Y.NumeroD = @NumeroD)            

      -- 3. Elimina pedidos de repuestos asociados a la orden de reparacion.
      SELECT @NroPedido = X.NumeroD
         FROM SAFACT AS X
         INNER JOIN SESA_VW_ORDENES_REPARACION AS Y
         ON (X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD)
         WHERE (X.TipoFac = 'E' AND X.CodOper = @CodOper AND Y.Orden_de_Reparacion = @OrdenReparacion)
      DELETE FROM SAITEMFAC
         WHERE (TipoFac = 'E' AND NumeroD = @NroPedido)
      DELETE FROM SAFACT
         WHERE (TipoFac = 'E' AND NumeroD = @NroPedido)

      -- 4. Actualiza monto comprometido del producto. <<<<<<<<<<<<<<<<<


      IF EXISTS (SELECT X.NumeroD
                    FROM SAITEMFAC AS X
                    INNER JOIN SAFACT AS Y
                    ON X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD
                    WHERE (X.TipoFac = @TipoDoc) AND (Y.CodOper = @CodOper) AND (X.NumeroD = @NumeroD) AND (X.EsServ = 0))
      BEGIN
         -- 5. Genera movimiento de inventario, si la orden de reparacion tiene repuestos.
         -- Obtiene proximo numero de descargo.
         SELECT @PrxDesc = PrxDesc + 1 FROM SACONF
         UPDATE SACONF
            WITH (ROWLOCK)
            SET PrxDesc = @PrxDesc

         SET @NroDesc = SUBSTRING('000000', 1, 6-LEN(@PrxDesc)) + LTRIM(STR(@PrxDesc))

         -- Prepara y crea encabezado del descargo.
         SET @UsoMat = ('Orden de reparacion Nro.: ' + @OrdenReparacion)
         SELECT @MontoDesc = sum(X.Precio * X.Cantidad)
            FROM SAITEMFAC AS X
            INNER JOIN SAFACT AS Y
            ON X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD
            WHERE (X.TipoFac = @TipoDoc) AND (Y.CodOper = @CodOper) AND (X.NumeroD = @NumeroD) AND (X.EsServ = 0)
 
            INSERT SAOPEI (TipoOpi, NumeroD, CodSucu, CodUsua, CodUbic, Signo, Autori, Respon, UsoMat, Monto, FechaE, CodOper)
               VALUES ('O', @NroDesc, '00000', 'SISTEMA', @CodUbic, 1, '.', '.', @UsoMat, @MontoDesc, @FechaHoy, @OperDesc)

         -- Crea items del descargo
         INSERT INTO SAITEMOPI (TipoOpi, NumeroD, NroLinea, CodItem, CodUbic, Descrip1, Signo, Cantidad, Costo, FechaE, EsServ)
            SELECT 'O', @NroDesc, X.NroLinea, X.CodItem, X.CodUbic, X.Descrip1, 0, X.Cantidad, X.Costo, @FechaHoy, X.EsServ
               FROM SAITEMFAC AS X
               INNER JOIN SAFACT AS Y
               ON X.TipoFac = Y.TipoFac AND X.NumeroD = Y.NumeroD
               WHERE (Y.TipoFac = @TipoDoc) AND (Y.CodOper = @CodOper) AND (Y.NumeroD = @NumeroD AND (X.EsServ = 0))

         -- 6. Actualiza existencia del producto para el deposito en cuestion. <<<<<<<<<<<<<<<<<
         -- 7. Actualiza existencia a nivel de producto. <<<<<<<<<<<<<<<<<
      END

      -- 8. Limpia rastro del documento en espera OR.
      DELETE FROM SAITEMFAC
         WHERE (TipoFac = @TipoDoc AND NumeroD = @OrdenReparacion)
      DELETE FROM SESA_VW_ORDENES_REPARACION
         WHERE (TipoFac = @TipoDoc AND NumeroD = @OrdenReparacion)
      DELETE FROM SAFACT
         WHERE (TipoFac = @TipoDoc AND NumeroD = @OrdenReparacion)

      FETCH NEXT FROM CURSOR_OR INTO @NumeroD, @FechaE, @Placa, @OrdenReparacion
   END
   CLOSE CURSOR_OR
   DEALLOCATE CURSOR_OR
END
