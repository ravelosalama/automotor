--- TRIGGER QUE GENERAL EL REGISTRO DE NOTA DE CREDITO EN CXC POR DEVOLUCION 
--- DE FACTURA A CREDITO MANTENIENDO LA CUENTA LIMPIA 
--- ELABORADO POR: JOSE RAVELO JUNIO 2009


DROP TRIGGER  [TG_ADM_NC_X_DEVVTA_CREDITO] 
GO

CREATE TRIGGER [TG_ADM_NC_X_DEVVTA_CREDITO] ON [dbo].[SAFACT] 
FOR INSERT  
AS


DECLARE @CODCLIE VARCHAR(15)
DECLARE @FECHAE DATETIME
DECLARE @FECHAT DATETIME
DECLARE @FECHAV DATETIME
DECLARE @FECHAI DATETIME
DECLARE @FECHAO DATETIME
DECLARE @NUMEROD VARCHAR(20)
DECLARE @NUMERON VARCHAR(20)
DECLARE @DOCUMENT VARCHAR(25)
DECLARE @MONTO DECIMAL(23,2)
DECLARE @MTOTAX DECIMAL (23,2)
DECLARE @BASEIMPO DECIMAL (23,2)
DECLARE @TEXENTO DECIMAL (23,2)
DECLARE @CREDITO DECIMAL (23,2)
DECLARE @MONTONETO DECIMAL (23,2)
DECLARE @NROUNICO INT
DECLARE @NROUNI10 INT
DECLARE @NROREGI INT
DECLARE @CODOPER VARCHAR(10)
DECLARE @TIPOCXC VARCHAR(2)
DECLARE @ESLIBRO INT
DECLARE @AFECTAVTA INT
DECLARE @AFECTACOMO INT
DECLARE @CODSUCU VARCHAR(10)
DECLARE @CODESTA VARCHAR(15)
DECLARE @CODUSUA VARCHAR(15)
DECLARE @CODVEND VARCHAR(15)
DECLARE @NROCTROL VARCHAR(10)
DECLARE @FROMTRAN INT
DECLARE @TIPOFAC VARCHAR(1)

SELECT  @CODCLIE=CODCLIE,
        @FECHAE=GETDATE(),
        @FECHAT=GETDATE(),
        @FECHAV=GETDATE(),
        @FECHAI=GETDATE(),
        @NUMEROD=NUMEROD,
        @NUMERON=NUMEROR,
        @DOCUMENT='DEV.'+@NUMEROD+'/ F.AFEC:'+@NUMERON,
        @MONTO=MTOTOTAL,
        @MTOTAX=MTOTAX,
        @BASEIMPO=TGRAVABLE,
        @TEXENTO=TEXENTO,
        @CODOPER=CODOPER,
        @CODSUCU=CODSUCU,
        @CODESTA=CODESTA,
        @CODUSUA=CODUSUA,
        @CODVEND=CODVEND,
        @NROCTROL=NROCTROL,
        @TIPOFAC=TIPOFAC,
        @CREDITO=CREDITO,
        @MONTONETO=TEXENTO+TGRAVABLE
        

FROM INSERTED

SELECT @NROREGI=NROUNICO, @FECHAO=FECHAE FROM SAACXC WHERE NUMEROD=@NUMERON AND TIPOCXC='10'AND CODCLIE=@CODCLIE

IF @TIPOFAC='B' AND @CREDITO>0

     BEGIN
 
          INSERT INTO SAACXC  (CODCLIE, FECHAE, FECHAV, CODSUCU, CODESTA, CODUSUA, CODOPER, CODVEND, NUMEROD, NROCTROL, FROMTRAN,
                               TIPOCXC, DOCUMENT, MONTO, MONTONETO, MTOTAX, ESLIBROI, BASEIMPO, AFECTAVTA, AFECTACOMI, FECHAI,
                               NUMERON, TEXENTO, FECHAT )
 
          SELECT               @CODCLIE, @FECHAE, @FECHAE, @CODSUCU, @CODESTA, @CODUSUA, @CODOPER, @CODVEND, @NUMEROD, @NUMEROD, 0,
                               '31', @DOCUMENT, @MONTO, @MONTONETO, @MTOTAX, 1, @BASEIMPO, 1, 1, @FECHAE, 
                               @NUMERON, @TEXENTO, @FECHAE
   


          UPDATE SAACXC
          SET SALDO = SALDO - @MONTO
          WHERE  NUMEROD=@NUMERON AND TIPOCXC='10' AND CODCLIE=@CODCLIE




          SELECT @NROUNICO=NROUNICO FROM SAACXC WHERE NUMEROD=@NUMEROD AND TIPOCXC='31' AND CODCLIE=@CODCLIE

          INSERT INTO SAPAGCXC  (NROPPAL, NROREGI,TIPOCXC,MONTODOCA,MONTO,NUMEROD,DESCRIP,FECHAE,FECHAO,BASEIMPO,MTOTAX,TEXENTO)
 
          SELECT @NROUNICO, @NROREGI,'10', @MONTO, @MONTO,@NUMERON,@DOCUMENT, @FECHAE,@FECHAO, @BASEIMPO, @MTOTAX, @TEXENTO
               




     END    
 
