#NoTrayIcon

#include <au3Documentor.au3>

;au3doc(@ScriptFullPath)
;au3doc("C:\Program Files (x86)\AutoIt3\Include\Math.au3", $AL_FLAG_AUTOINCLUDE)
$au3doc = au3doc(@ScriptDir&"\Examplefile.au3")
;$au3doc = au3doc(@ScriptDir&"\..\AutoItObject-Internal\AutoItObject_Internal.au3", $AL_FLAG_AUTOLINECONT)
;$au3doc = au3doc(@ScriptDir&"\in\DllStructEx.au3", $AL_FLAG_AUTOLINECONT)

au3doc_to_file($au3doc, @ScriptDir&"\out")

Func au3doc_to_file($au3doc, $outdir)
    $hFile = FileOpen($outdir&"\au3doc.html", 2)
    If @error <> 0 Then Return SetError(1)
    FileWrite($hFile, "<!DOCTYPE html><html><head>")
    FileWrite($hFile, "<style>body{margin:0;padding:0;display:flex;flex-direction:row;}aside{flex:0 0 200px}main{height:100vh;overflow:auto;flex:1 1 auto;}</style>")
    FileWrite($hFile, "</head><body>")
    
    FileWrite($hFile, "<aside>")

    FileWrite($hFile, "<ul>")
    For $i = 0 To UBound($au3doc, 1) - 1
        FileWrite($hFile, '<li><a href="#item'&$i&'">')
        FileWrite($hFile, ($au3doc[$i])[0])
        FileWrite($hFile, "</a></li>")
    Next
    FileWrite($hFile, "</ul>")

    FileWrite($hFile, "</aside>")
    FileWrite($hFile, "<main>")

    For $i = 0 To UBound($au3doc, 1) - 1
        FileWrite($hFile, '<h2 id="item'&$i&'">')
        FileWrite($hFile, ($au3doc[$i])[0])
        FileWrite($hFile, "</h2>")
        FileWrite($hFile, "<q>")
        FileWrite($hFile, ($au3doc[$i])[1])
        FileWrite($hFile, "</q>")
        FileWrite($hFile, "<pre>")
        FileWrite($hFile, ($au3doc[$i])[2])
        FileWrite($hFile, "</pre>")
        FileWrite($hFile, "<code>")
        FileWrite($hFile, ($au3doc[$i])[3])
        FileWrite($hFile, "</code>")
        FileWrite($hFile, "<hr/>")
    Next

    FileWrite($hFile, "</main>")
    FileWrite($hFile, "</body></html>")
    FileClose($hFile)
EndFunc
