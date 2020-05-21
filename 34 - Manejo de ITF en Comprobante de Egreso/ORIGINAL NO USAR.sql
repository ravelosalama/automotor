SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- ************************************************************** 
-- * NOMBRE: VW_SBDTRN                                          *
-- * AUTOR:  infoproyectos@mipunto.com                          *
-- * FECHA:   18-02-2008                                        *
-- * DESCRIPCION:                                               *
-- * Crea una vista para incluir el idb/itf en la impresion     *
-- * de las cuentas contables del comprobante de cheques        *
-- * bancarios, permitiendonos totalizar el asiento con el itf  *
-- ************************************************************** 


-- CREA VISTA DE REGISTRO DE TRANSACCIONES BANCARIAS
IF EXISTS (SELECT TABLE_NAME 
	   FROM   INFORMATION_SCHEMA.VIEWS 
	   WHERE  TABLE_NAME = N'VW_SBDTRN')
    DROP VIEW VW_SBDTRN
GO

create view VW_SBDTRN AS
select t2.codbanc, t2.nope, t2.codcta, t2.descripcion, t2.monto, t2.mtodb, t2.mtocr 
from sbtran t1 
inner join sbdtrn t2 
on t1.nope=t2.nope 
where t1.cdcd=0
union all
select t2.codbanc, t1.operel, t2.codcta, t2.descripcion, t2.monto, t2.mtodb, t2.mtocr 
from sbtran t1 
inner join sbdtrn t2 
on t1.nope=t2.nope 
where t1.cdcd=3 and operel<>0
GO

BEGIN TRANSACTION SBDTRN
declare @NUMERRORS    INT

-- AGREGA TABLA EN GENERADOR DE REPORTES
INSERT INTO SATABL(TABLENAME,TABLEALIAS)
VALUES('VW_SBDTRN','VW_SBDTRN')

SET @NUMERRORS=@NUMERRORS+@@ERROR;

-- AGREGA CAMPOS EN GENERADOR DE REPORTES
INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'CodBanc', 'CodBanc', 'dtString', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'Nope', 'Nope', 'dtInteger', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'CodCta', 'CodCta', 'dtString', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'Descripcion', 'Descripcion', 'dtString', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'Monto', 'Monto', 'dtDouble', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'MtoDB', 'MtoDB', 'dtDouble', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

INSERT INTO SAFIEL (TABLENAME, FIELDNAME, FIELDALIAS, DATATYPE, SELECTABLE, SEARCHABLE, SORTABLE, AUTOSEARCH, MANDATORY)
VALUES ('WV_SBDTRN', 'MtoCR', 'MtoCR', 'dtDouble', 'T', 'T', 'T', 'F', 'F')
SET @NUMERRORS=@NUMERRORS+@@ERROR;

IF @NUMERRORS>0 ROLLBACK TRANSACTION SBDTRN
ELSE COMMIT TRANSACTION SBDTRN;


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- NOTA:
-- En el formato de cheques debemos enlazar las tablas por el campor NOPE 