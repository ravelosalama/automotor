-- ********************************************************************************
-- TRIGGER PARA PROCESAR MODIFICACION DE SERIALES 
-- ********************************************************************************
-- ***************** JOSE RAVELO NOV-2007 *****************************************
DROP TRIGGER MODIFICA_SERIALES_DE_VEHICULOS
GO

CREATE TRIGGER [MODIFICA_SERIALES_DE_VEHICULOS] ON [dbo].[SAPROD_11_02] 
WITH ENCRYPTION
FOR INSERT, UPDATE 
AS

DECLARE @CODPROD VARCHAR(15)
DECLARE @USUARIO VARCHAR(35)
DECLARE @SERIALOLD VARCHAR(20)
DECLARE @SERIALNEW VARCHAR(20)
DECLARE @RESULTADO VARCHAR(35)
DECLARE @PLACA VARCHAR(15)
DECLARE @NROUNICO INT 

BEGIN
SELECT @NROUNICO=NROUNICO, @CODPROD=CODPROD, @USUARIO=USUARIO, @SERIALOLD=Serial_viejo, @SERIALNEW=Serial_nuevo FROM INSERTED

IF EXISTS (SELECT * FROM SASERI WHERE (NROSERIAL=@SERIALOLD))
   BEGIN
      -- SELECT @PLACA = CODPROD FROM SAPROD_12_01 WHERE SERIAL=@SERIALOLD
      
      UPDATE SAPROD_12_01 SET SERIAL=@SERIALNEW WHERE SERIAL=@SERIALOLD
      UPDATE SASERI SET NROSERIAL=@SERIALNEW WHERE NROSERIAL=@SERIALOLD
      UPDATE SASEPRCOM SET NROSERIAL=@SERIALNEW WHERE NROSERIAL=@SERIALOLD

      SET @RESULTADO = 'MODIFICACION SATISFACTORIA'
       

   END
   ELSE
   BEGIN
      SET @RESULTADO = 'SERIAL A MODIFICAR NO EXISTE EN BD'
   END 

UPDATE SAPROD_11_02 SET RESULTADO=@RESULTADO WHERE NROUNICO=@NROUNICO
END




 