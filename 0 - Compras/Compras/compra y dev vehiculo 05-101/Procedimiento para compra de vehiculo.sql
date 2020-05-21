  -- *****************************************************************************************
-- PROCESA COMPRA DE VEHICULO
-- 1. Corrige extension de compra del vehiculo.
-- 2. Crea vehiculo en inventario. Si existe lo actualiza.
-- 3. Crea registro de existencia en deposito de vehiculos.
-- 4. Crea registro de impuesto.
-- 5. Crea registro de extension del vehiculo. Si existe lo actualiza.
-- ********** REALIZADO POR CARLOS SILVA. MODIFICADO POR JOSE RAVELO ***********************
-- revisado ene-2013 JOSE RAVELO SOBRE LIBERTYLABORATORIO
-- *****************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SESA_SP_COMPRA_VEHICULO]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SESA_SP_COMPRA_VEHICULO]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
 


CREATE PROCEDURE dbo.SESA_SP_COMPRA_VEHICULO
@TipoDoc varchar(1), @NumeroD Varchar(10), @CodProv Varchar(10)
--WITH ENCRYPTION
AS


DECLARE @FechaHoy datetime
DECLARE @NumRec int

-- Datos del registro de IVA
DECLARE @CodTaxs varchar (5),
        @MontoIVA decimal (23,2),
        @EsPorct smallint

-- Datos del registro extendido de compra de vehiculo
DECLARE @CodProd varchar (15),
        @Serial varchar (35),
        @SerialMotor varchar (35),
        @Factura_compra varchar (10)

-- Datos del registro del modelo
DECLARE @Modelo varchar (15),
        @DescVehiculo varchar (35),
        @Marca varchar (20),
        @EsExento smallint

-- Datos del registro extendido del modelo
DECLARE @Ano int,
        @Cilindros int,
        @Kilometraje int,
        @Peso decimal(28,3),
        @Puestos int

-- Datos del registro extendido del vehiculo
DECLARE @Placa varchar (10),
        @Color varchar (25),
        @Status varchar (25),
        @CodInst int

-- Datos del registro de existencia
DECLARE @Deposito varchar (10),
        @Existencia decimal(28,3)

-- oTROS
DECLARE @CONCESIONARIO VARCHAR(40)

-- Datos del registro de item de la compra del vehiculo
DECLARE @CodItem varchar (15)

DECLARE @STATUSERROR INT,
        @DESCRIPERROR VARCHAR(200)
    





SET @NumRec     = 0
SET @FechaHoy   = getdate()
SET @Status     = 'EN VENTA'
SET @CodInst    = '12'
SET @Deposito   = '020'
SET @Existencia = 0
SET @CodTaxs    = 'IVA'

BEGIN
   -- RECOGE DATOS ADICIONALES COMPRA VEHICULO
   SELECT @Placa = UPPER(Placa),
          @Color = UPPER(Color),
          @Kilometraje = ISNULL(Kilometraje,0),  
          @SerialMotor = UPPER(Serial_motor)
      FROM dbo.SACOMP_01 
      WHERE (TipoCom = @TipoDoc AND NumeroD = @NumeroD AND CodProv = @CodProv)

