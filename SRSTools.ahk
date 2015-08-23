;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Leah T <msliatg@gmail.com>
;
; Script Function:
;	This script takes reddit comment links, quotes the comment, and returns the comment quoted with the link to your clipboard.
;

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
body := miniParser(jsonOut, "body")
body := ">[" body "](" link ")"
clipboard := body
TrayTip, Quote&Link, "Quote copied to clipboard", 5
return

URLDownloadToVar(url){ ; This takes a URL and downloads it to a variable
	out:= ComObjCreate("WinHttp.WinHttpRequest.5.1")
	out.Open("GET",url)
	out.Send()
	return out.ResponseText
}

miniParser(json, att) { ; Just a simple parser, only returns strings. json is the json string, and att is the attribute you're looking for.
	att := """" att
	att .= """:"
	start := InStr(json, att)
	start += StrLen(att) + 2
	stop := InStr(json, """,", false, start) - 1
	parsedJson := SubStr(json, start, stop-start)
	parsedJson := StrReplace(parsedJson, "\n\n" , "  `r")
	parsedJson := StrReplace(parsedJson, "\n\n" , "`r")
	parsedJson := StrReplace(parsedJson, "\""" , """")
	parsedJson := StrReplace(parsedJson, "\\" , "\")
	parsedJson := StrReplace(parsedJson, "\/" , "/")
	return parsedJson
}
