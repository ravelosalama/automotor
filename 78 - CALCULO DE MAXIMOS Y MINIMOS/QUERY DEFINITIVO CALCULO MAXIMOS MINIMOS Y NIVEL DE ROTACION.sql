-- QUERY QUE CALCULA MAXIMOS Y MINIMOS ESTIMADOS DE ARTICULOS ACTIVOS (CON VENTAS EN LOS ULTIMOS 12 MESES 
-- Y LO ACTUALIZA EN SUS CAMPOS DE SAFACT 
-- ADICIONALMENTE CLASIFICA LOS ARTICULOS POR ROTACION> ALTA, MEDIA, Y BAJA
-- LA CONSULTA ESTUDIA LOS ITEM SAITEMFAC QUE NO SON VEHIULOS NI MDELOS, QUE NO SEAN SERVICIO, QUE SEAN 
-- DE FACTURAS NO DEVUELTAS, QUE SEAN DE VENTAS DE REPUESTOS X MOSTRADOR Y SERVICIOS, Y GARANTIAS
-- LOS ORDENA POR CODITEM Y CRONOLOGICAMENTE X DOCUMENTO Y SUMA LAS CANTIDADES EL RESULTADO LO DIVIDE ENTRE EL NUMERO DE
-- MESES QUE ABARCA EL RANGO DE FECHA DE ESTUDIO SOLICITADO ESE SERA EL MAXIMO Y EL MINIMO SERA EL MAXIMO ENTRE 4 (SEMANAS)
-- YA QUE CHRSYLER ASEGURA ENTREGA SEMANALMENTE)
-- LA SOLUCION REQUIERE DE CAMPOS ADICIONALES EN SAPROD LLAMADO SAPROD_01

-- DISE;ADO Y REALIZADO POR: JOSE RAVELO FECHA: MARZO 2012
-- OJO SE REQUIERE CORRERLO Y PROBAR TODOS Y CADA UNA DE SUS FUNCIONES EN VIVO CON CHEQUEO SOBRE BASE DE DATOS DE PRUEBA.
-- este query se complementa en agosto 2012 AGREGANDO DOS NIVELES DE ROTACION MAS ALOS YA CREADOS ALTA, MEDIA, BAJA MUY BAJA, NULA
-- CON LOS SIGUIENTES CRITERIOS:
-- 18/08/2012 SE OBSERVA QUE LOS QUERYS EN LOS WHERE SE ENCUENTRAN LIMITADOS AL LAPSO DE TIEMPO ENTRE LA VARIABLE @DESDEUV Y GETDATE()
-- POR LO QUE EN EL CALCULO DE MESES SOLO TENDRA EFECTO PARA CALCULAR MESES MENORES A MAXIMO CALCULADO. ES DECIR REDUNDA UN POCO. 



DECLARE @CODitem VARCHAR(15)
DECLARE @CANTIDAD INT
DECLARE @PROMEDIO INT
DECLARE @ROTACION VARCHAR(35)
DECLARE @DESDEUV VARCHAR(35)
DECLARE @FECHAHOY DATETIME
DECLARE @MESES INT
DECLARE @MAXMES INT
DECLARE @PROM_M INT
DECLARE @PROM_S INT
DECLARE @FechaI datetime

-- PARAMETROS DE LA CONSULTA: FECHA DE LA ULTIMA VENTA DESDE QUE SE DESEA HACER EL ESTUDIO HASTA LA FECHA DE EJECUCION DEL QUERY.
--                            RANGOS DE CANTIDAD PROMEDIO VENDIDO 

SET @DESDEUV='07/31/2012'
SET @FECHAHOY=GETDATE()
  
DECLARE MIREG CURSOR FOR

 -- Selecciona los articulos sin repeticion que cumplen con la condicion 
 
SELECT  DISTINCT  X.CODITEM
FROM         SAITEMFAC AS x INNER JOIN
                      SAFACT AS y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAPROD AS Z ON x.CodItem = Z.CodProd
  WHERE     
(x.EsServ = '0') AND (y.CodOper = '01-201' OR y.CodOper = '01-301') AND (y.TipoFac = 'A' OR Y.TipoFac='C') AND
 (y.NumeroR IS NULL OR y.NumeroR = '') AND (Z.FechaUV >= CONVERT(DATETIME, @DESDEUV, 120)) 
                      
