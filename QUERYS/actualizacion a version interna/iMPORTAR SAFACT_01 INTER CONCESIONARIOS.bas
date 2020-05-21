'****************************************************************
'Microsoft SQL Server 2000
'Visual Basic file generated for DTS Package
'File Name: e:\Documents and Settings\jravelo\Mis documentos\CONCESIONARIOS\SAINT\SOLUCIONES\QUERYS\actualizacion a version interna\iMPORTAR SAFACT_01 INTER CONCESIONARIOS.bas
'Package Name: iMPORTAR SAFACT_01 INTER CONCESIONARIOS
'Package Description: Descripci�n del paquete DTS
'Generated Date: 18/07/2008
'Generated Time: 8:08:42
'****************************************************************

Option Explicit
Public goPackageOld As New DTS.Package
Public goPackage As DTS.Package2
Private Sub Main()
	set goPackage = goPackageOld

	goPackage.Name = "iMPORTAR SAFACT_01 INTER CONCESIONARIOS"
	goPackage.Description = "Descripci�n del paquete DTS"
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
	oConnection.ConnectionProperties("Initial Catalog") = "libertycarsadmindb"
	oConnection.ConnectionProperties("Data Source") = "CONSULTOR"
	oConnection.ConnectionProperties("Application Name") = "Asistente para importaci�n/exportaci�n con DTS"
	
	oConnection.Name = "Conexi�n1"
	oConnection.ID = 1
	oConnection.Reusable = True
	oConnection.ConnectImmediate = False
	oConnection.DataSource = "CONSULTOR"
	oConnection.ConnectionTimeout = 60
	oConnection.Catalog = "libertycarsadmindb"
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
	oConnection.ConnectionProperties("Application Name") = "Asistente para importaci�n/exportaci�n con DTS"
	
	oConnection.Name = "Conexi�n2"
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

	oStep.Name = "Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Paso"
	oStep.Description = "Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Paso"
	oStep.ExecutionStatus = 1
	oStep.TaskName = "Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea"
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

'------------- call Task_Sub1 for task Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea (Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea)
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


'------------- define Task_Sub1 for task Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea (Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea)
Public Sub Task_Sub1(ByVal goPackage As Object)

Dim oTask As DTS.Task
Dim oLookup As DTS.Lookup

