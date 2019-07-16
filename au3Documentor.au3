#include "ault\ErrorHandler.au3"
#include "ault\Lexer.au3"

Global Enum Step *2 _
$AU3DOC_FLAG_AUTOLINECONT = 1, _
$AU3DOC_FLAG_NORESOLVEKEYWORD, _
$AU3DOC_FLAG_AUTOINCLUDE, _
$__AU3DOC_FLAG_LINECONT

; Constants for accessing a Token array
Global Enum _
$AU3DOC_TOKI_TYPE = 0, _
$AU3DOC_TOKI_DATA, _
$AU3DOC_TOKI_ABS, _
$AU3DOC_TOKI_LINE, _
$AU3DOC_TOKI_COL, _
$_AU3DOC_TOKI_COUNT

; Token types
Global Enum $AU3DOC_TOK_EOF = $AL_TOK_EOF, _ ; End of File
$AU3DOC_TOK_EOL = $AL_TOK_EOL, _ ; End of Line
$AU3DOC_TOK_OP = $AL_TOK_OP, _ ; Operator.
$AU3DOC_TOK_ASSIGN = $AL_TOK_ASSIGN, _ ; Operator.
$AU3DOC_TOK_KEYWORD = $AL_TOK_KEYWORD, _ ; Keyword. E.g. 'Func', 'Local' etc. (not used if $AL_FLAG_NORESOLVEKEYWORD is set)
$AU3DOC_TOK_FUNC = $AL_TOK_FUNC, _ ; Standard function (not used if $AL_FLAG_NORESOLVEKEYWORD is set)
$AU3DOC_TOK_WORD = $AL_TOK_WORD, _ ; Word (but not keyword or standard function)
$AU3DOC_TOK_OPAR = $AL_TOK_OPAR, _ ; (
$AU3DOC_TOK_EPAR = $AL_TOK_EPAR, _ ; )
$AU3DOC_TOK_OBRACK = $AL_TOK_OBRACK, _ ; [
$AU3DOC_TOK_EBRACK = $AL_TOK_EBRACK, _ ; ]
$AU3DOC_TOK_COMMA = $AL_TOK_COMMA, _ ; ,
$AU3DOC_TOK_STR = $AL_TOK_STR, _ ; " ... "
$AU3DOC_TOK_NUMBER = $AL_TOK_NUMBER, _ ; Integer, float, hex etc.
$AU3DOC_TOK_MACRO = $AL_TOK_MACRO, _ ; @...
$AU3DOC_TOK_VARIABLE = $AL_TOK_VARIABLE, _ ; $...
$AU3DOC_TOK_PREPROC = $AL_TOK_PREPROC, _; Preprocessor statement. NB returns whole line and does no processing apart from #cs and #ce
$AU3DOC_TOK_COMMENT = $AL_TOK_COMMENT, _ ; Comment. Includes multiline.
$AU3DOC_TOK_LINECONT = $AL_TOK_LINECONT, _ ; Line continuation _ (only used if $AL_FLAG_AUTOLINECONT not set)
$AU3DOC_TOK_INCLUDE = $AL_TOK_INCLUDE, _ ; Include statement
$AU3DOC_TOK_MAX

Global Enum $AU3DOC_LEXI_FILENAME = 0, _
        $AU3DOC_LEXI_DATA, _
        $AU3DOC_LEXI_FLAGS, _
        $AU3DOC_LEXI_ABS, _
        $AU3DOC_LEXI_LINE, _
        $AU3DOC_LEXI_COL, _
        $AU3DOC_LEXI_PARENT, _
        $AU3DOC_LEXI_INCLONCE, _
        $__AU3DOC_LEXI_COUNT

Global Enum $AU3DOC_ST_START = -1, _
    $AU3DOC_ST_NONE, _
    $AU3DOC_ST_DOCBLOCK, _
    $AU3DOC_ST_DOCBLOCKNL, _
    $AU3DOC_ST_DOCBLOCKEND, _
    $AU3DOC_ST_PREPROC, _
    $AU3DOC_ST_PREPROCLINE, _
    $AU3DOC_ST_PREPROCLINE_IGNORE

