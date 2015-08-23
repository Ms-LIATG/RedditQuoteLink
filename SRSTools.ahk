;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Leah T <msliatg@gmail.com>
;
; Script Function:
;	This script takes reddit comment links, 
;

#Include %A_ScriptDir%
#Include JSON.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IniRead, LinkKey, keybinds.ini, QuoteAndLink, linkKey, ^+l ;reads the input file for the hotkey
Hotkey, %LinkKey%, linkInput

return

linkInput: 
; ask for input
InputBox, link, Quote and Link, Please drop the comment link into the box
throwaLink := link
; checking for things like ?context=3 and removing them to retrieve the json. Copy is kept so link is fully intact
IfInString, link, ?
	throwaLink := SubStr(link, 1, InStr(link, "?")-1)
throwaLink .= ".json"
jsonOut := URLDownloadToVar(throwaLink)
parsedJson := JSON.Load(jsonOut)
MsgBox, %parsedJson%.body
return

URLDownloadToVar(url){ ; This takes a URL and downloads it to a variable
	hObject:= ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}