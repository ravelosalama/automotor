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
DROP TRIGGER CONCESIONARIOS_TG_ESPERA_OR
GO
CREATE TRIGGER CONCESIONARIOS_TG_ESPERA_OR ON SAFACT_02
WITH ENCRYPTION
AFTER INSERT, UPDATE
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

-----------------------------------------------------
--- RECOLECCION DE DATOS - (CORRECCION Y PREPARACION)
-----------------------------------------------------

-- Recoge datos de la tabla: INSERTED
   SELECT @TIPOFAC=TIPOFAC,
          @NUMEROD=NUMEROD,
          @MODELO=UPPER(MODELO),
          @COLOR=UPPER(COLOR),
          @SERIAL=UPPER(SERIAL),
          @SERIAL_M=UPPER(SERIAL_M),
          @VENDIDO=ISNULL(VENDIDO,'01/01/2000'),
          @CONCESIONARIO=UPPER(VENDIO_CONCESIONARIO),
          @INTERNO=Z_INTERNO
   FROM INSERTED

-- Recoge datos de la tabla: SAFACT_01
   SELECT @PLACA=UPPER(PLACA),
          @KILOMETRAJE=ISNULL(KILOMETRAJE,0),
          @LIQUIDACION=LIQUIDACION,
          @STATUS=STATUS,
          @CIERRE_OR=GETDATE(),
          @APERTURA_OR=APERTURA_OR
   FROM SAFACT_01 WHERE TIPOFAC=@TIPOFAC AND NUMEROD=@NUMEROD

   -- Determina la liquidacion de la orden segun la primera letras
   BEGIN
     IF (UPPER(SUBSTRING(@Liquidacion,1,1)) = 'I') SET @Liquidacion = 'INTERNA'
     ELSE
     IF (UPPER(SUBSTRING(@Liquidacion,1,1)) = 'G') SET @Liquidacion = 'GARANTIA'
     ELSE
     IF (UPPER(SUBSTRING(@Liquidacion,1,1)) = 'C') SET @Liquidacion = 'CONTADO'
     ELSE
     IF (UPPER(SUBSTRING(@Liquidacion,1,1)) = 'A') SET @Liquidacion = 'ACCESORIO'
     ELSE 
     SET @Liquidacion = '???'
   END

   -- Determina el status de la orden de reparacion segun a la primera letra
   BEGIN
     IF (UPPER(SUBSTRING(@Status,1,1)) = 'P') or LEN(@Status) = 0 -- PENDIENTE O PROCESO
        SET @Status = 'PENDIENTE'
     ELSE
     IF (UPPER(SUBSTRING(@Status,1,1)) = 'C') -- CERRADA
        SET @Status = 'CERRADA'
     ELSE
     IF (UPPER(SUBSTRING(@Status,1,1)) = 'S') -- SUSPENSO EN ESPERA DE REPUESTOS.
        SET @Status = 'SUSPENSO'
   END


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


IF @TIPOFAC='G' AND @CODOPER='01-301'

BEGIN

