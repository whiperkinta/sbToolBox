#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=sbtbx.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=sbToolBox
#AutoIt3Wrapper_Res_Fileversion=1.0.0.14
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Salamy
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#pragma compile(AutoItExecuteAllowed, true)

Opt("TrayIconHide", 1) ;0=show, 1=hide tray icon
Opt("TrayMenuMode", 1) ;0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
Opt("ExpandEnvStrings", 1)

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <Constants.au3>
#include "_sbAuArchSz.au3"
#include <GuiMenu.au3>
#include <WinAPI.au3>
#include <GuiEdit.au3>
#include <Misc.au3>


If @OSArch = "X64" Then
	FileInstall(".\sbToolbox_x64.exe", @ScriptDir & "\sbToolbox_x64.exe", 1)
	Run("sbToolbox_x64.exe")
	Exit
EndIf


If _Singleton("sbToolBox", 1) = 0 Then
	MsgBox(16, "sbToolBox", "An instance of sbToolBox is already running!")
	Exit
EndIf


#Region ### START Koda GUI section ### Form=c:\apps space\bdtoolbox\bdtoolbox.kxf
$Form1 = GUICreate("sbToolBox", 641, 481, 192, 118)

$Edit1 = GUICtrlCreateEdit("", 134, 402, 503, 76, BitOR($WS_VSCROLL, $ES_READONLY), $WS_EX_STATICEDGE)
GUICtrlSetFont(-1, 7, 400, 0, "Lucida Console")
GUICtrlSetData(-1, "CONSOLE")

$Button1 = GUICtrlCreateButton("GRAB (slect)", 42, 448, 80, 25)

$Button2 = GUICtrlCreateButton("Check UPDATES", 8, 408, 65, 33, $BS_MULTILINE)

$Button3 = GUICtrlCreateButton("CFG .ini", 82, 408, 40, 33, $BS_MULTILINE)

$Button5 = GUICtrlCreateButton("R", 8, 448, 25, 25)
GUICtrlSetFont(-1, 10, 800)

Local $exStyles = BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER)
$ListView1 = _GUICtrlListView_Create($Form1, "", 4, 4, 633, 393, -1, -1, True) ; Last option Calls CoInitializeEx
;_GUICtrlListView_SetHoverTime($ListView1, 10)
_GUICtrlListView_SetExtendedListViewStyle($ListView1, $exStyles)
_GUICtrlListView_InsertColumn($ListView1, 0, "Name", 160)
_GUICtrlListView_InsertColumn($ListView1, 1, "Path", 400)
_GUICtrlListView_InsertColumn($ListView1, 2, "Type", 53)

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

Global $gmindex = -1
Global $gsindex = -1

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;pscheck()

;INSTALL 7Z

Global $7zPath = @TempDir & "\7z.exe"
$res = FileInstall(".\7z.exe", $7zPath, 1)
If $res = 0 Then
	_ConsoleLog("FileInstall Failed", "(" & $7zPath & " " & $res & ")")
ElseIf $res = 1 Then
	_ConsoleLog("FileInstall OK", "(" & $7zPath & " " & $res & ")")
EndIf

_sbszSetPath($7zPath)

Global $7zdPath = @TempDir & "\7z.dll"
$res = FileInstall(".\7z.dll", $7zdPath, 1)
If $res = 0 Then
	_ConsoleLog("FileInstall Failed", "(" & $7zdPath & " " & $res & ")")
ElseIf $res = 1 Then
	_ConsoleLog("FileInstall OK", "(" & $7zdPath & " " & $res & ")")
EndIf

;==>INSTALL 7Z


