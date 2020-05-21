----------------------------------------------------------------------------------
-- Ejemplo Trigger que genera ventanas de mensaje durante la ejecución de Saint --
-- Sirve para hacer validaciones al ingresar campos, entre otros                --
-- ejecuta este este query para grabar el trigger                               -- 
-- Inicia el modulo administrativo e ingresa un cliente cuyo codigo sea SAINT   --
--                                                                              -- 
--                                                                              --
-- Miguel Sagués - G.R.M. Soluciones, C.A.                                      --
-- msagues@grm.net.ve                                                           --
--                                                                              --
-- Por favor conserva este encabezado cuando distribuyas este ejemplo a otros   --
----------------------------------------------------------------------------------

CREATE TRIGGER VALIDA_CODCLIE
ON SACLIE
FOR INSERT
AS

BEGIN
   DECLARE
   @CODCLIE VARCHAR(10)
   
   SELECT
   @CODCLIE = CODCLIE
   FROM INSERTED

   IF @CODCLIE = 'SAINT'
   BEGIN
      RAISERROR ('Disculpe, la palabra SAINT no se puede usar como codigo de cliente',16,1)
      ROLLBACK TRANSACTION
      -- RETURN
   END
END



