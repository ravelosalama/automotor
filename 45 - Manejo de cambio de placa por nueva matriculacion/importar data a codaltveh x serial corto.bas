'****************************************************************
'Microsoft SQL Server 2000
'Visual Basic file generated for DTS Package
'File Name: e:\Documents and Settings\jravelo\Mis documentos\importar data a codaltveh x serial corto.bas
'Package Name: Nuevo paquete
'Package Description: Descripción del paquete DTS
'Generated Date: 13/07/2008
'Generated Time: 10:49:40
'****************************************************************

Option Explicit
Public goPackageOld As New DTS.Package
Public goPackage As DTS.Package2
Private Sub Main()
	set goPackage = goPackageOld

	goPackage.Name = "Nuevo paquete"
	goPackage.Description = "Descripción del paquete DTS"
	goPackage.WriteCompletionStatusToNTEventLog = False
	goPackage.FailOnError = False
	goPackage.PackagePriorityClass = 2
	goPackage.MaxConcurrentSteps = 4
	goPackage.LineageOptions = 0
	goPackage.UseTransaction = True
	goPackage.TransactionIsolationLevel = 4096
	goPackage.AutoCommitTransaction = True
	goPackage.RepositoryMetadataOptions = 0
	goPackage.UseOLEDBServiceComponents = True
	goPackage.LogToSQLServer = False
	goPackage.LogServerFlags = 0
	goPackage.FailPackageOnLogFailure = False
	goPackage.ExplicitGlobalVariables = False
	goPackage.PackageType = 0
	

Dim oConnProperty As DTS.OleDBProperty

'---------------------------------------------------------------------------
' create package connection information
'---------------------------------------------------------------------------

Dim oConnection as DTS.Connection2

'------------- a new connection defined below.
'For security purposes, the password is never scripted

Set oConnection = goPackage.Connections.New("SQLOLEDB")

	oConnection.ConnectionProperties("Integrated Security") = "SSPI"
	oConnection.ConnectionProperties("Persist Security Info") = True
	oConnection.ConnectionProperties("Initial Catalog") = "Guayanautoadmindb"
	oConnection.ConnectionProperties("Data Source") = "CONSULTOR"
	oConnection.ConnectionProperties("Application Name") = "Asistente para importación/exportación con DTS"
	
	oConnection.Name = "Conexión1"
	oConnection.ID = 1
	oConnection.Reusable = True
	oConnection.ConnectImmediate = False
	oConnection.DataSource = "CONSULTOR"
	oConnection.ConnectionTimeout = 60
	oConnection.Catalog = "Guayanautoadmindb"
	oConnection.UseTrustedConnection = True
	oConnection.UseDSL = False
	
	'If you have a password for this connection, please uncomment and add your password below.
	'oConnection.Password = "<put the password here>"

goPackage.Connections.Add oConnection
Set oConnection = Nothing

'------------- a new connection defined below.
'For security purposes, the password is never scripted

Set oConnection = goPackage.Connections.New("SQLOLEDB")

	oConnection.ConnectionProperties("Integrated Security") = "SSPI"
	oConnection.ConnectionProperties("Persist Security Info") = True
	oConnection.ConnectionProperties("Initial Catalog") = "Guayanautoadmindb"
	oConnection.ConnectionProperties("Data Source") = "CONSULTOR"
	oConnection.ConnectionProperties("Application Name") = "Asistente para importación/exportación con DTS"
	
	oConnection.Name = "Conexión2"
	oConnection.ID = 2
	oConnection.Reusable = True
	oConnection.ConnectImmediate = False
	oConnection.DataSource = "CONSULTOR"
	oConnection.ConnectionTimeout = 60
	oConnection.Catalog = "Guayanautoadmindb"
	oConnection.UseTrustedConnection = True
	oConnection.UseDSL = False
	
	'If you have a password for this connection, please uncomment and add your password below.
	'oConnection.Password = "<put the password here>"

