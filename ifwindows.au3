#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Then
	Run("control sysdm.cpl")
ElseIf @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_7" Then
	Run("control /name Microsoft.System")
EndIf


