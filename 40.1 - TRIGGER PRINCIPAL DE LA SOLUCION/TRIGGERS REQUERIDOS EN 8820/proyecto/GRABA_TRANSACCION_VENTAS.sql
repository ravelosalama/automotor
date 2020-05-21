-- en construccion 
-- debe activarse en la ultima actualizacion de insercion o update de safact y que verifique que todos los registros de tablas
-- esten creados y llenos solo cuando esto ultimo se de se ejecuta el cuerpo del trigger que debera ser el query general completo.
--
--


DROP TRIGGER GRABA_TRANSACCION_VENTAS
GO
CREATE TRIGGER GRABA_TRANSACCION_VENTAS ON SAFACT
-- WITH ENCRYPTION
AFTER INSERT,UPDATE
AS
-----------------------------------
-- DECLARACION DE VARIABLES 
-----------------------------------

-- Contenido de campos de safact / inserted
DECLARE @TipoFac     varchar (1),
        @OTipo       varchar (1),
        @NumeroD     varchar (10),
        @ONumero     varchar (10),
        @Codoper     varchar (10),
        @Coditem     varchar (20),
        @Cantidad    int
        
        
 select @tipofac=tipofac, @numerod=numerod,@codoper=codoper from inserted     
        
 select  @ONUMERO=ONUMERO from saitemfac where numerod=@numerod and tipofac=@tipofac 
        
 
 IF NOT EXISTS(SELECT NUMEROD FROM SATRANS WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC)
 
    INSERT INTO SATRANS ( NUMEROD,  TIPOFAC,  CODOPER,  NUMERODO,  TIPOFACO)
    VALUE               (
 
 