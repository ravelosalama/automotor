CREATE TRIGGER [ACTUALIZA FECHA REAL] ON [dbo].[SACOMP_01] 
FOR INSERT 
AS

-- ACTUALIZA CAMPOS FECHA REAL
 
DECLARE @CODOPER VARCHAR(10)
DECLARE @NUMEROD VARCHAR(20)
DECLARE @TIPOCOM VARCHAR(1)
DECLARE @FECHA_REAL DATETIME


BEGIN
SELECT  @NUMEROD=NUMEROD, @TIPOCOM=TIPOCOM FROM INSERTED

IF @TIPOCOM = 'H'  

SELECT @FECHA_REAL = FECHAI FROM SACOMP WHERE NUMEROD=@NUMEROD AND TIPOCOM=@TIPOCOM

UPDATE    SACOMP_01
SET   FECHA_REAL = @FECHA_REAL WHERE SACOMP_01.NUMEROD=@NUMEROD AND SACOMP_01.TIPOCOM = 'H'

END