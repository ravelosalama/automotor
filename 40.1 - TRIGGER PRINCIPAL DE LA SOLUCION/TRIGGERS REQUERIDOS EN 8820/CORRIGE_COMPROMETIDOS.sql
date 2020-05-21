-- CREADO DIC2013 POR JOSE RAVELO SOBRE VERSION 8820 DEL 14022013
-- DESARROLLADO PARA CORREGIR FALLA DE VERSION EN ACTUALIZACION DE NROS DE DOC CRUZADOS DEVOLUCIONS Y FACTURAS
-- CORREGIR DESCONTAR COMPROMETIDOS AL FACTURAR SERVICIOS Y SUMAR COMPROMETIDOS AL REVERSAR FACTURAS DE SERVICIOS
-- CREAR REGISTROS EN SAACXC Y SAPAGCXC DE NC PROVENIENTES DE DEVOLUCIONES A CREDITOS DE FORMA AUTOMATICA PARA TODOS LOS TIPOS CODOPER
-- DESBLOQUEA FACTURA CON DEVOLUCIONES PARCIALES.


-- SE SUSTITUYE EL SIGUIENTE TRIGGER 
if exists (select * from dbo.sysobjects where id = object_id(N'[TG_ADM_NC_X_DEVVTA_CREDITO]'))
drop TRIGGER TG_ADM_NC_X_DEVVTA_CREDITO 
GO



DROP TRIGGER CORRIGE_COMPROMETIDOS
GO
CREATE TRIGGER CORRIGE_COMPROMETIDOS ON SAITEMFAC 
-- WITH ENCRYPTION
AFTER INSERT
AS
-----------------------------------
-- DECLARACION DE VARIABLES 
-----------------------------------

-- Contenido de campos de saitemfac / inserted
DECLARE  
        @Coditem     varchar (20),
        @Cantidad    int,
        @Esserv      int,
        @ONumero     varchar (10),
        @OTipo       varchar (1)
          
-- CONTENIDO DE CAMPOS DE SAFACT          
DECLARE @CODCLIE VARCHAR(15)
DECLARE @FECHAE DATETIME
DECLARE @FECHAT DATETIME
DECLARE @FECHAV DATETIME
DECLARE @FECHAI DATETIME
DECLARE @FECHAO DATETIME
DECLARE @NUMEROD VARCHAR(20)
--DECLARE @NUMERON VARCHAR(20)
DECLARE @DOCUMENT VARCHAR(25)
DECLARE @MONTO DECIMAL(23,2)
DECLARE @MTOTAX DECIMAL (23,2)
DECLARE @BASEIMPO DECIMAL (23,2)
DECLARE @TEXENTO DECIMAL (23,2)

DECLARE @CREDITO DECIMAL (23,2),
        @CONTADO DECIMAL (23,2),
        @TOTFACAFE DECIMAL (23,2),
        @TOTDEVOLS DECIMAL (23,2)

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
        
-- LEE REGISTRO INSERTED        
        
 select @tipofac=tipofac, 
        @numerod=numerod, 
        @CANTIDAD=CANTIDAD,
        @ESSERV=esserv, 
        @Coditem=Coditem,
        @ONumero=Onumero, 
        @Otipo=Otipo from inserted
 
-- LEE REGISTRO SAFACT SEGUN DATOS DE INSERTED 
 
SELECT  @CODCLIE=CODCLIE,
        @FECHAE=GETDATE(),
        @FECHAT=GETDATE(),
        @FECHAV=GETDATE(),
        @FECHAI=GETDATE(),
        
        @DOCUMENT='DEV.'+@NUMEROD+'/ F.AFEC:'+@ONUMERO,
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
        @CREDITO=CREDITO,
        @CONTADO=CONTADO,
        @MONTONETO=TEXENTO+TGRAVABLE
        

FROM SAFACT where numerod=@numerod and tipofac=@tipofac  

 
   -- Descuenta CANTIDAD A COMPROMETIDOS POR CADA repuestos facturado EN OR / CONTADO
   -- (ESTO ES UNA CORRECCION A FALLA DE SAINT)
 
-- Factura de servicios  
        
    IF @TIPOFAC='A' AND @CODOPER='01-301' AND @ESSERV=0
    
       UPDATE SAPROD SET COMPRO=COMPRO-@CANTIDAD where Codprod=@Coditem 
     