Func au3doc($sFile, $iFlags = $AL_FLAG_AUTOLINECONT + $AL_FLAG_AUTOINCLUDE)
    Local $l = _Ault_CreateLexer($sFile, $iFlags)
    Local $sData, $iType
    Local $prevTok = [0]
    Do
        $aTok = _Ault_LexerStep($l)
        If @error Then
            ConsoleWrite("Error: " & @error & @LF)
            ExitLoop
        EndIf
        ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
        If $prevTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT And $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOL Then ContinueLoop
            If $prevTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT And __au3doc_isDocBlock($prevTok[$AL_TOKI_DATA]) Then
                If  $aTok[$AL_TOKI_TYPE] = $AL_TOK_KEYWORD Then
                    Switch $aTok[$AL_TOKI_DATA]
                        Case "func", "local", "global", "const"
                            ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($prevTok[$AL_TOKI_TYPE]), $prevTok[$AL_TOKI_DATA]))
                            ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
                            Local $lex = __au3doc_CreateLexerFromString(StringFormat("%s#L%s", $l[$AL_LEXI_FILENAME], $prevTok[$AL_TOKI_LINE]), $prevTok[$AL_TOKI_DATA], $AL_FLAG_AUTOLINECONT)
                            Do
                                $aTok2 = _au3doc_LexerStep($lex)
                                If @error Then
                                    ConsoleWrite("Error: " & @error & @LF & $aTok2[0] & @LF)
                                    ExitLoop
                                EndIf
                                ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok2[$AU3DOC_TOKI_TYPE]), $aTok2[$AU3DOC_TOKI_DATA]))
                            Until $aTok2[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_EOF
                        Case "func"
                            ;look for Word, following func
                        Case "local", "global", "const", "dim", "static", "enum"
                            ;skip other keywords, capture var
                            ;handle cases where multiple vars are defined on the same line
                        EndSwitch
                ElseIf  $aTok[$AL_TOKI_TYPE] = $AL_TOK_VARIABLE Then
                    ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($prevTok[$AL_TOKI_TYPE]), $prevTok[$AL_TOKI_DATA]))
                    ;ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
                EndIf
            EndIf
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $aTok[$AL_TOKI_LINE]))
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $l[$AL_LEXI_FILENAME]));get fn for current token type
        $prevTok = $aTok
    Until $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOF And $aTok[$AL_TOKI_DATA] = ""
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

Func __au3doc_CreateLexerFromString($sName, $sData, $iFlags)
    Local $lexRet[$__AU3DOC_LEXI_COUNT]

    $lexRet[$AU3DOC_LEXI_FILENAME] = $sName
    $lexRet[$AU3DOC_LEXI_DATA] = $sData & @CRLF
    $lexRet[$AU3DOC_LEXI_FLAGS] = $iFlags

    $lexRet[$AU3DOC_LEXI_ABS] = 1
    $lexRet[$AU3DOC_LEXI_LINE] = 1
    $lexRet[$AU3DOC_LEXI_COL] = 1

    $lexRet[$AU3DOC_LEXI_PARENT] = 0
    $lexRet[$AU3DOC_LEXI_INCLONCE] = ";"

    Return $lexRet
EndFunc

