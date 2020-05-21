DROP VIEW dbo.VW_ADM_GESTION_TALLER
GO
CREATE VIEW dbo.VW_ADM_GESTION_TALLER
AS

SELECT TOP 100 PERCENT

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 1. OR PENDIENTES APERTURADAS EN MESES ANTERIORES 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- OR CONTADO PENDIENTE (1/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_C_P_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_P_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_P_MA, 

-- OR GARANTIA PENDIENTE (2/24) 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_G_P_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_P_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_P_MA, 

-- OR INTERNA PENDIENTE (3/24) 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_I_P_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_P_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_P_MA, 

-- OR ACCESORIO PENDIENTE (4/24) 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_A_P_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_P_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (X.Status = 'PENDIENTE') AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_P_MA, 


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 2. OR APERTURADAS EN EL PERIODO ACTUAL    OJO DE AQUI SOLO SIRVE EL CONTADOR DE REGISTROS NO EL ACUMULADOR DE TOTALES
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- OR CONTADO (5/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_C_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_PA,

-- OR GARANTIA (6/24)
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA')  AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_G_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA')  AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA')  AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_PA,

-- OR INTERNA (7/24)
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_I_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_PA,

-- OR ACCESORIO (8/24)
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_A_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE()))THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_PA,



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 3. OR CERRADAS EN EL PERIODO DE OR DE MESES ANTERIORES   OJO DE AQUI SOLO SIRVE EL CONTADOR DE REGISTROS NO EL ACUMULADOR DE TOTALES
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- OR CONTADO (9/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_C_C_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_C_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_C_MA,

-- OR GARANTIA (10/24)
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN 1 ELSE 0 END) AS OR_G_C_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_C_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_C_MA,

-- OR INTERNA (11/24)
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN 1 ELSE 0 END) AS OR_I_C_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_C_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE()))  THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_C_MA,

-- OR ACCESORIO (12/24)
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_A_C_MA,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_C_MA, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)<= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_C_MA,


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 4. OR CERRADAS EN EL PERIODO DE OR DEL MISMO PERIODO  OJO DE AQUI SOLO SIRVE EL CONTADOR DE REGISTROS NO EL ACUMULADOR DE TOTALES
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- OR CONTADO (13/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_C_C_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='A' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_C_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND X.TIPOFAC='A' AND X.STATUS<>'PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_C_PA,

-- OR GARANTIA (14/24)
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_G_C_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_C_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_C_PA,

-- OR INTERNA (15/24)
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_I_C_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_C_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND X.TIPOFAC='Z' AND (MONTH(X.Apertura_OR) < MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_C_PA,

-- OR ACCESORIO (16/24)
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_A_C_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_C_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND X.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) AND (MONTH(X.CIERRE_OR)=MONTH(GETDATE()) AND YEAR(X.CIERRE_OR)=YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_C_PA,


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 5. OR PENDIENTES HASTA LA FECHA APERTURADAS EN MISMO PERIODO  OJO DE AQUI SOLO SIRVE EL CONTADOR DE REGISTROS NO EL ACUMULADOR DE TOTALES
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- OR CONTADO (17/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_C_P_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_P_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_P_PA,

-- OR GARANTIA (18/24)
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_G_P_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_P_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_P_PA,

-- OR INTERNA (19/24)
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_I_P_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_P_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_P_PA,

-- OR ACCESORIO (20/24)
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN 1 ELSE 0 END) AS OR_A_P_PA,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_P_PA, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE'AND (MONTH(X.Apertura_OR) = MONTH(GETDATE())) AND (YEAR(X.Apertura_OR)= YEAR(GETDATE())) THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_P_PA,


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 6 OR PENDIENTES TOTALES 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- OR CONTADO (21/24)
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' THEN 1 ELSE 0 END) AS OR_C_P,          
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' THEN Y.TOTALSRV else 0 END) AS SVR_OR_C_P, 
 SUM(CASE WHEN (X.Liquidacion = 'CONTADO') AND Y.TIPOFAC='G' AND X.STATUS='PENDIENTE' THEN Y.TOTALPRD else 0 END) AS PRD_OR_C_P,

-- OR GARANTIA (22/24)
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' THEN 1 ELSE 0 END) AS OR_G_P,          
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' THEN Y.TOTALSRV else 0 END) AS SVR_OR_G_P, 
 SUM(CASE WHEN (X.Liquidacion = 'GARANTIA') AND Y.TIPOFAC='G' THEN Y.TOTALPRD else 0 END) AS PRD_OR_G_P,

-- OR INTERNA (23/24)
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' THEN 1 ELSE 0 END) AS OR_I_P,          
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' THEN Y.TOTALSRV else 0 END) AS SVR_OR_I_P, 
 SUM(CASE WHEN (X.Liquidacion = 'INTERNA') AND Y.TIPOFAC='G' THEN Y.TOTALPRD else 0 END) AS PRD_OR_I_P,

-- OR ACCESORIO (24/24)
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' THEN 1 ELSE 0 END) AS OR_A_P,          
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' THEN Y.TOTALSRV else 0 END) AS SVR_OR_A_P, 
 SUM(CASE WHEN (X.Liquidacion = 'ACCESORIO') AND Y.TIPOFAC='G' AND X.STATUS<>'PENDIENTE' THEN Y.TOTALPRD else 0 END) AS PRD_OR_A_P


FROM  SAFACT_01 X LEFT OUTER JOIN SAFACT Y ON X.NUMEROD=Y.NUMEROD 
                
 
GO
----------------

declare @TNAME CHAR(21)
declare @ALIAS CHAR(21)
SET @TNAME = 'VW_ADM_GESTION_TALLER'
SET @ALIAS = 'VW_ADM_GESTION_TALLER'
 
Delete SATABL
Where TableName=@TNAME
 
DELETE SAFIEL
Where TableName=@TNAME

Insert Into SATABL
(tablename, tablealias)
Values (@TNAME, @ALIAS)

Insert Into  SAFIEL 
(TableName, FieldName, FieldAlias, DataType, Selectable, Searchable, Sortable, AutoSearch, Mandatory)
 
(
Select A.Name As TableName, B.Name As FieldName, B.Name As FieldAlias, 
       Case B.XType
    When 56  Then 'dtLongInt'
	When 58  Then 'dtInteger'
	When 106 Then 'dtDouble'
        When 167 Then 'dtString'
        When 61  Then 'dtDateTime'
	When 35  Then 'dtMemo'
        When 52  Then 'dtInteger'
	When 34  Then 'dtGraphic'
	When 165 Then 'dtBlob'        
        End As DataType,
       'T' Selectable, 
       'T' Searchable,  
       'T' Sortable, 
       'F' AutoSearch, 
       'F' Mandatory
from SysObjects A, syscolumns B 
where A.name=@TNAME
and   A.Id=B.Id
) 