goPackage.Connections.Add oConnection
Set oConnection = Nothing

'---------------------------------------------------------------------------
' create package steps information
'---------------------------------------------------------------------------

Dim oStep as DTS.Step2
Dim oPrecConstraint as DTS.PrecedenceConstraint

'------------- a new step defined below

Set oStep = goPackage.Steps.New

	oStep.Name = "Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Paso"
	oStep.Description = "Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Paso"
	oStep.ExecutionStatus = 1
	oStep.TaskName = "Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea"
	oStep.CommitSuccess = False
	oStep.RollbackFailure = False
	oStep.ScriptLanguage = "VBScript"
	oStep.AddGlobalVariables = True
	oStep.RelativePriority = 3
	oStep.CloseConnection = False
	oStep.ExecuteInMainThread = False
	oStep.IsPackageDSORowset = False
	oStep.JoinTransactionIfPresent = False
	oStep.DisableStep = False
	oStep.FailPackageOnError = False
	
goPackage.Steps.Add oStep
Set oStep = Nothing

'---------------------------------------------------------------------------
' create package tasks information
'---------------------------------------------------------------------------

'------------- call Task_Sub1 for task Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea (Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea)
Call Task_Sub1( goPackage	)

'---------------------------------------------------------------------------
' Save or execute package
'---------------------------------------------------------------------------

'goPackage.SaveToSQLServer "(local)", "sa", ""
goPackage.Execute
goPackage.Uninitialize
'to save a package instead of executing it, comment out the executing package line above and uncomment the saving package line
set goPackage = Nothing

set goPackageOld = Nothing

End Sub


'------------- define Task_Sub1 for task Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea (Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea)
Public Sub Task_Sub1(ByVal goPackage As Object)

Dim oTask As DTS.Task
Dim oLookup As DTS.Lookup

Dim oCustomTask1 As DTS.DataPumpTask2
Set oTask = goPackage.Tasks.New("DTSDataPumpTask")
Set oCustomTask1 = oTask.CustomTask

	oCustomTask1.Name = "Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea"
	oCustomTask1.Description = "Copy Data from SAPROD to [Guayanautoadmindb].[dbo].[SACCSCODALTVEH] Tarea"
	oCustomTask1.SourceConnectionID = 1
	oCustomTask1.SourceSQLStatement = "select [CodProd],[Descrip],[CodInst],[Descrip2],[Descrip3],[Refere],[Marca],[Unidad],[UndEmpaq],[CantEmpaq],[Precio1],[Precio2],[Precio3],[PrecioU],[CostAct],[CostPro],[CostAnt],[Existen],[ExUnidad],[ExistenCon],[ExUnidadCon],[Compro],[Pedido],[Minimo],[M"
	oCustomTask1.SourceSQLStatement = oCustomTask1.SourceSQLStatement & "aximo],[Tara],[DEsComp],[DEsComi],[DEsSeri],[DEsLote],[DEsVence],[EdoABP],[EsPublish],[EsImport],[EsExento],[EsEnser],[EsOferta],[EsPesa],[EsEmpaque],[ExDecimal],[DiasEntr],[FechaUV],[FechaUC],[Activo] from [Guayanautoadmindb].[dbo].[SAPROD]"
	oCustomTask1.DestinationConnectionID = 2
	oCustomTask1.DestinationObjectName = "[Guayanautoadmindb].[dbo].[SACCSCODALTVEH]"
	oCustomTask1.ProgressRowCount = 1000
	oCustomTask1.MaximumErrorCount = 0
	oCustomTask1.FetchBufferSize = 1
	oCustomTask1.UseFastLoad = True
	oCustomTask1.InsertCommitSize = 0
	oCustomTask1.ExceptionFileColumnDelimiter = "|"
	oCustomTask1.ExceptionFileRowDelimiter = vbCrLf
	oCustomTask1.AllowIdentityInserts = False
	oCustomTask1.FirstRow = 0
	oCustomTask1.LastRow = 0
	oCustomTask1.FastLoadOptions = 2
	oCustomTask1.ExceptionFileOptions = 1
	oCustomTask1.DataPumpOptions = 0
	