-------------------
    
    
-- Devolucion Factura  

 
  IF @TIPOFAC='B'
     BEGIN
     -- ACTUALIZACION CRUZADA FACTURA/DEVOLUCION 
     UPDATE SAFACT SET NUMEROR=@Onumero WHERE numerod=@numerod and tipofac=@tipofac    -- actualiza registro de la DEVOLUCION    
     UPDATE SAFACT SET NUMEROR=@numerod WHERE numerod=@Onumero and tipofac=@Otipo       -- actualiza registro de factura afectada
 
 
     IF @CODOPER='01-301' -- devolucion factura servicio.
  
        UPDATE SAPROD SET COMPRO=COMPRO+@CANTIDAD where Codprod=@Coditem
     
   
     END
     
    



IF @TIPOFAC='B' AND @CREDITO>0 AND NOT EXISTS (SELECT DOCUMENT FROM SAACXC WHERE TIPOCXC='31' AND NUMEROD=@NUMEROD AND CODCLIE=@CODCLIE)

     BEGIN
 
          -- SEGMENTO QUE GENERA LOS REGISTROS DE NOTAS DE CREDITO Y PAGOS CUANDO SE PRODUCE UNA DEVOLUCION A CREDITO
 
          INSERT INTO SAACXC  (CODCLIE, FECHAE, FECHAV, CODSUCU, CODESTA, CODUSUA, CODOPER, CODVEND, NUMEROD, NROCTROL, FROMTRAN,
                               TIPOCXC, DOCUMENT, MONTO, MONTONETO, MTOTAX, ESLIBROI, BASEIMPO, AFECTAVTA, AFECTACOMI, FECHAI,
                               NUMERON, TEXENTO, FECHAT )
 
          SELECT               @CODCLIE, @FECHAE, @FECHAE, @CODSUCU, @CODESTA, @CODUSUA, @CODOPER, @CODVEND, @NUMEROD, @NUMEROD, 0,
                               '31', @DOCUMENT, @MONTO, @MONTONETO, @MTOTAX, 1, @BASEIMPO, 1, 1, @FECHAE, 
                               @ONUMERO, @TEXENTO, @FECHAE
   
      
          SELECT @NROREGI=NROUNICO, @FECHAO=FECHAE FROM SAACXC WHERE NUMEROD=@ONUMERO AND TIPOCXC='10'AND CODCLIE=@CODCLIE
          SELECT @NROUNICO=NROUNICO FROM SAACXC WHERE NUMEROD=@NUMEROD AND TIPOCXC='31' AND CODCLIE=@CODCLIE

    
          INSERT INTO SAPAGCXC  (NROPPAL, NROREGI,TIPOCXC,MONTODOCA,MONTO,NUMEROD,DESCRIP,FECHAE,FECHAO,BASEIMPO,MTOTAX,TEXENTO)
          SELECT @NROUNICO, @NROREGI,'10', @MONTO, @MONTO,@ONUMERO,@DOCUMENT, @FECHAE,@FECHAO, @BASEIMPO, @MTOTAX, @TEXENTO
        
         -- SEGMENTO QUE ACTUALIZA EL SALDO DE FACTURAS EN CXC EN BASE A LA NOTA DE CREDITO PRODUCTO DE LA DEVOLUCION
        
          UPDATE SAACXC
          SET SALDO = SALDO - @MONTO
          WHERE  NUMEROD=@ONUMERO AND TIPOCXC='10' AND CODCLIE=@CODCLIE


 
          -- SEGMENTO QUE DESBLOQUEA FACTURA QUE NO HAYA SIDO DEVUELTA N SU TOTALIDAD PARA QUE SIGA QUEDANDO DISPONIBLE.
 
          SELECT @TOTDEVOLS=SUM(MONTO+MTOTAX) FROM SAFACT WHERE TIPOFAC='B' AND NUMEROR=@ONUMERO
          SELECT @TOTFACAFE=CREDITO+CONTADO FROM SAFACT WHERE NUMEROD=@ONUMERO AND TIPOFAC='A'
         
          IF @TOTDEVOLS<@TOTFACAFE
          
            UPDATE SAFACT SET NUMEROR='' WHERE NUMEROD=@ONUMERO AND TIPOFAC='A'
            
     END
 


     