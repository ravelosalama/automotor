DECLARE @REFERE VARCHAR(25)
DECLARE @SIGUIENTE VARCHAR(25)
DECLARE @ACTUAL VARCHAR(25)
  
DECLARE MIREG CURSOR FOR
      SELECT REFERE
         FROM dbo.SAPROD AS X ORDER BY REFERE
      OPEN MIREG
      FETCH NEXT FROM MIREG INTO @REFERE
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
         SET @SIGUIENTE=@ACTUAL
         SET @ACTUAL=@REFERE
         IF @ACTUAL=@SIGUIENTE
            PRINT @aCTUAL
            FETCH NEXT FROM MIREG INTO @REFERE
      END
      CLOSE MIREG
      DEALLOCATE MIREG

 


 

 