---------------------    
-- VALIDACIONES
--------------------- 

    -- Valida consistencia en campo de MODELO
     IF NOT EXISTS (SELECT * FROM SAPROD WHERE CODPROD=@MODELO)AND LEN(@COLOR)<>0 AND LEN(@SERIAL)<>0 
       BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='MODELO INDICADO NO EXISTE EN BASE DE DATOS, CREE EL MODELO O REVISE LA INFORMACION '             
        END 
        
   IF LEN(@PLACA) = 0 OR LEN(@PLACA)<6 OR LEN(@PLACA)>7 OR @PLACA=''
     BEGIN
      SET @STATUSERROR=1
      SET @DESCRIPERROR='<<<<<<<<< Debe indicar un numero de PLACA Valida. >>>>>>>>'            
     END
   ELSE
      -- Respecto a existencia y consistencia de datos del vehiculo en base de datos
      IF NOT EXISTS (SELECT * FROM SAPROD WHERE CodProd = @Placa or refere=@placa) 
         IF LEN(@MODELO)=0 OR LEN(@COLOR)=0 OR LEN(@SERIAL)=0 OR LEN(@SERIAL_M)=0 OR LEN(@VENDIDO)=0 OR LEN(@CONCESIONARIO)=0
           BEGIN
            SET @STATUSERROR=1
            SET @DESCRIPERROR='La Placa no existe en base de datos, Debe comenzar de nuevo el proceso. Cerciorese de completar TODOS los datos de la ficha Registro de vehiculo'            
           END
         ELSE
           IF NOT EXISTS (SELECT * FROM SAPROD_12_01 WHERE (SERIAL = @SERIAL))
              SET @VEHICULO = 1 -- CREAR VEHICULO EN BASE DE DATOS SEGUN REGISTRO DE VEHICULO
           ELSE
           BEGIN
            SET @STATUSERROR=1
            SET @DESCRIPERROR='Inconsistencia detectada: El Serial citado ya existe en base de datos con otra placa asignada, REVISE e intente de nuevo'            
           END
      ELSE
          BEGIN
            SET @VEHICULO = 2 -- TOMAR DATOS DE VEHICULO EN BD Y CARGARLO A REGISTRO DE VEHICULO

            SELECT @CODVEH=CODPROD FROM SAPROD WHERE REFERE=@PLACA OR CODPROD=@PLACA

            SELECT @Modelo = Modelo,
             @Serial = Serial,
             @Color  = Color,
             @VENDIDO=ISNULL(fecha_venta,'01/01/2000'),
             @Serial_M= ISNULL(Serial_motor,SERIAL),
             @concesionario=Concesionario
            FROM dbo.SAPROD_12_01 WHERE (CODPROD=@CODVEH)
         END
  
     -- Respecto a numeros de OR ABIERTAS  del mismo vehiculo.
     IF EXISTS (SELECT * FROM SAFACT_01 x inner join safact_02 y on x.tipofac=y.tipofac and x.numerod=y.numerod WHERE (@serial<>'' and Y.SERIAL=@SERIAL AND x.TIPOFAC='G' AND x.NUMEROD <>@NUMEROD AND LIQUIDACION = @LIQUIDACION AND STATUS = 'PENDIENTE'))  
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='Ya existe una OR Abierta y del mismo tipo para este vehiculo segun SERIAL, Debe cambiar Status de LA EXISTENTE antes de abrir nueva Orden'             
        END

     -- Valida si codigo del asesor es valido
     IF SUBSTRING(@CODVEND,1,2)<>'AS'
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='EL Codigo:'+ @codvend + ' del Asesor no es valido, Revise los datos del encabezado e intente de nuevo'             
        END

     --Valida si al cerrar orden posee tecnicos validos   OJO REVISAR ESTA VALIDACION NO FUNCIONA se coloco en otro trigger
    -- IF SUBSTRING(@STATUS,1,1)='C' AND EXISTS (SELECT * FROM SAITEMFAC WHERE CODMECA='AAAAA' and numerod=@numerod and tipofac=@tipofac)
      --  BEGIN
      --   SET @STATUSERROR=1
      --   SET @DESCRIPERROR='No se puede cerrar la O/R con rubros de servicios sin definicion de técnico asignado valido'             
      --  END   
     
     -- Valida si se registraron requerimientos en Comentarios
     IF @NOTAS1 IS NULL AND @NOTAS2 IS NULL AND @NOTAS3 IS NULL AND @NOTAS4 IS NULL AND @NOTAS5 IS NULL  
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='No ha registrado los requerimientos en la Orden, Reinicie el proceso y asegurese de rellenar los Comentarios'             
        END  
  --   IF LEN(@NOTAS6)=0 AND LEN(@NOTAS7)=0 AND LEN(@NOTAS8)=0 AND LEN(@NOTAS9)=0 AND LEN(@NOTAS10)=0
  --     BEGIN
  --       SET @STATUSERROR=1
  --       SET @DESCRIPERROR='No ha registrado los requerimientos en la Orden, Reinicie el proceso y asegurese de rellenar los Comentarios'             
  --      END  

     -- Valida consistenacia en campo de liquidacion
     IF @Liquidacion<>'CONTADO' AND @Liquidacion<>'GARANTIA' AND @LIQUIDACION<>'INTERNA' AND @LIQUIDACION<>'ACCESORIO'
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='El Campo liquidacion solo acepta los valores: CONTADO, GARANTIA, INTERNA O ACCESORIO, REVISE Y Reintente la accion.'             
        END  

     -- Valida consistencia en campo de status
     IF @STATUS<>'PENDIENTE' AND @STATUS<>'CERRADA' AND @STATUS<>'SUSPENSO'
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='El Campo Status solo acepta los valores: PENDIENTE, CERRADA O SUSPENSO, REVISE Y Reintente la accion.'             
        END  

     -- Valida consistencia en campo de status
     IF @LIQUIDACION='CONTADO' AND @STATUS='CERRADA' -- OR @LIQUIDACION='GARANTIA' CONDICION RORAIMA
        BEGIN
         SET @STATUSERROR=1
         SET @DESCRIPERROR='POR SEGURIDAD LAS ORDENES <<CONTADO>> NO se cierran por esta via, Son CERRADAS por el sistema solo si son FACTURADAS por CAJA '             
        END 


 -- MUESTRA PANTALLA CON RESULTADO DE VALIDACIONES SI LAS HAY.

   IF @STATUSERROR=1
   BEGIN
      RAISERROR (@DESCRIPERROR,16,1)
      ROLLBACK TRANSACTION
      RETURN
   END

