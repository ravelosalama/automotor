USE LIBERTYCARSANUALDB;
GO

IF OBJECT_ID ('TG_AGREGA_RIF', 'TR') IS NOT NULL
   DROP TRIGGER TG_AGREGA_RIF;
GO

CREATE TRIGGER TG_AGREGA_RIF ON saclie
AFTER INSERT
AS 
SELECT
    ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
GO
 
DECLARE @ID3     VARCHAR(15)
DECLARE @Id_Alte VARCHAR(15)
 
BEGIN try

    SELECT 
       @ID3 = ID3,
       @Id_Alte= codclie
      
     FROM INSERTED
    
 END  try

BEGIN CATCH
    -- Execute error retrieval routine.
    EXECUTE usp_GetErrorInfo;
END CATCH;






