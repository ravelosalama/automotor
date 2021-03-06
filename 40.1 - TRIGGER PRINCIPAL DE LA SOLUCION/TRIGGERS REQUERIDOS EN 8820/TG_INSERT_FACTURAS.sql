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
DROP TRIGGER INSERT_FACTURAS
GO
CREATE TRIGGER INSERT_FACTURAS ON SATAXVTA
-- WITH ENCRYPTION
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
SELECT @NUMEROD=NUMEROD, @TIPOFAC=TIPOFAC FROM INSERTED
 

-----------------------------------------------------
--- RECOLECCION DE DATOS - (CORRECCION Y PREPARACION)
-----------------------------------------------------
 
-- Recoge datos de la tabla: SAFACT
   SELECT @CODCLIE = CODCLIE,
          @CODOPER = CODOPER,
          @DESCLIE = DESCRIP,
          @CODVEND = CODVEND,
          @NOTAS1=NOTAS1,@NOTAS2=NOTAS2,@NOTAS3=NOTAS3,@NOTAS4=NOTAS4,@NOTAS5=NOTAS5,
          @NOTAS6=NOTAS6,@NOTAS7=NOTAS7,@NOTAS8=NOTAS8,@NOTAS9=NOTAS9,@NOTAS10=NOTAS10,
          @CODUSUA = CODUSUA  
          FROM SAFACT
          WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
          
-- 
    SELECT @INTERNO=Z_INTERNO FROM SAFACT_02
    WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC        
          
          

------------------------------------------------------------------------------------------------------
-- IDENTIFICADORES CRUZADOS, MARCAS Y ACCIONES ESPECIALES GENERALES  (CASOS DE FACTURACION) 
------------------------------------------------------------------------------------------------------
 
 
 
 
-- Factura de repuesto.
IF @TIPOFAC='A' AND @CODOPER='01-201'
  BEGIN
   UPDATE SAFACT_01 SET STATUS='REPUESTO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
   UPDATE SAFACT SET ORDENC='REPUESTO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
  END



-- Factura de servicio.
IF @TIPOFAC='A' AND @CODOPER='01-301'

  BEGIN
  
    UPDATE SAFACT_01 SET STATUS=Y.Z_INTERNO 
   FROM SAFACT_01 X INNER JOIN SAFACT_02 Y 
   ON X.NUMEROD=Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC
   WHERE X.NUMEROD=@NUMEROD AND X.TIPOFAC=@TIPOFAC  

   UPDATE SAFACT_01 SET STATUS=@NUMEROD, CIERRE_OR=@FECHAHOY 
   FROM SAFACT_01 X INNER JOIN SAFACT_02 Y 
   ON X.NUMEROD=Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC
   WHERE (X.NUMEROD=@INTERNO) AND (X.TIPOFAC='G') 

   UPDATE SAFACT SET ORDENC=Y.Z_INTERNO 
   FROM SAFACT X INNER JOIN SAFACT_02 Y 
   ON X.NUMEROD=Y.NUMEROD AND X.TIPOFAC=Y.TIPOFAC
   WHERE X.NUMEROD=@NUMEROD AND X.TIPOFAC=@TIPOFAC 

   UPDATE SAPROD_12_03 SET FECHA=@FECHAHOY, FACTURA=@NUMEROD, SERVICIO_REALIZADO='VER FACTURA'  
   FROM SAPROD_12_03 X 
   INNER JOIN SAFACT_02 Y ON X.ORDEN_DE_REPARACION=Y.Z_INTERNO AND Y.TIPOFAC='G'
   INNER JOIN SAFACT_01 Z ON Y.TIPOFAC=Z.TIPOFAC AND Y.NUMEROD=Z.NUMEROD
   WHERE X.ORDEN_DE_REPARACION=@INTERNO AND CODPROD=Z.PLACA 
   
  END

  
  
  

-- Factura por otros servicios
IF @TIPOFAC='A' AND @CODOPER='01-401'
  BEGIN
   UPDATE SAFACT_01 SET STATUS='OTROS' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
   UPDATE SAFACT SET ORDENC='OTROS' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
  END

-- Factura de ACCESORIOS DE VENTA POR VEHICULO NUEVO.
IF @TIPOFAC='A' AND @CODOPER='01-501'
  BEGIN
   UPDATE SAFACT_01 SET STATUS='ACCESORIOS' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
   UPDATE SAFACT SET ORDENC='ACCESORIOS' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
  END


-- Factura de GARANTIAS A CHRYSLER. AGREGADO EL 06/03/2009
IF @TIPOFAC='A' AND @CODOPER='01-901'
  BEGIN
   UPDATE SAFACT_01 SET STATUS='GARANTIA' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
   UPDATE SAFACT SET ORDENC='GARANTIA' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC
  END
 