-----------------------------------------------------------------------------------------   
-- SI PLACA NO EXISTE EN BD Y REGISTRO DE VEHICULO ESTA COMPLETO CREA VEHICULO EN BD
----------------------------------------------------------------------------------------- 
 
IF @VEHICULO = 1

BEGIN

   -- 1 --  VERIFICA DATOS DEL MODELO EN BD

   IF EXISTS (SELECT * FROM SAPROD WHERE (CodProd = @Modelo))
      BEGIN
       SELECT @DescriModelo   = Descrip,
              @EsExento = EsExento
              FROM SAPROD
              WHERE (CodProd = @Modelo)
      END
   ELSE
      BEGIN
        SET @DescriModelo   = 'MOD. CITADO POR SERV.NO EXISTE EN BD'
        SET @EsExento = 1
      END
      
   -- 2 -- Crea vehiculo en inventario
      INSERT SAPROD (CodProd, Refere, Descrip, Descrip3, CodInst, EsExento) 
         VALUES (@Placa, @Placa, @DescriModelo, 'VEHICULO', @CodInst, @EsExento)

      -- Crea registro de existencia
      INSERT SAEXIS (CodProd, CodUbic, Existen) 
         VALUES (@Placa, @Deposito, 0)

      -- Crea registro de impuesto
      IF @EsExento = 0
      BEGIN
         SELECT @MontoIVA = MtoTax,
                @EsPorct = EsPorct
            FROM dbo.[SATAXES]
            WHERE (CodTaxs = @CodTaxs)

         INSERT SATAXPRD (CodProd, CodTaxs, Monto, EsPorct) 
            VALUES (@Placa, @CodTaxs, @MontoIVA, @EsPorct)
      END 
      
      -- Crea datos adicionales del vehiculo
 
      INSERT dbo.SAPROD_12_01 (CodProd, Modelo, Serial, Color, Fecha_venta, Kilometraje,Serial_motor, Concesionario ) 
         VALUES (@Placa, @Modelo, @Serial, @Color, @Vendido, @Kilometraje, @Serial_M, @concesionario)
END

------------------------------------------------------------------------------------------------------
-- SI EXISTE PLACA EN BASE DE DATOS REGOGE DATOS ADICIONALES Y LOS CARGA EN REGISTRO DE VEHICULO
------------------------------------------------------------------------------------------------------
--IF @VEHICULO = 2


