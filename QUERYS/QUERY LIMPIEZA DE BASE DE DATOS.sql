  -- QUERY DE LIMPIEZA DE BASE DE DATOS SOLO TRANSACCIONES
-- SE MANTIENEN DATOS EN TABLAS MAESTRAS
-- CASO CONCESIONARIOS de la misma marca
-- ELABORADO POR: JOSE RAVELO / OM System Consulting, C.A.

-- COMPRAS --
DELETE FROM SACOMP
DELETE FROM SAITEMCOM
DELETE FROM SAACXP
DELETE FROM SAPAGCXP
DELETE FROM SATAXCOM
DELETE FROM SATAXITC
DELETE FROM SAECOM
DELETE FROM SAEPRV
DELETE FROM SASEPRCOM
DELETE FROM SACOMP_01
DELETE FROM SACOMP_02

-- VENTAS --

DELETE FROM SAFACT
DELETE FROM SAFACT_01
DELETE FROM SAFACT_02
DELETE FROM SAFACT_03
DELETE FROM SACFAC
DELETE FROM SACLICNV
DELETE FROM SAITEMFAC
DELETE FROM SAACXC
DELETE FROM SAPAGCXC
DELETE FROM SATAXCXC
DELETE FROM SATAXVTA
DELETE FROM SATAXITF
DELETE FROM SAECLI
DELETE FROM SAEVTA
DELETE FROM SASEPRFAC
DELETE FROM SASE_RETIVACXC

-- INVENTARIO --

DELETE FROM SAEPRD
DELETE FROM SAEOPI
DELETE FROM SAINITI
DELETE FROM SAOPEI
DELETE FROM SAITEMOPI


-- SERVICIOS --

DELETE FROM SAESRV

-- VENDEDORES --

DELETE FROM SAEVEN
DELETE FROM SACVEN

-- SERVIDORES --

DELETE FROM SAEMEC
DELETE FROM SACMEC

-- INSTRIMENTOS DE PAGO --

DELETE FROM SAETAR
DELETE FROM SAIPACXC
DELETE FROM SAIPAVTA

-- BANCOS --

DELETE FROM SBDTRN
DELETE FROM SBDIFE
DELETE FROM SBTRAN

-- TABLAS MAESTRAS

--DELETE FROM SAPROD
--DELETE FROM SAPROD_11_01
--DELETE FROM SAPROD_11_02
--DELETE FROM SAPROD_12_01
--DELETE FROM SAPROD_12_02
--DELETE FROM SAPROD_12_03
--DELETE FROM SACODBAR
--DELETE FROM SASERI
--DELETE FROM SAEXIS
--DELETE FROM SAIPRD




