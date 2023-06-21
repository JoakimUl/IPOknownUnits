{ ; 
#NoEnv
#SingleInstance force
#NoTrayIcon
SendMode Input
#InstallKeybdHook
FileEncoding, UTF-8
#Persistent
ini = IPOKnownUnits.ini
pr := "%"
sc := ";"
iniread, fullpath, %ini%, System, fullpath

Fil := StrSplit(fullpath, ".")
Fil := Fil[1]
htmlfil := Fil ".html"
If fullpath =
fullpath := A_WorkingDir
Gui, -MinimizeBox -MaximizeBox
Gui, color, FFF8F0
Gui Font, s10 bold, Arial
Gui Add, Text, x6 BackgroundTrans,Path to KnownUnits:
Gui Font, s8, Arial
Gui Add, Edit, x30 w270 h20 R1 BackgroundTrans vGuipath, %fullpath%
Gui Font, s10, Arial
Gui Add, Button, x6 w24 yp-1 h24 BackgroundTrans gUnit, ...
Gui Font, s8, Arial
Gui Add, Button, x300 yp+0 h24 BackgroundTrans gGo , Convert to HTML
Gui Font, s10 bold, Arial
Gui Show, x200 y100, IP Office KnownUnits.csv - to HTML converter
Return
}
Unit:
{
FileSelectFile, tpath,,%A_WorkingDir% ,Select the Avaya IP Office KnownUnits.csv file, *.csv
If tpath =
Return
iniWrite, %tpath%, %ini%, System, fullpath
Fil := StrSplit(tpath, ".")
Fil := Fil[1]
htmlfil := Fil ".html"
GuiControl,, Guipath, %tpath%
Return
}
Go:
{
iniread, ver100, %ini%, Software, ver10.0
iniread, ver101, %ini%, Software, ver10.1
iniread, ver110, %ini%, Software, ver11.0
iniread, ver111, %ini%, Software, ver11.1
iniread, ver11X, %ini%, Software, ver11.X
iniread, fullpath, %ini%, System, fullpath
SplitPath, fullpath,, dir
Row =
Listan =
headern =
(
<!DOCTYPE html><html lang="en">
<head><title>IP Office Known Units</title>
<style>
body  { background-color: #000; font-family: arial, sans-serif; color: #DDE; cursor: default; font-size:18px;}
table { background-color: #262626; height:100%pr%; border-collapse:collapse; border:0; margin:0; padding:0;}
th {border: solid #626262 1px; color:#FFF; padding:0px 10px; font-style:normal; text-align:left; background-color:#777;}
td {border: solid #626262 1px; color:#FFF; padding:0px 10px; font-style:normal;}
a {color:white;}
a:hover {background-color:#69F;}
.btn { border:none; color:white; background: none; margin:0; padding:0; font-size:18px;}
.btn:hover {background-color: #69F;}
</style></head>
<body><b style="font-size:24px;">IP Office Known Units</b>
<table><th>Customer/Lic.</th><th>Link</th><th>Copy IP (VPN)</th><th>System</th><th>Software</th>`n
)
fileread, fullfile, %fullpath%
nlines = 0
Loop Parse, fullfile, `n
  ++nlines
nlines -= 1	
Filedelete, %htmlfil%
Loop, parse, fullfile, `n
{
	L := StrSplit(A_LoopField, ",")
	Nam := "<tr><td>" L[1] "</td>"
	Namn := L[1]
if FileExist(dir "\IP Office\LicencePage_" Namn ".html" )	
Nam := "<tr><td><a href='file:///" dir "/IP Office/LicencePage_" Namn ".html' title='Click for Licence page' target='_blank'>" Namn "</a></td>"
	MAC := "<td>" L[2] "</td>"
	Sys := L[3]
	Adr := L[4]
	cIP := "cp" . A_Index
	bID := "B" . A_Index
	Ver := L[5]
	SW := StrSplit(Ver, ".")
	SW := SW[1]SW[2]
	Vers := "<td style='" ver100 "'>" Ver "</td>"	
IF SW > 100
	Vers := "<td style='" ver101 "'>" Ver "</td>"
IF SW > 101
	Vers := "<td style='" ver110 "'>" Ver "</td>"
IF SW > 110
	Vers := "<td style='" ver111 "'>" Ver "</td>"
IF SW > 111
	Vers := "<td style='" ver11X "'>" Ver "</td>"

If nlines < %A_Index%
		Break 
IF Sys = IP 500 V2
{
Adm := "<td><a href='https://" Adr ":8443/WebMgmtEE/WebManagement.html' target='_blank'>Web Manager</a></td><td><button class='btn' title='Click to Copy IP Address' id='" bID "' onclick='" cIP "(document.getElementById(`""" bID ""`").innerHTML)'>"  Adr "</button></td>"
Typ := "<td style='background-color:#447;'>" L[3] "</td>"
} else {
Adm := "<td><a href='https://" Adr ":7070/WebManagement/WebManagement.html' target='_blank'>Web Manager</a></td><td><button class='btn' title='Click to Copy IP Address' id='" bID "' onclick='" cIP "(document.getElementById(`""" bID ""`").innerHTML)'>"  Adr "</button></td>"
Typ := "<td>" L[3] "</td>"
}
Row := Nam Adm Typ Vers "</tr> `n"
funks .= "function " cIP "(text) { window.prompt('Copy to clipboard: Ctrl+C, Enter', text); }`n"
Listan .= Row
IF Nam =
	Break
}
Listan := headern Listan "</table>`n<script>`n" funks "`n</script>`n</body></html>"
Filedelete, test.html
	fileappend, %Listan%, %htmlfil% ,Utf-8
sleep 1000
Run %htmlfil%
	Return
}
GuiClose:
ExitApp