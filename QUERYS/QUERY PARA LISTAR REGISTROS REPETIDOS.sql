DECLARE @CODCLIE VARCHAR(10)
DECLARE @SIGUIENTE VARCHAR(10)
DECLARE @ACTUAL VARCHAR(10)
  
DECLARE MIREG CURSOR FOR
      SELECT CODCLIE
         FROM dbo.SACLIE3 AS X ORDER BY CODCLIE
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @CODCLIE
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
         SET @SIGUIENTE=@ACTUAL
         SET @ACTUAL=@CODCLIE
         IF @ACTUAL=@SIGUIENTE
            PRINT @aCTUAL
            FETCH NEXT FROM MIREG INTO @CODCLIE
      END
      CLOSE MIREG
      DEALLOCATE MIREG

 