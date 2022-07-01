#include "ault\ErrorHandler.au3"
#include "ault\Lexer.au3"
#include "docBlock.au3"

Func au3doc($sFile, $iFlags = $AL_FLAG_AUTOLINECONT + $AL_FLAG_AUTOINCLUDE)
    Local $au3doc[100], $iAu3doc = 0

    Local $l = _Ault_CreateLexer($sFile, $iFlags)
    If @error <> 0 Then Return SetError(@error, @extended, 0)
    Local $sData, $iType
    Local $prevTok = [0]
    Do
        $aTok = _Ault_LexerStep($l)
        If @error Then
            ;ConsoleWrite($aTok[4]&@CRLF)
            ;ConsoleWrite("Error: " & @error & @LF)
            ConsoleWrite("Error: "&$aTok[$AULT_ERRI_MSG]&@CRLF)
            ConsoleWrite($aTok[$AULT_ERRI_FILE]&":"&$aTok[$AULT_ERRI_LINE]&":"&$aTok[$AULT_ERRI_COL]&@CRLF)
            ExitLoop
        EndIf
        ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
        If $prevTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT And $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOL Then ContinueLoop
            If $prevTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT And __au3doc_isDocBlock($prevTok[$AL_TOKI_DATA]) Then
                ConsoleWrite($prevTok[$AL_TOKI_DATA]&@CRLF&@CRLF&@CRLF)
                Switch $aTok[$AL_TOKI_TYPE]
                    Case $AL_TOK_KEYWORD
                        Switch $aTok[$AL_TOKI_DATA]
                            Case "func"
                                $aTok = _Ault_LexerStep($l)
                                If ($aTok[$AL_TOKI_TYPE] = $AL_TOK_WORD) Then
                                    $docBlock = splitDocBlock(stripDocComment($prevTok[$AL_TOKI_DATA]))
                                    $tags = parseTagBlock($docBlock[$docBlock_tags], "")

                                    __au3doc_arr_addDoc($au3doc, $iAu3doc, $aTok[$AL_TOKI_DATA], $docBlock[$docBlock_summary], $docBlock[$docBlock_description], $docBlock[$docBlock_tags], "", $prevTok[$AL_TOKI_LINE], $prevTok[$AL_TOKI_COL])
                                    ;ConsoleWrite("Function:"&@CRLF)
                                    ;ConsoleWrite(@TAB&"Name:        "&$aTok[$AL_TOKI_DATA]&@CRLF)
                                    ;ConsoleWrite(@TAB&"Summary:     "&$docBlock[$docBlock_summary]&@CRLF)
                                    ;ConsoleWrite(@TAB&"Description: "&$docBlock[$docBlock_description]&@CRLF)
                                    ;ConsoleWrite(@TAB&"Tags:        "&@CRLF&@TAB&@TAB&_ArrayToString($tags,@CRLF&@TAB&@TAB)&@CRLF)
                                EndIf
                                ;look for Word, following func
                            Case "local", "global", "const", "dim", "static", "enum"
                                Do
                                    $aTok = _Ault_LexerStep($l)
                                Until $aTok[$AL_TOKI_TYPE] = $AL_TOK_VARIABLE Or $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOF
                                ;handle cases where multiple vars are defined on the same line
                        EndSwitch
                        If $aTok[$AL_TOKI_TYPE] = $AL_TOK_VARIABLE Then ContinueCase
                    Case $AL_TOK_VARIABLE
                        ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($prevTok[$AL_TOKI_TYPE]), $prevTok[$AL_TOKI_DATA]))
                        ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
                        $docBlock = splitDocBlock(stripDocComment($prevTok[$AL_TOKI_DATA]))
                        $tags = parseTagBlock($docBlock[$docBlock_tags], "")
                        ;ConsoleWrite($docBlock[1]&@CRLF&_ArrayToString($tags)&@CRLF)
                        __au3doc_arr_addDoc($au3doc, $iAu3doc, $aTok[$AL_TOKI_DATA], $docBlock[$docBlock_summary], $docBlock[$docBlock_description], $docBlock[$docBlock_tags], "", $prevTok[$AL_TOKI_LINE], $prevTok[$AL_TOKI_COL])
                        ;ConsoleWrite("Variable:"&@CRLF)
                        ;ConsoleWrite(@TAB&"Name:        "&$aTok[$AL_TOKI_DATA]&@CRLF)
                        ;ConsoleWrite(@TAB&"Summary:     "&$docBlock[$docBlock_summary]&@CRLF)
                        ;ConsoleWrite(@TAB&"Description: "&$docBlock[$docBlock_description]&@CRLF)
                        ;ConsoleWrite(@TAB&"Tags:        "&@CRLF&@TAB&@TAB&_ArrayToString($tags,@CRLF&@TAB&@TAB)&@CRLF)
                EndSwitch
            EndIf
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $aTok[$AL_TOKI_LINE]))
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $l[$AL_LEXI_FILENAME]));get fn for current token type
        $prevTok = $aTok
    Until $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOF And $aTok[$AL_TOKI_DATA] = ""

    ReDim $au3doc[$iAu3doc]
    Return $au3doc