Func _au3doc_LexerStep(ByRef $lex)
    Local $iState = $AU3DOC_ST_START
    Local $c, $c2, $anchor

    Local $tokRet[$AU3DOC_TOK_MAX] = [0, "", -1, -1, -1]

    If Not IsArray($lex) Then
        ConsoleWrite("Invalid lexer provided" & @LF)
        Return SetError(@ScriptLineNumber, 0, $tokRet)
    EndIf

    While 1
        $c = __au3doc_NextChar($lex)

        Switch $iState
            Case $AU3DOC_ST_START
                Select
                    Case $c = ""
                        If IsArray($lex[$AU3DOC_LEXI_PARENT]) Then
                            Local $sFileEnding = $lex[$AU3DOC_LEXI_FILENAME];TODO
                            Local $sInclOnce = $lex[$AU3DOC_LEXI_INCLONCE];TODO
                            $lex = $lex[$AU3DOC_LEXI_PARENT]
                            $lex[$AU3DOC_LEXI_INCLONCE] &= StringTrimLeft($sInclOnce, 1)

                            Return __AuTok_Make($AU3DOC_TOK_EOF, $sFileEnding, $lex[$AU3DOC_LEXI_ABS], $lex[$AU3DOC_LEXI_LINE], $lex[$AU3DOC_LEXI_COL])
                        EndIf

                        Return __au3doc_Make($AU3DOC_TOK_EOF, "", $lex[$AU3DOC_LEXI_ABS], $lex[$AU3DOC_LEXI_LINE], $lex[$AU3DOC_LEXI_COL])
                    Case __AuLex_StrIsNewLine($c)
                        If BitAND($lex[$AU3DOC_LEXI_FLAGS], $__AU3DOC_FLAG_LINECONT) Then
                            $lex[$AU3DOC_LEXI_FLAGS] = BitXOR($lex[$AU3DOC_LEXI_FLAGS], $__AU3DOC_FLAG_LINECONT)
                        Else
                            Return __AuTok_Make($AU3DOC_TOK_EOL, $c, $lex[$AU3DOC_LEXI_ABS] - StringLen($c), $lex[$AU3DOC_LEXI_LINE] - 1, -1)
                        EndIf
                    Case Not StringIsSpace($c)
                        ; Save token position
                        $tokRet[$AU3DOC_TOKI_ABS] = $lex[$AU3DOC_LEXI_ABS] - 1
                        $tokRet[$AU3DOC_TOKI_LINE] = $lex[$AU3DOC_LEXI_LINE]
                        $tokRet[$AU3DOC_TOKI_COL] = $lex[$AU3DOC_LEXI_COL] - 1

                        $iState = $AU3DOC_ST_NONE
                        __AuLex_PrevChar($lex)
                EndSelect
            Case $AU3DOC_ST_NONE
                Select
                    Case $c = "#"
                        $iState = $AU3DOC_ST_PREPROC
                    ;Case StringIsAlpha($c)
                        ;$iState = $AU3DOC_ST_KEYWORD
                    Case Else
                        ; ERROR: Invalid character
                        Return SetError(@ScriptLineNumber, 0, _
                                _Error_CreateLex("Invalid character '" & $c & "'", $lex))
                EndSelect
            Case $AU3DOC_ST_PREPROC
                If StringIsSpace($c) Or $c = "" Then
                    Switch StringStripWS(StringMid($lex[$AU3DOC_LEXI_DATA], $tokRet[$AU3DOC_TOKI_ABS], $lex[$AU3DOC_LEXI_ABS] - $tokRet[$AU3DOC_TOKI_ABS]), 2)
                        Case "#cs", "#comments-start"
                            $iState = $AU3DOC_ST_DOCBLOCK
                        ;Case "#include"
                        ;    If Not BitAND($lex[$AU3DOC_LEXI_FLAGS], $AU3DOC_FLAG_AUTOINCLUDE) Then ContinueCase
                        ;    $iState = $AU3DOC_ST_INCLUDELINE
                        ;Case "#include-once"
                        ;    If Not BitAND($lex[$AU3DOC_LEXI_FLAGS], $AU3DOC_FLAG_AUTOINCLUDE) Then ContinueCase

                        ;    Local $l = $lex, $fFound = False
                        ;    Do
                        ;        If StringInStr($l[$AU3DOC_LEXI_INCLONCE], ";" & $lex[$AU3DOC_LEXI_FILENAME] & ";") Then
                        ;            $fFound = True
                        ;            ExitLoop
                        ;        EndIf
                        ;        $l = $l[$AU3DOC_LEXI_PARENT]
                        ;    Until Not IsArray($l)

                        ;    ; Add to list if not already there.
                        ;    If Not $fFound Then
                        ;        $lex[$AU3DOC_LEXI_INCLONCE] &= $lex[$AU3DOC_LEXI_FILENAME] & ";"
                        ;    EndIf

                        ;    If __AuLex_StrIsNewLine($c) Then
                        ;        $iState = $AU3DOC_ST_START
                        ;    Else
                        ;        $iState = $AU3DOC_ST_PREPROCLINE_IGNORE
                        ;    EndIf
                        Case Else
                            If __AuLex_StrIsNewLine($c) Then
                                ; __AuLex_PrevChar($lex)
                                $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_PREPROC
                                ExitLoop
                            Else
                                $iState = $AU3DOC_ST_PREPROCLINE
                            EndIf
                    EndSwitch
                EndIf
            Case $AU3DOC_ST_PREPROCLINE
                If __AuLex_StrIsNewLine($c) Or $c = "" Then
                    ; __AuLex_PrevChar($lex)
                    $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_PREPROC
                    ExitLoop
                EndIf
            Case $AU3DOC_ST_PREPROCLINE_IGNORE
                If __AuLex_StrIsNewLine($c) Or $c = "" Then
                    $iState = $AU3DOC_ST_START
                EndIf
            ;Case $AU3DOC_ST_INCLUDELINE
                ;TODO
            Case $AU3DOC_ST_DOCBLOCK
                If __AuLex_StrIsNewLine($c) Then
                    $iState = $AU3DOC_ST_DOCBLOCKNL
                ElseIf $c = "" Then
                    ; ERROR: Multiline comment not terminated
                    Return SetError(@ScriptLineNumber, 0, _
                            _Error_CreateLex("Multiline comment not terminated", $lex))
                EndIf
            Case $AU3DOC_ST_DOCBLOCKNL
                If $c = "#" Then
                    $iState = $AU3DOC_ST_DOCBLOCKEND
                    $anchor = $lex[$AL_LEXI_ABS]
                ElseIf $c = "" Then
                    ; ERROR: Multiline comment not terminated
                    Return SetError(@ScriptLineNumber, 0, 0)
                ElseIf __AuLex_StrIsNewLine($c) Then
                    $iState = $AU3DOC_ST_DOCBLOCKNL
                Else
                    $iState = $AL_ST_COMMENTMULTI ; $AU3DOC_ST_DOCBLOCKEND
                EndIf
            Case $AU3DOC_ST_DOCBLOCKEND
                If StringIsSpace($c) Or $c = "" Then
                    Switch StringStripWS(StringMid($lex[$AU3DOC_LEXI_DATA], $anchor, $lex[$AU3DOC_LEXI_ABS] - $anchor), 2)
                        Case "ce", "comments-end"
                            __AuLex_PrevChar($lex)
                            $tokRet[$AL_TOKI_TYPE] = $AL_TOK_COMMENT
                            ExitLoop
                        Case Else
                            If __AuLex_StrIsNewLine($c) Then
                                $iState = $AU3DOC_ST_DOCBLOCKNL
                            Else
                                $iState = $AL_ST_COMMENTMULTI ; $AU3DOC_ST_DOCBLOCKEND
                            EndIf
                    EndSwitch
                EndIf
            Case Else
                ConsoleWrite("iState: "&$iState&@lf)
                ; Serious issue with the lexer.
                Return SetError(@ScriptLineNumber, 0, _
                        _Error_CreateLex("Lexer logic error", $lex))
        EndSwitch
    WEnd

    $tokRet[$AU3DOC_TOKI_DATA] = StringMid($lex[$AU3DOC_LEXI_DATA], _
            $tokRet[$AU3DOC_TOKI_ABS], $lex[$AU3DOC_LEXI_ABS] - $tokRet[$AU3DOC_TOKI_ABS])

    $tokRet[$AU3DOC_TOKI_DATA] = StringStripWS($tokRet[$AU3DOC_TOKI_DATA], 3)

    If $tokRet[$AU3DOC_TOKI_DATA] = "Or" Or $tokRet[$AU3DOC_TOKI_DATA] = "And" Then
        $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_OP
    ElseIf $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_WORD And _
            Not BitAND($lex[$AU3DOC_LEXI_FLAGS], $AU3DOC_FLAG_NORESOLVEKEYWORD) Then
        If _Ault_IsKeyword($tokRet[$AU3DOC_TOKI_DATA]) Then
            $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_KEYWORD
        ElseIf _Ault_IsStandardFunc($tokRet[$AU3DOC_TOKI_DATA]) Then
            $tokRet[$AU3DOC_TOKI_TYPE] = $AU3DOC_TOK_FUNC
        EndIf
    EndIf

    Return $tokRet
