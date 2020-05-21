SELECT tab.name AS Tablename,
       user_seeks, user_scans, user_lookups, user_updates,
       last_user_seek, last_user_scan, last_user_lookup, last_user_update
FROM sys.dm_db_index_usage_stats ius 
INNER JOIN sys.tables tab ON (tab.object_id = ius.object_id)
WHERE database_id = DB_ID(N'LIBERTYCarsAnualDB') AND (tab.name = 'SAFACT' OR tab.name = 'SAITEMFAC' OR tab.name = 'SATAXVTA' OR tab.name = 'SAFACT_01' OR tab.name = 'SAFACT_02' OR tab.name = 'SAFACT_03' OR tab.name = 'SAFACT_04'OR tab.name = 'SAITEMFAC' OR tab.name = 'SACLPR' OR tab.name = 'SAACXC')
order by last_user_update 


-- CONSULTA DE TODAS LAS TABLAS Y CAMPOS DE FECHAS DE ACTUALIZACION
SELECT     ius.last_user_seek, ius.last_user_scan, ius.last_user_lookup, ius.last_user_update, tab.name, tab.create_date, tab.modify_date
FROM         sys.dm_db_index_usage_stats AS ius INNER JOIN
                      sys.tables AS tab ON tab.object_id = ius.object_id
WHERE     (ius.database_id = DB_ID(N'LIBERTYCarsAnualDB'))
ORDER BY tab.modify_date
   