EndFunc

Func __au3doc_arr_addDoc(ByRef $arr, ByRef $index, $name, $summary, $description, $tags, $file, $line, $column)
    Local $doc[7]
    $doc[0] = $name
    $doc[1] = $summary
    $doc[2] = $description
    $doc[3] = $tags
    $doc[4] = $file
    $doc[5] = $line
    $doc[6] = $column

    ;ConsoleWrite("Index: "&$index&@CRLF)
    ;ConsoleWrite("Old: "&UBound($arr, 1)&@CRLF)
    ;ConsoleWrite("New: "&UBound($arr, 1) * 2&@CRLF)

    If UBound($arr, 1) <= ($index+1) Then ReDim $arr[UBound($arr, 1) * 2]
    $arr[$index] = $doc
    $index += 1
EndFunc

Func __au3doc_isDocBlock($sData)
    Local $sFile = "!comment!"
    Local $lex = _Ault_CreateLexerFromString($sFile, $sData, $AL_FLAG_AUTOLINECONT)
    Local $iState = $AL_ST_START
    Local $tokRet[$_AL_TOKI_COUNT] = [0, "", -1, -1, -1]
    Local $c
    While 1
        $c = __AuLex_NextChar($lex)
        Switch $iState
            Case $AL_ST_START
                Select
                    Case $c = ""
                        If IsArray($lex[$AL_LEXI_PARENT]) Then
                            Local $sFileEnding = $lex[$AL_LEXI_FILENAME]
                            Local $sInclOnce = $lex[$AL_LEXI_INCLONCE]
                            $lex = $lex[$AL_LEXI_PARENT]
                            $lex[$AL_LEXI_INCLONCE] &= StringTrimLeft($sInclOnce, 1)

                            Return __AuTok_Make($AL_TOK_EOF, $sFileEnding, $lex[$AL_LEXI_ABS], $lex[$AL_LEXI_LINE], $lex[$AL_LEXI_COL])
                        EndIf

                        Return __AuTok_Make($AL_TOK_EOF, "", $lex[$AL_LEXI_ABS], $lex[$AL_LEXI_LINE], $lex[$AL_LEXI_COL])
                    Case __AuLex_StrIsNewLine($c)
                        If BitAND($lex[$AL_LEXI_FLAGS], $__AL_FLAG_LINECONT) Then
                            $lex[$AL_LEXI_FLAGS] = BitXOR($lex[$AL_LEXI_FLAGS], $__AL_FLAG_LINECONT)
                        Else
                            Return __AuTok_Make($AL_TOK_EOL, $c, $lex[$AL_LEXI_ABS] - StringLen($c), $lex[$AL_LEXI_LINE] - 1, -1)
                        EndIf
                    Case Not StringIsSpace($c)
                        ; Save token position
                        $tokRet[$AL_TOKI_ABS] = $lex[$AL_LEXI_ABS] - 1
                        $tokRet[$AL_TOKI_LINE] = $lex[$AL_LEXI_LINE]
                        $tokRet[$AL_TOKI_COL] = $lex[$AL_LEXI_COL] - 1

                        $iState = $AL_ST_NONE
                        __AuLex_PrevChar($lex)
                EndSelect
            Case $AL_ST_NONE
                Select
                    Case $c = ";"
                        $iState = $AL_ST_COMMENT
                    Case $c = "#"
                        $iState = $AL_ST_PREPROC
                    Case $c = "_"
                        $c2 = __AuLex_PeekChar($lex)

                        If StringIsAlNum($c2) Or $c2 = "_" Then
                            $iState = $AL_ST_KEYWORD
                        ElseIf BitAND($lex[$AL_LEXI_FLAGS], $AL_FLAG_AUTOLINECONT) Then
                            $iState = $AL_ST_LINECONT
                        Else
                            $tokRet[$AL_TOKI_TYPE] = $AL_TOK_LINECONT
                            ExitLoop
                        EndIf
                    Case StringIsAlpha($c)
                        $iState = $AL_ST_KEYWORD
                    Case Else
                        ; ERROR: Invalid character
                        Return SetError(@ScriptLineNumber, 0, _
                                _Error_CreateLex("Invalid character '" & $c & "'", $lex))
                EndSelect
            Case $AL_ST_COMMENT
                Return False
                If $c = "" Or __AuLex_StrIsNewLine($c) Then
                    __AuLex_PrevChar($lex)
                    $tokRet[$AL_TOKI_TYPE] = $AL_TOK_COMMENT
                    ExitLoop
                EndIf
                Return False
            Case $AL_ST_COMMENTMULTI
                If __AuLex_StrIsNewLine($c) Then
                    $iState = $AL_ST_COMMENTMULTINL
                ElseIf $c = "" Then
                    ; ERROR: Multiline comment not terminated
                    Return SetError(@ScriptLineNumber, 0, _
                            _Error_CreateLex("Multiline comment not terminated", $lex))
                EndIf
            Case $AL_ST_COMMENTMULTINL
                If $c = "#" Then
                    $iState = $AL_ST_COMMENTMULTIEND
                    $anchor = $lex[$AL_LEXI_ABS]
                ElseIf $c = "" Then
                    ; ERROR: Multiline comment not terminated
                    Return SetError(@ScriptLineNumber, 0, 0)
                ElseIf __AuLex_StrIsNewLine($c) Then
                    $iState = $AL_ST_COMMENTMULTINL
                Else
                    $iState = $AL_ST_COMMENTMULTI
                EndIf
            Case $AL_ST_COMMENTMULTIEND
                If StringIsSpace($c) Or $c = "" Then
                    Switch StringStripWS(StringMid($lex[$AL_LEXI_DATA], $anchor, $lex[$AL_LEXI_ABS] - $anchor), 2)
                        Case "ce", "comments-end"
                            __AuLex_PrevChar($lex)
                            $tokRet[$AL_TOKI_TYPE] = $AL_TOK_COMMENT
                            ExitLoop
                        Case Else
                            If __AuLex_StrIsNewLine($c) Then
                                $iState = $AL_ST_COMMENTMULTINL
                            Else
                                $iState = $AL_ST_COMMENTMULTI
                            EndIf
                    EndSwitch
                EndIf
            Case $AL_ST_PREPROC
                If StringIsSpace($c) Or $c = "" Then
                    Switch StringStripWS(StringMid($lex[$AL_LEXI_DATA], $tokRet[$AL_TOKI_ABS], $lex[$AL_LEXI_ABS] - $tokRet[$AL_TOKI_ABS]), 2)
                        Case "#cs", "#comments-start"
                            $iState = $AL_ST_COMMENTMULTI
                        Case "#include"
                            If Not BitAND($lex[$AL_LEXI_FLAGS], $AL_FLAG_AUTOINCLUDE) Then ContinueCase
                            $iState = $AL_ST_INCLUDELINE
                        Case "#include-once"
                            If Not BitAND($lex[$AL_LEXI_FLAGS], $AL_FLAG_AUTOINCLUDE) Then ContinueCase

                            Local $l = $lex, $fFound = False
                            Do
                                If StringInStr($l[$AL_LEXI_INCLONCE], ";" & $lex[$AL_LEXI_FILENAME] & ";") Then
                                    $fFound = True
                                    ExitLoop
                                EndIf
                                $l = $l[$AL_LEXI_PARENT]
                            Until Not IsArray($l)

                            ; Add to list if not already there.
                            If Not $fFound Then
                                $lex[$AL_LEXI_INCLONCE] &= $lex[$AL_LEXI_FILENAME] & ";"
                            EndIf

                            If __AuLex_StrIsNewLine($c) Then
                                $iState = $AL_ST_START
                            Else
                                $iState = $AL_ST_PREPROCLINE_IGNORE
                            EndIf
                        Case Else
                            If __AuLex_StrIsNewLine($c) Then
                                ; __AuLex_PrevChar($lex)
                                $tokRet[$AL_TOKI_TYPE] = $AL_TOK_PREPROC
                                ExitLoop
                            Else
                                $iState = $AL_ST_PREPROCLINE
                            EndIf
                    EndSwitch
                EndIf
            Case $AL_ST_PREPROCLINE
                If __AuLex_StrIsNewLine($c) Or $c = "" Then
                    ; __AuLex_PrevChar($lex)
                    $tokRet[$AL_TOKI_TYPE] = $AL_TOK_PREPROC
                    ExitLoop
                EndIf
            Case $AL_ST_PREPROCLINE_IGNORE
                If __AuLex_StrIsNewLine($c) Or $c = "" Then
                    $iState = $AL_ST_START
                EndIf
            Case Else
                Return False
        EndSwitch
    WEnd
    Return True
EndFunc
