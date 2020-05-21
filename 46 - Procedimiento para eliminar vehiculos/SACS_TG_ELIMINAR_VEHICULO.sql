DROP TRIGGER SACS_TG_ELIMINAR_VEHICULO

GO
 
CREATE TRIGGER SACS_TG_ELIMINAR_VEHICULO ON SAEXIS
WITH ENCRYPTION
FOR DELETE 
AS

-----------------------------------
-- DECLARACION DE VARIABLES 
-----------------------------------

-- Contenido de campos de safact
DECLARE @CODINST     varchar (2),
        @CODPROD     varchar (15)
      
SELECT @CODPROD=CODPROD  FROM DELETED 

EXECUTE dbo.SACS_SP_ELIMINA_VEHICULO   @CODPROD



  
