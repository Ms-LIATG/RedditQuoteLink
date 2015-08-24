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

; GUI BEGINS
IniRead, NP, keybinds.ini, QuoteAndLink, NP, 0
IniRead, CK, keybinds.ini, QuoteAndLink, ShowCommentKarma, 0
Gui,Add,Tab2,x0 y0 	w400 h150,Link||Settings
Gui,Tab,1
Gui,Add,Button,x320 y110 w70 h30 gCancelButton,Cancel
Gui,Add,Button,x10 y110 w70 h30 gOKButton,OK
Gui,Add,Edit,x10 y60 w340 h21 vlink,
Gui,Add,DropDownList,x350 y60 w40 vcontext,0||1|2|3|4|5|6|7|8
Gui,Add,Text,x10 y40 w400 h13,Please drop the comment link into the box, and select context on the right
;Gui,Add,Checkbox,x10 y90 w300 h13 vquoteContext,Would you like to include the context in the quote?
Gui,Tab,2
Gui,Add,Checkbox,x10 y30 w70 h13 vNP Checked%NP%,NP or nah?
Gui,Add,Checkbox,x10 y50 w180 h13 vCK Checked%CK%,Include the comment's karma
Gui,Add,Text, x217 y50 w150 h13 center vHK,Hotkey to open this window
Gui,Add,Hotkey,x230 y65 w120 h21 vLinkKeyTemp, %LinkKey%
Gui,Add,Button,x10 y110 w70 h30 gApplyButton,Apply
Gui,Add,Button,x320 y110 w70 h30 gCancelButton,Cancel
Gui,Show, w400 h150 Center xCenter yCenter,
return
CancelButton:
GuiClose:
Gui, destroy
return
ApplyButton:
Gui, submit
Gui, Show
IniWrite, %CK%, keybinds.ini, QuoteAndLink, showCommentKarma
IniWrite, %NP%, keybinds.ini, QuoteAndLink, NP
if LinkKeyTemp
{
	LinkKey := LinkKeyTemp
}
IniWrite, %LinkKey%, keybinds.ini, QuoteAndLink, linkKey
return
OKButton:
Gui, submit
Gui, destroy
; GUI END

; saving np to file so it is remembered last time
IniWrite, %NP%, keybinds.ini, QuoteAndLink, NP
IniWrite, %CK%, keybinds.ini, QuoteAndLink, showCommentKarma
if LinkKeyTemp
{
	LinkKey := LinkKeyTemp
}
IniWrite, %LinkKey%, keybinds.ini, QuoteAndLink, linkKey

; checking for things like ?context=3 and removing them, then writing the JSON to jsonOut
QuoteContext=0
if(QuoteContext = 0) {
	IfInString, link, ?
		link := SubStr(link, 1, InStr(link, "?")-1)
	link .= ".json"
	jsonOut := URLDownloadToVar(link)

	; remodifying link so it's useful in the output
	link := SubStr(link, 1, StrLen(link)-5)
	if NP = 1
	{
		spot := InStr(link, "reddit")
		link := "https://np." SubStr(link, spot)
	}
	link .= "?context=" context

	; parsing the json and formatting the rest of the output
	body := miniParser(jsonOut, "body", 1, 1)
	body := ">[" body "](" link ")"
	if (CK = 1) { 
		score := miniParser(jsonOut, "score", 1, 1)
		if (score >= 0)
			score := "+" score
		body .= " [" score "]"
	}

	clipboard := body
	TrayTip, Quote&Link, "Quote copied to clipboard", 5 ;pops up a traytip to say that the quote was copied to the clipboard
}
; this will be added in a later version
;else {
;	while context >= 0
;	
;}


return ;end of main script, functions below



URLDownloadToVar(url){ ; This takes a URL and downloads it to a variable
	out:= ComObjCreate("WinHttp.WinHttpRequest.5.1")
	out.Open("GET",url)
	out.Send()
	return out.ResponseText
}

miniParser(json, att, occ=1, fromEnd = 0) { ; Just a simple parser, only returns strings. json is the json string, and att is the attribute you're looking for.
	att := """" att
	att .= """:"
	if (fromEnd = 1){
		occ := 1
		var := 1
		while inStr(json, att, false, 1, occ) != 0{
			var := inStr(json, att, false, 1, occ)
			occ++
		}
		start := var
	} else{
		start := InStr(json, att, false, 1, occ)
	}
	start += StrLen(att) + 2
	if SubStr(json, start - 1, 1) = """"{	
		stop := InStr(json, """,", false, start)
		parsedJson := SubStr(json, start, stop-start)
		parsedJson := StrReplace(parsedJson, "\n\n" , "  `r")
		parsedJson := StrReplace(parsedJson, "\n\n" , "`r")
		parsedJson := StrReplace(parsedJson, "\""" , """")
		parsedJson := StrReplace(parsedJson, "\\" , "\")
		parsedJson := StrReplace(parsedJson, "\/" , "/")
	}
	else
	{
		start -= 1
		stop := InStr(json, ",", false, start)
		parsedJson := SubStr(json, start, stop-start)
	}
	return parsedJson
}