-- VALIDACION DE LLENADO DE DATOS EN COMPRA VEHICULO

   IF LEN(@PLACA)=0 OR LEN(@COLOR)=0 OR LEN(@SerialMotor)=0
     BEGIN
      RAISERROR ('ESTOY AQUI',16,1)
      ROLLBACK TRANSACTION
      RETURN
     END
 
   -- REGOGE DATOS DE SERIALES DE COMPRA DE VEHICULO
   SELECT @CodItem = X.CodItem,
          @Serial  = X.NroSerial
      FROM SASEPRCOM AS X
      INNER JOIN dbo.SAITEMCOM AS Y
      ON (X.TipoCom = Y.TipoCom AND X.NumeroD = Y.NumeroD AND X.CodProv = Y.CodProv AND X.CodItem = Y.CodItem)
      WHERE (X.TipoCom = @TipoDoc AND X.NumeroD = @NumeroD AND X.CodProv = @CodProv)

   -- RECOGE DATOS 
   SELECT @Modelo       = x.CodProd,
          @DescVehiculo = X.Descrip,
          @Marca        = X.Marca,
          @EsExento     = X.EsExento,
          @Ano          = Y.Ano,
          @Cilindros    = Y.Cilindros,
          @Puestos      = Y.Puestos,
          @Peso         = Y.Peso
      FROM dbo.SAPROD AS X
      INNER JOIN dbo.SESA_VW_MODELOS AS Y
      ON (X.CodProd = Y.CodProd)
      WHERE (X.CodProd = @CodItem)

     -- recoge datos de concesionario
     SELECT @CONCESIONARIO = DESCRIP FROM SACONF 
    

   SET @NumRec = @@ROWCOUNT
   IF @NumRec > 0
   BEGIN
      -- Corrige extension de compra de vehiculo
      UPDATE dbo.SACOMP_01
         SET Placa       = @Placa,
             Kilometraje = @Kilometraje,
             Color       = @Color

         WHERE (TipoCom = @TipoDoc AND NumeroD = @NumeroD AND CodProv = @CodProv)
         
         -- llege bien hasta aqui 
         SET @DESCRIPERROR='LLEGUE HASTA AQUI CON ESTOS VALORES:' + @DESCvEHICULO+' / '+@CODINST+' / '+@MARCA +' / '+ @Placa+' / '+@Color+' / '+@SerialMotor+' / '+@Serial+' / '+@Modelo     
         RAISERROR ( @DESCRIPERROR, 16,1)
         --ROLLBACK TRANSACTION
         --RETURN  
         
         

      IF LEN(@Placa)= 6 OR LEN(@Placa)=7
         IF EXISTS (SELECT CodProd FROM dbo.SAPROD WHERE CodProd = @Placa or Refere=@placa)
         BEGIN
         
            -- Actualiza vehiculo en inventario.
            UPDATE dbo.SAPROD 
               SET Descrip = @DescVehiculo,
                   CodInst = @CodInst,
                   Marca   = @Marca,
                   Descrip3 = 'VEHICULO'
               WHERE (CodProd = @Placa or refere=@placa)
       
            -- Actualiza registro de extension del vehiculo.
            UPDATE dbo.SAPROD_12_01 
               SET Modelo         = @Modelo,
                   Serial         = @Serial,
                   Serial_motor   = @SerialMotor,
                   Color          = @Color,
                   factura_compra = @numerod, 
                   Kilometraje    = @Kilometraje,
                   Concesionario  = @Concesionario
               WHERE (CodProd = @Placa)
               
         END
         ELSE
         BEGIN



 
            -- Crea o actualiza registro en datos adicionales de existencia para optimizar consulta.
            IF NOT EXISTS (SELECT * FROM SAPROD_11_03 WHERE serial=@serial)
              INSERT dbo.SAPROD_11_03 (CodProd, Serial, Placa, Color, Status)     
              VALUES (@modelo, @serial, @placa, @Color, 'DISPONIBLE')
            ELSE
              UPDATE SAPROD_11_03 
                 SET Codprod=@modelo,
                     Serial=@serial,
                     Color=@Color,
                     Status='DISPONIBLE'
                 WHERE SERIAL=@SERIAL

            -- Crea vehiculo en inventario.
            
            IF NOT EXISTS (SELECT * FROM SAPROD WHERE CodProd=@placa)
               INSERT dbo.SAPROD (CodProd, Descrip, CodInst,Refere, Marca, Descrip3, EsExento) 
               VALUES (@Placa, @DescVehiculo, @CodInst, @placa, @Marca, 'VEHICULO', @EsExento)
            ELSE
               UPDATE SAPROD 
                 SET  CODPROD=@Placa,
                      Descrip=@DescVehiculo,
                      CODINST=@CodInst,
                      Refere=@placa,
                      Marca=@Marca,
                      Descrip3='VEHICULO',
                      EsExento=@EsExento
                 WHERE CODPROD=@Placa
                 

            -- Crea registro de existencia en deposito de vehiculos.
            
             IF NOT EXISTS (SELECT * FROM SAEXIS WHERE CodProd=@placa AND CodUbic=@Deposito)
               INSERT dbo.SAEXIS (CodProd, CodUbic, Existen) 
               VALUES (@Placa, @Deposito, @Existencia)
             ELSE
               UPDATE SAEXIS 
                 SET CodProd=@Placa,
                     CodUbic=@Deposito,
                     Existen=@Existencia
               where CodProd=@placa AND CodUbic=@Deposito

  

            -- Crea registro de impuesto.
            IF @EsExento = 0
            BEGIN
               SELECT @MontoIVA = MtoTax, @EsPorct = EsPorct FROM dbo.SATAXES WHERE (CodTaxs = @CodTaxs)
               INSERT SATAXPRD (CodProd, CodTaxs, Monto, EsPorct) 
                  VALUES (@Placa, @CodTaxs, @MontoIVA, @EsPorct)
            END
         
            -- Crea registro de extension del vehiculo.
            INSERT dbo.SAPROD_12_01 (CodProd, modelo, Serial, Serial_motor, Color, factura_compra, Kilometraje, Concesionario) 
               VALUES (@Placa, @Modelo, @Serial, @SerialMotor, @Color,@numerod, @Kilometraje, @concesionario)
            
            -- Crea los registros en tabla de conversion SACSCODALTVEH Y SACODBAR
            IF NOT EXISTS (SELECT CODALT FROM SACSCODALTVEH WHERE CODALT=@placa)
              INSERT dbo.SACSCODALTVEH (CodProd, CodAlt, Tipo)     
              VALUES (@placa, @placa, '1')
            IF NOT EXISTS (SELECT CODALT FROM SACSCODALTVEH WHERE CODALT=@SERIAL)
              INSERT dbo.SACSCODALTVEH (CodProd, CodAlt, Tipo)     
              VALUES (@placa, @SERIAL, '2')
            IF NOT EXISTS (SELECT CODALT FROM SACSCODALTVEH WHERE CODALT=RIGHT(@SERIAL,9))
              INSERT dbo.SACSCODALTVEH (CodProd, CodAlt, Tipo)     
              VALUES (@placa, RIGHT(@SERIAL,9), '3')
            IF NOT EXISTS (SELECT CODALT FROM SACSCODALTVEH WHERE CODALT=RIGHT(@SERIAL,6))
              INSERT dbo.SACSCODALTVEH (CodProd, CodAlt, Tipo)     
              VALUES (@placa, RIGHT(@SERIAL,6), '4')


            IF NOT EXISTS (SELECT CODALTE FROM SACODBAR WHERE CODALTE=@placa)
              INSERT dbo.SACODBAR (CodProd, CodAlte)     
              VALUES (@placa, @placa)
            IF NOT EXISTS (SELECT CODALTE FROM SACODBAR WHERE CODALTE=@SERIAL)
              INSERT dbo.SACODBAR (CodProd, CodAlte)     
              VALUES (@placa, @SERIAL)
            IF NOT EXISTS (SELECT CODALTE FROM SACODBAR WHERE CODALTE=RIGHT(@SERIAL,9))
              INSERT dbo.SACODBAR (CodProd, CodAlte)     
              VALUES (@placa, RIGHT(@SERIAL,9))
            IF NOT EXISTS (SELECT CODALTE FROM SACODBAR WHERE CODALTE=RIGHT(@SERIAL,6))
              INSERT dbo.SACODBAR (CodProd, CodAlte)     
              VALUES (@placa, RIGHT(@SERIAL,6))
          END
   END
END

SET QUOTED_IDENTIFIER OFF 
GO






