;INSTALL REST
FileInstall(".\back.png", @ScriptDir & "\back.png", 0)
FileInstall(".\toolboxa.ini", @ScriptDir & "\toolboxa.ini", 0)
FileInstall(".\toolboxb.ini", @ScriptDir & "\toolboxb.ini", 0)
FileInstall(".\settings.ini", @ScriptDir & "\settings.ini", 0)
DirCreate(@ScriptDir & "\icons")
FileInstall(".\icons\0.ico", @ScriptDir & "\icons\0.ico", 0)
FileInstall(".\icons\1.ico", @ScriptDir & "\icons\1.ico", 0)
FileInstall(".\icons\2.ico", @ScriptDir & "\icons\2.ico", 0)
FileInstall(".\icons\3.ico", @ScriptDir & "\icons\3.ico", 0)
FileInstall(".\icons\4.ico", @ScriptDir & "\icons\4.ico", 0)
FileInstall(".\icons\5.ico", @ScriptDir & "\icons\5.ico", 0)
FileInstall(".\icons\6.ico", @ScriptDir & "\icons\6.ico", 0)
FileInstall(".\icons\7.ico", @ScriptDir & "\icons\7.ico", 0)
FileInstall(".\icons\8.ico", @ScriptDir & "\icons\8.ico", 0)
FileInstall(".\icons\9.ico", @ScriptDir & "\icons\9.ico", 0)
;===>INSTALL REST


_GUICtrlListView_SetBkImage($ListView1, @ScriptDir & "\back.png")


Dim $aTools[1][20] ;0base


