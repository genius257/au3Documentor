#include "ault\ErrorHandler.au3"
#include "ault\Lexer.au3"

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
            If $prevTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then
                If  $aTok[$AL_TOKI_TYPE] = $AL_TOK_KEYWORD Then
                    Switch $aTok[$AL_TOKI_DATA]
                        Case "func", "local", "global", "const"
                            ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($prevTok[$AL_TOKI_TYPE]), $prevTok[$AL_TOKI_DATA]))
                            ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
                        EndSwitch
                ElseIf  $aTok[$AL_TOKI_TYPE] = $AL_TOK_VARIABLE Then
                    ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($prevTok[$AL_TOKI_TYPE]), $prevTok[$AL_TOKI_DATA]))
                    ConsoleWrite(StringFormat("%s: %s\n", __AuTok_TypeToStr($aTok[$AL_TOKI_TYPE]), $aTok[$AL_TOKI_DATA]))
                EndIf
            EndIf
        ; $AL_TOKI_ABS, _
        ; $AL_TOKI_LINE, _
        ; $AL_TOKI_COL, _
        ; $_AL_TOKI_COUNT
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $aTok[$AL_TOKI_LINE]))
        ;If $aTok[$AL_TOKI_TYPE] = $AL_TOK_COMMENT Then ConsoleWrite(StringFormat("%s\n", $l[$AL_LEXI_FILENAME]));get fn for current token type
        $prevTok = $aTok
    Until $aTok[$AL_TOKI_TYPE] = $AL_TOK_EOF And $aTok[$AL_TOKI_DATA] = ""
EndFunc

#cs
# used for lexing
#ce
Func __au3doc_lex()

EndFunc