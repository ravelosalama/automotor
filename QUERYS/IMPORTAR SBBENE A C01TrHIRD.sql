-- AGREGA REGISTROS NO COINCIDENTES DE INVENT EN SAPROD

INSERT INTO  LCARS001.LIBERTYCONTABDB.dbo.C01Thirds
            (ID_Third, Descrip, ID_OrgThird, dtDate, boStatus) 
                    
SELECT SUBSTRING(CodBene,1,15), Descripcion,  SUBSTRING(CodBene,1,15), GETDATE() , 1

FROM dbo.SBBENE  