-- CREA VISTA PARA MOSTRAR VALORES POSIBLES DE ROTACION EN SCROLL DE REPORTES


if exists (select * from dbo.sysobjects where id = object_id(N'[VISTA_TIPO_ROTACION]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view VISTA_TIPO_ROTACION
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW VISTA_TIPO_ROTACION
AS 

SELECT DISTINCT Rotacion 
FROM SAPROD_01 where Rotacion is not null and Rotacion<>' '
 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