-- TOMA EL VALOR EN @CODPROD DEL CAMPO CODPROD DEL REGISTRO DE VEHICULO CONSULTADO POR REFERENCIA O NUEVA PLACA. OJO MUY IMPORTANTE.




 
-- ACTUALIZA DATOS CORREGIDOS Y PREPARADOS EN SAFACT_01 Y SAFACT_02, coloca placa en orden de compra en SAFACT, 

   UPDATE SAFACT_01 SET            
          PLACA=@PLACA,
          KILOMETRAJE=@KILOMETRAJE,
          LIQUIDACION=@LIQUIDACION,
          STATUS=@STATUS,
          CIERRE_OR=@CIERRE_OR,
          APERTURA_OR=@APERTURA_OR
          WHERE TIPOFAC=@TIPOFAC AND NUMEROD=@NUMEROD


   UPDATE SAFACT_02 SET
          MODELO=@MODELO,
          COLOR=@COLOR,
          SERIAL=@SERIAL,
          SERIAL_M=@SERIAL_M,
          VENDIDO=@VENDIDO,
          VENDIO_CONCESIONARIO=@CONCESIONARIO,
          Z_INTERNO = @NUMEROD
          WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC


   UPDATE SAFACT SET
          ORDENC=@PLACA+' '+@LIQUIDACION, NOTAS10=@PLACA+' '+@LIQUIDACION
          WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC


--------------------------------------------------------------------------------------------------------
-- CREA VINCULOS CON TABLAS MAESTRAS PARA MEJORAR INFORMACION DE CONSULTA RAPIDA
--------------------------------------------------------------------------------------------------------


   -- Crea datos del vinculo con el cliente y viceversa.  
   IF NOT EXISTS (SELECT * FROM SACLIE_04 WHERE (CODCLIE=@CODCLIE AND PLACA=@PLACA))
      INSERT dbo.SACLIE_04 (FecTrn, Codclie, Placa, Modelo, Serial, Color, Vendido, Concesionario ) 
      VALUES (@Fechahoy, @codclie, @Placa, @Modelo, @Serial, @Color, @Vendido, @concesionario)
   ELSE
      UPDATE SACLIE_04 SET
          FecTrn=@Fechahoy,
          CODCLIE=@CODCLIE,
          PLACA=@PLACA,
          MODELO=@MODELO,
          COLOR=@COLOR,
          SERIAL=@SERIAL,
          VENDIDO=@VENDIDO,
          CONCESIONARIO=@CONCESIONARIO
          WHERE CODCLIE=@CODCLIE AND PLACA=@PLACA

    -- Crea o actualiza ficha de Clientes Vinculados en Productos/vehiculo.
    IF NOT EXISTS (SELECT * FROM SAPROD_12_02 WHERE (CODPROD=@PLACA AND CODCLIE=@CODCLIE))
      INSERT dbo.SAPROD_12_02 (FecTrn, Codprod, CodClie, Descripcion, Condicion) 
      VALUES (@fechahoy, @Placa, @Codclie, @Desclie, 'X DEFINIR' )
    ELSE
      UPDATE SAPROD_12_02 SET
          FecTrn=@Fechahoy,
          CODCLIE=@CODCLIE,
          CODPROD=@PLACA,
          DESCRIPCION=@DESCLIE
          -- CONDICION=''                    
      WHERE CODCLIE=@CODCLIE AND CODPROD=@PLACA

    -- Crea o actualiza ficha de consulta de servicios en Productos.
    IF NOT EXISTS (SELECT * FROM SAPROD_12_03 WHERE (CODPROD=@PLACA AND Orden_de_reparacion=@numerod))
      INSERT dbo.SAPROD_12_03 (Codprod, FecTrn, fecha, factura, Orden_de_reparacion, servicio_realizado) 
      VALUES (@placa, @fechahoy, @fechahoy, 'PENDIENTE', @numerod, @status )
    ELSE
      UPDATE SAPROD_12_03 SET
          FecTrn=@Fechahoy,
          Fecha=@Fechahoy,
          CODprod=@Placa,
          Orden_de_reparacion=@numerod
      WHERE (CODPROD=@PLACA AND Orden_de_reparacion=@numerod) 


