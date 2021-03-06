 
-- Verify that the stored procedure does not exist.
IF OBJECT_ID ('validaR_rif', 'tr') IS NOT NULL
    DROP trigger validaR_rif;
GO
CREATE TRIGGER [VALIDAR_RIF] ON SACLIE
--WITH ENCRYPTION
FOR INSERT
AS


BEGIN

DECLARE @CODCLIE VARCHAR(15)
DECLARE @STATUSERROR INT
DECLARE @DESCRIPERROR VARCHAR(100)
DECLARE @ID3 VARCHAR(15)
DECLARE @MODULO VARCHAR(25)
DECLARE @SUBMODULO VARCHAR(25)
DECLARE @OPERACION VARCHAR(25)
DECLARE @USUARIO VARCHAR(25)
DECLARE @FECHA DATETIME
DECLARE @CODIGO VARCHAR(20)
DECLARE @TIPO VARCHAR (1)
DECLARE @NUMEROD VARCHAR(20)
DECLARE @NUMEROR VARCHAR(20)
DECLARE @EMISION DATETIME
DECLARE @ACCION VARCHAR(100)
DECLARE @NIVEL VARCHAR (25)
DECLARE @COMANDO VARCHAR(150)
DECLARE @CODESTA VARCHAR(20)
DECLARE @COD_ID VARCHAR(20)




SET @STATUSERROR=0
SET @FECHA = GETDATE()
SET @MODULO = 'ADMINISTRATIVO'
SET @SUBMODULO ='ARCHIVO'
SET @NIVEL ='CLIENTE'
SET @OPERACION ='INSERTAR'
SET @USUARIO = '001'
SET @CODESTA=HOST_NAME()
SET @COD_ID=HOST_ID()         
 
SELECT @CODCLIE=UPPER(CODCLIE) , @ID3=ID3 FROM INSERTED

SET @CODIGO=@CODCLIE 

IF @CODCLIE LIKE '%-%' OR @CODCLIE LIKE '%.%' OR @CODCLIE LIKE '%/%' OR @CODCLIE LIKE '% %' OR @CODCLIE LIKE '%,%'
   BEGIN
   SET @STATUSERROR=1
   SET @DESCRIPERROR= 'ATENCION: No debe utilizar ningun caracter especial en este campo CODIGO. INTENTE DE NUEVO'
   END
   
IF SUBSTRING(@CODCLIE,1,1)<>'V' AND SUBSTRING(@CODCLIE,1,1)<>'E' AND SUBSTRING(@CODCLIE,1,1)<>'J' AND SUBSTRING(@CODCLIE,1,1)<>'G' AND SUBSTRING(@CODCLIE,1,1)<>'P'
      BEGIN
      SET @STATUSERROR=2
      SET @DESCRIPERROR='ATENCION: Utilice las letras: V - venezolana, J - juridica, E - entranjero, G - gobierno, P - PASAPORTE en el primer digito del CODIGO. Ejemplo: V99999999.'  
      END

IF @ID3<>@CODCLIE  
         BEGIN
         SET @STATUSERROR=3
         SET @DESCRIPERROR='ATENCION: EL CAMPO DE ID.Fiscal debe ser igual al CODIGO indicado. INTENTE DE NUEVO'  
         END
     
       
    IF @STATUSERROR<>0
             BEGIN 
                    DELETE FROM SACLIE WHERE CODCLIE=@CODCLIE OR ID3=@ID3
                    DELETE FROM DBTHIRD WHERE (ID3Org=@id3 or ID_Alte=@codclie) and TipoID3=2 
                    DELETE FROM SAICLI WHERE CODCLIE=@CODCLIE
                   --SET @ACCION='ELIMINAR EL REGISTRO' 
                   --INSERT INTO Control_TRAZA
                   -- (MODULO,SUBMODULO,OPERACION,USUARIO,FECHA,CODIGO,TIPO,NUMEROD,NUMEROR,EMISION,DESCRIPERROR,CODERROR,ACCION)
                   --     VALUES(@MODULO,@SUBMODULO,@OPERACION,@USUARIO,@FECHA,@CODIGO,@TIPO,@NUMEROD,@NUMEROR,@EMISION,@DESCRIPERROR,@STATUSERROR,@ACCION)
                    SET @COMANDO='NET SEND '+@CODESTA+' ADVERTENCIA: '+@COD_ID+' '+@DESCRIPERROR
                    EXEC xp_cmdshell @COMANDO, NO_OUTPUT
                    RAISERROR (@DESCRIPERROR,16,1)
                    ROLLBACK TRANSACTION
                    RETURN 
              END 
       
 END   
 
 
 
   
       
 
  
    



 
 

 