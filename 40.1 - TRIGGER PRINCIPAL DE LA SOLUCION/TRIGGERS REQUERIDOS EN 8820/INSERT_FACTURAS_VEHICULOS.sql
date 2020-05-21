      -- ********************************************************************************
-- NUEVO TRIGGER PARA PROCESAR ORDENES DE REPARCION DESDE SAFACT_02
-- Y COMPLEMENTA DATOS POR TRANSACIONES DE FACTURACION DE REPUESTOS Y VEHICULOS
-- CREADO POR: JOSE RAVELO MAY-2008 / MODIFICADO: NOVIEMBRE 2010 / MODIFICADO: JULIO 2011
-- MODIFICACION TEMPORAL EL 31/05/2012 SE AGREGA CONDICION PARA CERRAR OR INTERNAS Y GARANTIA 
-- SOLO A JACK SOLO EN PRESTIGE CARS EN LINEA 56,149,409 24/01/2013 SE AGREGA A DORIS EN LINEA 409
-- 13/03/2013 MODIFICACION PARA RORAIMA MOTORS INCORPORACION DE OR GARANTIAS IGUAL PROCESO A CONTADO.
-- LINEAS MODIFICADAS:253,409
-- OJO OJO PARA EL RESTO DE LOS CONCESIONARIOS DEBEN ELIMINARSE LAS MODIFICACIONES PARTICULARES PRESTIGE Y RORAIMA.
-- ********************************************************************************
DROP TRIGGER INSERT_FACTURAS_VEHICULOS
GO
CREATE TRIGGER INSERT_FACTURAS_VEHICULOS ON  SAITEMFAC

WITH ENCRYPTION
AFTER INSERT
AS
-----------------------------------
-- DECLARACION DE VARIABLES 
-----------------------------------

-- Contenido de campos de safact_01
DECLARE @TipoFac     varchar (1),
        @NumeroD     varchar (10),
        @Placa       varchar(10),
        @Kilometraje int,
        @liquidacion Varchar(15),
        @status Varchar(15),
        @cierre_Or datetime,
        @apertura_or datetime,
        @OR varchar(10)
 
-- Contenido de campos safact_02
DECLARE @Modelo varchar(15),
        @Color varchar(20),
        @Serial_M varchar(20),
        @Serial varchar(20),
        @Vendido datetime,
        @concesionario Varchar(35),
        @interno varchar(10)

-- Contenido de campos Safact
DECLARE @CODCLIE VARCHAR(10),
        @CODOPER VARCHAR(10),
        @DESCLIE VARCHAR(40),
        @CODVEND VARCHAR(10),
        @NOTAS1  VARCHAR(60),
        @NOTAS2  VARCHAR(60),
        @NOTAS3  VARCHAR(60),
        @NOTAS4  VARCHAR(60),
        @NOTAS5  VARCHAR(60),
        @NOTAS6  VARCHAR(60),
        @NOTAS7  VARCHAR(60),
        @NOTAS8  VARCHAR(60),
        @NOTAS9  VARCHAR(60),
        @NOTAS10 VARCHAR(60),
        @CODUSUA VARCHAR(60)
        
-- Contenido de saitemfac
DECLARE @CANTIDAD INT,
        @CODITEM  VARCHAR(20)        
               

-- Contenido de variables locales
DECLARE @STATUSERROR INT, -- SWICHE QUE SE ACTIVA
        @DESCRIPERROR VARCHAR(256), -- DESCRIBE EL MENSAJE DE ERROR
        @VEHICULO INT, -- DEFINE ACCION A TOMAR PARA EL REGISTRO DE VEHICULO
        @DescriModelo Varchar(40),
        @EsExento int,
        @CodInst varchar(10)
        
DECLARE @CODVEH varchar(10)
DECLARE @Deposito varchar(10)
DECLARE @CodTaxs varchar(5)
DECLARE @Tmp_Codigo varchar (15)
DECLARE @Tmp_Serial varchar (35)
DECLARE @Tmp_Color varchar (25)
DECLARE @MontoIVA decimal (23,2)
DECLARE @EsPorct smallint
DECLARE @FechaHoy Datetime
 

-------------------------------------------
-- VALORES INICIALES ASISGNADOS
-------------------------------------------

SET @FechaHoy = getdate()
SET @Deposito = '020'
SET @CodTaxs  = 'IVA'
SET @Modelo   = 'NO EXISTE'
SET @CodInst  = 12
SET @TIPOFAC  = ''

-- RECOGE DATOS INSERTED
SELECT @NUMEROD=NUMEROD, @TIPOFAC=TIPOFAC  FROM INSERTED


-----------------------------------------------------
--- RECOLECCION DE DATOS - (CORRECCION Y PREPARACION)
-----------------------------------------------------