EndFunc

#cs
# used for lexing
#ce
Func __au3doc_lex($sFile, $sData, $iFlags)
    Return _Ault_CreateLexerFromString($sFile, $sData, $iFlags)
EndFunc

Func __au3doc_NextChar(ByRef $lex)
    Local $ret = __au3doc_PeekChar($lex)
    If $ret = "" Then Return ""
    
    $lex[$AU3DOC_LEXI_ABS] += StringLen($ret)

    If __AuLex_StrIsNewLine($ret) Then
        $lex[$AU3DOC_LEXI_LINE] += 1
        $lex[$AU3DOC_LEXI_COL] = 1
    Else
        $lex[$AU3DOC_LEXI_COL] += StringLen($ret)
    EndIf

    Return $ret
EndFunc

Func __au3doc_PeekChar(ByRef $lex)
    Local $ret = StringMid($lex[$AU3DOC_LEXI_DATA], $lex[$AU3DOC_LEXI_ABS], 1)

    If $ret = @CR Then
        Local $r2 = StringMid($lex[$AU3DOC_LEXI_DATA], $lex[$AU3DOC_LEXI_ABS] + 1, 1)

        If $r2 = @LF Then $ret = @CRLF
    EndIf

    Return $ret
EndFunc

Func __au3doc_Make($iType = 0, $sData = "", $iAbs = -1, $iLine = -1, $iCol = -1)
    Local $tokRet[$AU3DOC_TOK_MAX] = [$iType, $sData, $iAbs, $iLine, $iCol]
    Return $tokRet
EndFunc

au3doc("Examplefile.au3")