Dim oCustomTask1 As DTS.DataPumpTask2
Set oTask = goPackage.Tasks.New("DTSDataPumpTask")
Set oCustomTask1 = oTask.CustomTask

	oCustomTask1.Name = "Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea"
	oCustomTask1.Description = "Copy Data from SAFACT_01 to [Guayanautoadmindb].[dbo].[SAFACT_01] Tarea"
	oCustomTask1.SourceConnectionID = 1
	oCustomTask1.SourceSQLStatement = "select [TipoFac],[NumeroD],[Orden_de_Compra],[Orden_de_reparacion],[Placa],[Codigo],[Serial],[Color],[Fecha_venta],[Kilometraje],[Liquidacion],[Status],[Revisado],[Resultado],[Eliminar],[Apertura_OR],[Cierre_OR] from [libertycarsadmindb].[dbo].[SAFACT_01]"
	oCustomTask1.SourceSQLStatement = oCustomTask1.SourceSQLStatement & ""
	oCustomTask1.DestinationConnectionID = 2
	oCustomTask1.DestinationObjectName = "[Guayanautoadmindb].[dbo].[SAFACT_01]"
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
		
		Set oColumn = oTransformation.SourceColumns.New("TipoFac" , 1)
			oColumn.Name = "TipoFac"
			oColumn.Ordinal = 1
			oColumn.Flags = 8
			oColumn.Size = 1
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("NumeroD" , 2)
			oColumn.Name = "NumeroD"
			oColumn.Ordinal = 2
			oColumn.Flags = 8
			oColumn.Size = 10
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Placa" , 5)
			oColumn.Name = "Placa"
			oColumn.Ordinal = 5
			oColumn.Flags = 104
			oColumn.Size = 10
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Kilometraje" , 10)
			oColumn.Name = "Kilometraje"
			oColumn.Ordinal = 10
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 3
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Liquidacion" , 11)
			oColumn.Name = "Liquidacion"
			oColumn.Ordinal = 11
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Status" , 12)
			oColumn.Name = "Status"
			oColumn.Ordinal = 12
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Cierre_OR" , 17)
			oColumn.Name = "Cierre_OR"
			oColumn.Ordinal = 17
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Apertura_OR" , 16)
			oColumn.Name = "Apertura_OR"
			oColumn.Ordinal = 16
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Orden_de_Compra" , 3)
			oColumn.Name = "Orden_de_Compra"
			oColumn.Ordinal = 3
			oColumn.Flags = 104
			oColumn.Size = 20
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Orden_de_reparacion" , 4)
			oColumn.Name = "Orden_de_reparacion"
			oColumn.Ordinal = 4
			oColumn.Flags = 104
			oColumn.Size = 10
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Codigo" , 6)
			oColumn.Name = "Codigo"
			oColumn.Ordinal = 6
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Serial" , 7)
			oColumn.Name = "Serial"
			oColumn.Ordinal = 7
			oColumn.Flags = 104
			oColumn.Size = 35
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Color" , 8)
			oColumn.Name = "Color"
			oColumn.Ordinal = 8
			oColumn.Flags = 104
			oColumn.Size = 25
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Fecha_venta" , 9)
			oColumn.Name = "Fecha_venta"
			oColumn.Ordinal = 9
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Revisado" , 13)
			oColumn.Name = "Revisado"
			oColumn.Ordinal = 13
			oColumn.Flags = 104
			oColumn.Size = 3
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Resultado" , 14)
			oColumn.Name = "Resultado"
			oColumn.Ordinal = 14
			oColumn.Flags = 104
			oColumn.Size = 60
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.SourceColumns.New("Eliminar" , 15)
			oColumn.Name = "Eliminar"
			oColumn.Ordinal = 15
			oColumn.Flags = 104
			oColumn.Size = 1
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.SourceColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("TipoFac" , 1)
			oColumn.Name = "TipoFac"
			oColumn.Ordinal = 1
			oColumn.Flags = 8
			oColumn.Size = 1
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("NumeroD" , 2)
			oColumn.Name = "NumeroD"
			oColumn.Ordinal = 2
			oColumn.Flags = 8
			oColumn.Size = 10
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = False
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Placa" , 3)
			oColumn.Name = "Placa"
			oColumn.Ordinal = 3
			oColumn.Flags = 104
			oColumn.Size = 10
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Kilometraje" , 4)
			oColumn.Name = "Kilometraje"
			oColumn.Ordinal = 4
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 3
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Liquidacion" , 5)
			oColumn.Name = "Liquidacion"
			oColumn.Ordinal = 5
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Status" , 6)
			oColumn.Name = "Status"
			oColumn.Ordinal = 6
			oColumn.Flags = 104
			oColumn.Size = 15
			oColumn.DataType = 129
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Cierre_OR" , 7)
			oColumn.Name = "Cierre_OR"
			oColumn.Ordinal = 7
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
			oColumn.Precision = 0
			oColumn.NumericScale = 0
			oColumn.Nullable = True
			
		oTransformation.DestinationColumns.Add oColumn
		Set oColumn = Nothing

		Set oColumn = oTransformation.DestinationColumns.New("Apertura_OR" , 8)
			oColumn.Name = "Apertura_OR"
			oColumn.Ordinal = 8
			oColumn.Flags = 120
			oColumn.Size = 0
			oColumn.DataType = 135
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
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""TipoFac"") = DTSSource(""TipoFac"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""NumeroD"") = DTSSource(""NumeroD"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Placa"") = DTSSource(""Placa"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Kilometraje"") = DTSSource(""Kilometraje"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Liquidacion"") = DTSSource(""Liquidacion"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Status"") = DTSSource(""Status"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Cierre_OR"") = DTSSource(""Cierre_OR"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	DTSDestination(""Apertura_OR"") = DTSSource(""Apertura_OR"")" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "	Main = DTSTransformStat_OK" & vbCrLf
		oTransProps("Text") = oTransProps("Text") & "End Function"
		oTransProps("Language") = "VBScript"
		oTransProps("FunctionEntry") = "Main"
		
	Set oTransProps = Nothing

	oCustomTask1.Transformations.Add oTransformation
	Set oTransformation = Nothing

End Sub