---------------------------------------------------------------------------------------------------
-- PROCESA CIERRE DE ORDENES DISTINTAS A CONTADO PARA QUE NO SEAN EDITABLES Y TENGAN FECHA DE CORTE
---------------------------------------------------------------------------------------------------
--AND (@CODUSUA='JACK' OR @CODUSUA='DORIS') -- OJO ADAPTACION TEMPORAL PRESTIGE CARS  ADAPTACION RORAIMA MOTORS {AND @LIQUIDACION<>'GARANTIA'.
          
  IF @LIQUIDACION<>'CONTADO'  AND @STATUS='CERRADA' 
       BEGIN
        UPDATE SAFACT    SET TIPOFAC='Z' WHERE (TipoFac = @TipoFac and NumeroD = @NumeroD) 
        UPDATE SAFACT_01 SET TIPOFAC='Z' WHERE (TipoFac = @TipoFac and NumeroD = @NumeroD)
        UPDATE SAFACT_02 SET TIPOFAC='Z' WHERE (TipoFac = @TipoFac and NumeroD = @NumeroD)
        -- UPDATE SAITEMFAC SET TIPOFAC='Z' WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD)
        -- LA SIGUENTE INSTRUCCION ES PARA ELIMINAR LOS REGISTROS EN SAITEMFAC QUE SE CREAN 
        -- Y DUPLICAN LA DATA SOLO QUE LO CREA CON TIPOFAC='G' OJO AVERIGUAR POR QUE PASA ESTO
        --DELETE FROM SAITEMFAC WHERE (TipoFac = @TipoDoc and NumeroD = @NumeroD) 
      END
END

-------------------------------------------------------------------------------------------------------
-- IDENTIFICADOR DE TRANSAACIONES Y MARCAS GENERALES EN CASO DE ORDEN DE REPARACION (CASOS PREFACTURAS)
-------------------------------------------------------------------------------------------------------

IF @TIPOFAC='G' AND @CODOPER='01-101'
   UPDATE SAFACT SET ORDENC='VEHICULO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

IF @TIPOFAC='G' AND @CODOPER='01-201'
   UPDATE SAFACT SET ORDENC='REPUESTO' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC

IF @TIPOFAC='G' AND @CODOPER='01-901'
   UPDATE SAFACT SET ORDENC='GARANTIA' WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC



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

   INSERT SACLIE_04 (CODCLIE, FECTRN, PLACA, MODELO, SERIAL, COLOR, VENDIDO, CONCESIONARIO)
   VALUES (@CODCLIE, @FECHAHOY, @PLACA, @MODELO, @SERIAL, @COLOR, @FECHAHOY, @CONCESIONARIO)

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

   -- Descuenta CANTIDAD A COMPROMETIDOS POR CADA repuestos facturado EN OR / CONTADO
   -- (ESTO ES UNA CORRECCION A FALLA DE SAINT)
   
       DECLARE MIREG1 CURSOR FOR
       
       SELECT DISTINCT CODITEM 
       FROM SAITEMFAC WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC  
       
      OPEN MIREG1
      FETCH NEXT FROM MIREG1 INTO @CodItem
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
 
         -- Determina la cantidad del repuesto entregado
         SELECT @Cantidad = SUM(Cantidad)
         FROM  SAITEMFAC 
         WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC AND CODITEM=@Coditem
      
         -- Actualiza la cantidad comprometida del repuesto en la tabla saprod
            UPDATE SAPROD SET COMPRO=COMPRO - @CANTIDAD WHERE CODPROD=@CodItem

         FETCH NEXT FROM MIREG1 INTO @CodItem
      END
      CLOSE MIREG1
      DEALLOCATE MIREG1
     

  END

-- Devolucion Factura de servicio

  IF @TIPOFAC='B' AND @CODOPER='01-301'
    
    BEGIN
    -- Suma la CANTIDAD DEVUELTA A COMPROMETIDOS POR CADA repuestos devuelto EN OR / CONTADO
    -- (ESTO ES UNA CORRECCION A FALLA DE SAINT)
          
       DECLARE MIREG CURSOR FOR
       
       SELECT DISTINCT CODITEM 
       FROM SAITEMFAC WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC  
       
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @CodItem
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
 
         -- Determina la cantidad del repuesto entregado
         SELECT @Cantidad = SUM(Cantidad)
         FROM  SAITEMFAC 
         WHERE NUMEROD=@NUMEROD AND TIPOFAC=@TIPOFAC AND CODITEM=@Coditem
      
         -- Actualiza la cantidad comprometida del repuesto en la tabla saprod
            UPDATE SAPROD SET COMPRO=COMPRO + @CANTIDAD WHERE CODPROD=@CodItem

         FETCH NEXT FROM MIREG INTO @CodItem
      END
      CLOSE MIREG
      DEALLOCATE MIREG
     
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



