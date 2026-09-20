Add-Type -AssemblyName System.IO.Compression.FileSystem

$docxPath = "c:\laragon\www\prestasiku\doc\rancangan_sistem.docx"
$outputPath = "c:\laragon\www\prestasiku\doc\rancangan_sistem_extracted.txt"

$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)
$entry = $zip.GetEntry("word/document.xml")
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xmlText = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

$xml = [xml]$xmlText
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

$paragraphs = $xml.SelectNodes("//w:p", $ns)
$lines = [System.Collections.Generic.List[string]]::new()

foreach ($p in $paragraphs) {
    $texts = $p.SelectNodes(".//w:t", $ns)
    $line = ($texts | ForEach-Object { $_.InnerText }) -join ""
    if ($line.Trim().Length -gt 0) {
        $lines.Add($line)
    }
}

[System.IO.File]::WriteAllLines($outputPath, $lines)
Write-Output "Successfully extracted $($lines.Count) lines to $outputPath"
