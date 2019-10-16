#include <Array.au3>

#cs
# parsed to AutoIt from https://github.com/phpDocumentor/ReflectionDocBlock/blob/8fcadfe5f85c38705151c9ab23b4781f23e6a70e/src/DocBlockFactory.php
#ce

#cs
# Strips the asterisks from the DocBlock comment.
#
# @param string $comment String containing the comment text.
#ce
Func stripDocComment($comment)
    $comment = StringRegExpReplace(preg_replace('[ \t]*(?:\#cs|\#ce|\#)?[ \t]{0,1}(.*)?', '$1', $comment), "(?:^[ \t\n\r\0\x0B]|[ \t\n\r\0\x0B]$)", "");

    ; reg ex above is not able to remove #ce from a single line docblock
    if (StringRight($comment, 3) == '#ce') Then
        $comment = StringRegExpReplace(StringLeft($comment, StringLen($comment) -3), "(?:^[ \t\n\r\0\x0B]|[ \t\n\r\0\x0B]$)", "");
    EndIf

    return StringRegExpReplace($comment, "(?:\r\n|\r)", StringFormat("\n"))
EndFunc

#cs
# Splits the DocBlock into a template marker, summary, description and block of tags.
#
# @param string $comment Comment to split into the sub-parts.
#
# @author Richard van Velzen (@_richardJ) Special thanks to Richard for the regex responsible for the split.
# @author Mike van Riel <me@mikevanriel.com> for extending the regex with template marker support.
#
# @return string[] containing the template marker (if any), summary, description and a string containing the tags.
#ce
Func splitDocBlock($comment)
    ; Performance improvement cheat: if the first character is an @ then only tags are in this DocBlock. This
    ; method does not split tags so we return this verbatim as the fourth result (tags). This saves us the
    ; performance impact of running a regular expression
    If (StringInStr($comment, '@') - 1 == 0) Then
        local $return = ['', '', '', $comment]
        return $return;
    EndIf
    ; clears all extra horizontal whitespace from the line endings to prevent parsing issues
    $comment = preg_replace('/\h*$/Sum', '', $comment);TODO: test
    #cs
    # Splits the docblock into a template marker, summary, description and tags section.
    #
    # - The template marker is empty, #@+ or #@- if the DocBlock starts with either of those (a newline may
    #   occur after it and will be stripped).
    # - The short description is started from the first character until a dot is encountered followed by a
    #   newline OR two consecutive newlines (horizontal whitespace is taken into account to consider spacing
    #   errors). This is optional.
    # - The long description, any character until a new line is encountered followed by an @ and word
    #   characters (a tag). This is optional.
    # - Tags; the remaining characters
    #
    # Big thanks to RichardJ for contributing this Regular Expression
    #ce
    $matches = StringRegExp( _
        $comment, _
        '(?x)' & @crlf & _
        '\A' & @crlf & _
        '# 1. Extract the template marker' & @crlf & _
        '(?:(\#\@\+|\#\@\-)\n?)?' & @crlf & _
        '# 2. Extract the summary' & @crlf & _
        '(?:' & @crlf & _
        '  (?! @\pL ) # The summary may not start with an @' & @crlf & _
        '  (' & @crlf & _
        '    [^\n.]+' & @crlf & _
        '    (?:' & @crlf & _
        '      (?! \. \n | \n{2} )     # End summary upon a dot followed by newline or two newlines' & @crlf & _
        '      [\n.]* (?! [ \t]* @\pL ) # End summary when an @ is found as first character on a new line' & @crlf & _
        '      [^\n.]+                 # Include anything else' & @crlf & _
        '    )*' & @crlf & _
        '    \.?' & @crlf & _
        '  )?' & @crlf & _
        ')' & @crlf & _
        '# 3. Extract the description' & @crlf & _
        '(?:' & @crlf & _
        '  \s*        # Some form of whitespace _must_ precede a description because a summary must be there' & @crlf & _
        '  (?! @\pL ) # The description may not start with an @' & @crlf & _
        '  (' & @crlf & _
        '    [^\n]+' & @crlf & _
        '    (?: \n+' & @crlf & _
        '      (?! [ \t]* @\pL ) # End description when an @ is found as first character on a new line' & @crlf & _
        '      [^\n]+            # Include anything else' & @crlf & _
        '    )*' & @crlf & _
        '  )' & @crlf & _
        ')?' & @crlf & _
        '# 4. Extract the tags (anything that follows)' & @crlf & _
        '(\s+ [\s\S]*)? # everything that follows', _
        1 _
    );

    while (UBound($matches, 1) < 4)
        Redim $matches[UBound($matches, 1)+1]
        $matches[UBound($matches, 1)-1] = '';
    WEnd

    Return $matches;
EndFunc

#cs
# Creates the tag objects.
#
# @param string $tags Tag block to parse.
# @param Types\Context $context Context of the parsed Tag
#
# @return DocBlock\Tag[]|string[]|null[]
#ce
Func parseTagBlock($tags, $context)
    $tags = filterTagBlock($tags);
    if (Not $tags) Then
        Local $return = []
        return $return;
    EndIf
    $result = splitTagBlockIntoTagLines($tags);
    For $i = 0 To UBound($result)-1 Step +1
        $result[$i] = StringRegExpReplace($result[$i], "(?:^[ \t\n\r\0\x0B]|[ \t\n\r\0\x0B]$)", "")
    Next
    return $result;
EndFunc

#cs
# @return string[]
#ce
Func splitTagBlockIntoTagLines($tags)
    Local $result[0]
    For $tag_line In StringSplit($tags, StringFormat('\n'), 3)
        If StringLeft($tag_line, 1) == '@' Then
            Redim $result[UBound($result, 1) + 1]
            $result[UBound($result, 1) - 1] = $tag_line
        Else
            $result[UBound($result, 1) - 1] &= StringFormat("\n%s", $tag_line)
        EndIf
    Next
    return $result;
EndFunc

Func filterTagBlock($tags)
    $tags = StringRegExpReplace($tags, "(?:^[ \t\n\r\0\x0B]+|[ \t\n\r\0\x0B]+$)", "");
    if (Not $tags) Then
        return null;
    EndIf
    if Not ('@' == StringLeft($tags, 1)) Then
        ; Can't simulate this; this only happens if there is an error with the parsing of the DocBlock that
        ; we didn't foresee.
        Exit MsgBox(0, "", 'A tag block started with text instead of an at-sign(@): ' & $tags)
    EndIf
    return $tags;
EndFunc

Func preg_replace($pattern, $replace, $str)
    Return StringRegExpReplace($str, $pattern, $replace)
EndFunc

#cs
$result = stripDocComment(FileRead("test.txt"))
$result = splitDocBlock($result)
$result = parseTagBlock($result[3], "")

_ArrayDisplay($result)
#ce
