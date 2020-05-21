
if exists (select * from dbo.sysobjects where id = object_id(N'[CONCESIONARIOS_TG_ESPERA_OR]'))
drop TRIGGER CONCESIONARIOS_TG_ESPERA_OR  
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[INSERT_ORDEN]'))
drop TRIGGER INSERT_ORDEN  
GO

-- ********************************************************************************
-- NUEVO TRIGGER PARA 9020 CREADO POR: JOSE RAVELO MAR-2016 
-- DETECTA TRANSACCIÓN EN SACOMP, RECOGE DATOS DEL MISMO E INSERTA EN:
-- TRANSACCIONES CONCESIONARIOS.
-- ********************************************************************************
DROP TRIGGER TG_05_INSERTA_TRANSACCION
GO

CREATE TRIGGER TG_05_INSERTA_TRANSACCION ON SACOMP
-- WITH ENCRYPTION
AFTER INSERT, UPDATE
AS
-----------------------------------
-- DECLARACION DE VARIABLES 
-----------------------------------
DECLARE @STATUSERROR INT,
        @DESCRIPERROR VARCHAR(100)
    
-- Contenido de campos de saCOMP
DECLARE @TipoDOC     varchar (1),
        @NumeroD     varchar (20),
        @NROUNICO    INT
   
DECLARE @CODTERCERO VARCHAR(15),
        @CODOPER VARCHAR(10),
        @CODUSUA VARCHAR (10),
        @CODESTA VARCHAR (10),
        @FECHAT DATETIME
        
-----------------------------------------------------
--- RECOLECCION DE DATOS - (CORRECCION Y PREPARACION)
-----------------------------------------------------

-- Recoge datos de la tabla: INSERTED
   SELECT @TIPODOC=TIPOcom,
          @NUMEROD=NUMEROD,
          @Nrounico=nrounico,
          @CodTERCERO=Codprov,
          @Codoper=Codoper,
          @Codusua=Codusua,
          @Codesta=Codesta,
          @Fechat=Fechat 
   FROM INSERTED
   
-- VALIDA Y/O CORRIGE DATOS EJEMPLO: CODPROV O USUARIO RESTRIGIDO

IF   @CODOPER <> '05-101' AND @CODOPER <> '05-201' AND @CODOPER<> '05-301' AND @CODOPER <> '05-401' AND @CODOPER<> '05-501' AND @CODOPER <> '05-601' AND @CODOPER<> '05-310'
        BEGIN
         SET @STATUSERROR=1
         SELECT @DESCRIPERROR=DESCRIPCION FROM SAERROR WHERE CODERR='05001'            
        END 
        
-- VERIFICA SI SE ACTIVO ALGUN SWICH DE VALIDACION, MUESTRA ADVERTENCIA Y REVERSA TRANSACCION

   IF @STATUSERROR=1
   BEGIN
      RAISERROR (@DESCRIPERROR,16,1)
      ROLLBACK TRANSACTION
      RETURN
   END

-- SI LA TRANSAACIÓN ES VALIDA GRABA DATOS EN TABLA TRANSACCIONAL
    
   INSERT SATRANSAC (TipoDOC,NumeroD,NROUNICO,CODTERCERO,CODOPER,CODUSUA,CODESTA,FECHAT)
   VALUES  (@TipoDOC,@NumeroD,@NROUNICO,@CODTERCERO,@CODOPER,@CODUSUA,@CODESTA,@FECHAT)