Call oCustomTask1_Trans_Sub1( oCustomTask1	)
		
		
goPackage.Tasks.Add oTask
Set oCustomTask1 = Nothing
Set oTask = Nothing

End Sub

Public Sub oCustomTask1_Trans_Sub1(ByVal oCustomTask1 As Object)

	Dim oTransformation As DTS.Transformation2
	Dim oTransProps as DTS.Properties
	Dim oColumn As DTS.Column
	Set oTransformation = oCustomTask1.Transformations.New("DTS.DataPumpTransformScript")
		oTransformation.Name = "AxScriptXform"
		oTransformation.TransformFlags = 63
		oTransformation.ForceSourceBlobsBuffered = 0
		oTransformation.ForceBlobsInMemory = False
		oTransformation.InMemoryBlobSize = 1048576
		oTransformation.TransformPhases = 4
		
		Set oColumn = oTransformation.SourceColumns.New("CodProd" , 1)
			oColumn.Name = "CodProd"
			oColumn.Ordinal = 1
			oColumn.Flags = 8
			oColumn.Size = 20
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Descrip" , 2)
			oColumn.Name = "Descrip"
			oColumn.Ordinal = 2
			oColumn.Flags = 104
			oColumn.Size = 40
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("CodInst" , 3)
			oColumn.Name = "CodInst"
			oColumn.Ordinal = 3
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 3
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Descrip2" , 4)
			oColumn.Name = "Descrip2"
			oColumn.Ordinal = 4
			oColumn.Flags = 104
			oColumn.Size = 40
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Descrip3" , 5)
			oColumn.Name = "Descrip3"
			oColumn.Ordinal = 5
			oColumn.Flags = 104
			oColumn.Size = 40
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Refere" , 6)
			oColumn.Name = "Refere"
			oColumn.Ordinal = 6
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Marca" , 7)
			oColumn.Name = "Marca"
			oColumn.Ordinal = 7
			oColumn.Flags = 104
			oColumn.Size = 20
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Unidad" , 8)
			oColumn.Name = "Unidad"
			oColumn.Ordinal = 8
			oColumn.Flags = 104
			oColumn.Size = 3
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("UndEmpaq" , 9)
			oColumn.Name = "UndEmpaq"
			oColumn.Ordinal = 9
			oColumn.Flags = 104
			oColumn.Size = 3
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("CantEmpaq" , 10)
			oColumn.Name = "CantEmpaq"
			oColumn.Ordinal = 10
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Precio1" , 11)
			oColumn.Name = "Precio1"
			oColumn.Ordinal = 11
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Precio2" , 12)
			oColumn.Name = "Precio2"
			oColumn.Ordinal = 12
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Precio3" , 13)
			oColumn.Name = "Precio3"
			oColumn.Ordinal = 13
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("PrecioU" , 14)
			oColumn.Name = "PrecioU"
			oColumn.Ordinal = 14
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("CostAct" , 15)
			oColumn.Name = "CostAct"
			oColumn.Ordinal = 15
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("CostPro" , 16)
			oColumn.Name = "CostPro"
			oColumn.Ordinal = 16
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("CostAnt" , 17)
			oColumn.Name = "CostAnt"
			oColumn.Ordinal = 17
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Existen" , 18)
			oColumn.Name = "Existen"
			oColumn.Ordinal = 18
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("ExUnidad" , 19)
			oColumn.Name = "ExUnidad"
			oColumn.Ordinal = 19
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("ExistenCon" , 20)
			oColumn.Name = "ExistenCon"
			oColumn.Ordinal = 20
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("ExUnidadCon" , 21)
			oColumn.Name = "ExUnidadCon"
			oColumn.Ordinal = 21
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Compro" , 22)
			oColumn.Name = "Compro"
			oColumn.Ordinal = 22
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Pedido" , 23)
			oColumn.Name = "Pedido"
			oColumn.Ordinal = 23
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Minimo" , 24)
			oColumn.Name = "Minimo"
			oColumn.Ordinal = 24
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Maximo" , 25)
			oColumn.Name = "Maximo"
			oColumn.Ordinal = 25
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Tara" , 26)
			oColumn.Name = "Tara"
			oColumn.Ordinal = 26
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 131
			oColumn.Precision = 28
			oColumn.NumericScale = 3
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DEsComp" , 27)
			oColumn.Name = "DEsComp"
			oColumn.Ordinal = 27
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DEsComi" , 28)
			oColumn.Name = "DEsComi"
			oColumn.Ordinal = 28
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DEsSeri" , 29)
			oColumn.Name = "DEsSeri"
			oColumn.Ordinal = 29
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DEsLote" , 30)
			oColumn.Name = "DEsLote"
			oColumn.Ordinal = 30
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DEsVence" , 31)
			oColumn.Name = "DEsVence"
			oColumn.Ordinal = 31
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EdoABP" , 32)
			oColumn.Name = "EdoABP"
			oColumn.Ordinal = 32
			oColumn.Flags = 104
			oColumn.Size = 5
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsPublish" , 33)
			oColumn.Name = "EsPublish"
			oColumn.Ordinal = 33
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsImport" , 34)
			oColumn.Name = "EsImport"
			oColumn.Ordinal = 34
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsExento" , 35)
			oColumn.Name = "EsExento"
			oColumn.Ordinal = 35
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsEnser" , 36)
			oColumn.Name = "EsEnser"
			oColumn.Ordinal = 36
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsOferta" , 37)
			oColumn.Name = "EsOferta"
			oColumn.Ordinal = 37
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsPesa" , 38)
			oColumn.Name = "EsPesa"
			oColumn.Ordinal = 38
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("EsEmpaque" , 39)
			oColumn.Name = "EsEmpaque"
			oColumn.Ordinal = 39
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("ExDecimal" , 40)
			oColumn.Name = "ExDecimal"
			oColumn.Ordinal = 40
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("DiasEntr" , 41)
			oColumn.Name = "DiasEntr"
			oColumn.Ordinal = 41
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 3
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("FechaUV" , 42)
			oColumn.Name = "FechaUV"
			oColumn.Ordinal = 42
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("FechaUC" , 43)
			oColumn.Name = "FechaUC"
			oColumn.Ordinal = 43
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Activo" , 44)
			oColumn.Name = "Activo"
			oColumn.Ordinal = 44
			oColumn.Flags = 24
			oColumn.Size = 0
			oColumn.DataType = 2
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Codprod" , 1)
			oColumn.Name = "Codprod"
			oColumn.Ordinal = 1
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("CodAlt" , 2)
			oColumn.Name = "CodAlt"
			oColumn.Ordinal = 2
			oColumn.Flags = 8
			oColumn.Size = 20
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Tipo" , 3)
			oColumn.Name = "Tipo"
			oColumn.Ordinal = 3
			oColumn.Flags = 104
			oColumn.Size = 1
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

	Set oTransProps = oTransformation.TransformServerProperties

		oTransProps("Text") = "'**********************************************************************" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "'  Visual Basic Transformation Script" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "'  Copy each source column to the" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "'  destination column" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "'************************************************************************" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "Function Main()" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Codprod"") = DTSSource(""CodProd"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""CodAlt"") = DTSSource(""Descrip2"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Tipo"") = DTSSource(""3"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	Main = DTSTransformStat_OK" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "End Function"
		oTransProps("Language") = "VBScript"
		oTransProps("FunctionEntry") = "Main"
		
	Set oTransProps = Nothing

	oCustomTask1.Transformations.Add oTransformation
	Set oTransformation = Nothing

End Sub

