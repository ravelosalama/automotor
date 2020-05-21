-- *********************************************************************************************************
--  elaborado por JOSE RAVELO / aGOSTO 2008 PARA SEAT MARACAIBO POR NVD SYSTEMAS
--
-- *********************************************************************************************************

DROP TRIGGER SESA_TG_ASEGURADORA
GO

CREATE  TRIGGER SESA_TG_ASEGURADORA ON SAITEMFAC
WITH ENCRYPTION
AFTER INSERT, UPDATE
AS
 
DECLARE @TipoFAC varchar (1),
        @NumeroD varchar (15),
        @CodOper varchar (10),
        @Ordenase Varchar(35),
        @Vale Varchar(10),
        @liquidacion Varchar(15),
        @status Varchar(15),
        @Codclie Varchar(10),
        @Codase Varchar(15),
        @Fechaase datetime,
        @MODELO VARCHAR(20),
        @PLACA VARCHAR(10),
        @SERIAL VARCHAR(20),
        @COLOR VARCHAR (20),
        @CONCESIONARIO VARCHAR(35),
        @codbene VARCHAR(15),
        @Poliza VARCHAR(20),
        @Siniestro VARCHAR(20)


         

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
        @Statuserror Varchar(1)

   -- RECOGE DATOS DEL INSERT
   SELECT @TIPOFAC=TIPOFAC,
         @NUMEROD=NUMEROD,
         @CODITEM=CODITEM
   FROM  INSERTED

   -- RECOGE DATOS DEL VEHICULO EN SAFACT_01 Y SAFACT_02
   SELECT @MODELO=X.MODELO,
         @PLACA=Y.PLACA,
         @SERIAL=X.SERIAL,
         @CONCESIONARIO=X.VENDIO_CONCESIONARIO,
         @COLOR=X.COLOR
   FROM SAFACT_02 X INNER JOIN SAFACT_01 Y ON X.NUMEROD=Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC
   WHERE X.NUMEROD=@NUMEROD AND X.TIPOFAC=@TIPOFAC
  
   -- RECOGE DATOS DE TABLA SAFACT_04
   SELECT @Ordenase = orden_de_reparacion,
          @CodAse=codigo_aseguradora,
          @FECHAASE=EMISION_DE_LA_ORDEN,
          @Codbene=codigo_beneficiario,
          @Poliza=poliza,
          @Siniestro=siniestro
    
   FROM SAFACT_04 WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

   -- RECOGE DATOS DE item de la orden de reparacion
   SELECT @CodOper = CodOper,
          @CODCLIE=CodClie  FROM SAFACT 
      WHERE (TipoFac = @TipoFac AND NumeroD = @NumeroD)

IF @CODITEM ='S1000' OR @CODITEM='S2000' -- ES una Orden con servicios de latonera y pintura autorizada por aseguradora
  BEGIN
      IF LEN(@ORDENASE)<>0 AND LEN(@CODASE)<>0 and LEN(@FECHAASE)<>0 AND LEN(@CODBENE)<>0 AND LEN(@POLIZA)<>0 AND LEN(@SINIESTRO)<>0 
         IF EXISTS (SELECT * FROM SACLIE WHERE CODCLIE=@CODASE) AND EXISTS (SELECT * FROM SACLIE WHERE CODCLIE=@CODBENE)
           BEGIN
             SET @statuserror='0'
             SET @RESULTADO=''
             IF NOT EXISTS (SELECT * FROM SACLIE_04 WHERE CONCESIONARIO=@ORDENASE AND PLACA=@PLACA)
               INSERT SACLIE_04 (CodCLIE, FECTRN, PLACA, MODELO, SERIAL, COLOR, VENDIDO, CONCESIONARIO) 
               VALUES (@CODASE, GETDATE(), @Placa, @Modelo, @SERIAL, @COLOR, @FECHAASE, @ORDENASE)
           END
         ELSE
            BEGIN 
             SET @STATUSERROR='1'
             SET @RESULTADO='EL CODIGO DE ASEGURADORA O DE BENEFICIARIO INDICADO NO EXISTE EN BASE DE DATOS REVISE E INTENTE DE NUEVO'
            END
      ELSE 
         BEGIN
         SET @statuserror='1'
         SET @RESULTADO='<< FALTAN DATOS DE ASEGURADORA, DEBE COMPLETAR LOS DATOS SOLICITADOS >>'
        END
  END
      
 
-- MUESTRA PANTALLA CON RESULTADO DE VALIDACIONES SI LAS HAY.

   IF @statuserror=1
   BEGIN
      RAISERROR (@RESULTADO,16,1)
      ROLLBACK TRANSACTION
      RETURN
   END
  
 


