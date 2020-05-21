-- QUERY ELABORADO EN MARZO 2012 MODIFICADO EN AGOSTO 2012 PARA ADAPTARLO A NUEVAS INSTANCIAS DE OBSOLESCENCIAS
-- ESTE QUERY DEBE CORRERSE CUANDO LAS INSTANCIAS EN SAINSTA ESTEN ACTUALIZADAS EN LAS TABLAS.

-- Repara llevando a cero el stock en negativo


DECLARE @DESDEUV DATETIME
SET @DESDEUV='07/31/2012' 
 
 
   
update SAPROD set Existen=0 
where Existen<0

update SAEXIS set Existen=0 
where Existen<0


-- Repara llevando a cero el compro en negativo
   
update SAPROD set Compro=0 
where Compro<0

update SAprod set Pedido=0 
where Pedido<0


-- CLASIFICA NUEVOS  PRODUCTOS  QUE ENTRAN EN OBSOLESCENCIA COMO OBSOLETOS EN FUNCION A LA ULTIMA VENTA SEA MENOR A LA 
-- 
--INDICADA EN LA VARIABLE  @DESDEUV NORMALMENTE DEBE SER TOMADA 12 MESES ANTES A LA FECHA DE HOY O DE EJECUCION DE LA 
-- 
-- CONSULTA.
-- EL CAMPO Diasentr nativo de saint pero no usado sera utilizado para guardar la instancia anterior de inventario
-- la debilidad de este procedimiento es que no se puede correr mas de una vez porque pierde el contenido aterior.

        
UPDATE SAPROD SET Diasentr=CodInst, CodInst='34',Activo=0  
FROM         SAPROD 
WHERE FechaUV < CONVERT(DATETIME, @DESDEUV, 120) AND CodInst<>'11' AND CodInst<>'12' AND CodInst<>'27'and CodInst<>'34' and Existen=0 

        
UPDATE SAPROD SET Diasentr=CodInst, CodInst='33',Activo=1  
FROM         SAPROD 
WHERE FechaUV < CONVERT(DATETIME, @DESDEUV, 120) AND CodInst<>'11' AND CodInst<>'12' AND CodInst<>'27'and Existen>0  and CodInst<>'33' 


-- DESINCORPORA EL PRODUCTO EN FUNCION A QUE SEA OBSOLETO Y TENGA STOCK CERO.

   UPDATE SAPROD SET Activo=0  
   WHERE CodInst='34' AND Existen=0

-- CORRIGE REINCORPORANDO EL PRODUCTO SI TIENE STOCK AUN CUANDO ESTE CLASIFICADO OBSOLETO.     

UPDATE    SAPROD
SET              Activo = 1
FROM         SAPROD  
WHERE     (SAPROD.CodInst = '33') AND (SAPROD.Existen <> 0) AND (SAPROD.Activo = 0)


-- CORRIGE RECLASIFICANDO Y REINCORPORANDO PRODUCTOS QUE TIENEN MENOS DE 12 MESES DESDE SU ULTIMA VENTA Y ESTABA COMO -- OBSOLETO
 

UPDATE SAPROD SET CODINST='32', ACTIVO=1
FROM         SAPROD WHERE FechaUV >= CONVERT(DATETIME, @DESDEUV, 120) AND (CodInst='33'or CodInst='34') 



-- RECLASIFICACION PARA ARTICULOS ACTIVOS 

--- RECLASIFICACION DE ACEITES Y FILTROS

UPDATE    SAPROD
SET              CodInst = '20'
WHERE     (Descrip LIKE 'ACEITE%') AND (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34')

UPDATE    SAPROD
SET              CodInst = '20'
WHERE     (Descrip LIKE 'FILTRO%') AND (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34')

UPDATE    SAPROD
SET              CodInst = '20'
FROM         SAPROD
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (Descrip LIKE '%LIQUIDO%')

UPDATE    SAPROD
SET              CodInst = '20'
FROM         SAPROD
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (Descrip LIKE '%LIGA%')


--- RECLASIFICACION DE ACCESORIOS

UPDATE    SAPROD
SET              CodInst = '4'
WHERE     (Descrip LIKE '%ALFOMBRA%') AND (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34')

UPDATE    SAPROD
SET              CodInst = '4'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (SUBSTRING(CodProd, 1, 3) = '822') AND (CodInst <> '4') AND (CodInst <> '20')

--UPDATE    SAPROD
--SET              CodInst = '4'
--WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (CodInst = '5') AND (Descrip LIKE '%EMBLEMA%')

UPDATE    SAPROD
SET              CodInst = '4'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (Descrip LIKE '%APLIQUE%')

UPDATE    SAPROD
SET              CodInst = '4'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (Descrip LIKE '%ESTRIBO%')

--- RECLASIFICACION DE REPUESTOS GENERALES

UPDATE    SAPROD
SET              CodInst = '32'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (CodInst = '5')

-- QUERY ESPECIAL DE PLANET CARS
UPDATE    SAPROD
SET              CodInst = '32'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (CodInst = '28')

--

-- QUERY ESPECIAL DE GUAYANAUTO
UPDATE    SAPROD
SET              CodInst = '32'
WHERE     (CodInst <> '27') AND (CodInst <> '33') AND (CodInst <> '34') AND (CodInst = '29')

 
-- RECLASIFICACION Y DESACTIVACION DE ARTICULOS OBSOLETOS Y SIN STOCK
 

-- precisiones de prestige cars por estar capo fechauv en null

update SAPROD set CodInst='33', Activo=1
   where  CodInst='32' and   ( FechaUV < CONVERT(DATETIME, @DESDEUV, 120) or FechaUV is null) and Existen<>0
  
update saprod set codinst='34', activo=0  
   where  CodInst='32' and   ( FechaUV < CONVERT(DATETIME, @DESDEUV, 120) or FechaUV is null) and Existen=0
   