ORDER BY x.CodItem   
 
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @CODitem 
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
               -- Calcula la cantidad total de unidades vendidas del articulo en el rango de fecha desde ultima venta hasta hoy
      
               SELECT  @CANTIDAD= SUM(X.CANTIDAD)
                                   
                  FROM         SAITEMFAC AS x INNER JOIN
                      SAFACT AS y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAPROD AS Z ON x.CodItem = Z.CodProd
                  WHERE     
                     (x.EsServ = '0') AND (y.CodOper = '01-201' OR y.CodOper = '01-301') AND (y.TipoFac = 'A' OR Y.TipoFac='C') AND
                     (y.NumeroR IS NULL OR y.NumeroR = '') AND (Z.FechaUV >= CONVERT(DATETIME, @DESDEUV, 120)) and x.CODITEM=@CODITEM
                    
                 -- Calcula el mayor periodo de tiempo en meses entre las fechas de ventas del ariculo y hoy   
                     
                  SELECT  @MAXMES=MAX(DATEDIFF (mm ,x.fechae ,getdate())  )OVER(PARTITION BY x.coditem)   
                             
                  FROM         SAITEMFAC AS x INNER JOIN
                      SAFACT AS y ON x.NumeroD = y.NumeroD AND x.TipoFac = y.TipoFac INNER JOIN
                      SAPROD AS Z ON x.CodItem = Z.CodProd
                  WHERE     
                     (x.EsServ = '0') AND (y.CodOper = '01-201' OR y.CodOper = '01-301') AND (y.TipoFac = 'A' OR Y.TipoFac='C') AND
                     (y.NumeroR IS NULL OR y.NumeroR = '') AND (Z.FechaUV >= CONVERT(DATETIME, @DESDEUV, 120)) and x.CODITEM=@CODITEM
              
                      -- CALCULA LOS MESES POR EL CUAL DEBERA DIVIDIRSE LA CANTIDAD TOTAL VEDIDA EN EL PERIODO PARA PROMEDIAR
                      -- EXACTAMENTE LAS VENTAS ENTRE LOS MESES EFECTIVAEMNTE ACTIVO del producto.
              BEGIN
              IF  @MAXMES >=DATEDIFF(mm ,CONVERT(DATETIME, @DESDEUV, 120),getdate())
                 SET @MESES=DATEDIFF(mm ,CONVERT(DATETIME, @DESDEUV, 120),getdate())
              ELSE
                 SET @MESES=@MAXMES       
              END
              
              SET @PROMEDIO=ROUND(@CANTIDAD/@MESES,0)
              
              UPDATE SAPROD SET Maximo=@PROMEDIO WHERE CodProd=@CODitem
                          
              IF @PROMEDIO>=15 
                 begin
                 UPDATE SAPROD SET Minimo=@PROMEDIO/2 WHERE CodProd=@CODitem
                 set @rotacion='ALTA'
                 end
              IF @PROMEDIO>=4 AND @PROMEDIO<15
                 begin
                 UPDATE SAPROD SET Minimo=@PROMEDIO/3 WHERE CodProd=@CODitem
                 set @rotacion='MEDIA'
                 end
              IF @PROMEDIO>0 AND @PROMEDIO<=3
                 begin
                 UPDATE SAPROD SET Minimo=@PROMEDIO/4 WHERE CodProd=@CODitem
                 set @rotacion='BAJA'
                 end
              IF @PROMEDIO=0 AND @CANTIDAD>0
                 begin
                 UPDATE SAPROD SET Minimo=@PROMEDIO/5 WHERE CodProd=@CODitem
                 set @rotacion='MUY BAJA'
                 end
               IF @PROMEDIO=0 AND @CANTIDAD=0
                 begin
                 UPDATE SAPROD SET Minimo=@PROMEDIO/5 WHERE CodProd=@CODitem
                 set @rotacion='OBSOLETO'
                 end   
               BEGIN   
                IF NOT EXISTS (SELECT * FROM SAPROD_01 WHERE CODPROD=@CODitem)
                   INSERT SAPROD_01 (CodProd
                                       , Fecha_de_inicio
                                       ,ultimo_estudio
                                       , PROM_MENSUAL
                                       ,PROM_MOSTRADOR
                                       ,PROM_SERVICIO                                       
                                       ,rotacion)
                                        
                   VALUES              (@Coditem
                                        , @FechaI
                                        , getdate()
                                        , @promedio
                                        , @PROM_M
                                        , @PROM_S
                                        , @rotacion)
                ELSE
                   UPDATE SAPROD_01 set Fecha_de_inicio=@FechaI
                                         ,ultimo_estudio=GETDATE()
                                         ,PROM_MENSUAL=@PROMEDIO
                                         ,PROM_MOSTRADOR=@PROM_M
                                         ,PROM_SERVICIO=@PROM_S                                         
                                         ,Rotacion=@ROTACION
                   WHERE CodProd=@CODitem
              END                
              FETCH NEXT FROM MIREG INTO @CODitem       
        END             
      CLOSE MIREG
      DEALLOCATE MIREG
 
  