-- Recoge datos de la tabla: SAFACT
          
   SELECT 
          @CODCLIE = CODCLIE,
          @CODOPER = CODOPER,
          @DESCLIE = DESCRIP,
          @CODVEND = CODVEND,
          @NOTAS1=NOTAS1,@NOTAS2=NOTAS2,@NOTAS3=NOTAS3,@NOTAS4=NOTAS4,@NOTAS5=NOTAS5,
          @NOTAS6=NOTAS6,@NOTAS7=NOTAS7,@NOTAS8=NOTAS8,@NOTAS9=NOTAS9,@NOTAS10=NOTAS10,
          @CODUSUA = CODUSUA  
          FROM SAFACT
          WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

------------------------------------------------------------------------------------------------------
-- IDENTIFICADORES CRUZADOS, MARCAS Y ACCIONES ESPECIALES GENERALES  (CASOS DE FACTURACION) 
------------------------------------------------------------------------------------------------------

-- Factura de vehiculo
IF @TIPOFAC='A' AND @CODOPER='01-101'

  BEGIN
   
   SELECT @PLACA=CODPROD, @MODELO=Z.MODELO, @COLOR=Z.COLOR, @FECHAHOY=X.FECHAE, @CONCESIONARIO=CONCESIONARIO, @SERIAL=Y.NROSERIAL
   FROM SAFACT X 
   INNER JOIN SASEPRFAC Y ON X.NUMEROD = Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC 
   INNER JOIN SAPROD_12_01 Z ON Y.NROSERIAL=Z.SERIAL 
   WHERE X.NUMEROD=@NUMEROD AND X.TIPOFAC=@TIPOFAC
   
   

   UPDATE SAFACT_01 SET PLACA=@PLACA, STATUS='VEHICULO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

   UPDATE SAPROD_12_01 SET FACTURA_VENTA = 'FA/'+@NUMEROD, FECHA_VENTA = @FECHAHOY         
   WHERE SERIAL=@SERIAL

   UPDATE SAFACT SET ORDENC='VEHICULO/' + @placa WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
   
   IF NOT EXISTS (SELECT PLACA FROM SACLIE_04 WHERE PLACA=@PLACA)
   INSERT SACLIE_04 (CODCLIE, FECTRN, PLACA, MODELO, SERIAL, COLOR, VENDIDO, CONCESIONARIO)
   VALUES (@CODCLIE, @FECHAHOY, @PLACA, @MODELO, @SERIAL, @COLOR, @FECHAHOY, @CONCESIONARIO)

  IF NOT EXISTS (SELECT CODPROD FROM SAPROD_12_02 WHERE CODPROD=@PLACA) 
  INSERT SAPROD_12_02 (CODPROD, FECTRN, CODCLIE, DESCRIPCION, CONDICION)
  VALUES (@PLACA, @FECHAHOY, @CODCLIE, @DESCLIE, 'TITULAR')

   DELETE FROM SAPROD_11_03 WHERE SERIAL=@SERIAL

   -- LA SIGUIENTE INSTRUCCION ES PARA CORREGIR FALLA DE LA APLICACION ORIGINAL QUE NO ELIMINA EL REGISTRO DE SASERI CUANDO FACTURA EN VERSION 873 Y 872
   DELETE FROM SASERI       WHERE NROSERIAL=@SERIAL

  END

--  Devolucion de Factura de venta de Vehiculo.
IF @TIPOFAC='B' AND @CODOPER='01-101'

  BEGIN

   SELECT @PLACA=CODPROD, @MODELO=Z.MODELO, @COLOR=Z.COLOR, @FECHAHOY=X.FECHAE, @CONCESIONARIO=CONCESIONARIO, @SERIAL=Y.NROSERIAL
   FROM SAFACT X 
   INNER JOIN SASEPRFAC Y ON X.NUMEROD = Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC 
   INNER JOIN SAPROD_12_01 Z ON Y.NROSERIAL=Z.SERIAL 
   WHERE X.NUMEROD=@NUMEROD AND X.TIPOFAC=@TIPOFAC

   UPDATE SAFACT_01 SET PLACA=@PLACA, STATUS='VEHICULO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

   UPDATE SAPROD_12_01 SET FACTURA_VENTA = 'NC/'+@NUMEROD, FECHA_VENTA = @FECHAHOY         
   WHERE SERIAL=@SERIAL

   UPDATE SAFACT SET ORDENC='VEHICULO/DV' + @placa WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
 
    -- Crea o actualiza registro en datos adicionales de existencia para optimizar consulta.
            IF NOT EXISTS (SELECT * FROM SAPROD_11_03 WHERE serial=@serial)
              INSERT dbo.SAPROD_11_03 (CodProd, fectrn, Serial, Placa, Color, Status)     
              VALUES (@modelo, getDate(), @serial, @placa, @Color, 'DISPONIBLE')
            ELSE
              UPDATE SAPROD_11_03 
                 SET Codprod=@modelo,
                     fectrn=getdate(),
                     Serial=@serial,
                     Placa=@Placa,
                     Color=@Color,
                     Status='DISPONIBLE'
                 WHERE SERIAL=@SERIAL  

   END

 