-- ******************************************************************************************
-- ACTUALIZA CAMPO DE COMPROMETIDO EN SAPROD EN FUNCION A SAFACT (E) PEDIDOS SOBRE ORDENES (G) 
-- LIQ:PUBLICAS(CONTADO) STATUS: PENDIENTES REALIDAS EN EL A;O 2011
-- ORIGINAL DISE;ADO EL 06/07/2011 POR: JOSE RAVELO
--*************************************************************************************

USE LIBERTYCARSANUALDB

DROP PROCEDURE SESA_SP_CORRIGE_COMPROMETIDOS
GO 

CREATE PROCEDURE SESA_SP_CORRIGE_COMPROMETIDOS

 
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
        
  -- LIMPIA CAMPO COMPROMETIDOS EN SAFACT CON VALOR CERO
  
       UPDATE SAPROD SET Compro = 0 
     
        
  -- Procesa cada repuesto para todos los pedidos relacionados con la OR
       DECLARE MIREG CURSOR FOR
       
       SELECT DISTINCT Z.CODITEM 
       FROM  SAFACT_03 AS X INNER JOIN
             SAFACT_01 AS Y ON X.Nro_OR = Y.NumeroD AND Y.TipoFac = 'G' INNER JOIN
             SAITEMFAC AS Z ON X.TipoFac = Z.TipoFac AND X.NumeroD = Z.NumeroD INNER JOIN
             SAFACT AS W ON W.NumeroD = X.NumeroD AND W.TipoFac = X.TipoFac
       WHERE     (X.TipoFac = 'E') AND (Y.Status = 'PENDIENTE') AND (YEAR(W.FechaE)='2011')
       ORDER BY Z.CodItem
       
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @CodItem
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
 
         -- Determina la cantidad del repuesto entregado
         SELECT @Cantidad = SUM(Z.Cantidad)
         FROM  SAFACT_03 AS X INNER JOIN
               SAFACT_01 AS Y ON X.Nro_OR = Y.NumeroD AND Y.TipoFac = 'G' INNER JOIN
               SAITEMFAC AS Z ON X.TipoFac = Z.TipoFac AND X.NumeroD = Z.NumeroD INNER JOIN
               SAFACT AS W ON W.NumeroD = X.NumeroD AND W.TipoFac = X.TipoFac
         WHERE (X.TipoFac = 'E') AND (Y.Status = 'PENDIENTE') AND (YEAR(W.FechaE)='2011') AND Z.CodItem=@CodItem
      
          -- Actualiza la cantidad comprometida del repuesto en la tabla saprod
            UPDATE SAPROD SET COMPRO=@CANTIDAD WHERE CODPROD=@CodItem



         FETCH NEXT FROM MIREG INTO @CodItem
      END
      CLOSE MIREG
      DEALLOCATE MIREG
     
 

    