CommandRefresh()


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg

		Case $GUI_EVENT_CLOSE
			DllCall('ole32.dll', 'long', 'CoUinitialize')
			GUIDelete($Form1)
			Exit
		Case $Button1
			GrabSelection()
		Case $Button5
			CommandRefresh()
		Case $Button2
			CommandCheckUpdates()
		Case $Button3
			Local $toolbox = IniRead("settings.ini", "Settings", "toolbox", "toolbox.ini")
			ShellExecute(@ScriptDir & "\" & $toolbox)

	EndSwitch
WEnd


Func LoadIni($sIniPath, $sOSArch) ; Returns array containing the tools data OR sets @error to 1.

	Local $aToolsData[1][20]

	$aSectionName = IniReadSectionNames($sIniPath)
	If @error Then
		SetError(1) ; Can't read .ini file or no section names found.
	Else
		For $i = 1 To $aSectionName[0]


			$sAbout = IniRead($sIniPath, $aSectionName[$i], "about", "")

			$sGroups = IniRead($sIniPath, $aSectionName[$i], "groups", "000UNGROUPED")
			$aGroup = StringSplit($sGroups, ";")

			$sType = IniRead($sIniPath, $aSectionName[$i], "type", "bin")

			$sWebsite = IniRead($sIniPath, $aSectionName[$i], "website", "")


			$sRepository = ""
			$sOnline = IniRead($sIniPath, $aSectionName[$i], "online", "")
			If $sOnline = "" Then $sRepository = IniRead($sIniPath, $aSectionName[$i], "repository", "")

			$sLocal = IniRead($sIniPath, $aSectionName[$i], "local", "")
			If $sLocal = "" Then
				$sLocal = $aSectionName[$i] & ".exe"
			EndIf

			$sWorking = IniRead($sIniPath, $aSectionName[$i], "working", "")
			If $sWorking = "" Then
				$sWorking = @ScriptDir & "\TOOLS\" & $aSectionName[$i] & "\" & $sLocal
			ElseIf StringLeft($sWorking, 2) = ".\" Then
				$sWorking = @ScriptDir & StringTrimLeft($sWorking, 1)
			EndIf

			$sUninstall = IniRead($sIniPath, $aSectionName[$i], "uninstall", "")


			$sOnclick = IniRead($sIniPath, $aSectionName[$i], "onclick", 'If FileExists("%WORKING%") Then|Run("%WORKING%")|EndIf')

			$sOnuninstall = IniRead($sIniPath, $aSectionName[$i], "onuninstall", 'Run("%UNINSTALL%")')

			$sOnspecial = IniRead($sIniPath, $aSectionName[$i], "onspecial", "")


			If $sOSArch = "X64" Then


				$sRepository64 = ""
				$sOnline64 = IniRead($sIniPath, $aSectionName[$i], "online64", "")
				If $sOnline64 = "" Then $sRepository64 = IniRead($sIniPath, $aSectionName[$i], "repository64", "")

				$sLocal64 = IniRead($sIniPath, $aSectionName[$i], "local64", "")
				If $sLocal64 = "" Then
					$sLocal64 = $aSectionName[$i] & ".exe"
				EndIf

				$sWorking64 = IniRead($sIniPath, $aSectionName[$i], "working64", "")
				If $sWorking64 = "" Then
					$sWorking64 = @ScriptDir & "\TOOLS\" & $aSectionName[$i] & "\" & $sLocal64
				ElseIf StringLeft($sWorking64, 2) = ".\" Then
					$sWorking64 = @ScriptDir & StringTrimLeft($sWorking64, 1)
				EndIf

				$sUninstall64 = IniRead($sIniPath, $aSectionName[$i], "uninstall64", "")


				$sOnclick64 = IniRead($sIniPath, $aSectionName[$i], "onclick64", '')

				$sOnuninstall64 = IniRead($sIniPath, $aSectionName[$i], "onuninstall64", '')

				$sOnspecial64 = IniRead($sIniPath, $aSectionName[$i], "onspecial64", "")


				If $sOnline64 <> "" Then $sOnline = $sOnline64
				If $sRepository64 <> "" Then $sRepository = $sRepository64
				If $sLocal64 <> "" Then $sLocal = $sLocal64
				If $sWorking64 <> "" Then $sWorking = $sWorking64
				If $sUninstall64 <> "" Then $sUninstall = $sUninstall64
				If $sOnclick64 <> "" Then $sOnclick = $sOnclick64
				If $sOnuninstall64 <> "" Then $sOnuninstall = $sOnuninstall64
				If $sOnspecial64 <> "" Then $sOnspecial = $sOnspecial64


			EndIf


			If StringInStr($sWorking, @ScriptDir) Then
				$sWorkingDisplay = StringReplace($sWorking, @ScriptDir, ".")
			Else
				$sWorkingDisplay = $sWorking
			EndIf


			For $j = 1 To $aGroup[0]

				$d = UBound($aToolsData)
				ReDim $aToolsData[$d + 1][20]
				$d = $d - 1

				$aToolsData[$d][0] = $aSectionName[$i]
				$aToolsData[$d][1] = StringTrimLeft($aGroup[$j], 3)
				$aToolsData[$d][2] = $sOnline
				$aToolsData[$d][3] = $sRepository
				$aToolsData[$d][4] = $sLocal
				$aToolsData[$d][5] = $sType
				$aToolsData[$d][6] = $sWebsite
				$aToolsData[$d][7] = $sAbout
				$aToolsData[$d][8] = $sWorking
				$aToolsData[$d][9] = $sUninstall
				$aToolsData[$d][10] = $sOnclick
				$aToolsData[$d][11] = $sOnuninstall
				$aToolsData[$d][12] = $sOnspecial
				$aToolsData[$d][13] = $sWorkingDisplay
				$aToolsData[$d][14] = StringLeft($aGroup[$j], 3) & StringLeft($aSectionName[$i], 3)

			Next


		Next

		$d = UBound($aToolsData)
		ReDim $aToolsData[$d - 1][20]

		_ArraySort($aTools, 0, 0, 0, 14)

		Return $aToolsData
	EndIf

EndFunc   ;==>LoadIni


Func ListDefineColors($hListView) ; Defines the icons to be used. No error handling.

	Local $hImage = _GUIImageList_Create(16, 16, 3, 1)
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\0.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\1.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\2.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\3.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\4.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\5.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\6.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\7.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\8.ico")
	_GUIImageList_AddIcon($hImage, @ScriptDir & "\icons\9.ico")
	_GUICtrlListView_SetImageList($hListView, $hImage, 1)

EndFunc   ;==>ListDefineColors

Func ListPopulate($hListView, ByRef $aToolsData) ; Clear the list and fill with entries. No error handling.

	_GUICtrlListView_DeleteAllItems($hListView)

	For $i = 0 To UBound($aToolsData) - 1
		_GUICtrlListView_AddItem($hListView, $aToolsData[$i][0], 2)
		_GUICtrlListView_AddSubItem($hListView, $i, $aToolsData[$i][13], 1, 2)
		_GUICtrlListView_AddSubItem($hListView, $i, $aToolsData[$i][5], 2, 2)
	Next

EndFunc   ;==>ListPopulate

Func ListGroupItems($hListView, ByRef $aToolsData) ; Creates groups and sorts by group name. No error handling.

	$aGroups = _ArrayUnique($aToolsData, 2)
	_ArraySort($aGroups, 0, 1)

	_GUICtrlListView_EnableGroupView($hListView)

	For $i = 1 To $aGroups[0]
		_GUICtrlListView_InsertGroup($hListView, -1, $i, $aGroups[$i])
		_GUICtrlListView_SetGroupInfo($hListView, $i, $aGroups[$i], 0, BitOR($LVGS_COLLAPSIBLE, $LVGS_NORMAL))

	Next

	For $i = 0 To UBound($aToolsData) - 1
		_GUICtrlListView_SetItemGroupID($hListView, $i, _ArraySearch($aGroups, $aToolsData[$i][1], 1))
	Next

EndFunc   ;==>ListGroupItems

Func ListColorize($hListView, ByRef $aToolsData, $w = -1) ; Colorize all items or passed item (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aTools) - 1
			_GUICtrlListView_SetItemImage($hListView, $i, $aToolsData[$i][16])
			_GUICtrlListView_SetItemImage($hListView, $i, $aToolsData[$i][17], 1)
			_GUICtrlListView_SetItemImage($hListView, $i, $aToolsData[$i][15], 2)
		Next
	Else
		_GUICtrlListView_SetItemImage($hListView, $w, $aToolsData[$w][16])
		_GUICtrlListView_SetItemImage($hListView, $w, $aToolsData[$w][17], 1)
		_GUICtrlListView_SetItemImage($hListView, $w, $aToolsData[$w][15], 2)
	EndIf

EndFunc   ;==>ListColorize


Func CheckType(ByRef $aToolsData, $w = -1) ; Checks type all or passed item (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aToolsData) - 1
			Select
				Case $aToolsData[$i][5] = "pak"
					$aToolsData[$i][15] = 6
				Case $aToolsData[$i][5] = "bin"
					$aToolsData[$i][15] = 7
				Case $aToolsData[$i][5] = "ins"
					$aToolsData[$i][15] = 8
				Case $aToolsData[$i][5] = "win"
					$aToolsData[$i][15] = 9
			EndSelect
		Next
	Else
		Select
			Case $aToolsData[$w][5] = "pak"
				$aToolsData[$w][15] = 6
			Case $aToolsData[$w][5] = "bin"
				$aToolsData[$w][15] = 7
			Case $aToolsData[$w][5] = "ins"
				$aToolsData[$w][15] = 8
			Case $aToolsData[$w][5] = "win"
				$aToolsData[$w][15] = 9
		EndSelect
	EndIf

EndFunc   ;==>CheckType

Func CheckLocal(ByRef $aToolsData, $w = -1) ; Check local path for all or passed (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aToolsData) - 1
			If FileExists(@ScriptDir & "\TOOLS\" & $aToolsData[$i][0] & "\" & $aToolsData[$i][4]) Then
				$aToolsData[$i][16] = 4
			ElseIf $aToolsData[$i][5] = "win" Then
				$aToolsData[$i][16] = 5
			Else
				$aToolsData[$i][16] = 2
			EndIf
		Next
	Else
		If FileExists(@ScriptDir & "\TOOLS\" & $aToolsData[$w][0] & "\" & $aToolsData[$w][4]) Then
			$aToolsData[$w][16] = 4
		ElseIf $aToolsData[$w][5] = "win" Then
			$aToolsData[$w][16] = 5
		Else
			$aToolsData[$w][16] = 2
		EndIf
	EndIf

EndFunc   ;==>CheckLocal

Func CheckPath(ByRef $aToolsData, $w = -1) ; Checks if path exists for all or passed item (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aToolsData) - 1
			If FileExists($aToolsData[$i][8]) Then
				$aToolsData[$i][17] = 0
			Else
				$aToolsData[$i][17] = 2
			EndIf
		Next
	Else
		If FileExists($aToolsData[$w][8]) Then
			$aToolsData[$w][17] = 0
		Else
			$aToolsData[$w][17] = 2
		EndIf
	EndIf

EndFunc   ;==>CheckPath

Func CheckUninstall(ByRef $aToolsData, $w = -1) ; Check uninstall path for all or passed (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aToolsData) - 1
			If $aToolsData[$i][5] = "ins" Then
				If FileExists($aToolsData[$i][9]) Then
					$aToolsData[$i][18] = 1
				Else
					$aToolsData[$i][18] = 0
				EndIf
			EndIf
		Next
	Else
		If $aToolsData[$w][5] = "ins" Then
			If FileExists($aToolsData[$w][9]) Then
				$aToolsData[$w][18] = 1
			Else
				$aToolsData[$w][18] = 0
			EndIf
		EndIf
	EndIf

EndFunc   ;==>CheckUninstall


Func CheckUpdated(ByRef $aToolsData, $w = -1) ; Checks updated all or passed item (0base). No error handling.

	If $w < 0 Then
		For $i = 0 To UBound($aToolsData) - 1
			If $aToolsData[$i][3] <> "" Then
				$aToolsData[$i][16] = SizeCompareRepository(@ScriptDir & "\REPO\" & $aToolsData[$i][3], @ScriptDir & "\TOOLS\" & $aToolsData[$i][0] & "\" & $aToolsData[$i][4])
			Else
				$aToolsData[$i][16] = SizeCompareOnline($aToolsData[$i][2], @ScriptDir & "\TOOLS\" & $aToolsData[$i][0] & "\" & $aToolsData[$i][4])
			EndIf
		Next
	Else
		If $aToolsData[$w][3] <> "" Then
			$aToolsData[$w][16] = SizeCompareRepository(@ScriptDir & "\REPO\" & $aToolsData[$w][3], @ScriptDir & "\TOOLS\" & $aToolsData[$w][0] & "\" & $aToolsData[$w][4])
		Else
			$aToolsData[$w][16] = SizeCompareOnline($aToolsData[$w][2], @ScriptDir & "\TOOLS\" & $aToolsData[$w][0] & "\" & $aToolsData[$w][4])
		EndIf
	EndIf

EndFunc   ;==>CheckUpdated

Func SizeCompareOnline($sOnlinePath, $sLocalPath)

	$onlineSize = InetGetSize($sOnlinePath)
	$localSize = FileGetSize($sLocalPath)

	Select
		Case $sOnlinePath = ""
			Return 5
		Case $localSize = 0
			Return 2
		Case $onlineSize = 0
			Return 3
		Case $onlineSize <> $localSize
			Return 1
		Case $onlineSize = $localSize
			Return 0
	EndSelect

EndFunc   ;==>SizeCompareOnline

Func SizeCompareRepository($sOnlinePath, $sLocalPath)

	$onlineSize = FileGetSize($sOnlinePath)
	$localSize = FileGetSize($sLocalPath)

	Select
		Case $sOnlinePath = ""
			Return 5
		Case $localSize = 0
			Return 2
		Case $onlineSize = 0
			Return 3
		Case $onlineSize <> $localSize
			Return 1
		Case $onlineSize = $localSize
			Return 0
	EndSelect

EndFunc   ;==>SizeCompareRepository


Func GrabSelection()

	_ConsoleLog("Grabbing...", "")

	GUISetState(@SW_DISABLE, $Form1)
	GUISetCursor(1, 1, $Form1)

	HttpSetUserAgent("Mozilla/4.0")

	For $i = 0 To UBound($aTools) - 1
		If _GUICtrlListView_GetItemChecked($ListView1, $i) Then

			DirCreate(@ScriptDir & "\TOOLS\" & $aTools[$i][0])

			If $aTools[$i][3] <> "" Then
				FileCopy(@ScriptDir & "\REPO\" & $aTools[$i][3], @ScriptDir & "\TOOLS\" & $aTools[$i][0] & "\" & $aTools[$i][4], 1 + 8)
				_ConsoleLog("FileCopy", @error & " (" & $aTools[$i][4] & ")")
			Else
				InetGet($aTools[$i][2], @ScriptDir & "\TOOLS\" & $aTools[$i][0] & "\" & $aTools[$i][4], 1)
				_ConsoleLog("InetGet", @error & " (" & $aTools[$i][4] & ")")
			EndIf

			If $aTools[$i][5] = "pak" Then
				_ConsoleLog("Unpacking", $aTools[$i][4])
				$res = _sbszExtractTest(@ScriptDir & "\TOOLS\" & $aTools[$i][0] & "\" & $aTools[$i][4], @ScriptDir & "\TOOLS\" & $aTools[$i][0], "")
				If $res = 0 Then
					_ConsoleLog("_sbszExtractTest", $aTools[$i][4] & " 0 - can't extract")
				ElseIf $res = 2 Then
					_ConsoleLog("_sbszExtractTest", $aTools[$i][4] & " 2 - wrong password")
				ElseIf $res = 1 Then
					_ConsoleLog("_sbszExtractTest", $aTools[$i][4] & " 1 - success")
				EndIf
			EndIf

			CheckUpdated($aTools, $i)
			CheckPath($aTools, $i)
			CheckUninstall($aTools, $i)
			ListColorize($ListView1, $aTools, $i)

		EndIf
	Next

	GUISetState(@SW_ENABLE, $Form1)
	GUISetCursor(-1, 1, $Form1)

	_ConsoleLog("Done!", "")

EndFunc   ;==>GrabSelection

Func CommandRefresh()

	_ConsoleLog("Refreshing...", "")

	GUISetState(@SW_DISABLE, $Form1)
	GUISetCursor(1, 1, $Form1)

	$toolbox = IniRead("settings.ini", "Settings", "toolbox", "toolbox.ini")
	$arch = IniRead("settings.ini", "Settings", "forcearch", "")
	If $arch <> "" Then $arch = @OSArch

	$aTools = LoadIni(@ScriptDir & "\" & $toolbox, $arch)
	If @error Then
		_ConsoleLog("LoadIni Error", @ScriptDir & "\" & $toolbox & " for " & $arch)
		Exit
	Else
		_ConsoleLog("LoadIni OK", @ScriptDir & "\" & $toolbox & " for " & $arch)
	EndIf

	ListDefineColors($ListView1)

	_GUICtrlListView_BeginUpdate($ListView1)

	ListPopulate($ListView1, $aTools)

	ListGroupItems($ListView1, $aTools)

	CheckLocal($aTools)

	CheckPath($aTools)

	CheckType($aTools)

	CheckUninstall($aTools)

	ListColorize($ListView1, $aTools)

	_GUICtrlListView_EndUpdate($ListView1)

	GUISetState(@SW_ENABLE, $Form1)
	GUISetCursor(-1, 1, $Form1)

	_ConsoleLog("Done!", "")

EndFunc   ;==>CommandRefresh

Func CommandCheckUpdates()

	_ConsoleLog("Checking all for updates...", "")

	GUISetState(@SW_DISABLE, $Form1)
	GUISetCursor(1, 1, $Form1)

	CheckUpdated($aTools)

	ListColorize($ListView1, $aTools)

	GUISetState(@SW_ENABLE, $Form1)
	GUISetCursor(-1, 1, $Form1)

	_ConsoleLog("Done!", "")

EndFunc   ;==>CommandCheckUpdates


Func ExecuteRA($index, $zet)

	If $index >= 0 Then

		$file = FileOpen(@ScriptDir & "\r.a", 2 + 8)
		If $file = -1 Then
			_ConsoleLog("Executing Error", $zet & " " & $aTools[$index][0] & " - can't make run file")
			Return 0
		EndIf

		$aLines = StringSplit($aTools[$index][$zet], "|", 1)

		FileWriteLine($file, "#NoTrayIcon")

		For $j = 1 To $aLines[0]

			$aLines[$j] = StringReplace($aLines[$j], "%WORKING%", $aTools[$index][8])
			$aLines[$j] = StringReplace($aLines[$j], "%UNINSTALL%", $aTools[$index][9])

			FileWriteLine($file, $aLines[$j])

		Next
		FileClose($file)

		$file_loc = @ScriptDir & "\r.a"
		$file_exe = FileGetShortName(@AutoItExe & ' /AutoIt3ExecuteScript "' & $file_loc & '"')
		$pid = Run($file_exe)

		_ConsoleLog("Executing", $aTools[$index][0])

	EndIf

EndFunc   ;==>ExecuteRA


Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam) ; Handle WM_COMMAND messages
	Switch $iwParam

		Case 1000
			If $gsindex = 0 Then
				Run("Explorer.exe /select," & @ScriptDir & "\TOOLS\" & $aTools[$gmindex][0] & "\" & $aTools[$gmindex][4])
			Else
				Run("Explorer.exe /select," & $aTools[$gmindex][8])
			EndIf

		Case 2000
			ExecuteRA($gmindex, 12)

		Case 3000
			$msg = $aTools[$gmindex][7] & @CRLF & @CRLF & "-" & @CRLF & $aTools[$gmindex][2] & $aTools[$gmindex][3] & @CRLF & $aTools[$gmindex][4] & @CRLF & $aTools[$gmindex][5] & @CRLF & "-"
			MsgBox(0, $aTools[$gmindex][0], $msg, 0, $Form1)

		Case 4000
			ShellExecute($aTools[$gmindex][6])

		Case 5000
			$pid = Run(@ScriptDir & "\TOOLS\" & $aTools[$gmindex][0] & "\" & $aTools[$gmindex][4])
			_ConsoleLog("Executing", @ScriptDir & "\TOOLS\" & $aTools[$gmindex][0] & "\" & $aTools[$gmindex][1] & " (PID " & $pid & ")")

		Case 6000
			ExecuteRA($gmindex, 11)

	EndSwitch
EndFunc   ;==>WM_COMMAND

Func DisplaContextMenu($mindex, $sindex)

	If $mindex >= 0 Then

		$gmindex = $mindex
		$gsindex = $sindex

		Local $hMenu
		$hMenu = _GUICtrlMenu_CreatePopup()

		_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Browse", 1000)
		_GUICtrlMenu_InsertMenuItem($hMenu, 1, "", 0)

		_GUICtrlMenu_InsertMenuItem($hMenu, 2, "Command", 2000)
		_GUICtrlMenu_InsertMenuItem($hMenu, 3, "", 0)
		_GUICtrlMenu_InsertMenuItem($hMenu, 4, "About", 3000)
		_GUICtrlMenu_InsertMenuItem($hMenu, 5, "Website", 4000)
		_GUICtrlMenu_InsertMenuItem($hMenu, 6, "", 0)
		_GUICtrlMenu_InsertMenuItem($hMenu, 7, "Install", 5000)
		_GUICtrlMenu_InsertMenuItem($hMenu, 8, "Uninstall", 6000)

		;browse
		If $sindex > 0 Then
			If $aTools[$mindex][17] <> 0 Then
				_GUICtrlMenu_EnableMenuItem($hMenu, 0, 3)
			EndIf
		Else
			If $aTools[$mindex][16] = 2 Or $aTools[$mindex][16] = 5 Then
				_GUICtrlMenu_EnableMenuItem($hMenu, 0, 3)
			EndIf
		EndIf

		;command
		If $aTools[$mindex][12] = "" Then
			_GUICtrlMenu_EnableMenuItem($hMenu, 2, 3)
		EndIf

		;about
		;If $aTools[$mindex][8] = "" Then
		;	_GUICtrlMenu_EnableMenuItem($hMenu, 4, 3)
		;EndIf

		;website
		If $aTools[$mindex][6] = "" Then
			_GUICtrlMenu_EnableMenuItem($hMenu, 5, 3)
		EndIf

		;install
		If $aTools[$mindex][16] = 2 Or $aTools[$mindex][17] <> 2 Or $aTools[$mindex][5] <> "ins" Then
			_GUICtrlMenu_EnableMenuItem($hMenu, 7, 3)
		EndIf

		;uninstall
		If $aTools[$mindex][18] <> 1 Then
			_GUICtrlMenu_EnableMenuItem($hMenu, 8, 3)
		EndIf

		_GUICtrlMenu_TrackPopupMenu($hMenu, $Form1)
		_GUICtrlMenu_DestroyMenu($hMenu)

		Return True

	EndIf

EndFunc   ;==>DisplaContextMenu


Func ListView_HOTTRACK($iSubItem)
	Local $HotItem = _GUICtrlListView_GetHotItem($ListView1)
	;If $HotItem <> -1 Then _GUICtrlStatusBar_SetText($hStatus, "Hot Item: " & $HotItem & " SubItem: " & $iSubItem)
EndFunc   ;==>ListView_HOTTRACK

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
	$hWndListView = $ListView1
	If Not IsHWnd($ListView1) Then $hWndListView = GUICtrlGetHandle($ListView1)

	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $LVN_HOTTRACK ; Sent by a list-view control when the user moves the mouse over an item
					$tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
					ListView_HOTTRACK(DllStructGetData($tInfo, "SubItem"))
;~ 					_DebugPrint("$LVN_HOTTRACK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
;~ 							"-->IDFrom:" & @TAB & $iIDFrom & @LF & _
;~ 							"-->Code:" & @TAB & $iCode & @LF & _
;~ 							"-->Item:" & @TAB & DllStructGetData($tInfo, "Item") & @LF & _
;~ 							"-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
;~ 							"-->NewState:" & @TAB & DllStructGetData($tInfo, "NewState") & @LF & _
;~ 							"-->OldState:" & @TAB & DllStructGetData($tInfo, "OldState") & @LF & _
;~ 							"-->Changed:" & @TAB & DllStructGetData($tInfo, "Changed") & @LF & _
;~ 							"-->ActionX:" & @TAB & DllStructGetData($tInfo, "ActionX") & @LF & _
;~ 							"-->ActionY:" & @TAB & DllStructGetData($tInfo, "ActionY") & @LF & _
;~ 							"-->Param:" & @TAB & DllStructGetData($tInfo, "Param"))
					Return 0 ; allow the list view to perform its normal track select processing.
					;Return 1 ; the item will not be selected.
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					ExecuteRA(DllStructGetData($tInfo, "Index"), 10)
					;					_DebugPrint("$NM_DBLCLK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
					;							"-->IDFrom:" & @TAB & $iIDFrom & @LF & _
					;							"-->Code:" & @TAB & $iCode & @LF & _
					;							"-->Index:" & @TAB & DllStructGetData($tInfo, "Index") & @LF & _
					;							"-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
					;							"-->NewState:" & @TAB & DllStructGetData($tInfo, "NewState") & @LF & _
					;							"-->OldState:" & @TAB & DllStructGetData($tInfo, "OldState") & @LF & _
					;							"-->Changed:" & @TAB & DllStructGetData($tInfo, "Changed") & @LF & _
					;							"-->ActionX:" & @TAB & DllStructGetData($tInfo, "ActionX") & @LF & _
					;							"-->ActionY:" & @TAB & DllStructGetData($tInfo, "ActionY") & @LF & _
					;							"-->lParam:" & @TAB & DllStructGetData($tInfo, "lParam") & @LF & _
					;							"-->KeyFlags:" & @TAB & DllStructGetData($tInfo, "KeyFlags"))
					; No return value
				Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					DisplaContextMenu(DllStructGetData($tInfo, "Index"), DllStructGetData($tInfo, "SubItem"))
					;					_DebugPrint("$NM_RCLICK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
					;							"-->IDFrom:" & @TAB & $iIDFrom & @LF & _
					;							"-->Code:" & @TAB & $iCode & @LF & _
					;							"-->Index:" & @TAB & DllStructGetData($tInfo, "Index") & @LF & _
					;							"-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
					;							"-->NewState:" & @TAB & DllStructGetData($tInfo, "NewState") & @LF & _
					;							"-->OldState:" & @TAB & DllStructGetData($tInfo, "OldState") & @LF & _
					;							"-->Changed:" & @TAB & DllStructGetData($tInfo, "Changed") & @LF & _
					;							"-->ActionX:" & @TAB & DllStructGetData($tInfo, "ActionX") & @LF & _
					;							"-->ActionY:" & @TAB & DllStructGetData($tInfo, "ActionY") & @LF & _
					;							"-->lParam:" & @TAB & DllStructGetData($tInfo, "lParam") & @LF & _
					;							"-->KeyFlags:" & @TAB & DllStructGetData($tInfo, "KeyFlags"))
					;Return 1 ; not to allow the default processing
					Return 0 ; allow the default processing
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY


Func pscheck()

	$aformpos = WinGetPos($Form1)

	GUISetCursor(7, 1, $Form1)

	$val = ""
	While $val <> "bdxpd457"
		$val = InputBox("Confirmation", " ", "", "~M", 10, 10, $aformpos[0] + 40, $aformpos[1] + 70, -1, $Form1)
		If @error = 1 Then Exit
	WEnd

	GUISetCursor(-1, 1, $Form1)

EndFunc   ;==>pscheck


Func _ConsoleLog($event, $data)

	If $data <> "" Then
		_GUICtrlEdit_AppendText($Edit1, @CRLF & $event & ": " & $data)
	Else
		_GUICtrlEdit_AppendText($Edit1, @CRLF & $event)
	EndIf

EndFunc   ;==>_ConsoleLog
