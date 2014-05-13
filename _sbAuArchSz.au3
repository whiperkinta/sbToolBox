
Global $sbszPath

Func _sbszSetPath($pathToExe)

	$sbszPath = $pathToExe

EndFunc   ;==>_sbszSetPath

Func _sbszRunCmd($command)

	Local $PID = Run(@ComSpec & " /c " & $sbszPath & " " & $command, "", @SW_HIDE, $STDOUT_CHILD)

	Return $PID

EndFunc   ;==>_sbszRunCmd

Func _sbszStdoutReadNRT($PID)

	Local $line
	Local $output = ""

	While 1
		$line = StdoutRead($PID)
		If @error Then ExitLoop
		$output = $output & $line
	WEnd

	Return $output

EndFunc   ;==>_sbszStdoutReadNRT


Func _sbszExtractTest($filePath, $destinationFolder, $password)

	Local $PID = _sbszRunCmd('x ' & '-o' & '"' & $destinationFolder & '"' & ' -p' & $password & ' -y ' & '"' & $filePath & '"')
	Local $result = _sbszStdoutReadNRT($PID)

	If StringInStr($result, "Everything is Ok") Then
		Return 1
	ElseIf StringInStr($result, "Wrong password") Then
		Return 2
	Else
		Return 0
	EndIf

EndFunc   ;==>_sbszExtractTest

Func _sbszCompactTest($folderPath, $destinationFile, $password)

	Local $PID = _sbszRunCmd('a ' & '"' & $destinationFile & '" "' & $folderPath & '\*"' & ' -p' & $password)
	Local $result = _sbszStdoutReadNRT($PID)

	If StringInStr($result, "Everything is Ok") Then
		Return 1
	Else
		Return 0
	EndIf

EndFunc   ;==>_sbszCompactTest